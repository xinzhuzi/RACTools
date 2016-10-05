//
//  RACSignal_VC.m
//  RACTools
//
//  Created by 郑冰津 on 2016/10/4.
//  Copyright © 2016年 IceGod. All rights reserved.
//

#import "RACSignal_VC.h"
#import "SignalTestView.h"

@interface RACSignal_VC ()

@end

@implementation RACSignal_VC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"RACSignal的使用";
    arrayVClass = @[@"RACSignal最简单的发送接收销毁",@"RACSubject信号提供与RACReplaySubject重复信号提供",@"采用RAC替换代理",@"等待多个信号都有返回值时才执行方法"].mutableCopy;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *selString = @[@"easyMostSendReceiveDestroy",@"signalProvideAndReplay",@"textSignalReplaceDelegate",@"MultipleSignalValueReturn"][indexPath.row];
    SEL gcdSEL = NSSelectorFromString(selString);
    if ([self respondsToSelector:gcdSEL]) {
        ((void (*)(id self, SEL))objc_msgSend)(self, gcdSEL);
    }
}

/**
 最简单的发送,接收,销毁
 RACSignal使用步骤：
 1.创建信号 + (RACSignal *)createSignal:(RACDisposable * (^)(id<racsubscriber> subscriber))didSubscribe
 2.订阅信号,才会激活信号. - (RACDisposable *)subscribeNext:(void (^)(id x))nextBlock
 3.发送信号 - (void)sendNext:(id)value
 
 RACSignal底层实现：
 1.创建信号，首先把didSubscribe保存到信号中，还不会触发。
 2.当信号被订阅，也就是调用signal的subscribeNext:nextBlock
 2.2 subscribeNext内部会创建订阅者subscriber，并且把nextBlock保存到subscriber中。
 2.1 subscribeNext内部会调用siganl的didSubscribe
 3.siganl的didSubscribe中调用[subscriber sendNext:@1];
 3.1 sendNext底层其实就是执行subscriber的nextBlock
 */
- (void)easyMostSendReceiveDestroy{
    //1.创建信号
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSLog(@"创建信号:%@",self);
        //block调用时刻：每当有订阅者订阅信号，就会调用block。
        //3.发送信号
        [subscriber sendNext:@1];
//        [subscriber sendError:[NSError errorWithDomain:@"必现" code:409 userInfo:@{@"reason":@"发送的错误码"}]];
        [subscriber sendCompleted];
        
        return [RACDisposable disposableWithBlock:^{
            // block调用时刻：当信号发送完成或者发送错误，就会自动执行这个block,取消订阅信号。
            // 执行完Block后，当前信号就不在被订阅了。
            NSLog(@"信号销毁了");
        }];
    }];
    //2.订阅信号,才会激活信号,成为热信号,如果在此不订阅信号,则信号一直是冷信号
    [signal subscribeNext:^(id x) {
        ///block调用时刻：每当有信号发出数据，就会调用block.
        NSLog(@"接收发送的信号值:%@",x);
    } error:^(NSError *error) {
        NSLog(@"信号流程出现错误:%@",error);
    } completed:^{
        NSLog(@"信号发送完成");
    }];    ///2句代码可以合成一句代码,只是码行占用较多

    ///可以多次订阅
    [signal subscribeNext:^(id x) {
        NSLog(@"第二次订阅收到数据:%@",x);
    }];
    
}

/**
 RACSubject使用步骤
 1.创建信号 [RACSubject subject]，跟RACSiganl不一样，创建信号时没有block。
 2.订阅信号 - (RACDisposable *)subscribeNext:(void (^)(id x))nextBlock
 3.发送信号 sendNext:(id)value
 
 RACSubject:底层实现和RACSignal不一样。
 1.调用subscribeNext订阅信号，只是把订阅者保存起来，并且订阅者的nextBlock已经赋值了。
 2.调用sendNext发送信号，遍历刚刚保存的所有订阅者，一个一个调用订阅者的nextBlock。
 
 RACReplaySubject使用步骤:
 1.创建信号 [RACSubject subject]，跟RACSiganl不一样，创建信号时没有block。
 2.可以先订阅信号，也可以先发送信号。
 2.1 订阅信号 - (RACDisposable *)subscribeNext:(void (^)(id x))nextBlock
 2.2 发送信号 sendNext:(id)value
 
 RACReplaySubject:底层实现和RACSubject不一样。
 1.调用sendNext发送信号，把值保存起来，然后遍历刚刚保存的所有订阅者，一个一个调用订阅者的nextBlock。
 2.调用subscribeNext订阅信号，遍历保存的所有值，一个一个调用订阅者的nextBlock
 
 如果想当一个信号被订阅，就重复播放之前所有值，需要先发送信号，在订阅信号。
 也就是先保存值，在订阅值。
 */
- (void)signalProvideAndReplay{
    //1.创建
    RACSubject *subject = [RACSubject subject];
    //2.多次订阅,当一个信号发送完毕时,所有的订阅者走完调用的block,下一个信号才被接收
    [subject subscribeNext:^(id x) {
        NSLog(@"RACSubject:第1个订阅者:%@",x);
    }];
    [subject subscribeNext:^(id x) {
        NSLog(@"RACSubject:第2个订阅者:%@",x);
    }];
    // 3.发送信号,多次发送
    [subject sendNext:@"1"];
    [subject sendNext:@"2"];
    
    //2<->3步可转换代码位置
    RACReplaySubject *replaySubject = [RACReplaySubject replaySubjectWithCapacity:3];
    // 2.发送信号,可以首先发送信号,这一步可以写在任何位置.当一个订阅的block接收到信号时,所有的信号全部接收到之后,才能走下一个订阅的block
    [replaySubject sendNext:@77777];
    [replaySubject sendNext:@88888];
    // 3.订阅信号,然后订阅信号接收
    [replaySubject subscribeNext:^(id x) {
        NSLog(@"RACReplaySubject:第1个订阅者接收到的数据%@",x);
    }];
    // 3.订阅信号,然后订阅信号接收
    [replaySubject subscribeNext:^(id x) {
        NSLog(@"RACReplaySubject:第2个订阅者接收到的数据%@",x);
    }];
}


/**
 采用RAC替换代理
 */
- (void)textSignalReplaceDelegate{
    SignalTestView *stView = [[SignalTestView alloc]initWithFrame:CGRectMake(0, 64, Screen_W, Screen_H-64)];
    [self.view addSubview:stView];
    [stView.delegateSignal subscribeNext:^(id x) {
        NSLog(@"点击了button,传递过来一个button,这个不属于真正的代理协议:%@",x);
    }];
    
    RACSignal *trueSignal = [stView rac_signalForSelector:@selector(testButtonClickDelegate:) fromProtocol:@protocol(SignalTestViewDelegate)];
    [trueSignal subscribeNext:^(id x) {
        RACTupleUnpack(NSNumber *number)=x;
        NSLog(@"协议替换成RAC中的runtime操作,这才是真正的代理协议,参数:%@",number);
    }];
}

/**
 等待多个信号都有返回值时才执行方法
 */
- (void)MultipleSignalValueReturn{
    // 处理多个请求，都返回结果的时候，统一做处理.
    RACSignal *request1 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        // 发送请求1
        [subscriber sendNext:@"发送请求1"];
        return nil;
    }];
    
    RACSignal *request2 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [NSThread sleepForTimeInterval:2];
        // 发送请求2
        [subscriber sendNext:@"发送请求2"];
        return nil;
    }];
    
    // 使用注意：几个信号，参数一的方法就几个参数，每个参数对应信号发出的数据。
    [self rac_liftSelector:@selector(updateUIWithR1:R2:) withSignalsFromArray:@[request1,request2]];
    
}
- (void)updateUIWithR1:(id)obj1 R2:(id)obj2{
    NSLog(@"参数1:%@ 参数2:%@",obj1,obj2);
}


@end
