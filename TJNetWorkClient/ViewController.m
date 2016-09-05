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
    TJNetWorkClient *client=[[TJNetWorkClient alloc]init];
    [client GET:@"http://c.m.163.com//nc/article/headline/T1348647853363/0-20.html"
         params:nil
        success:^(id response) {
            NSLog(@"%@",response);
        } fail:^(NSError *error) {
            NSLog(@"%@",error.localizedDescription);
        }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
