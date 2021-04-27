export declare function importAny(...modules: string[]): Promise<any>;
export declare function concat(...arrs: any[]): any[];
/** Paths used by preprocessors to resolve @imports */
export declare function getIncludePaths(fromFilename: string, base?: string[]): string[];
/**
 * Checks if a package is installed.
 *
 * @export
 * @param {string} dep
 * @returns boolean
 */
export declare function hasDepInstalled(dep: string): Promise<boolean>;
export declare function isValidLocalPath(path: string): boolean;
export declare function findUp({ what, from }: {
    what: any;
    from: any;
}): string;
export declare function setProp(obj: any, keyList: any, val: any): void;
