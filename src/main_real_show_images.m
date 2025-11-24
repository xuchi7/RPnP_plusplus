clear; clc; close all
initpath

% idx-name
load ../data/RealData/idx-name/idxs.mat

% method list
infos = {   ...
    'P3P', 'RSC P3P', 'b-.', ...
    'P3P+OPnPGN', 'RSC P3P+OPnP+GN', 'b-', ...
    'P4P', 'RSC P4P', 'g-.', ...
    'P4P+OPnPGN', 'RSC P4P+OPnP+GN', 'g-', ...
    'R1PPnP', 'R1PPnP', 'r-.', ...
    'R2PPnP', 'R2PPnP', 'm-.', ...
    'R2PPnP+Finalize', 'RPnP++', 'm-', ...
    };

infos = reshape(infos, 3, []);
names = squeeze(infos(1, :));
dispnames = squeeze(infos(2, :));
styles = squeeze(infos(3, :));

feature_names = {'ORB', 'SURF', 'SIFT'};

iFea = 1;
    
feaname = feature_names{iFea};

dataPath = sprintf('../data/RealData/testData/%s_1_n/', feaname);
savePath = sprintf('../data/RealData/testResults/%s_1_n/', feaname);

% Scenes
subdirList = dir([dataPath '*.mat']);
nScene = length(subdirList);
nMethod = length(names);

for iScene = 1:nScene
    
    basename = subdirList(iScene).name;
    scenename = basename(1:end-4);
    disp(scenename);
            
    key = [feaname '_' scenename];
    tb = getfield(idxs,key);
    
    % load test data
    ifname = sprintf('%s%s', dataPath, basename);
    disp(ifname);
    mat = load(ifname);
    
    % load test results
    for iMethod = 1:nMethod
        name = names{iMethod};
        filename = sprintf('%s%s-%s.mat', savePath, basename, name);
        res(iMethod) = load(filename);
    end
    
    % save
    inlier_rates(iFea,iScene,:) = res(1).inlier_rate;
    for iMethod = 1:length(res)
        dRs(iFea,iScene,:,iMethod) = res(iMethod).dR;
        Rs(:,:,:,iMethod) = res(iMethod).estm_Rs;
        ts(:,:,iMethod) = res(iMethod).estm_ts;
    end
    
    nTest = length(res(1).dR);
    for iTest = 1:nTest
        D = mat.Data{iTest};
        s.width = D.width;
        s.height = D.height;
        s.X = D.XXw';
        s.x = D.xx';
        s.K = D.K;
        s.gR = D.R;
        s.gt = D.t';
        s.Rs = squeeze(Rs(iTest,:,:,:)); % [3,3,nMethod]
        s.ts = squeeze(ts(iTest,:,:)); % [3,nMethod]            
        s.ref = ['../data/RealImages/' scenename '/images/' tb{D.refIdx}];
        s.tar = ['../data/RealImages/' scenename '/images/' tb{D.tarIdx}];            
        results(iFea,iScene,iTest) = s;
    end
end

% show some images

iMethod = 7;

dRs1 = reshape(dRs(1,:,:,iMethod), [], 1);
irates1 = reshape(inlier_rates(1,:,:), [], 1);
res1 = reshape(results(1,:,:), [], 1);

idxs = [33 623 304 310 240 353 287 157 207 957 571 331 1 608 858 268 458 688 972 45 105 359 329];


w1 = 250; w2 = 500; wspace = 10; 
h1 = 300; h2 = 450; htop = 35; 
fontsize = 18;
figure('pos',[0 10 w1+w2+wspace h2+htop])
set(gcf,'color','w')

for i = idxs
    
    s = res1(i);
    ref = imread(s.ref);
    tar = imread(s.tar);
    orate = (1-irates1(i))*100;
    
    x = s.x;
    X = s.X;
    K = s.K;
    gR = s.gR;
    gt = s.gt;
    
    R = s.Rs(:,:,iMethod);
    t = s.ts(:,iMethod);
    
    Xc = K * (R * X + repmat(t, 1, length(X)));
    xc = Xc(1:2,:) ./ repmat(Xc(3,:), 2, 1);
    
    err = xnorm(xc - x);
    iin = err < 5;    
    
    scenename = s.ref(15:end);
    scenename = split(scenename, '/');
    scenename = scenename{1};
    scenename = strrep(scenename, '_', ' ');
        
    clf
    
    % ref
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
    title(sprintf('%s', scenename), 'fontsize', fontsize, 'fontname', 'times')
    
    % tar
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
    scatter(x(1,:)*scale,x(2,:)*scale,'b.')
    scatter(x(1,iin)*scale,x(2,iin)*scale,12,'go')
    scatter(xc(1,iin)*scale,xc(2,iin)*scale,5,'yo','filled')
    title(sprintf('outlier: %.2f%% , rotation err: %.2f^o', orate, dRs1(i)), ...
        'fontsize', fontsize, 'fontname', 'times')
    hold off
    
    pause(1)
end
