//
//  TJNetWorkClient+Cache.m
//  TJNetAPIClient
//
//  Created by 王朋涛 on 16/9/1.
//  Copyright © 2016年 王朋涛. All rights reserved.
//

#import "TJNetWorkClient+Cache.h"

@implementation TJNetWorkClient (Cache)
#pragma mark -文件操作

+ (NSString* )pathInCacheDirectory:(NSString *)fileName
{
    NSArray *cachePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = [cachePaths objectAtIndex:0];
    return [cachePath stringByAppendingPathComponent:fileName];
}
+ (BOOL)createDirInCache:(NSString *)dirName
{
    NSString *dirPath = [self pathInCacheDirectory:dirName];
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:dirPath isDirectory:&isDir];
    BOOL isCreated = NO;
    if ( !(isDir == YES && existed == YES) )
    {
        isCreated = [fileManager createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    if (existed) {
        isCreated = YES;
    }
    return isCreated;
}
#pragma mark -清除缓存


+ (BOOL)deleteResponseCache{
    return [self deleteCacheWithPath:kPath_TJResponseCache];
}
+ (NSUInteger)getResponseCacheSize {
    return [self getCacheSizeWithPath:kPath_TJResponseCache];
}

+ (BOOL)deleteDownFileCache{
    return [self deleteCacheWithPath:kPath_TJDownFileCache];
}
+ (NSUInteger)getDownFileCacheSize {
    return [self getCacheSizeWithPath:kPath_TJDownFileCache];
}

+ (BOOL)deleteCacheWithPath:(NSString *)cachePath{
    NSString *dirPath = [self pathInCacheDirectory:cachePath];
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:dirPath isDirectory:&isDir];
    bool isDeleted = false;
    if ( isDir == YES && existed == YES )
    {
        isDeleted = [fileManager removeItemAtPath:dirPath error:nil];
    }
    return isDeleted;
}
+ (NSUInteger)getCacheSizeWithPath:(NSString *)cachePath {
    NSString *dirPath = [self pathInCacheDirectory:cachePath];
    NSUInteger size = 0;
    NSDirectoryEnumerator *fileEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:dirPath];
    for (NSString *fileName in fileEnumerator) {
        NSString *filePath = [dirPath stringByAppendingPathComponent:fileName];
        NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
        size += [attrs fileSize];
    }
    return size;
}
+ (void)deleteAllCacheOnCompletion:(void(^)())completion{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString *cachPath = [ NSSearchPathForDirectoriesInDomains ( NSCachesDirectory , NSUserDomainMask , YES ) objectAtIndex : 0];
        NSArray *files = [[ NSFileManager defaultManager ] subpathsAtPath :cachPath];
        
        for ( NSString *p in files) {
            NSError *error;
            NSString *path = [cachPath stringByAppendingPathComponent :p];
            if ([[ NSFileManager defaultManager ] fileExistsAtPath :path]) {
                [[ NSFileManager defaultManager ] removeItemAtPath :path error :&error];
            }
        }dispatch_async(dispatch_get_main_queue(), ^{
            completion();
        });
    });
    
}
#pragma mark -计算缓存😂
+ (NSString *)diskCacheSize{
    NSUInteger size = [TJNetWorkClient getResponseCacheSize];
    size += [TJNetWorkClient getDownFileCacheSize];
    float tmpSize =size/ 1024.0/ 1024.0;
    NSString *clearCacheName = tmpSize >= 1 ? [NSString stringWithFormat:@"%.2fMB",tmpSize] : [NSString stringWithFormat:@"%.2fKB",tmpSize * 1024];
    return clearCacheName;

}
+ (NSString *)diskCacheSizeWithOtherSize:(NSUInteger)otherSize{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    NSUInteger size = [TJNetWorkClient getResponseCacheSize];
    size += [TJNetWorkClient getDownFileCacheSize];
    size += otherSize;
    float tmpSize =size/ 1024.0/ 1024.0;
    NSString *clearCacheName = tmpSize >= 1 ? [NSString stringWithFormat:@"%.2fMB",tmpSize] : [NSString stringWithFormat:@"%.2fKB",tmpSize * 1024];
    return clearCacheName;
}

@end
