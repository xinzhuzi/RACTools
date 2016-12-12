//
//  Take_VC.m
//  RACTools
//
//  Created by 郑冰津 on 2016/12/1.
//  Copyright © 2016年 IceGod. All rights reserved.
//

#import "Take_VC.h"

@interface Take_VC ()

@end

@implementation Take_VC

- (void)dealloc{
    NSLog(@"对象被销毁了:%s",__FUNCTION__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"执行次数";
    
    arrayVClass = @[@"简单使用,接收次数",@"takeUntil条件控制"].mutableCopy;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *selString = @[@"take_Function_EasyUse",@"takeUntil_Function_EasyUse"][indexPath.row];
    SEL gcdSEL = NSSelectorFromString(selString);
    if ([self respondsToSelector:gcdSEL]) {
        ((void (*)(id self, SEL))objc_msgSend)(self, gcdSEL);
    }
}

- (void)take_Function_EasyUse{
    RACSignal *siganl = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [subscriber sendNext:@"one"];
        [subscriber sendNext:@"two"];
        [subscriber sendNext:@"three"];
        [subscriber sendNext:@"four"];
        [subscriber sendCompleted];
        return [RACDisposable disposableWithBlock:^{
            
        }];
        
    }];
//    siganl = [siganl take:2];
//    siganl = [siganl takeLast:2];
//    siganl = [siganl skip:2];
    [siganl subscribeNext:^(id x){
        NSLog(@"x==%@",x);
    }];
    
    //take 只接收前几次
    //skip 跳过前几次
    //takeLast 只接收最后几次
    /*
     takeUntilBlock:
     takeWhileBlock:
     skipWhileBlock:
     skipUntilBlock:
    */
}


- (void)takeUntil_Function_EasyUse{
    /**
     解释：`takeUntil:(RACSignal *)signalTrigger`  当`signalTrigger`这个signal发出消息之后,所有的信号将会停止
     经常使用takeUntil:self.rac_willDeallocSignal 来防止循环引用,销毁信号
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
            [subscriber sendCompleted];
        });
        return nil;
    }]] subscribeNext:^(id x) {
        NSLog(@"最终结果:%@",x);
    }];
}

@end




