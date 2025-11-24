clear; clc; close all
initpath

infos = {   ...
    'P3P', 'RSC P3P', 'b^-.', ...
    'P3P+OPnPGN', 'RSC P3P+OPnP+GN', 'bs-', ...
    'P4P', 'RSC P4P', 'g^-.', ...
    'P4P+OPnPGN', 'RSC P4P+OPnP+GN', 'gs-', ...
    'REPPnP', 'REPPnP', 'co-', ...
    'R1PPnP', 'R1PPnP', 'ro-.', ...
    'R2PPnP', 'R2PPnP', 'm^-', ...
};
infos = reshape(infos, 3, []);
names = squeeze(infos(1, :));
dispnames = squeeze(infos(2, :));
styles = squeeze(infos(3, :));

% Load experimental results
for c = 1:3
    npt = 100;
    noise = 5;
    printvars(c, noise)
    for i = 1:length(names)
        name = names{i};
        printvars(' ', name)
        [dRs(:,:,i,c), dts(:,:,i,c), times(:,:,i,c), ~, ~, ...
            correct_inliers(:,:,i,c), ninlier(:,:,i,c), ninlier_gt(:,:,i,c)] = ...
            load_syn_test_results(name, c, npt, noise);
    end
end

% Show Mean & Median Errors

figure()
set(gcf, 'pos', [0 10 1000 1500])
show_basic(dispnames, styles, dRs, dts, correct_inliers)

% Show Computational Time

figure()
set(gcf, 'pos', [10 50 450 420])
c = 1;
rates = 5:5:95;
xplot(rates, mean(times(:,:,:,c), 1), styles)
legend(dispnames)
legend(dispnames, 'location', 'northwest')
ylim([0.001, 450])
xlim(rates([2,end]))
set(gca, 'yscale', 'log')
set(gca, 'xtick', [20 45 70 95]) 
xlabel('Outlier rate (%)')
ylabel('Time (second)')
title('Computational time')


function show_basic(names, styles, dRs, dts, correct_inliers)

    rates = 5:5:95;
    nx = 3;
    ny = 5;
    ax = 0.0;
    ay = 0.07;
    bx = (1-ax-0.01)/nx;
    by = (1-ay)/ny;
    xpos = (0:nx-1)*bx + ax;
    ypos = (ny-1:-1:0)*by;
    
    function disp_header(ix, txt)
        subplot('Position', [xpos(ix) by*ny bx ay])
        text(0.58, 0.5, txt, 'fontsize', 14, 'horiz', 'center')
        axis off
    end

    disp_header(1, '(a) Ordinary')
    disp_header(2, '(b) Quasi-singular')
    disp_header(3, '(c) Planar')
    
    function plot_ax(iy, ix, Y)
        subplot(ny+1, nx+1, iy*(nx+1)+ix+1, 'align')
        xplot(rates, Y, styles)
        xlim(rates([2,end]))
        set(gca, 'xtick', [20 45 70 95])
        xlabel('Outlier rate (%)')
        set(gca, 'outer', [xpos(ix)+0.02 ypos(iy)+0.02 bx-0.02 by])
    end
    
    max_yr = [1.2 2.5 3.0];
    max_yt = [1.0 3.5 2.5];
    for c = 1:3
        
        % meanR
        plot_ax(1, c, mean(dRs(:,:,:,c), 1))
        ylabel('Mean err_{\bf{R}} (degree)')
        ylim([0, max_yr(c)])
        
        % legend
        if c == 1, legend(names, 'location', 'northwest'); end
        
        % medianR
        plot_ax(2, c, median(dRs(:,:,:,c), 1))
        ylabel('Median err_{\bf{R}} (degree)')
        ylim([0, max_yr(c)])
        
        % meanT
        plot_ax(3, c, mean(dts(:,:,:,c), 1))
        ylabel('Mean err_{\bf{t}} (%)')
        ylim([0, max_yt(c)])
        
        % medianT
        plot_ax(4, c, median(dts(:,:,:,c), 1))
        ylabel('Median err_{\bf{t}} (%)')
        ylim([0, max_yt(c)])
        tmp0 = get(gca, 'pos');
        
        % meanInliers
        plot_ax(5, c, mean(correct_inliers(:,:,:,c)*100, 1))
        ylabel('acc_{in} (%)')
        ylim([50, 100])
        tmp = get(gca, 'pos');
        tmp(3) = tmp0(3);
        set(gca, 'pos', tmp);
        
    end

end


function xplot(x, Y, S)

    hold off
    Y = squeeze(Y);
    for i = 1:size(Y, 2)
        h = plot(x, Y(:,i), S{i}, 'linew', 1);
        set(h, 'markerfacecolor', get(h, 'color'));
        set(h, 'markersize', 3);
        hold on
    end

end

