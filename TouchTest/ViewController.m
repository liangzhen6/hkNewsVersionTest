//
//  ViewController.m
//  TouchTest
//
//  Created by shenzhenshihua on 2018/3/12.
//  Copyright © 2018年 shenzhenshihua. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSString * url = @"alipay://ge";
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:url]]) {
        if (@available(iOS 10.0, *)) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url] options:@{} completionHandler:^(BOOL success) {
                NSLog(@"%d----",success);
            }];
        } else {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
            // Fallback on earlier versions
        }
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
