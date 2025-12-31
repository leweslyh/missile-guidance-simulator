function test_TargetModel()
    addpath('..');
    addpath('../models');
    addpath('../guidance');
    addpath('../simulation');
    addpath('../utils');
    
    fprintf('========================================\n');
    fprintf('  测试目标运动学模型\n');
    fprintf('========================================\n\n');
    
    initial_state.position = [5000; 3000; 1000];
    initial_state.velocity = [-200; 0; 0];
    initial_state.acceleration = [0; 0; 0];
    
    fprintf('测试1: 匀速运动测试\n');
    target = TargetModel(initial_state, 'constant', struct());
    dt = 0.1;
    target.update(dt);
    
    expected_position = initial_state.position + initial_state.velocity * dt;
    assert(norm(target.position - expected_position) < 1e-6, '匀速运动位置错误');
    assert(norm(target.acceleration) < 1e-6, '匀速运动加速度不为零');
    fprintf('  通过\n\n');
    
    fprintf('测试2: 圆弧运动测试\n');
    target.reset(initial_state);
    motion_params.turn_rate = 0.5;
    target = TargetModel(initial_state, 'circular', motion_params);
    target.update(dt);
    
    speed = norm(initial_state.velocity);
    assert(abs(norm(target.velocity) - speed) < 1e-6, '圆弧运动速度大小改变');
    fprintf('  通过\n\n');
    
    fprintf('测试3: 正弦运动测试\n');
    target.reset(initial_state);
    motion_params.amplitude = 50;
    motion_params.frequency = 0.5;
    target = TargetModel(initial_state, 'sine', motion_params);
    target.update(dt);
    
    speed = norm(initial_state.velocity);
    assert(abs(norm(target.velocity) - speed) < 10, '正弦运动速度大小变化过大');
    fprintf('  通过\n\n');
    
    fprintf('测试4: 随机运动测试\n');
    target.reset(initial_state);
    motion_params.max_accel = 20;
    motion_params.change_prob = 0.1;
    target = TargetModel(initial_state, 'random', motion_params);
    target.update(dt);
    
    assert(norm(target.acceleration) <= motion_params.max_accel + 1e-6, '随机运动加速度超限');
    fprintf('  通过\n\n');
    
    fprintf('测试5: 机动运动测试\n');
    target.reset(initial_state);
    motion_params.turn_rate = 0.8;
    motion_params.switch_time = 2.0;
    target = TargetModel(initial_state, 'evasive', motion_params);
    target.update(dt);
    
    speed = norm(initial_state.velocity);
    assert(abs(norm(target.velocity) - speed) < 1e-6, '机动运动速度大小改变');
    fprintf('  通过\n\n');
    
    fprintf('测试6: 状态获取测试\n');
    target = TargetModel(initial_state, 'constant', struct());
    state = target.get_state();
    
    assert(isequal(state.position, initial_state.position), '位置获取失败');
    assert(isequal(state.velocity, initial_state.velocity), '速度获取失败');
    assert(isequal(state.acceleration, initial_state.acceleration), '加速度获取失败');
    fprintf('  通过\n\n');
    
    fprintf('测试7: 状态设置测试\n');
    target = TargetModel(initial_state, 'constant', struct());
    new_state.position = [6000; 4000; 2000];
    new_state.velocity = [-250; 50; 0];
    target.set_state(new_state);
    
    assert(isequal(target.position, new_state.position), '位置设置失败');
    assert(isequal(target.velocity, new_state.velocity), '速度设置失败');
    fprintf('  通过\n\n');
    
    fprintf('测试8: 重置测试\n');
    target = TargetModel(initial_state, 'constant', struct());
    target.update(dt);
    target.reset(initial_state);
    
    assert(isequal(target.position, initial_state.position), '重置后位置错误');
    assert(isequal(target.velocity, initial_state.velocity), '重置后速度错误');
    assert(target.time == 0, '重置后时间不为零');
    fprintf('  通过\n\n');
    
    fprintf('测试9: 时间更新测试\n');
    target = TargetModel(initial_state, 'constant', struct());
    initial_time = target.time;
    target.update(dt);
    
    assert(abs(target.time - initial_time - dt) < 1e-6, '时间更新错误');
    fprintf('  通过\n\n');
    
    fprintf('========================================\n');
    fprintf('  所有测试通过!\n');
    fprintf('========================================\n');
end
