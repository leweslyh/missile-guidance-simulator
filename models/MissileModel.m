classdef MissileModel < handle
    properties
        position
        velocity
        acceleration
        attitude
        max_acceleration
        min_velocity
        mass
        thrust
        drag_coefficient
    end
    
    methods
        function obj = MissileModel(initial_state, params)
            if nargin < 2
                params = struct();
            end
            
            obj.position = initial_state.position;
            obj.velocity = initial_state.velocity;
            obj.acceleration = initial_state.acceleration;
            obj.attitude = initial_state.attitude;
            
            obj.max_acceleration = params.max_acceleration;
            obj.min_velocity = params.min_velocity;
            obj.mass = params.mass;
            obj.thrust = params.thrust;
            obj.drag_coefficient = params.drag_coefficient;
        end
        
        function obj = update(obj, guidance_cmd, dt)
            speed = norm(obj.velocity);
            
            if speed > 0
                velocity_dir = obj.velocity / speed;
            else
                velocity_dir = [1; 0; 0];
            end
            
            guidance_cmd_mag = norm(guidance_cmd);
            if guidance_cmd_mag > obj.max_acceleration
                guidance_cmd = guidance_cmd / guidance_cmd_mag * obj.max_acceleration;
            end
            
            obj.acceleration = guidance_cmd;
            
            obj.velocity = obj.velocity + obj.acceleration * dt;
            
            speed = norm(obj.velocity);
            if speed < obj.min_velocity
                obj.velocity = obj.velocity / speed * obj.min_velocity;
            end
            
            obj.position = obj.position + obj.velocity * dt;
            
            obj.attitude = obj.calculate_attitude();
        end
        
        function attitude = calculate_attitude(obj)
            speed = norm(obj.velocity);
            if speed > 1e-6
                attitude = obj.velocity / speed;
            else
                attitude = [1; 0; 0];
            end
        end
        
        function state = get_state(obj)
            state.position = obj.position;
            state.velocity = obj.velocity;
            state.acceleration = obj.acceleration;
            state.attitude = obj.attitude;
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
            if isfield(state, 'attitude')
                obj.attitude = state.attitude;
            end
        end
        
        function reset(obj, initial_state)
            obj.position = initial_state.position;
            obj.velocity = initial_state.velocity;
            obj.acceleration = initial_state.acceleration;
            obj.attitude = initial_state.attitude;
        end
    end
end
