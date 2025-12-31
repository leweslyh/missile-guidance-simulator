import React, { useState } from 'react'
import { Form, InputNumber, Select, Button, Card, Space, Divider } from 'antd'

const { Option } = Select

function SimulationControl({ onRunSimulation, isRunning }) {
  const [form] = Form.useForm()

  const handleRun = () => {
    form.validateFields().then(values => {
      const params = {
        missile: {
          position: [values.missilePosX, values.missilePosY, values.missilePosZ],
          velocity: [values.missileVelX, values.missileVelY, values.missileVelZ],
          maxAcceleration: values.missileMaxAccel,
          minVelocity: values.missileMinVel
        },
        target: {
          position: [values.targetPosX, values.targetPosY, values.targetPosZ],
          velocity: [values.targetVelX, values.targetVelY, values.targetVelZ],
          motionType: values.targetMotionType
        },
        guidance: {
          lawType: values.guidanceLaw,
          params: {
            N: values.navigationRatio
          },
          // 添加自定义制导律代码
          customCode: values.customGuidanceLaw || ''
        },
        simulation: {
          dt: values.timeStep,
          maxTime: values.maxSimulationTime,
          missDistanceThreshold: values.missDistanceThreshold,
          minMissileSpeed: values.minMissileSpeed
        }
      }
      
      onRunSimulation(params)
    })
  }

  return (
    <Card title="仿真控制" className="control-panel" variant="outlined">
      <Form
        form={form}
        layout="vertical"
        initialValues={{
          missilePosX: 0,
          missilePosY: 0,
          missilePosZ: 0,
          missileVelX: 300,
          missileVelY: 0,
          missileVelZ: 0,
          missileMaxAccel: 200,
          missileMinVel: 50,
          targetPosX: 2000,
          targetPosY: 800,
          targetPosZ: 400,
          targetVelX: -80,
          targetVelY: 0,
          targetVelZ: 0,
          targetMotionType: 'constant',
          guidanceLaw: 'PN',
          navigationRatio: 4.0,
          timeStep: 0.01,
          maxSimulationTime: 30.0,
          missDistanceThreshold: 5.0,
          minMissileSpeed: 50.0
        }}
      >
        <Divider orientation="left">导弹参数</Divider>
        
        <Space.Compact direction="vertical" style={{ width: '100%' }}>
          <Form.Item name="missilePosX" label="导弹X坐标 (m)">
            <InputNumber style={{ width: '100%' }} min={-10000} max={10000} />
          </Form.Item>
          
          <Form.Item name="missilePosY" label="导弹Y坐标 (m)">
            <InputNumber style={{ width: '100%' }} min={-10000} max={10000} />
          </Form.Item>
          
          <Form.Item name="missilePosZ" label="导弹Z坐标 (m)">
            <InputNumber style={{ width: '100%' }} min={-10000} max={10000} />
          </Form.Item>
          
          <Form.Item name="missileVelX" label="导弹X速度 (m/s)">
            <InputNumber style={{ width: '100%' }} min={0} max={1000} />
          </Form.Item>
          
          <Form.Item name="missileVelY" label="导弹Y速度 (m/s)">
            <InputNumber style={{ width: '100%' }} min={-500} max={500} />
          </Form.Item>
          
          <Form.Item name="missileVelZ" label="导弹Z速度 (m/s)">
            <InputNumber style={{ width: '100%' }} min={-500} max={500} />
          </Form.Item>
          
          <Form.Item name="missileMaxAccel" label="最大加速度 (m/s²)" extra="导弹能够产生的最大过载加速度">
            <InputNumber style={{ width: '100%' }} min={10} max={500} />
          </Form.Item>
          
          <Form.Item name="missileMinVel" label="最小速度 (m/s)">
            <InputNumber style={{ width: '100%' }} min={0} max={200} />
          </Form.Item>
        </Space.Compact>
        
        <Divider orientation="left">目标参数</Divider>
        
        <Space.Compact direction="vertical" style={{ width: '100%' }}>
          <Form.Item name="targetPosX" label="目标X坐标 (m)">
            <InputNumber style={{ width: '100%' }} min={-10000} max={10000} />
          </Form.Item>
          
          <Form.Item name="targetPosY" label="目标Y坐标 (m)">
            <InputNumber style={{ width: '100%' }} min={-10000} max={10000} />
          </Form.Item>
          
          <Form.Item name="targetPosZ" label="目标Z坐标 (m)">
            <InputNumber style={{ width: '100%' }} min={-10000} max={10000} />
          </Form.Item>
          
          <Form.Item name="targetVelX" label="目标X速度 (m/s)">
            <InputNumber style={{ width: '100%' }} min={-500} max={500} />
          </Form.Item>
          
          <Form.Item name="targetVelY" label="目标Y速度 (m/s)">
            <InputNumber style={{ width: '100%' }} min={-500} max={500} />
          </Form.Item>
          
          <Form.Item name="targetVelZ" label="目标Z速度 (m/s)">
            <InputNumber style={{ width: '100%' }} min={-500} max={500} />
          </Form.Item>
          
          <Form.Item name="targetMotionType" label="运动类型" extra="选择目标的运动模式">
            <Select>
              <Option value="constant">匀速直线</Option>
              <Option value="sine">正弦运动</Option>
              <Option value="circular">圆周运动</Option>
              <Option value="random">随机运动（平滑）</Option>
              <Option value="evasive">智能规避</Option>
              <Option value="zigzag">之字形机动</Option>
              <Option value="spiral">螺旋机动</Option>
            </Select>
          </Form.Item>
        </Space.Compact>
        
        <Divider orientation="left">制导参数</Divider>
        
        <Space.Compact direction="vertical" style={{ width: '100%' }}>
          <Form.Item name="guidanceLaw" label="制导律">
            <Select>
              <Option value="PN">比例导引 (PN)</Option>
              <Option value="PP">纯追踪 (PP)</Option>
              <Option value="APN">扩展比例导引 (APN)</Option>
              <Option value="OGL">最优制导律 (OGL)</Option>
              <Option value="custom">自定义制导律</Option>
            </Select>
          </Form.Item>
          
          <Form.Item name="navigationRatio" label="导航比 N" extra="PN制导律的核心参数，一般取3-5">
            <InputNumber style={{ width: '100%' }} min={1} max={10} step={0.5} />
          </Form.Item>
          
          <Form.Item 
            name="customGuidanceLaw" 
            label="自定义制导律代码" 
            extra="💡 极简说明：\n- 直接编写加速度计算逻辑，最后返回 [ax, ay, az] 数组\n- 无需模板代码，无需定义函数\n- 支持直接使用以下变量：\n  • N: 导航比\n  • r: 相对距离\n  • Vc: 接近速度\n  • losRate: 视线速率 [wx, wy, wz]\n  • losVector: 视线向量 [nx, ny, nz]\n  • relativePos: 相对位置 [rx, ry, rz]\n  • relativeVel: 相对速度 [vx, vy, vz]"
          >
            <textarea 
              rows={8} 
              placeholder="// 示例1：最简比例导引律（推荐）\nreturn [\n  N * Vc * losRate[0],\n  N * Vc * losRate[1],\n  N * Vc * losRate[2]\n];\n\n// 示例2：更简单的写法\n// return losRate.map(w => N * Vc * w);\n\n// 示例3：纯追踪制导律\n// const desiredVel = losVector.map(v => v * missileState.speed);\n// return [\n//   (desiredVel[0] - missileState.velocity[0]) / 0.1,\n//   (desiredVel[1] - missileState.velocity[1]) / 0.1,\n//   (desiredVel[2] - missileState.velocity[2]) / 0.1\n// ];\n\n// 示例4：无导航比的简单比例导引\n// return [\n//   3 * Vc * losRate[0],\n//   3 * Vc * losRate[1],\n//   3 * Vc * losRate[2]\n// ];\n\n// 示例5：基于相对位置的制导\n// return [\n//   -relativePos[0] * 0.1,\n//   -relativePos[1] * 0.1,\n//   -relativePos[2] * 0.1\n// ];
"
              style={{ 
                width: '100%', 
                background: 'var(--secondary-bg)', 
                color: 'var(--text-primary)', 
                border: '1px solid var(--border-color)',
                borderRadius: '4px',
                padding: '8px',
                fontFamily: 'monospace',
                fontSize: '12px'
              }} 
            />
          </Form.Item>
        </Space.Compact>
        
        <Divider orientation="left">仿真参数</Divider>
        
        <Space.Compact direction="vertical" style={{ width: '100%' }}>
          <Form.Item name="timeStep" label="时间步长 (s)" extra="仿真时间步长，越小精度越高但速度越慢">
            <InputNumber style={{ width: '100%' }} min={0.001} max={0.1} step={0.001} />
          </Form.Item>
          
          <Form.Item name="maxSimulationTime" label="最大仿真时间 (s)" extra="仿真最大持续时间，超过则自动终止">
            <InputNumber style={{ width: '100%' }} min={5} max={60} step={1} />
          </Form.Item>
          
          <Form.Item name="missDistanceThreshold" label="脱靶量阈值 (m)">
            <InputNumber style={{ width: '100%' }} min={0.1} max={20} step={0.5} />
          </Form.Item>
          
          <Form.Item name="minMissileSpeed" label="导弹最小速度 (m/s)">
            <InputNumber style={{ width: '100%' }} min={0} max={100} />
          </Form.Item>
        </Space.Compact>
        
        <Divider />
        
        <Space style={{ width: '100%' }} direction="vertical">
          <Button 
            type="primary" 
            size="large" 
            onClick={handleRun}
            loading={isRunning}
            disabled={isRunning}
            block
          >
            {isRunning ? '仿真中...' : '开始仿真'}
          </Button>
        </Space>
      </Form>
    </Card>
  )
}

export default SimulationControl