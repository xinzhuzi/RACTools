//
//  Macros_VC.m
//  MyTools
//
//  Created by 郑冰津 on 16/8/31.
//  Copyright © 2016年 IceGod. All rights reserved.
//

#import "Macros_VC.h"
#import <objc/message.h>

@interface Macros_VC ()

@property (nonatomic,strong)NSString *observedValue1;

@property (nonatomic,strong)NSString *observedValue2;
@end

@implementation Macros_VC

- (void)dealloc{
    NSLog(@"销毁了:%s",__FUNCTION__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"宏命令";
    arrayVClass = @[@"RAC/RACObserve宏命令",@"RACObserve()察值宏命令",@"数据包装RACTuple"].mutableCopy;
    
    /*
     A:这个宏是最常用的，RAC()总是出现在等号左边，等号右边是一个RACSignal，表示的意义是将一个对象的一个属性和一个signal绑定，signal每产生一个value（id类型），都会自动执行：
     [TARGET setValue:value ?: NIL_VALUE forKeyPath:KEYPATH];
     
     B:数字值会升级为NSNumber *，当setValue:forKeyPath时会自动降级成基本类型（int, float ,BOOL等），所以RAC绑定一个基本类型的值是没有问题的
     RACObserve(TARGET, KEYPATH)
     作用是观察TARGET的KEYPATH属性，相当于KVO，产生一个RACSignal
     最常用的使用，和RAC宏绑定属性：
     上面的代码将textField2.text的输出和self.title属性绑定，实现联动，text但凡有变化都会使得title变化
     */
    RAC(self,title,@"收到nil时就显示我") = RACObserve(self, observedValue1);
    ///可以将UITextField的值传入信号,进行赋值操作
    //RAC(textField2,text,@"收到nil时就显示我") = textField1.rac_textSignal;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *selString = @[@"RAC_Macros_EaseUse",@"RACObserve_Macros_EaseUse",@"RACTuple_Macros_EaseUse"][indexPath.row];
    SEL gcdSEL = NSSelectorFromString(selString);
    if ([self respondsToSelector:gcdSEL]) {
        ((void (*)(id self, SEL))objc_msgSend)(self, gcdSEL);
    }
}

- (void)RAC_Macros_EaseUse{
    int b = 10*arc4random()%100;
    self.observedValue1 = b<50?nil:[NSString stringWithFormat:@"测试:%d",b];
}

///察值
- (void)RACObserve_Macros_EaseUse{
    ///这个地方,是只要self.observedValue有值便被记录,每一次修改值都被记录
    self.observedValue2 = @"2334234";
    @weakify(self);
    [RACObserve(self, observedValue2) subscribeNext:^(NSString* x) {
        @strongify(self);
        NSLog(@"你动了:%@:%@",self.observedValue2,[NSThread currentThread]);
    }];
    self.observedValue2 = @"000000";
}

- (void)RACTuple_Macros_EaseUse{
    // 把参数中的数据包装成元组
    RACTuple *tuple = RACTuplePack(@"xmg",@20);
    // 解包元组，会把元组的值，按顺序给参数里面的变量赋值
    // name = @"xmg" age = @20
    RACTupleUnpack(NSString *name,NSNumber *age) = tuple;
    NSLog(@"name = %@ age = %@",name,age);
    
    /*
     RACTuple:元组类,类似NSArray,用来包装值.
     RACSequence:RAC中的集合类，用于代替NSArray,NSDictionary,可以使用它来快速遍历数组和字典。
     使用场景：1.字典转模型
     RACSequence和RACTuple简单使用
     回调都是分线程
     */
    
    NSArray *arrayNumbers = @[@14,@1424,@4536,@67,@8797];
    [arrayNumbers.rac_sequence.signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"数组的信号分解:%@ %@",x,[NSThread currentThread]);
    }];
    
    NSDictionary *dict = @{@"name":@"郑冰津",@"age":@3454646554};
    [dict.rac_sequence.signal subscribeNext:^(id  _Nullable x) {
        RACTupleUnpack(NSString *key,id value) =x;
        NSLog(@"字典的信号分解key:%@,value:%@ %@",key,value,[NSThread currentThread]);
    }];
}

@end
