// 制导律模块
import VectorUtils from '../utils/VectorUtils.js';
import configManager from '../config/ConfigManager.js';

class GuidanceLaw {
  constructor(params) {
    this.lawType = params.lawType || 'PN';
    this.params = params.params || {};
    this.customCode = params.customCode || '';
    this.customFunction = null;
    
    // 编译自定义制导律代码
    if (this.lawType === 'custom' && this.customCode) {
      this.compileCustomLaw();
    }
  }

  // 计算视线速率
  calculateLOSRate(relativePosition, relativeVelocity) {
    const r = VectorUtils.norm(relativePosition);
    if (r < 1e-6) return [0, 0, 0];
    
    // 视线速率 = cross(relativePosition, relativeVelocity) / r² （注意叉积顺序）
    const losRate = VectorUtils.cross(relativePosition, relativeVelocity);
    const rSquared = r * r;
    return losRate.map(val => val / rSquared);
  }

  // 计算接近速度
  calculateClosingVelocity(relativePosition, relativeVelocity) {
    const rHat = VectorUtils.normalize(relativePosition);
    return -VectorUtils.dot(relativeVelocity, rHat);
  }

  // 计算PN制导律（含物理补偿）
  calculatePN(missileState, targetState, relativeMotion) {
    const N = this.params.N || 3.0;
    const losRate = relativeMotion.losRate;
    const closingVelocity = relativeMotion.closingVelocity;
    const losVector = relativeMotion.losVector;
    
    if (closingVelocity < 1e-6) {
      return [0, 0, 0];
    }
    
    // 正确的PN制导律：加速度垂直于视线
    // accelCmd = N * Vc * cross(losRate, losVector)
    const baseCmd = VectorUtils.cross(losRate, losVector);
    let accelCmd = baseCmd.map(val => val * N * closingVelocity);
    
    // 添加重力补偿
    // 从配置管理器获取重力参数
    const gravity = configManager.getPhysicalParam('gravity');
    
    // 计算重力在垂直于视线方向的分量
    // 重力补偿 = -重力在垂直于视线方向的投影
    const gravityAlongLOS = VectorUtils.dot(gravity, losVector);
    const gravityNormal = gravity.map((val, i) => val - gravityAlongLOS * losVector[i]);
    
    // 添加重力补偿到制导指令
    accelCmd = accelCmd.map((val, i) => val - gravityNormal[i]);
    
    // 添加大气阻力补偿
    // 阻力加速度 = -0.5 * ρ * Cd * S * v² / m * v方向
    const altitude = missileState.position[1]; // 假设y轴为高度
    const airDensity = configManager.calculateAirDensity(altitude);
    const missileSpeed = VectorUtils.norm(missileState.velocity);
    const velocityDir = VectorUtils.normalize(missileState.velocity);
    
    // 从配置管理器获取导弹默认参数
    const missileDefaults = configManager.getMissileDefaultParams();
    const dragCoefficient = missileDefaults.dragCoefficient;
    const referenceArea = missileDefaults.referenceArea;
    const missileMass = missileDefaults.mass;
    
    // 计算阻力加速度
    const dragForce = 0.5 * airDensity * dragCoefficient * referenceArea * missileSpeed * missileSpeed;
    const dragAccel = VectorUtils.multiply(velocityDir, -dragForce / missileMass);
    
    // 添加阻力补偿
    accelCmd = accelCmd.map((val, i) => val - dragAccel[i]);
    
    return accelCmd;
  }

  // 计算PP制导律
  calculatePP(missileState, targetState, relativeMotion) {
    const missileSpeed = missileState.speed;
    const losVector = relativeMotion.losVector;
    
    // 纯追踪制导律：速度方向指向目标
    const desiredVelocity = losVector.map(val => val * missileSpeed);
    
    // 简化的加速度指令计算
    const accelCmd = desiredVelocity.map((v, i) => (v - missileState.velocity[i]) / 0.1);
    
    return accelCmd;
  }

  // 计算APN制导律（含物理补偿）
  calculateAPN(missileState, targetState, relativeMotion) {
    const N = this.params.N || 3.0;
    const losRate = relativeMotion.losRate;
    const closingVelocity = relativeMotion.closingVelocity;
    const losVector = relativeMotion.losVector;
    
    if (closingVelocity < 1e-6) {
      return [0, 0, 0];
    }
    
    // 基础PN指令
    const baseCmd = VectorUtils.cross(losRate, losVector);
    let accelCmd = baseCmd.map(val => val * N * closingVelocity);
    
    // 目标加速度补偿
    const targetAccel = targetState.acceleration;
    const targetAccelNormal = targetAccel.map((val, i) => 
      val - VectorUtils.dot(targetAccel, losVector) * losVector[i]
    );
    const targetCompensation = targetAccelNormal.map(val => val * (N / 2));
    
    // 总指令
    accelCmd = accelCmd.map((val, i) => val + targetCompensation[i]);
    
    // 添加重力补偿
    // 从配置管理器获取重力参数
    const gravity = configManager.getPhysicalParam('gravity');
    
    // 计算重力在垂直于视线方向的分量
    // 重力补偿 = -重力在垂直于视线方向的投影
    const gravityAlongLOS = VectorUtils.dot(gravity, losVector);
    const gravityNormal = gravity.map((val, i) => val - gravityAlongLOS * losVector[i]);
    
    // 添加重力补偿到制导指令
    accelCmd = accelCmd.map((val, i) => val - gravityNormal[i]);
    
    // 添加大气阻力补偿
    // 阻力加速度 = -0.5 * ρ * Cd * S * v² / m * v方向
    const altitude = missileState.position[1]; // 假设y轴为高度
    const airDensity = configManager.calculateAirDensity(altitude);
    const missileSpeed = VectorUtils.norm(missileState.velocity);
    const velocityDir = VectorUtils.normalize(missileState.velocity);
    
    // 从配置管理器获取导弹默认参数
    const missileDefaults = configManager.getMissileDefaultParams();
    const dragCoefficient = missileDefaults.dragCoefficient;
    const referenceArea = missileDefaults.referenceArea;
    const missileMass = missileDefaults.mass;
    
    // 计算阻力加速度
    const dragForce = 0.5 * airDensity * dragCoefficient * referenceArea * missileSpeed * missileSpeed;
    const dragAccel = VectorUtils.multiply(velocityDir, -dragForce / missileMass);
    
    // 添加阻力补偿
    accelCmd = accelCmd.map((val, i) => val - dragAccel[i]);
    
    return accelCmd;
  }

  // 计算OGL制导律（含物理补偿）
  calculateOGL(missileState, targetState, relativeMotion) {
    const N = this.params.N || 3.0;
    const losRate = relativeMotion.losRate;
    const closingVelocity = relativeMotion.closingVelocity;
    const losVector = relativeMotion.losVector;
    const timeToGo = relativeMotion.timeToGo;
    
    if (closingVelocity < 1e-6 || timeToGo < 1e-6) {
      return [0, 0, 0];
    }
    
    // 基础PN指令
    const baseCmd = VectorUtils.cross(losRate, losVector);
    let accelCmd = baseCmd.map(val => val * N * closingVelocity);
    
    // 目标加速度补偿（考虑时间到拦截）
    const targetAccel = targetState.acceleration;
    const targetAccelNormal = targetAccel.map((val, i) => 
      val - VectorUtils.dot(targetAccel, losVector) * losVector[i]
    );
    
    const compensationFactor = 1 - 2 / (N * timeToGo * closingVelocity);
    const targetCompensation = targetAccelNormal.map(val => 
      val * (N / 2) * compensationFactor
    );
    
    // 总指令
    accelCmd = accelCmd.map((val, i) => val + targetCompensation[i]);
    
    // 添加重力补偿
    // 从配置管理器获取重力参数
    const gravity = configManager.getPhysicalParam('gravity');
    
    // 计算重力在垂直于视线方向的分量
    // 重力补偿 = -重力在垂直于视线方向的投影
    const gravityAlongLOS = VectorUtils.dot(gravity, losVector);
    const gravityNormal = gravity.map((val, i) => val - gravityAlongLOS * losVector[i]);
    
    // 添加重力补偿到制导指令
    accelCmd = accelCmd.map((val, i) => val - gravityNormal[i]);
    
    // 添加大气阻力补偿
    // 阻力加速度 = -0.5 * ρ * Cd * S * v² / m * v方向
    const altitude = missileState.position[1]; // 假设y轴为高度
    const airDensity = configManager.calculateAirDensity(altitude);
    const missileSpeed = VectorUtils.norm(missileState.velocity);
    const velocityDir = VectorUtils.normalize(missileState.velocity);
    
    // 从配置管理器获取导弹默认参数
    const missileDefaults = configManager.getMissileDefaultParams();
    const dragCoefficient = missileDefaults.dragCoefficient;
    const referenceArea = missileDefaults.referenceArea;
    const missileMass = missileDefaults.mass;
    
    // 计算阻力加速度
    const dragForce = 0.5 * airDensity * dragCoefficient * referenceArea * missileSpeed * missileSpeed;
    const dragAccel = VectorUtils.multiply(velocityDir, -dragForce / missileMass);
    
    // 添加阻力补偿
    accelCmd = accelCmd.map((val, i) => val - dragAccel[i]);
    
    return accelCmd;
  }

  // 计算制导指令
  calculate(missileState, targetState, relativeMotion) {
    // 如果没有提供相对运动信息，则自己计算
    let computedRelativeMotion = relativeMotion;
    if (!computedRelativeMotion) {
      const relativePosition = targetState.position.map((val, i) => val - missileState.position[i]);
      const relativeVelocity = targetState.velocity.map((val, i) => val - missileState.velocity[i]);
      
      computedRelativeMotion = {
        relativePosition,
        relativeVelocity,
        losVector: VectorUtils.normalize(relativePosition),
        losRate: this.calculateLOSRate(relativePosition, relativeVelocity),
        closingVelocity: this.calculateClosingVelocity(relativePosition, relativeVelocity),
        timeToGo: this.calculateTimeToGo(relativePosition, relativeVelocity)
      };
    }
    
    // 根据制导律类型计算指令
    let accelCmd;
    switch (this.lawType) {
      case 'PN':
        accelCmd = this.calculatePN(missileState, targetState, computedRelativeMotion);
        break;
      case 'PP':
        accelCmd = this.calculatePP(missileState, targetState, computedRelativeMotion);
        break;
      case 'APN':
        accelCmd = this.calculateAPN(missileState, targetState, computedRelativeMotion);
        break;
      case 'OGL':
        accelCmd = this.calculateOGL(missileState, targetState, computedRelativeMotion);
        break;
      case 'custom':
        accelCmd = this.calculateCustom(missileState, targetState, computedRelativeMotion);
        break;
      default:
        accelCmd = this.calculatePN(missileState, targetState, computedRelativeMotion);
    }
    
    return accelCmd;
  }

  // 计算自定义制导律
  calculateCustom(missileState, targetState, relativeMotion) {
    try {
      // 准备简化的变量，让使用者更容易编写代码
      const N = this.params.N || 3.0;
      const r = relativeMotion.relativeDistance || VectorUtils.norm(relativeMotion.relativePosition);
      const Vc = relativeMotion.closingVelocity;
      const losRate = relativeMotion.losRate;
      const losVector = relativeMotion.losVector;
      const relativePos = relativeMotion.relativePosition;
      const relativeVel = relativeMotion.relativeVelocity;
      
      // 如果自定义函数未编译或代码已更新，重新编译
      if (!this.customFunction && this.customCode) {
        const compileResult = this.compileCustomLaw();
        if (!compileResult.success) {
          console.error('自定义制导律编译失败:', compileResult.error);
          return [0, 0, 0];
        }
      }
      
      // 执行自定义制导律
      if (this.customFunction) {
        // 传递简化的变量和原始变量
        const accelCmd = this.customFunction(
          missileState, 
          targetState, 
          relativeMotion, 
          this.params,
          // 简化的变量
          N, r, Vc, losRate, losVector, relativePos, relativeVel
        );
        
        // 验证返回值是否为有效的加速度数组
        if (Array.isArray(accelCmd) && accelCmd.length === 3 && 
            accelCmd.every(val => typeof val === 'number' && !isNaN(val))) {
          return accelCmd;
        } else {
          console.error('自定义制导律返回值无效，必须返回长度为3的数字数组');
          return [0, 0, 0];
        }
      }
    } catch (error) {
      console.error('自定义制导律执行错误:', error);
    }
    
    // 默认返回零加速度
    return [0, 0, 0];
  }

  // 编译自定义制导律代码（增强安全性和易用性）
  compileCustomLaw() {
    try {
      // 1. 代码安全验证
      const forbiddenKeywords = ['eval', 'Function', 'setTimeout', 'setInterval', 'document', 'window', 'global', 'process', 'require', 'import'];
      const lowerCode = this.customCode.toLowerCase();
      
      for (const keyword of forbiddenKeywords) {
        if (lowerCode.includes(keyword)) {
          throw new Error(`禁用的关键字: ${keyword}`);
        }
      }
      
      // 2. 自动为用户代码添加必要的模板和安全沙箱
      const code = `
        (function() {
          // 安全沙箱：限制可用的全局对象
          const safeMath = {
            abs: Math.abs,
            acos: Math.acos,
            asin: Math.asin,
            atan: Math.atan,
            atan2: Math.atan2,
            ceil: Math.ceil,
            cos: Math.cos,
            exp: Math.exp,
            floor: Math.floor,
            log: Math.log,
            log10: Math.log10,
            max: Math.max,
            min: Math.min,
            pow: Math.pow,
            random: Math.random,
            round: Math.round,
            sin: Math.sin,
            sqrt: Math.sqrt,
            tan: Math.tan,
            PI: Math.PI,
            E: Math.E
          };
          
          // 辅助函数
          function norm(vec) {
            return Math.sqrt(vec.reduce((sum, v) => sum + v*v, 0));
          }
          
          function dot(v1, v2) {
            return v1.reduce((sum, v, i) => sum + v * v2[i], 0);
          }
          
          function cross(v1, v2) {
            return [
              v1[1] * v2[2] - v1[2] * v2[1],
              v1[2] * v2[0] - v1[0] * v2[2],
              v1[0] * v2[1] - v1[1] * v2[0]
            ];
          }
          
          function normalize(vec) {
            const magnitude = norm(vec);
            return magnitude > 1e-6 ? vec.map(v => v / magnitude) : [0, 0, 0];
          }
          
          function multiply(vec, scalar) {
            return vec.map(v => v * scalar);
          }
          
          function add(v1, v2) {
            return v1.map((v, i) => v + v2[i]);
          }
          
          function subtract(v1, v2) {
            return v1.map((v, i) => v - v2[i]);
          }
          
          return function(missileState, targetState, relativeMotion, params, N, r, Vc, losRate, losVector, relativePos, relativeVel) {
            // 自动计算常用变量
            const missileSpeed = norm(missileState.velocity);
            const targetSpeed = norm(targetState.velocity);
            const timeToGo = relativeMotion.timeToGo;
            
            // 用户编写的加速度计算逻辑
            ${this.customCode}
          };
        })()
      `;
      
      // 3. 使用Function构造函数编译代码
      this.customFunction = new Function(code)();
      return { success: true };
    } catch (error) {
      console.error('自定义制导律编译错误:', error);
      return { success: false, error: error.message };
    }
  }

  // 计算时间到拦截
  calculateTimeToGo(relativePosition, relativeVelocity) {
    const r = VectorUtils.norm(relativePosition);
    const closingVelocity = this.calculateClosingVelocity(relativePosition, relativeVelocity);
    
    if (closingVelocity < 1e-6) {
      return 1.0;
    }
    
    return r / closingVelocity;
  }
}

export default GuidanceLaw