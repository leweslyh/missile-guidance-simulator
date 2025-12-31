// 核心类型定义

export interface Vector3D {
  [index: number]: number;
  0: number;
  1: number;
  2: number;
}

export interface MissileState {
  position: Vector3D;
  velocity: Vector3D;
  acceleration: Vector3D;
  attitude: Vector3D;
  speed: number;
}

export interface TargetState {
  position: Vector3D;
  velocity: Vector3D;
  acceleration: Vector3D;
}

export interface RelativeMotion {
  relativePosition: Vector3D;
  relativeVelocity: Vector3D;
  losVector: Vector3D;
  losRate: Vector3D;
  closingVelocity: number;
  timeToGo: number;
  relativeDistance: number;
}

export interface GuidanceParams {
  N?: number;
  [key: string]: any;
}

export interface SimulationParams {
  dt: number;
  maxTime: number;
  missDistanceThreshold: number;
  minMissileSpeed: number;
}

export interface MissileParams {
  position: Vector3D;
  velocity: Vector3D;
  maxAcceleration: number;
  minVelocity: number;
  mass?: number;
  thrust?: number;
  dragCoefficient?: number;
}

export interface TargetParams {
  position: Vector3D;
  velocity: Vector3D;
  motionType: string;
  motionParams?: any;
}

export interface GuidanceParams {
  lawType: string;
  params: GuidanceParams;
  customCode?: string;
}

export interface SimulationResult {
  terminated: boolean;
  reason: string;
  time: number;
  missDistance: number;
  missileState: MissileState;
  targetState: TargetState;
}

export interface SimulationData {
  time: number[];
  missilePosition: [number[], number[], number[]];
  targetPosition: [number[], number[], number[]];
  missileVelocity: [number[], number[], number[]];
  targetVelocity: [number[], number[], number[]];
  missileAcceleration: [number[], number[], number[]];
  relativeDistance: number[];
  closingVelocity: number[];
}
