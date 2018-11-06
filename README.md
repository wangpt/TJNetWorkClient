# TJNetWorkClient的介绍
AFNetWorking 3.1.0封装

## 数据请求

+ (TJURLSessionTask *)tj_requestWithType:(HttpRequestType)type
                               urlString:(NSString *)urlString
                              parameters:(_Nullable id)parameters
                                progress:(void (^_Nullable)(NSProgress *uploadProgress))progressBlock
                                 success:(TJHttpRequestSuccess)successBlock
                                    fail:(TJHttpRequestFailed)failBlock;
## 

+ (TJURLSessionTask *)GET:(NSString *)urlString
               parameters:(_Nullable id)parameters
                 progress:(void (^_Nullable)(NSProgress *))progressBlock
                  success:(TJHttpRequestSuccess)successBlock
                     fail:(TJHttpRequestFailed)failBlock;
## 

+ (TJURLSessionTask *)POST:(NSString *)urlString
                parameters:(_Nullable id)parameters
                  progress:(void (^_Nullable)(NSProgress *))progressBlock
                   success:(TJHttpRequestSuccess)successBlock
                      fail:(TJHttpRequestFailed)failBlock;
## 

+ (TJURLSessionTask *)POSTFORM:(NSString *)urlString
                  formDataDict:(NSDictionary * _Nullable)formDataDict
                      progress:(void (^_Nullable)(NSProgress *))progressBlock
                       success:(TJHttpRequestSuccess)successBlock
                          fail:(TJHttpRequestFailed)failBlock;
## 

+ (TJURLSessionTask *)POSTBODY:(NSString *)urlString
                    parameters:(_Nullable id)parameters
                      httpBody:(NSDictionary * _Nullable)httpBody
                uploadProgress:(void (^_Nullable)(NSProgress *uploadProgress))uploadProgressBlock
              downloadProgress:(void (^_Nullable)(NSProgress *uploadProgress))downloadProgressBlock
                       success:(TJHttpRequestSuccess)successBlock
                          fail:(TJHttpRequestFailed)failBlock;
                          
## 

+ (TJURLSessionTask *)PUT:(NSString *)urlString
               parameters:(_Nullable id)parameters
                  success:(TJHttpRequestSuccess)successBlock
                     fail:(TJHttpRequestFailed)failBlock; 
                     
                     
## 

+ (TJURLSessionTask *)DELE:(NSString *)urlString
                parameters:(_Nullable id)parameters
                   success:(TJHttpRequestSuccess)successBlock
                      fail:(TJHttpRequestFailed)failBlock;
##

+ (TJURLSessionTask *)download:(NSString *)url
                       fileDir:(NSString *)fileDir
                      progress:(void (^)(NSProgress *downloadProgress))progressBlock
                       success:(void(^)(NSString *url, NSURL *filePath))successBlock
                          fail:(void (^)(NSError *error))failBlock;
##

+ (TJURLSessionTask *)upload:(NSString *)url
                      params:(NSDictionary *)params
               withFileArray:(NSArray *)fileArray
                    progress:(void (^_Nullable) (NSProgress *uploadProgress))progressBlock
                     success:(void(^)(id response))successBlock
                        fail:(void(^)(NSError *error))failBlock;


                      
                      
                 
                      

