# 导弹制导律验证程序 - 函数关系流程图

## 系统架构概览

本程序采用模块化设计，主要包含以下核心模块：

1. **App.jsx** - 主应用组件，协调所有子组件
2. **SimulationControl** - 仿真控制面板，收集用户输入
3. **SimulationEnv** - 仿真环境，控制仿真循环
4. **GuidanceLaw** - 制导律模块，计算制导指令
5. **MissileModel** - 导弹运动学模型
6. **TargetModel** - 目标运动学模型
7. **Visualization** - 可视化组件，显示仿真结果
8. **ResultsDisplay** - 结果显示组件

---

## 主流程图

```mermaid
graph TD
    A[用户点击开始仿真] --> B[SimulationControl.handleRun]
    B --> C[App.handleRunSimulation]
    C --> D[创建 MissileModel 实例]
    C --> E[创建 TargetModel 实例]
    C --> F[创建 GuidanceLaw 实例]
    C --> G[创建 SimulationEnv 实例]
    G --> H[SimulationEnv.run]
    H --> I[仿真循环]
    I --> J[记录数据]
    I --> K[计算制导指令]
    I --> L[更新导弹状态]
    I --> M[更新目标状态]
    I --> N[更新相对运动]
    I --> O[检查终止条件]
    O -->|未终止| I
    O -->|已终止| P[返回仿真结果]
    P --> Q[App 设置状态]
    Q --> R[Visualization 渲染]
    Q --> S[ResultsDisplay 显示]
```

---

## SimulationEnv 详细流程图

```mermaid
graph TD
    A[SimulationEnv.run] --> B[初始化时间 t=0]
    B --> C[初始化数据存储]
    C --> D[updateRelativeMotion]
    D --> E[while 循环开始]
    E --> F[recordData]
    F --> G[missile.getState]
    F --> H[target.getState]
    G --> I[guidanceLaw.calculate]
    H --> I
    I --> J[missile.update]
    J --> K[target.update]
    K --> L[时间步进 t += dt]
    L --> M[updateRelativeMotion]
    M --> N[checkTermination]
    N -->|terminated=false| E
    N -->|terminated=true| O[记录最终状态]
    O --> P[返回结果对象]
```

### updateRelativeMotion 函数流程

```mermaid
graph TD
    A[updateRelativeMotion] --> B[missile.getState]
    A --> C[target.getState]
    B --> D[计算相对位置]
    C --> D
    D --> E[计算相对速度]
    E --> F[计算视线向量 losVector]
    F --> G[计算相对距离 r]
    G --> H[计算视线速率 losRate]
    H --> I[计算接近速度 Vc]
    I --> J[计算时间到拦截 t_go]
    J --> K[更新 relativeMotion 对象]
```

---

## GuidanceLaw 详细流程图

```mermaid
graph TD
    A[GuidanceLaw.calculate] --> B{lawType?}
    B -->|PN| C[calculatePN]
    B -->|PP| D[calculatePP]
    B -->|APN| E[calculateAPN]
    B -->|OGL| F[calculateOGL]
    B -->|custom| G[calculateCustom]
    C --> H[返回加速度指令]
    D --> H
    E --> H
    F --> H
    G --> H
```

### calculatePN 流程（含物理补偿）

```mermaid
graph TD
    A[calculatePN] --> B[获取导航比 N]
    A --> C[获取视线速率 losRate]
    A --> D[获取接近速度 Vc]
    A --> E[获取视线向量 losVector]
    A --> F[获取导弹状态]
    A --> G[获取目标状态]
    
    B --> H{Vc < 1e-6?}
    H -->|是| I[返回 0,0,0]
    H -->|否| J[计算基础PN指令]
    
    J --> K[cross losRate, losVector]
    K --> L[乘以 N * Vc]
    
    L --> M[添加重力补偿]
    M --> N[计算重力加速度分量]
    N --> O[垂直视线方向补偿]
    
    O --> P[添加大气阻力补偿]
    P --> Q[计算当前速度大小]
    Q --> R[计算阻力加速度]
    
    R --> S[总加速度指令]
    S --> T[返回加速度指令]
```

### calculateCustom 流程

```mermaid
graph TD
    A[calculateCustom] --> B[准备简化变量]
    B --> C[N, r, Vc, losRate, losVector]
    B --> D[relativePos, relativeVel]
    C --> E{customFunction 存在?}
    E -->|否| F[compileCustomLaw]
    E -->|是| G[执行自定义函数]
    F --> H{编译成功?}
    H -->|否| I[返回 0,0,0]
    H -->|是| G
    G --> J[验证返回值]
    J --> K{有效?}
    K -->|否| I
    K -->|是| L[返回加速度指令]
```

### compileCustomLaw 流程

```mermaid
graph TD
    A[compileCustomLaw] --> B[构建代码模板]
    B --> C[添加自动变量计算]
    C --> D[插入用户代码]
    D --> E[Function 构造函数]
    E --> F{编译成功?}
    F -->|是| G[保存 customFunction]
    F -->|否| H[返回错误信息]
    G --> I[返回 success: true]
```

---

## MissileModel 详细流程图（含物理模型）

```mermaid
graph TD
    A[missile.update] --> B[获取当前速度大小]
    B --> C[计算速度方向]
    C --> D[获取制导指令]
    
    D --> E[限制制导指令到最大加速度]
    E --> F[计算总加速度]
    
    F --> G[添加重力加速度]
    G --> H[计算重力分量 g = [0, -9.81, 0]]
    
    H --> I[计算大气阻力]
    I --> J[计算动态压力 q = 0.5 * ρ * v²]
    J --> K[计算阻力系数 Cd]
    K --> L[计算阻力面积 S]
    L --> M[阻力加速度 = -Cd * S * q / m]
    
    M --> N[计算推力加速度]
    N --> O[获取推力大小]
    O --> P[推力加速度 = thrust / m * 速度方向]
    
    P --> Q[总加速度 = 制导 + 重力 + 阻力 + 推力]
    
    Q --> R[更新速度 v = v + a*dt]
    R --> S{速度 < minVelocity?}
    S -->|是| T[限制到最小速度]
    S -->|否| U[更新位置 p = p + v*dt]
    T --> U
    
    U --> V[更新姿态 attitude = normalize v]
    V --> W[计算当前马赫数]
    W --> X[更新空气动力学参数]
    
    X --> Y[返回 this]
```

---

## TargetModel 详细流程图（增强机动模式）

```mermaid
graph TD
    A[target.update] --> B[时间步进 t += dt]
    B --> C{motionType?}
    
    C -->|constant| D[匀速直线运动]
    D --> E[加速度 = 0,0,0]
    
    C -->|circular| F[圆周运动]
    F --> G[计算角速度 ω]
    G --> H[计算向心加速度]
    H --> I[加速度 = [-rω²cosθ, -rω²sinθ, 0]]
    
    C -->|sine| J[正弦机动]
    J --> K[计算振幅 A]
    K --> L[计算频率 f]
    L --> M[加速度 = [A*sin(2πft), A*cos(2πft), 0]]
    
    C -->|random| N[随机机动]
    N --> O[生成高斯随机数]
    O --> P[平滑滤波]
    P --> Q[加速度 = [randX, randY, randZ]]
    
    C -->|evasive| R[智能规避]
    R --> S[检测导弹接近]
    S --> T[计算威胁方向]
    T --> U[生成垂直于威胁方向的机动]
    U --> V[加速度 = 规避指令]
    
    C -->|zigzag| W[之字形机动]
    W --> X[计算转向点]
    X --> Y[切换加速度方向]
    Y --> Z[加速度 = ±[maxAccel, 0, 0]]
    
    C -->|spiral| AA[螺旋机动]
    AA --> AB[计算螺旋参数]
    AB --> AC[加速度 = 螺旋轨迹加速度]
    
    E --> AD[更新速度 v = v + a*dt]
    I --> AD
    M --> AD
    Q --> AD
    V --> AD
    Z --> AD
    AC --> AD
    
    AD --> AE[更新位置 p = p + v*dt]
    AE --> AF[返回 this]
```

---

## Visualization 组件流程图

```mermaid
graph TD
    A[Visualization 组件] --> B{data 存在?}
    B -->|否| C[显示提示信息]
    B -->|是| D{Tab 选择}
    D -->|3D轨迹| E[renderTrajectory3D]
    D -->|相对距离| F[renderRelativeDistance]
    D -->|加速度| G[renderAcceleration]
    D -->|速度| H[renderVelocity]
    E --> I[创建 Plotly 3D 散点图]
    F --> J[创建 Plotly 2D 散点图]
    G --> K[创建 Plotly 2D 散点图]
    H --> L[创建 Plotly 2D 散点图]
```

---

## 数据流向图

```mermaid
graph LR
    A[用户输入] --> B[SimulationControl]
    B --> C[App.handleRunSimulation]
    C --> D[SimulationEnv]
    D --> E[GuidanceLaw]
    D --> F[MissileModel]
    D --> G[TargetModel]
    D --> H[recordData]
    H --> I[data 对象]
    I --> J[Visualization]
    I --> K[ResultsDisplay]
```

---

## 函数调用关系表

| 调用者 | 被调用函数 | 说明 |
|--------|-----------|------|
| App | MissileModel | 创建导弹模型实例 |
| App | TargetModel | 创建目标模型实例 |
| App | GuidanceLaw | 创建制导律实例 |
| App | SimulationEnv | 创建仿真环境实例 |
| SimulationEnv.run | missile.getState | 获取导弹状态 |
| SimulationEnv.run | target.getState | 获取目标状态 |
| SimulationEnv.run | guidanceLaw.calculate | 计算制导指令 |
| SimulationEnv.run | missile.update | 更新导弹状态 |
| SimulationEnv.run | target.update | 更新目标状态 |
| SimulationEnv.run | updateRelativeMotion | 更新相对运动 |
| SimulationEnv.run | recordData | 记录数据 |
| SimulationEnv.run | checkTermination | 检查终止条件 |
| GuidanceLaw.calculate | calculatePN | 计算比例导引 |
| GuidanceLaw.calculate | calculatePP | 计算纯追踪 |
| GuidanceLaw.calculate | calculateAPN | 计算扩展比例导引 |
| GuidanceLaw.calculate | calculateOGL | 计算最优制导律 |
| GuidanceLaw.calculate | calculateCustom | 计算自定义制导律 |
| calculateCustom | compileCustomLaw | 编译自定义代码 |
| MissileModel.update | limit | 限制向量大小 |
| MissileModel.update | normalize | 归一化向量 |
| TargetModel.update | - | 根据运动类型更新 |

---

## 关键数据结构

### SimulationEnv.data
```javascript
{
  time: [],                    // 时间序列
  missilePosition: [[], [], []],  // 导弹位置 [x, y, z]
  targetPosition: [[], [], []],   // 目标位置 [x, y, z]
  missileVelocity: [[], [], []],  // 导弹速度 [vx, vy, vz]
  targetVelocity: [[], [], []],   // 目标速度 [vx, vy, vz]
  missileAcceleration: [[], [], []], // 导弹加速度 [ax, ay, az]
  relativeDistance: [],        // 相对距离
  closingVelocity: []          // 接近速度
}
```

### relativeMotion
```javascript
{
  relativePosition: [rx, ry, rz],    // 相对位置
  relativeVelocity: [vx, vy, vz],    // 相对速度
  losVector: [nx, ny, nz],           // 视线向量（归一化）
  losRate: [wx, wy, wz],             // 视线速率
  closingVelocity: Vc,                // 接近速度
  timeToGo: t_go,                    // 时间到拦截
  relativeDistance: r                // 相对距离
}
```

### missileState / targetState
```javascript
{
  position: [x, y, z],      // 位置
  velocity: [vx, vy, vz],  // 速度
  acceleration: [ax, ay, az], // 加速度
  speed: V                 // 速度大小（仅导弹）
}
```

---

## 仿真循环时序图

```mermaid
sequenceDiagram
    participant App
    participant SimEnv
    participant GL
    participant Missile
    participant Target

    App->>SimEnv: run()
    SimEnv->>SimEnv: updateRelativeMotion()
    
    loop 仿真循环
        SimEnv->>SimEnv: recordData()
        SimEnv->>Missile: getState()
        Missile-->>SimEnv: missileState
        SimEnv->>Target: getState()
        Target-->>SimEnv: targetState
        SimEnv->>GL: calculate(missileState, targetState, relativeMotion)
        GL-->>SimEnv: guidanceCmd
        SimEnv->>Missile: update(guidanceCmd, dt)
        SimEnv->>Target: update(dt)
        SimEnv->>SimEnv: time += dt
        SimEnv->>SimEnv: updateRelativeMotion()
        SimEnv->>SimEnv: checkTermination()
    end
    
    SimEnv-->>App: results
```

---

## 自定义制导律执行流程

```mermaid
graph TD
    A[用户输入自定义代码] --> B[SimulationControl 收集]
    B --> C[App.handleRunSimulation]
    C --> D[GuidanceLaw 构造函数]
    D --> E{lawType == 'custom'?}
    E -->|是| F[compileCustomLaw]
    E -->|否| G[跳过编译]
    F --> H{编译成功?}
    H -->|是| I[保存 customFunction]
    H -->|否| J[记录错误]
    I --> K[仿真循环开始]
    K --> L[calculateCustom]
    L --> M[准备简化变量]
    M --> N[执行 customFunction]
    N --> O[验证返回值]
    O --> P[返回加速度指令]
```

---

## 总结

本程序采用清晰的模块化架构，各模块职责明确：

1. **App.jsx** - 应用主控制器，协调各组件
2. **SimulationControl** - 用户界面，收集参数
3. **SimulationEnv** - 仿真引擎，控制循环
4. **GuidanceLaw** - 制导算法，计算指令
5. **MissileModel** - 导弹模型，更新状态
6. **TargetModel** - 目标模型，更新状态
7. **Visualization** - 可视化展示
8. **ResultsDisplay** - 结果统计

数据流向清晰：用户输入 → 仿真计算 → 数据记录 → 可视化展示
