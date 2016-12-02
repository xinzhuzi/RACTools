//
//  Delay_Timer_VC.m
//  RACTools
//
//  Created by 郑冰津 on 2016/12/1.
//  Copyright © 2016年 IceGod. All rights reserved.
//

#import "Delay_Timer_VC.h"

@interface Delay_Timer_VC ()

@end

@implementation Delay_Timer_VC

- (void)dealloc{
    NSLog(@"对象被销毁了:%s",__FUNCTION__);
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title= @"RAC中延时/定时器";
    arrayVClass = @[@"延时afterDelay",@"定时器",@"延时delay方法",@"请求超时"].mutableCopy;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *selString = @[@"racAfterDelay_EasyUse1",@"racDelay_EasyUse2",@"delayEsayUse1",@"delay_Function_Request"][indexPath.row];
    SEL gcdSEL = NSSelectorFromString(selString);
    if ([self respondsToSelector:gcdSEL]) {
        ((void (*)(id self, SEL))objc_msgSend)(self, gcdSEL);
    }
}

- (void)racAfterDelay_EasyUse1{
    NSLog(@"begin");
    //    1. 延迟某个时间后再做某件事
    [[RACScheduler mainThreadScheduler]afterDelay:2.0f schedule:^{
        NSLog(@"2秒之后发生的事情");
    }];
}

- (void)racDelay_EasyUse2{
    /*
     第一个参数填入时间间隔,
     第二个参数填入线程,不能填入[RACScheduler immediateScheduler] 也不能为nil 
     第三个参数是从现在开始间隔多少时间再执行block回调,只有第一次执行
     take:5 含义是:执行60次之后,销毁
     takeUntil:self.rac_willDeallocSignal 含义是当本身被销毁之后,定时器也销毁
     */
    NSLog(@"定时器创建,只有第一次间隔5秒之后执行");
    [[[[RACSignal interval:1 onScheduler:[RACScheduler mainThreadScheduler] withLeeway:5] take:5] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id  _Nullable x) {
        NSLog(@"定时器运行了,主线程:%@",[NSThread currentThread]);
    }];

//    [[[RACSignal interval:2 onScheduler:[RACScheduler schedulerWithPriority:RACSchedulerPriorityDefault name:@"timer.gcd"]] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id  _Nullable x) {
//        
//        NSLog(@"定时器运行了,分线程:%@",[NSThread currentThread]);
//    }];
    
//    [[[RACSignal interval:2 onScheduler:[RACScheduler scheduler]] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id  _Nullable x) {
//        
//        NSLog(@"定时器运行了,分线程:%@",[NSThread currentThread]);
//    }];
    

}

- (void)delayEsayUse1{
    /*
     delay: 延时执行发送信号
     startWith:相当于在发送某个信号之前先发送另一个信号
     */
    RACSignal *siganl = [[[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSLog(@"发送信号");
        [subscriber sendNext:@1];
        [subscriber sendCompleted];
        
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"discard Signal");
        }];
    }] delay:3] startWith:@"two"] delay:1];
    NSLog(@"创建信号");
    [siganl subscribeNext:^(id x) {
        NSLog(@"接收信号=%@",x);
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

@end





