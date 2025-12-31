// 导弹运动学模型
import VectorUtils from '../utils/VectorUtils.js';
import configManager from '../config/ConfigManager.js';

class MissileModel {
  constructor(params) {
    this.position = params.position || [0, 0, 0];
    this.velocity = params.velocity || [300, 0, 0];
    this.acceleration = params.acceleration || [0, 0, 0];
    this.attitude = params.attitude || [1, 0, 0];
    
    this.maxAcceleration = params.maxAcceleration || 200.0;
    this.minVelocity = params.minVelocity || 50.0;
    this.mass = params.mass || 100.0;
    this.thrust = params.thrust || 0.0;
    this.dragCoefficient = params.dragCoefficient || 0.0;
  }

  // 更新导弹状态（增强物理模型）
  update(guidanceCmd, dt) {
    // 获取当前速度大小
    const speed = VectorUtils.norm(this.velocity);
    
    // 计算速度方向
    const velocityDir = speed > 0 ? VectorUtils.normalize(this.velocity) : [1, 0, 0];
    
    // 限制制导指令
    const limitedCmd = VectorUtils.limit(guidanceCmd, this.maxAcceleration);
    
    // 1. 从配置管理器获取物理参数
    const gravity = configManager.getPhysicalParam('gravity');
    
    // 2. 计算大气阻力
    // 获取高度（假设z=0为海平面）
    const altitude = this.position[1]; // 假设y轴为高度
    const airDensity = configManager.calculateAirDensity(altitude);
    // 使用导弹自身参数和配置的默认参考面积
    const referenceArea = this.referenceArea || configManager.getMissileDefaultParams().referenceArea;
    const dragForce = 0.5 * airDensity * this.dragCoefficient * referenceArea * speed * speed;
    const dragAccel = VectorUtils.multiply(velocityDir, -dragForce / this.mass);
    
    // 3. 计算推力加速度
    // 推力加速度 = thrust / m * 速度方向
    const thrustAccel = VectorUtils.multiply(velocityDir, this.thrust / this.mass);
    
    // 4. 总加速度 = 制导指令 + 重力 + 阻力 + 推力
    this.acceleration = limitedCmd;
    
    // 添加重力
    this.acceleration = this.acceleration.map((val, i) => val + gravity[i]);
    
    // 添加阻力
    this.acceleration = this.acceleration.map((val, i) => val + dragAccel[i]);
    
    // 添加推力
    this.acceleration = this.acceleration.map((val, i) => val + thrustAccel[i]);
    
    // 更新速度
    this.velocity = this.velocity.map((v, i) => v + this.acceleration[i] * dt);
    
    // 限制最小速度
    const newSpeed = VectorUtils.norm(this.velocity);
    if (newSpeed < this.minVelocity) {
      this.velocity = VectorUtils.normalize(this.velocity).map(val => val * this.minVelocity);
    }
    
    // 更新位置
    this.position = this.position.map((p, i) => p + this.velocity[i] * dt);
    
    // 更新姿态（指向速度方向）
    this.attitude = VectorUtils.normalize(this.velocity);
    
    return this;
  }

  // 获取当前状态
  getState() {
    return {
      position: [...this.position],
      velocity: [...this.velocity],
      acceleration: [...this.acceleration],
      attitude: [...this.attitude],
      speed: VectorUtils.norm(this.velocity)
    };
  }

  // 重置状态
  reset(params) {
    this.position = params.position || [0, 0, 0];
    this.velocity = params.velocity || [300, 0, 0];
    this.acceleration = params.acceleration || [0, 0, 0];
    this.attitude = params.attitude || [1, 0, 0];
    return this;
  }
}

export default MissileModel