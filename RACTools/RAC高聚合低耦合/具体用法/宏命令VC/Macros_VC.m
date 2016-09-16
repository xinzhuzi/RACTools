//
//  Macros_VC.m
//  MyTools
//
//  Created by 郑冰津 on 16/8/31.
//  Copyright © 2016年 IceGod. All rights reserved.
//

#import "Macros_VC.h"
#import <objc/message.h>
#import "RACTestView.h"

@interface Macros_VC ()

@property (nonatomic,strong)NSString *observedValue;
@end

@implementation Macros_VC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"宏命令";
    arrayVClass = @[@"RAC(TARGET, [KEYPATH, [NIL_VALUE]])宏命令",@"RACObserve()察值宏命令",@""].mutableCopy;
    
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *selString = @[@"RAC_Macros_EaseUse",@"RACObserve_Macros_EaseUse"][indexPath.row];
    SEL gcdSEL = NSSelectorFromString(selString);
    if ([self respondsToSelector:gcdSEL]) {
        ((void (*)(id self, SEL))objc_msgSend)(self, gcdSEL);
    }
}

- (void)RAC_Macros_EaseUse{
    RACTestView *tView = [[RACTestView alloc]initWithFrame:CGRectMake(0, 64, Screen_W, Screen_H-64)];
    UITextField *textField1 = (UITextField *)[tView viewWithTag:876];
    UITextField *textField2 = (UITextField *)[tView viewWithTag:877];
    [self.view addSubview:tView];
    textField1.placeholder = @"在这个输入框里面输入....";
    RAC(textField2,text,@"收到nil时就显示我") = textField1.rac_textSignal;
    /*
     　　这个宏是最常用的，RAC()总是出现在等号左边，等号右边是一个RACSignal，表示的意义是将一个对象的一个属性和一个signal绑定，signal每产生一个value（id类型），都会自动执行：
        [TARGET setValue:value ?: NIL_VALUE forKeyPath:KEYPATH];
     */
    
    RAC(self,title) = RACObserve(textField2, text);

    /*
     　　数字值会升级为NSNumber *，当setValue:forKeyPath时会自动降级成基本类型（int, float ,BOOL等），所以RAC绑定一个基本类型的值是没有问题的
        RACObserve(TARGET, KEYPATH)
        作用是观察TARGET的KEYPATH属性，相当于KVO，产生一个RACSignal
        最常用的使用，和RAC宏绑定属性：
        上面的代码将textField2.text的输出和self.title属性绑定，实现联动，text但凡有变化都会使得title变化
     */
//    RACTuplePack(<#...#>)
//    RACTupleUnpack(<#...#>)
//    RACChannelTo(<#TARGET, ...#>)
}

///察值
- (void)RACObserve_Macros_EaseUse{
    ///这个地方,是只要self.observedValue有值便被记录,每一次修改值都被记录
    self.observedValue = @"2334234";
    @weakify(self);
    [RACObserve(self, observedValue) subscribeNext:^(NSString* x) {
        @strongify(self);
        NSLog(@"你动了:%@",self.observedValue);
    }];
    self.observedValue = @"000000";
    
}

@end
