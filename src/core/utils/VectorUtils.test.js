import VectorUtils from './VectorUtils';

describe('VectorUtils', () => {
  describe('norm', () => {
    it('should return 0 for zero vector', () => {
      expect(VectorUtils.norm([0, 0, 0])).toBe(0);
    });

    it('should return correct magnitude for 3D vector', () => {
      expect(VectorUtils.norm([3, 4, 0])).toBe(5);
      expect(VectorUtils.norm([1, 1, 1])).toBe(Math.sqrt(3));
    });
  });

  describe('normalize', () => {
    it('should return [1, 0, 0] for zero vector', () => {
      expect(VectorUtils.normalize([0, 0, 0])).toEqual([1, 0, 0]);
    });

    it('should normalize 3D vector correctly', () => {
      const result = VectorUtils.normalize([3, 4, 0]);
      expect(VectorUtils.norm(result)).toBeCloseTo(1);
      expect(result).toEqual([0.6, 0.8, 0]);
    });
  });

  describe('dot', () => {
    it('should return correct dot product', () => {
      expect(VectorUtils.dot([1, 0, 0], [0, 1, 0])).toBe(0);
      expect(VectorUtils.dot([1, 2, 3], [4, 5, 6])).toBe(32);
    });
  });

  describe('cross', () => {
    it('should return correct cross product', () => {
      expect(VectorUtils.cross([1, 0, 0], [0, 1, 0])).toEqual([0, 0, 1]);
      expect(VectorUtils.cross([0, 1, 0], [1, 0, 0])).toEqual([0, 0, -1]);
    });
  });

  describe('add', () => {
    it('should return correct vector sum', () => {
      expect(VectorUtils.add([1, 2, 3], [4, 5, 6])).toEqual([5, 7, 9]);
    });
  });

  describe('subtract', () => {
    it('should return correct vector difference', () => {
      expect(VectorUtils.subtract([4, 5, 6], [1, 2, 3])).toEqual([3, 3, 3]);
    });
  });

  describe('multiply', () => {
    it('should return correct scalar multiplication', () => {
      expect(VectorUtils.multiply([1, 2, 3], 2)).toEqual([2, 4, 6]);
    });
  });

  describe('limit', () => {
    it('should not change vector if magnitude is less than max', () => {
      expect(VectorUtils.limit([1, 0, 0], 2)).toEqual([1, 0, 0]);
    });

    it('should limit vector magnitude to max', () => {
      const result = VectorUtils.limit([3, 4, 0], 3);
      expect(VectorUtils.norm(result)).toBe(3);
      // 使用toBeCloseTo处理浮点数精度问题
      expect(result[0]).toBeCloseTo(1.8);
      expect(result[1]).toBeCloseTo(2.4);
      expect(result[2]).toBe(0);
    });
  });
});