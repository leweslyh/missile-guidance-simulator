classdef GuidanceLaw < handle
    properties
        law_type
        params
    end
    
    methods
        function obj = GuidanceLaw(law_type, params)
            if nargin < 2
                params = struct();
            end
            if nargin < 1
                law_type = 'PN';
            end
            
            obj.law_type = law_type;
            obj.params = params;
        end
        
        function [accel_cmd, info] = calculate(obj, missile_state, target_state, relative_motion)
            switch obj.law_type
                case 'PN'
                    [accel_cmd, info] = calculate_PN(obj, missile_state, target_state, relative_motion);
                case 'PP'
                    [accel_cmd, info] = calculate_PP(obj, missile_state, target_state, relative_motion);
                case 'APN'
                    [accel_cmd, info] = calculate_APN(obj, missile_state, target_state, relative_motion);
                case 'OGL'
                    [accel_cmd, info] = calculate_OGL(obj, missile_state, target_state, relative_motion);
                otherwise
                    [accel_cmd, info] = calculate_PN(obj, missile_state, target_state, relative_motion);
            end
        end
        
        function [accel_cmd, info] = calculate_PN(obj, missile_state, target_state, relative_motion)
            if isfield(obj.params, 'N')
                N = obj.params.N;
            else
                N = 3;
            end
            
            if isfield(relative_motion, 'los_rate')
                los_rate = relative_motion.los_rate;
            else
                los_rate = [0; 0; 0];
            end
            
            if isfield(relative_motion, 'closing_velocity')
                Vc = relative_motion.closing_velocity;
            else
                Vc = norm(relative_motion.relative_velocity);
            end
            
            if isfield(relative_motion, 'los_vector')
                los_vector = relative_motion.los_vector;
            else
                los_vector = relative_motion.relative_position / norm(relative_motion.relative_position);
            end
            
            if Vc > 1e-6
                % 正确的PN制导律：加速度垂直于视线
                % 叉积顺序应该是 los_rate × los_vector
                accel_cmd = N * Vc * cross(los_rate, los_vector);
            else
                accel_cmd = [0; 0; 0];
            end
            
            info.law_type = 'PN';
            info.N = N;
            info.los_rate = los_rate;
            info.closing_velocity = Vc;
            info.los_vector = los_vector;
        end
        
        function [accel_cmd, info] = calculate_PP(obj, missile_state, target_state, relative_motion)
            if isfield(missile_state, 'speed')
                Vm = missile_state.speed;
            else
                Vm = norm(missile_state.velocity);
            end
            
            if isfield(relative_motion, 'los_vector')
                los_vector = relative_motion.los_vector;
            else
                los_vector = relative_motion.relative_position / norm(relative_motion.relative_position);
            end
            
            if isfield(missile_state, 'velocity')
                Vm_vec = missile_state.velocity;
            else
                Vm_vec = [0; 0; 0];
            end
            
            desired_velocity = los_vector * Vm;
            accel_cmd = (desired_velocity - Vm_vec) / 0.1;
            
            info.law_type = 'PP';
            info.los_vector = los_vector;
            info.desired_velocity = desired_velocity;
        end
        
        function [accel_cmd, info] = calculate_APN(obj, missile_state, target_state, relative_motion)
            if isfield(obj.params, 'N')
                N = obj.params.N;
            else
                N = 3;
            end
            
            if isfield(relative_motion, 'los_rate')
                los_rate = relative_motion.los_rate;
            else
                los_rate = [0; 0; 0];
            end
            
            if isfield(relative_motion, 'closing_velocity')
                Vc = relative_motion.closing_velocity;
            else
                Vc = norm(relative_motion.relative_velocity);
            end
            
            if isfield(target_state, 'acceleration')
                At = target_state.acceleration;
            else
                At = [0; 0; 0];
            end
            
            if isfield(relative_motion, 'los_vector')
                los_vector = relative_motion.los_vector;
            else
                los_vector = relative_motion.relative_position / norm(relative_motion.relative_position);
            end
            
            At_normal = At - dot(At, los_vector) * los_vector;
            
            if Vc > 1e-6
                % 正确的APN制导律：加速度垂直于视线，加上目标加速度补偿
                % 叉积顺序应该是 los_rate × los_vector
                accel_cmd = N * Vc * cross(los_rate, los_vector) + (N/2) * At_normal;
            else
                accel_cmd = (N/2) * At_normal;
            end
            
            info.law_type = 'APN';
            info.N = N;
            info.los_rate = los_rate;
            info.closing_velocity = Vc;
            info.target_accel_normal = At_normal;
            info.los_vector = los_vector;
        end
        
        function [accel_cmd, info] = calculate_OGL(obj, missile_state, target_state, relative_motion)
            if isfield(obj.params, 'N')
                N = obj.params.N;
            else
                N = 3;
            end
            
            if isfield(relative_motion, 'los_rate')
                los_rate = relative_motion.los_rate;
            else
                los_rate = [0; 0; 0];
            end
            
            if isfield(relative_motion, 'closing_velocity')
                Vc = relative_motion.closing_velocity;
            else
                Vc = norm(relative_motion.relative_velocity);
            end
            
            if isfield(relative_motion, 'time_to_go')
                t_go = relative_motion.time_to_go;
            else
                if Vc > 1e-6
                    t_go = norm(relative_motion.relative_position) / Vc;
                else
                    t_go = 1.0;
                end
            end
            
            if isfield(target_state, 'acceleration')
                At = target_state.acceleration;
            else
                At = [0; 0; 0];
            end
            
            if isfield(relative_motion, 'los_vector')
                los_vector = relative_motion.los_vector;
            else
                los_vector = relative_motion.relative_position / norm(relative_motion.relative_position);
            end
            
            At_normal = At - dot(At, los_vector) * los_vector;
            
            if t_go > 1e-6
                % 正确的OGL制导律：加速度垂直于视线，加上目标加速度和时间到拦截补偿
                % 叉积顺序应该是 los_rate × los_vector
                accel_cmd = N * Vc * cross(los_rate, los_vector) + (N/2) * At_normal * (1 - 2/(N*t_go*Vc));
            else
                accel_cmd = N * Vc * cross(los_rate, los_vector) + (N/2) * At_normal;
            end
            
            info.law_type = 'OGL';
            info.N = N;
            info.los_rate = los_rate;
            info.closing_velocity = Vc;
            info.time_to_go = t_go;
            info.target_accel_normal = At_normal;
            info.los_vector = los_vector;
        end
        
        function obj = set_params(obj, params)
            obj.params = params;
        end
        
        function params = get_params(obj)
            params = obj.params;
        end
    end
end
