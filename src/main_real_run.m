initpath

for iscene = 1:10
    data = Dataset.real_1002(1, iscene);
    
    evaluate_real('R2PPnP', @evalR2PPnP, data);
    evaluate_real_refinement('R2PPnP', '+Finalize', @applyFinalize, data);
    
    evaluate_real('P3P', @evalP3P, data);
    evaluate_real('P4P', @evalP4P, data);
    evaluate_real_refinement('P3P', '+OPnPGN', @applyOPnPGN, data);
    evaluate_real_refinement('P4P', '+OPnPGN', @applyOPnPGN, data);
end
