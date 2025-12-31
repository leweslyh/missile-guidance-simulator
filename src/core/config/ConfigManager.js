// 配置管理系统
class ConfigManager {
  constructor() {
    // 默认物理参数
    this.physicalParams = {
      gravity: [0, -9.81, 0],          // 重力加速度 (m/s²)
      airDensitySeaLevel: 1.225,       // 海平面大气密度 (kg/m³)
      standardPressure: 101325,        // 标准大气压力 (Pa)
      standardTemperature: 288.15,     // 标准大气温度 (K)
      lapseRate: -0.0065,              // 温度递减率 (K/m)
      gasConstant: 287.058,           // 气体常数 (J/(kg·K))
      earthRadius: 6371000,           // 地球半径 (m)
      universalGasConstant: 8.31446261815324 // 通用气体常数 (J/(mol·K))
    };

    // 默认导弹参数
    this.missileDefaultParams = {
      mass: 100,                      // 初始质量 (kg)
      thrust: 5000,                   // 推力 (N)
      dragCoefficient: 0.5,           // 阻力系数
      referenceArea: 0.1,             // 参考面积 (m²)
      fuelMass: 20,                   // 燃料质量 (kg)
      fuelBurnRate: 2,                // 燃料消耗率 (kg/s)
      maxAcceleration: 200,           // 最大加速度 (m/s²)
      minVelocity: 50                 // 最小速度 (m/s)
    };

    // 默认仿真参数
    this.simulationDefaultParams = {
      dt: 0.01,                       // 默认时间步长 (s)
      maxTime: 30,                    // 最大仿真时间 (s)
      missDistanceThreshold: 5,        // 脱靶量阈值 (m)
      minMissileSpeed: 50,            // 导弹最小速度 (m/s)
      adaptiveTimeStep: true,         // 是否使用自适应时间步长
      timeStepTolerance: 0.001,       // 时间步长容差
      maxTimeStep: 0.1,               // 最大时间步长
      minTimeStep: 0.0001             // 最小时间步长
    };

    // 默认目标参数
    this.targetDefaultParams = {
      mass: 500,                      // 目标质量 (kg)
      dragCoefficient: 0.3,           // 目标阻力系数
      maxAcceleration: 100,           // 目标最大加速度 (m/s²)
      motionParams: {
        amplitude: 100,               // 正弦运动振幅
        frequency: 0.5,               // 正弦运动频率
        omega: 0.1,                  // 圆周运动角速度
        spiralGrowth: 0.1            // 螺旋运动增长率
      }
    };

    // 预设场景
    this.presets = {
      basicIntercept: {
        name: '基础拦截场景',
        description: '导弹从原点拦截远处匀速直线运动的目标',
        missile: {
          position: [0, 0, 0],
          velocity: [300, 0, 0],
          maxAcceleration: 200,
          minVelocity: 50
        },
        target: {
          position: [5000, 3000, 1000],
          velocity: [-200, 0, 0],
          motionType: 'constant'
        },
        guidance: {
          lawType: 'PN',
          params: { N: 4 }
        },
        simulation: {
          dt: 0.01,
          maxTime: 30
        }
      },
      evasiveTarget: {
        name: '规避目标场景',
        description: '导弹拦截进行智能规避机动的目标',
        missile: {
          position: [0, 0, 0],
          velocity: [350, 0, 0],
          maxAcceleration: 250,
          minVelocity: 50
        },
        target: {
          position: [6000, 2000, 500],
          velocity: [-150, 50, 0],
          motionType: 'evasive',
          motionParams: {
            evasionFreq: 1.5,
            evasionAmplitude: 150
          }
        },
        guidance: {
          lawType: 'APN',
          params: { N: 5 }
        },
        simulation: {
          dt: 0.005,
          maxTime: 40
        }
      },
      highAltitudeIntercept: {
        name: '高空拦截场景',
        description: '在高空环境下拦截目标，考虑大气密度变化',
        missile: {
          position: [0, 10000, 0],
          velocity: [400, 0, 0],
          maxAcceleration: 300,
          minVelocity: 50
        },
        target: {
          position: [8000, 12000, 2000],
          velocity: [-250, -50, 100],
          motionType: 'sine',
          motionParams: {
            amplitude: 200,
            frequency: 0.8
          }
        },
        guidance: {
          lawType: 'OGL',
          params: { N: 4.5 }
        },
        simulation: {
          dt: 0.005,
          maxTime: 35
        }
      }
    };
  }

  // 获取物理参数
  getPhysicalParam(name) {
    return this.physicalParams[name];
  }

  // 设置物理参数
  setPhysicalParam(name, value) {
    this.physicalParams[name] = value;
  }

  // 获取导弹默认参数
  getMissileDefaultParams() {
    return { ...this.missileDefaultParams };
  }

  // 获取仿真默认参数
  getSimulationDefaultParams() {
    return { ...this.simulationDefaultParams };
  }

  // 获取目标默认参数
  getTargetDefaultParams() {
    return { ...this.targetDefaultParams };
  }

  // 获取预设场景
  getPreset(name) {
    return this.presets[name];
  }

  // 获取所有预设场景
  getAllPresets() {
    return { ...this.presets };
  }

  // 添加预设场景
  addPreset(name, preset) {
    this.presets[name] = preset;
  }

  // 删除预设场景
  removePreset(name) {
    delete this.presets[name];
  }

  // 计算给定高度的大气密度（精确标准大气模型）
  calculateAirDensity(altitude) {
    const { airDensitySeaLevel, standardTemperature, standardPressure, gasConstant } = this.physicalParams;
    
    let temperature, pressure;
    const altitudeKm = altitude / 1000; // 转换为千米
    
    // 标准大气分层模型
    if (altitudeKm < 11) {
      // 对流层（0-11km）：温度随高度线性降低
      const lapseRate = -0.0065; // K/m
      temperature = standardTemperature + lapseRate * altitude;
      const pressureRatio = Math.pow(temperature / standardTemperature, -9.81 / (lapseRate * gasConstant));
      pressure = standardPressure * pressureRatio;
    } else if (altitudeKm < 20) {
      // 平流层底部（11-20km）：温度保持恒定
      const temp11km = 216.65; // K
      const pressure11km = 22632.06; // Pa
      temperature = temp11km;
      const deltaH = altitude - 11000; // m
      pressure = pressure11km * Math.exp(-9.81 * deltaH / (gasConstant * temperature));
    } else if (altitudeKm < 32) {
      // 平流层中部（20-32km）：温度随高度线性升高
      const temp20km = 216.65; // K
      const pressure20km = 5474.89; // Pa
      const lapseRate = 0.001; // K/m
      temperature = temp20km + lapseRate * (altitude - 20000);
      const pressureRatio = Math.pow(temperature / temp20km, 9.81 / (lapseRate * gasConstant));
      pressure = pressure20km * pressureRatio;
    } else {
      // 更高层：使用简化模型
      temperature = Math.max(186.87, standardTemperature - 6.5 * 11 - 0.0 * 9 + 0.0028 * Math.max(0, altitude - 32000));
      pressure = standardPressure * Math.exp(-9.81 * altitude / (gasConstant * temperature));
    }
    
    // 计算密度：理想气体状态方程
    const density = pressure / (gasConstant * temperature);
    
    return Math.max(density, 1e-9); // 确保密度为正数
  }
}

// 创建单例实例
const configManager = new ConfigManager();
export default configManager;
