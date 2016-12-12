//
//  Throttle_VC.m
//  RACTools
//
//  Created by 郑冰津 on 2016/12/2.
//  Copyright © 2016年 IceGod. All rights reserved.
//

#import "Throttle_VC.h"


@implementation ThrottleViewTest

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor orangeColor];
        
        @weakify(self);
        UIButton *button = [[UIButton alloc]initWithFrame:self.frame];
        [self addSubview:button];
        [[button rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            [self removeFromSuperview];
        }];
        UITextField *textField = [[UITextField alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, 40)];
        textField.borderStyle=UITextBorderStyleBezel;
        textField.tag= 455;
        [self addSubview:textField];
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, self.frame.size.height -40, self.frame.size.width, 40)];
        label.backgroundColor = [UIColor brownColor];
        label.tag = 456;
        [self addSubview:label];
    }
    return self;
}

@end


@interface Throttle_VC ()

@end

@implementation Throttle_VC

- (void)dealloc{
    NSLog(@"对象被销毁了:%s",__FUNCTION__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"RAC节流阀";
    arrayVClass = @[@"简单使用1",@"简单使用2",@"测试textField"].mutableCopy;
    
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *selString = @[@"rac_throttle_EasyUse1",@"rac_throttle_EasyUse2",@"rac_throttle_EasyUse3"][indexPath.row];
    SEL gcdSEL = NSSelectorFromString(selString);
    if ([self respondsToSelector:gcdSEL]) {
        ((void (*)(id self, SEL))objc_msgSend)(self, gcdSEL);
    }
}

- (void)rac_throttle_EasyUse1{
    //节流阀,throttle秒内只能通过1个消息,并且是单位时间(N)内最后一个才能被发出来
    [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"6"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [subscriber sendNext:@"66"];
        });
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [subscriber sendNext:@"666"];
            [subscriber sendCompleted];
        });
        
        return nil;
    }] throttle:2] subscribeNext:^(id x) {
        //throttle: N   N秒之内只能通过一个消息，所以只有单位时间(N)内最后一个才能被发出来
        NSLog(@"RAC_throttle------result = %@",x);
    }];
}

- (void)rac_throttle_EasyUse2{
    [[[RACSignal createSignal:^RACDisposable *(id subscriber) {
        [subscriber sendNext:@"旅客A"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [subscriber sendNext:@"旅客B"];
        });
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [subscriber sendNext:@"旅客C"];
            [subscriber sendNext:@"旅客D"];
            [subscriber sendNext:@"旅客E"];
        });
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [subscriber sendNext:@"旅客F"];
            [subscriber sendNext:@"旅客D"];

        });
        return nil;
    }] throttle:1] subscribeNext:^(id x) {
        NSLog(@"%@通过了",x);
    }];
}

- (void)rac_throttle_EasyUse3{
    //就是在我们设置那个时间内（0.5秒），不会发送消息，让其不会一直不断的发送过来。
    ThrottleViewTest *tView = [[ThrottleViewTest alloc]initWithFrame:CGRectMake(0, 64, Screen_W, Screen_H-64)];
    UITextField *textField1 = (UITextField *)[tView viewWithTag:455];
    [self.view addSubview:tView];
    [[textField1.rac_textSignal throttle:1]subscribeNext:^(id x){
        NSLog(@"节流:%@", x);
    }];
    //distinctUntilChanged 相同的就不发送，直到有所该变再发送
    [[[textField1.rac_textSignal throttle:2] distinctUntilChanged]subscribeNext:^(id x){
        NSLog(@"相同的就不发送，直到有所该变再发送:%@", x);
        
    }];
    //ignore:忽略某个值，像上面就是忽略 (整个字符串)空值
    [[[[textField1.rac_textSignal throttle:3] distinctUntilChanged] ignore:@" "] subscribeNext:^(id x){
        NSLog(@"忽略某个值:%@", x);
    }];
}

@end




