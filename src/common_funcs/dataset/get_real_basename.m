function baseName = get_real_basename(ifea, iscene)
    feature_names = {'ORB', 'SURF', 'SIFT'};
    folder = feature_names{ifea};
    subdirList = dir(sprintf('../data/RealData/testData/%s_1_n/*.mat', folder));
    baseName = sprintf('%s_1_n/%s', folder, subdirList(iscene).name);
end