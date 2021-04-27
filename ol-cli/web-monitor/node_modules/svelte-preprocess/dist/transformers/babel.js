"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.transformer = void 0;
const core_1 = require("@babel/core");
const transformer = async ({ content, filename, options, map = undefined, }) => {
    const babelOptions = {
        ...options,
        inputSourceMap: typeof map === 'string' ? JSON.parse(map) : map !== null && map !== void 0 ? map : undefined,
        sourceType: 'module',
        // istanbul ignore next
        sourceMaps: !!options.sourceMaps,
        filename,
        minified: false,
        ast: false,
        code: true,
    };
    const { code, map: sourcemap } = await core_1.transformAsync(content, babelOptions);
    return {
        code,
        map: sourcemap,
    };
};
exports.transformer = transformer;
