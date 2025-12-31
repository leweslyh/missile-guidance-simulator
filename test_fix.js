// 简单测试脚本，验证修复是否有效
import SimulationEnv from './src/core/simulation/SimulationEnv.js';
import MissileModel from './src/core/models/MissileModel.js';
import TargetModel from './src/core/models/TargetModel.js';
import GuidanceLaw from './src/core/guidance/GuidanceLaw.js';

console.log('Starting test...');

try {
  // 创建模型实例
  const missile = new MissileModel({
    position: [0, 0, 0],
    velocity: [300, 0, 0],
    maxAcceleration: 200
  });

  const target = new TargetModel({
    position: [5000, 3000, 1000],
    velocity: [-200, 0, 0],
    motionType: 'constant'
  });

  const guidanceLaw = new GuidanceLaw({
    lawType: 'PN',
    params: { N: 3 }
  });

  // 创建仿真环境
  const simEnv = new SimulationEnv(missile, target, guidanceLaw, {
    dt: 0.01,
    maxTime: 10
  });

  console.log('Models created successfully');

  // 运行仿真
  const result = simEnv.run();
  
  console.log('Simulation completed successfully!');
  console.log('Result:', result);
  console.log('\n✅ Fix verified: The simulation runs without the TypeError');

} catch (error) {
  console.error('❌ Test failed with error:', error);
  process.exit(1);
}
