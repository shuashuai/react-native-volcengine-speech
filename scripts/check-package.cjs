const { existsSync } = require('node:fs')
const { join } = require('node:path')
const pkg = require('../package.json')

for (const file of [
  pkg.main,
  pkg.types,
  pkg['react-native'],
  'lib/nativeOptions.d.ts',
  'lib/config.js',
  'lib/config.d.ts',
  'scripts/ios-simulator.rb',
  'android/build.gradle',
  'ios/RNVolcengineSpeech.m',
  'react-native-volcengine-speech.podspec',
  'react-native.config.js',
  'README.md',
]) {
  if (!existsSync(join(__dirname, '..', file))) {
    throw new Error(`Missing npm artifact: ${file}`)
  }
}
