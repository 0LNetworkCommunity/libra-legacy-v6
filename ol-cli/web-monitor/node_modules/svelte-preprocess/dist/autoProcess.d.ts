import type { PreprocessorGroup, Processed, TransformerArgs, TransformerOptions, Options } from './types';
declare type AutoPreprocessGroup = PreprocessorGroup & {
    defaultLanguages: Readonly<{
        markup: string;
        style: string;
        script: string;
    }>;
};
declare type AutoPreprocessOptions = {
    markupTagName?: string;
    aliases?: Array<[string, string]>;
    preserve?: string[];
    defaults?: {
        markup?: string;
        style?: string;
        script?: string;
    };
    sourceMap?: boolean;
    babel?: TransformerOptions<Options.Babel>;
    typescript?: TransformerOptions<Options.Typescript>;
    scss?: TransformerOptions<Options.Sass>;
    sass?: TransformerOptions<Options.Sass>;
    less?: TransformerOptions<Options.Less>;
    stylus?: TransformerOptions<Options.Stylus>;
    postcss?: TransformerOptions<Options.Postcss>;
    coffeescript?: TransformerOptions<Options.Coffeescript>;
    pug?: TransformerOptions<Options.Pug>;
    globalStyle?: Options.GlobalStyle | boolean;
    replace?: Options.Replace;
    [languageName: string]: TransformerOptions;
};
export declare const transform: (name: string, options: TransformerOptions, { content, map, filename, attributes }: TransformerArgs<any>) => Promise<Processed>;
export declare function sveltePreprocess({ aliases, markupTagName, preserve, defaults, sourceMap, ...rest }?: AutoPreprocessOptions): AutoPreprocessGroup;
export {};
