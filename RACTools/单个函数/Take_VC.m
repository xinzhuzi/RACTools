//
//  Take_VC.m
//  RACTools
//
//  Created by 郑冰津 on 2016/12/1.
//  Copyright © 2016年 IceGod. All rights reserved.
//

#import "Take_VC.h"

@interface Take_VC ()

@end

@implementation Take_VC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"执行次数";
    
    arrayVClass = @[@"简单使用"].mutableCopy;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *selString = @[@"take_Function_EasyUse"][indexPath.row];
    SEL gcdSEL = NSSelectorFromString(selString);
    if ([self respondsToSelector:gcdSEL]) {
        ((void (*)(id self, SEL))objc_msgSend)(self, gcdSEL);
    }
}

- (void)take_Function_EasyUse{
    RACSignal *siganl = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [subscriber sendNext:@"one"];
        [subscriber sendNext:@"two"];
        [subscriber sendNext:@"three"];
        [subscriber sendNext:@"four"];
        [subscriber sendCompleted];
        return [RACDisposable disposableWithBlock:^{
            
        }];
        
    }];
//    siganl = [siganl take:2];
//    siganl = [siganl takeLast:2];
//    siganl = [siganl skip:2];
    [siganl subscribeNext:^(id x){
        NSLog(@"x==%@",x);
    }];
    
    //take 只接收前几次
    //skip 跳过前几次
    //takeLast 只接收最后几次
    /*
     takeUntilBlock:
     takeWhileBlock:
     skipWhileBlock:
     skipUntilBlock:
    */
}

@end
