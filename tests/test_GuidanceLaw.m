function test_GuidanceLaw()
    addpath('..');
    addpath('../models');
    addpath('../guidance');
    addpath('../simulation');
    addpath('../utils');
    
    fprintf('========================================\n');
    fprintf('  测试制导律模块\n');
    fprintf('========================================\n\n');
    
    missile_state.position = [0; 0; 0];
    missile_state.velocity = [300; 0; 0];
    missile_state.acceleration = [0; 0; 0];
    missile_state.speed = 300;
    
    target_state.position = [5000; 3000; 1000];
    target_state.velocity = [-200; 0; 0];
    target_state.acceleration = [0; 0; 0];
    
    relative_motion.relative_position = target_state.position - missile_state.position;
    relative_motion.relative_velocity = target_state.velocity - missile_state.velocity;
    relative_motion.relative_distance = norm(relative_motion.relative_position);
    relative_motion.los_vector = relative_motion.relative_position / relative_motion.relative_distance;
    relative_motion.los_rate = [0; 0; 0.01];
    relative_motion.closing_velocity = 500;
    relative_motion.time_to_go = relative_motion.relative_distance / relative_motion.closing_velocity;
    
    fprintf('测试1: 比例导引(PN)测试\n');
    params.N = 3.0;
    guidance_law = GuidanceLaw('PN', params);
    [accel_cmd, info] = guidance_law.calculate(missile_state, target_state, relative_motion);
    
    assert(strcmp(info.law_type, 'PN'), '制导律类型错误');
    assert(abs(info.N - params.N) < 1e-6, 'N值错误');
    assert(norm(accel_cmd) > 0, 'PN加速度指令为零');
    fprintf('  通过\n\n');
    
    fprintf('测试2: 纯追踪(PP)测试\n');
    guidance_law = GuidanceLaw('PP', struct());
    [accel_cmd, info] = guidance_law.calculate(missile_state, target_state, relative_motion);
    
    assert(strcmp(info.law_type, 'PP'), '制导律类型错误');
    assert(norm(accel_cmd) > 0, 'PP加速度指令为零');
    fprintf('  通过\n\n');
    
    fprintf('测试3: 扩展比例导引(APN)测试\n');
    params.N = 3.0;
    guidance_law = GuidanceLaw('APN', params);
    [accel_cmd, info] = guidance_law.calculate(missile_state, target_state, relative_motion);
    
    assert(strcmp(info.law_type, 'APN'), '制导律类型错误');
    assert(abs(info.N - params.N) < 1e-6, 'N值错误');
    fprintf('  通过\n\n');
    
    fprintf('测试4: 最优制导律(OGL)测试\n');
    params.N = 3.0;
    guidance_law = GuidanceLaw('OGL', params);
    [accel_cmd, info] = guidance_law.calculate(missile_state, target_state, relative_motion);
    
    assert(strcmp(info.law_type, 'OGL'), '制导律类型错误');
    assert(abs(info.N - params.N) < 1e-6, 'N值错误');
    assert(abs(info.time_to_go - relative_motion.time_to_go) < 1e-6, '剩余时间错误');
    fprintf('  通过\n\n');
    
    fprintf('测试5: PN视线角速率响应测试\n');
    params.N = 3.0;
    guidance_law = GuidanceLaw('PN', params);
    
    los_rate_1 = [0; 0; 0.01];
    los_rate_2 = [0; 0; 0.02];
    relative_motion.los_rate = los_rate_1;
    [accel_cmd_1, ~] = guidance_law.calculate(missile_state, target_state, relative_motion);
    relative_motion.los_rate = los_rate_2;
    [accel_cmd_2, ~] = guidance_law.calculate(missile_state, target_state, relative_motion);
    
    assert(norm(accel_cmd_2) > norm(accel_cmd_1), 'PN对视线角速率响应错误');
    fprintf('  通过\n\n');
    
    fprintf('测试6: PN接近速度响应测试\n');
    params.N = 3.0;
    guidance_law = GuidanceLaw('PN', params);
    
    Vc_1 = 500;
    Vc_2 = 1000;
    relative_motion.los_rate = [0; 0; 0.01];
    relative_motion.closing_velocity = Vc_1;
    [accel_cmd_1, ~] = guidance_law.calculate(missile_state, target_state, relative_motion);
    relative_motion.closing_velocity = Vc_2;
    [accel_cmd_2, ~] = guidance_law.calculate(missile_state, target_state, relative_motion);
    
    assert(norm(accel_cmd_2) > norm(accel_cmd_1), 'PN对接近速度响应错误');
    fprintf('  通过\n\n');
    
    fprintf('测试7: APN目标加速度补偿测试\n');
    params.N = 3.0;
    guidance_law = GuidanceLaw('APN', params);
    
    target_state.acceleration = [0; 50; 0];
    [accel_cmd_1, info_1] = guidance_law.calculate(missile_state, target_state, relative_motion);
    
    target_state.acceleration = [0; 100; 0];
    [accel_cmd_2, info_2] = guidance_law.calculate(missile_state, target_state, relative_motion);
    
    assert(norm(info_2.target_accel_normal) > norm(info_1.target_accel_normal), 'APN目标加速度补偿错误');
    fprintf('  通过\n\n');
    
    fprintf('测试8: 参数设置测试\n');
    params.N = 5.0;
    guidance_law = GuidanceLaw('PN', params);
    retrieved_params = guidance_law.get_params();
    
    assert(abs(retrieved_params.N - params.N) < 1e-6, '参数获取错误');
    fprintf('  通过\n\n');
    
    fprintf('测试9: 参数更新测试\n');
    guidance_law = GuidanceLaw('PN', struct('N', 3.0));
    new_params.N = 4.0;
    guidance_law.set_params(new_params);
    retrieved_params = guidance_law.get_params();
    
    assert(abs(retrieved_params.N - 4.0) < 1e-6, '参数更新错误');
    fprintf('  通过\n\n');
    
    fprintf('========================================\n');
    fprintf('  所有测试通过!\n');
    fprintf('========================================\n');
end
