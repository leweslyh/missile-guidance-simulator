classdef SimulationEnv < handle
    properties
        missile
        target
        guidance_law
        data_logger
        time
        dt
        max_time
        miss_distance_threshold
        min_missile_speed
        running
        relative_motion
    end
    
    methods
        function obj = SimulationEnv(missile, target, guidance_law, params)
            if nargin < 4
                params = struct();
            end
            
            obj.missile = missile;
            obj.target = target;
            obj.guidance_law = guidance_law;
            
            obj.time = 0;
            obj.dt = params.dt;
            obj.max_time = params.max_time;
            obj.miss_distance_threshold = params.miss_distance_threshold;
            obj.min_missile_speed = params.min_missile_speed;
            obj.running = false;
            
            obj.relative_motion = struct();
        end
        
        function obj = initialize(obj)
            obj.time = 0;
            obj.running = true;
            obj = update_relative_motion(obj);
        end
        
        function obj = step(obj)
            if ~obj.running
                return;
            end
            
            obj = update_relative_motion(obj);
            
            [accel_cmd, ~] = obj.guidance_law.calculate(...
                obj.missile.get_state(), ...
                obj.target.get_state(), ...
                obj.relative_motion);
            
            obj.missile.update(accel_cmd, obj.dt);
            obj.target.update(obj.dt);
            
            obj.time = obj.time + obj.dt;
            
            obj = check_termination(obj);
        end
        
        function obj = update_relative_motion(obj)
            missile_state = obj.missile.get_state();
            target_state = obj.target.get_state();
            
            obj.relative_motion.relative_position = target_state.position - missile_state.position;
            obj.relative_motion.relative_velocity = target_state.velocity - missile_state.velocity;
            
            relative_distance = norm(obj.relative_motion.relative_position);
            obj.relative_motion.relative_distance = relative_distance;
            
            if relative_distance > 1e-6
                obj.relative_motion.los_vector = obj.relative_motion.relative_position / relative_distance;
            else
                obj.relative_motion.los_vector = [0; 0; 0];
            end
            
            relative_speed = norm(obj.relative_motion.relative_velocity);
            obj.relative_motion.relative_speed = relative_speed;
            
            closing_velocity = -dot(obj.relative_motion.relative_velocity, obj.relative_motion.los_vector);
            obj.relative_motion.closing_velocity = closing_velocity;
            
            if relative_distance > 1e-6 && relative_speed > 1e-6
                Vr = obj.relative_motion.relative_velocity;
                R = obj.relative_motion.relative_position;
                % 正确的视线速率计算：los_rate = cross(R, Vr) / ||R||^2
                % 注意：叉积顺序是 R × Vr，而不是 Vr × R
                los_rate = cross(R, Vr) / (relative_distance^2);
                obj.relative_motion.los_rate = los_rate;
            else
                obj.relative_motion.los_rate = [0; 0; 0];
            end
            
            if closing_velocity > 1e-6
                obj.relative_motion.time_to_go = relative_distance / closing_velocity;
            else
                obj.relative_motion.time_to_go = inf;
            end
            
            obj.relative_motion.azimuth = atan2(obj.relative_motion.los_vector(2), obj.relative_motion.los_vector(1));
            obj.relative_motion.elevation = asin(obj.relative_motion.los_vector(3));
        end
        
        function obj = check_termination(obj)
            if obj.relative_motion.relative_distance <= obj.miss_distance_threshold
                obj.running = false;
                return;
            end
            
            if obj.time >= obj.max_time
                obj.running = false;
                return;
            end
            
            missile_state = obj.missile.get_state();
            if missile_state.speed < obj.min_missile_speed
                obj.running = false;
                return;
            end
        end
        
        function obj = run(obj, data_logger)
            obj.initialize();
            
            if nargin < 2
                data_logger = [];
            end
            
            while obj.running
                obj.step();
                
                if ~isempty(data_logger)
                    data_logger.log(obj.time, obj.missile.get_state(), ...
                        obj.target.get_state(), obj.relative_motion);
                end
            end
        end
        
        function results = get_results(obj)
            results.time = obj.time;
            results.missile_state = obj.missile.get_state();
            results.target_state = obj.target.get_state();
            results.relative_motion = obj.relative_motion;
            results.termination_reason = obj.get_termination_reason();
            results.miss_distance = obj.relative_motion.relative_distance;
        end
        
        function reason = get_termination_reason(obj)
            if obj.relative_motion.relative_distance <= obj.miss_distance_threshold
                reason = 'intercepted';
            elseif obj.time >= obj.max_time
                reason = 'timeout';
            else
                reason = 'low_speed';
            end
        end
        
        function reset(obj, missile_state, target_state)
            obj.missile.reset(missile_state);
            obj.target.reset(target_state);
            obj.time = 0;
            obj.running = false;
        end
    end
end
