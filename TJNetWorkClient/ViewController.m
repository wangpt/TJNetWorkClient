//
//  ViewController.m
//  TJNetWorkClient
//
//  Created by 王朋涛 on 16/9/2.
//  Copyright © 2016年 王朋涛. All rights reserved.
//

#import "ViewController.h"
#import "TJNetWorkClient+Cache.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [TJNetWorkClient requestWithType:HttpRequestTypeGet withUrlString:@"" cache:0 params:nil progress:^(NSProgress *uploadProgress) {
        NSLog(@"%lld_____%lld",uploadProgress.completedUnitCount,uploadProgress.totalUnitCount);
    } success:^(id response) {
        NSLog(@"success");
    } fail:^(NSError *error) {
        NSLog(@"error");

    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
