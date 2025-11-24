% X (m, n)
% l (1, n)
function l = xnorm(X)
    l = sum(X.^2, 1).^0.5;
end
