function ifname = get_real_fname_testdata(ifea, iscene)
    dataPath = '../data/RealData/testData/';
    baseName = get_real_basename(ifea, iscene);
    ifname = sprintf('%s%s', dataPath, baseName);
end