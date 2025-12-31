classdef Analyzer
    methods (Static)
        function metrics = calculate_metrics(data, results)
            metrics.miss_distance = results.miss_distance;
            metrics.interception_time = results.time;
            metrics.termination_reason = results.termination_reason;
            
            if isfield(data, 'missile_acceleration')
                accel_norm = sqrt(sum(data.missile_acceleration.^2, 1));
                metrics.max_acceleration = max(accel_norm);
                metrics.mean_acceleration = mean(accel_norm);
                metrics.rms_acceleration = sqrt(mean(accel_norm.^2));
                metrics.energy_consumption = sum(accel_norm) * (data.time(2) - data.time(1));
            else
                metrics.max_acceleration = 0;
                metrics.mean_acceleration = 0;
                metrics.rms_acceleration = 0;
                metrics.energy_consumption = 0;
            end
            
            if isfield(data, 'guidance_cmd')
                cmd_norm = sqrt(sum(data.guidance_cmd.^2, 1));
                metrics.max_guidance_cmd = max(cmd_norm);
                metrics.mean_guidance_cmd = mean(cmd_norm);
            else
                metrics.max_guidance_cmd = 0;
                metrics.mean_guidance_cmd = 0;
            end
            
            if isfield(data, 'los_rate')
                los_rate_norm = sqrt(sum(data.los_rate.^2, 1));
                metrics.max_los_rate = max(los_rate_norm);
                metrics.mean_los_rate = mean(los_rate_norm);
            else
                metrics.max_los_rate = 0;
                metrics.mean_los_rate = 0;
            end
            
            if isfield(data, 'relative_distance')
                metrics.initial_distance = data.relative_distance(1);
                metrics.final_distance = data.relative_distance(end);
                metrics.min_distance = min(data.relative_distance);
            else
                metrics.initial_distance = 0;
                metrics.final_distance = 0;
                metrics.min_distance = 0;
            end
            
            if isfield(data, 'closing_velocity')
                metrics.initial_closing_velocity = data.closing_velocity(1);
                metrics.final_closing_velocity = data.closing_velocity(end);
                metrics.mean_closing_velocity = mean(data.closing_velocity);
            else
                metrics.initial_closing_velocity = 0;
                metrics.final_closing_velocity = 0;
                metrics.mean_closing_velocity = 0;
            end
            
            if isfield(data, 'missile_velocity')
                missile_speed = sqrt(sum(data.missile_velocity.^2, 1));
                metrics.initial_missile_speed = missile_speed(1);
                metrics.final_missile_speed = missile_speed(end);
            else
                metrics.initial_missile_speed = 0;
                metrics.final_missile_speed = 0;
            end
            
            metrics.success = strcmp(results.termination_reason, 'intercepted');
        end
        
        function report = generate_report(metrics)
            report = sprintf('=== 仿真结果报告 ===\n\n');
            report = [report, sprintf('拦截状态: %s\n', Analyzer.bool_to_string(metrics.success))];
            report = [report, sprintf('终止原因: %s\n', metrics.termination_reason)];
            report = [report, sprintf('\n--- 脱靶量 ---\n')];
            report = [report, sprintf('最终脱靶量: %.4f m\n', metrics.miss_distance)];
            report = [report, sprintf('最小距离: %.4f m\n', metrics.min_distance)];
            report = [report, sprintf('\n--- 时间 ---\n')];
            report = [report, sprintf('拦截时间: %.4f s\n', metrics.interception_time)];
            report = [report, sprintf('\n--- 加速度 ---\n')];
            report = [report, sprintf('最大加速度: %.4f m/s²\n', metrics.max_acceleration)];
            report = [report, sprintf('平均加速度: %.4f m/s²\n', metrics.mean_acceleration)];
            report = [report, sprintf('RMS加速度: %.4f m/s²\n', metrics.rms_acceleration)];
            report = [report, sprintf('能量消耗: %.4f m/s\n', metrics.energy_consumption)];
            report = [report, sprintf('\n--- 制导指令 ---\n')];
            report = [report, sprintf('最大指令: %.4f m/s²\n', metrics.max_guidance_cmd)];
            report = [report, sprintf('平均指令: %.4f m/s²\n', metrics.mean_guidance_cmd)];
            report = [report, sprintf('\n--- 视线角速率 ---\n')];
            report = [report, sprintf('最大视线角速率: %.4f rad/s\n', metrics.max_los_rate)];
            report = [report, sprintf('平均视线角速率: %.4f rad/s\n', metrics.mean_los_rate)];
            report = [report, sprintf('\n--- 相对运动 ---\n')];
            report = [report, sprintf('初始距离: %.4f m\n', metrics.initial_distance)];
            report = [report, sprintf('最终距离: %.4f m\n', metrics.final_distance)];
            report = [report, sprintf('初始接近速度: %.4f m/s\n', metrics.initial_closing_velocity)];
            report = [report, sprintf('最终接近速度: %.4f m/s\n', metrics.final_closing_velocity)];
            report = [report, sprintf('平均接近速度: %.4f m/s\n', metrics.mean_closing_velocity)];
        end
        
        function str = bool_to_string(bool_val)
            if bool_val
                str = '成功';
            else
                str = '失败';
            end
        end
        
        function comparison = compare_guidance_laws(metrics_list, law_names)
            n_laws = length(metrics_list);
            
            comparison.law_names = law_names;
            comparison.miss_distance = zeros(n_laws, 1);
            comparison.interception_time = zeros(n_laws, 1);
            comparison.max_acceleration = zeros(n_laws, 1);
            comparison.energy_consumption = zeros(n_laws, 1);
            comparison.success = false(n_laws, 1);
            
            for i = 1:n_laws
                comparison.miss_distance(i) = metrics_list{i}.miss_distance;
                comparison.interception_time(i) = metrics_list{i}.interception_time;
                comparison.max_acceleration(i) = metrics_list{i}.max_acceleration;
                comparison.energy_consumption(i) = metrics_list{i}.energy_consumption;
                comparison.success(i) = metrics_list{i}.success;
            end
            
            comparison.best_miss_distance = comparison.law_names{find(comparison.miss_distance == min(comparison.miss_distance(comparison.success)), 1)};
            comparison.best_time = comparison.law_names{find(comparison.interception_time == min(comparison.interception_time(comparison.success)), 1)};
            comparison.best_energy = comparison.law_names{find(comparison.energy_consumption == min(comparison.energy_consumption(comparison.success)), 1)};
        end
        
        function sensitivity = parameter_sensitivity(base_params, param_names, param_values, simulation_func)
            n_params = length(param_names);
            
            sensitivity.param_names = param_names;
            sensitivity.param_values = param_values;
            sensitivity.miss_distance = cell(n_params, 1);
            sensitivity.interception_time = cell(n_params, 1);
            
            for i = 1:n_params
                n_values = length(param_values{i});
                sensitivity.miss_distance{i} = zeros(n_values, 1);
                sensitivity.interception_time{i} = zeros(n_values, 1);
                
                for j = 1:n_values
                    test_params = base_params;
                    test_params.(param_names{i}) = param_values{i}(j);
                    
                    [data, results] = simulation_func(test_params);
                    metrics = Analyzer.calculate_metrics(data, results);
                    
                    sensitivity.miss_distance{i}(j) = metrics.miss_distance;
                    sensitivity.interception_time{i}(j) = metrics.interception_time;
                end
            end
        end
        
        function plot_sensitivity(sensitivity, results_dir)
            n_params = length(sensitivity.param_names);
            
            for i = 1:n_params
                figure;
                subplot(2, 1, 1);
                plot(sensitivity.param_values{i}, sensitivity.miss_distance{i}, 'b-o', 'LineWidth', 2);
                xlabel(sprintf('%s', sensitivity.param_names{i}));
                ylabel('脱靶量 (m)');
                title(sprintf('脱靶量 vs %s', sensitivity.param_names{i}));
                grid on;
                
                subplot(2, 1, 2);
                plot(sensitivity.param_values{i}, sensitivity.interception_time{i}, 'r-s', 'LineWidth', 2);
                xlabel(sprintf('%s', sensitivity.param_names{i}));
                ylabel('拦截时间 (s)');
                title(sprintf('拦截时间 vs %s', sensitivity.param_names{i}));
                grid on;
                
                if nargin >= 2
                    filename = fullfile(results_dir, sprintf('sensitivity_%s.png', sensitivity.param_names{i}));
                    saveas(gcf, filename);
                end
            end
        end
    end
end
