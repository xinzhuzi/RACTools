//
//  RACDelegateView.m
//  MyTools
//
//  Created by 郑冰津 on 16/8/24.
//  Copyright © 2016年 IceGod. All rights reserved.
//

#import "RACTestView.h"

@implementation RACTestView

- (void)dealloc{
    NSLog(@"%s",__func__);
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor cyanColor];
        self.contentSize = CGSizeMake(frame.size.width, 2000);
        @weakify(self);
        ///移除并且测试代理的button
        {
            UIButton *testBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 160, 40)];
            testBtn.backgroundColor = [UIColor brownColor];
            [testBtn setTitle:@"removeTestView" forState:UIControlStateNormal];
            [self addSubview:testBtn];
            [[[testBtn rac_signalForControlEvents:UIControlEventTouchUpInside] doNext:^(id x) {
                @strongify(self);
                [self endEditing:YES];
                [self removeFromSuperview];
            }] subscribeNext:^(UIButton *btn) {
                @strongify(self);
                if (self.delegateSignal) {
                    [self.delegateSignal sendNext:btn];
                    [self testButtonClickDelegate:@2];
                }
            }];
        }
        ///倒计时,验证码
        {
            UIButton *verificationBtn = [[UIButton alloc]initWithFrame:CGRectMake(frame.size.width-200, 0, 200, 40)];
            [verificationBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
            [verificationBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
            verificationBtn.tag = 766;
            [self addSubview:verificationBtn];
            
            [[[verificationBtn rac_signalForControlEvents:UIControlEventTouchUpInside] doNext:^(UIButton *btn) {
                @strongify(self);
                [btn setTitle:@"倒计时59s" forState:UIControlStateNormal];
                [self endEditing:YES];
            }] subscribeNext:^(UIButton * btn) {
                btn.selected = !btn.selected;
                @strongify(self);
                [self timerVerification:btn];
            }];
        }
        ///输入框,账户与密码
        {
            for (NSInteger i =0; i<2; i++) {
                UITextField *textField = [[UITextField alloc]initWithFrame:CGRectMake(0, 60 + i*60, frame.size.width, 40)];
                textField.clearButtonMode=UITextFieldViewModeAlways;
                textField.clearsOnBeginEditing=YES;
                textField.tag = 876+i;
                textField.placeholder = @[@"账户",@"密码"][i];
                textField.backgroundColor = [UIColor yellowColor];
                [self addSubview:textField];
            }
        }
        ///测试UITextView
        {
            UITextView *textView = [[UITextView alloc]initWithFrame:CGRectMake(0, frame.size.height-100, Screen_W, 100)];
            textView.tag = 788;
            textView.backgroundColor = [UIColor purpleColor];
            [self addSubview:textView];
        }
        ///测试的label
        {
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, frame.size.height-140, frame.size.width, 40)];
            label.tag = 123;
            label.numberOfLines = 0;
            [self addSubview:label];
        }
        
        {
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]init];
            tap.numberOfTapsRequired = 2;
            [self addGestureRecognizer:tap];
            [tap.rac_gestureSignal subscribeNext:^(id x) {
                NSLog(@"手势:%@",x);
            } error:^(NSError *error) {
                NSLog(@"手势接收错误:%@",error);
            } completed:^{
                NSLog(@"手势结束");
            }];
        }
        
    }
    return self;
}

- (void)timerVerification:(UIButton *)btn{
   RACSignal *signal = [[[[RACSignal interval:1.0f onScheduler:
        [RACScheduler mainThreadScheduler]]
                        take:60]///执行60次之后,销毁
                        takeUntil:self.rac_willDeallocSignal]///本身被移除之后,销毁
                        map:^NSString *(NSDate * date) {
        NSString *secondStr = [[btn.titleLabel.text componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet]] componentsJoinedByString:@""];
        NSString *titleString= @"获取验证码";
        NSInteger seconds = [secondStr integerValue];
        if (seconds>1) {
            seconds--;
            titleString=[NSString stringWithFormat:@"倒计时%lds",(long)seconds];
            [btn setTitleColor:[UIColor brownColor] forState:UIControlStateNormal];
            btn.userInteractionEnabled=NO;
        }else{
            [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
            btn.userInteractionEnabled=YES;
        }
        NSLog(@"%@--%@",titleString,date);
        return titleString;
    }];
    
    [signal subscribeNext:^(NSString * titleString) {
        [btn setTitle:titleString forState:UIControlStateNormal];
    }error:^(NSError *error) {
        NSLog(@"验证码倒计时错误:%@",error);
    } completed:^{
        NSLog(@"验证码倒计时完成");
    }];
    
}
//- (void)testButtonClickDelegate:(id)obj{
//    NSLog(@"传递的参数:%@",obj);
//}

@end
