//
//  Command_VC.m
//  MyTools
//
//  Created by 郑冰津 on 16/9/5.
//  Copyright © 2016年 IceGod. All rights reserved.
//

#import "Command_VC.h"
#import <objc/message.h>

@interface Command_VC (){
    RACCommand *_command;
}

@end

@implementation Command_VC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title= @"RAC中控制命令";
    arrayVClass = @[@"简单使用1",@"简单使用2"].mutableCopy;

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *selString = @[@"racCommand_EasyUse1",@"racCommand_EasyUse2"][indexPath.row];
    SEL gcdSEL = NSSelectorFromString(selString);
    if ([self respondsToSelector:gcdSEL]) {
        ((void (*)(id self, SEL))objc_msgSend)(self, gcdSEL);
    }
}
- (void)racCommand_EasyUse1 {
    RACCommand *command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            NSLog(@"racCommandDemo------亲，帮我带份饭~");
            [subscriber sendCompleted];
            return nil;
        }];
    }];    
    //命令执行
    [command execute:nil];
}
///RAC中用于处理事件的类，可以把事件如何处理,事件中的数据如何传递，包装到这个类中，他可以很方便的监控事件的执行过程。使用场景:监听按钮点击，网络请求
- (void)racCommand_EasyUse2{
    /*
     一、RACCommand使用步骤:
     1.创建命令 initWithSignalBlock:(RACSignal * (^)(id input))signalBlock
     2.在signalBlock中，创建RACSignal，并且作为signalBlock的返回值
     3.执行命令 - (RACSignal *)execute:(id)input
     
     二、RACCommand使用注意:
     1.signalBlock必须要返回一个信号，不能传nil.
     2.如果不想要传递信号，直接创建空的信号[RACSignal empty];
     3.RACCommand中信号如果数据传递完，必须调用[subscriber sendCompleted]，这时命令才会执行完毕，否则永远处于执行中。
     4.RACCommand需要被强引用，否则接收不到RACCommand中的信号，因此RACCommand中的信号是延迟发送的。
     
     三、RACCommand设计思想：内部signalBlock为什么要返回一个信号，这个信号有什么用。
     1.在RAC开发中，通常会把网络请求封装到RACCommand，直接执行某个RACCommand就能发送请求。
     2.当RACCommand内部请求到数据的时候，需要把请求的数据传递给外界，这时候就需要通过signalBlock返回的信号传递了。
     
     四、如何拿到RACCommand中返回信号发出的数据。
     1.RACCommand有个执行信号源executionSignals，这个是signal of signals(信号的信号),意思是信号发出的数据是信号，不是普通的类型。
     2.订阅executionSignals就能拿到RACCommand中返回的信号，然后订阅signalBlock返回的信号，就能获取发出的值。
     五、监听当前命令是否正在执行executing
     六、使用场景,监听按钮点击，网络请求
     */
    
    RACCommand *command = [[RACCommand alloc]initWithSignalBlock:^RACSignal *(id input) {
        NSLog(@"执行命令");
        // 创建空信号,必须返回信号
        //        return [RACSignal empty];
        
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [subscriber sendNext:@"发送的数据7777"];
            // 注意：数据传递完，最好调用sendCompleted，这时命令才执行完毕。
            [subscriber sendCompleted];
            return [RACDisposable disposableWithBlock:^{
                NSLog(@"信号销毁");
            }];
        }];
    }];
    // 强引用命令，不要被销毁，否则接收不到数据
    _command = command;
    // 3.订阅RACCommand中的信号
    [command.executionSignals subscribeNext:^(RACSignal * x) {
        [x subscribeNext:^(id x) {
            NSLog(@"接收数据:%@",x);
        }];
    }];
    // RAC高级用法
    // switchToLatest:用于signal of signals，获取signal of signals发出的最新信号,也就是可以直接拿到RACCommand中的信号
    [command.executionSignals.switchToLatest subscribeNext:^(id x) {
        NSLog(@"RAC高级用法,直接拿到RACCommand中的信号:%@",x);
    }];
    // 4.监听命令是否执行完毕,默认会来一次，可以直接跳过，skip表示跳过第一次信号。
    [[command.executing skip:1] subscribeNext:^(id x) {
        if ([x boolValue] == YES) {
            // 正在执行
            NSLog(@"正在执行");
        }else{
            // 执行完成
            NSLog(@"执行完成");
        }
    }];
    // 5.执行命令
    [_command execute:@5];
    
}
@end
