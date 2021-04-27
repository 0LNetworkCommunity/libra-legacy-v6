"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.transformMarkup = void 0;
async function transformMarkup({ content, filename }, transformer, options = {}) {
    let { markupTagName = 'template' } = options;
    markupTagName = markupTagName.toLocaleLowerCase();
    const markupPattern = new RegExp(`/<!--[^]*?-->|<${markupTagName}(\\s[^]*?)?(?:>([^]*?)<\\/${markupTagName}>|\\/>)`);
    const templateMatch = content.match(markupPattern);
    /** If no <template> was found, run the transformer over the whole thing */
    if (!templateMatch) {
        return transformer({ content, attributes: {}, filename, options });
    }
    const [fullMatch, attributesStr = '', templateCode] = templateMatch;
    /** Transform an attribute string into a key-value object */
    const attributes = attributesStr
        .split(/\s+/)
        .filter(Boolean)
        .reduce((acc, attr) => {
        const [name, value] = attr.split('=');
        // istanbul ignore next
        acc[name] = value ? value.replace(/['"]/g, '') : true;
        return acc;
    }, {});
    /** Transform the found template code */
    let { code, map, dependencies } = await transformer({
        content: templateCode,
        attributes,
        filename,
        options,
    });
    code =
        content.slice(0, templateMatch.index) +
            code +
            content.slice(templateMatch.index + fullMatch.length);
    return { code, map, dependencies };
}
exports.transformMarkup = transformMarkup;
