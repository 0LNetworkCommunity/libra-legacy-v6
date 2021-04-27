import type { PreprocessorArgs } from '../types';
export declare const getTagInfo: ({ attributes, filename, content, }: PreprocessorArgs) => Promise<{
    filename: string;
    attributes: Record<string, string | boolean>;
    content: string;
    lang: string;
    alias: any;
    dependencies: any[];
}>;
