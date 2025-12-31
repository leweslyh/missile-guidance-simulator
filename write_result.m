% 脚本：将仿真结果写入文件，以便查看完整输出
addpath('models');
addpath('guidance');
addpath('simulation');
addpath('utils');

% 打开文件用于写入结果
fid = fopen('simulation_result.txt', 'w');
fprintf(fid, '导弹制导仿真结果\n');
fprintf(fid, '===================\n\n');

% 参数设置
missile_pos = [0; 0; 0];
missile_vel = [300; 0; 0];
target_pos = [2000; 800; 400]; % 更近的目标
target_vel = [-80; 0; 0];

fprintf(fid, '初始条件：\n');
fprintf(fid, '导弹位置：[%f, %f, %f]\n', missile_pos(1), missile_pos(2), missile_pos(3));
fprintf(fid, '导弹速度：[%f, %f, %f]\n', missile_vel(1), missile_vel(2), missile_vel(3));
fprintf(fid, '目标位置：[%f, %f, %f]\n', target_pos(1), target_pos(2), target_pos(3));
fprintf(fid, '目标速度：[%f, %f, %f]\n', target_vel(1), target_vel(2), target_vel(3));
fprintf(fid, '导航比N：4.0\n');
fprintf(fid, '最大加速度：200.0 m/s²\n\n');

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
sim_params.max_time = 15.0;
sim_params.miss_distance_threshold = 5.0;
sim_params.min_missile_speed = 50.0;

sim_env = SimulationEnv(missile, target, guidance_law, sim_params);

% 运行仿真
sim_env.initialize();
fprintf(fid, '开始仿真...\n\n');
fprintf(fid, '时间(s) | 距离(m)\n');
fprintf(fid, '--------|--------\n');

% 记录初始距离
initial_dist = norm(missile_pos - target_pos);
fprintf(fid, '%.1f     | %.2f\n', 0.0, initial_dist);

while sim_env.running
    sim_env.step();
    % 每1秒记录一次
    if rem(sim_env.time, 1.0) < sim_params.dt
        fprintf(fid, '%.1f     | %.2f\n', sim_env.time, sim_env.relative_motion.relative_distance);
    end
end

% 最终结果
results = sim_env.get_results();
fprintf(fid, '\n=== 最终结果 ===\n');
fprintf(fid, '终止原因：%s\n', results.termination_reason);
fprintf(fid, '仿真时间：%.2f s\n', results.time);
fprintf(fid, '最终脱靶量：%.2f m\n', results.miss_distance);
fprintf(fid, '最终导弹位置：[%f, %f, %f]\n', results.missile_state.position(1), results.missile_state.position(2), results.missile_state.position(3));
fprintf(fid, '最终目标位置：[%f, %f, %f]\n', results.target_state.position(1), results.target_state.position(2), results.target_state.position(3));

if strcmp(results.termination_reason, 'intercepted')
    fprintf(fid, '\n✅ 导弹成功命中目标！\n');
else
    fprintf(fid, '\n❌ 导弹未命中目标！\n');
end

% 关闭文件
fclose(fid);

% 显示完成信息
fprintf('仿真完成！结果已写入 simulation_result.txt 文件\n');
