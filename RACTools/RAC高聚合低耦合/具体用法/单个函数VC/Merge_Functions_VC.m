//
//  Merge_Functions_VC.m
//  MyTools
//
//  Created by 郑冰津 on 16/9/5.
//  Copyright © 2016年 IceGod. All rights reserved.
//

#import "Merge_Functions_VC.h"
#import <objc/message.h>

@interface Merge_Functions_VC ()

@end

@implementation Merge_Functions_VC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title= @"RAC合并函数";
    arrayVClass = @[@"合并2个信号-->1",@"合并2个信号-->2"].mutableCopy;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *selString = @[@"racSignalMerge1",@"racSignalMerge2"][indexPath.row];
    SEL gcdSEL = NSSelectorFromString(selString);
    if ([self respondsToSelector:gcdSEL]) {
        ((void (*)(id self, SEL))objc_msgSend)(self, gcdSEL);
    }
}
- (void)racSignalMerge1 {
    /*
     不管怎么合并,只要中间出现错误,立马停止
     */
    RACSignal *signal1 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendError:nil];
        [subscriber sendNext:@"清纯妹子"];
        [subscriber sendCompleted];
        return nil;
    }];
    
    RACSignal *signal2 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"性感妹子"];
        [subscriber sendCompleted];
        
        return nil;
    }];
    
    [[signal1 merge:signal2] subscribeNext:^(id x) {
        NSLog(@"RAC信号合并------我喜欢： %@",x);
    }];
}

- (void)racSignalMerge2{
    RACSignal * signalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [subscriber sendError:nil];
            [subscriber sendNext:@"Signal_A"];
            [subscriber sendCompleted];
        });
        return nil;
    }];
    RACSignal * signalB = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [subscriber sendNext:@"Signal_B"];
            [subscriber sendCompleted];
        });
        return nil;
    }];
    NSLog(@"开始预订,同时订阅信号,合并");
    [[RACSignal merge:@[signalA, signalB]]subscribeNext:^(id x) {
        NSLog(@"x==%@",x);
    }];
    
}

@end
