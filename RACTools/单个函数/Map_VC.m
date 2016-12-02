//
//  Map_VC.m
//  RACTools
//
//  Created by 郑冰津 on 2016/12/1.
//  Copyright © 2016年 IceGod. All rights reserved.
//

#import "Map_VC.h"

@implementation TestMapView

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


@interface Map_VC ()

@end

@implementation Map_VC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"映射";
    arrayVClass = @[@"map函数测试",@"flattenMap函数的操作",@"map和flattenMap函数的区别",@"mapReplace函数测试",@"tryMap的函数测试",@"flattenMap信号传递"].mutableCopy;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *selString = @[@"map_Function_Test",@"flattenMap_Function_EasyUse",@"map_flattenMap_Function",@"mapReplace_Function_EasyUse",@"tryMap_Function_EasyUse",@"racSignalPass"][indexPath.row];
    SEL gcdSEL = NSSelectorFromString(selString);
    if ([self respondsToSelector:gcdSEL]) {
        ((void (*)(id self, SEL))objc_msgSend)(self, gcdSEL);
    }
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
    TestMapView *tView = [[TestMapView alloc]initWithFrame:CGRectMake(0, 64, Screen_W, Screen_H-64)];
    UITextField *textField1 = (UITextField *)[tView viewWithTag:455];
    UILabel *label = (UILabel *)[tView viewWithTag:456];

    [self.view addSubview:tView];
    [[textField1.rac_textSignal map:^id(id value) {
        // 当源信号发出，就会调用这个block，修改源信号的内容
        // 返回值：就是处理完源信号的内容。
        return [NSString stringWithFormat:@"输出:%@",value];
    }] subscribeNext:^(id x) {
        NSLog(@"经过map映射并添加其他字符串处理的:\n%@",x);
    }];
    
    [[textField1.rac_textSignal map:^id(NSString * value) {
        // 当源信号发出，就会调用这个block，修改源信号的内容
        // 返回值：就是处理完源信号的内容。
        return @(value.length);
    }] subscribeNext:^(NSString * _Nullable x) {
        NSLog(@"经过map映射输入字符的长度:\n%@",x);
    }];
    
    [[[textField1.rac_textSignal map:^id(NSString * value) {
        return @(value.length);
    }] filter:^BOOL(NSNumber * number) {
        return number.integerValue>2;
    }] subscribeNext:^(id x) {
        NSLog(@"经过map映射和filter过滤字符超过2的才显示字符长度:\n%@",x);
    }];
    
    RAC(label, text) = [[[RACSignal interval:1 onScheduler:
                          [RACScheduler mainThreadScheduler]]
                         takeUntil:tView.rac_willDeallocSignal]
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
    TestMapView *tView = [[TestMapView alloc]initWithFrame:CGRectMake(0, 64, Screen_W, Screen_H-64)];
    UITextField *textField1 = (UITextField *)[tView viewWithTag:455];
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





