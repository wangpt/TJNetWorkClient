//
//  TJNetWorkClient.m
//  TJNetAPIClient
//
//  Created by 王朋涛 on 16/8/31.
//  Copyright © 2016年 王朋涛. All rights reserved.
//

#import "TJNetWorkClient.h"
#import "TJNetWorkClient+Cache.h"
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

static NSTimeInterval   requestTimeout = 20.f;

@implementation TJNetWorkClient

+ (instancetype)sharedClient{
    return [[self class] alloc];
}

-(AFHTTPSessionManager *)manager{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //缓存设置
    manager.requestSerializer.cachePolicy = _cachePolicy?:NSURLRequestUseProtocolCachePolicy;
    //超时设置
    [manager.requestSerializer setTimeoutInterval:requestTimeout];
    //header 设置
    manager.securityPolicy     = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    //设置请求内容的类型
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    //设置请求的编码类型
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain", @"text/html",@"application/javascript",@"application/json", nil];//接收的类型可以不写
    // 设置请求格式
    //    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    // 设置返回格式
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    
    return manager;
}
#pragma mark - 网络请求集合

+ (TJURLSessionTask *)requestWithType:(HttpRequestType)type withUrlString:(NSString *)url
                                cache:(NSURLRequestCachePolicy)cache
                               params:(NSDictionary *)params
                        progress:(void (^)(NSProgress *uploadProgress))progressBlock
                         success:(void(^)(id response))successBlock
                            fail:(void(^)(NSError *error))failBlock{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
   TJNetWorkClient *manager= [self sharedClient];
    if (type == HttpRequestTypeGet) {
        manager.cachePolicy=cache;
        return [manager GET:url params:params progress:progressBlock success:successBlock fail:failBlock];

    }else{
        return [manager POST:url params:params progress:progressBlock success:successBlock fail:failBlock];

    }
}
#pragma mark - 网络请求GET
- (TJURLSessionTask *)GET:(NSString *)url params:(NSDictionary *)params success:(void (^)(id))successBlock fail:(void (^)(NSError *))failBlock{
    return [self GET:url params:params progress:nil success:successBlock fail:failBlock];
}

- (TJURLSessionTask *)GET:(NSString *)url
                   params:(NSDictionary *)params
                 progress:(void (^)(NSProgress *uploadProgress))progressBlock
                  success:(void(^)(id response))successBlock
                     fail:(void(^)(NSError *error))failBlock{
    AFHTTPSessionManager *manager = [self manager];
    return  [manager GET:url parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        progressBlock ? progressBlock(uploadProgress) : nil;
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        successBlock(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        failBlock(error);
    }];


}
#pragma mark - 网络请求POST
- (TJURLSessionTask *)POST:(NSString *)url params:(NSDictionary *)params success:(void (^)(id))successBlock fail:(void (^)(NSError *))failBlock{
    return [self POST:url params:params progress:nil success:successBlock fail:failBlock];
}

- (TJURLSessionTask *)POST:(NSString *)url
                    params:(NSDictionary *)params
                  progress:(void (^)(NSProgress *uploadProgress))progressBlock
                   success:(void(^)(id response))successBlock
                      fail:(void(^)(NSError *error))failBlock{
    AFHTTPSessionManager *manager = [self manager];
   return  [manager POST:url parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
       progressBlock ? progressBlock(uploadProgress) : nil;
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

        successBlock(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

        failBlock(error);
    }];
}

#pragma mark - 文件下载

+ (TJURLSessionTask *)download:(NSString *)url
                       fileDir:(NSString *)fileDir
                      progress:(void (^)(NSProgress *downloadProgress))progressBlock
                       success:(void(^)(NSString *url, NSURL *filePath))successBlock
                       fail:(void (^)(NSError *error))failBlock{

   
    AFHTTPSessionManager *manager = [[self sharedClient] manager];
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] progress:^(NSProgress * _Nonnull downloadProgress) {
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
            failBlock ? failBlock(error) : nil;

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
    AFHTTPSessionManager *manager = [[self sharedClient] manager];
    return [manager POST:url parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        [fileArray enumerateObjectsUsingBlock:^(TJFileModel *  _Nonnull model, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *name=[NSString stringWithFormat:@"uploadFile%d",(int)idx];//服务器用于区分
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
        failBlock ? failBlock(error) : nil;
    }];
}

@end
