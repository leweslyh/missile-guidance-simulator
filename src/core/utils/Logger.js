// 日志系统
class Logger {
  constructor() {
    this.logLevel = 'info'; // 默认日志级别
    this.logLevels = ['debug', 'info', 'warn', 'error'];
    this.logFile = null;
    this.logHistory = [];
  }

  // 设置日志级别
  setLevel(level) {
    if (this.logLevels.includes(level)) {
      this.logLevel = level;
      this.info(`日志级别已设置为: ${level}`);
    } else {
      this.error(`无效的日志级别: ${level}，可选级别: ${this.logLevels.join(', ')}`);
    }
  }

  // 获取日志级别
  getLevel() {
    return this.logLevel;
  }

  // 判断是否应该记录该级别的日志
  shouldLog(level) {
    return this.logLevels.indexOf(level) >= this.logLevels.indexOf(this.logLevel);
  }

  // 调试日志
  debug(message, ...args) {
    if (this.shouldLog('debug')) {
      const logMessage = `[DEBUG] ${new Date().toISOString()} - ${message}`;
      console.debug(logMessage, ...args);
      this.addToHistory('debug', logMessage, args);
    }
  }

  // 信息日志
  info(message, ...args) {
    if (this.shouldLog('info')) {
      const logMessage = `[INFO] ${new Date().toISOString()} - ${message}`;
      console.info(logMessage, ...args);
      this.addToHistory('info', logMessage, args);
    }
  }

  // 警告日志
  warn(message, ...args) {
    if (this.shouldLog('warn')) {
      const logMessage = `[WARN] ${new Date().toISOString()} - ${message}`;
      console.warn(logMessage, ...args);
      this.addToHistory('warn', logMessage, args);
    }
  }

  // 错误日志
  error(message, ...args) {
    if (this.shouldLog('error')) {
      const logMessage = `[ERROR] ${new Date().toISOString()} - ${message}`;
      console.error(logMessage, ...args);
      this.addToHistory('error', logMessage, args);
    }
  }

  // 添加日志到历史记录
  addToHistory(level, message, args) {
    this.logHistory.push({
      level,
      message,
      args,
      timestamp: new Date().toISOString()
    });
    
    // 限制历史记录数量
    if (this.logHistory.length > 1000) {
      this.logHistory.shift();
    }
  }

  // 获取日志历史
  getHistory() {
    return [...this.logHistory];
  }

  // 清除日志历史
  clearHistory() {
    this.logHistory = [];
    this.info('日志历史已清除');
  }

  // 导出日志
  exportLogs() {
    const logs = this.logHistory.map(log => {
      const argsString = log.args.length > 0 ? ` - Args: ${JSON.stringify(log.args)}` : '';
      return `${log.timestamp} [${log.level.toUpperCase()}] ${log.message}${argsString}`;
    }).join('\n');

    const blob = new Blob([logs], { type: 'text/plain' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `simulation_log_${new Date().toISOString().replace(/[:.]/g, '-')}.txt`;
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(url);
    
    this.info('日志已导出');
  }

  // 记录性能指标
  performance(name, startTime, endTime) {
    const duration = endTime - startTime;
    this.debug(`${name} 执行时间: ${duration.toFixed(4)}ms`);
    return duration;
  }
}

// 创建单例实例
const logger = new Logger();
export default logger;
