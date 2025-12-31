export default {
  testEnvironment: 'jsdom',
  transform: {
    '^.+\\.(js|jsx)$': 'babel-jest'
  },
  moduleNameMapping: {
    '^@/(.*)$': '<rootDir>/src/$1'
  },
  testMatch: [
    '<rootDir>/src/**/*.test.(js|jsx)',
    '<rootDir>/tests/**/*.test.(js|jsx)'
  ],
  transformIgnorePatterns: [
    '/node_modules/'
  ],
  collectCoverage: true,
  coverageDirectory: 'coverage',
  coverageReporters: ['text', 'html']
};