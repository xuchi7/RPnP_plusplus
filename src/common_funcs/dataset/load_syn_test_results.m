function [dRs, dts, times, estm_Rs, estm_ts, correct_inliers, ninlier, ninlier_gt, num_trials] = load_syn_test_results(methodname, c, npt, noise)
% testdata
fname = get_syn_fname_testdata(c, npt, noise);
testdata = load(fname);
nSet = length(testdata.Data);
nTest = length(testdata.Data{1});
% test results
results = load(get_syn_fname_results(methodname, c, npt, noise));
times = reshape(results.cost_times, nTest, nSet);
if isfield(results, 'num_trials')
    num_trials = reshape(results.num_trials, nTest, nSet);
else
    num_trials = [];
end
estm_Rs = reshape(results.estm_Rs, nTest, nSet, 3, 3);
estm_ts = reshape(results.estm_ts, nTest, nSet, 3);
for i = 1:nSet
    for j = 1:nTest
        D = testdata.Data{i}(j);
        X = D.XXw;
        xn = D.xxn;
        K = [1000 0 0; 0 1000 0; 0 0 1];
        x = xxn2xx(K, xn);
        th_pixel = 10;
        R = squeeze(estm_Rs(j, i, :, :));
        t = squeeze(estm_ts(j, i, :));
        inliers_gt = calcInliers(D.R_cw, D.t_cw, X, x, K, th_pixel);
        inliers = calcInliers(R, t, X, x, K, th_pixel);
        ninlier(j,i) = sum(inliers);
        ninlier_gt(j,i) = sum(inliers_gt);
        if 1 % count inlier (within threshold)
            correct_inliers(j,i) =  sum(inliers_gt & inliers)/sum(inliers_gt);
        else % count inlier (first 100)
            tmp = zeros(size(inliers)); tmp(1:100) = 1;
            correct_inliers(j,i) = sum(tmp & inliers)/100;
        end
        dRs(j,i) = calc_dR(D.R_cw, R);
        dts(j,i) = calc_dt(D.t_cw, t)*100;
    end
end
