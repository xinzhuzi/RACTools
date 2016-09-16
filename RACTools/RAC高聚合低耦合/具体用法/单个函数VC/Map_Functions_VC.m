//
//  RACMAP_VC.m
//  MyTools
//
//  Created by 郑冰津 on 16/8/29.
//  Copyright © 2016年 IceGod. All rights reserved.
//

#import "Map_Functions_VC.h"
#import "MyToolsHeader.h"
#import <objc/message.h>
#import "RACTestView.h"
#import "ReactiveCocoa/RACReturnSignal.h"

@interface Map_Functions_VC ()

@end

@implementation Map_Functions_VC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title= @"RAC中的map函数";
    arrayVClass = @[@"基础函数bind测试",@"map函数测试",@"map函数配合其他高级函数使用",@"flattenMap函数的操作",@"map和flattenMap函数的区别",@"mapReplace函数测试",@"tryMap的函数测试",@"flattenMap信号传递"].mutableCopy;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *selString = @[@"bind_Function_EasyUse",@"map_Function_Test",@"map_Else_Functions",@"flattenMap_Function_EasyUse",@"map_flattenMap_Function",@"mapReplace_Function_EasyUse",@"tryMap_Function_EasyUse",@"racSignalPass"][indexPath.row];
    SEL gcdSEL = NSSelectorFromString(selString);
    if ([self respondsToSelector:gcdSEL]) {
        ((void (*)(id self, SEL))objc_msgSend)(self, gcdSEL);
    }
}

//http://blog.sunnyxx.com/2014/03/06/rac_2_racstream/
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
    // 方式一:在返回结果后，拼接。
    RACTestView *tView = [[RACTestView alloc]initWithFrame:CGRectMake(0, 64, Screen_W, Screen_H-64)];
    UITextField *textField1 = (UITextField *)[tView viewWithTag:876];
    [self.view addSubview:tView];
    [textField1.rac_textSignal subscribeNext:^(id x) {
        NSLog(@"输出:%@",x);
    }];
    // 方式二:在返回结果前，拼接，使用RAC中bind方法做处理。
    [[textField1.rac_textSignal bind:^RACStreamBindBlock{
        // 什么时候调用:
        // block作用:表示绑定了一个信号.
        return ^RACStream*(id value, BOOL *stop){
            // 什么时候调用block:当信号有新的值发出，就会来到这个block。
            // block作用:做返回值的处理
            // 做好处理，通过信号返回出去.
            return [RACReturnSignal return:[NSString stringWithFormat:@"bind输出:%@",value]];
//            return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
//                [subscriber sendNext:[NSString stringWithFormat:@"bind输出:%@",value]];
//                [subscriber sendCompleted];
//                return nil;
//            }];
        };
    }] subscribeNext:^(id x) {
        NSLog(@"bind:----%@",x);
    }error:^(NSError *error) {
        
    } completed:^{
        NSLog(@"bind函数发送成功");
    }];
    
}

- (void)map_Function_Test{
    /*
     Map作用:把源信号的值映射成一个新的值
        1.传入一个block,类型是返回对象，参数是value
        2.value就是源信号的内容，直接拿到源信号的内容做处理
        3.把处理好的内容，直接返回就好了，不用包装成信号，返回的值，就是映射的值。
     Map底层实现:
        1.Map底层其实是调用flatternMap,Map中block中的返回的值会作为flatternMap中block中的值。
        2.当订阅绑定信号，就会生成bindBlock。
        3.当源信号发送内容，就会调用bindBlock(value, *stop)
        4.调用bindBlock，内部就会调用flattenMap的block
        5.flattenMap的block内部会调用Map中的block，把Map中的block返回的内容包装成返回的信号。
        6.返回的信号最终会作为bindBlock中的返回信号，当做bindBlock的返回信号。
        7.订阅bindBlock的返回信号，就会拿到绑定信号的订阅者，把处理完成的信号内容发送出来。
     */
    RACTestView *tView = [[RACTestView alloc]initWithFrame:CGRectMake(0, 64, Screen_W, Screen_H-64)];
    UITextField *textField1 = (UITextField *)[tView viewWithTag:876];
    [self.view addSubview:tView];
    [[textField1.rac_textSignal map:^id(id value) {
        // 当源信号发出，就会调用这个block，修改源信号的内容
        // 返回值：就是处理完源信号的内容。
        return [NSString stringWithFormat:@"输出:%@",value];
    }] subscribeNext:^(id x) {
        NSLog(@"打印结果:%@",x);
    }];
}

- (void)map_Else_Functions{
    RACTestView *tView = [[RACTestView alloc]initWithFrame:CGRectMake(0, 64, Screen_W, Screen_H-64)];
    UITextView *textView = (UITextView *)[tView viewWithTag:788];
    UIButton *verificationBtn = (UIButton *)[tView viewWithTag:766];
    UILabel *label = (UILabel *)[tView viewWithTag:123];
    [self.view addSubview:tView];
    
    [[[textView.rac_textSignal map:^id(NSString * value) {
        NSLog(@"map映射的结果:%@",value);
        return @(value.length);
    }] filter:^BOOL(NSNumber * number) {
        return number.integerValue>2;
    }] subscribeNext:^(id x) {
        NSLog(@"最终的结果:%@",x);
    }];
    RAC(tView,backgroundColor) = [RACObserve(verificationBtn, selected) map:^UIColor *(NSNumber * value) {
        NSLog(@"%@",value);
        return [value boolValue]?[UIColor magentaColor]:[UIColor cyanColor];
    }];
    
    RAC(label, text) = [[[RACSignal interval:1 onScheduler:
                          [RACScheduler mainThreadScheduler]]
                         takeUntil:self.rac_willDeallocSignal]
                        map:^NSString *(NSDate * date) {
                            //            NSLog(@"label定时器");
                            NSDateFormatter *df = [NSDateFormatter new];
                            df.dateFormat = @"yyyy-MM-dd HH:mm:ss";
                            NSString *localDate = [df stringFromDate:date];
                            return localDate.description;
                        }];
}

- (void)flattenMap_Function_EasyUse{
    /*
     flattenMap作用:把源信号的内容映射成一个新的信号，信号可以是任意类型。
        1.传入一个block，block类型是返回值RACStream，参数value
        2.参数value就是源信号的内容，拿到源信号的内容做处理
        3.包装成RACReturnSignal信号，返回出去。
     flattenMap底层实现:
        1.flattenMap内部调用bind方法实现的,flattenMap中block的返回值,会作为bind中bindBlock的返回值。
        2.当订阅绑定信号，就会生成bindBlock。
        3.当源信号发送内容，就会调用bindBlock(value, *stop)
        4.调用bindBlock，内部就会调用flattenMap的block，flattenMap的block作用：就是把处理好的数据包装成信号。
        5.返回的信号最终会作为bindBlock中的返回信号，当做bindBlock的返回信号。
        6.订阅bindBlock的返回信号，就会拿到绑定信号的订阅者，把处理完成的信号内容发送出来
     */
    RACTestView *tView = [[RACTestView alloc]initWithFrame:CGRectMake(0, 64, Screen_W, Screen_H-64)];
    UITextField *textField1 = (UITextField *)[tView viewWithTag:876];
    [self.view addSubview:tView];
    RACSignal *flaSignal = [textField1.rac_textSignal flattenMap:^RACStream *(id value) {
         // block什么时候 : 源信号发出的时候，就会调用这个block。
        // block作用 : 改变源信号的内容。
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [subscriber sendNext:value];///信号创建然后发送数据
            [subscriber sendCompleted];///发送结束,销毁创建的信号
            return nil;
        }];
        // 返回值：绑定信号的内容.
//        return [RACReturnSignal return:[NSString stringWithFormat:@"return一个值:%@",value]];
    }];
    [flaSignal subscribeNext:^(id x) {
        // 订阅绑定信号，每当源信号发送内容，做完处理，就会调用这个block。
        NSLog(@"订阅绑定信号:%@",x);
    }];
}

- (void)map_flattenMap_Function{
    /*
     FlatternMap和Map的区别
        1.FlatternMap中的Block返回信号(RACStream类型的,RACSignal继承与RACStream)。
        2.Map中的Block返回对象(id类型的)。
        3.开发中，如果信号发出的值不是信号，映射一般使用Map
        4.开发中，如果信号发出的值是信号，映射一般使用FlatternMap。
     signalOfsignals用FlatternMap。
     */
    RACSubject *signalOfsignals = [RACSubject subject];
    RACSubject *signal = [RACSubject subject];
    [[signalOfsignals flattenMap:^RACStream *(id value) {
         // 当signalOfsignals的signals发出信号才会调用
        return value;
    }] subscribeNext:^(id x) {
        // 只有signalOfsignals的signal发出信号才会调用，因为内部订阅了bindBlock中返回的信号，也就是flattenMap返回的信号。
        // 也就是flattenMap返回的信号发出内容，才会调用。
        NSLog(@"订阅:%@",x);
    } error:^(NSError *error) {
    } completed:^{
        NSLog(@"发送完成");
    }];
    // 信号的信号发送信号
    [signalOfsignals sendNext:signal];
    [signalOfsignals sendCompleted];
    [signal sendNext:@"信号中的信号发出的有用数据"];
    [signal sendCompleted];
}

- (void)mapReplace_Function_EasyUse{
    RACSignal *signal = [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@1];
        [subscriber sendCompleted];
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"信号销毁了");
        }];
    }] mapReplace:[NSString stringWithFormat:@"信号的值被替换了"]];///mapReplace这个意思大概是传入的值是id类型的,将会替换sendNext:的值
    
    [signal subscribeNext:^(id x) {
        NSLog(@"mapReplace函数测试,订阅的值:%@",x);
    }];
}

- (void)tryMap_Function_EasyUse{
    RACSignal *signal = [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:nil];
        [subscriber sendCompleted];
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"信号销毁了");
        }];
    }] tryMap:^id(id value, NSError *__autoreleasing *errorPtr) {
        if (!value) {
            *errorPtr = [NSError errorWithDomain:@"自己定制的错误" code:510 userInfo:nil];
            return *errorPtr;
        }
        ///尝试map映射,如果mapBlock的参数value不能map映射,自己定制*errorPtr返回*errorPtr
        NSLog(@"tryMap-value:%@ -errorPtr:%p",value,errorPtr);
        return [NSString stringWithFormat:@"合成新的值,value:%@",value];
    }];
    
    [signal subscribeNext:^(id x) {
        NSLog(@"tryMap函数测试,订阅的值:%@",x);
    } error:^(NSError *error) {
        NSLog(@"%@",error);
    } completed:^{
        NSLog(@"接收数据完成");
    }];
}

- (void)racSignalPass {
    [[[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"老板向我扔过来一个Star"];
        [subscriber sendCompleted];
        return nil;
    }] flattenMap:^RACStream *(NSString *value) {
        NSLog(@"RAC信号传递------%@",value);
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [subscriber sendNext:@"我向老板扔回一块板砖"];
            [subscriber sendCompleted];
            return nil;
        }];
    }] flattenMap:^RACStream *(NSString *value) {
        NSLog(@"RAC信号传递------%@",value);
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [subscriber sendNext:@"我跟老板正面刚~,结果可想而知"];
            [subscriber sendCompleted];
            return nil;
        }];
    }] subscribeNext:^(id x) {
        NSLog(@"RAC信号传递------%@",x);
    }];
}

@end



/*
 switchToLatest: 的作用是自动切换signal of signals到最后一个，比如之前的command.executionSignals就可以使用switchToLatest:。
 
 map:的作用很简单，对sendNext的value做一下处理，返回一个新的值。
 takeUntil:someSignal 的作用是当someSignal sendNext时，当前的signal就sendCompleted，someSignal就像一个拳击裁判，哨声响起就意味着比赛终止。
 它的常用场景之一是处理cell的button的点击事件，比如点击Cell的详情按钮，需要push一个VC，就可以这样：
 [[[cell.detailButton
 rac_signalForControlEvents:UIControlEventTouchUpInside]
 takeUntil:cell.rac_prepareForReuseSignal]
 subscribeNext:^(id x) {
 // generate and push ViewController
 }];
 如果不加takeUntil:cell.rac_prepareForReuseSignal，那么每次Cell被重用时，该button都会被addTarget:selector。
 
 */
