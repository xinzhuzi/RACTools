//
//  Filter_Functions_VC.m
//  MyTools
//
//  Created by 郑冰津 on 16/9/2.
//  Copyright © 2016年 IceGod. All rights reserved.
//

#import "Filter_Functions_VC.h"
#import <objc/message.h>

@interface Filter_Functions_VC ()

@end

@implementation Filter_Functions_VC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title= @"RAC过滤函数";
    arrayVClass = @[@"过滤信号"].mutableCopy;
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *selString = @[@"racSignalFilter"][indexPath.row];
    SEL gcdSEL = NSSelectorFromString(selString);
    if ([self respondsToSelector:gcdSEL]) {
        ((void (*)(id self, SEL))objc_msgSend)(self, gcdSEL);
    }
}
- (void)racSignalFilter {
    //信号过滤可以参考上面UIButton引用RAC的实例
    [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@(19)];
        [subscriber sendNext:@(12)];
        [subscriber sendNext:@(20)];
        [subscriber sendCompleted];
        
        return nil;
    }] filter:^BOOL(NSNumber *value) {
        if (value.integerValue < 18) {
            //18禁
            NSLog(@"RAC信号过滤------FBI Warning~");
        }
        return value.integerValue > 18;
    }]
     subscribeNext:^(id x) {
         NSLog(@"RAC信号过滤------年龄：%@",x);
     }];
    
}

@end
