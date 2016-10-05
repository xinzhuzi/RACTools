//
//  SignalTestView.m
//  RACTools
//
//  Created by 郑冰津 on 2016/10/5.
//  Copyright © 2016年 IceGod. All rights reserved.
//

#import "SignalTestView.h"

@implementation SignalTestView

- (void)dealloc{
    NSLog(@"%s",__func__);
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor cyanColor];
        self.contentSize = CGSizeMake(frame.size.width, 2000);
        @weakify(self);
        self.delegateSignal = [RACSubject subject];
        {
            UIButton *testBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), 40)];
            testBtn.backgroundColor = [UIColor brownColor];
            [testBtn setTitle:@"TestReplaceDelegateButton" forState:UIControlStateNormal];
            testBtn.tag = 777;
            [self addSubview:testBtn];
            [[[testBtn rac_signalForControlEvents:UIControlEventTouchUpInside] doNext:^(id x) {
                NSLog(@"doNext:%@",x);
                @strongify(self);
                [self endEditing:YES];
                [self removeFromSuperview];
            }] subscribeNext:^(UIButton *btn) {
                @strongify(self);
                [self.delegateSignal sendNext:@(btn.tag)];
                [self testButtonClickDelegate:@(btn.tag)];
            }];
        }
    }
    return self;
}



@end
