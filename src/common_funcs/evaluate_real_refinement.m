function evaluate_real_refinement(methodname, refinename, func, data, varargin)

    fname = data.fname_testresult_real_1002(methodname);
    fprintf(fname);
    res = load(fname);
    assert(length(res.estm_Rs) == length(data.vec))

    for i = 1:length(data.vec)

        fprintf('%3d, ', i);    
        inlier_rate(i) = 1 - data.outlier_rates(i);
        D = data.vec{i};        
        
        R = squeeze(res.estm_Rs(i, :, :));
        t = squeeze(res.estm_ts(i, :))';
        
        t0 = tic;
        % try
            [R1, t1] = func(R, t, D.X, D.x, D.K, D.th_pixel, varargin{:});
        % catch
        %     R1 = [];
        % end    
        cost_times(i) = toc(t0) + res.cost_times(i);
        fprintf('total time = %.3fs, ',cost_times(i));
        
        if isempty(R1)
            R1 = eye(3); t1 = zeros(3, 1);
            fprintf('x')
        end
        
        estm_Rs(i,:,:) = R1;
        estm_ts(i,:) = t1;
        dR(i) = calc_dR(D.gR, R1);
        dt(i) = calc_dt(D.gt, t1);
        fprintf('R_error = %.3f, t_error = %.3f.\n', dR(i), dt(i))
        
    end

    printvars('mean dR:', mean(dR));

    % save
    fname = data.fname_testresult_real_1002([methodname, refinename]);
    fprintf(fname);
    if 1 % change if 1 to if 0 to override existing results
        disp('skip save')
    else
        save(fname, 'estm_Rs','estm_ts','cost_times','inlier_rate','dR','dt');
    end

end
