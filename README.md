# we-cloud-ios-sdk

[![CI Status](https://img.shields.io/travis/chenhw/WeCloudIosSdk.svg?style=flat)](https://travis-ci.org/chenhw/WeCloudIosSdk)
[![Version](https://img.shields.io/cocoapods/v/WeCloudIosSdk.svg?style=flat)](https://cocoapods.org/pods/WeCloudIosSdk)
[![License](https://img.shields.io/cocoapods/l/WeCloudIosSdk.svg?style=flat)](https://cocoapods.org/pods/WeCloudIosSdk)
[![Platform](https://img.shields.io/cocoapods/p/WeCloudIosSdk.svg?style=flat)](https://cocoapods.org/pods/WeCloudIosSdk)

## Example

示例代码：
#import <WCUploadManager.h>
NSString *path = [[NSBundle mainBundle] pathForResource:@"123" ofType:@"png"];
NSData *data = [NSData dataWithContentsOfFile:path];
NSString *mimeType = [NSString mimeTypeForFileAtPath:path];
__weak typeof(self) ws = self;
[[WCUploadManager defaultManager] uploadFileData:data fileName:@"123.png" mimeType:mimeType prgress:^(NSProgress * _Nonnull uploadProgress) {
    NSLog(@"%lld--%lld", uploadProgress.completedUnitCount, uploadProgress.totalUnitCount);
} complete:^(NSInteger code, id  _Nullable responseObject) {
    NSLog(@"%@", responseObject);
}];
从responseObject中获取上传的文件地址：
[[WCUploadManager defaultManager] getFileUrlFromResponse:responseObject];

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements
ios 10.0以上sdk，AFNetworking 3.X

## Installation

WeCloudIosSdk is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'WeCloudIosSdk'
```

## Author

chenhw, 406399537@qq.com

## License

WeCloudIosSdk is available under the MIT license. See the LICENSE file for more info.
