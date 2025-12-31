function main()
    addpath('models');
    addpath('guidance');
    addpath('simulation');
    addpath('utils');
    addpath('tests');
    
    params = config();
    
    fprintf('========================================\n');
    fprintf('  寻的导弹制导律验证程序\n');
    fprintf('========================================\n\n');
    
    fprintf('配置参数:\n');
    fprintf('  制导律: %s\n', params.guidance.law_type);
    fprintf('  导弹最大加速度: %.1f m/s²\n', params.missile.max_acceleration);
    fprintf('  目标运动模式: %s\n', params.target.motion_type);
    fprintf('  仿真时间步长: %.3f s\n', params.simulation.dt);
    fprintf('  最大仿真时间: %.1f s\n', params.simulation.max_time);
    fprintf('\n');
    
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
    
    data_logger = DataLogger();
    
    fprintf('开始仿真...\n');
    sim_env.initialize();
    
    while sim_env.running
        sim_env.step();
        
        data_logger.log(sim_env.time, sim_env.missile.get_state(), ...
            sim_env.target.get_state(), sim_env.relative_motion, ...
            sim_env.missile.acceleration);
    end
    
    fprintf('仿真完成!\n\n');
    
    results = sim_env.get_results();
    
    fprintf('仿真结果:\n');
    fprintf('  终止原因: %s\n', results.termination_reason);
    fprintf('  仿真时间: %.4f s\n', results.time);
    fprintf('  最终脱靶量: %.4f m\n', results.miss_distance);
    fprintf('  初始距离: %.4f m\n', norm(params.missile.position - params.target.position));
    fprintf('  最终导弹位置: [%.2f, %.2f, %.2f]\n', results.missile_state.position(1), results.missile_state.position(2), results.missile_state.position(3));
    fprintf('  最终目标位置: [%.2f, %.2f, %.2f]\n', results.target_state.position(1), results.target_state.position(2), results.target_state.position(3));
    fprintf('\n');
    
    if results.termination_reason == 'intercepted'
        fprintf('✅ 导弹成功命中目标!\n\n');
    else
        fprintf('❌ 导弹未命中目标!\n\n');
    end
    
    data = data_logger.get_all_data();
    
    metrics = Analyzer.calculate_metrics(data, results);
    
    report = Analyzer.generate_report(metrics);
    fprintf('%s\n', report);
    
    if params.output.save_data
        if ~exist(params.output.data_dir, 'dir')
            mkdir(params.output.data_dir);
        end
        
        timestamp = datestr(now, 'yyyymmdd_HHMMSS');
        data_filename = fullfile(params.output.data_dir, sprintf('simulation_data_%s.mat', timestamp));
        data_logger.save(data_filename, 'mat');
        fprintf('数据已保存到: %s\n', data_filename);
    end
    
    if params.output.save_figures
        if ~exist(params.output.figures_dir, 'dir')
            mkdir(params.output.figures_dir);
        end
        
        Visualizer.plot_all(data, params.output.figures_dir);
        fprintf('图形已保存到: %s\n', params.output.figures_dir);
    end
    
    if params.output.create_animation
        if ~exist(params.output.figures_dir, 'dir')
            mkdir(params.output.figures_dir);
        end
        
        Visualizer.animate_trajectory(data, params.output.figures_dir);
        fprintf('动画已保存到: %s\n', params.output.figures_dir);
    end
    
    fprintf('\n========================================\n');
    fprintf('  程序执行完成\n');
    fprintf('========================================\n');
end
