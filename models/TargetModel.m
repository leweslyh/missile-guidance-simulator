classdef TargetModel < handle
    properties
        position
        velocity
        acceleration
        motion_type
        motion_params
        time
    end
    
    methods
        function obj = TargetModel(initial_state, motion_type, motion_params)
            if nargin < 3
                motion_params = struct();
            end
            if nargin < 2
                motion_type = 'constant';
            end
            
            obj.position = initial_state.position;
            obj.velocity = initial_state.velocity;
            obj.acceleration = initial_state.acceleration;
            obj.motion_type = motion_type;
            obj.motion_params = motion_params;
            obj.time = 0;
        end
        
        function obj = update(obj, dt)
            obj.time = obj.time + dt;
            
            switch obj.motion_type
                case 'constant'
                    obj = update_constant(obj, dt);
                case 'circular'
                    obj = update_circular(obj, dt);
                case 'sine'
                    obj = update_sine(obj, dt);
                case 'random'
                    obj = update_random(obj, dt);
                case 'evasive'
                    obj = update_evasive(obj, dt);
                otherwise
                    obj = update_constant(obj, dt);
            end
            
            obj.position = obj.position + obj.velocity * dt;
        end
        
        function obj = update_constant(obj, dt)
            obj.acceleration = [0; 0; 0];
        end
        
        function obj = update_circular(obj, dt)
            if isfield(obj.motion_params, 'turn_rate')
                turn_rate = obj.motion_params.turn_rate;
            else
                turn_rate = 0.5;
            end
            
            speed = norm(obj.velocity);
            if speed > 1e-6
                velocity_dir = obj.velocity / speed;
                
                R = [cos(turn_rate*dt), -sin(turn_rate*dt), 0;
                     sin(turn_rate*dt), cos(turn_rate*dt), 0;
                     0, 0, 1];
                
                new_velocity_dir = R * velocity_dir;
                obj.velocity = new_velocity_dir * speed;
                obj.acceleration = (new_velocity_dir - velocity_dir) * speed / dt;
            end
        end
        
        function obj = update_sine(obj, dt)
            if isfield(obj.motion_params, 'amplitude')
                amplitude = obj.motion_params.amplitude;
            else
                amplitude = 50;
            end
            
            if isfield(obj.motion_params, 'frequency')
                frequency = obj.motion_params.frequency;
            else
                frequency = 0.5;
            end
            
            speed = norm(obj.velocity);
            if speed > 1e-6
                velocity_dir = obj.velocity / speed;
                
                lateral_accel = amplitude * sin(2 * pi * frequency * obj.time);
                
                if abs(velocity_dir(1)) > abs(velocity_dir(2))
                    perp_dir = [0; 1; 0];
                else
                    perp_dir = [1; 0; 0];
                end
                
                obj.acceleration = perp_dir * lateral_accel;
            end
        end
        
        function obj = update_random(obj, dt)
            if isfield(obj.motion_params, 'max_accel')
                max_accel = obj.motion_params.max_accel;
            else
                max_accel = 20;
            end
            
            if isfield(obj.motion_params, 'change_prob')
                change_prob = obj.motion_params.change_prob;
            else
                change_prob = 0.1;
            end
            
            if rand() < change_prob
                obj.acceleration = (rand(3, 1) - 0.5) * 2 * max_accel;
            end
        end
        
        function obj = update_evasive(obj, dt)
            if isfield(obj.motion_params, 'turn_rate')
                turn_rate = obj.motion_params.turn_rate;
            else
                turn_rate = 0.8;
            end
            
            if isfield(obj.motion_params, 'switch_time')
                switch_time = obj.motion_params.switch_time;
            else
                switch_time = 2.0;
            end
            
            speed = norm(obj.velocity);
            if speed > 1e-6
                velocity_dir = obj.velocity / speed;
                
                current_turn = turn_rate * sin(2 * pi * obj.time / switch_time);
                
                R = [cos(current_turn*dt), -sin(current_turn*dt), 0;
                     sin(current_turn*dt), cos(current_turn*dt), 0;
                     0, 0, 1];
                
                new_velocity_dir = R * velocity_dir;
                obj.velocity = new_velocity_dir * speed;
                obj.acceleration = (new_velocity_dir - velocity_dir) * speed / dt;
            end
        end
        
        function state = get_state(obj)
            state.position = obj.position;
            state.velocity = obj.velocity;
            state.acceleration = obj.acceleration;
            state.speed = norm(obj.velocity);
        end
        
        function obj = set_state(obj, state)
            if isfield(state, 'position')
                obj.position = state.position;
            end
            if isfield(state, 'velocity')
                obj.velocity = state.velocity;
            end
            if isfield(state, 'acceleration')
                obj.acceleration = state.acceleration;
            end
        end
        
        function reset(obj, initial_state)
            obj.position = initial_state.position;
            obj.velocity = initial_state.velocity;
            obj.acceleration = initial_state.acceleration;
            obj.time = 0;
        end
    end
end
