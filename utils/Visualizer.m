classdef Visualizer
    methods (Static)
        function plot_trajectory_3d(data, results_dir, filename)
            if nargin < 3
                filename = 'trajectory_3d.png';
            end
            
            figure;
            plot3(data.missile_position(1,:), data.missile_position(2,:), data.missile_position(3,:), ...
                  'b-', 'LineWidth', 2, 'DisplayName', '导弹');
            hold on;
            plot3(data.target_position(1,:), data.target_position(2,:), data.target_position(3,:), ...
                  'r--', 'LineWidth', 2, 'DisplayName', '目标');
            plot3(data.missile_position(1,1), data.missile_position(2,1), data.missile_position(3,1), ...
                  'bo', 'MarkerSize', 10, 'MarkerFaceColor', 'b', 'DisplayName', '导弹起点');
            plot3(data.target_position(1,1), data.target_position(2,1), data.target_position(3,1), ...
                  'rs', 'MarkerSize', 10, 'MarkerFaceColor', 'r', 'DisplayName', '目标起点');
            plot3(data.missile_position(1,end), data.missile_position(2,end), data.missile_position(3,end), ...
                  'b*', 'MarkerSize', 15, 'DisplayName', '导弹终点');
            plot3(data.target_position(1,end), data.target_position(2,end), data.target_position(3,end), ...
                  'r*', 'MarkerSize', 15, 'DisplayName', '目标终点');
            
            xlabel('X (m)');
            ylabel('Y (m)');
            zlabel('Z (m)');
            title('三维轨迹图');
            legend('Location', 'best');
            grid on;
            axis equal;
            view(3);
            
            if nargin >= 2
                saveas(gcf, fullfile(results_dir, filename));
            end
        end
        
        function plot_trajectory_2d(data, results_dir, filename)
            if nargin < 3
                filename = 'trajectory_2d.png';
            end
            
            figure;
            
            subplot(2, 2, 1);
            plot(data.missile_position(1,:), data.missile_position(2,:), 'b-', 'LineWidth', 2);
            hold on;
            plot(data.target_position(1,:), data.target_position(2,:), 'r--', 'LineWidth', 2);
            plot(data.missile_position(1,1), data.missile_position(2,1), 'bo', 'MarkerSize', 10, 'MarkerFaceColor', 'b');
            plot(data.target_position(1,1), data.target_position(2,1), 'rs', 'MarkerSize', 10, 'MarkerFaceColor', 'r');
            xlabel('X (m)');
            ylabel('Y (m)');
            title('XY平面轨迹');
            legend('导弹', '目标', 'Location', 'best');
            grid on;
            axis equal;
            
            subplot(2, 2, 2);
            plot(data.missile_position(1,:), data.missile_position(3,:), 'b-', 'LineWidth', 2);
            hold on;
            plot(data.target_position(1,:), data.target_position(3,:), 'r--', 'LineWidth', 2);
            plot(data.missile_position(1,1), data.missile_position(3,1), 'bo', 'MarkerSize', 10, 'MarkerFaceColor', 'b');
            plot(data.target_position(1,1), data.target_position(3,1), 'rs', 'MarkerSize', 10, 'MarkerFaceColor', 'r');
            xlabel('X (m)');
            ylabel('Z (m)');
            title('XZ平面轨迹');
            legend('导弹', '目标', 'Location', 'best');
            grid on;
            axis equal;
            
            subplot(2, 2, 3);
            plot(data.missile_position(2,:), data.missile_position(3,:), 'b-', 'LineWidth', 2);
            hold on;
            plot(data.target_position(2,:), data.target_position(3,:), 'r--', 'LineWidth', 2);
            plot(data.missile_position(2,1), data.missile_position(3,1), 'bo', 'MarkerSize', 10, 'MarkerFaceColor', 'b');
            plot(data.target_position(2,1), data.target_position(3,1), 'rs', 'MarkerSize', 10, 'MarkerFaceColor', 'r');
            xlabel('Y (m)');
            ylabel('Z (m)');
            title('YZ平面轨迹');
            legend('导弹', '目标', 'Location', 'best');
            grid on;
            axis equal;
            
            if nargin >= 2
                saveas(gcf, fullfile(results_dir, filename));
            end
        end
        
        function plot_relative_distance(data, results_dir, filename)
            if nargin < 3
                filename = 'relative_distance.png';
            end
            
            figure;
            plot(data.time, data.relative_distance, 'b-', 'LineWidth', 2);
            xlabel('时间 (s)');
            ylabel('相对距离 (m)');
            title('相对距离随时间变化');
            grid on;
            
            if nargin >= 2
                saveas(gcf, fullfile(results_dir, filename));
            end
        end
        
        function plot_los_rate(data, results_dir, filename)
            if nargin < 3
                filename = 'los_rate.png';
            end
            
            los_rate_norm = sqrt(sum(data.los_rate.^2, 1));
            
            figure;
            plot(data.time, los_rate_norm, 'b-', 'LineWidth', 2);
            xlabel('时间 (s)');
            ylabel('视线角速率 (rad/s)');
            title('视线角速率随时间变化');
            grid on;
            
            if nargin >= 2
                saveas(gcf, fullfile(results_dir, filename));
            end
        end
        
        function plot_acceleration(data, results_dir, filename)
            if nargin < 3
                filename = 'acceleration.png';
            end
            
            accel_norm = sqrt(sum(data.missile_acceleration.^2, 1));
            
            figure;
            subplot(2, 1, 1);
            plot(data.time, accel_norm, 'b-', 'LineWidth', 2);
            xlabel('时间 (s)');
            ylabel('加速度幅值 (m/s²)');
            title('导弹加速度幅值');
            grid on;
            
            subplot(2, 1, 2);
            plot(data.time, data.missile_acceleration(1,:), 'r-', 'LineWidth', 1.5);
            hold on;
            plot(data.time, data.missile_acceleration(2,:), 'g-', 'LineWidth', 1.5);
            plot(data.time, data.missile_acceleration(3,:), 'b-', 'LineWidth', 1.5);
            xlabel('时间 (s)');
            ylabel('加速度分量 (m/s²)');
            title('导弹加速度分量');
            legend('a_x', 'a_y', 'a_z', 'Location', 'best');
            grid on;
            
            if nargin >= 2
                saveas(gcf, fullfile(results_dir, filename));
            end
        end
        
        function plot_guidance_cmd(data, results_dir, filename)
            if nargin < 3
                filename = 'guidance_cmd.png';
            end
            
            cmd_norm = sqrt(sum(data.guidance_cmd.^2, 1));
            
            figure;
            subplot(2, 1, 1);
            plot(data.time, cmd_norm, 'b-', 'LineWidth', 2);
            xlabel('时间 (s)');
            ylabel('制导指令幅值 (m/s²)');
            title('制导指令幅值');
            grid on;
            
            subplot(2, 1, 2);
            plot(data.time, data.guidance_cmd(1,:), 'r-', 'LineWidth', 1.5);
            hold on;
            plot(data.time, data.guidance_cmd(2,:), 'g-', 'LineWidth', 1.5);
            plot(data.time, data.guidance_cmd(3,:), 'b-', 'LineWidth', 1.5);
            xlabel('时间 (s)');
            ylabel('制导指令分量 (m/s²)');
            title('制导指令分量');
            legend('g_x', 'g_y', 'g_z', 'Location', 'best');
            grid on;
            
            if nargin >= 2
                saveas(gcf, fullfile(results_dir, filename));
            end
        end
        
        function plot_closing_velocity(data, results_dir, filename)
            if nargin < 3
                filename = 'closing_velocity.png';
            end
            
            figure;
            plot(data.time, data.closing_velocity, 'b-', 'LineWidth', 2);
            xlabel('时间 (s)');
            ylabel('接近速度 (m/s)');
            title('接近速度随时间变化');
            grid on;
            
            if nargin >= 2
                saveas(gcf, fullfile(results_dir, filename));
            end
        end
        
        function plot_all(data, results_dir)
            Visualizer.plot_trajectory_3d(data, results_dir, 'trajectory_3d.png');
            Visualizer.plot_trajectory_2d(data, results_dir, 'trajectory_2d.png');
            Visualizer.plot_relative_distance(data, results_dir, 'relative_distance.png');
            Visualizer.plot_los_rate(data, results_dir, 'los_rate.png');
            Visualizer.plot_acceleration(data, results_dir, 'acceleration.png');
            Visualizer.plot_guidance_cmd(data, results_dir, 'guidance_cmd.png');
            Visualizer.plot_closing_velocity(data, results_dir, 'closing_velocity.png');
        end
        
        function animate_trajectory(data, results_dir, filename)
            if nargin < 3
                filename = 'trajectory_animation.gif';
            end
            
            n_frames = length(data.time);
            skip = max(1, floor(n_frames / 100));
            frames = 1:skip:n_frames;
            
            figure;
            for i = frames
                plot3(data.missile_position(1,1:i), data.missile_position(2,1:i), data.missile_position(3,1:i), ...
                      'b-', 'LineWidth', 2);
                hold on;
                plot3(data.target_position(1,1:i), data.target_position(2,1:i), data.target_position(3,1:i), ...
                      'r--', 'LineWidth', 2);
                plot3(data.missile_position(1,i), data.missile_position(2,i), data.missile_position(3,i), ...
                      'bo', 'MarkerSize', 8, 'MarkerFaceColor', 'b');
                plot3(data.target_position(1,i), data.target_position(2,i), data.target_position(3,i), ...
                      'rs', 'MarkerSize', 8, 'MarkerFaceColor', 'r');
                
                xlabel('X (m)');
                ylabel('Y (m)');
                zlabel('Z (m)');
                title(sprintf('轨迹动画 t=%.2f s', data.time(i)));
                legend('导弹', '目标', 'Location', 'best');
                grid on;
                axis equal;
                view(3);
                
                xlim([min([data.missile_position(1,:), data.target_position(1,:)]), ...
                     max([data.missile_position(1,:), data.target_position(1,:)])]);
                ylim([min([data.missile_position(2,:), data.target_position(2,:)]), ...
                     max([data.missile_position(2,:), data.target_position(2,:)])]);
                zlim([min([data.missile_position(3,:), data.target_position(3,:)]), ...
                     max([data.missile_position(3,:), data.target_position(3,:)])]);
                
                drawnow;
                frame = getframe(gcf);
                im = frame2im(frame);
                [imind, cm] = rgb2ind(im, 256);
                
                if i == frames(1)
                    imwrite(imind, cm, fullfile(results_dir, filename), 'gif', 'Loopcount', inf, 'DelayTime', 0.1);
                else
                    imwrite(imind, cm, fullfile(results_dir, filename), 'gif', 'WriteMode', 'append', 'DelayTime', 0.1);
                end
                
                hold off;
            end
        end
        
        function plot_comparison(metrics_list, law_names, results_dir, filename)
            if nargin < 4
                filename = 'comparison.png';
            end
            
            n_laws = length(metrics_list);
            
            miss_distances = zeros(n_laws, 1);
            interception_times = zeros(n_laws, 1);
            max_accelerations = zeros(n_laws, 1);
            energy_consumptions = zeros(n_laws, 1);
            
            for i = 1:n_laws
                miss_distances(i) = metrics_list{i}.miss_distance;
                interception_times(i) = metrics_list{i}.interception_time;
                max_accelerations(i) = metrics_list{i}.max_acceleration;
                energy_consumptions(i) = metrics_list{i}.energy_consumption;
            end
            
            figure;
            
            subplot(2, 2, 1);
            bar(1:n_laws, miss_distances);
            set(gca, 'XTickLabel', law_names);
            ylabel('脱靶量 (m)');
            title('脱靶量对比');
            grid on;
            
            subplot(2, 2, 2);
            bar(1:n_laws, interception_times);
            set(gca, 'XTickLabel', law_names);
            ylabel('拦截时间 (s)');
            title('拦截时间对比');
            grid on;
            
            subplot(2, 2, 3);
            bar(1:n_laws, max_accelerations);
            set(gca, 'XTickLabel', law_names);
            ylabel('最大加速度 (m/s²)');
            title('最大加速度对比');
            grid on;
            
            subplot(2, 2, 4);
            bar(1:n_laws, energy_consumptions);
            set(gca, 'XTickLabel', law_names);
            ylabel('能量消耗 (m/s)');
            title('能量消耗对比');
            grid on;
            
            if nargin >= 3
                saveas(gcf, fullfile(results_dir, filename));
            end
        end
    end
end
