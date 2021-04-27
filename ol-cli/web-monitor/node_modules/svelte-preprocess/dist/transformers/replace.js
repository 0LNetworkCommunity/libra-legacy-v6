"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.transformer = void 0;
const transformer = async ({ content, options, }) => {
    let newContent = content;
    for (const [regex, replacer] of options) {
        newContent = newContent.replace(regex, replacer);
    }
    return {
        code: newContent,
    };
};
exports.transformer = transformer;
