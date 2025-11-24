clear; clc; close all
initpath

% load test data
data = Dataset.real_star();

% list methods
infos = {   ...
    'P3P', 'RSC(P3P)', 'b-.', 
    'P3P+OPnPGN', 'RSC(P3P)+OGN', 'b-',
    'P4P', 'RSC(RP4P)', 'g-.', 
    'P4P+OPnPGN', 'RSC(RP4P)+OGN', 'g-',
    'R1PPnP', 'R1PPnP', 'r-.', 
    'R2PPnP2+Finalize', 'Ours', 'm-', 
};

names = squeeze(infos(:, 1));
dispnames = squeeze(infos(:, 2));
styles = squeeze(infos(:, 3));

% load results
nMethod = length(names);
for j = 1:nMethod
    name = names{j};
    disp(name)
    res(j) = load(data.fname_testresults(name));
    cost_times(:,j) = res(j).cost_times;
end

% deal gt
nTest = length(res(1).dR);
for k = 1:nTest
    D = data.vec{k};
    inliers_gt{k} = calcInliers(D.gR, D.gt, D.X, D.x, D.K, D.th_pixel);
    ninliers_gt(k) = sum(inliers_gt{k});
    inlier_rates_gt(k) = mean(inliers_gt{k});
end

mask = ninliers_gt >= 10;
fprintf('number of images: %d\n', sum(mask))

for j = 1:length(res)

    for k = 1:nTest
        D = data.vec{k};
        R = squeeze(res(j).estm_Rs(k,:,:));
        t = squeeze(res(j).estm_ts(k,:))';
        inliers{k,j} = calcInliers(R, t, D.X, D.x, D.K, D.th_pixel);
        ninliers(k,j) = sum(inliers{k,j});
        correct_inliers(k,j) = sum(inliers_gt{k} & inliers{k,j})/ninliers_gt(k);
    end

    fprintf('  %s: dR %2.2f (%2.2f), dT %2.2f (%2.2f), time %.1f, correct: %.3f\n', ...
        dispnames{j}, ...
        mean(res(j).dR(mask)), std(res(j).dR(mask)),...
        mean(res(j).dt(mask)), std(res(j).dt(mask)),...
        mean(res(j).cost_times(mask)), mean(correct_inliers(mask,j))...
        )            
end

% 1) accum curve of dR
figure('position', [0 50 350 350])
for j = 1:nMethod
    [x, y] = accum_curve(res(j).dR(mask));            
    h = plot(x, y*100, styles{j}, 'linew', 0.75);
    set(h, 'markerfacecolor', get(h, 'color'));
    set(h, 'markersize', 3);
    hold on
end

xlim([0, 20])
title('Rotation error')
xlabel('threshold of err_{\bf{R}} (degree)')
ylabel('Percentage of tsets within threshold (%)')
legend(dispnames, 'location', 'southeast')

% 2) accum curve of dt
figure('position', [0 50 350 350])
for j = 1:nMethod
    [x, y] = accum_curve(res(j).dt(mask)*100);            
    h = plot(x, y*100, styles{j}, 'linew', 0.75);
    set(h, 'markerfacecolor', get(h, 'color'));
    set(h, 'markersize', 3);
    hold on
end

xlim([0, 20])
title('Translation error')
xlabel('threshold of err_{\bf{t}} (%)')
ylabel('Percentage of tsets within threshold (%)')
legend(dispnames, 'location', 'southeast')

% 3) accum curve of correct rate
figure('position', [0 50 350 350])
for j = 1:nMethod
    [x, y] = accum_curve(correct_inliers(mask,j));            
    h = plot(x*100, (1-y)*100, styles{j}, 'linew', 0.75);
    set(h, 'markerfacecolor', get(h, 'color'));
    set(h, 'markersize', 3);
    hold on
end

xlim([0, 100])
title('Accuracy of detected inliers')
xlabel('threshold of acc_{in} (%)')
ylabel('Percentage of tsets above threshold (%)')
legend(dispnames, 'location', 'southwest')

% 4) hist of time
figure('position', [0 50 350 350])
x = -2:0.15:4.5;
y = hist(log10(cost_times(mask,:)), x);
x1 = x(2:end-1);
y1 = (y(1:end-2,:)+y(2:end-1,:)*2+y(3:end,:))*0.25;
for j = 1:nMethod
    plot(x1, y1(:,j), styles{j}, 'linew', 0.75);
    hold on
end    
xlim([-2.2 4.2])   
tick = -1:4;
for i = 1:length(tick)
    ticklabel{i} = sprintf('10^{%i}', tick(i));
end
set(gca,'xtick',tick)
set(gca,'xticklabel',ticklabel)
title('Distribution of computational time')
xlabel('Time (seconds)')
legend(dispnames)

% 5) Histogram of outlier rate
figure('position', [0 50 350 350])
histogram((1-inlier_rates_gt)*100, 0:5:100);
xlim([0 100])
xlabel('Outlier rate (%)','fontname','times')
title('Histogram of Outliers','fontname','times')