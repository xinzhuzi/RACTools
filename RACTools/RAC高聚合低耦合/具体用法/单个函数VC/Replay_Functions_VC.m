//
//  Replay_Functions_VC.m
//  MyTools
//
//  Created by 郑冰津 on 16/9/11.
//  Copyright © 2016年 IceGod. All rights reserved.
//

#import "Replay_Functions_VC.h"

@interface Replay_Functions_VC ()

@end

@implementation Replay_Functions_VC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title= @"RAC重放";
    arrayVClass = @[@"简单使用"].mutableCopy;

}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *selString = @[@"racSignalReplay"][indexPath.row];
    SEL gcdSEL = NSSelectorFromString(selString);
    if ([self respondsToSelector:gcdSEL]) {
        ((void (*)(id self, SEL))objc_msgSend)(self, gcdSEL);
    }
}

- (void)racSignalReplay{
    /*
     作用是:保存sendNext:发送的值,当第二次之后订阅的时候立即返回这个值,不需要再次创建信号
     */
    RACSignal *replaySignal = [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber>subscriber) {
        NSLog(@"大导演拍了一部电影《我的男票是程序员》");
        [subscriber sendNext:@"《我的男票是程序员》"];
        [subscriber sendCompleted];
        return nil;
    }] replay];
    [replaySignal subscribeNext:^(id x) {
        NSLog(@"小明看了%@", x);
    }];
    [replaySignal subscribeNext:^(id x) {
        NSLog(@"小红也看了%@", x);
    }];
}

@end
