function test_MissileModel()
    addpath('..');
    addpath('../models');
    addpath('../guidance');
    addpath('../simulation');
    addpath('../utils');
    
    fprintf('========================================\n');
    fprintf('  测试导弹运动学模型\n');
    fprintf('========================================\n\n');
    
    initial_state.position = [0; 0; 0];
    initial_state.velocity = [300; 0; 0];
    initial_state.acceleration = [0; 0; 0];
    initial_state.attitude = [1; 0; 0];
    
    params.max_acceleration = 200.0;
    params.min_velocity = 50.0;
    params.mass = 100.0;
    params.thrust = 0.0;
    params.drag_coefficient = 0.0;
    
    missile = MissileModel(initial_state, params);
    
    fprintf('测试1: 初始化测试\n');
    assert(isequal(missile.position, initial_state.position), '位置初始化失败');
    assert(isequal(missile.velocity, initial_state.velocity), '速度初始化失败');
    assert(isequal(missile.acceleration, initial_state.acceleration), '加速度初始化失败');
    fprintf('  通过\n\n');
    
    fprintf('测试2: 状态获取测试\n');
    state = missile.get_state();
    assert(isequal(state.position, initial_state.position), '位置获取失败');
    assert(isequal(state.velocity, initial_state.velocity), '速度获取失败');
    assert(norm(state.attitude - 1) < 1e-6, '姿态获取失败');
    fprintf('  通过\n\n');
    
    fprintf('测试3: 更新测试\n');
    guidance_cmd = [50; 0; 0];
    dt = 0.1;
    missile.update(guidance_cmd, dt);
    
    expected_position = initial_state.position + initial_state.velocity * dt;
    expected_velocity = initial_state.velocity + guidance_cmd * dt;
    
    assert(norm(missile.position - expected_position) < 1e-6, '位置更新失败');
    assert(norm(missile.velocity - expected_velocity) < 1e-6, '速度更新失败');
    fprintf('  通过\n\n');
    
    fprintf('测试4: 加速度限制测试\n');
    missile.reset(initial_state);
    guidance_cmd = [300; 0; 0];
    missile.update(guidance_cmd, dt);
    
    assert(norm(missile.acceleration) <= params.max_acceleration + 1e-6, '加速度限制失败');
    fprintf('  通过\n\n');
    
    fprintf('测试5: 最小速度限制测试\n');
    missile.reset(initial_state);
    missile.velocity = [60; 0; 0];
    guidance_cmd = [-200; 0; 0];
    missile.update(guidance_cmd, dt);
    
    assert(norm(missile.velocity) >= params.min_velocity - 1e-6, '最小速度限制失败');
    fprintf('  通过\n\n');
    
    fprintf('测试6: 姿态计算测试\n');
    missile.reset(initial_state);
    missile.velocity = [300; 400; 0];
    attitude = missile.calculate_attitude();
    expected_attitude = missile.velocity / norm(missile.velocity);
    
    assert(norm(attitude - expected_attitude) < 1e-6, '姿态计算失败');
    fprintf('  通过\n\n');
    
    fprintf('测试7: 状态设置测试\n');
    new_state.position = [100; 200; 300];
    new_state.velocity = [400; 500; 600];
    missile.set_state(new_state);
    
    assert(isequal(missile.position, new_state.position), '位置设置失败');
    assert(isequal(missile.velocity, new_state.velocity), '速度设置失败');
    fprintf('  通过\n\n');
    
    fprintf('测试8: 重置测试\n');
    missile.update([100; 100; 100], dt);
    missile.reset(initial_state);
    
    assert(isequal(missile.position, initial_state.position), '重置后位置错误');
    assert(isequal(missile.velocity, initial_state.velocity), '重置后速度错误');
    fprintf('  通过\n\n');
    
    fprintf('========================================\n');
    fprintf('  所有测试通过!\n');
    fprintf('========================================\n');
end
