// 目标运动学模型
import VectorUtils from '../utils/VectorUtils.js';

class TargetModel {
  constructor(params) {
    this.position = params.position || [5000, 3000, 1000];
    this.velocity = params.velocity || [-200, 0, 0];
    this.acceleration = params.acceleration || [0, 0, 0];
    
    this.motionType = params.motionType || 'constant';
    this.motionParams = params.motionParams || {};
    
    this.time = 0;
    this.previousAccel = [0, 0, 0]; // 用于平滑随机机动
    this.zigzagDirection = 1; // 用于之字形机动
    this.zigzagSwitchTime = 0; // 用于之字形机动
  }

  // 更新目标状态（增强机动模式）
  update(dt) {
    this.time += dt;
    
    // 根据运动类型更新加速度
    switch (this.motionType) {
      case 'constant':
        // 匀速直线运动
        this.acceleration = [0, 0, 0];
        break;
        
      case 'circular':
        // 圆周运动（改进版：绕指定中心点）
        const omega = this.motionParams.omega || 0.1;
        const center = this.motionParams.center || [0, 0, 0];
        
        // 计算相对于中心点的位置
        const relPos = this.position.map((val, i) => val - center[i]);
        const radius = VectorUtils.norm(relPos);
        
        // 圆周运动加速度 = -ω² * 相对位置（指向圆心）
        this.acceleration = relPos.map(val => -omega * omega * val);
        break;
        
      case 'sine':
        // 正弦机动（3D支持）
        const amplitude = this.motionParams.amplitude || 100;
        const frequency = this.motionParams.frequency || 0.5;
        const phase = this.motionParams.phase || 0;
        
        // 在y和z方向生成正弦加速度
        this.acceleration[0] = 0;
        this.acceleration[1] = -amplitude * frequency * frequency * Math.sin(frequency * this.time + phase);
        this.acceleration[2] = -amplitude * frequency * frequency * Math.sin(frequency * this.time + phase + Math.PI/2);
        break;
        
      case 'random':
        // 随机运动（平滑版）
        const maxAccel = this.motionParams.maxAccel || 50;
        const smoothFactor = this.motionParams.smoothFactor || 0.3;
        
        // 生成随机加速度
        const randomAccel = [
          (Math.random() - 0.5) * 2 * maxAccel,
          (Math.random() - 0.5) * 2 * maxAccel,
          (Math.random() - 0.5) * 2 * maxAccel
        ];
        
        // 平滑处理
        this.acceleration = this.acceleration.map((val, i) => 
          val * (1 - smoothFactor) + randomAccel[i] * smoothFactor
        );
        
        this.previousAccel = [...this.acceleration];
        break;
        
      case 'evasive':
        // 智能规避运动
        const evasionFreq = this.motionParams.evasionFreq || 1.0;
        const evasionAmplitude = this.motionParams.evasionAmplitude || 100;
        
        // 生成垂直于速度方向的机动
        const speed = VectorUtils.norm(this.velocity);
        const velocityDir = speed > 0 ? VectorUtils.normalize(this.velocity) : [1, 0, 0];
        
        // 生成垂直于速度方向的单位向量
        const perpendicular1 = [0, velocityDir[2], -velocityDir[1]];
        const perpendicular2 = VectorUtils.cross(velocityDir, perpendicular1);
        
        // 在垂直于速度方向上生成正弦机动
        this.acceleration = VectorUtils.add(
          VectorUtils.multiply(perpendicular1, evasionAmplitude * Math.sin(evasionFreq * this.time)),
          VectorUtils.multiply(perpendicular2, evasionAmplitude * Math.cos(evasionFreq * this.time))
        );
        break;
        
      case 'zigzag':
        // 之字形机动
        const zigzagAmplitude = this.motionParams.zigzagAmplitude || 100;
        const zigzagFreq = this.motionParams.zigzagFreq || 1.0;
        const switchInterval = 1 / zigzagFreq;
        
        // 定期切换方向
        if (this.time >= this.zigzagSwitchTime) {
          this.zigzagDirection *= -1;
          this.zigzagSwitchTime = this.time + switchInterval;
        }
        
        // 生成之字形加速度
        this.acceleration = [
          0,
          this.zigzagDirection * zigzagAmplitude,
          0
        ];
        break;
        
      case 'spiral':
        // 螺旋机动
        const spiralFreq = this.motionParams.spiralFreq || 0.5;
        const spiralAmplitude = this.motionParams.spiralAmplitude || 50;
        const spiralGrowth = this.motionParams.spiralGrowth || 0.1;
        
        // 生成螺旋加速度
        const spiralRadius = spiralGrowth * this.time;
        this.acceleration[0] = -spiralFreq * spiralFreq * spiralRadius * Math.cos(spiralFreq * this.time);
        this.acceleration[1] = -spiralFreq * spiralFreq * spiralRadius * Math.sin(spiralFreq * this.time);
        this.acceleration[2] = spiralAmplitude * Math.sin(spiralFreq * this.time);
        break;
        
      default:
        this.acceleration = [0, 0, 0];
    }
    
    // 更新速度
    this.velocity = this.velocity.map((v, i) => v + this.acceleration[i] * dt);
    
    // 更新位置
    this.position = this.position.map((p, i) => p + this.velocity[i] * dt);
    
    return this;
  }

  // 获取当前状态
  getState() {
    return {
      position: [...this.position],
      velocity: [...this.velocity],
      acceleration: [...this.acceleration]
    };
  }

  // 重置状态
  reset(params) {
    this.position = params.position || [5000, 3000, 1000];
    this.velocity = params.velocity || [-200, 0, 0];
    this.acceleration = params.acceleration || [0, 0, 0];
    this.time = 0;
    this.previousAccel = [0, 0, 0];
    this.zigzagDirection = 1;
    this.zigzagSwitchTime = 0;
    return this;
  }
}

export default TargetModel