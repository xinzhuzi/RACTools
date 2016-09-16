//
//  Start_Functions_VC.m
//  MyTools
//
//  Created by 郑冰津 on 16/9/12.
//  Copyright © 2016年 IceGod. All rights reserved.
//

#import "Start_Functions_VC.h"

@interface Start_Functions_VC ()

@end

@implementation Start_Functions_VC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"RAC先发送";
    arrayVClass = @[@"比源信号值先发送一个信号值"].mutableCopy;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *selString = @[@"racSignalStart"][indexPath.row];
    SEL gcdSEL = NSSelectorFromString(selString);
    if ([self respondsToSelector:gcdSEL]) {
        ((void (*)(id self, SEL))objc_msgSend)(self, gcdSEL);
    }
}
- (void)racSignalStart{
    RACSignal *siganl = [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"我是源信号"];
        [subscriber sendCompleted];
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"信号结束");
        }];
    }] startWith:@"比源信号先发"];
    [siganl subscribeNext:^(id x) {
        
        NSLog(@"接收信号的值:%@",x);
    }];
}
@end
