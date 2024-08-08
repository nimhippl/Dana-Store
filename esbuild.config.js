const esbuild = require('esbuild');
const cssModulesPlugin = require('esbuild-css-modules-plugin');

esbuild.build({
    entryPoints: ['app/javascript/packs/order.js'],
    bundle: true,
    sourcemap: true,
    format: 'esm',
    outdir: 'app/assets/builds',
    publicPath: '/assets',
    watch: process.argv.includes('--watch'),
    platform: 'browser',
    plugins: [
    cssModulesPlugin()
    ],
}).catch(() => process.exit(1));