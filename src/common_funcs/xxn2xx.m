function xx = xxn2xx(K, xxn)

xx = K * [xxn; ones(1, size(xxn, 2))];
xx = xx(1:2, :);

end