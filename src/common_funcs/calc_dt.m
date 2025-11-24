function err = calc_dt(t_gt, t)
    err = norm(t_gt - t(:)) / norm(t_gt);
end