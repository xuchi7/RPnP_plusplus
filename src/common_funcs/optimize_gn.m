function [R, t, w, err] = optimize_gn(X, v, t0, thv, w, err, weight_order, max_iter)
    if sum(w>0.99999) < 5
        R = eye(3);
        t = t0;
        return
    end
    % prepare
    xx = v(1:2, :) ./ repmat(v(3,:), 2, 1);
    n = size(v, 2);
    zero3 = zeros(3, n);
    zero1 = zeros(1, n);
    one1 = ones(1, n);
    uu = xx(1, :);
    vv = xx(2, :);
    Ap = [X; 
          zero3;
          repmat(-uu, 3, 1).*X;
          t0(1)-t0(3)*uu;
          zero3;
          X;
          repmat(-vv, 3, 1).*X;
          t0(2)-t0(3)*vv];  % (20, n)
    Bp = -[one1; zero1; -uu; zero1; one1; -vv];  % (6, n)
    % init
    s = [0, 0, 0];
    R = eye(3);
    r = [1, 0, 0, 0, 1, 0, 0, 0, 1, 1];    
    % optimize
    best_R = R;
    best_t = t0;
    best_w = w;
    best_err = err;
    best_score = sum(w);
    for iter = 1:max_iter
        A = reshape(Ap .* repmat(w, 20, 1), 10, 2*n)';  % (n, 10)
        B = reshape(Bp .* repmat(w, 6, 1), 3, 2*n)';  % (n, 3)
        %try
        %    C = B\A;
        %catch
        %    break
        %end
        C = inv(B'*B+eye(3)*1e-3)*B'*A; % to avoid singularity of B
        M = A - B*C;
        MTM = M'*M;
        
        J = [2*s(1), -2*s(2), -2*s(3);
             2*s(2), 2*s(1), -2;
             2*s(3), 2, 2*s(1);
             2*s(2), 2*s(1), 2;
             -2*s(1), 2*s(2), -2*s(3);
             -2, 2*s(3), 2*s(2);
             2*s(3), -2, 2*s(1);
             2, 2*s(3), 2*s(2);
             -2*s(1), -2*s(2), 2*s(3);
             0, 0, 0];
        ds = -inv(J'*MTM*J+eye(3)*1e-3)*(r*MTM*J)';
        nds = norm(ds);
        % condition
        if nds < 1e-4
            break
        end
        
        s0 = s;
        ds0 = ds;
        for i = 0:2
            lstep = 0.1 / 2^i;
            if nds > lstep
                ds = ds / nds * lstep;
            end
            s = s + ds';
            % result
            r = [s(1)*s(1)-s(2)*s(2)-s(3)*s(3)+1, 2*s(1)*s(2)-2*s(3), 2*s(1)*s(3)+2*s(2), ...
                 2*s(1)*s(2)+2*s(3), -s(1)*s(1)+s(2)*s(2)-s(3)*s(3)+1, 2*s(2)*s(3)-2*s(1), ...
                 2*s(1)*s(3)-2*s(2), 2*s(2)*s(3)+2*s(1), -s(1)*s(1)-s(2)*s(2)+s(3)*s(3)+1, 1];

            scale = 1+sum(s.^2);
            R = reshape(r(1:9), 3, 3)' * (1/scale);
            t = (t0 + C*r') * (1/scale);
            [~, err] = project_d_err(R, t, 1., X, v);
            w = calc_weight(err, thv, weight_order);
            score = sum(w);

            if score >= best_score
                best_score = score;
                best_R = R;
                best_t = t;
                best_w = w;
                best_err = err;
                break
            else
                s = s0;
                ds = ds0;
            end
        end
    end
    
    % select best
    R = best_R;
    t = best_t;
    w = best_w;
    err = best_err;
end