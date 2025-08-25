module.exports = {
  testEnvironment: 'node',
  reporters: [
    'default',
    ['jest-junit', {
      outputDirectory: 'test-reports',
      outputName: 'test-results.xml'
    }]
  ]
};
