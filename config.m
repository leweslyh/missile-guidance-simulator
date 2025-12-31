function params = config()
    params.simulation.dt = 0.01;
    params.simulation.max_time = 30.0;
    params.simulation.miss_distance_threshold = 5.0;
    params.simulation.min_missile_speed = 50.0;
    
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
    params.guidance.N = 4.0;
    
    params.output.results_dir = 'results';
    params.output.data_dir = 'results/data';
    params.output.figures_dir = 'results/figures';
    params.output.save_data = true;
    params.output.save_figures = true;
    params.output.create_animation = false;
end
