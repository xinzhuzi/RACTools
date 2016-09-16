//
//  Take_Functions_VC.m
//  MyTools
//
//  Created by 郑冰津 on 16/9/5.
//  Copyright © 2016年 IceGod. All rights reserved.
//

#import "Take_Functions_VC.h"
#import <objc/message.h>

@interface Take_Functions_VC ()

@end

@implementation Take_Functions_VC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title= @"RAC条件控制";
    arrayVClass = @[@"简单使用1",@"简单使用2"].mutableCopy;
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *selString = @[@"rac_Take_EasyUse1",@"rac_Take_EasyUse2"][indexPath.row];
    SEL gcdSEL = NSSelectorFromString(selString);
    if ([self respondsToSelector:gcdSEL]) {
        ((void (*)(id self, SEL))objc_msgSend)(self, gcdSEL);
    }
}
- (void)rac_Take_EasyUse1{
    //条件控制
    /**
     解释：`takeUntil:(RACSignal *)signalTrigger` 只有当`signalTrigger`这个signal发出消息才会停止
     */
    [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [[RACSignal interval:1.0 onScheduler:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
            //每秒发一个消息
            [subscriber sendNext:@"RAC_Condition------吃饭中~"];
        }];
        return nil;
    }] takeUntil:[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        //延迟5S发送一个消息，才会让前面的信号停止
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"RAC_Condition------吃饱了~");
            [subscriber sendNext:@"吃饱了"];
        });
        return nil;
    }]] subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
}

- (void)rac_Take_EasyUse2{
    RACSignal *siganl = [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [subscriber sendNext:@"one"];
        [subscriber sendNext:@"two"];
        [subscriber sendNext:@"three"];
        [subscriber sendNext:@"four"];
        [subscriber sendCompleted];
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"结束");
        }];
    }] takeLast:2];
    [siganl subscribeNext:^(id x){
        NSLog(@"x==%@",x);
    }];
   
    /*
     //take 只接收前几次
     //skip 跳过前几次
     //takeLast 只接收最后几次
     takeUntilBlock:
     takeWhileBlock:
     skipWhileBlock:
     skipUntilBlock:
    */
}

@end
