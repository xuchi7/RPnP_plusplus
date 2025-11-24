function generate_syn_data()
    dirnames = {'Ordinary-3D', 'Quasi-singular', 'Planar'};
    nTest = 100; % number of tests
    if 1 % change it as 0 if you want to regenerate the data
        disp('syncdata has already been generated.')
    else
        npt = 100;
        noise = 5;
        vecRate = 0.05:0.05:0.95;
        for c = 1:3
            for i = 1:length(vecRate)
                Data{i} = prepareTestData(nTest, npt, noise, vecRate(i), c);
            end
            fname = strcat('../data/SynthData/testData/', dirnames{c}, '/Outlier', ...
                '-npt', num2str(npt), '-noise', num2str(noise), '.mat');
            save(fname, 'Data');
            disp(fname)
        end
    end

function D = prepareTestData(nTest, npt, noiseStd, rateOutlier, Configuration)
    % parameters
    width = 640;
    height = 480;
    focal = 1000;
    % generate Data
    for kk= 1:nTest
        if Configuration==1
            Xc= [xrand(1,npt,[-2 2]); xrand(1,npt,[-2 2]); xrand(1,npt,[4 8])];
            t= mean(Xc,2);
            R= rodrigues(randn(3,1));
            XXw= inv(R)*(Xc-repmat(t,1,npt));
        elseif Configuration==2
            Xc= [xrand(1,npt,[1 2]); xrand(1,npt,[1 2]); xrand(1,npt,[4 8])];
            t= mean(Xc,2);
            R= rodrigues(randn(3,1));
            XXw= inv(R)*(Xc-repmat(t,1,npt));
        elseif Configuration==3 % planar
            XXw= [xrand(2,npt,[-2 2]); zeros(1,npt)];
            R= rodrigues(randn(3,1));
            t= [rand-0.5;rand-0.5;rand*8+4];
            Xc= R*XXw+repmat(t,1,npt);
        end
        % projection
        xx  = [Xc(1,:)./Xc(3,:); Xc(2,:)./Xc(3,:)]*focal;
        xxn = xx + randn(2,npt) *noiseStd;
        xxn= xxn./focal;
        % add outliers
        if rateOutlier > 0
            if (rateOutlier ~= 0)
                nout = max(1,round((npt * rateOutlier)/(1-rateOutlier))); %at least we want 1 outlier
                idx  = randi(npt,1,nout);
                XXwo = XXw(:,idx);
            else
                nout = 0;
                XXwo = [];
            end
            % assignation of random 2D correspondences
            xxno  = [xrand(1,nout,[min(xxn(1,:)) max(xxn(1,:))]); xrand(1,nout,[min(xxn(2,:)) max(xxn(2,:))])];
            XXw = [XXw, XXwo];
            xxn = [xxn, xxno];
        end
        % save data
        D(kk).xxn = xxn;
        D(kk).XXw = XXw;
        D(kk).R_cw = R;
        D(kk).t_cw = t;
    end