//
//  TodayViewController.m
//  WidgetTest
//
//  Created by shenzhenshihua on 2018/3/8.
//  Copyright © 2018年 shenzhenshihua. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>
#define Screen_Frame     [[UIScreen mainScreen] bounds]
#define Screen_Width     [[UIScreen mainScreen] bounds].size.width
#define Screen_Height    [[UIScreen mainScreen] bounds].size.height

@interface TodayViewController () <NCWidgetProviding>
@property (weak, nonatomic) IBOutlet UILabel *newsTitle;
@property (weak, nonatomic) IBOutlet UIImageView *icon;
@property (weak, nonatomic) IBOutlet UILabel *newsDate;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLeft;
@property (weak, nonatomic) IBOutlet UIImageView *playIcon;
@property (weak, nonatomic) IBOutlet UIButton *enterBtn;
@property (weak, nonatomic) IBOutlet UILabel *newsDesp;
@property (weak, nonatomic) IBOutlet UILabel *category;
@property (weak, nonatomic) IBOutlet UILabel *readMore;

@property(nonatomic,copy)NSString *linkUrl;
@end

@implementation TodayViewController
/*
 tip：
 1.图片资源不能共享宿主app，因为是两个完全不同的进程。
 2.widget资源有限内存仅能暂用20M，所以只能有简单的操作。
 3.展开 与 折叠 只有ios10以上才可以，所以要对系统版本进行判断。
 4.这个target 也需要设置支持iOS版本。否则
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    [self handleData];
    // Do any additional setup after loading the view from its nib.
}

- (void)initView {
    _icon.layer.cornerRadius = 5;
    _enterBtn.userInteractionEnabled = NO;
    if (@available(iOS 10.0, *)) {
        self.extensionContext.widgetLargestAvailableDisplayMode = NCWidgetDisplayModeExpanded;
    }
//    self.preferredContentSize = CGSizeMake(Screen_Width, 200);
    
}
- (void)handleData {
    [self requestData:@"https://newsapp.mingpao.com/php/api/app_frontpage.php" type:@"data" completion:^(NSDictionary *dict) {
        NSDictionary * fistData = dict[@"data"][@"data_Result"][0];
        [self handleNewsData:fistData];
    }];
}

- (void)handleNewsData:(NSDictionary *)dict {
    NSString * title = dict[@"TITLE"];
    NSString * newsdesp = dict[@"SUMMARY"][@"text"];
    NSString * category = dict[@"CATEGORY"];
    NSString * newsDate = dict[@"PUBDATE"];
    NSString * linkUrl = dict[@"LINK"];
    NSString * imageUrl = nil;
    NSString * newsType = @"textNews";
    
    _linkUrl = linkUrl;
    
    NSArray * mediaArr = dict[@"media:group"];
    if (mediaArr.count) {
        NSDictionary * mediaDict = mediaArr[0];
        NSString * newsTy = mediaDict[@"ATTRIBUTES"][@"MEDIUM"];
        if ([newsTy isEqualToString:@"image"]) {
            newsType = newsTy;
            NSArray * mediaCintent = mediaDict[@"media:content"];
            if (mediaCintent.count > 1) {
                imageUrl = mediaCintent[1][@"ATTRIBUTES"][@"URL"];
            }
        } else if ([newsTy isEqualToString:@"video"]){
            newsType = newsTy;
            NSArray * mediaCintent = mediaDict[@"media:content"];
            if (mediaCintent.count > 1) {
                imageUrl = mediaCintent[1][@"ATTRIBUTES"][@"URL"];
            }
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        _newsTitle.text = title;
        _newsDate.text = newsDate;
        _newsDesp.text = newsdesp;
        _category.text = category;
        _enterBtn.userInteractionEnabled = YES;
        _readMore.hidden = NO;
        
        if ([newsType isEqualToString:@"textNews"]) {
            _titleLeft.constant = -80;
            _icon.hidden = YES;
        } else {
            _icon.hidden = NO;
            //不是纯文字新闻
            _titleLeft.constant = 10;
            if ([newsType isEqualToString:@"image"]) {
                _playIcon.hidden = YES;
            } else if([newsType isEqualToString:@"video"]) {
                _playIcon.hidden = NO;
            }
            if (imageUrl.length) {
//                [self requestData:@"https://fs.mingpao.com/ins/20180308/s00001/30548736e67acf8301e20e51ecb5433c.jpg" type:@"image" completion:^(NSDictionary *dict) {
//                    if (dict[@"data"]) {
//                        dispatch_async(dispatch_get_main_queue(), ^{
//                            UIImage * img = [UIImage imageWithData:dict[@"data"]];
//                            _icon.image = [UIImage imageWithData:dict[@"data"]];
//                            NSLog(@"%@---%@",img,dict);
//                        });
//                    }
//                }];
                [self downloadImage:imageUrl completion:^(NSURL *path) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        _icon.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:path]];
                        //UIImage * image = [UIImage imageNamed:@"play.png"];
                        //_icon.image = image;
                        //NSLog(@"%@--%@",image,path);

                    });
                }];
            }
        }
    });
    
    
}


- (void)requestData:(NSString *)urlString type:(NSString *)type completion:(void(^)(NSDictionary *dict))completion {
    NSURLSession * session = [NSURLSession sharedSession];
    NSURL * url = [NSURL URLWithString:urlString];
    NSMutableURLRequest * request =[NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"GET";
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:postData options:NSJSONWritingPrettyPrinted error:nil];
//    NSString * jsstring =  [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//    request.HTTPBody = [jsstring dataUsingEncoding:NSUTF8StringEncoding];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    NSURLSessionTask * task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            if ([type isEqualToString:@"image"]) {
                if (completion) {
                    completion(@{@"type":type, @"data":data});
                }
            } else {
                NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                if (completion) {
                    completion(@{@"type":type, @"data":dict});
                }
                NSLog(@"%@",dict);
            }

        }
    }];
    [task  resume];
}

- (void)downloadImage:(NSString *)url completion:(void(^)(NSURL *path))completion {
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSString *fileExt = [self fileExtensionForMediaType:@"image"];
    [[session downloadTaskWithURL:[NSURL URLWithString:url] completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        NSLog(@"%@",location);
        if (!error) {
            NSError * error1;
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSURL *localURL = [NSURL fileURLWithPath:[location.path stringByAppendingString:fileExt]];
            [fileManager moveItemAtURL:location toURL:localURL error:&error1];
            if (!error1) {
//                NSLog(@"%@---%@",[NSData dataWithContentsOfURL:localURL],[UIImage imageWithData:[NSData dataWithContentsOfURL:localURL]]);
                if (completion) {
                    completion(localURL);
                }
            }
        }
    }] resume];
    
}
- (NSString *)fileExtensionForMediaType:(NSString *)type {
    NSString *ext = type;
    if ([type isEqualToString:@"image"]) {
        ext = @"jpg";
    }
    if ([type isEqualToString:@"video"]) {
        ext = @"mp4";
    }
    if ([type isEqualToString:@"audio"]) {
        ext = @"mp3";
    }
    return [@"." stringByAppendingString:ext];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)touchAction:(id)sender {
    NSURL * URL = [NSURL URLWithString:[NSString stringWithFormat:@"3DTouch://data=%@",_linkUrl]];
    [self.extensionContext openURL:URL completionHandler:^(BOOL success) {
        NSLog(@"%d",success);
    }];
    NSLog(@"点击了，哈哈哈哈");
}

- (void) widgetActiveDisplayModeDidChange:(NCWidgetDisplayMode)activeDisplayMode withMaximumSize:(CGSize)maxSize {
    NSLog(@"maxWidth %f maxHeight %f",maxSize.width,maxSize.height);
    if (@available(iOS 10.0, *)) {
        if (activeDisplayMode == NCWidgetDisplayModeCompact) {
            //折叠
            self.preferredContentSize = CGSizeMake(maxSize.width, 100);
            //处理一些操作
        } else {
            //展开
            self.preferredContentSize = CGSizeMake(maxSize.width, 200);
            //处理一些操作
        }
    } else {
        // Fallback on earlier versions
    }
}


- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {

    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData

    completionHandler(NCUpdateResultNewData);
}

@end
