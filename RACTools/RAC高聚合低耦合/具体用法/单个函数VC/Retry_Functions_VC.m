//
//  Retry_Functions_VC.m
//  MyTools
//
//  Created by 郑冰津 on 16/9/5.
//  Copyright © 2016年 IceGod. All rights reserved.
//

#import "Retry_Functions_VC.h"
#import <objc/message.h>

@interface Retry_Functions_VC ()

@end

@implementation Retry_Functions_VC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title= @"RAC重试";
    arrayVClass = @[@"简单使用"].mutableCopy;

}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *selString = @[@"rac_retry_EasyUse"][indexPath.row];
    SEL gcdSEL = NSSelectorFromString(selString);
    if ([self respondsToSelector:gcdSEL]) {
        ((void (*)(id self, SEL))objc_msgSend)(self, gcdSEL);
    }
}

- (void)rac_retry_EasyUse{
    //设置retry次数，这部分可以和网络请求一起用
    __block int retry_idx = 0;
    [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSLog(@"请求的第%d次",retry_idx);
        if (retry_idx < 3) {
            retry_idx++;
            [subscriber sendError:nil];
        }else {
            [subscriber sendNext:@"success!"];
            [subscriber sendCompleted];
        }
        return nil;
    }] retry:3] subscribeNext:^(id x) {
        NSLog(@"请求:%@",x);
    }];
}

@end
