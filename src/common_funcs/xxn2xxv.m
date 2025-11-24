% xxn (2, n)
% xxv (3, n)
function xxv = xxn2xxv(xxn)
    n = size(xxn, 2);
    xxv= [xxn; ones(1,n)];
    xxv = xxv ./ repmat(xnorm(xxv), 3, 1);
end
