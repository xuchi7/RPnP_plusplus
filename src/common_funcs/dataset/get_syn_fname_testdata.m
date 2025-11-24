function ifname = get_syn_fname_testdata(c, npt, noise)
    path_testdata = '../data/SynthData/testData';
    basename = get_syn_basename(c, npt, noise);
    ifname = sprintf('%s/%s.mat', path_testdata, basename);
end