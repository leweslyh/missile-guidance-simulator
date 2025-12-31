// 仿真环境模块
import VectorUtils from '../utils/VectorUtils.js';

class SimulationEnv {
  constructor(missile, target, guidanceLaw, params) {
    this.missile = missile;
    this.target = target;
    this.guidanceLaw = guidanceLaw;
    
    this.dt = params.dt || 0.01;
    this.maxTime = params.maxTime || 30.0;
    this.missDistanceThreshold = params.missDistanceThreshold || 5.0;
    this.minMissileSpeed = params.minMissileSpeed || 50.0;
    
    this.time = 0;
    this.running = false;
    
    // 存储仿真数据（优化后的数据结构）
    this.data = {
      time: [],
      missile: {
        position: { x: [], y: [], z: [] },
        velocity: { x: [], y: [], z: [] },
        acceleration: { x: [], y: [], z: [] },
        attitude: { x: [], y: [], z: [] },
        speed: []
      },
      target: {
        position: { x: [], y: [], z: [] },
        velocity: { x: [], y: [], z: [] },
        acceleration: { x: [], y: [], z: [] }
      },
      relativeMotion: {
        relativePosition: { x: [], y: [], z: [] },
        relativeVelocity: { x: [], y: [], z: [] },
        losVector: { x: [], y: [], z: [] },
        losRate: { x: [], y: [], z: [] },
        closingVelocity: [],
        timeToGo: [],
        relativeDistance: []
      },
      guidance: {
        accelCmd: { x: [], y: [], z: [] }
      }
    };
    
    this.relativeMotion = {
      relativePosition: [0, 0, 0],
      relativeVelocity: [0, 0, 0],
      losVector: [1, 0, 0],
      losRate: [0, 0, 0],
      closingVelocity: 0,
      timeToGo: 0
    };
  }

  // 更新相对运动信息
    updateRelativeMotion() {
        const missileState = this.missile.getState();
        const targetState = this.target.getState();
        
        // 计算相对位置和速度
        const relativePosition = targetState.position.map((val, i) => val - missileState.position[i]);
        const relativeVelocity = targetState.velocity.map((val, i) => val - missileState.velocity[i]);
        
        // 计算视线向量
        const losVector = VectorUtils.normalize(relativePosition);
        
        // 计算相对距离
        const relativeDistance = VectorUtils.norm(relativePosition);
        
        // 计算视线速率
        // 注意：叉积顺序应该是 relativePosition × relativeVelocity，而不是相反
        const losRate = relativeDistance > 1e-6 ? 
            VectorUtils.cross(relativePosition, relativeVelocity).map(val => val / (relativeDistance * relativeDistance)) : 
            [0, 0, 0];
        
        // 计算接近速度
        const closingVelocity = -VectorUtils.dot(relativeVelocity, losVector);
        
        // 计算时间到拦截（优化版）
        // 使用更精确的时间到拦截估计，考虑目标加速度
        let timeToGo;
        if (closingVelocity > 1e-6) {
            // 获取目标加速度
            const targetState = this.target.getState();
            const targetAccel = targetState.acceleration;
            const targetAccelNorm = VectorUtils.norm(targetAccel);
            
            if (targetAccelNorm < 1e-6) {
                // 目标匀速运动时，使用简单估计
                timeToGo = relativeDistance / closingVelocity;
            } else {
                // 目标加速运动时，使用更精确的估计
                // 考虑目标加速度的影响，近似解
                const a_t = targetAccelNorm;
                const r = relativeDistance;
                const Vc = closingVelocity;
                
                // 简化模型：假设目标加速度垂直于视线
                // tgo = r / Vc + (a_t * r) / (2 * Vc^2)
                timeToGo = (r / Vc) * (1 + (a_t * r) / (2 * Vc * Vc));
            }
        } else {
            timeToGo = this.maxTime;
        }
        
        this.relativeMotion = {
            relativePosition,
            relativeVelocity,
            losVector,
            losRate,
            closingVelocity,
            timeToGo,
            relativeDistance // 添加相对距离属性
        };
    }

  // 检查仿真终止条件
  checkTermination() {
    const missileState = this.missile.getState();
    const relativeDistance = VectorUtils.norm(this.relativeMotion.relativePosition);
    
    // 检查脱靶量
    if (relativeDistance <= this.missDistanceThreshold) {
      return { terminated: true, reason: 'intercepted' };
    }
    
    // 检查最大时间
    if (this.time >= this.maxTime) {
      return { terminated: true, reason: 'timeout' };
    }
    
    // 检查导弹最小速度
    if (missileState.speed < this.minMissileSpeed) {
      return { terminated: true, reason: 'low_speed' };
    }
    
    return { terminated: false };
  }

  // 记录仿真数据
  recordData(guidanceCmd = null) {
    const missileState = this.missile.getState();
    const targetState = this.target.getState();
    const relativeMotion = this.relativeMotion;
    
    // 记录时间
    this.data.time.push(this.time);
    
    // 记录导弹数据
    this.data.missile.position.x.push(missileState.position[0]);
    this.data.missile.position.y.push(missileState.position[1]);
    this.data.missile.position.z.push(missileState.position[2]);
    
    this.data.missile.velocity.x.push(missileState.velocity[0]);
    this.data.missile.velocity.y.push(missileState.velocity[1]);
    this.data.missile.velocity.z.push(missileState.velocity[2]);
    
    this.data.missile.acceleration.x.push(missileState.acceleration[0]);
    this.data.missile.acceleration.y.push(missileState.acceleration[1]);
    this.data.missile.acceleration.z.push(missileState.acceleration[2]);
    
    this.data.missile.attitude.x.push(missileState.attitude[0]);
    this.data.missile.attitude.y.push(missileState.attitude[1]);
    this.data.missile.attitude.z.push(missileState.attitude[2]);
    
    this.data.missile.speed.push(missileState.speed);
    
    // 记录目标数据
    this.data.target.position.x.push(targetState.position[0]);
    this.data.target.position.y.push(targetState.position[1]);
    this.data.target.position.z.push(targetState.position[2]);
    
    this.data.target.velocity.x.push(targetState.velocity[0]);
    this.data.target.velocity.y.push(targetState.velocity[1]);
    this.data.target.velocity.z.push(targetState.velocity[2]);
    
    this.data.target.acceleration.x.push(targetState.acceleration[0]);
    this.data.target.acceleration.y.push(targetState.acceleration[1]);
    this.data.target.acceleration.z.push(targetState.acceleration[2]);
    
    // 记录相对运动数据
    this.data.relativeMotion.relativePosition.x.push(relativeMotion.relativePosition[0]);
    this.data.relativeMotion.relativePosition.y.push(relativeMotion.relativePosition[1]);
    this.data.relativeMotion.relativePosition.z.push(relativeMotion.relativePosition[2]);
    
    this.data.relativeMotion.relativeVelocity.x.push(relativeMotion.relativeVelocity[0]);
    this.data.relativeMotion.relativeVelocity.y.push(relativeMotion.relativeVelocity[1]);
    this.data.relativeMotion.relativeVelocity.z.push(relativeMotion.relativeVelocity[2]);
    
    this.data.relativeMotion.losVector.x.push(relativeMotion.losVector[0]);
    this.data.relativeMotion.losVector.y.push(relativeMotion.losVector[1]);
    this.data.relativeMotion.losVector.z.push(relativeMotion.losVector[2]);
    
    this.data.relativeMotion.losRate.x.push(relativeMotion.losRate[0]);
    this.data.relativeMotion.losRate.y.push(relativeMotion.losRate[1]);
    this.data.relativeMotion.losRate.z.push(relativeMotion.losRate[2]);
    
    this.data.relativeMotion.closingVelocity.push(relativeMotion.closingVelocity);
    this.data.relativeMotion.timeToGo.push(relativeMotion.timeToGo);
    this.data.relativeMotion.relativeDistance.push(relativeMotion.relativeDistance);
    
    // 记录制导指令
    if (guidanceCmd) {
      this.data.guidance.accelCmd.x.push(guidanceCmd[0]);
      this.data.guidance.accelCmd.y.push(guidanceCmd[1]);
      this.data.guidance.accelCmd.z.push(guidanceCmd[2]);
    }
  }

  // 运行仿真（性能优化版）
  run() {
    this.time = 0;
    this.data = {
      time: [],
      missile: {
        position: { x: [], y: [], z: [] },
        velocity: { x: [], y: [], z: [] },
        acceleration: { x: [], y: [], z: [] },
        attitude: { x: [], y: [], z: [] },
        speed: []
      },
      target: {
        position: { x: [], y: [], z: [] },
        velocity: { x: [], y: [], z: [] },
        acceleration: { x: [], y: [], z: [] }
      },
      relativeMotion: {
        relativePosition: { x: [], y: [], z: [] },
        relativeVelocity: { x: [], y: [], z: [] },
        losVector: { x: [], y: [], z: [] },
        losRate: { x: [], y: [], z: [] },
        closingVelocity: [],
        timeToGo: [],
        relativeDistance: []
      },
      guidance: {
        accelCmd: { x: [], y: [], z: [] }
      }
    };
    
    // 初始化相对运动
    this.updateRelativeMotion();
    
    this.running = true;
    
    while (this.running) {
      // 优化：在循环开始时只获取一次状态
      const missileState = this.missile.getState();
      const targetState = this.target.getState();
      
      // 计算制导指令
      const guidanceCmd = this.guidanceLaw.calculate(missileState, targetState, this.relativeMotion);
      
      // 记录当前数据（包含制导指令）
      this.recordData(guidanceCmd);
      
      // 更新导弹和目标状态
      this.missile.update(guidanceCmd, this.dt);
      this.target.update(this.dt);
      
      // 更新时间
      this.time += this.dt;
      
      // 更新相对运动
      this.updateRelativeMotion();
      
      // 检查终止条件
      const termination = this.checkTermination();
      if (termination.terminated) {
        this.running = false;
        // 记录最终状态
        this.recordData();
        
        // 优化：只获取一次最终状态
        const finalMissileState = this.missile.getState();
        const finalTargetState = this.target.getState();
        const finalMissDistance = VectorUtils.norm(this.relativeMotion.relativePosition);
        
        return {
          terminated: true,
          reason: termination.reason,
          time: this.time,
          missDistance: finalMissDistance,
          missileState: finalMissileState,
          targetState: finalTargetState
        };
      }
    }
    
    return {
      terminated: false,
      time: this.time,
      missDistance: VectorUtils.norm(this.relativeMotion.relativePosition)
    };
  }

  // 获取仿真数据
  getData() {
    return this.data;
  }

  // 重置仿真环境
  reset() {
    this.time = 0;
    this.running = false;
    this.data = {
      time: [],
      missile: {
        position: { x: [], y: [], z: [] },
        velocity: { x: [], y: [], z: [] },
        acceleration: { x: [], y: [], z: [] },
        attitude: { x: [], y: [], z: [] },
        speed: []
      },
      target: {
        position: { x: [], y: [], z: [] },
        velocity: { x: [], y: [], z: [] },
        acceleration: { x: [], y: [], z: [] }
      },
      relativeMotion: {
        relativePosition: { x: [], y: [], z: [] },
        relativeVelocity: { x: [], y: [], z: [] },
        losVector: { x: [], y: [], z: [] },
        losRate: { x: [], y: [], z: [] },
        closingVelocity: [],
        timeToGo: [],
        relativeDistance: []
      },
      guidance: {
        accelCmd: { x: [], y: [], z: [] }
      }
    };
  }
  
  // 评估制导律性能
  evaluatePerformance() {
    const data = this.data;
    const numDataPoints = data.time.length;
    
    if (numDataPoints === 0) {
      return null;
    }
    
    // 1. 脱靶量 (最终相对距离)
    const missDistance = data.relativeMotion.relativeDistance[numDataPoints - 1] || 0;
    
    // 2. 拦截时间
    const interceptTime = data.time[numDataPoints - 1] || 0;
    
    // 3. 加速度指令统计
    let totalAccelCmd = 0;
    let maxAccelCmd = 0;
    let sumSquaredAccelCmd = 0;
    
    for (let i = 0; i < numDataPoints; i++) {
      const ax = data.guidance.accelCmd.x[i] || 0;
      const ay = data.guidance.accelCmd.y[i] || 0;
      const az = data.guidance.accelCmd.z[i] || 0;
      
      const accelCmdMag = Math.sqrt(ax * ax + ay * ay + az * az);
      
      totalAccelCmd += accelCmdMag;
      maxAccelCmd = Math.max(maxAccelCmd, accelCmdMag);
      sumSquaredAccelCmd += accelCmdMag * accelCmdMag;
    }
    
    const meanAccelCmd = totalAccelCmd / numDataPoints;
    const rmsAccelCmd = Math.sqrt(sumSquaredAccelCmd / numDataPoints);
    
    // 4. 视线角速度统计
    let sumSquaredLOSRate = 0;
    for (let i = 0; i < numDataPoints; i++) {
      const lx = data.relativeMotion.losRate.x[i] || 0;
      const ly = data.relativeMotion.losRate.y[i] || 0;
      const lz = data.relativeMotion.losRate.z[i] || 0;
      
      const losRateMag = Math.sqrt(lx * lx + ly * ly + lz * lz);
      sumSquaredLOSRate += losRateMag * losRateMag;
    }
    
    const rmsLOSRate = Math.sqrt(sumSquaredLOSRate / numDataPoints);
    
    // 5. 能量消耗指标（积分加速度指令平方）
    const energyConsumption = sumSquaredAccelCmd * (numDataPoints > 1 ? data.time[1] - data.time[0] : 0);
    
    // 6. 拦截成功率
    const intercepted = missDistance <= this.missDistanceThreshold;
    
    // 7. 平均接近速度
    let totalClosingVelocity = 0;
    for (let i = 0; i < numDataPoints; i++) {
      totalClosingVelocity += data.relativeMotion.closingVelocity[i] || 0;
    }
    const meanClosingVelocity = totalClosingVelocity / numDataPoints;
    
    return {
      missDistance,
      interceptTime,
      meanAccelCmd,
      maxAccelCmd,
      rmsAccelCmd,
      rmsLOSRate,
      energyConsumption,
      intercepted,
      meanClosingVelocity,
      dataPoints: numDataPoints
    };
  }
}

export default SimulationEnv