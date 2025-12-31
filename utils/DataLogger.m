classdef DataLogger < handle
    properties
        time_history
        missile_position_history
        missile_velocity_history
        missile_acceleration_history
        target_position_history
        target_velocity_history
        target_acceleration_history
        relative_distance_history
        los_rate_history
        closing_velocity_history
        time_to_go_history
        guidance_cmd_history
        max_points
    end
    
    methods
        function obj = DataLogger(max_points)
            if nargin < 1
                max_points = 100000;
            end
            
            obj.time_history = [];
            obj.missile_position_history = [];
            obj.missile_velocity_history = [];
            obj.missile_acceleration_history = [];
            obj.target_position_history = [];
            obj.target_velocity_history = [];
            obj.target_acceleration_history = [];
            obj.relative_distance_history = [];
            obj.los_rate_history = [];
            obj.closing_velocity_history = [];
            obj.time_to_go_history = [];
            obj.guidance_cmd_history = [];
            obj.max_points = max_points;
        end
        
        function obj = log(obj, time, missile_state, target_state, relative_motion, guidance_cmd)
            if nargin < 6
                guidance_cmd = [0; 0; 0];
            end
            
            obj.time_history(end+1) = time;
            obj.missile_position_history(:, end+1) = missile_state.position;
            obj.missile_velocity_history(:, end+1) = missile_state.velocity;
            obj.missile_acceleration_history(:, end+1) = missile_state.acceleration;
            obj.target_position_history(:, end+1) = target_state.position;
            obj.target_velocity_history(:, end+1) = target_state.velocity;
            obj.target_acceleration_history(:, end+1) = target_state.acceleration;
            obj.relative_distance_history(end+1) = relative_motion.relative_distance;
            obj.los_rate_history(:, end+1) = relative_motion.los_rate;
            obj.closing_velocity_history(end+1) = relative_motion.closing_velocity;
            obj.time_to_go_history(end+1) = relative_motion.time_to_go;
            obj.guidance_cmd_history(:, end+1) = guidance_cmd;
            
            if length(obj.time_history) > obj.max_points
                warning('DataLogger: Maximum number of points reached. Consider increasing max_points.');
            end
        end
        
        function data = get_all_data(obj)
            data.time = obj.time_history;
            data.missile_position = obj.missile_position_history;
            data.missile_velocity = obj.missile_velocity_history;
            data.missile_acceleration = obj.missile_acceleration_history;
            data.target_position = obj.target_position_history;
            data.target_velocity = obj.target_velocity_history;
            data.target_acceleration = obj.target_acceleration_history;
            data.relative_distance = obj.relative_distance_history;
            data.los_rate = obj.los_rate_history;
            data.closing_velocity = obj.closing_velocity_history;
            data.time_to_go = obj.time_to_go_history;
            data.guidance_cmd = obj.guidance_cmd_history;
        end
        
        function obj = clear(obj)
            obj.time_history = [];
            obj.missile_position_history = [];
            obj.missile_velocity_history = [];
            obj.missile_acceleration_history = [];
            obj.target_position_history = [];
            obj.target_velocity_history = [];
            obj.target_acceleration_history = [];
            obj.relative_distance_history = [];
            obj.los_rate_history = [];
            obj.closing_velocity_history = [];
            obj.time_to_go_history = [];
            obj.guidance_cmd_history = [];
        end
        
        function save(obj, filename, format)
            if nargin < 3
                format = 'mat';
            end
            
            data = obj.get_all_data();
            
            switch format
                case 'mat'
                    save(filename, 'data');
                case 'csv'
                    obj.save_csv(filename, data);
                otherwise
                    error('Unsupported format: %s', format);
            end
        end
        
        function save_csv(obj, filename, data)
            n_points = length(data.time);
            
            csv_data = zeros(n_points, 1 + 3 + 3 + 3 + 3 + 3 + 3 + 1 + 3 + 1 + 1 + 3);
            
            csv_data(:, 1) = data.time';
            csv_data(:, 2:4) = data.missile_position';
            csv_data(:, 5:7) = data.missile_velocity';
            csv_data(:, 8:10) = data.missile_acceleration';
            csv_data(:, 11:13) = data.target_position';
            csv_data(:, 14:16) = data.target_velocity';
            csv_data(:, 17:19) = data.target_acceleration';
            csv_data(:, 20) = data.relative_distance';
            csv_data(:, 21:23) = data.los_rate';
            csv_data(:, 24) = data.closing_velocity';
            csv_data(:, 25) = data.time_to_go';
            csv_data(:, 26:28) = data.guidance_cmd';
            
            header = {'Time', 'Mx', 'My', 'Mz', 'MVx', 'MVy', 'MVz', 'MAx', 'MAy', 'MAz', ...
                      'Tx', 'Ty', 'Tz', 'TVx', 'TVy', 'TVz', 'TAx', 'TAy', 'TAz', ...
                      'RelDist', 'LOS_Rx', 'LOS_Ry', 'LOS_Rz', 'Vc', 'Tgo', 'Gx', 'Gy', 'Gz'};
            
            fid = fopen(filename, 'w');
            fprintf(fid, '%s,', header{1:end-1});
            fprintf(fid, '%s\n', header{end});
            fclose(fid);
            
            dlmwrite(filename, csv_data, '-append', 'precision', '%.6f');
        end
        
        function data = load(obj, filename, format)
            if nargin < 3
                [~, ~, ext] = fileparts(filename);
                format = ext(2:end);
            end
            
            switch format
                case 'mat'
                    loaded_data = load(filename);
                    data = loaded_data.data;
                case 'csv'
                    data = obj.load_csv(filename);
                otherwise
                    error('Unsupported format: %s', format);
            end
        end
        
        function data = load_csv(obj, filename)
            raw_data = csvread(filename, 1, 0);
            
            data.time = raw_data(:, 1);
            data.missile_position = raw_data(:, 2:4)';
            data.missile_velocity = raw_data(:, 5:7)';
            data.missile_acceleration = raw_data(:, 8:10)';
            data.target_position = raw_data(:, 11:13)';
            data.target_velocity = raw_data(:, 14:16)';
            data.target_acceleration = raw_data(:, 17:19)';
            data.relative_distance = raw_data(:, 20);
            data.los_rate = raw_data(:, 21:23)';
            data.closing_velocity = raw_data(:, 24);
            data.time_to_go = raw_data(:, 25);
            data.guidance_cmd = raw_data(:, 26:28)';
        end
        
        function n = get_num_points(obj)
            n = length(obj.time_history);
        end
    end
end
