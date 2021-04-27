import type { Transformer, Preprocessor } from '../types';
export declare function transformMarkup({ content, filename }: {
    content: string;
    filename: string;
}, transformer: Preprocessor | Transformer<unknown>, options?: Record<string, any>): Promise<import("svelte/types/compiler/preprocess").Processed>;
