function [x, y] = accum_curve(dR)
    dR = reshape(dR, 1, []);
    x = [0 sort(dR)];
    y = [0 (1:length(dR))/length(dR)];
end