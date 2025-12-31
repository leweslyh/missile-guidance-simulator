# 导弹制导律验证软件

一个基于Web的导弹制导律验证与仿真系统，支持多种经典制导律和自定义制导律开发。

## 🎯 功能特性

### 核心功能
- **多种制导律支持**：比例导引（PN）、纯追踪（PP）、扩展比例导引（APN）、最优制导律（OGL）
- **自定义制导律**：支持用户编写JavaScript代码实现自定义制导算法
- **3D轨迹可视化**：使用Plotly.js实现高精度3D轨迹绘制
- **实时数据曲线**：相对距离、加速度、速度、接近速度等数据的实时可视化
- **多种目标运动模式**：匀速直线、正弦运动、圆周运动、平滑随机运动、智能规避、之字形机动、螺旋机动
- **物理模型**：包含重力、大气阻力、推力等物理因素

### 技术特性
- **模块化架构**：清晰的分层设计，易于扩展和维护
- **响应式设计**：适配不同屏幕尺寸
- **高性能仿真**：优化的仿真循环，支持实时仿真
- **友好的用户界面**：基于Ant Design的现代化UI

## 📋 快速开始

### 环境要求
- Node.js >= 18.0.0
- npm >= 9.0.0

### 安装依赖
```bash
npm install
```

### 启动开发服务器
```bash
npm run dev
```

应用将在 `http://localhost:3000` 启动。

### 构建生产版本
```bash
npm run build
```

构建后的文件将输出到 `dist` 目录。

### 运行测试
```bash
npm test
```

## 📁 项目结构

```
├── src/
│   ├── components/          # React组件
│   │   ├── SimulationControl/   # 仿真控制面板
│   │   ├── Visualization/       # 3D轨迹和数据可视化
│   │   └── ResultsDisplay/      # 仿真结果显示
│   ├── core/               # 核心仿真逻辑
│   │   ├── simulation/         # 仿真环境
│   │   ├── guidance/           # 制导律模块
│   │   ├── models/             # 运动学模型
│   │   └── utils/              # 工具函数
│   ├── App.jsx             # 应用主组件
│   └── main.jsx            # 应用入口
├── matlab/                 # MATLAB原始代码
├── results/                # 仿真结果
├── docs/                   # 文档
├── package.json            # 依赖配置
└── README.md               # 项目说明
```

## 🛠️ 使用指南

### 1. 设置仿真参数

在左侧控制面板中设置以下参数：

- **导弹参数**：位置、速度、最大加速度、最小速度
- **目标参数**：位置、速度、运动类型
- **制导参数**：制导律类型、导航比、自定义制导律代码
- **仿真参数**：时间步长、最大仿真时间、脱靶量阈值

### 2. 运行仿真

点击"开始仿真"按钮，系统将：
- 初始化仿真环境
- 执行仿真循环
- 实时计算导弹和目标的运动轨迹
- 记录仿真数据

### 3. 查看仿真结果

仿真完成后，可以在右侧查看：
- **3D轨迹**：导弹和目标的三维运动轨迹
- **相对距离**：导弹与目标之间的距离随时间变化
- **加速度**：导弹在三个方向上的加速度
- **速度**：导弹和目标的速度大小
- **接近速度**：导弹与目标的接近速度

### 4. 编写自定义制导律

选择"自定义制导律"，在代码框中编写JavaScript代码。

**示例1：比例导引律**
```javascript
return losRate.map(w => N * Vc * w);
```

**示例2：纯追踪制导律**
```javascript
const desiredVel = losVector.map(v => v * missileState.speed);
return [
  (desiredVel[0] - missileState.velocity[0]) / 0.1,
  (desiredVel[1] - missileState.velocity[1]) / 0.1,
  (desiredVel[2] - missileState.velocity[2]) / 0.1
];
```

**可用变量**：
- `N`：导航比
- `r`：相对距离
- `Vc`：接近速度
- `losRate`：视线速率 [wx, wy, wz]
- `losVector`：视线向量 [nx, ny, nz]
- `relativePos`：相对位置 [rx, ry, rz]
- `relativeVel`：相对速度 [vx, vy, vz]
- `missileState`：导弹状态对象
- `targetState`：目标状态对象

## 🏗️ 架构设计

### 核心模块

1. **SimulationEnv**：仿真环境，负责控制仿真循环和数据管理
2. **GuidanceLaw**：制导律模块，实现各种制导算法
3. **MissileModel**：导弹运动学模型，包含物理特性
4. **TargetModel**：目标运动模型，支持多种运动模式
5. **VectorUtils**：向量工具类，提供各种向量运算

### 数据流

```
用户输入 → SimulationControl → SimulationEnv → GuidanceLaw → MissileModel
                                                     ↓
                                           TargetModel → 相对运动计算
                                                     ↓
                                            数据记录 → 可视化展示
```

## 📊 仿真结果分析

仿真完成后，系统将生成以下数据：

| 数据项 | 说明 |
|--------|------|
| 时间序列 | 仿真时间点 |
| 导弹位置 | 三维坐标 (x, y, z) |
| 目标位置 | 三维坐标 (x, y, z) |
| 导弹速度 | 三维速度分量 |
| 目标速度 | 三维速度分量 |
| 导弹加速度 | 三维加速度分量 |
| 相对距离 | 导弹与目标之间的距离 |
| 接近速度 | 导弹向目标接近的速度 |

## 🔧 开发说明

### 代码规范
- 使用ES6+语法
- 遵循React最佳实践
- 使用Ant Design组件库
- 代码通过ESLint检查

### 测试
- 使用Jest进行单元测试
- 测试文件命名为 `*.test.js`
- 运行 `npm test` 执行测试

### 性能优化
- 仿真循环优化，减少状态获取次数
- 向量运算优化，使用高效的数学计算
- 可视化渲染优化，避免不必要的重绘

## 🤝 贡献指南

欢迎提交Issue和Pull Request！

1. Fork本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启Pull Request

## 📄 许可证

本项目采用MIT许可证。

## 📞 联系方式

如有问题或建议，请通过GitHub Issues反馈。

---

**导弹制导律验证软件** - 基于Web的高性能仿真系统
