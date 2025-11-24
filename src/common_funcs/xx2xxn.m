function xxn = xx2xxn(K, xx)

xxn = K \ [xx; ones(1, size(xx, 2))];
xxn = xxn(1:2, :);

end