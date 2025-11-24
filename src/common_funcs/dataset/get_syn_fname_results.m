function ofname = get_syn_fname_results(methodname, c, npt, noise)
    path_testresult = '../data/SynthData/testResults';
    basename = get_syn_basename(c, npt, noise);
    ofname = sprintf('%s/%s-%s.mat', path_testresult, basename, methodname);
end