import React from 'react'
import { Card, Descriptions, Tag, Space } from 'antd'

function ResultsDisplay({ results }) {
  if (!results) return null

  const getResultStatus = () => {
    switch (results.reason) {
      case 'intercepted':
        return <Tag color="success">成功命中</Tag>
      case 'timeout':
        return <Tag color="warning">超时</Tag>
      case 'low_speed':
        return <Tag color="error">速度过低</Tag>
      default:
        return <Tag color="default">未知</Tag>
    }
  }

  return (
    <Card title="仿真结果" className="results-panel" variant="outlined">
      <Descriptions column={2} bordered>
        <Descriptions.Item label="仿真状态">
          {getResultStatus()}
        </Descriptions.Item>
        
        <Descriptions.Item label="终止原因">
          {results.reason === 'intercepted' ? '导弹命中目标' : 
           results.reason === 'timeout' ? '超过最大仿真时间' : 
           results.reason === 'low_speed' ? '导弹速度低于最小阈值' : 
           '未知原因'}
        </Descriptions.Item>
        
        <Descriptions.Item label="仿真时间">
          {results.time.toFixed(2)} 秒
        </Descriptions.Item>
        
        <Descriptions.Item label="脱靶量">
          {results.missDistance.toFixed(2)} 米
        </Descriptions.Item>
        
        <Descriptions.Item label="导弹最终位置" span={2}>
          [{results.missileState.position[0].toFixed(2)}, 
           {results.missileState.position[1].toFixed(2)}, 
           {results.missileState.position[2].toFixed(2)}] 米
        </Descriptions.Item>
        
        <Descriptions.Item label="目标最终位置" span={2}>
          [{results.targetState.position[0].toFixed(2)}, 
           {results.targetState.position[1].toFixed(2)}, 
           {results.targetState.position[2].toFixed(2)}] 米
        </Descriptions.Item>
        
        <Descriptions.Item label="导弹最终速度">
          {results.missileState.speed.toFixed(2)} 米/秒
        </Descriptions.Item>
        
        <Descriptions.Item label="目标最终速度">
          {Math.sqrt(
            results.targetState.velocity[0] ** 2 + 
            results.targetState.velocity[1] ** 2 + 
            results.targetState.velocity[2] ** 2
          ).toFixed(2)} 米/秒
        </Descriptions.Item>
      </Descriptions>
    </Card>
  )
}

export default ResultsDisplay