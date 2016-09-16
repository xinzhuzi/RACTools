//
//  Combine_Functions_VC.m
//  MyTools
//
//  Created by 郑冰津 on 16/9/5.
//  Copyright © 2016年 IceGod. All rights reserved.
//

#import "Combine_Functions_VC.h"
#import <objc/message.h>

@interface Combine_Functions_VC ()

@end

@implementation Combine_Functions_VC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title= @"RAC组合函数";
    arrayVClass = @[@"组合2个信号"].mutableCopy;

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *selString = @[@"racSignalCombine"][indexPath.row];
    SEL gcdSEL = NSSelectorFromString(selString);
    if ([self respondsToSelector:gcdSEL]) {
        ((void (*)(id self, SEL))objc_msgSend)(self, gcdSEL);
    }
}
- (void)racSignalCombine {
    RACSignal *signal1 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"年轻"];
        [subscriber sendNext:@"清纯"];
        [subscriber sendCompleted];
        return nil;
    }];
    
    RACSignal *signal2 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"温柔"];
        [subscriber sendCompleted];
        
        return nil;
    }];
    
    RACSignal *signal3 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"又纯又骚的"];
        [subscriber sendCompleted];
        
        return nil;
    }];
    //combineLatest 将数组中的信号量发出的最后一个object 组合到一起
    [[RACSignal combineLatest:@[signal1, signal2,signal3]] subscribeNext:^(RACTuple *x) {
        //先进行解包
        RACTupleUnpack(NSString *signal1_Str, NSString *signal2_Str, NSString *signal3_Str) = x;
        NSLog(@"RAC信号组合------我喜欢 %@的 %@的 %@ 妹子",signal1_Str,signal2_Str,signal3_Str);
    }];
    
    //会注意收到 组合方法后还可以跟一个Block  /** + (RACSignal *)combineLatest:(id<NSFastEnumeration>)signals reduce:(id (^)())reduceBlock */
    /*
     reduce这个Block可以对组合后的信号量做处理
     */
    //我们还可以这样使用,reduce:归纳处理
    [[RACSignal combineLatest:@[signal1, signal2] reduce:^(NSString *signal1_Str, NSString *signal2_Str){
        return [signal1_Str stringByAppendingString:signal2_Str];
    }] subscribeNext:^(id x) {
        NSLog(@"RAC信号组合(Reduce处理)------我喜欢 %@ 的妹子",x);
    }];
}



@end
