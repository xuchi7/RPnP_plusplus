function w = calc_weight(err, th, weight_order)
    if weight_order == inf
        w = err < th;
    else
        w = (th ./ max(err, th)).^weight_order;
    end
end