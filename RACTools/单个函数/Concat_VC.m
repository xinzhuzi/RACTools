//
//  Concat_VC.m
//  RACTools
//
//  Created by 郑冰津 on 2016/12/2.
//  Copyright © 2016年 IceGod. All rights reserved.
//

#import "Concat_VC.h"

@interface Concat_VC ()

@end

@implementation Concat_VC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title= @"RAC拼接信号";
    arrayVClass = @[@"拼接2个信号"].mutableCopy;

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *selString = @[@"racSignalLink"][indexPath.row];
    SEL gcdSEL = NSSelectorFromString(selString);
    if ([self respondsToSelector:gcdSEL]) {
        ((void (*)(id self, SEL))objc_msgSend)(self, gcdSEL);
    }
}
- (void)racSignalLink {
    RACSignal *signal1 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                [subscriber sendNext:@(1)];
//        [subscriber sendError:nil];
        [subscriber sendCompleted];
        return nil;
    }];
    
    RACSignal *signal2 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@(2)];
        [subscriber sendCompleted];
        
        return nil;
    }];
    NSLog(@"开始预订,合并,执行完A 后才执行 B ，而且A成功与否，B都会执行，中间出错,亦可进行下去");
    ///谁在前面先回调谁的值
    [[signal2 concat:signal1] subscribeNext:^(NSNumber *value) {
        NSLog(@"RAC信号拼接------value = %@",value);
    }];
    
    RACSignal *signalC = [RACSignal createSignal:^RACDisposable *(id subscriber) {
        //        [subscriber sendNext:@"我恋爱啦"];
        [subscriber sendError:nil];
        
        [subscriber sendCompleted];
        return nil;
    }];
    RACSignal *signalD = [RACSignal createSignal:^RACDisposable *(id subscriber) {
        [subscriber sendNext:@"我结婚啦"];
        [subscriber sendCompleted];
        return nil;
    }];
    NSLog(@"开始预订,合并,执行完A 后才执行 B ，而且A必须成功，B才会执行，他们是异步请求.中间出错,则不能进行下去");
    [[RACSignal concat:@[signalC, signalD]]subscribeNext:^(id x) {
        NSLog(@"x==%@",x);
    }];
}

@end





