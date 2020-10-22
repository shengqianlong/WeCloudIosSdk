//
//  NSString+WeCloud.h
//  WeCloud.cn
//
//  Created by mac on 2020/10/21.
//  Copyright © 2020 mac. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (WeCloud)
///获取md5加密字符串
- (NSString*)wc_MD5String;

///Json字符串转NSDictionary或NSArray
- (id)wc_JSONObject;

///传本地文件路径获取文件的mimeType
+ (NSString *)mimeTypeForFileAtPath:(NSString *)path;

@end

@interface NSDictionary (WeCloud)

///NSDictionary转Json字符串
- (NSString*)wc_JSONString;

@end

@interface NSData (WeCloud)

///获取文件的哈希值
- (NSString*)hashString;

@end

NS_ASSUME_NONNULL_END
