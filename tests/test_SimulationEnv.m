function test_SimulationEnv()
    addpath('..');
    addpath('../models');
    addpath('../guidance');
    addpath('../simulation');
    addpath('../utils');
    
    fprintf('========================================\n');
    fprintf('  测试仿真环境模块\n');
    fprintf('========================================\n\n');
    
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
    
    fprintf('测试1: 初始化测试\n');
    sim_env = SimulationEnv(missile, target, guidance_law, sim_params);
    sim_env.initialize();
    
    assert(sim_env.running == true, '仿真未启动');
    assert(sim_env.time == 0, '初始时间不为零');
    fprintf('  通过\n\n');
    
    fprintf('测试2: 相对运动计算测试\n');
    sim_env = SimulationEnv(missile, target, guidance_law, sim_params);
    sim_env.initialize();
    
    expected_rel_pos = target_initial_state.position - missile_initial_state.position;
    expected_rel_vel = target_initial_state.velocity - missile_initial_state.velocity;
    
    assert(norm(sim_env.relative_motion.relative_position - expected_rel_pos) < 1e-6, '相对位置计算错误');
    assert(norm(sim_env.relative_motion.relative_velocity - expected_rel_vel) < 1e-6, '相对速度计算错误');
    fprintf('  通过\n\n');
    
    fprintf('测试3: 单步更新测试\n');
    sim_env = SimulationEnv(missile, target, guidance_law, sim_params);
    sim_env.initialize();
    
    initial_time = sim_env.time;
    sim_env.step();
    
    assert(abs(sim_env.time - initial_time - sim_params.dt) < 1e-6, '时间更新错误');
    fprintf('  通过\n\n');
    
    fprintf('测试4: 制导指令应用测试\n');
    sim_env = SimulationEnv(missile, target, guidance_law, sim_params);
    sim_env.initialize();
    
    initial_missile_vel = sim_env.missile.velocity;
    sim_env.step();
    
    assert(norm(sim_env.missile.velocity - initial_missile_vel) > 1e-6, '导弹速度未更新');
    fprintf('  通过\n\n');
    
    fprintf('测试5: 目标更新测试\n');
    sim_env = SimulationEnv(missile, target, guidance_law, sim_params);
    sim_env.initialize();
    
    initial_target_pos = sim_env.target.position;
    sim_env.step();
    
    assert(norm(sim_env.target.position - initial_target_pos) > 1e-6, '目标位置未更新');
    fprintf('  通过\n\n');
    
    fprintf('测试6: 视线角速率计算测试\n');
    sim_env = SimulationEnv(missile, target, guidance_law, sim_params);
    sim_env.initialize();
    
    assert(norm(sim_env.relative_motion.los_rate) >= 0, '视线角速率计算错误');
    fprintf('  通过\n\n');
    
    fprintf('测试7: 接近速度计算测试\n');
    sim_env = SimulationEnv(missile, target, guidance_law, sim_params);
    sim_env.initialize();
    
    assert(sim_env.relative_motion.closing_velocity > 0, '接近速度计算错误');
    fprintf('  通过\n\n');
    
    fprintf('测试8: 剩余时间计算测试\n');
    sim_env = SimulationEnv(missile, target, guidance_law, sim_params);
    sim_env.initialize();
    
    expected_tgo = sim_env.relative_motion.relative_distance / sim_env.relative_motion.closing_velocity;
    assert(abs(sim_env.relative_motion.time_to_go - expected_tgo) < 1e-6, '剩余时间计算错误');
    fprintf('  通过\n\n');
    
    fprintf('测试9: 结果获取测试\n');
    sim_env = SimulationEnv(missile, target, guidance_law, sim_params);
    sim_env.initialize();
    results = sim_env.get_results();
    
    assert(isfield(results, 'time'), '结果缺少时间字段');
    assert(isfield(results, 'missile_state'), '结果缺少导弹状态字段');
    assert(isfield(results, 'target_state'), '结果缺少目标状态字段');
    assert(isfield(results, 'relative_motion'), '结果缺少相对运动字段');
    fprintf('  通过\n\n');
    
    fprintf('测试10: 重置测试\n');
    sim_env = SimulationEnv(missile, target, guidance_law, sim_params);
    sim_env.initialize();
    sim_env.step();
    sim_env.reset(missile_initial_state, target_initial_state);
    
    assert(sim_env.time == 0, '重置后时间不为零');
    assert(isequal(sim_env.missile.position, missile_initial_state.position), '重置后导弹位置错误');
    assert(isequal(sim_env.target.position, target_initial_state.position), '重置后目标位置错误');
    fprintf('  通过\n\n');
    
    fprintf('测试11: 短时仿真测试\n');
    sim_env = SimulationEnv(missile, target, guidance_law, sim_params);
    data_logger = DataLogger();
    
    sim_env.initialize();
    for i = 1:100
        sim_env.step();
        data_logger.log(sim_env.time, sim_env.missile.get_state(), ...
            sim_env.target.get_state(), sim_env.relative_motion);
    end
    
    assert(sim_env.time > 0, '仿真时间未增加');
    assert(data_logger.get_num_points() == 100, '数据记录点数错误');
    fprintf('  通过\n\n');
    
    fprintf('========================================\n');
    fprintf('  所有测试通过!\n');
    fprintf('========================================\n');
end
