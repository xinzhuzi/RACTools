//
//  Bind_VC.m
//  RACTools
//
//  Created by 郑冰津 on 2016/12/1.
//  Copyright © 2016年 IceGod. All rights reserved.
//

#import "Bind_VC.h"


@implementation TestBindView

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
            NSLog(@"移除view");
            [self removeFromSuperview];
        }];
        UITextField *textField = [[UITextField alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, 40)];
        textField.borderStyle=UITextBorderStyleBezel;
        textField.tag= 455;
        [self addSubview:textField];
        
    }
    return self;
}

@end

@interface Bind_VC ()

@end

@implementation Bind_VC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"绑定的核心函数";
    arrayVClass = @[@"基础函数bind测试"].mutableCopy;

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *selString = @[@"bind_Function_EasyUse"][indexPath.row];
    SEL gcdSEL = NSSelectorFromString(selString);
    if ([self respondsToSelector:gcdSEL]) {
        ((void (*)(id self, SEL))objc_msgSend)(self, gcdSEL);
    }
}
- (void)bind_Function_EasyUse{
    /*
     ReactiveCocoa操作的核心方法是bind（绑定）,而且RAC中核心开发方式，也是绑定，之前的开发方式是赋值，而用RAC开发，应该把重心放在绑定，也就是可以在创建一个对象的时候，就绑定好以后想要做的事情，而不是等赋值之后在去做事情。
     列如：把数据展示到控件上，之前都是重写控件的setModel方法，用RAC就可以在一开始创建控件的时候，就绑定好数据。
     在开发中很少使用bind方法，bind属于RAC中的底层方法，RAC已经封装了很多好用的其他方法，底层都是调用bind，用法比bind简单.
     假设想监听文本框的内容，并且在每次输出结果的时候，都在文本框的内容拼接一段文字“输出：”
     
     使用方式:
     1.bind方法参数:需要传入一个返回值是RACStreamBindBlock的block参数
     2.RACStreamBindBlock是一个block的类型，返回值是信号，参数（value,stop），因此参数的block返回值也是一个block。
     {
     RACStreamBindBlock:
     1.参数一(value):表示接收到信号的原始值，还没做处理
     2.参数二(*stop):用来控制绑定Block，如果*stop = yes,那么就会结束绑定。
     3.返回值：信号，做好处理，在通过这个信号返回出去，一般使用RACReturnSignal,需要手动导入头文件RACReturnSignal.h。
     }
     3.描述一个RACStreamBindBlock类型的bindBlock作为block的返回值。
     4.描述一个返回结果的信号，作为bindBlock的返回值。
     5.注意：在bindBlock中做信号结果的处理。
     底层实现:
     1.源信号调用bind,会重新创建一个绑定信号。
     2.当绑定信号被订阅，就会调用绑定信号中的didSubscribe，生成一个bindingBlock。
     3.当源信号有内容发出，就会把内容传递到bindingBlock处理，调用bindingBlock(value,stop)
     4.调用bindingBlock(value,stop)，会返回一个内容处理完成的信号（RACReturnSignal）。
     5.订阅RACReturnSignal，就会拿到绑定信号的订阅者，把处理完成的信号内容发送出来。
     // 注意:不同订阅者，保存不同的nextBlock，看源码的时候，一定要看清楚订阅者是哪个。
     // 这里需要手动导入#import <ReactiveCocoa/RACReturnSignal.h>，才能使用RACReturnSignal。
     */
    TestBindView *tView = [[TestBindView alloc]initWithFrame:CGRectMake(0, 64, Screen_W, Screen_H-64)];
    UITextField *textField1 = (UITextField *)[tView viewWithTag:455];
    [self.view addSubview:tView];
    RACSignal *signal = [textField1.rac_textSignal bind:^RACStreamBindBlock{
        // 什么时候调用:
        // block作用:表示绑定了一个信号.
        return ^RACStream*(id value, BOOL *stop){
            // 什么时候调用block:当信号有新的值发出，就会来到这个block。
            // block作用:做返回值的处理
            // 做好处理，通过信号返回出去.
//            return [RACReturnSignal return:[NSString stringWithFormat:@"bind输出:%@",value]];
//            return nil;
            return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                    [subscriber sendNext:[NSString stringWithFormat:@"bind输出:%@",value]];
                    [subscriber sendCompleted];
                return nil;
            }];
        };
    }];
    [signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
}

@end
