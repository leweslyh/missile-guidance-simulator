function test_Analyzer()
    addpath('..');
    addpath('../models');
    addpath('../guidance');
    addpath('../simulation');
    addpath('../utils');
    
    fprintf('========================================\n');
    fprintf('  测试分析模块\n');
    fprintf('========================================\n\n');
    
    fprintf('测试1: 性能指标计算测试\n');
    data.time = linspace(0, 10, 100);
    data.missile_position = [linspace(0, 3000, 100); linspace(0, 1800, 100); linspace(0, 600, 100)];
    data.missile_velocity = [300*ones(1,100); 180*ones(1,100); 60*ones(1,100)];
    data.missile_acceleration = [50*sin(linspace(0, 2*pi, 100)); 50*cos(linspace(0, 2*pi, 100)); zeros(1,100)];
    data.target_position = [5000-200*data.time; 3000*ones(1,100); 1000*ones(1,100)];
    data.target_velocity = [-200*ones(1,100); zeros(1,100); zeros(1,100)];
    data.target_acceleration = zeros(3, 100);
    data.relative_distance = 6000 - 500*data.time;
    data.los_rate = [zeros(1,100); zeros(1,100); 0.01*sin(linspace(0, 2*pi, 100))];
    data.closing_velocity = 500*ones(1,100);
    data.time_to_go = data.relative_distance ./ data.closing_velocity;
    data.guidance_cmd = data.missile_acceleration;
    
    results.time = 10.0;
    results.miss_distance = 1.0;
    results.termination_reason = 'intercepted';
    
    metrics = Analyzer.calculate_metrics(data, results);
    
    assert(isfield(metrics, 'miss_distance'), '缺少脱靶量指标');
    assert(isfield(metrics, 'interception_time'), '缺少拦截时间指标');
    assert(isfield(metrics, 'max_acceleration'), '缺少最大加速度指标');
    assert(isfield(metrics, 'energy_consumption'), '缺少能量消耗指标');
    fprintf('  通过\n\n');
    
    fprintf('测试2: 脱靶量测试\n');
    results.miss_distance = 2.5;
    metrics = Analyzer.calculate_metrics(data, results);
    
    assert(abs(metrics.miss_distance - 2.5) < 1e-6, '脱靶量计算错误');
    fprintf('  通过\n\n');
    
    fprintf('测试3: 拦截时间测试\n');
    results.time = 15.5;
    metrics = Analyzer.calculate_metrics(data, results);
    
    assert(abs(metrics.interception_time - 15.5) < 1e-6, '拦截时间计算错误');
    fprintf('  通过\n\n');
    
    fprintf('测试4: 最大加速度测试\n');
    data.missile_acceleration = [50*sin(linspace(0, 2*pi, 100)); 50*cos(linspace(0, 2*pi, 100)); zeros(1,100)];
    metrics = Analyzer.calculate_metrics(data, results);
    
    assert(abs(metrics.max_acceleration - 50) < 1e-4, '最大加速度计算错误');
    fprintf('  通过\n\n');
    
    fprintf('测试5: 能量消耗测试\n');
    data.missile_acceleration = [50*sin(linspace(0, 2*pi, 100)); 50*cos(linspace(0, 2*pi, 100)); zeros(1,100)];
    metrics = Analyzer.calculate_metrics(data, results);
    
    assert(metrics.energy_consumption > 0, '能量消耗计算错误');
    fprintf('  通过\n\n');
    
    fprintf('测试6: 视线角速率测试\n');
    data.los_rate = [zeros(1,100); zeros(1,100); 0.02*sin(linspace(0, 2*pi, 100))];
    metrics = Analyzer.calculate_metrics(data, results);
    
    assert(metrics.max_los_rate > 0, '最大视线角速率计算错误');
    assert(metrics.mean_los_rate >= 0, '平均视线角速率计算错误');
    fprintf('  通过\n\n');
    
    fprintf('测试7: 相对距离测试\n');
    data.relative_distance = 6000 - 500*data.time;
    metrics = Analyzer.calculate_metrics(data, results);
    
    assert(abs(metrics.initial_distance - 6000) < 1e-4, '初始距离计算错误');
    assert(abs(metrics.final_distance - 1000) < 1e-4, '最终距离计算错误');
    fprintf('  通过\n\n');
    
    fprintf('测试8: 成功标志测试\n');
    results.termination_reason = 'intercepted';
    metrics = Analyzer.calculate_metrics(data, results);
    
    assert(metrics.success == true, '成功标志错误');
    
    results.termination_reason = 'timeout';
    metrics = Analyzer.calculate_metrics(data, results);
    
    assert(metrics.success == false, '失败标志错误');
    fprintf('  通过\n\n');
    
    fprintf('测试9: 报告生成测试\n');
    results.termination_reason = 'intercepted';
    results.miss_distance = 1.0;
    results.time = 10.0;
    metrics = Analyzer.calculate_metrics(data, results);
    
    report = Analyzer.generate_report(metrics);
    
    assert(~isempty(report), '报告为空');
    assert(contains(report, '拦截状态'), '报告缺少拦截状态');
    assert(contains(report, '脱靶量'), '报告缺少脱靶量');
    fprintf('  通过\n\n');
    
    fprintf('测试10: 制导律对比测试\n');
    metrics_list = cell(2, 1);
    metrics_list{1} = metrics;
    
    metrics2 = metrics;
    metrics2.miss_distance = 2.0;
    metrics2.interception_time = 12.0;
    metrics_list{2} = metrics2;
    
    law_names = {'PN', 'APN'};
    comparison = Analyzer.compare_guidance_laws(metrics_list, law_names);
    
    assert(isfield(comparison, 'miss_distance'), '对比结果缺少脱靶量');
    assert(isfield(comparison, 'best_miss_distance'), '对比结果缺少最佳脱靶量');
    fprintf('  通过\n\n');
    
    fprintf('测试11: 布尔转换测试\n');
    str_true = Analyzer.bool_to_string(true);
    str_false = Analyzer.bool_to_string(false);
    
    assert(strcmp(str_true, '成功'), '布尔转换错误(true)');
    assert(strcmp(str_false, '失败'), '布尔转换错误(false)');
    fprintf('  通过\n\n');
    
    fprintf('========================================\n');
    fprintf('  所有测试通过!\n');
    fprintf('========================================\n');
end
