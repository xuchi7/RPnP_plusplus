function basename = get_syn_basename(c, npt, noise)
    dirnames = {'Ordinary-3D', 'Quasi-singular', 'Planar'};
    basename = sprintf('%s/Outlier-npt%i-noise%g', dirnames{c}, npt, noise);
end