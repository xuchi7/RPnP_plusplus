initpath

for c = 1:3
    evaluate_syn('REPPnP', @evalREPPnP, c, 100, 5);
    evaluate_syn('R1PPnP', @evalR1PPnP, c, 100, 5);

    evaluate_syn('P3P', @evalP3P, c, 100, 5);
    evaluate_syn('P4P', @evalP4P, c, 100, 5);
    evaluate_syn_refinement('P3P', '+OPnPGN', @applyOPnPGN, c, 100, 5)
    evaluate_syn_refinement('P4P', '+OPnPGN', @applyOPnPGN, c, 100, 5)
    
    evaluate_syn('R2PPnP', @evalR2PPnP, c, 100, 5);
    evaluate_syn_refinement('R2PPnP', '+Finalize', @applyFinalize, c, 100, 5)
end