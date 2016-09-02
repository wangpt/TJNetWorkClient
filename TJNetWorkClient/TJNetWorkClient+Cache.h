//
//  TJNetWorkClient+Cache.h
//  TJNetAPIClient
//
//  Created by 王朋涛 on 16/9/1.
//  Copyright © 2016年 王朋涛. All rights reserved.
//

#import "TJNetWorkClient.h"
#define kPath_TJResponseCache @"TJResponseCache"
#define kPath_TJDownFileCache @"TJDownFileCache"

@interface TJNetWorkClient (Cache)
/**
 *  获取fileName的完整地址

 *
 *  @return 缓存文件路径
 */
+ (NSString* )pathInCacheDirectory:(NSString *)fileName;
/**
 *  创建临时缓存目录
 *
 *  @return 是否创建成功
 */
+ (BOOL)createDirInCache:(NSString *)dirName;
/**
 *  获取下载的缓存文件大小
 *
 *  @return 缓存文件大小
 */
+ (NSUInteger)getDownFileCacheSize;
/**
 *  清除下载的缓存文件
 *
 *  @return 是否清除成功
 */
+ (BOOL)deleteDownFileCache;
/**
 *  网络缓存
 *
 *  @return 网路缓存总大小
 */
+ (NSString *)diskCacheSize;
/**
 *  缓存大小
 *
 *  @param otherSize 其它混存比如sdweb大小
 *
 *  @return 包含网络产生的缓存
 */
+ (NSString *)diskCacheSizeWithOtherSize:(NSUInteger)otherSize;
@end
