function run_all_tests()
    addpath('models');
    addpath('guidance');
    addpath('simulation');
    addpath('utils');
    addpath('tests');
    
    fprintf('\n');
    fprintf('========================================\n');
    fprintf('  运行所有测试\n');
    fprintf('========================================\n\n');
    
    test_functions = {
        @test_MissileModel;
        @test_TargetModel;
        @test_GuidanceLaw;
        @test_SimulationEnv;
        @test_DataLogger;
        @test_Analyzer;
        @test_Integration;
    };
    
    test_names = {
        '导弹运动学模型';
        '目标运动学模型';
        '制导律模块';
        '仿真环境模块';
        '数据记录模块';
        '分析模块';
        '集成测试';
    };
    
    passed = 0;
    failed = 0;
    
    for i = 1:length(test_functions)
        fprintf('\n');
        try
            test_functions{i}();
            passed = passed + 1;
            fprintf('\n[成功] %s 测试通过\n', test_names{i});
        catch ME
            failed = failed + 1;
            fprintf('\n[失败] %s 测试失败\n', test_names{i});
            fprintf('错误信息: %s\n', ME.message);
            fprintf('错误位置: %s (第%d行)\n', ME.stack(1).name, ME.stack(1).line);
        end
        fprintf('\n');
    end
    
    fprintf('========================================\n');
    fprintf('  测试总结\n');
    fprintf('========================================\n');
    fprintf('总测试数: %d\n', length(test_functions));
    fprintf('通过: %d\n', passed);
    fprintf('失败: %d\n', failed);
    fprintf('========================================\n\n');
    
    if failed == 0
        fprintf('所有测试通过!\n');
    else
        fprintf('有 %d 个测试失败\n', failed);
    end
end
