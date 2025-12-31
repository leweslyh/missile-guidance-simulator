// 向量工具类 - 统一管理向量运算
class VectorUtils {
  // 计算向量的模长
  static norm(vector) {
    return Math.sqrt(vector.reduce((sum, val) => sum + val * val, 0));
  }

  // 向量归一化
  static normalize(vector) {
    const mag = this.norm(vector);
    if (mag < 1e-6) return [1, 0, 0];
    return vector.map(val => val / mag);
  }

  // 向量点积
  static dot(v1, v2) {
    return v1.reduce((sum, val, i) => sum + val * v2[i], 0);
  }

  // 向量叉积
  static cross(v1, v2) {
    return [
      v1[1] * v2[2] - v1[2] * v2[1],
      v1[2] * v2[0] - v1[0] * v2[2],
      v1[0] * v2[1] - v1[1] * v2[0]
    ];
  }

  // 向量加法
  static add(v1, v2) {
    return v1.map((val, i) => val + v2[i]);
  }

  // 向量减法
  static subtract(v1, v2) {
    return v1.map((val, i) => val - v2[i]);
  }

  // 向量数乘
  static multiply(vector, scalar) {
    return vector.map(val => val * scalar);
  }

  // 限制向量大小
  static limit(vector, max) {
    const mag = this.norm(vector);
    if (mag <= max) return vector;
    return this.normalize(vector).map(val => val * max);
  }

  // 计算向量间夹角（弧度）
  static angleBetween(v1, v2) {
    const dotProduct = this.dot(v1, v2);
    const magProduct = this.norm(v1) * this.norm(v2);
    if (magProduct < 1e-6) return 0;
    const cosTheta = Math.min(1, Math.max(-1, dotProduct / magProduct));
    return Math.acos(cosTheta);
  }

  // 投影向量v1到向量v2
  static project(v1, v2) {
    const v2Norm = this.normalize(v2);
    const dotProduct = this.dot(v1, v2Norm);
    return this.multiply(v2Norm, dotProduct);
  }

  // 向量旋转（绕z轴）
  static rotateZ(vector, angle) {
    const [x, y, z] = vector;
    const cos = Math.cos(angle);
    const sin = Math.sin(angle);
    return [
      x * cos - y * sin,
      x * sin + y * cos,
      z
    ];
  }
}

export default VectorUtils;