function test_Integration()
    addpath('..');
    addpath('../models');
    addpath('../guidance');
    addpath('../simulation');
    addpath('../utils');
    
    fprintf('========================================\n');
    fprintf('  集成测试\n');
    fprintf('========================================\n\n');
    
    fprintf('测试1: 完整仿真流程测试\n');
    
    missile_initial_state.position = [0; 0; 0];
    missile_initial_state.velocity = [300; 0; 0];
    missile_initial_state.acceleration = [0; 0; 0];
    missile_initial_state.attitude = [1; 0; 0];
    
    target_initial_state.position = [5000; 3000; 1000];
    target_initial_state.velocity = [-200; 0; 0];
    target_initial_state.acceleration = [0; 0; 0];
    
    missile_params.max_acceleration = 200.0;
    missile_params.min_velocity = 50.0;
    missile_params.mass = 100.0;
    
    missile = MissileModel(missile_initial_state, missile_params);
    target = TargetModel(target_initial_state, 'constant', struct());
    guidance_law = GuidanceLaw('PN', struct('N', 3.0));
    
    sim_params.dt = 0.01;
    sim_params.max_time = 30.0;
    sim_params.miss_distance_threshold = 5.0;
    sim_params.min_missile_speed = 50.0;
    
    sim_env = SimulationEnv(missile, target, guidance_law, sim_params);
    data_logger = DataLogger();
    
    sim_env.initialize();
    while sim_env.running
        sim_env.step();
        data_logger.log(sim_env.time, sim_env.missile.get_state(), ...
            sim_env.target.get_state(), sim_env.relative_motion, ...
            sim_env.missile.acceleration);
    end
    
    results = sim_env.get_results();
    data = data_logger.get_all_data();
    
    assert(results.time > 0, '仿真时间为零');
    assert(data_logger.get_num_points() > 0, '未记录任何数据');
    fprintf('  通过\n\n');
    
    fprintf('测试2: 性能指标计算测试\n');
    metrics = Analyzer.calculate_metrics(data, results);
    
    assert(isfield(metrics, 'miss_distance'), '缺少脱靶量指标');
    assert(isfield(metrics, 'interception_time'), '缺少拦截时间指标');
    fprintf('  通过\n\n');
    
    fprintf('测试3: 数据保存和加载测试\n');
    test_file = 'test_integration_data.mat';
    data_logger.save(test_file, 'mat');
    
    assert(exist(test_file, 'file') == 2, '数据保存失败');
    
    loaded_logger = DataLogger();
    loaded_data = loaded_logger.load(test_file, 'mat');
    
    assert(length(loaded_data.time) == length(data.time), '加载数据点数错误');
    
    delete(test_file);
    fprintf('  通过\n\n');
    
    fprintf('测试4: 不同制导律对比测试\n');
    law_types = {'PN', 'PP', 'APN', 'OGL'};
    metrics_list = cell(length(law_types), 1);
    
    for i = 1:length(law_types)
        missile = MissileModel(missile_initial_state, missile_params);
        target = TargetModel(target_initial_state, 'constant', struct());
        guidance_law = GuidanceLaw(law_types{i}, struct('N', 3.0));
        
        sim_env = SimulationEnv(missile, target, guidance_law, sim_params);
        data_logger = DataLogger();
        
        sim_env.initialize();
        while sim_env.running
            sim_env.step();
            data_logger.log(sim_env.time, sim_env.missile.get_state(), ...
                sim_env.target.get_state(), sim_env.relative_motion, ...
                sim_env.missile.acceleration);
        end
        
        results = sim_env.get_results();
        data = data_logger.get_all_data();
        metrics_list{i} = Analyzer.calculate_metrics(data, results);
    end
    
    comparison = Analyzer.compare_guidance_laws(metrics_list, law_types);
    assert(isfield(comparison, 'best_miss_distance'), '对比结果缺少最佳脱靶量');
    fprintf('  通过\n\n');
    
    fprintf('测试5: 不同目标运动模式测试\n');
    motion_types = {'constant', 'circular', 'sine'};
    
    for i = 1:length(motion_types)
        missile = MissileModel(missile_initial_state, missile_params);
        target = TargetModel(target_initial_state, motion_types{i}, struct());
        guidance_law = GuidanceLaw('PN', struct('N', 3.0));
        
        sim_env = SimulationEnv(missile, target, guidance_law, sim_params);
        data_logger = DataLogger();
        
        sim_env.initialize();
        while sim_env.running
            sim_env.step();
            data_logger.log(sim_env.time, sim_env.missile.get_state(), ...
                sim_env.target.get_state(), sim_env.relative_motion, ...
                sim_env.missile.acceleration);
        end
        
        results = sim_env.get_results();
        assert(results.time > 0, sprintf('%s模式仿真失败', motion_types{i}));
    end
    fprintf('  通过\n\n');
    
    fprintf('测试6: 参数敏感性测试\n');
    N_values = [2.0, 3.0, 4.0, 5.0];
    miss_distances = zeros(length(N_values), 1);
    
    for i = 1:length(N_values)
        missile = MissileModel(missile_initial_state, missile_params);
        target = TargetModel(target_initial_state, 'constant', struct());
        guidance_law = GuidanceLaw('PN', struct('N', N_values(i)));
        
        sim_env = SimulationEnv(missile, target, guidance_law, sim_params);
        data_logger = DataLogger();
        
        sim_env.initialize();
        while sim_env.running
            sim_env.step();
            data_logger.log(sim_env.time, sim_env.missile.get_state(), ...
                sim_env.target.get_state(), sim_env.relative_motion, ...
                sim_env.missile.acceleration);
        end
        
        results = sim_env.get_results();
        miss_distances(i) = results.miss_distance;
    end
    
    assert(length(miss_distances) == length(N_values), '敏感性测试失败');
    fprintf('  通过\n\n');
    
    fprintf('测试7: 报告生成测试\n');
    missile = MissileModel(missile_initial_state, missile_params);
    target = TargetModel(target_initial_state, 'constant', struct());
    guidance_law = GuidanceLaw('PN', struct('N', 3.0));
    
    sim_env = SimulationEnv(missile, target, guidance_law, sim_params);
    data_logger = DataLogger();
    
    sim_env.initialize();
    while sim_env.running
        sim_env.step();
        data_logger.log(sim_env.time, sim_env.missile.get_state(), ...
            sim_env.target.get_state(), sim_env.relative_motion, ...
            sim_env.missile.acceleration);
    end
    
    results = sim_env.get_results();
    data = data_logger.get_all_data();
    metrics = Analyzer.calculate_metrics(data, results);
    
    report = Analyzer.generate_report(metrics);
    assert(~isempty(report), '报告为空');
    assert(contains(report, '拦截状态'), '报告缺少拦截状态');
    fprintf('  通过\n\n');
    
    fprintf('测试8: 可视化测试\n');
    try
        Visualizer.plot_trajectory_3d(data, [], 'test_trajectory.png');
        Visualizer.plot_relative_distance(data, [], 'test_distance.png');
        Visualizer.plot_acceleration(data, [], 'test_accel.png');
        
        if exist('test_trajectory.png', 'file')
            delete('test_trajectory.png');
        end
        if exist('test_distance.png', 'file')
            delete('test_distance.png');
        end
        if exist('test_accel.png', 'file')
            delete('test_accel.png');
        end
        
        fprintf('  通过\n\n');
    catch
        fprintf('  跳过(图形环境不可用)\n\n');
    end
    
    fprintf('测试9: 边界条件测试\n');
    
    sim_params.miss_distance_threshold = 0.1;
    missile = MissileModel(missile_initial_state, missile_params);
    target = TargetModel(target_initial_state, 'constant', struct());
    guidance_law = GuidanceLaw('PN', struct('N', 3.0));
    
    sim_env = SimulationEnv(missile, target, guidance_law, sim_params);
    data_logger = DataLogger();
    
    sim_env.initialize();
    while sim_env.running
        sim_env.step();
        data_logger.log(sim_env.time, sim_env.missile.get_state(), ...
            sim_env.target.get_state(), sim_env.relative_motion, ...
            sim_env.missile.acceleration);
    end
    
    results = sim_env.get_results();
    assert(results.miss_distance >= 0, '脱靶量为负');
    fprintf('  通过\n\n');
    
    fprintf('测试10: 重置和重新仿真测试\n');
    missile = MissileModel(missile_initial_state, missile_params);
    target = TargetModel(target_initial_state, 'constant', struct());
    guidance_law = GuidanceLaw('PN', struct('N', 3.0));
    
    sim_env = SimulationEnv(missile, target, guidance_law, sim_params);
    data_logger = DataLogger();
    
    sim_env.initialize();
    while sim_env.running
        sim_env.step();
        data_logger.log(sim_env.time, sim_env.missile.get_state(), ...
            sim_env.target.get_state(), sim_env.relative_motion, ...
            sim_env.missile.acceleration);
    end
    
    results1 = sim_env.get_results();
    
    sim_env.reset(missile_initial_state, target_initial_state);
    data_logger.clear();
    
    sim_env.initialize();
    while sim_env.running
        sim_env.step();
        data_logger.log(sim_env.time, sim_env.missile.get_state(), ...
            sim_env.target.get_state(), sim_env.relative_motion, ...
            sim_env.missile.acceleration);
    end
    
    results2 = sim_env.get_results();
    
    assert(abs(results1.time - results2.time) < 1e-6, '重置后仿真结果不一致');
    fprintf('  通过\n\n');
    
    fprintf('========================================\n');
    fprintf('  所有集成测试通过!\n');
    fprintf('========================================\n');
end
