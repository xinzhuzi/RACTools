//
//  Try_Functions_VC.m
//  MyTools
//
//  Created by 郑冰津 on 16/9/11.
//  Copyright © 2016年 IceGod. All rights reserved.
//

#import "Try_Functions_VC.h"

@interface Try_Functions_VC ()

@end

@implementation Try_Functions_VC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title= @"RAC重试";
    arrayVClass = @[@"简单使用"].mutableCopy;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *selString = @[@"racSignalRetry"][indexPath.row];
    SEL gcdSEL = NSSelectorFromString(selString);
    if ([self respondsToSelector:gcdSEL]) {
        ((void (*)(id self, SEL))objc_msgSend)(self, gcdSEL);
    }
}

- (void)racSignalRetry{
    /*
     在retry函数中,sendCompleted没有作用,每次发送sendError:时,立即停止block块里面代码的运行,然后重新执行block块,当没有执行sendError:方法时,则retry函数失效
     */
    __block int failedCount = 0;
    [[[RACSignal createSignal:^RACDisposable *(id <RACSubscriber>subscriber) {
        if (failedCount < 100) {

            failedCount++;
            NSLog(@"我失败了");
            [subscriber sendError:nil];
        }else{
            NSLog(@"经历了数百次失败后");
            [subscriber sendNext:@"发送完毕2"];
        }

        return nil;
    }] retry] subscribeNext:^(id x) {
        NSLog(@"终于成功了:%@",x);
    }];
}

@end
