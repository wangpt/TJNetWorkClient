# TJNetWorkClient
# AFNetWorking 3.1.0封装
##  缓存策略
@property (nonatomic, assign) NSURLRequestCachePolicy cachePolicy;//缓存策略

#数据请求封装
##带进度回调的请求
/**
*
*  @param url              请求路径
*  @param cache            缓存策略
*  @param params           拼接参数
*  @param progressBlock    进度回调
*  @param successBlock     成功回调
*  @param failBlock        失败回调
*
*  @return 返回的对象中可取消请求
*/

+ (TJURLSessionTask *)requestWithType:(HttpRequestType)type
                        withUrlString:(NSString *)url
                                cache:(NSURLRequestCachePolicy)cache
                               params:(NSDictionary *)params
                             progress:(void (^)(NSProgress *uploadProgress))progressBlock
                              success:(void(^)(id response))successBlock
                                 fail:(void(^)(NSError *error))failBlock;
##GET请求
/**
*
*  @param url              请求路径
*  @param params           拼接参数
*  @param successBlock     成功回调
*  @param failBlock        失败回调
*
*  @return 返回的对象中可取消请求
*/
- (TJURLSessionTask *)GET:(NSString *)url
                   params:(NSDictionary *)params
                  success:(void(^)(id response))successBlock
                     fail:(void(^)(NSError *error))failBlock;
##POST请求
/**
*
*  @param url              请求路径
*  @param params           拼接参数
*  @param successBlock     成功回调
*  @param failBlock        失败回调
*
*  @return 返回的对象中可取消请求
*/
- (TJURLSessionTask *)POST:(NSString *)url
                    params:(NSDictionary *)params
                   success:(void(^)(id response))successBlock
                      fail:(void(^)(NSError *error))failBlock;
##下载文件

/**
*
*  @param url      请求地址
*  @param fileDir  文件存储目录(默认存储目录为Download)
*  @param progress 文件下载的进度信息
*  @param success  下载成功的回调(回调参数filePath:文件的路径)
*  @param failure  下载失败的回调
*
*  @return 返回NSURLSessionDownloadTask实例，可用于暂停继续，暂停调用suspend方法，开始下载调用resume方法
*/
+ (TJURLSessionTask *)download:(NSString *)url
                       fileDir:(NSString *)fileDir
                      progress:(void (^)(NSProgress *downloadProgress))progress
                       success:(void(^)(NSString *url, NSURL *filePath))success
                          fail:(void (^)(NSError *error))failure;
##上传文件

/**
*
*  @param url      请求地址
*  @param params   拼接参数
*  @param progress 文件的进度信息
*  @param success  下载成功的回调(回调参数filePath:文件的路径)
*  @param failure  下载失败的回调
*
*  @return 返回的对象可取消请求,调用cancle方法
*/

+ (TJURLSessionTask *)upload:(NSString *)url
                      params:(NSDictionary *)params
               withFileArray:(NSArray *)fileArray
                    progress:(void (^)(NSProgress *uploadProgress))progressBlock
                     success:(void(^)(id response))successBlock
                        fail:(void(^)(NSError *error))failBlock;