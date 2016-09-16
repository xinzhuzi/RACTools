//
//  ZIP_Functions_VC.m
//  MyTools
//
//  Created by 郑冰津 on 16/9/6.
//  Copyright © 2016年 IceGod. All rights reserved.
//

#import "ZIP_Functions_VC.h"

@interface ZIP_Functions_VC ()

@end

@implementation ZIP_Functions_VC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title= @"RAC压缩";
    arrayVClass = @[@"简单使用"].mutableCopy;

}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *selString = @[@"racSignalZIP"][indexPath.row];
    SEL gcdSEL = NSSelectorFromString(selString);
    if ([self respondsToSelector:gcdSEL]) {
        ((void (*)(id self, SEL))objc_msgSend)(self, gcdSEL);
    }
}
- (void)racSignalZIP {
    RACSignal *signal1 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"清纯"];
        [subscriber sendNext:@"年轻"];
        [subscriber sendCompleted];
        return nil;
    }];
    
    RACSignal *signal2 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"温柔"];
        [subscriber sendCompleted];
        return nil;
    }];
    
    //zip 默认会取信号量的最开始发送的对象 所以结果会是 清纯 、温柔
    [[signal1 zipWith:signal2] subscribeNext:^(RACTuple *x) {
        RACTupleUnpack(NSString *signal1_Str1,NSString *signal2_Str) = x;
        NSLog(@"RAC信号压缩------我喜欢 %@的 %@的 妹子",signal1_Str1, signal2_Str);
    }];
    [[RACSignal zip:@[signal1,signal2]] subscribeNext:^(RACTuple *x) {
        RACTupleUnpack(NSString *signal1_Str1,NSString *signal2_Str) = x;
        NSLog(@"RAC信号压缩------我喜欢 %@的 %@的 妹子",signal1_Str1, signal2_Str);
    }];
}
@end
