//
//  WCUploadManager.m
//  WeCloud.cn
//
//  Created by mac on 2020/10/20.
//  Copyright © 2020 mac. All rights reserved.
//

#import "WCUploadManager.h"
#import <AFNetworking/AFNetworking.h>

#define WeCloudHostUrl  @"https://api.wecloud.cn:10007/file/"

@interface WCUploadManager()

@property (nonatomic, strong) AFHTTPSessionManager *operationManager;
@property (nonatomic, strong) dispatch_queue_t completionQueue;

@property (nonatomic, copy) NSString *accessKey;
@property (nonatomic, copy) NSString *secretKey;
@property (nonatomic, copy) NSString *bucketId;

@end

@implementation WCUploadManager
+ (instancetype)defaultManager {
    static WCUploadManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[WCUploadManager alloc] init];
    });
    return manager;
}

+ (void)setupWithAccessKey:(NSString*)accessKey secret:(NSString*)secretKey{
    [WCUploadManager defaultManager].accessKey = accessKey;
    [WCUploadManager defaultManager].secretKey = secretKey;
}

+ (void)setDefaultBucketID:(NSString*)bucketId {
    [WCUploadManager defaultManager].bucketId = bucketId;
}

- (nullable NSURLSessionTask*)uploadFileData:(NSData*)data fileName:(NSString*)fileName mimeType:(NSString*)mimeType prgress:(nullable void (^)(NSProgress *uploadProgress))uploadProgressBlock complete:(nullable void (^)(NSInteger code, id _Nullable responseObject))completeBlock {
    return [self uploadFileData:data fileName:fileName mimeType:mimeType parameters:nil prgress:uploadProgressBlock complete:completeBlock];
}

- (nullable NSURLSessionTask*)uploadFileData:(NSData*)data fileName:(NSString*)fileName mimeType:(NSString*)mimeType parameters:(nullable NSDictionary*)param prgress:(nullable void (^)(NSProgress *uploadProgress))uploadProgressBlock complete:(nullable void (^)(NSInteger code, id _Nullable responseObject))completeBlock {
    NSDictionary *realParam = [self getRealParam:param fileName:fileName dataLength:data.length];
    if (!realParam)
        return nil;
    NSString *url = [WeCloudHostUrl stringByAppendingString:@"uploadSingleFile"];
    [self.operationManager.requestSerializer setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];
    NSURLSessionTask *task = [self.operationManager POST:url parameters:realParam constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileData:data name:@"file" fileName:fileName mimeType:mimeType];
    } progress:uploadProgressBlock success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (completeBlock) {
            NSDictionary *object;
            if ([responseObject isKindOfClass:[NSData class]]) {
                object = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
            } else if ([responseObject isKindOfClass:[NSDictionary class]]){
                object =responseObject;
            } else {
                //返回格式错误，一般不会存在
                completeBlock(-1, responseObject);
                return;
            }
            NSInteger code = [[object objectForKey:@"code"] integerValue];
            if (code == 0) {
                //成功返回数据
                completeBlock(0, [object objectForKey:@"data"]);
            } else {
                //失败返回错误信息
                completeBlock(code, [object objectForKey:@"msg"]);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (completeBlock) {
            completeBlock(-1, error.userInfo);
        }
    }];
    return task;
}

- (nullable NSURLSessionTask*)uploadImgData:(NSData*)data fileName:(NSString*)fileName mimeType:(NSString*)mimeType parameters:(nullable NSDictionary*)param prgress:(nullable void (^)(NSProgress *uploadProgress))uploadProgressBlock complete:(nullable void (^)(NSInteger code, id _Nullable responseObject))completeBlock {
    NSDictionary *realParam = [self getRealParam:param fileName:fileName dataLength:data.length];
    if (!realParam)
        return nil;
    NSString *url = [WeCloudHostUrl stringByAppendingString:@"uploadImageFile"];
    [self.operationManager.requestSerializer setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];
    NSURLSessionTask *task = [self.operationManager POST:url parameters:realParam constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileData:data name:@"file" fileName:fileName mimeType:mimeType];
    } progress:uploadProgressBlock success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (completeBlock) {
            NSDictionary *object;
            if ([responseObject isKindOfClass:[NSData class]]) {
                object = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
            } else if ([responseObject isKindOfClass:[NSDictionary class]]){
                object =responseObject;
            } else {
                //返回格式错误，一般不会存在
                completeBlock(-1, responseObject);
                return;
            }
            NSInteger code = [[object objectForKey:@"code"] integerValue];
            if (code == 0) {
                //成功返回数据
                completeBlock(0, [object objectForKey:@"data"]);
            } else {
                //失败返回错误信息
                completeBlock(code, [object objectForKey:@"msg"]);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (completeBlock) {
            completeBlock(-1, error.userInfo);
        }
    }];
    return task;
}

- (nullable NSURLSessionTask*)fastUploadFileData:(NSData*)data fileName:(NSString*)fileName mimeType:(NSString*)mimeType parameters:(nullable NSDictionary*)param prgress:(nullable void (^)(NSProgress *uploadProgress))uploadProgressBlock complete:(nullable void (^)(NSInteger code, id _Nullable responseObject))completeBlock {
    if (![param objectForKey:@"fileHash"]) {
        NSMutableDictionary *p = [NSMutableDictionary dictionaryWithDictionary:param];
        NSString *hash = [data hashString];
        [p setObject:hash forKey:@"fileHash"];
        [p setObject:mimeType forKey:@"mimeType"];
        [p setObject:fileName forKey:@"fileName"];
        [p setObject:@(data.length) forKey:@"fileSize"];
        param = p;
    }
    NSDictionary *realParam = [self getRealParam:param fileName:fileName dataLength:data.length];
    if (!realParam)
        return nil;
    NSString *url = [WeCloudHostUrl stringByAppendingString:@"fastUpload"];
    [self.operationManager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSURLSessionTask *task = [self.operationManager POST:url parameters:realParam progress:uploadProgressBlock success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (completeBlock) {
            NSDictionary *object;
            if ([responseObject isKindOfClass:[NSData class]]) {
                object = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
            } else if ([responseObject isKindOfClass:[NSDictionary class]]){
                object =responseObject;
            } else {
                //返回格式错误，一般不会存在
                completeBlock(-1, responseObject);
                return;
            }
            NSInteger code = [[object objectForKey:@"code"] integerValue];
            if (code == 0) {
                //成功返回数据
                completeBlock(0, [object objectForKey:@"data"]);
            } else {
                //失败返回错误信息
                completeBlock(code, [object objectForKey:@"msg"]);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (completeBlock) {
            completeBlock(-1, error.userInfo);
        }
    }];
    return task;
}

- (NSString*)getFileUrlFromResponse:(NSDictionary*)response {
    NSString *sourceId = [response objectForKey:@"id"];
    NSString *customId = [response objectForKey:@"customId"];
    NSString *realId = customId ? customId : sourceId;
    NSString *bucketId = [response objectForKey:@"bucketId"];
    NSString *originalSign = [NSString stringWithFormat:@"%@.%@.%@", self.secretKey, realId, bucketId];
    
    NSString *downloadToken = [NSString stringWithFormat:@"%@.%@", self.accessKey, [originalSign wc_MD5String]];
    
    NSString *fileUrlString = [NSString stringWithFormat:@"%@download", WeCloudHostUrl];
    
    fileUrlString = [fileUrlString stringByAppendingFormat:@"?bucketId=%@",bucketId];
    
    if (customId) {
        fileUrlString = [fileUrlString stringByAppendingFormat:@"&customId=%@",customId];
    } else {
        fileUrlString = [fileUrlString stringByAppendingFormat:@"&userFileId=%@",sourceId];
    }
    fileUrlString = [fileUrlString stringByAppendingFormat:@"&downloadToken=%@",downloadToken];
    
    return fileUrlString;
}

- (NSString*)getImageUrlFromResponse:(NSDictionary*)response width:(NSInteger)width height:(NSInteger)height quality:(CGFloat)quality rotate:(CGFloat)rotate scale:(CGFloat)scale {
    NSString *sourceId = [response objectForKey:@"id"];
    NSString *customId = [response objectForKey:@"customId"];
    NSString *realId = customId ? customId : sourceId;
    NSString *bucketId = [response objectForKey:@"bucketId"];
    NSString *originalSign = [NSString stringWithFormat:@"%@.%@.%@", self.secretKey, realId, bucketId];
    
    NSString *downloadToken = [NSString stringWithFormat:@"%@.%@", self.accessKey, [originalSign wc_MD5String]];
    
    NSString *fileUrlString = [NSString stringWithFormat:@"%@getCustomImage", WeCloudHostUrl];
    
    fileUrlString = [fileUrlString stringByAppendingFormat:@"?bucketId=%@",bucketId];
    
    if (customId) {
        fileUrlString = [fileUrlString stringByAppendingFormat:@"&customId=%@",customId];
    } else {
        fileUrlString = [fileUrlString stringByAppendingFormat:@"&userFileId=%@",sourceId];
    }
    fileUrlString = [fileUrlString stringByAppendingFormat:@"&downloadToken=%@",downloadToken];
    
    if (width > 0 && height > 0) {
        fileUrlString = [fileUrlString stringByAppendingFormat:@"&width=%ld&height=%ld", (long)width, (long)height];
    }
    if (quality > 0 && quality < 1) {
        fileUrlString = [fileUrlString stringByAppendingFormat:@"&quality=%f", quality];
    }
    if (rotate != 0) {
        fileUrlString = [fileUrlString stringByAppendingFormat:@"&rotate=%f", rotate];
    }
    if (scale != 0) {
        fileUrlString = [fileUrlString stringByAppendingFormat:@"&scale=%f", scale];
    }
    return fileUrlString;
}

- (AFHTTPSessionManager *)operationManager {
    if (!_operationManager) {
        _operationManager = [AFHTTPSessionManager manager];
        _operationManager.requestSerializer = [AFJSONRequestSerializer serializer];
        _operationManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        _completionQueue = dispatch_queue_create("WCUpload_Queue", DISPATCH_QUEUE_CONCURRENT);
        _operationManager.completionQueue = _completionQueue;
        _operationManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/plain", @"text/json", @"text/javascript",@"text/html",@"application/x-protobuf", @"application/octet-stream", nil];
        _operationManager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        [_operationManager.requestSerializer setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];
    }
    return _operationManager;
}

- (nullable NSDictionary*)getRealParam:(nullable NSDictionary*)param fileName:(NSString*)fileName dataLength:(NSInteger)length{
    if (self.accessKey.length == 0) {
        NSLog(@"WeCloudSDK: 请先设置accessKey");
        return nil;
    }
    if (self.secretKey.length == 0) {
        NSLog(@"WeCloudSDK: 请先设置secretKey");
        return nil;
    }
    NSString *bucketId = [param objectForKey:@"bucketId"];
    if (bucketId.length == 0) {
        bucketId = self.bucketId;
    }
    if (bucketId.length == 0)
        return nil;
    NSMutableDictionary *retParam = [NSMutableDictionary dictionaryWithCapacity:0];
    if (param)
        [retParam setDictionary:param];
    NSString *originalSign = [NSString stringWithFormat:@"%@.%@", self.secretKey, bucketId];
    if ([param objectForKey:@"customId"]) {
        originalSign = [originalSign stringByAppendingFormat:@".%@", [param objectForKey:@"customId"]];
    }
    if ([param objectForKey:@"expired"]) {
        originalSign = [originalSign stringByAppendingFormat:@".%@", [param objectForKey:@"expired"]];
    }
    originalSign = [originalSign stringByAppendingFormat:@".%@", fileName];
    originalSign = [originalSign stringByAppendingFormat:@".%ld", (long)length];
    if ([param objectForKey:@"mimeType"]) {
        originalSign = [originalSign stringByAppendingFormat:@".%@", [param objectForKey:@"mimeType"]];
    }
    if ([param objectForKey:@"fileHash"]) {
        originalSign = [originalSign stringByAppendingFormat:@".%@", [param objectForKey:@"fileHash"]];
    }
    NSString *customImageInfoString = nil;
    if ([param objectForKey:@"customImageInfo"]) {
        id customImageInfo = [param objectForKey:@"customImageInfo"];
        if ([customImageInfo isKindOfClass:[NSDictionary class]]) {
            customImageInfoString = [(NSDictionary*)customImageInfo wc_JSONString];
        } else if ([customImageInfo isKindOfClass:[NSString class]]) {
            customImageInfoString = customImageInfo;
        }
        if (customImageInfoString)
            originalSign = [originalSign stringByAppendingFormat:@".%@", customImageInfoString];
    }
    
    NSString *uploadToken = [NSString stringWithFormat:@"%@.%@", self.accessKey, [originalSign wc_MD5String]];
    [retParam setObject:uploadToken forKey:@"uploadToken"];
    [retParam setObject:bucketId forKey:@"bucketId"];
    if (customImageInfoString) {
        [retParam setObject:customImageInfoString forKey:@"customImageInfo"];
    }
    return retParam;
}

@end
