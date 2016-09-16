//
//  Then_Functions_VC.m
//  MyTools
//
//  Created by 郑冰津 on 16/9/5.
//  Copyright © 2016年 IceGod. All rights reserved.
//

#import "Then_Functions_VC.h"
#import <objc/message.h>

@interface Then_Functions_VC ()

@end

@implementation Then_Functions_VC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title= @"RAC信号串";
    arrayVClass = @[@"then函数简单使用"].mutableCopy;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *selString = @[@"racSignalQueue"][indexPath.row];
    SEL gcdSEL = NSSelectorFromString(selString);
    if ([self respondsToSelector:gcdSEL]) {
        ((void (*)(id self, SEL))objc_msgSend)(self, gcdSEL);
    }
}
//用那个著名的脑筋急转弯说明吧，“如何把大象放进冰箱里”  第一步，打开冰箱；第二步，把大象放进冰箱；第三步，关上冰箱门。
- (void)racSignalQueue {
    //与信号传递类似，不过使用 `then` 表明的是秩序，没有传递value
    [[[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"RAC信号串------打开冰箱"];
        [subscriber sendCompleted];
        return nil;
    }] then:^RACSignal *{
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [subscriber sendNext:@"RAC信号串------把大象放进冰箱"];
            [subscriber sendCompleted];
            return nil;
        }];
    }] then:^RACSignal *{
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [subscriber sendNext:@"RAC信号串------关上冰箱门"];
            [subscriber sendCompleted];
            return nil;
        }];
    }] subscribeNext:^(id x) {
        NSLog(@"RAC信号串传递:%@",x);
    }];
}

@end
