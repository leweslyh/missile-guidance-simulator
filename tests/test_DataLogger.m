function test_DataLogger()
    addpath('..');
    addpath('../models');
    addpath('../guidance');
    addpath('../simulation');
    addpath('../utils');
    
    fprintf('========================================\n');
    fprintf('  测试数据记录模块\n');
    fprintf('========================================\n\n');
    
    fprintf('测试1: 初始化测试\n');
    logger = DataLogger();
    
    assert(isempty(logger.time_history), '时间历史不为空');
    assert(isempty(logger.missile_position_history), '导弹位置历史不为空');
    assert(isempty(logger.target_position_history), '目标位置历史不为空');
    fprintf('  通过\n\n');
    
    fprintf('测试2: 数据记录测试\n');
    logger = DataLogger();
    
    time = 0.0;
    missile_state.position = [0; 0; 0];
    missile_state.velocity = [300; 0; 0];
    missile_state.acceleration = [50; 0; 0];
    
    target_state.position = [5000; 3000; 1000];
    target_state.velocity = [-200; 0; 0];
    target_state.acceleration = [0; 0; 0];
    
    relative_motion.relative_distance = 6000;
    relative_motion.los_rate = [0; 0; 0.01];
    relative_motion.closing_velocity = 500;
    relative_motion.time_to_go = 12.0;
    
    guidance_cmd = [100; 50; 0];
    
    logger.log(time, missile_state, target_state, relative_motion, guidance_cmd);
    
    assert(length(logger.time_history) == 1, '时间记录失败');
    assert(logger.time_history(1) == time, '时间值错误');
    fprintf('  通过\n\n');
    
    fprintf('测试3: 多点记录测试\n');
    logger = DataLogger();
    
    for i = 1:10
        time = i * 0.1;
        missile_state.position = [i*10; 0; 0];
        target_state.position = [5000+i*5; 3000; 1000];
        relative_motion.relative_distance = 6000 - i*5;
        
        logger.log(time, missile_state, target_state, relative_motion, guidance_cmd);
    end
    
    assert(logger.get_num_points() == 10, '多点记录失败');
    fprintf('  通过\n\n');
    
    fprintf('测试4: 数据获取测试\n');
    logger = DataLogger();
    
    time = 1.0;
    missile_state.position = [100; 200; 300];
    missile_state.velocity = [300; 400; 500];
    missile_state.acceleration = [50; 60; 70];
    
    target_state.position = [5000; 3000; 1000];
    target_state.velocity = [-200; 0; 0];
    target_state.acceleration = [0; 0; 0];
    
    relative_motion.relative_distance = 6000;
    relative_motion.los_rate = [0; 0; 0.01];
    relative_motion.closing_velocity = 500;
    relative_motion.time_to_go = 12.0;
    
    guidance_cmd = [100; 50; 0];
    
    logger.log(time, missile_state, target_state, relative_motion, guidance_cmd);
    data = logger.get_all_data();
    
    assert(isfield(data, 'time'), '数据缺少时间字段');
    assert(isfield(data, 'missile_position'), '数据缺少导弹位置字段');
    assert(isfield(data, 'target_position'), '数据缺少目标位置字段');
    assert(isequal(data.missile_position(:,1), missile_state.position), '导弹位置数据错误');
    fprintf('  通过\n\n');
    
    fprintf('测试5: 清空测试\n');
    logger = DataLogger();
    
    for i = 1:10
        logger.log(i*0.1, missile_state, target_state, relative_motion, guidance_cmd);
    end
    
    assert(logger.get_num_points() == 10, '记录失败');
    
    logger.clear();
    assert(logger.get_num_points() == 0, '清空失败');
    fprintf('  通过\n\n');
    
    fprintf('测试6: MAT文件保存测试\n');
    logger = DataLogger();
    
    for i = 1:10
        time = i * 0.1;
        missile_state.position = [i*10; 0; 0];
        target_state.position = [5000+i*5; 3000; 1000];
        relative_motion.relative_distance = 6000 - i*5;
        
        logger.log(time, missile_state, target_state, relative_motion, guidance_cmd);
    end
    
    test_file = 'test_data.mat';
    logger.save(test_file, 'mat');
    
    assert(exist(test_file, 'file') == 2, 'MAT文件保存失败');
    
    loaded_logger = DataLogger();
    loaded_data = loaded_logger.load(test_file, 'mat');
    
    assert(length(loaded_data.time) == 10, '加载数据点数错误');
    assert(isequal(loaded_data.time, logger.time_history), '加载时间数据错误');
    
    delete(test_file);
    fprintf('  通过\n\n');
    
    fprintf('测试7: CSV文件保存测试\n');
    logger = DataLogger();
    
    for i = 1:5
        time = i * 0.1;
        missile_state.position = [i*10; 0; 0];
        target_state.position = [5000+i*5; 3000; 1000];
        relative_motion.relative_distance = 6000 - i*5;
        
        logger.log(time, missile_state, target_state, relative_motion, guidance_cmd);
    end
    
    test_file = 'test_data.csv';
    logger.save(test_file, 'csv');
    
    assert(exist(test_file, 'file') == 2, 'CSV文件保存失败');
    
    loaded_logger = DataLogger();
    loaded_data = loaded_logger.load(test_file, 'csv');
    
    assert(length(loaded_data.time) == 5, '加载数据点数错误');
    assert(max(abs(loaded_data.time - logger.time_history)) < 1e-4, '加载时间数据错误');
    
    delete(test_file);
    fprintf('  通过\n\n');
    
    fprintf('测试8: 大数据量测试\n');
    logger = DataLogger(10000);
    
    for i = 1:1000
        time = i * 0.01;
        missile_state.position = [i; 0; 0];
        target_state.position = [5000+i; 3000; 1000];
        relative_motion.relative_distance = 6000 - i;
        
        logger.log(time, missile_state, target_state, relative_motion, guidance_cmd);
    end
    
    assert(logger.get_num_points() == 1000, '大数据量记录失败');
    fprintf('  通过\n\n');
    
    fprintf('测试9: 相对距离记录测试\n');
    logger = DataLogger();
    
    for i = 1:5
        time = i * 0.1;
        relative_motion.relative_distance = 6000 - i * 100;
        logger.log(time, missile_state, target_state, relative_motion, guidance_cmd);
    end
    
    data = logger.get_all_data();
    assert(length(data.relative_distance) == 5, '相对距离记录失败');
    assert(data.relative_distance(1) == 6000, '相对距离值错误');
    fprintf('  通过\n\n');
    
    fprintf('========================================\n');
    fprintf('  所有测试通过!\n');
    fprintf('========================================\n');
end
