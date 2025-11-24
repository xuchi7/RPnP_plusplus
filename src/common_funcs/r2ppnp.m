% XXw (3, n)
% xxn (2, n)
function [R, t, cnt_trial, w, score] = r2ppnp(XXw, xxn, thv, nr1, ransac_p)
    if nargin < 3, thv = 0.01; end
    if nargin < 4, nr1 = 30; end
    if nargin < 5, ransac_p = 0.7; end
    % params
    pnp.XXw = XXw;
    pnp.xxn = xxn;
    pnp.xxv = xxn2xxv(xxn);
    pnp.npt = size(xxn, 2);
    pnp.nr1 = nr1;
    pnp.nr2 = nr1*2;
    pnp.thv = thv;
    pnp.th_cons = 0.01;
    pnp.step_r1 = pi / pnp.nr1;
    pnp.step_r2 = pi * 2 / pnp.nr2;
    pnp.bin_r1 = pnp.step_r1*0.5-pi*0.5: pnp.step_r1: pi*0.5;
    pnp.bin_r1a = pnp.bin_r1 - pnp.step_r1/3;
    pnp.bin_r1b = pnp.bin_r1 + pnp.step_r1/3;
    pnp.bin_r2 = pnp.step_r2*0.5-pi: pnp.step_r2: pi;
    pnp.grid_ipt = repmat(1:pnp.npt, pnp.nr1, 1)';
    pnp.grid_ir1 = repmat(1:pnp.nr1, pnp.npt, 1);
    pnp.ransac_p = ransac_p;
    rng(3, 'twister');
    % solve
    [R, t, cnt_trial, w, score] = ransac_rpnp(pnp);
end

function [best_R, best_t, cnt_trial, best_w, best_score] = ransac_rpnp(pnp)
    best_R = [];
    best_t = [];
    best_w = [];
    best_score = 0;
    % params
    % max_trials = min(300000, pnp.npt*(pnp.npt-1)/2);
    max_trials = min(5000, pnp.npt*(pnp.npt-1)/2);
    cnt_trial = 0;
    N = max_trials;
    pnp.thH = max(5, pnp.npt * 0.005);
    while cnt_trial < N
        cnt_trial = cnt_trial + 1;
        i0 = randi(pnp.npt);
        i1 = randi(pnp.npt);
        d = norm(pnp.xxv(:,i1)-pnp.xxv(:,i0));
        D = norm(pnp.XXw(:,i1)-pnp.XXw(:,i0));
        if d < pnp.thv*7 || D < 1e-3
            continue
        end
        % solve
        [R, t, w, score] = rpnp_trial(pnp, i0, i1);
        score = score / pnp.npt;
        if score > best_score
            best_R = R;
            best_t = t;
            best_w = w;
            best_score = score;
            % Update estimate of N
            tmp = max(score, 5/pnp.npt);
            tmp = min(max(1-tmp^2, 0.0001), 0.9999);
            tmp = log(1-pnp.ransac_p)/log(tmp);
            N = min(max_trials, tmp);
        end
    end
end

function [best_R, best_t, best_w, best_score] = rpnp_trial(pnp, i0, i1)
    best_R = [];
    best_t = [];
    best_w = [];
    best_score = 0;
    % let i0 near center
    if xnorm(pnp.xxn(:,i0)) > xnorm(pnp.xxn(:,i1))
        tmp = i0;
        i0 = i1;
        i1 = tmp;
    end
    % init param
    i2s = 1:pnp.npt;
    i2s = (i2s ~= i0) & (i2s ~= i1);
    v0 = pnp.xxv(:, i0);  % (3, 1)
    v1 = pnp.xxv(:, i1);
    v2 = pnp.xxv(:, i2s);
    X0 = pnp.XXw(:, i0);
    X1 = pnp.XXw(:, i1);
    X2 = pnp.XXw(:, i2s);  % (3, m)
    D1 = norm(X1-X0);
    D2 = xnorm(X2-repmat(X0, 1, pnp.npt-2));
    D3 = xnorm(X2-repmat(X1, 1, pnp.npt-2));  % (1, m)
    idx_valid = (D2 > 1e-5) & (D3 > 1e-5);
    m = sum(idx_valid);
    if m < 4
        return
    end
    if m < size(idx_valid, 2)
        v2 = v2(:, idx_valid);
        X2 = X2(:, idx_valid);  % (3, m)
        D2 = D2(idx_valid);
        D3 = D3(idx_valid);  % (1, m)
    end
    grid_ipt = pnp.grid_ipt(1:m,:);
    grid_ir1 = pnp.grid_ir1(1:m,:);
    % calc r2_base
    r2_base = param_r2_base(X0, X1, X2);
    % calc pst
    cg1 = clip(v0'*v1, -1, 1);
    cg2 = clip(v0'*v2, -1, 1);
    cg3 = clip(v1'*v2, -1, 1);
    sg1 = (1 - cg1.^2).^0.5;
    sg2 = (1 - cg2.^2).^0.5;
    l1 = cg1;
    l2 = cg2;
    C1 = sg1;
    C2 = sg2;
    k = D2/D1;
    A1 = k.*k;
    A2 = A1.*(C1^2)-C2.^2;
    A3 = l2.*cg3-l1;
    A4 = l1*cg3-l2;
    A5 = cg3;
    A6 = (D3.^2-D1^2-D2.^2)/(2*D1^2);
    A7 = 1-l1^2-l2.^2+l1*l2.*cg3+C1^2*A6;
    B4 = A6.^2-A1.*A5.^2;
    B3 = 2*(A3.*A6-A1.*A4.*A5);
    B2 = A3.^2+2*A6.*A7-A1.*A4.^2-A2.*A5.^2;
    B1 = 2*(A3.*A7-A2.*A4.*A5);
    B0 = A7.^2-A2.*A4.^2;  % (1, m)
    % calc y, t1s
    nr1 = pnp.nr1;
    t1s = tan(pnp.bin_r1) * C1;  % (1, nr1)
    mt1s = repmat(t1s, m, 1);  % (m, nr1)
    mB4 = repmat(B4', 1, nr1);
    mB3 = repmat(B3', 1, nr1);
    mB2 = repmat(B2', 1, nr1);
    mB1 = repmat(B1', 1, nr1);
    mB0 = repmat(B0', 1, nr1);
    mA4 = repmat(A4', 1, nr1);
    mA5 = repmat(A5', 1, nr1);
    Y0 = ((((mB4.*mt1s)+mB3).*mt1s+mB2).*mt1s+mB1).*mt1s+mB0;  % (m, nr1)
    tmp = mA4+mA5.*mt1s;
    Y0 = Y0 ./ max(tmp.^2, 1e-12);
    Y = abs(Y0);
    % calc i_l, j_l, t1_l, t2_l
    idx_b_l = Y < pnp.th_cons;
    i_l = grid_ipt(idx_b_l)';  % (1, l)
    j_l = grid_ir1(idx_b_l)';  % (1, l)
    t1_l = t1s(j_l);
    A3_l = A3(i_l);
    A4_l = A4(i_l);
    A5_l = A5(i_l);
    A6_l = A6(i_l);
    A7_l = A7(i_l);
    tmp1 = A6_l.*t1_l.^2+A3_l.*t1_l+A7_l;
    tmp2 = A4_l+A5_l.*t1_l;
    idx1 = abs(tmp2) > 1e-9;
    i_l = i_l(idx1);
    j_l = j_l(idx1);
    t1_l = t1_l(idx1);
    t2_l = -tmp1(idx1)./tmp2(idx1);
    % calc k d
    d1_l = l1+t1_l;
    d2_l = l2(i_l)+t2_l;
    tmpidx = (d2_l > 0.05) & (d1_l > 0.05);
    if sum(tmpidx) < 3
        return
    end
    d1_l = d1_l(tmpidx);
    d2_l = d2_l(tmpidx);
    i_l = i_l(tmpidx);
    j_l = j_l(tmpidx);
    
    % calc k jk
    l = length(i_l);
    nV_base = xnormalize_vec(xcross_vec(v0, v1));
    dir_r = sign(nV_base'*v2(:,i_l));
    dir_r(dir_r == 0) = -1;
    vd1 = v1*d1_l - repmat(v0,1,l);  % (3,l)
    vd2 = v2(:,i_l).*repmat(d2_l,3,1) - repmat(v0,1,l);  % (3,l)
    nX = xnormalize(cross(vd1, vd2));
    r2_l =acos(clip(nV_base'*nX, -1, 1)).*dir_r-r2_base(i_l);
    r2_l(r2_l >  pi) = r2_l(r2_l >  pi) - pi*2;
    r2_l(r2_l < -pi) = r2_l(r2_l < -pi) + pi*2;
    k_l = clip(floor((r2_l +pi) / pnp.step_r2), 0, pnp.nr2-1); % [0 nr2-1]
    jk_l = (j_l-1) * pnp.nr2 + k_l; % [0 nr1*nr2-1]
    
    % hist
    H = hist(jk_l,(1:pnp.nr1*pnp.nr2)-1);
    H = imfilter(H, fspecial('gaussian', 3), 'circular');
    H = reshape(H, pnp.nr2, pnp.nr1)';  % (nr1, nr2)
    Hd = imdilate(H, ones(3));
    maxH = max(H(:));
    idx_b_H = (H == Hd) & (H >= max(pnp.thH, maxH*0.7));
    score_m = H(idx_b_H);
    [j_m, k_m] = find(idx_b_H);
    [~, idx_scores] = sort(score_m, 'descend');
    % find best cam pose
    y = xnormalize_vec(X1-X0);
    z = xnormalize_vec(X2(:,1)-X0);
    x = xnormalize_vec(xcross_vec(y, z));
    z = xnormalize_vec(xcross_vec(x, y));
    Rm0 = [x, y, z];
    
    % for each local maximum
    sz = min(4, length(idx_scores));
    for ii = 1:sz
        i = idx_scores(ii);
        j = j_m(i);
        k = k_m(i); % [1 nr2]

        % init hough pose
        d1 = l1 + t1s(j);
        r2 = pnp.bin_r2(k);
        
        x = xnormalize_vec(xcross_vec(v0, v1));
        y = v1*d1-v0;
        ny = norm(y);
        s0 = ny / D1;
        y = y / ny;
        z = xnormalize_vec(xcross_vec(x, y));
        Rc0 = [x, y, z];
        tc0 = v0;
        
        c2 = cos(r2);
        s2 = sin(r2);
        Rcy = [c2, 0, s2; 0, 1, 0; -s2, 0, c2];
        R0 = Rc0*Rcy*Rm0';
        t0 = tc0/s0-R0*X0;
        
        % post process
        [~, err] = project_d_err(R0, t0, 1, pnp.XXw, pnp.xxv);
        ninlier = sum(err < pnp.thv);
        if ninlier < pnp.thH
            continue
        end
        weights = 2;
        if ninlier < m * 0.5, weights = [2 2]; end
        if ninlier < m * 0.1, weights = [2 2 2]; end
        [R, t, w, ~] = dsw_gn(R0, t0, pnp.XXw, pnp.xxv, pnp.thv, weights, 4, err);
                
        % select best
        score = sum(w>0.99999);
        if score > best_score
            best_R = R;
            best_t = t;
            best_w = w;
            best_score = score;
        end
    end
end

function r2_base = param_r2_base(X0, X1, X2)
    vX1 = X1 - X0;
    vX2 = X2 - repmat(X1, 1, size(X2, 2));
    nX2 = xnormalize(cross(repmat(vX1, 1, size(vX2, 2)), vX2));
    s = sign(nX2(:, 1)' * vX2);
    s(s == 0) = 1;
    r2_base = s .* acos(clip(nX2(:, 1)' * nX2, -1, 1));
end

function Y = xnormalize_vec(X)
    Y = X / norm(X);
end

function y = clip(x, a, b)
    y = min(max(x, a), b);
end

function c = xcross_vec(a,b)
    c = [a(2)*b(3)-a(3)*b(2);
         a(3)*b(1)-a(1)*b(3);
         a(1)*b(2)-a(2)*b(1)];
end