# TJNetWorkClient的介绍（AFNetWorking 3.1.0封装）

##缓存策略

@property (nonatomic, assign) NSURLRequestCachePolicy cachePolicy;

##数据请求

+ (TJURLSessionTask *)requestWithType:(HttpRequestType)type
                        withUrlString:(NSString *)url
                                cache:(NSURLRequestCachePolicy)cache
                               params:(NSDictionary *)params
                             progress:(void (^)(NSProgress *uploadProgress))progressBlock
                              success:(void(^)(id response))successBlock
                                 fail:(void(^)(NSError *error))failBlock;
##GET请求

- (TJURLSessionTask *)GET:(NSString *)url
                   params:(NSDictionary *)params
                  success:(void(^)(id response))successBlock
                     fail:(void(^)(NSError *error))failBlock;
##POST请求

- (TJURLSessionTask *)POST:(NSString *)url
                    params:(NSDictionary *)params
                   success:(void(^)(id response))successBlock
                      fail:(void(^)(NSError *error))failBlock;
##下载文件

+ (TJURLSessionTask *)download:(NSString *)url
                       fileDir:(NSString *)fileDir
                      progress:(void (^)(NSProgress *downloadProgress))progress
                       success:(void(^)(NSString *url, NSURL *filePath))success
                          fail:(void (^)(NSError *error))failure;
##上传文件

+ (TJURLSessionTask *)upload:(NSString *)url
                      params:(NSDictionary *)params
               withFileArray:(NSArray *)fileArray
                    progress:(void (^)(NSProgress *uploadProgress))progressBlock
                     success:(void(^)(id response))successBlock
                        fail:(void(^)(NSError *error))failBlock;