clear; clc; close all
initpath

% load results
fname_data = sprintf('data/real_%s.mat', 'ORB');

infos = {   ...
    'P3P', 'RSC(P3P)', 'b-.', ...
    'P3P+OPnPGN', 'RSC(P3P)+OGN', 'b-', ...
    'P4P', 'RSC(RP4P)', 'g-.', ...
    'P4P+OPnPGN', 'RSC(RP4P)+OGN', 'g-', ...
    'R1PPnP', 'R1PPnP', 'r-.', ...
    'R2PPnP', 'R2PPnP', 'm-.', ...
    'R2PPnP+Finalize', 'Ours', 'm-', ...
};

infos = reshape(infos, 3, []);
names = squeeze(infos(1, :));
dispnames = squeeze(infos(2, :));
styles = squeeze(infos(3, :));
    
testDataPath = sprintf('../data/RealData/testData/%s_1_n/', 'ORB');
testResultsPath = sprintf('../data/RealData/testResults/%s_1_n/', 'ORB');

subdirList = dir([testDataPath '*.mat']);
nScene = length(subdirList);
nMethod = length(names);

for i = 1:nScene
    basename = subdirList(i).name;
    disp(basename);

    ifname = sprintf('%s%s', testDataPath, basename);
    disp(ifname);
    mat = load(ifname);

    % load data
    for j = 1:nMethod
        name = names{j};
        filename = sprintf('%s%s-%s.mat', testResultsPath, basename, name);
        res(j) = load(filename);
    end

    % statistic
    inlier_rates(:,i) = res(1).inlier_rate;
    for j = 1:length(res)
        dRs(:,j,i) = res(j).dR;
        dts(:,j,i) = res(j).dt;
        cost_times(:,j,i) = res(j).cost_times;

        nTest = length(res(j).dR);
        for k = 1:nTest
            D = mat.Data{k};
            X = D.XXw';
            x = D.xx';
            K = D.K;
            th_pixel = 5;
            gR = D.R;
            gt = D.t';

            R = squeeze(res(j).estm_Rs(k,:,:));
            t = squeeze(res(j).estm_ts(k,:))';
            inliers_gt = calcInliers(gR, gt, X, x, K, th_pixel);
            inliers = calcInliers(R, t, X, x, K, th_pixel);
            correct_inliers(k,j,i) =  sum(inliers_gt & inliers)/sum(inliers_gt);
        end

        fprintf('  %s: dR %2.2f (%2.2f), dT %2.2f (%2.2f), time %.1f, correct: %.3f\n', ...
            dispnames{j}, ...
            mean(dRs(:,j,i)), std(dRs(:,j,i)),...
            mean(dts(:,j,i)), std(dts(:,j,i)),...
            mean(cost_times(:,j,i)), mean(correct_inliers(:,j,i))...
            )            
    end
end

% Scatter of accuracy and time
iMethods = [1 2 3 4 5 7];

figure('position', [0 50 400 380])
colors = {'b','b','g','g','r','m','m'};
markers = {'s','^','s','^','s','^','^'};

for j = iMethods
    if j == 1 || j == 3
        scatter(squeeze(mean(dRs(:,j,:),1)), squeeze(mean(cost_times(:,j,:),1)), 30, colors{j}, markers{j})
    else
        scatter(squeeze(mean(dRs(:,j,:),1)), squeeze(mean(cost_times(:,j,:),1)), 30, colors{j}, markers{j}, 'filled')
    end
    hold on
end
legend(dispnames(iMethods), 'location', 'NorthEast')
xlabel('Mean rotation error (degree)')
ylabel('Avg computational time (second)')
set(gca, 'xscale', 'log')
set(gca, 'yscale', 'log')
set(gca, 'box', 'on')

% Histogram of outlier rate

figure('position', [0 50 420 290])
histogram((1-inlier_rates(:))*100, 50:5:100);
xlim([50 100])
xlabel('Outlier rate (%)','fontname','times')
title('Histogram of Outliers','fontname','times')

% Show result of all scenes

% 1) accum curve of dR
figure('position', [0 50 350 350])
tmp = reshape(permute(dRs, [1 3 2]), [], size(dRs,2));
for j = iMethods
    [x, y] = accum_curve(tmp(:,j));            
    h = plot(x, y*100, styles{j}, 'linew', 0.75);
    set(h, 'markerfacecolor', get(h, 'color'));
    set(h, 'markersize', 3);
    hold on
end

xlim([0, 5])
title('Rotation error')
xlabel('threshold of err_{\bf{R}} (degree)')
ylabel('Percentage of tsets within threshold (%)')
legend(dispnames(iMethods), 'location', 'southeast')

% 2) accum curve of dt
figure('position', [0 50 350 350])
tmp = reshape(permute(dts, [1 3 2]), [], size(dts,2));
for j = iMethods
    [x, y] = accum_curve(tmp(:,j)*100);            
    h = plot(x, y*100, styles{j}, 'linew', 0.75);
    set(h, 'markerfacecolor', get(h, 'color'));
    set(h, 'markersize', 3);
    hold on
end

xlim([0, 25])
title('Translation error')
xlabel('threshold of err_{\bf{t}} (%)')
ylabel('Percentage of tsets within threshold (%)')
legend(dispnames(iMethods), 'location', 'southeast')

% 3) accum curve of dR
figure('position', [0 50 350 350])
tmp = reshape(permute(correct_inliers, [1 3 2]), [], size(correct_inliers,2));
for j = iMethods
    [x, y] = accum_curve(tmp(:,j));            
    h = plot(x*100, (1-y)*100, styles{j}, 'linew', 0.75);
    set(h, 'markerfacecolor', get(h, 'color'));
    set(h, 'markersize', 3);
    hold on
end

xlim([0, 100])
title('Accuracy of detected inliers')
xlabel('threshold of acc_{in} (%)')
ylabel('Percentage of tsets above threshold (%)')
legend(dispnames(iMethods), 'location', 'southwest')

% 4) hist of time
figure('position', [0 50 370 350])
cost_times = reshape(permute(cost_times, [1 3 2]), [], size(cost_times,2));
x = -2:0.15:4.5;
y = hist(log10(cost_times), x);
x1 = x(2:end-1);
y1 = (y(1:end-2,:)+y(2:end-1,:)*2+y(3:end,:))*0.25;
for j = iMethods
    plot(x1, y1(:,j), styles{j}, 'linew', 0.75);
    hold on
end    
xlim([-1.5 4.75])   
tick = -1:4;
for i = 1:length(tick)
    ticklabel{i} = sprintf('10^{%i}', tick(i));
end
set(gca,'xtick',tick)
set(gca,'xticklabel',ticklabel)
title('Distribution of computational time')
xlabel('Time (seconds)')
legend(dispnames(iMethods))

% Show accum curve of all scenes

dispnames{7} = 'Ours';
iMethods = [1 2 3 4 5 7];

figure();
nx = 5;
ny = 2;
ax = 0.03;
ay = 0;
bx = (1-ax*2)/nx;
by = (1-ay*2)/ny;
xpos = (0:nx-1)*bx + ax;
ypos = (ny-1:-1:0)*by + ay;
set(gcf, 'position', [0 50 1400 620])

% show results
for i = 1:nScene

    baseame = subdirList(i).name;        

    % show axis
    subplot(ny, nx, i)

    for j = iMethods
        [x, y] = accum_curve(dRs(:,j,i));            
        h = plot(x, y*100, styles{j}, 'linew', 0.75);
        set(h, 'markerfacecolor', get(h, 'color'));
        set(h, 'markersize', 3);
        hold on
    end

    xlim([0, 10])
    title(strrep(baseame(1:length(baseame)-4), '_', ' '), 'fontsize', 14)
    xlabel('threshold of err_{\bf{R}} (degree)')
    ylabel('Percentage of tests within threshold (%)')

    set(gca, 'outer', [xpos(mod(i-1,nx)+1) ypos(ceil(i/nx)) bx by-0.01])
    if i == 1
        tmp = get(gca, 'position');
    end
    if i == nScene
        legend(dispnames(iMethods), 'location', 'southeast')
    end
    if mod(i, nx) == 0
        tmp1 = get(gca, 'position');
        tmp1(3) = tmp(3);
        set(gca, 'position', tmp1);
    end

end
