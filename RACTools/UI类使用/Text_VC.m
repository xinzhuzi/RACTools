//
//  Text_VC.m
//  RACTools
//
//  Created by 郑冰津 on 2016/12/1.
//  Copyright © 2016年 IceGod. All rights reserved.
//

#import "Text_VC.h"

@interface Text_VC ()

@end

@implementation Text_VC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UITextField *textField = [[UITextField alloc]initWithFrame:CGRectMake(0, 64, Screen_W, 40)];
    textField.borderStyle =  UITextBorderStyleRoundedRect;
    [self.view addSubview:textField];
    
    [textField.rac_textSignal subscribeNext:^(NSString * _Nullable x) {
        NSLog(@"%@",x);
    }];
}


@end
