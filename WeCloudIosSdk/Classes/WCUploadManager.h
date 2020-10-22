//
//  WCUploadManager.h
//  WeCloud.cn
//
//  Created by mac on 2020/10/20.
//  Copyright © 2020 mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSString+WeCloud.h"

NS_ASSUME_NONNULL_BEGIN

@interface WCUploadManager : NSObject
+ (instancetype)defaultManager;

//设置accessKey和secretKey（3N7NEPp8CN， qxTpeF5j5aQR）
+ (void)setupWithAccessKey:(NSString*)accessKey secret:(NSString*)secretKey;
//设置默认的空间ID，可以不设置，但在上传时需要添加这个参数
+ (void)setDefaultBucketID:(NSString*)bucketId;

/// 上传文件
/// @param data 文件数据
/// @param fileName 文件名
/// @param mimeType 文件类型
/// @param uploadProgressBlock 进度回调
/// @param completeBlock 完成回调，code=0代表成功;responseObject返回的数据，失败为错误信息
- (nullable NSURLSessionTask*)uploadFileData:(NSData*)data fileName:(NSString*)fileName mimeType:(NSString*)mimeType prgress:(nullable void (^)(NSProgress *uploadProgress))uploadProgressBlock complete:(nullable void (^)(NSInteger code, id _Nullable responseObject))completeBlock;

/**
 带参数的上传文件，parameters可以传以下字段，其他参数参照上面接口
 bucketId 空间Id，必须传值；如果设置了默认空间Id，则可以不设此字段
 customId 用户自定义文件获取Key，获取文件可直接通过该key获取
          该字段必须用户ID下唯一，若为空服务端自动生成
 cover    当customId存在时覆盖原有文件，0表示不覆盖，1表示覆盖
 expired  过期时间，expired < 0 或 expired == null 不过期
                   expired == 0 次日0点过期，
                   expired > 0 指定天数后0点过期
 fileHash 文件哈希值，用于校验文件
 */
- (nullable NSURLSessionTask*)uploadFileData:(NSData*)data fileName:(NSString*)fileName mimeType:(NSString*)mimeType parameters:(nullable NSDictionary*)param prgress:(nullable void (^)(NSProgress *uploadProgress))uploadProgressBlock complete:(nullable void (^)(NSInteger code, id _Nullable responseObject))completeBlock;

/*
 图片上传接口，parameters除了上面的字段，还可以传一个customImageInfo字段，customImageInfo为字典或json字符串，可以包含以下：
 targetFormat 目标格式，jpg、jpeg、gif、bmp、wbmp、png
 width        图片宽度，int，*高度与宽度必须同时有值或为空
 height       图片高度，int，*高度与宽度必须同时有值或为空
 quality      图片质量，float，（0<quality<=1）
 rotate       旋转角度，Double
 scale        图片缩放大小，Double
 如果不需要自定义参数，也可以用普通上传文件的接口
 */
- (nullable NSURLSessionTask*)uploadImgData:(NSData*)data fileName:(NSString*)fileName mimeType:(NSString*)mimeType parameters:(nullable NSDictionary*)param prgress:(nullable void (^)(NSProgress *uploadProgress))uploadProgressBlock complete:(nullable void (^)(NSInteger code, id _Nullable responseObject))completeBlock;

/**
 *快传文件接口，将文件哈希值传到云存储验证是否存在，存在则返回文件信息，不存在需要调用上面接口重新上传
 *param参照上面的
 */
- (nullable NSURLSessionTask*)fastUploadFileData:(NSData*)data fileName:(NSString*)fileName mimeType:(NSString*)mimeType parameters:(nullable NSDictionary*)param  prgress:(nullable void (^)(NSProgress *uploadProgress))uploadProgressBlock complete:(nullable void (^)(NSInteger code, id _Nullable responseObject))completeBlock;

/**
 从上传文件返回的数据中得到文件的地址链接
 */
- (NSString*)getFileUrlFromResponse:(NSDictionary*)response;
/**
 从上传文件返回的数据中得到自定义图片的地址链接
 如果只是想要得到图片原文件，用上面的接口一样可以
 */
- (NSString*)getImageUrlFromResponse:(NSDictionary*)response width:(NSInteger)width height:(NSInteger)height quality:(CGFloat)quality rotate:(CGFloat)rotate scale:(CGFloat)scale;
@end


static inline void RunInMainQueue(dispatch_block_t block){
    if ([NSThread isMainThread]) {
        if (block)
            block();
    } else {
        if (block)
            dispatch_async(dispatch_get_main_queue(), block);
    }
}

NS_ASSUME_NONNULL_END
