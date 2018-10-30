//
//  TJNetWorkClient.m
//  TJNetAPIClient
//
//  Created by 王朋涛 on 16/8/31.
//  Copyright © 2016年 王朋涛. All rights reserved.
//

#import "TJNetWorkClient.h"
#import "TJNetWorkClient+Cache.h"
#import "AFNetworking.h"
NSString *const TJRequestValidationErrorDomain = @"com.tjzl.request.validation";

@interface TJNetWorkClient ()
@end

@implementation TJNetWorkClient
static AFHTTPSessionManager *_sessionManager;
static NSTimeInterval requestTimeout = 30.f;
static NSMutableArray *_allSessionTask;
static BOOL _isOpenLog;   // 是否已开启日志打印
#pragma mark - init
+ (void)initialize {
    _sessionManager = [AFHTTPSessionManager manager];
    //超时设置
    _sessionManager.requestSerializer.timeoutInterval = requestTimeout;
    //设置请求的编码类型
    _sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html", @"text/json", @"text/plain", @"text/javascript", @"text/xml", @"image/*", nil];
    // 设置请求格式
    _sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
    // 设置返回格式
    _sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
    //header 设置
    _sessionManager.securityPolicy     = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    //设置请求内容的类型
    [_sessionManager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
}
/**
 存储着所有的请求task数组
 */
+ (NSMutableArray *)allSessionTask {
    if (!_allSessionTask) {
        _allSessionTask = [[NSMutableArray alloc] init];
    }
    return _allSessionTask;
}

+ (void)cancelAllRequest {
    // 锁操作
    @synchronized(self) {
        [_allSessionTask enumerateObjectsUsingBlock:^(NSURLSessionTask  *_Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
            [task cancel];
        }];
        [_allSessionTask removeAllObjects];
    }
}

+ (void)cancelRequestWithURL:(NSString *)URL {
    if (!URL) { return; }
    @synchronized (self) {
        [_allSessionTask enumerateObjectsUsingBlock:^(NSURLSessionTask  *_Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([task.currentRequest.URL.absoluteString hasPrefix:URL]) {
                [task cancel];
                [_allSessionTask removeObject:task];
                *stop = YES;
            }
        }];
    }
}
#pragma mark - 打印
+ (void)openLog {
    _isOpenLog = YES;
}

+ (void)closeLog {
    _isOpenLog = NO;
}

#pragma mark - 开始监听网络
+ (BOOL)tj_IsNetwork {
    return [AFNetworkReachabilityManager sharedManager].reachable;
}

+ (BOOL)tj_IsWWANNetwork {
    return [AFNetworkReachabilityManager sharedManager].reachableViaWWAN;
}

+ (BOOL)tj_IsWiFiNetwork {
    return [AFNetworkReachabilityManager sharedManager].reachableViaWiFi;
}

+ (void)tj_startNetWorkMonitoringWithBlock:(TJNetworkStatusBlock)networkStatus
{
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status)
        {
            case AFNetworkReachabilityStatusUnknown:
                networkStatus ? networkStatus(TJNetworkStatusUnknown) : nil;
                if (_isOpenLog) NSLog(@"未知网络");
                break;
            case AFNetworkReachabilityStatusNotReachable:
                networkStatus ? networkStatus(TJNetworkStatusNotReachable) : nil;
                if (_isOpenLog) NSLog(@"没有网络");
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                networkStatus ? networkStatus(TJNetworkStatusReachableViaWWAN) : nil;
                if (_isOpenLog) NSLog(@"手机自带网络");
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                networkStatus ? networkStatus(TJNetworkStatusReachableViaWiFi) : nil;
                if (_isOpenLog) NSLog(@"WIFI");
                break;
        }
    }];
    [manager startMonitoring];
}


#pragma mark - helper
- (NSString*)dictionaryToJson:(NSDictionary *)dic{
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}
+ (BOOL)validateResult:(TJURLSessionTask *)task responseObject:(id)responseObject error:(NSError * _Nullable __autoreleasing *)error {
    NSHTTPURLResponse *request = (NSHTTPURLResponse *)task.response;
    NSInteger statusCode = request.statusCode;
    if (statusCode>=200 &&statusCode <= 299) {
        return YES;
    }
    return NO;
}

+ (NSError *)errorResult:(TJURLSessionTask *)request{
    NSString * message = @"网络罢工了";
    NSInteger code = TJRequestValidationErrorInvalidNoNetWork;
    if (![TJNetWorkClient tj_IsNetwork]) {
        message = @"网络罢工了";//服务器连接超时
        code = TJRequestValidationErrorInvalidNetWorkTimeOut;
    }
    NSError* vaildateError = [NSError errorWithDomain:TJRequestValidationErrorDomain code:code userInfo:@{NSLocalizedDescriptionKey:message}];
    return vaildateError;
}

#pragma mark - 网络请求集合
+ (TJURLSessionTask *)requestWithType:(HttpRequestType)type
                                   urlString:(NSString *)urlString
                                  parameters:(id)parameters
                                    progress:(void (^)(NSProgress *uploadProgress))progressBlock
                                     success:(void(^)(TJURLSessionTask *task,id response))successBlock
                                        fail:(void(^)(TJURLSessionTask *task,NSError *error))failBlock{
    if (type == HttpRequestTypeGet) {
        return [self GET:urlString parameters:parameters progress:progressBlock success:successBlock fail:failBlock];
    }else if (type == HttpRequestTypePost){
        return [self POST:urlString parameters:parameters progress:progressBlock success:successBlock fail:failBlock];
    }else{
        return [self GET:urlString parameters:parameters progress:progressBlock success:successBlock fail:failBlock];
    }
}

#pragma mark - Get
+ (TJURLSessionTask *)GET:(NSString *)urlString
               parameters:(id)parameters
                 progress:(void (^)(NSProgress * _Nonnull))progressBlock
                  success:(TJHttpRequestSuccess)successBlock
                  fail:(TJHttpRequestFailed)failBlock{
    NSURLSessionTask *sessionTask = [_sessionManager GET:urlString parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        progressBlock? progressBlock(uploadProgress):nil;
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (_isOpenLog) {NSLog(@"responseObject = %@",responseObject);}
        dispatch_async(dispatch_get_main_queue(), ^{
            [[self allSessionTask] removeObject:task];
            if ([self validateResult:task responseObject:responseObject error:nil]) {
                successBlock? successBlock(task,responseObject):nil;
            }else{
                NSError * tempError = [self errorResult:task];
                failBlock? failBlock(task,tempError):nil;
            }
        });
    } failure:^(NSURLSessionDataTask * _Nullable dataTask, NSError * _Nonnull dataError) {
        if (_isOpenLog) {NSLog(@"error = %@",dataError);}
        dispatch_async(dispatch_get_main_queue(), ^{
            [[self allSessionTask] removeObject:dataTask];
            NSError * tempError = [self errorResult:dataTask];
            failBlock? failBlock(dataTask,tempError):nil;
        });
    }];
    // 添加sessionTask到数组
    sessionTask ? [[self allSessionTask] addObject:sessionTask] : nil ;
    return sessionTask;
}

#pragma mark - Post
+ (TJURLSessionTask *)POST:(NSString *)urlString
                parameters:(id)parameters
                  progress:(void (^)(NSProgress *uploadProgress))progressBlock
                   success:(void(^)(TJURLSessionTask *task,id response))successBlock
                      fail:(void(^)(TJURLSessionTask *task,NSError *error))failBlock{
    return  [_sessionManager POST:urlString parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        progressBlock ? progressBlock(uploadProgress) : nil;
    } success:^(NSURLSessionDataTask * _Nonnull dataTask, id  _Nullable dataResponseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (_isOpenLog) {NSLog(@"responseObject = %@",dataResponseObject);}
            [[self allSessionTask] removeObject:dataTask];
            if ([self validateResult:dataTask responseObject:dataResponseObject error:nil]) {
                successBlock? successBlock(dataTask,dataResponseObject):nil;
            }else{
                NSError * tempError = [self errorResult:dataTask];
                failBlock? failBlock(dataTask,tempError):nil;
            }
        });
    } failure:^(NSURLSessionDataTask * _Nullable dataTask, NSError * _Nonnull dataError) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (_isOpenLog) {NSLog(@"error = %@",dataError);}
            [[self allSessionTask] removeObject:dataTask];
            NSError * tempError = [self errorResult:dataTask];
            failBlock? failBlock(dataTask,tempError):nil;
        });
        
    }];
}

#pragma mark - 文件下载
+ (TJURLSessionTask *)download:(NSString *)url
                       fileDir:(NSString *)fileDir
                      progress:(void (^)(NSProgress *downloadProgress))progressBlock
                       success:(void(^)(NSString *url, NSURL *filePath))successBlock
                       fail:(void (^)(NSError *error))failBlock{
   
    NSURLSessionDownloadTask *downloadTask = [_sessionManager downloadTaskWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] progress:^(NSProgress * _Nonnull downloadProgress) {
        //下载进度
        progressBlock ? progressBlock(downloadProgress) : nil;
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        NSString *downloadDir=[self pathInCacheDirectory:fileDir?:kPath_TJDownFileCache];
        //创建Download目录
        [self createDirInCache:fileDir?:kPath_TJDownFileCache];
        //拼接文件路径
        NSString *filePath = [downloadDir stringByAppendingPathComponent:response.suggestedFilename];
        //返回文件位置的URL路径
        return [NSURL fileURLWithPath:filePath];
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        if (error) {
            NSError * tempError = [self errorResult:nil];
            failBlock? failBlock(tempError):nil;
        }else{
            successBlock ? successBlock(url,filePath /** NSURL->NSString*/) : nil;
        }
    }];
    //开始下载
    [downloadTask resume];
    return downloadTask;

}

#pragma mark - 文件上传
+ (TJURLSessionTask *)upload:(NSString *)url
                      params:(NSDictionary *)params
               withFileArray:(NSArray *)fileArray
                    progress:(void (^)(NSProgress *uploadProgress))progressBlock
                     success:(void(^)(id response))successBlock
                        fail:(void(^)(NSError *error))failBlock{
    return [_sessionManager POST:url parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [fileArray enumerateObjectsUsingBlock:^(TJFileModel *  _Nonnull model, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *name=[NSString stringWithFormat:@"file"];//服务器用于区分
            NSString *fileName=[NSString stringWithFormat:@"%@%@",name,[TJFileModel fileNameSuffixesWithFileType:model.fileType]];//服务器存储的文件名字
            NSString *mimeType =[TJFileModel mimeTypeWithFileType:model.fileType];//服务器判断类型
            switch (model.fileType) {
                case FileRequestTypePic:
                    if (model.fileData) {
                        [formData appendPartWithFileData:model.fileData name:name fileName:fileName mimeType:mimeType];
                    }else{
                        [formData appendPartWithFileURL:[NSURL fileURLWithPath:model.fileUrl] name:name fileName:fileName mimeType:mimeType error:NULL];
                    }
                    break;
                case FileRequestTypeVideo:
                    if (model.fileData) {
                        [formData appendPartWithFileData:model.fileData name:name fileName:fileName mimeType:mimeType];
                        
                    }else{
                        [formData appendPartWithFileURL:[NSURL fileURLWithPath:model.fileUrl] name:name fileName:fileName mimeType:mimeType error:NULL];
                    }
                    break;
                case FileRequestTypeVoice:
                    if (model.fileData) {
                        [formData appendPartWithFileData:model.fileData name:name fileName:fileName mimeType:mimeType];
                        
                    }else{
                        [formData appendPartWithFileURL:[NSURL fileURLWithPath:model.fileUrl] name:name fileName:fileName mimeType:mimeType error:NULL];
                    }
            }
        }];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        //上传进度
        progressBlock ? progressBlock(uploadProgress) : nil;
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        successBlock(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        NSError * tempError = [self errorResult:nil];
        failBlock? failBlock(tempError):nil;
    }];
}

#pragma mark - 网络请求Postform
- (TJURLSessionTask *)postForm:(NSString*)url
                         params:(NSDictionary *)params
                       success:(void(^)(TJURLSessionTask *  response,id responseObject))successBlock
                          fail:(void(^)(TJURLSessionTask *  response,NSError *error))failBlock{
    return [_sessionManager POST:url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        for (NSString *key in [params keyEnumerator])
        {
            NSData* xmlData = [[params valueForKey:key] dataUsingEncoding:NSUTF8StringEncoding];
            [formData appendPartWithFormData:xmlData name:key];
        }
    } progress:^(NSProgress * _Nonnull uploadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
//        successBlock(task,responseObject);
        [self responseSuccessDataTask:task responseObject:responseObject success:successBlock fail:failBlock];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        failBlock(task,error);
    }];
}


#pragma mark - 网络请求DELE
- (TJURLSessionTask *)DELE:(NSString *)url
                    params:(NSDictionary *)params
                   success:(void(^)(TJURLSessionTask *task,id response))successBlock
                      fail:(void(^)(TJURLSessionTask *task,NSError *error))failBlock
{
    
    return [self DELE:url params:params progress:nil success:successBlock fail:failBlock];

    
}
- (TJURLSessionTask *)DELE:(NSString *)url
                    params:(NSDictionary *)params
                  progress:(void (^)(NSProgress *uploadProgress))progressBlock
                   success:(void(^)(TJURLSessionTask *task,id response))successBlock
                      fail:(void(^)(TJURLSessionTask *task,NSError *error))failBlock{
   return  [_sessionManager DELETE:url parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
       [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
       [self responseSuccessDataTask:task responseObject:responseObject success:successBlock fail:failBlock];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        failBlock(task,error);
    }];
}
#pragma mark - 网络请求PUT
- (TJURLSessionTask *)PUT:(NSString *)url
                   params:(NSDictionary *)params
                  success:(void(^)(TJURLSessionTask *task,id response))successBlock
                     fail:(void(^)(TJURLSessionTask *task,NSError *error))failBlock{
    return [self PUT:url params:params progress:nil success:successBlock fail:failBlock];

}
- (TJURLSessionTask *)PUT:(NSString *)url
                    params:(NSDictionary *)params
                  progress:(void (^)(NSProgress *uploadProgress))progressBlock
                   success:(void(^)(TJURLSessionTask *task,id response))successBlock
                      fail:(void(^)(TJURLSessionTask *task,NSError *error))failBlock{
    return  [_sessionManager PUT:url parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [self responseSuccessDataTask:task responseObject:responseObject success:successBlock fail:failBlock];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        failBlock(task,error);
    }];
    
}

#pragma mark - request success
- (void)responseSuccessDataTask:(TJURLSessionTask *)task
                 responseObject:(id)responseObject
                        success:(void(^)(TJURLSessionTask *task,id response))successBlock
                           fail:(void(^)(TJURLSessionTask *task,NSError *error))failBlock{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
    if (httpResponse.statusCode == 200) {
        if ([responseObject isKindOfClass:[NSArray class]]) {
            successBlock(task,responseObject);
        }else{
            NSDictionary *respongseDic = responseObject;
            int code =  ((NSNumber *)[respongseDic objectForKey:@"rc"]).intValue;
            if (code == 200 || code == 0) {//在注册和登录时进行保存token
                successBlock(task,responseObject);
            }else{
            }
        }
    }else{
        successBlock(task,responseObject);
    }
}


#pragma mark - 网络请求body
- (TJURLSessionTask *)postBody:(NSString*)url
                    parameters:(NSDictionary *)parameters
                      bodyForm:(NSDictionary *)bodyForm
                       success:(void(^)(NSURLResponse *  response,id responseObject))successBlock
                          fail:(void(^)(NSURLResponse *  response,NSError *error))failBlock{
    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:url parameters:parameters error:nil];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//    NSString *token =  [TJNetWorkClient getToken];
//    if (token.length > 0) {
//        [request addValue:token forHTTPHeaderField:@"authorization"];
//    }
    if (bodyForm) {
        NSString *param = [self dictionaryToJson:bodyForm];
        NSData *body  =[param dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:body];
    }
    NSURLSessionDataTask *task =[_sessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (!error) {
            successBlock(response,responseObject);
        } else {
            failBlock(response,error);
            
        }
    }] ;
    [task resume];
    return task;
}

- (TJURLSessionTask *)getBody:(NSString*)url
                   parameters:(NSDictionary *)parameters
                        bodyForm:(NSDictionary *)bodyForm
                      success:(void(^)(NSURLResponse *  response,id responseObject))successBlock
                         fail:(void(^)(NSURLResponse *  response,NSError *error))failBlock{
    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"GET" URLString:url parameters:parameters error:nil];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//    NSString *token = [TJNetWorkClient getToken];
//    [request addValue:token forHTTPHeaderField:@"authorization"];
    if (bodyForm) {
        NSString *param = [self dictionaryToJson:bodyForm];
        NSData *body  =[param dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:body];
    }

    NSURLSessionDataTask *task =[_sessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (!error) {
            successBlock(response,responseObject);
            
        } else {
            failBlock(response,error);
        }
    }] ;
    [task resume];
    return task;
}


@end

@implementation TJFileModel

+ (NSString *)mimeTypeWithFileType:(FileRequestType)fileType{
    if (fileType==FileRequestTypePic) {
        return @"image/jpeg";
    }else if (fileType==FileRequestTypeVideo){
        return @"video/quicktime";
    }else{
        return @"audio/aac";
    }
}
+ (NSString *)fileNameSuffixesWithFileType:(FileRequestType)fileType{
    if (fileType==FileRequestTypePic) {
        return @".jpg";
    }else if (fileType==FileRequestTypeVideo){
        return @".mov";
    }else{
        return @".dll";
    }
}

@end
