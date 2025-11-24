clear; clc; close all
initpath

% load test data
data = Dataset.real_star();

% load results
name = 'R2PPnP2+Finalize';
res = load(data.fname_testresults(name));

% deal gt
nTest = length(res.dR);
for k = 1:nTest
    D = data.vec{k};
    % gt
    inliers_gt{k} = calcInliers(D.gR, D.gt, D.X, D.x, D.K, D.th_pixel);
    ninliers_gt(k) = sum(inliers_gt{k});
    inlier_rates_gt(k) = mean(inliers_gt{k});
    % res
    R = squeeze(res.estm_Rs(k,:,:));
    t = squeeze(res.estm_ts(k,:))';
    inliers{k} = calcInliers(R, t, D.X, D.x, D.K, D.th_pixel);
    ninliers(k) = sum(inliers{k});
    inlier_rates(k) = mean(inliers{k});
    correct_inliers(k) = sum(inliers_gt{k} & inliers{k})/ninliers_gt(k);
end

mask = ninliers_gt >= 10;
fprintf('number of images: %d / %d\n', sum(mask), length(mask))

path_image = '../data/StarRiver/images_upright/';
load('imginfo.mat')

w1 = 300; w2 = 800; wspace = 10; 
h1 = 300; h2 = 450; htop = 35; 
fontsize = 18;
figure('pos',[0 100 w1+w2+wspace h2+htop])
set(gcf,'color','w')

for k = 1:nTest
        
    D = data.vec{k};
    x = D.x;
    X = D.X;
    K = D.K;
    gR = D.gR;
    gt = D.gt;
    % reprojection
    R = squeeze(res.estm_Rs(k,:,:));
    t = squeeze(res.estm_ts(k,:))';
    Xc = K * (R * X + repmat(t, 1, length(X)));
    xc = Xc(1:2,:) ./ repmat(Xc(3,:), 2, 1);
    % calc inlier
    err = xnorm(xc - x);
    iin = err < D.th_pixel;   
    % read image
    it = imginfo{k};
    qname = it.qname;
    rname = it.rnames(1,:);
    npos = strfind(res.name{k}, ',');
    assert(strcmp(qname(1:npos-1),res.name{k}(1:npos-1)));
    % if isempty(strfind(qname, 'snow')), continue, end
    tar = imread([path_image qname]);
    ref = imread([path_image rname]);
    % clear 
    clf
    % show ref
    subplot(121)
    set(gca,'unit','pix')
    set(gca,'pos',[0 h2-h1 w1 h1])    
    wref = size(ref,2); href = size(ref,1);
    if wref/href > w1/h1
        scale = w1/wref;
        htmp = href*scale;
        set(gca,'pos',[0 h2-htmp w1 htmp])
    else
        scale = h1/href;
    end
    imshow(imresize(ref,scale))
    title('starriver', 'fontsize', fontsize, 'fontname', 'times')
    % show query
    subplot(122)
    set(gca,'unit','pix')
    set(gca,'pos',[w1+wspace 0 w2 h2])        
    wtar = size(tar,2); htar = size(tar,1);
    if wtar/htar > w2/h2
        scale = w2/wtar;
        htmp = htar*scale;
        set(gca,'pos',[w1+wspace h2-htmp w2 htmp])
    else
        scale = h2/htar;
    end
    imshow(imresize(tar,scale))
    hold on
    scatter(x(1,:)*scale,x(2,:)*scale,6,'co','filled')
    scatter(x(1,:)*scale,x(2,:)*scale,'b.')
    scatter(x(1,iin)*scale,x(2,iin)*scale,12,'go')
    scatter(xc(1,iin)*scale,xc(2,iin)*scale,5,'yo','filled')
    title(sprintf('outlier: %.2f%% , rotation err: %.2f^o', (1-inlier_rates(k))*100, res.dR(k)), ...
        'fontsize', fontsize, 'fontname', 'times')
    hold off
    drawnow

    pause(1)
end
