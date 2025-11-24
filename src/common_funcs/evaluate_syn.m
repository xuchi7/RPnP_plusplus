function evaluate_syn(methodname, func, c, npt, noise, varargin)

    % load testdata
    ifname = get_syn_fname_testdata(c, npt, noise);
    disp(ifname);
    mat = load(ifname);

    % eval
    disp(methodname)
    outlierRate = 0.05:0.05:0.95;
    nRate = length(outlierRate);
    nTest = length(mat.Data{1});

    for i = 1:nRate
        
        fprintf('Outlier rate %2.0f%% ', outlierRate(i)*100)
        
        for j= 1:nTest
            
            D = mat.Data{i}(j);
            X = D.XXw;
            xn = D.xxn;
            K = [1000 0 0; 0 1000 0; 0 0 1];
            x = xxn2xx(K, xn);
            th_pixel = 10;
            
            % eval
            t0 = tic;
            
            % try
                [R1, t1, ntrial] = func(X, x, K, th_pixel, varargin{:});
            % catch
            %     R1 = []; t1 = []; ntrial = 0;
            % end
            
            cost_time = toc(t0);
            
            if isempty(R1)
                R1 = eye(3); t1 = zeros(3, 1);
                fprintf('x')
            end
            
            % store results
            estm_Rs1(j,:,:) = R1;
            estm_ts1(j,:) = t1;
            cost_times1(j) = cost_time;
            num_trials1(j) = ntrial;
            
            % calc error
            dRs(j) = calc_dR(D.R_cw, R1);
            dts(j) = calc_dt(D.t_cw, t1);
        end
        
        fprintf('\nmeanR %.3f, meanT %.3f%%, meanTime %.1fms', mean(dRs), mean(dts)*100, mean(cost_times1)*1000);
        fprintf('\n')
        
        % store results
        estm_Rs(i,:,:,:) = estm_Rs1;
        estm_ts(i,:,:) = estm_ts1;
        cost_times(i,:) = cost_times1;
        num_trials(i,:) = num_trials1;
    end

    % reshape
    estm_Rs = reshape(permute(estm_Rs, [2, 1, 3, 4]), [], 3, 3);
    estm_ts = reshape(permute(estm_ts, [2, 1, 3]), [], 3);
    cost_times = reshape(permute(cost_times, [2, 1]), [], 1);
    num_trials = reshape(permute(num_trials, [2, 1]), [], 1);

    % save
    ofname = get_syn_fname_results(methodname, c, npt, noise);
    disp(ofname)
    if 1 % change it to 0 if you want to overwrite the results
        disp('skip save')
    else
        save(ofname, 'estm_Rs','estm_ts','cost_times','num_trials');
    end

end
