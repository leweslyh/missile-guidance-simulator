% 简单测试脚本，确保能看到完整输出
addpath('models');
addpath('guidance');
addpath('simulation');
addpath('utils');

% 简化的参数设置
missile_pos = [0; 0; 0];
missile_vel = [300; 0; 0];
target_pos = [3000; 1000; 500]; % 更近的目标，更容易命中
target_vel = [-100; 0; 0];

% 初始化模型
missile_state.position = missile_pos;
missile_state.velocity = missile_vel;
missile_state.acceleration = [0; 0; 0];
missile_state.attitude = [1; 0; 0];

target_state.position = target_pos;
target_state.velocity = target_vel;
target_state.acceleration = [0; 0; 0];

missile_params.max_acceleration = 200.0;
missile_params.min_velocity = 50.0;
missile_params.mass = 100.0;
missile_params.thrust = 0.0;
missile_params.drag_coefficient = 0.0;

missile = MissileModel(missile_state, missile_params);
target = TargetModel(target_state, 'constant', struct());

guidance_params.N = 4.0;
guidance_law = GuidanceLaw('PN', guidance_params);

sim_params.dt = 0.01;
sim_params.max_time = 20.0;
sim_params.miss_distance_threshold = 5.0;
sim_params.min_missile_speed = 50.0;

sim_env = SimulationEnv(missile, target, guidance_law, sim_params);

% 运行仿真
sim_env.initialize();
fprintf('开始仿真...\n');

while sim_env.running
    sim_env.step();
    % 每0.5秒打印一次结果
    if rem(sim_env.time, 0.5) < sim_params.dt
        fprintf('时间: %.1f s | 距离: %.2f m\n', sim_env.time, sim_env.relative_motion.relative_distance);
    end
end

% 显示最终结果
results = sim_env.get_results();
fprintf('\n=== 最终结果 ===\n');
fprintf('终止原因: %s\n', results.termination_reason);
fprintf('仿真时间: %.2f s\n', results.time);
fprintf('最终脱靶量: %.2f m\n', results.miss_distance);

if strcmp(results.termination_reason, 'intercepted')
    fprintf('✅ 导弹成功命中目标!\n');
else
    fprintf('❌ 导弹未命中目标!\n');
end
