const path = require('path');
const {getDefaultConfig, mergeConfig} = require('@react-native/metro-config');

/**
 * Metro configuration
 * https://reactnative.dev/docs/metro
 *
 * @type {import('metro-config').MetroConfig}
 */
const root = __dirname;
const libraryRoot = path.resolve(root, '..');

const config = {
  watchFolders: [libraryRoot],
  resolver: {
    nodeModulesPaths: [
      path.resolve(root, 'node_modules'),
      path.resolve(libraryRoot, 'node_modules'),
    ],
  },
};

module.exports = mergeConfig(getDefaultConfig(__dirname), config);
