classdef Dataset

    properties
        path = ''
        basename = ''
        vec = {} % test data orgnized as vector (for real)
        mat = {} % test data orgnized as matrix (for synth)
        outlier_rates = [] % a vector, corresponding to the 1-dim of the matrix
        names = {} % a vector, name of each pair data (for real)
    end

    methods
        
        function fname = fname_testresults(obj, methodname)
            temp_featureName = strsplit(obj.basename, '_');
            imr_name = temp_featureName{2};
            pose_name = temp_featureName{3};
            fname = sprintf('%s/testResults/results-%s-%s-%s.mat', obj.path, imr_name, pose_name, methodname);
        end

        function fname = fname_testresult_real_1002(obj, methodname)
            fname = sprintf('%s/testResults/%s.mat-%s.mat', obj.path, obj.basename, methodname);
        end
        
        function fname = fname_testdata(obj)
            fname = sprintf('%s/testData/%s.mat', obj.path, obj.basename);
        end
        
    end

    methods(Static)
        
        function D1 = deal_item_real_1002(D)
            D1.X = D.XXw';
            D1.x = D.xx';
            D1.K = D.K;
            D1.th_pixel = 5;
            D1.gR = D.R;
            D1.gt = D.t';
        end
        
        function obj = real_1002(ifea, iscene)
            obj = Dataset();
            obj.path = '../data/RealData';
            feature_names = {'ORB', 'SURF', 'SIFT'};
            folder = feature_names{ifea};
            subdirList = dir(sprintf('%s/testData/%s_1_n/*.mat', obj.path, folder));
            name = subdirList(iscene).name;
            name = name(1:length(name)-4);
            obj.basename = sprintf('%s_1_n/%s', folder, name);
            % load test data
            vec = load(obj.fname_testdata());
            vec = vec.Data(1:100); % test the first 100 only
            % deal real data
            for i = 1:length(vec)
                D = vec{i};
                obj.vec{i} = Dataset.deal_item_real_1002(D);
                obj.outlier_rates(i) = 1-D.inlierRate;
            end
        end
        
        function D1 = deal_item_real_star(D)
            D1.X = D.XXw';
            % D1.x = D.xx';
            D1.x = D.xxu';
            D1.x = D1.x(1:2, :);
            D1.K = D.K;
            D1.th_pixel = 10;
            D1.gR = D.R;
            D1.gt = D.t';
            D1.hloc_R = D.R_hloc;
            D1.hloc_t = D.t_hloc;
        end

        function obj = real_star()
            obj = Dataset();
            obj.path = '../data/StarRiver/splg'; 
            obj.basename = 'test_eigenplaces10_all';
            % load test data
            fname = obj.fname_testdata();
            disp(fname);
            vec = load(fname);
            vec = vec.Data;
            % deal real data
            for i = 1:length(vec)
                D = vec{i};
                obj.vec{i} = Dataset.deal_item_real_star(D);
                obj.outlier_rates(i) = 1-D.inlier_rate;
                obj.names{i} = vec{i}.name;
            end
        end
    end
end
