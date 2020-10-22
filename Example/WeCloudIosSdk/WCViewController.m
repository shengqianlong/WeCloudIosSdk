//
//  WCViewController.m
//  WeCloudIosSdk
//
//  Created by chenhw on 10/21/2020.
//  Copyright (c) 2020 chenhw. All rights reserved.
//

#import "WCViewController.h"
#import <WeCloudIosSdk/WCUploadManager.h>
@interface WCViewController ()

@property (nonatomic, weak) IBOutlet UILabel *logLabel;

@property (nonatomic, strong) NSDictionary *lastUploadResult;

@end

@implementation WCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [WCUploadManager setupWithAccessKey:@"3N7NEPp8CN" secret:@"qxTpeF5j5aQR"];
    [WCUploadManager setDefaultBucketID:@"1318444965537394690"];
}

- (IBAction)clickToUpload:(id)sender {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"123" ofType:@"png"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSString *mimeType = [NSString mimeTypeForFileAtPath:path];
    __weak typeof(self) ws = self;
//    [[WCUploadManager defaultManager] uploadFileData:data fileName:@"123.png" mimeType:mimeType prgress:^(NSProgress * _Nonnull uploadProgress) {
//        NSLog(@"%lld--%lld", uploadProgress.completedUnitCount, uploadProgress.totalUnitCount);
//    } complete:^(NSInteger code, id  _Nullable responseObject) {
//        NSLog(@"%@", responseObject);
//        /*
//             bucketId = 1318444965537394690;
//             createTime = 1603258334972;
//             expiredTime = 2145888000000;
//             fileFormat = "image/png";
//             fileName = "123.png";
//             folderId = 1318444965545783298;
//             id = 1318787157858631682;
//             modifyTime = 1603258334972;
//             status = 1;
//             userId = 1318439042056077314;
//         */
//    }];
//    [[WCUploadManager defaultManager] uploadFileData:data fileName:@"123.png" mimeType:mimeType parameters:@{@"customId":@"1111111.png",@"cover":@(1)} prgress:^(NSProgress * _Nonnull uploadProgress) {
//        NSLog(@"%lld--%lld", uploadProgress.completedUnitCount, uploadProgress.totalUnitCount);
//    } complete:^(NSInteger code, id  _Nullable responseObject) {
//        NSLog(@"%@", responseObject);
//        ws.lastUploadResult = responseObject;
//        RunInMainQueue(^{
//            [ws showResponse];
//        });
//        /*
//         bucketId = 1318444965537394690;
//         createTime = 1603272423547;
//         customId = "1111111.png";
//         expiredTime = 2145888000000;
//         fileFormat = "image/png";
//         fileName = "123.png";
//         folderId = 1318444965545783298;
//         id = 1318846249625108482;
//         modifyTime = 1603272423547;
//         status = 1;
//         userId = 1318439042056077314;
//         */
//    }];
    [[WCUploadManager defaultManager] fastUploadFileData:data fileName:@"123.png" mimeType:mimeType parameters:nil prgress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"%lld--%lld", uploadProgress.completedUnitCount, uploadProgress.totalUnitCount);
    } complete:^(NSInteger code, id  _Nullable responseObject) {
        NSLog(@"%@", responseObject);
        ws.lastUploadResult = responseObject;
        RunInMainQueue(^{
            [ws showResponse];
        });
    }];
}

- (IBAction)clickCoplyLink:(id)sender {
    NSString *string = [[WCUploadManager defaultManager] getFileUrlFromResponse:self.lastUploadResult];
    [[UIPasteboard generalPasteboard] setString:string];
}

- (void)showResponse {
    NSString *string = [[WCUploadManager defaultManager] getFileUrlFromResponse:self.lastUploadResult];
    NSString *log = [NSString stringWithFormat:@"%@\n上传后的文件路径：%@", self.lastUploadResult, string];
    self.logLabel.text = log;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
