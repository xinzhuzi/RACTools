//
//  MulticastConnection_VC.m
//  RACTools
//
//  Created by 郑冰津 on 2016/12/1.
//  Copyright © 2016年 IceGod. All rights reserved.
//

#import "MulticastConnection_VC.h"

@interface MulticastConnection_VC ()

@end

@implementation MulticastConnection_VC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"RAC多路传送";
    arrayVClass = @[@"多次订阅信号,createSignal方法的block块只调用一次",@"sequence的字典操作"].mutableCopy;

    
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
     RACMulticastConnection:用于当一个信号，被多次订阅时，为了保证创建信号时，避免多次调用创建信号中的block，造成副作用，可以使用这个类处理。
     使用注意:RACMulticastConnection通过RACSignal的-publish或者-muticast:方法创建.
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
     
      需求：假设在一个信号中发送请求，每次订阅一次都会发送请求，这样就会导致多次创建block块。
      解决：使用RACMulticastConnection就能解决.
     */
    
    // 1.创建请求信号
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSLog(@"发送请求");
        [subscriber sendNext:@1];
        [subscriber sendCompleted];
        return nil;
    }];
    // 2.订阅信号
    [signal subscribeNext:^(id x) {
        NSLog(@"接收数据");
    }];
    // 2.订阅信号
    [signal subscribeNext:^(id x) {
        NSLog(@"接收数据");
    }];
    
    // 3.运行结果，会执行两遍发送请求，也就是每次订阅都会发送一次请求
    
    NSLog(@"#################################");
    // RACMulticastConnection:解决重复请求问题
    // 1.创建信号
    RACSignal *signal1 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSLog(@"发送请求");
        [subscriber sendNext:@114233];
        return nil;
    }];
    
    // 2.创建连接
    RACMulticastConnection *connect = [signal1 publish];
    
    // 3.订阅信号，
    // 注意：订阅信号，也不能激活信号，只是保存订阅者到数组，必须通过连接,当调用连接，就会一次性调用所有订阅者的sendNext:
    [connect.signal subscribeNext:^(id x) {
        NSLog(@"订阅者一信号:%@",x);
    }];
    [connect.signal subscribeNext:^(id x) {
        NSLog(@"订阅者二信号:%@",x);
    }];
    // 4.连接,激活信号
    [connect connect];
    // 5.自动连接,并带有一个信号,订阅信号,接收信号发送值
//    [[connect autoconnect] subscribeNext:^(id  _Nullable x) {
//        NSLog(@"autoconnect1:%@",x);
//    }];
}

@end
