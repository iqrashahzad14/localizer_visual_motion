function test_suite = test_getDesignInput %#ok<*STOUT>
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions = localfunctions(); %#ok<*NASGU>
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;
end

function test_setSpeedTargets_MT()

    isMT = true;
    cfg = getMockConfig(isMT);

    [nbRepetitions, nbEventsPerBlock, maxNbPerBlock, nbBlocks] = getDesignInput(cfg);

    assertEqual(nbRepetitions, 12);
    assertEqual(nbEventsPerBlock, cfg.design.nbEventsPerBlock);
    assertEqual(maxNbPerBlock, 2);
    assertEqual(nbBlocks, 24);

end

function test_setSpeedTargets_MST()

    isMT = false;
    cfg = getMockConfig(isMT);

    [nbRepetitions, nbEventsPerBlock, maxNbPerBlock, nbBlocks] = getDesignInput(cfg);

    assertEqual(nbRepetitions, 24);
    assertEqual(nbEventsPerBlock, cfg.design.nbEventsPerBlock);
    assertEqual(maxNbPerBlock, 2);
    assertEqual(nbBlocks, 48);

end
