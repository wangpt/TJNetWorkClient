//
//  TJNetWorkClient.h
//  TJNetAPIClient
//
//  Created by 王朋涛 on 16/8/31.
//  Copyright © 2016年 王朋涛. All rights reserved.
//
#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const TJRequestValidationErrorDomain;
typedef NS_ENUM(NSUInteger, TJNetworkStatus) {
    /** 未知网络*/
    TJNetworkStatusUnknown,
    /** 无网络*/
    TJNetworkStatusNotReachable,
    /** 手机网络*/
    TJNetworkStatusReachableViaWWAN,
    /** WIFI网络*/
    TJNetworkStatusReachableViaWiFi
};

/**定义请求类型的枚举*/
typedef NS_ENUM(NSUInteger, HttpRequestType)
{
    HttpRequestTypeGet = 0,
    HttpRequestTypePost = 1,
    HttpRequestTypePut = 2,
    HttpRequestTypeDele = 3,
};


typedef NS_ENUM(NSInteger,TJRequestValidationType)
{
    TJRequestValidationErrorInvalidNoNetWork = -10000,
    TJRequestValidationErrorInvalidNetWorkTimeOut = -10001,
};

typedef NS_ENUM(NSUInteger,FileRequestType)
{
    FileRequestTypePic = 0,
    FileRequestTypeVideo=1,//视频类型
    FileRequestTypeVoice=2,//音频类型
};

/**
 *  请求任务
 */
typedef NSURLSessionTask TJURLSessionTask;
/**
 *  网络状态
 */
typedef void(^TJNetworkStatusBlock)(TJNetworkStatus status);
/**
 *  请求成功的Block
 */
typedef void(^TJHttpRequestSuccess)(TJURLSessionTask *task,id responseObject);
/**
 *  请求失败的Block
 */
typedef void(^TJHttpRequestFailed)(TJURLSessionTask *task,NSError *error);

@interface TJFileModel : NSObject
@property (nonatomic, strong) NSString * fileUrl;//地址
@property (nonatomic, strong) NSData * fileData;//数据
@property (nonatomic, assign) FileRequestType fileType;//类型
/**
 *  上传服务器类型
 *
 *  @param fileType 文件类型
 *
 *  @return 上传服务器类型  @"image/jpeg"等
 */
+ (NSString *)mimeTypeWithFileType:(FileRequestType)fileType;
/**
 *  上传服务器类型
 *
 *  @param fileType 文件类型
 *
 *  @return 上传服务器类型  .png等
 */
+ (NSString *)fileNameSuffixesWithFileType:(FileRequestType)fileType;

@end


@interface TJNetWorkClient : NSObject
/**
 *  开启打印
 */
+ (void)openLog;
/**
 *  关闭打印
 */
+ (void)closeLog;
/**
 *  是否无网络
 */
+ (BOOL)tj_IsNetwork;
/**
 *  是否蜂窝网
 */
+ (BOOL)tj_IsWWANNetwork;
/**
 *  是否WIFI
 */
+ (BOOL)tj_IsWiFiNetwork;
/**
 *  开始检测网络
 */
+ (void)tj_startNetWorkMonitoringWithBlock:(TJNetworkStatusBlock)networkStatus;
/**
 *  请求
 *
 *  @param type             请求类型
 *  @param urlString        请求路径
 *  @param parameters       拼接参数
 *  @param progressBlock    进度回调
 *  @param successBlock     成功回调
 *  @param failBlock        失败回调
 *
 *  @return 返回的对象中可取消请求
 */

/**
 *  请求
 *
 *  @param type             请求类型
 *  @param urlString        请求路径
 *  @param parameters       拼接参数
 *  @param progressBlock    进度回调
 *  @param successBlock     成功回调
 *  @param failBlock        失败回调
 *
 *  @return 返回的对象中可取消请求
 */
+ (TJURLSessionTask *)tj_requestWithType:(HttpRequestType)type
                               urlString:(NSString *)urlString
                              parameters:(_Nullable id)parameters
                                progress:(void (^_Nullable)(NSProgress *uploadProgress))progressBlock
                                 success:(TJHttpRequestSuccess)successBlock
                                    fail:(TJHttpRequestFailed)failBlock;

/**
 *  Get请求
 *
 *  @param urlString        请求路径
 *  @param parameters       拼接参数
 *  @param progressBlock    进度回调
 *  @param successBlock     成功回调
 *  @param failBlock        失败回调
 *
 *  @return 返回的对象中可取消请求
 */

+ (TJURLSessionTask *)GET:(NSString *)urlString
               parameters:(_Nullable id)parameters
                 progress:(void (^_Nullable)(NSProgress *))progressBlock
                  success:(TJHttpRequestSuccess)successBlock
                     fail:(TJHttpRequestFailed)failBlock;

/**
 *  POST请求
 *
 *  @param urlString        请求路径
 *  @param parameters       拼接参数
 *  @param progressBlock    进度回调
 *  @param successBlock     成功回调
 *  @param failBlock        失败回调
 *
 *  @return 返回的对象中可取消请求
 */
+ (TJURLSessionTask *)POST:(NSString *)urlString
                parameters:(_Nullable id)parameters
                  progress:(void (^_Nullable)(NSProgress *))progressBlock
                   success:(TJHttpRequestSuccess)successBlock
                      fail:(TJHttpRequestFailed)failBlock;
/**
 *  POSTFORM请求(上传文件)
 *
 *  @param urlString        请求路径
 *  @param formDataDict     拼接参数
 *  @param progressBlock    进度回调
 *  @param successBlock     成功回调
 *  @param failBlock        失败回调
 *
 *  @return 返回的对象中可取消请求
 */
+ (TJURLSessionTask *)POSTFORM:(NSString *)urlString
                  formDataDict:(NSDictionary * _Nullable)formDataDict
                      progress:(void (^_Nullable)(NSProgress *))progressBlock
                       success:(TJHttpRequestSuccess)successBlock
                          fail:(TJHttpRequestFailed)failBlock;

/**
 *  POSTBODY请求(httpBody头)
 *
 *  @param urlString                请求路径
 *  @param parameters               拼接参数
 *  @param httpBody                 httpBody
 *  @param uploadProgressBlock      进度回调
 *  @param downloadProgressBlock    进度回调
 *  @param successBlock             成功回调
 *  @param failBlock                失败回调
 *
 *  @return 返回的对象中可取消请求
 */
+ (TJURLSessionTask *)POSTBODY:(NSString *)urlString
                    parameters:(_Nullable id)parameters
                      httpBody:(NSDictionary * _Nullable)httpBody
                uploadProgress:(void (^_Nullable)(NSProgress *uploadProgress))uploadProgressBlock
              downloadProgress:(void (^_Nullable)(NSProgress *uploadProgress))downloadProgressBlock
                       success:(TJHttpRequestSuccess)successBlock
                          fail:(TJHttpRequestFailed)failBlock;

/**
 *  PUT请求
 *
 *  @param urlString        请求路径
 *  @param parameters       拼接参数
 *  @param successBlock     成功回调
 *  @param failBlock        失败回调
 *
 *  @return 返回的对象中可取消请求
 */
+ (TJURLSessionTask *)PUT:(NSString *)urlString
               parameters:(_Nullable id)parameters
                  success:(TJHttpRequestSuccess)successBlock
                     fail:(TJHttpRequestFailed)failBlock;
/**
 *  DELE请求
 *
 *  @param urlString        请求路径
 *  @param parameters       拼接参数
 *  @param successBlock     成功回调
 *  @param failBlock        失败回调
 *
 *  @return 返回的对象中可取消请求
 */
+ (TJURLSessionTask *)DELE:(NSString *)urlString
                parameters:(_Nullable id)parameters
                   success:(TJHttpRequestSuccess)successBlock
                      fail:(TJHttpRequestFailed)failBlock;

/**
 *  上传文件
 *
 *  @param url      请求地址
 *  @param params   拼接参数
 *  @param progressBlock 文件的进度信息
 *  @param successBlock  下载成功的回调(回调参数filePath:文件的路径)
 *  @param failBlock  下载失败的回调
 *
 *  @return 返回的对象可取消请求,调用cancle方法
 */

+ (TJURLSessionTask *)upload:(NSString *)url
                      params:(NSDictionary *)params
               withFileArray:(NSArray *)fileArray
                    progress:(void (^_Nullable) (NSProgress *uploadProgress))progressBlock
                     success:(void(^)(id response))successBlock
                        fail:(void(^)(NSError *error))failBlock;

/**
 *  下载文件
 *
 *  @param url           请求地址
 *  @param fileDir       文件存储目录(默认存储目录为Download)
 *  @param progressBlock 文件下载的进度信息
 *  @param successBlock  下载成功的回调(回调参数filePath:文件的路径)
 *  @param failBlock     下载失败的回调
 *
 *  @return 返回NSURLSessionDownloadTask实例，可用于暂停继续，暂停调用suspend方法，开始下载调用resume方法
 */
+ (TJURLSessionTask *)download:(NSString *)url
                       fileDir:(NSString *)fileDir
                      progress:(void (^)(NSProgress *downloadProgress))progressBlock
                       success:(void(^)(NSString *url, NSURL *filePath))successBlock
                          fail:(void (^)(NSError *error))failBlock;


@end
NS_ASSUME_NONNULL_END
