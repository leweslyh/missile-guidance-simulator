import React, { useState } from 'react'
import { Typography, Button, Card, Space } from 'antd'
import SimulationControl from './components/SimulationControl'
import Visualization from './components/Visualization'
import ResultsDisplay from './components/ResultsDisplay'
import { MissileModel, TargetModel, GuidanceLaw, SimulationEnv } from './core/simulation'

const { Title } = Typography

function App() {
  const [simulationResults, setSimulationResults] = useState(null)
  const [simulationData, setSimulationData] = useState(null)
  const [isRunning, setIsRunning] = useState(false)

  const handleRunSimulation = (params) => {
    setIsRunning(true)
    
    // 初始化模型
    const missile = new MissileModel(params.missile)
    const target = new TargetModel(params.target)
    
    // 创建制导律实例，包含自定义代码
    const guidanceLaw = new GuidanceLaw({
      lawType: params.guidance.lawType,
      params: params.guidance.params,
      customCode: params.guidance.customCode
    })
    
    const simulationEnv = new SimulationEnv(missile, target, guidanceLaw, params.simulation)
    
    // 运行仿真
    const results = simulationEnv.run()
    const data = simulationEnv.getData()
    
    setSimulationResults(results)
    setSimulationData(data)
    setIsRunning(false)
  }

  return (
    <div className="app-container">
      <Title level={2}>导弹制导律验证程序</Title>
      
      <div className="simulation-grid">
        {/* 左侧控制面板 */}
        <SimulationControl 
          onRunSimulation={handleRunSimulation}
          isRunning={isRunning}
        />
        
        {/* 右侧可视化区域 */}
        <div>
          <Visualization 
            data={simulationData}
            results={simulationResults}
          />
          
          {/* 结果显示 */}
          {simulationResults && (
            <ResultsDisplay results={simulationResults} />
          )}
        </div>
      </div>
    </div>
  )
}

export default App