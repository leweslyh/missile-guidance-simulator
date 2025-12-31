import React from 'react'
import { Card, Tabs, Space } from 'antd'
import Plot from 'react-plotly.js'

const { TabPane } = Tabs

function Visualization({ data, results }) {
  // 3D轨迹可视化
  const renderTrajectory3D = () => {
    if (!data) {
      return (
        <div className="trajectory-container" style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', background: 'var(--panel-bg)', borderRadius: '6px', border: '1px solid var(--border-color)' }}>
          请运行仿真以查看轨迹
        </div>
      )
    }

    const trace1 = {
      x: data.missile.position.x,
      y: data.missile.position.y,
      z: data.missile.position.z,
      type: 'scatter3d',
      mode: 'lines',
      name: '导弹轨迹',
      line: {
        color: '#3182ce',  // STK风格蓝色
        width: 3,
        smoothing: 0.8
      }
    }

    const trace2 = {
      x: data.target.position.x,
      y: data.target.position.y,
      z: data.target.position.z,
      type: 'scatter3d',
      mode: 'lines',
      name: '目标轨迹',
      line: {
        color: '#e53e3e',  // STK风格红色
        width: 2,
        dash: 'dash',
        smoothing: 0.8
      }
    }

    // 添加导弹和目标的终点标记
    const missileLen = data.missile.position.x.length;
    const targetLen = data.target.position.x.length;
    
    const trace3 = {
      x: [data.missile.position.x[missileLen - 1]],
      y: [data.missile.position.y[missileLen - 1]],
      z: [data.missile.position.z[missileLen - 1]],
      type: 'scatter3d',
      mode: 'markers',
      name: '导弹终点',
      marker: {
        color: '#3182ce',
        size: 8,
        symbol: 'circle',
        line: {
          color: '#ffffff',
          width: 1
        }
      }
    }

    const trace4 = {
      x: [data.target.position.x[targetLen - 1]],
      y: [data.target.position.y[targetLen - 1]],
      z: [data.target.position.z[targetLen - 1]],
      type: 'scatter3d',
      mode: 'markers',
      name: '目标终点',
      marker: {
        color: '#e53e3e',
        size: 8,
        symbol: 'square',
        line: {
          color: '#ffffff',
          width: 1
        }
      }
    }

    const layout = {
      title: {
        text: '导弹与目标轨迹',
        font: {
          color: '#1e293b',
          size: 16,
          family: 'Segoe UI'
        }
      },
      scene: {
        xaxis: {
          title: {
            text: 'X (m)',
            font: {
              color: '#475569',
              size: 12
            }
          },
          backgroundcolor: '#ffffff',
          gridcolor: 'rgba(148, 163, 184, 0.6)',
          showbackground: true,
          zerolinecolor: '#e2e8f0',
          tickcolor: '#475569',
          tickfont: {
            color: '#475569',
            size: 11
          }
        },
        yaxis: {
          title: {
            text: 'Y (m)',
            font: {
              color: '#475569',
              size: 12
            }
          },
          backgroundcolor: '#ffffff',
          gridcolor: 'rgba(148, 163, 184, 0.6)',
          showbackground: true,
          zerolinecolor: '#e2e8f0',
          tickcolor: '#475569',
          tickfont: {
            color: '#475569',
            size: 11
          }
        },
        zaxis: {
          title: {
            text: 'Z (m)',
            font: {
              color: '#475569',
              size: 12
            }
          },
          backgroundcolor: '#ffffff',
          gridcolor: 'rgba(148, 163, 184, 0.6)',
          showbackground: true,
          zerolinecolor: '#e2e8f0',
          tickcolor: '#475569',
          tickfont: {
            color: '#475569',
            size: 11
          }
        },
        aspectmode: 'auto',
        bgcolor: '#ffffff'
      },
      paper_bgcolor: '#ffffff',
      plot_bgcolor: '#ffffff',
      margin: { l: 0, r: 0, b: 0, t: 40 },
      legend: {
        x: 0.05,
        y: 0.95,
        font: {
          color: '#1e293b',
          size: 12
        },
        bgcolor: 'rgba(255, 255, 255, 0.9)',
        bordercolor: '#e2e8f0',
        borderwidth: 1
      },
      hoverlabel: {
        bgcolor: '#ffffff',
        bordercolor: '#e2e8f0',
        font: {
          color: '#1e293b',
          size: 11
        }
      }
    }

    return (
      <div className="trajectory-container plot-container">
        <Plot
          data={[trace1, trace2, trace3, trace4]}
          layout={layout}
          config={{
            displayModeBar: true,
            modeBarButtonsToRemove: ['pan2d', 'select2d', 'lasso2d'],
            displaylogo: false,
            toImageButtonOptions: {
              format: 'png',
              filename: 'trajectory_3d',
              height: 500,
              width: 800,
              scale: 2
            }
          }}
          style={{ width: '100%', height: '100%' }}
        />
      </div>
    )
  }

  // 相对距离可视化
  const renderRelativeDistance = () => {
    if (!data) {
      return (
        <div className="chart-container" style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', background: 'var(--panel-bg)', borderRadius: '6px', border: '1px solid var(--border-color)' }}>
          请运行仿真以查看相对距离
        </div>
      )
    }

    const trace = {
      x: data.time,
      y: data.relativeMotion.relativeDistance,
      type: 'scatter',
      mode: 'lines',
      name: '相对距离',
      line: {
        color: '#38a169',  // STK风格绿色
        width: 2,
        smoothing: 0.8
      }
    }

    const layout = {
      title: {
        text: '导弹与目标相对距离',
        font: {
          color: '#1e293b',
          size: 16,
          family: 'Segoe UI'
        }
      },
      xaxis: {
        title: {
          text: '时间 (s)',
          font: {
            color: '#475569',
            size: 12
          }
        },
        gridcolor: 'rgba(148, 163, 184, 0.6)',
        zerolinecolor: '#e2e8f0',
        tickcolor: '#475569',
        tickfont: {
          color: '#475569',
          size: 11
        },
        showgrid: true,
        showline: true,
        linecolor: '#e2e8f0'
      },
      yaxis: {
        title: {
          text: '距离 (m)',
          font: {
            color: '#475569',
            size: 12
          }
        },
        gridcolor: 'rgba(148, 163, 184, 0.6)',
        zerolinecolor: '#e2e8f0',
        tickcolor: '#475569',
        tickfont: {
          color: '#475569',
          size: 11
        },
        showgrid: true,
        showline: true,
        linecolor: '#e2e8f0'
      },
      paper_bgcolor: '#ffffff',
      plot_bgcolor: '#ffffff',
      margin: { l: 60, r: 20, b: 50, t: 40 },
      legend: {
        x: 0.02,
        y: 0.95,
        font: {
          color: '#1e293b',
          size: 12
        },
        bgcolor: 'rgba(255, 255, 255, 0.9)',
        bordercolor: '#e2e8f0',
        borderwidth: 1
      },
      hoverlabel: {
        bgcolor: '#ffffff',
        bordercolor: '#e2e8f0',
        font: {
          color: '#1e293b',
          size: 11
        }
      }
    }

    return (
      <div className="chart-container plot-container">
        <Plot
          data={[trace]}
          layout={layout}
          config={{
            displayModeBar: true,
            modeBarButtonsToRemove: ['pan2d', 'select2d', 'lasso2d'],
            displaylogo: false,
            toImageButtonOptions: {
              format: 'png',
              filename: 'relative_distance',
              height: 400,
              width: 800,
              scale: 2
            }
          }}
          style={{ width: '100%', height: '100%' }}
        />
      </div>
    )
  }

  // 加速度可视化
  const renderAcceleration = () => {
    if (!data) {
      return (
        <div className="chart-container" style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', background: 'var(--panel-bg)', borderRadius: '6px', border: '1px solid var(--border-color)' }}>
          请运行仿真以查看加速度
        </div>
      )
    }

    const traceX = {
      x: data.time,
      y: data.missile.acceleration.x,
      type: 'scatter',
      mode: 'lines',
      name: 'X方向加速度',
      line: { color: '#e53e3e', width: 1.5, smoothing: 0.8 }
    }

    const traceY = {
      x: data.time,
      y: data.missile.acceleration.y,
      type: 'scatter',
      mode: 'lines',
      name: 'Y方向加速度',
      line: { color: '#38a169', width: 1.5, smoothing: 0.8 }
    }

    const traceZ = {
      x: data.time,
      y: data.missile.acceleration.z,
      type: 'scatter',
      mode: 'lines',
      name: 'Z方向加速度',
      line: { color: '#3182ce', width: 1.5, smoothing: 0.8 }
    }

    const layout = {
      title: {
        text: '导弹加速度',
        font: {
          color: '#1e293b',
          size: 16,
          family: 'Segoe UI'
        }
      },
      xaxis: {
        title: {
          text: '时间 (s)',
          font: {
            color: '#475569',
            size: 12
          }
        },
        gridcolor: 'rgba(148, 163, 184, 0.6)',
        zerolinecolor: '#e2e8f0',
        tickcolor: '#475569',
        tickfont: {
          color: '#475569',
          size: 11
        },
        showgrid: true,
        showline: true,
        linecolor: '#e2e8f0'
      },
      yaxis: {
        title: {
          text: '加速度 (m/s²)',
          font: {
            color: '#475569',
            size: 12
          }
        },
        gridcolor: 'rgba(148, 163, 184, 0.6)',
        zerolinecolor: '#e2e8f0',
        tickcolor: '#475569',
        tickfont: {
          color: '#475569',
          size: 11
        },
        showgrid: true,
        showline: true,
        linecolor: '#e2e8f0'
      },
      paper_bgcolor: '#ffffff',
      plot_bgcolor: '#ffffff',
      margin: { l: 60, r: 20, b: 50, t: 40 },
      legend: {
        x: 0.02,
        y: 0.95,
        font: {
          color: '#1e293b',
          size: 12
        },
        bgcolor: 'rgba(255, 255, 255, 0.9)',
        bordercolor: '#e2e8f0',
        borderwidth: 1
      },
      hoverlabel: {
        bgcolor: '#ffffff',
        bordercolor: '#e2e8f0',
        font: {
          color: '#1e293b',
          size: 11
        }
      }
    }

    return (
      <div className="chart-container plot-container">
        <Plot
          data={[traceX, traceY, traceZ]}
          layout={layout}
          config={{
            displayModeBar: true,
            modeBarButtonsToRemove: ['pan2d', 'select2d', 'lasso2d'],
            displaylogo: false,
            toImageButtonOptions: {
              format: 'png',
              filename: 'acceleration',
              height: 400,
              width: 800,
              scale: 2
            }
          }}
          style={{ width: '100%', height: '100%' }}
        />
      </div>
    )
  }

  // 接近速度可视化
  const renderClosingVelocity = () => {
    if (!data) {
      return (
        <div className="chart-container" style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', background: 'var(--panel-bg)', borderRadius: '6px', border: '1px solid var(--border-color)' }}>
          请运行仿真以查看接近速度
        </div>
      )
    }

    const trace = {
      x: data.time,
      y: data.relativeMotion.closingVelocity,
      type: 'scatter',
      mode: 'lines',
      name: '接近速度',
      line: {
        color: '#805ad5',  // 紫色
        width: 2,
        smoothing: 0.8
      }
    }

    const layout = {
      title: {
        text: '导弹与目标接近速度',
        font: {
          color: '#1e293b',
          size: 16,
          family: 'Segoe UI'
        }
      },
      xaxis: {
        title: {
          text: '时间 (s)',
          font: {
            color: '#475569',
            size: 12
          }
        },
        gridcolor: 'rgba(148, 163, 184, 0.6)',
        zerolinecolor: '#e2e8f0',
        tickcolor: '#475569',
        tickfont: {
          color: '#475569',
          size: 11
        },
        showgrid: true,
        showline: true,
        linecolor: '#e2e8f0'
      },
      yaxis: {
        title: {
          text: '接近速度 (m/s)',
          font: {
            color: '#475569',
            size: 12
          }
        },
        gridcolor: 'rgba(148, 163, 184, 0.6)',
        zerolinecolor: '#e2e8f0',
        tickcolor: '#475569',
        tickfont: {
          color: '#475569',
          size: 11
        },
        showgrid: true,
        showline: true,
        linecolor: '#e2e8f0'
      },
      paper_bgcolor: '#ffffff',
      plot_bgcolor: '#ffffff',
      margin: { l: 60, r: 20, b: 50, t: 40 },
      legend: {
        x: 0.02,
        y: 0.95,
        font: {
          color: '#1e293b',
          size: 12
        },
        bgcolor: 'rgba(255, 255, 255, 0.9)',
        bordercolor: '#e2e8f0',
        borderwidth: 1
      },
      hoverlabel: {
        bgcolor: '#ffffff',
        bordercolor: '#e2e8f0',
        font: {
          color: '#1e293b',
          size: 11
        }
      }
    }

    return (
      <div className="chart-container plot-container">
        <Plot
          data={[trace]}
          layout={layout}
          config={{
            displayModeBar: true,
            modeBarButtonsToRemove: ['pan2d', 'select2d', 'lasso2d'],
            displaylogo: false,
            toImageButtonOptions: {
              format: 'png',
              filename: 'closing_velocity',
              height: 400,
              width: 800,
              scale: 2
            }
          }}
          style={{ width: '100%', height: '100%' }}
        />
      </div>
    )
  }

  // 速度可视化
  const renderVelocity = () => {
    if (!data) {
      return (
        <div className="chart-container" style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', background: 'var(--panel-bg)', borderRadius: '6px', border: '1px solid var(--border-color)' }}>
          请运行仿真以查看速度
        </div>
      )
    }

    // 计算导弹速度大小
    const missileSpeed = data.missile.velocity.x.map((vx, i) => {
      const vy = data.missile.velocity.y[i]
      const vz = data.missile.velocity.z[i]
      return Math.sqrt(vx * vx + vy * vy + vz * vz)
    })

    // 计算目标速度大小
    const targetSpeed = data.target.velocity.x.map((vx, i) => {
      const vy = data.target.velocity.y[i]
      const vz = data.target.velocity.z[i]
      return Math.sqrt(vx * vx + vy * vy + vz * vz)
    })

    const trace1 = {
      x: data.time,
      y: missileSpeed,
      type: 'scatter',
      mode: 'lines',
      name: '导弹速度',
      line: { color: '#3182ce', width: 2, smoothing: 0.8 }
    }

    const trace2 = {
      x: data.time,
      y: targetSpeed,
      type: 'scatter',
      mode: 'lines',
      name: '目标速度',
      line: { color: '#e53e3e', width: 2, dash: 'dash', smoothing: 0.8 }
    }

    const layout = {
      title: {
        text: '导弹与目标速度',
        font: {
          color: '#1e293b',
          size: 16,
          family: 'Segoe UI'
        }
      },
      xaxis: {
        title: {
          text: '时间 (s)',
          font: {
            color: '#475569',
            size: 12
          }
        },
        gridcolor: 'rgba(148, 163, 184, 0.6)',
        zerolinecolor: '#e2e8f0',
        tickcolor: '#475569',
        tickfont: {
          color: '#475569',
          size: 11
        },
        showgrid: true,
        showline: true,
        linecolor: '#e2e8f0'
      },
      yaxis: {
        title: {
          text: '速度 (m/s)',
          font: {
            color: '#475569',
            size: 12
          }
        },
        gridcolor: 'rgba(148, 163, 184, 0.6)',
        zerolinecolor: '#e2e8f0',
        tickcolor: '#475569',
        tickfont: {
          color: '#475569',
          size: 11
        },
        showgrid: true,
        showline: true,
        linecolor: '#e2e8f0'
      },
      paper_bgcolor: '#ffffff',
      plot_bgcolor: '#ffffff',
      margin: { l: 60, r: 20, b: 50, t: 40 },
      legend: {
        x: 0.02,
        y: 0.95,
        font: {
          color: '#1e293b',
          size: 12
        },
        bgcolor: 'rgba(255, 255, 255, 0.9)',
        bordercolor: '#e2e8f0',
        borderwidth: 1
      },
      hoverlabel: {
        bgcolor: '#ffffff',
        bordercolor: '#e2e8f0',
        font: {
          color: '#1e293b',
          size: 11
        }
      }
    }

    return (
      <div className="chart-container plot-container">
        <Plot
          data={[trace1, trace2]}
          layout={layout}
          config={{
            displayModeBar: true,
            modeBarButtonsToRemove: ['pan2d', 'select2d', 'lasso2d'],
            displaylogo: false,
            toImageButtonOptions: {
              format: 'png',
              filename: 'velocity',
              height: 400,
              width: 800,
              scale: 2
            }
          }}
          style={{ width: '100%', height: '100%' }}
        />
      </div>
    )
  }

  return (
    <Card title="仿真可视化" className="visualization-panel" variant="outlined">
      <Tabs defaultActiveKey="1" centered items={[
        {
          key: '1',
          label: '3D轨迹',
          children: renderTrajectory3D()
        },
        {
          key: '2',
          label: '相对距离',
          children: renderRelativeDistance()
        },
        {
          key: '3',
          label: '加速度',
          children: renderAcceleration()
        },
        {
          key: '4',
          label: '速度',
          children: renderVelocity()
        },
        {
          key: '5',
          label: '接近速度',
          children: renderClosingVelocity()
        }
      ]} />
    </Card>
  )
}

export default Visualization