//
//  Delay_Functions_VC.m
//  MyTools
//
//  Created by 郑冰津 on 16/8/29.
//  Copyright © 2016年 IceGod. All rights reserved.
//

#import "Time_Functions_VC.h"
#import "MyToolsHeader.h"
#import <objc/message.h>
#import "RACTestView.h"

@interface Time_Functions_VC ()

@end

@implementation Time_Functions_VC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title= @"RAC中的delay函数";
    arrayVClass = @[@"delay函数的使用等",@"delay请求超时",@"定时器"].mutableCopy;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *selString = @[@"delay_Function_BaseUse",@"delay_Function_Request",@"delay_Function_Timer"][indexPath.row];
    SEL gcdSEL = NSSelectorFromString(selString);
    if ([self respondsToSelector:gcdSEL]) {
        ((void (*)(id self, SEL))objc_msgSend)(self, gcdSEL);
    }
}

- (void)delay_Function_BaseUse{
    ///最基础的延时操作
    RACSignal *dalaySignal = [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSLog(@"开始发送数据");
        [subscriber sendNext:@"3秒钟之后发送的数据"];
        [subscriber sendCompleted];
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"%s已经释放",__func__);
        }];
    }] delay:3];
    NSLog(@"调用函数延迟3秒");
    [dalaySignal subscribeNext:^(id x) {
        NSLog(@"订阅结果:%@-->%@",x,[NSThread currentThread]);
    }];
    [[RACScheduler mainThreadScheduler] afterDelay:5.0f schedule:^{
        NSLog(@"5秒之后才执行的延时方法:%@",[NSThread currentThread]);
    }];
}

- (void)delay_Function_Request{
    ///请求超时
    RACSignal *signalTimeOut = [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        //修改afterDelay后面的秒数测试结果
        [[RACScheduler mainThreadScheduler] afterDelay:5.0f schedule:^{
            NSLog(@"###开始发送数据");
            [subscriber sendNext:@"数据返回正确"];
            [subscriber sendCompleted];
        }];
        return nil;
        /// 然后timeout就是当超过这个时间的时候就会出错
    }] timeout:4.0f onScheduler:[RACScheduler mainThreadScheduler]];

    [signalTimeOut subscribeNext:^(id x) {
        NSLog(@"###正确信息:%@",x);
    } error:^(NSError *error) {
        ///一般情况下,发送了错误信息,都会释放信号的
        NSLog(@"###错误信息:%@",error);
    } completed:^{
        NSLog(@"###请求超时测试结束");
    }];
}


- (void)delay_Function_Timer{
    ///定时器
    [[[RACSignal interval:1.0f onScheduler:[RACScheduler mainThreadScheduler]] takeUntil:self.rac_willDeallocSignal]///VC释放signal跟着释放
     subscribeNext:^(id x) {
         NSLog(@"主线程定时器,每隔1秒执行1次:%@-->%@",x,[NSThread currentThread]);
     }error:^(NSError *error) {
         NSLog(@"主线程定时器,error:%@",error);
     } completed:^{
         NSLog(@"主线程定时器,结束任务");
     }];
    
    //[RACScheduler scheduler]和下面那个是一类的,都是分线程
    RACSignal *signal = [RACSignal interval:1.5f onScheduler:[RACScheduler schedulerWithPriority:RACSchedulerPriorityDefault name:@"com.custom.queue"]];
    [[signal take:3] subscribeNext:^(id x) {
        NSLog(@"自定义定时器:%@-->%@",x,[NSThread currentThread]);
    }error:^(NSError *error) {
        NSLog(@"error:%@",error);
    } completed:^{
        NSLog(@"自定义定时器结束任务:%@",[NSThread currentThread]);
    }];
}

@end
