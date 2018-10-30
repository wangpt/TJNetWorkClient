//
//  TJNetWorkClientTests.m
//  TJNetWorkClientTests
//
//  Created by tao on 2018/10/29.
//  Copyright © 2018 tao. All rights reserved.
//  添加${SRCROOT}并设置成recursive

#import <XCTest/XCTest.h>
#import "TJNetWorkClient.h"
static NSString * const url = @"http://c.m.163.com/nc/video/home/1-10.html";
static NSString * const url1 = @"http://c.m.163.com//nc/article/headline/T1348647853363/0-20.html";

@interface TJNetWorkClientTests : XCTestCase

@end

@implementation TJNetWorkClientTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testNetWorkState {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    [TJNetWorkClient tj_startNetWorkMonitoringWithBlock:^(TJNetworkStatus status) {
        NSLog(@"%lu",(unsigned long)status);
        if ([TJNetWorkClient tj_IsNetwork]) {
            NSLog(@"目前有网络");
        }
        if ([TJNetWorkClient tj_IsWWANNetwork]) {
            NSLog(@"目前为蜂窝");
        }
        if ([TJNetWorkClient tj_IsWiFiNetwork]) {
            NSLog(@"目前为wifi");
        }
    }];
}

- (void)testNetWorkGet{
    [TJNetWorkClient openLog];
    [TJNetWorkClient requestWithType:HttpRequestTypeGet urlString:url parameters:nil progress:nil success:^(TJURLSessionTask * _Nonnull task, id  _Nonnull responseObject) {
        NSLog(@"%@",responseObject);
    } fail:^(TJURLSessionTask * _Nonnull task, NSError * _Nonnull error) {
        
    }];
}


- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
