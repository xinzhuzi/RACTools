//
//  TextUIRAC_VC.m
//  MyTools
//
//  Created by 郑冰津 on 16/8/25.
//  Copyright © 2016年 IceGod. All rights reserved.
//

#import "TestUIRAC_VC.h"
#import "RACToolsHeader.h"
#import <objc/message.h>
#import "RACTestView.h"

@interface TestUIRAC_VC ()

@end

@implementation TestUIRAC_VC

- (void)dealloc{
    NSLog(@"%s",__func__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"RAC的UI逻辑处理";
    arrayVClass = @[@"监测输入框的弹出与隐藏",@"测试输入框"].mutableCopy;
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *selString = @[@"keyBoardHiddenOrPopUp",@"testSignalTextField"][indexPath.row];
    SEL gcdSEL = NSSelectorFromString(selString);
    if ([self respondsToSelector:gcdSEL]) {
        ((void (*)(id self, SEL))objc_msgSend)(self, gcdSEL);
    }
}
///采用RAC替换代理
- (void)testSignalTextField{
    /*
     一个RACSignal的每个操作的返回值也是RACSignal，因此，它被称为 流式接口 (fluent interface)。这样的特征允许你构建事件流，而不需要考虑每一步都使用局部变量。
     */
    RACTestView *tView = [[RACTestView alloc]initWithFrame:CGRectMake(0, 64, Screen_W, Screen_H-64)];
    UITextField *textField1 = (UITextField *)[tView viewWithTag:876];
    UITextField *textField2 = (UITextField *)[tView viewWithTag:877];
    [self.view addSubview:tView];
    @weakify(tView);///在下面的block使用对象必须进行@weakify操作;
    
#if 0
    [[textField1.rac_textSignal filter:^BOOL(NSString * value) {
        return value.length>3;
    }] subscribeNext:^(id x) {
        NSLog(@"输出的text:%@",x);
    }];
    //新添加的map(映射)操作为改变事件数据提供了Block块。它将接收到的事件，通过执行Block块所得的返回值提供给下一个事件。在上面的代码中，map的Block返回了取出的NSString文字的长度, 这使得下一个事件的值则为NSNumber类型。
    [[[textField1.rac_textSignal map:^id(NSString * value) {
        return @(value.length);///这个地方除了转换成NSNumber类型的用法,不知道还有什么其他用法
    }] filter:^BOOL(NSNumber * number) {
        return number.integerValue>3;
    }] subscribeNext:^(id x) {
        NSLog(@"map之后输出的text:%@",x);
    }];
#elif 1
    ///比较low的写法
//    [[[tView.textField.rac_textSignal map:^id(NSString * value) {
//        return @(value.length>5);
//    }]map:^id(NSNumber * value) {
//        return value.integerValue>0?[UIColor clearColor]:[UIColor yellowColor];
//    }] subscribeNext:^(UIColor * x) {
//        @strongify(tView);
//        tView.textField.backgroundColor = x;
//    }];
    ///比较高级的写法
    RAC(textField1,backgroundColor) = [[textField1.rac_textSignal map:^id(NSString * value) {
        return @(value.length>5);
    }] map:^id(NSNumber * value) {
        return [value boolValue]?[UIColor whiteColor]:[UIColor yellowColor];
    }];
    ///2个信号绑定,可以使用ReactiveCocoa去执行一些非常重量级的任务
    RACSignal *signal1 = [textField1.rac_textSignal
                                      map:^id(NSString *text) {
                                          return @(text.length>5);
                                      }];
    RACSignal *signal2 = [textField2.rac_textSignal
                                      map:^id(NSString *text) {
                                          return @(text.length>5);
                                      }];
    ///结合
    [[RACSignal combineLatest:@[signal1, signal2] reduce:^id(NSNumber *usernameValid, NSNumber *passwordValid) {
        return @([usernameValid boolValue] && [passwordValid boolValue]).boolValue?[UIColor redColor]:[UIColor cyanColor];
    }] subscribeNext:^(UIColor *color) {
        @strongify(tView);
        tView.backgroundColor=color;
    }];
#endif
}
//处理键盘的弹出和隐藏,以及通知的使用
- (void)keyBoardHiddenOrPopUp{
    @weakify(self);
    //1.创建
    RACSignal *signalKeyboard = [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillShowNotification object:nil] map:^id(NSNotification *notification) {
        ///输入
        /*
         2.通过 map 操作，把 UIKeyboardWillShowNotification 转换成一个 CGRect(包装在 NSValue 里面)。map 操作是 FRP 里面最核心的一个基本操作，也是最体现函数式编程(FP)哲学的一个操作，所谓的这个哲学，用通俗的话来描述，就是『把复杂的业务拆分成一个一个的小任务，每一个小任务，都需要一个输入值，并且会给出一个输出值(当然也会反馈错误信息)，而且每个小任务都只专心的做一件事情』。如果第一个小任务的输出值，是第二个小任务的输入值，那么，就可以用 map 操作把这两个小任务串联在一起。在接收到 UIKeyboardWillShowNotification 消息通知的时候，这个小任务的输入值就是 NSNotification，输出值是键盘尺寸对应的 CGRect，小任务本身做的事情，就是从 NSNotification 里面取出包装着这个 CGRect 的 NSValue。
         */
        NSDictionary* userInfo = [notification userInfo];
        NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
        return aValue;///输出,赋值到signal里面
    }];
    [[[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillHideNotification object:nil] map:^id(NSNotification *notification) {///3,键盘消失,构造一个值CGRectZero
        return [NSValue valueWithCGRect:CGRectZero];
    }]/*
       4.终于到了这段代码的重点了，merge 操作在这里的使用效果，相当于把 2 和 3 里面的两个小任务的输出值作为自己的输入值，按照时间先后顺序排列起来，然后作为自己这个小任务的输出值，返回给 Pipeline 中的下一个环节。这样描述还是很抽象，看不懂，是吧？没关系，早就说过用语言很难描述了。把代码运行起来，通过 NSLog(@"Keyboard size is: %@", value) 这句代码的输出信息体会一下 merge 的实际效果。
       */
        merge:signalKeyboard]
        /*
         takeUntil 是一个难点，如果没有这一句代码调用，运行代码后会发现，前面 5 里面的业务还是正常执行了，但是当 self 被 dealloc 后(比如 pop UIViewController 后)， NSLog(@"事件流完成");这句代码没有被执行到(因为已经处理过 retain cycle，所以此时 self 是 nil)，这是因为当 self 被 dealloc 后，这个 Pipeline 并没有被释放，Pipeline 里面还是有数据在继续流动。这个话题牵扯到 RAC 框架中的内存管理策略，很重要，后面的内容中还会讲到这个话题。这里暂时只需要知道可以借助 takeUntil:self.rac_willDeallocSignal 这样的一行代码方便的解决问题就行了。
         */
        takeUntil:self.rac_willDeallocSignal]
        subscribeNext:^(NSValue *value) {
            ///5.订阅,完成最重要的逻辑
             @strongify(self);
            NSLog(@"Keyboard size is: %@", value);
            if ([value isEqualToValue:[NSValue valueWithCGRect:CGRectZero]]) {
                [self.navigationController setNavigationBarHidden:NO animated:YES];
            }else{
                [self.navigationController setNavigationBarHidden:YES animated:YES];
            }
        } completed:^{
            NSLog(@"事件流完成");
        }];
}

@end




