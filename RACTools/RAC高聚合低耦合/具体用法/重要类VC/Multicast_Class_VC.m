//
//  Multicast_Class_VC.m
//  MyTools
//
//  Created by 郑冰津 on 16/9/11.
//  Copyright © 2016年 IceGod. All rights reserved.
//

#import "Multicast_Class_VC.h"

@interface Multicast_Class_VC ()

@end

@implementation Multicast_Class_VC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"RAC多路传送";
    arrayVClass = @[@"sequence的数组操作",@"sequence的字典操作"].mutableCopy;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *selString = @[@"RACMulticastConnection_easyUse"][indexPath.row];
    SEL gcdSEL = NSSelectorFromString(selString);
    if ([self respondsToSelector:gcdSEL]) {
        ((void (*)(id self, SEL))objc_msgSend)(self, gcdSEL);
    }
}
- (void)RACMulticastConnection_easyUse{
    /*
     RACMulticastConnection使用步骤:
     1.创建信号 + (RACSignal *)createSignal:(RACDisposable * (^)(id<RACSubscriber> subscriber))didSubscribe
     2.创建连接 RACMulticastConnection *connect = [signal publish];
     3.订阅信号,注意：订阅的不在是之前的信号，而是连接的信号。 [connect.signal subscribeNext:nextBlock]
     4.连接 [connect connect]
     
     RACMulticastConnection底层原理:
     1.创建connect，connect.sourceSignal -> RACSignal(原始信号)  connect.signal -> RACSubject
     2.订阅connect.signal，会调用RACSubject的subscribeNext，创建订阅者，而且把订阅者保存起来，不会执行block。
     3.[connect connect]内部会订阅RACSignal(原始信号)，并且订阅者是RACSubject
     3.1.订阅原始信号，就会调用原始信号中的didSubscribe
     3.2 didSubscribe，拿到订阅者调用sendNext，其实是调用RACSubject的sendNext
     4.RACSubject的sendNext,会遍历RACSubject所有订阅者发送信号。
     4.1 因为刚刚第二步，都是在订阅RACSubject，因此会拿到第二步所有的订阅者，调用他们的nextBlock
     
     // 需求：假设在一个信号中发送请求，每次订阅一次都会发送请求，这样就会导致多次请求。
     // 解决：使用RACMulticastConnection就能解决.
     */
#if 0
    //1.创建
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSLog(@"发送请求");
        //2.发送数据
        [subscriber sendNext:@2016];
        [subscriber sendCompleted];
        return [RACDisposable disposableWithBlock:^{
            // 3.运行结果，会执行两遍发送请求，也就是每次订阅都会发送一次请求
            NSLog(@"信号销毁");
        }];
    }];
    // 2.订阅信号
    [signal subscribeNext:^(id x) {
        NSLog(@"接收数据:%@",x);
    }];
    // 2.订阅信号
    [signal subscribeNext:^(id x) {
        NSLog(@"接收数据:%@",x);
    }];
#elif 1
    //1.创建
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSLog(@"发送请求");
        //2.发送数据
        [subscriber sendNext:@2016];
        [subscriber sendCompleted];
        return [RACDisposable disposableWithBlock:^{
            // 3.运行结果，会执行两遍发送请求，也就是每次订阅都会发送一次请求
            NSLog(@"信号销毁");
        }];
    }];
    // 2.创建连接
    RACMulticastConnection *connect = [signal publish];
    // 3.订阅信号，
    // 注意：订阅信号，也不能激活信号，只是保存订阅者到数组，必须通过连接,当调用连接，就会一次性调用所有订阅者的sendNext:
    [connect.signal subscribeNext:^(id x) {
        NSLog(@"订阅者1信号:%@",x);
    }];
    [connect.signal subscribeNext:^(id x) {
        NSLog(@"订阅者2信号:%@",x);
    }];
    // 4.连接,激活信号
    [connect connect];
#endif
    
}

@end
