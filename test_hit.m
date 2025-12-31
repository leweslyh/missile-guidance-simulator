% 简单测试脚本，用于验证导弹是否能命中目标
addpath('models');
addpath('guidance');
addpath('simulation');
addpath('utils');

% 配置参数
params.missile.position = [0; 0; 0];
params.missile.velocity = [300; 0; 0];
params.missile.acceleration = [0; 0; 0];
params.missile.attitude = [1; 0; 0];
params.missile.max_acceleration = 200.0;
params.missile.min_velocity = 50.0;
params.missile.mass = 100.0;
params.missile.thrust = 0.0;
params.missile.drag_coefficient = 0.0;

params.target.position = [5000; 3000; 1000];
params.target.velocity = [-200; 0; 0];
params.target.acceleration = [0; 0; 0];
params.target.motion_type = 'constant';
params.target.motion_params = struct();

params.guidance.law_type = 'PN';
params.guidance.N = 3.0;

params.simulation.dt = 0.01;
params.simulation.max_time = 10.0;
params.simulation.miss_distance_threshold = 5.0;
params.simulation.min_missile_speed = 50.0;

% 初始化模型
missile_initial_state.position = params.missile.position;
missile_initial_state.velocity = params.missile.velocity;
missile_initial_state.acceleration = params.missile.acceleration;
missile_initial_state.attitude = params.missile.attitude;

target_initial_state.position = params.target.position;
target_initial_state.velocity = params.target.velocity;
target_initial_state.acceleration = params.target.acceleration;

missile_params.max_acceleration = params.missile.max_acceleration;
missile_params.min_velocity = params.missile.min_velocity;
missile_params.mass = params.missile.mass;
missile_params.thrust = params.missile.thrust;
missile_params.drag_coefficient = params.missile.drag_coefficient;

missile = MissileModel(missile_initial_state, missile_params);
target = TargetModel(target_initial_state, params.target.motion_type, params.target.motion_params);

guidance_params.N = params.guidance.N;
guidance_law = GuidanceLaw(params.guidance.law_type, guidance_params);

sim_params.dt = params.simulation.dt;
sim_params.max_time = params.simulation.max_time;
sim_params.miss_distance_threshold = params.simulation.miss_distance_threshold;
sim_params.min_missile_speed = params.simulation.min_missile_speed;

sim_env = SimulationEnv(missile, target, guidance_law, sim_params);

% 运行仿真
data_logger = DataLogger();
fprintf('开始仿真...\n');
sim_env.initialize();

% 记录关键数据
time_history = [];
miss_distance_history = [];

while sim_env.running
    sim_env.step();
    data_logger.log(sim_env.time, sim_env.missile.get_state(), ...
        sim_env.target.get_state(), sim_env.relative_motion, ...
        sim_env.missile.acceleration);
    
    % 记录距离数据用于分析
    time_history(end+1) = sim_env.time;
    miss_distance_history(end+1) = sim_env.relative_motion.relative_distance;
    
    % 每1秒打印一次进度
    if rem(sim_env.time, 1.0) < params.simulation.dt
        fprintf('时间: %.1f s, 距离: %.2f m\n', sim_env.time, sim_env.relative_motion.relative_distance);
    end
end

results = sim_env.get_results();
data = data_logger.get_all_data();

% 显示结果
fprintf('\n========================================\n');
fprintf('  仿真结果\n');
fprintf('========================================\n');
fprintf('终止原因: %s\n', results.termination_reason);
fprintf('仿真时间: %.4f s\n', results.time);
fprintf('最终脱靶量: %.4f m\n', results.miss_distance);
fprintf('初始距离: %.4f m\n', norm(params.missile.position - params.target.position));
fprintf('最小距离: %.4f m\n', min(miss_distance_history));
fprintf('最终导弹位置: [%.2f, %.2f, %.2f]\n', results.missile_state.position(1), results.missile_state.position(2), results.missile_state.position(3));
fprintf('最终目标位置: [%.2f, %.2f, %.2f]\n', results.target_state.position(1), results.target_state.position(2), results.target_state.position(3));
fprintf('========================================\n');

if results.termination_reason == 'intercepted'
    fprintf('✅ 导弹成功命中目标!\n');
else
    fprintf('❌ 导弹未命中目标!\n');
    fprintf('最小距离: %.4f m\n', min(miss_distance_history));
end
