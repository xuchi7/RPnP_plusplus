function ofname = get_real_fname_results(methodname, ifea, iscene)
    savePath = '../data/RealData/testResults/';
    baseName = get_real_basename(ifea, iscene);
    ofname = sprintf('%s%s-%s.mat', savePath, baseName, methodname);
end