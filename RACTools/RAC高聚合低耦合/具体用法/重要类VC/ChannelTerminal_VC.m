//
//  ChannelTerminal_VC.m
//  MyTools
//
//  Created by 郑冰津 on 16/9/5.
//  Copyright © 2016年 IceGod. All rights reserved.
//

#import "ChannelTerminal_VC.h"
#import <objc/message.h>

@interface ChannelTerminal_VC ()
@property (nonatomic,strong)NSString *valueA;
@property (nonatomic,strong)NSString *valueB;
@end

@implementation ChannelTerminal_VC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title= @"RAC中通道终端";
    arrayVClass = @[@"双通道"].mutableCopy;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *selString = @[@"RAC_ChannelTerminal_EasyUse"][indexPath.row];
    SEL gcdSEL = NSSelectorFromString(selString);
    if ([self respondsToSelector:gcdSEL]) {
        ((void (*)(id self, SEL))objc_msgSend)(self, gcdSEL);
    }
}

- (void)RAC_ChannelTerminal_EasyUse{
    RACChannelTerminal *channelA = RACChannelTo(self, valueA);
    RACChannelTerminal *channelB = RACChannelTo(self, valueB);
    [[channelA map:^id(NSString *value) {
        if ([value isEqualToString:@"西"]) {
            return @"东";
        }
        return value;
    }] subscribe:channelB];
    [[channelB map:^id(NSString *value) {
        if ([value isEqualToString:@"左"]) {
            return @"右";
        }
        return value;
    }] subscribe:channelA];
    [[RACObserve(self, valueA) filter:^BOOL(id value) {
        return value ? YES : NO;
    }] subscribeNext:^(NSString* x) {
        NSLog(@"你向%@", x);
    }];
    [[RACObserve(self, valueB) filter:^BOOL(id value) {
        return value ? YES : NO;
    }] subscribeNext:^(NSString* x) {
        NSLog(@"他向%@", x);
    }];
    
    self.valueA = @"西";
    self.valueB = @"左";
}
@end
