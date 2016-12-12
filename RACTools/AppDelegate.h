//
//  AppDelegate.h
//  RACTools
//
//  Created by 郑冰津 on 16/9/16.
//  Copyright © 2016年 IceGod. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;


@end

///RAC文档
//https://github.com/ziipin-code/ZiipinTemplateProject/blob/master/rac.md
//http://rxmarbles.com/#debounce  JS显示线路执行

///核心内涵函数学习
//http://blog.sunnyxx.com/2014/03/06/rac_2_racstream/


///基础学习
//http://www.jianshu.com/p/bae2eeba118d RAC基础方法练习
//http://fengjian0106.github.io/2016/04/17/The-Power-Of-Composition-In-FRP-Part-1/ 基础教程
//http://www.jianshu.com/p/4b99ddce3bae



//http://www.cnblogs.com/tangchangjiang/p/5645207.html
//http://www.cocoachina.com/ios/20140609/8737.html
//http://www.jianshu.com/p/e10e5ca413b7
//https://spin.atomicobject.com/2014/02/03/objective-c-delegate-pattern/
//https://github.com/aiqiuqiu/FRPCheatSheeta#原文地址
//http://www.jianshu.com/p/4fee21fb05b3
//http://www.teehanlax.com/blog/getting-started-with-reactivecocoa/
//http://www.cocoachina.com/ios/20150817/13071.html  代码四十八手
//http://www.cocoachina.com/cms/tags.php?/ReactiveCocoa/
//http://www.cocoachina.com/ios/20160729/17244.html
//http://www.cocoachina.com/ios/20160106/14880.html
//http://blog.sunnyxx.com/2014/04/19/rac_4_filters/
#pragma mark --------------实例demo
//https://github.com/leichunfeng/MVVMReactiveCocoa
//https://github.com/jiachenmu/ReactiveCocoaDemo


/*
 作用:
 在我们iOS开发过程中，经常会响应某些事件来处理某些业务逻辑，例如按钮的点击，上下拉刷新，网络请求，属性的变化（通过KVO）或者用户位置的变化（通过CoreLocation）。但是这些事件都用不同的方式来处理，比如action、delegate、KVO、callback等。
 其实这些事件，都可以通过RAC处理，ReactiveCocoa为事件提供了很多处理方法，而且利用RAC处理事件很方便，可以把要处理的事情，和监听的事情的代码放在一起，这样非常方便我们管理，就不需要跳到对应的方法里。非常符合我们开发中高聚合，低耦合的思想。
 编程思想:
 1,面向过程：处理事情以过程为核心，一步一步的实现。
 2,面向对象：万物皆对象
 3, 链式编程思想：是将多个操作（多行代码）通过点号(.)链接在一起成为一句代码,使代码可读性好。a(1).b(2).c(3).链式编程特点：方法的返回值是block,block必须有返回值（本身对象），block参数（需要操作的值）.代表：masonry框架。练习一:模仿masonry，写一个加法计算器，练习链式编程思想。
 4,响应式编程思想：不需要考虑调用顺序，只需要知道考虑结果，类似于蝴蝶效应，产生一个事件，会影响很多东西，这些事件像流一样的传播出去，然后影响结果，借用面向对象的一句话，万物皆是流。
 5,函数式编程思想：是把操作尽量写成一系列嵌套的函数或者方法调用。函数式编程本质:就是往方法中传入Block,方法中嵌套Block调用，把代码聚合起来管理.函数式编程特点：每个方法必须有返回值（本身对象）,把函数或者Block当做参数,block参数（需要操作的值）block返回值（操作结果）.代表：ReactiveCocoa。练习三:用函数式编程实现，写一个加法计算器,并且加法计算器自带判断是否等于某个值.
 ReactiveCocoa编程思想
 函数式编程（Functional Programming）
 
 响应式编程（Reactive Programming）
 
 所以，你可能听说过ReactiveCocoa被描述为函数响应式编程（FRP）框架。
 
 以后使用RAC解决问题，就不需要考虑调用顺序，直接考虑结果，把每一次操作都写成一系列嵌套的方法中，使代码高聚合，方便管理。
 RACSiganl主要类
 ===================================================================================
 ///具体函数的总结
 
 运用的是Hook（钩子）思想，Hook是一种用于改变API(应用程序编程接口：方法)执行结果的技术. Hook用处：截获API调用的技术。 Hook原理：在每次调用一个API返回结果之前，先执行你自己的方法，改变结果的输出
 
 
 1.3 ReactiveCocoa核心方法bind
 
 ReactiveCocoa操作的核心方法是bind（绑定）,而且RAC中核心开发方式，也是绑定，之前的开发方式是赋值，而用RAC开发，应该把重心放在绑定，也就是可以在创建一个对象的时候，就绑定好以后想要做的事情，而不是等赋值之后在去做事情。
 
 列如：把数据展示到控件上，之前都是重写控件的setModel方法，用RAC就可以在一开始创建控件的时候，就绑定好数据。
 
 在开发中很少使用bind方法，bind属于RAC中的底层方法，RAC已经封装了很多好用的其他方法，底层都是调用bind，用法比bind简单.
 
 bind方法简单介绍和使用。
 // 假设想监听文本框的内容，并且在每次输出结果的时候，都在文本框的内容拼接一段文字“输出：”
 
 // 方式一:在返回结果后，拼接。
 [_textField.rac_textSignal subscribeNext:^(id x) {
 
 NSLog(@"输出:%@",x);
 
 }];
 
 // 方式二:在返回结果前，拼接，使用RAC中bind方法做处理。
 // bind方法参数:需要传入一个返回值是RACStreamBindBlock的block参数
 // RACStreamBindBlock是一个block的类型，返回值是信号，参数（value,stop），因此参数的block返回值也是一个block。
 
 // RACStreamBindBlock:
 // 参数一(value):表示接收到信号的原始值，还没做处理
 // 参数二(*stop):用来控制绑定Block，如果*stop = yes,那么就会结束绑定。
 // 返回值：信号，做好处理，在通过这个信号返回出去，一般使用RACReturnSignal,需要手动导入头文件RACReturnSignal.h。
 
 // bind方法使用步骤:
 // 1.传入一个返回值RACStreamBindBlock的block。
 // 2.描述一个RACStreamBindBlock类型的bindBlock作为block的返回值。
 // 3.描述一个返回结果的信号，作为bindBlock的返回值。
 // 注意：在bindBlock中做信号结果的处理。
 
 // 底层实现:
 // 1.源信号调用bind,会重新创建一个绑定信号。
 // 2.当绑定信号被订阅，就会调用绑定信号中的didSubscribe，生成一个bindingBlock。
 // 3.当源信号有内容发出，就会把内容传递到bindingBlock处理，调用bindingBlock(value,stop)
 // 4.调用bindingBlock(value,stop)，会返回一个内容处理完成的信号（RACReturnSignal）。
 // 5.订阅RACReturnSignal，就会拿到绑定信号的订阅者，把处理完成的信号内容发送出来。
 
 // 注意:不同订阅者，保存不同的nextBlock，看源码的时候，一定要看清楚订阅者是哪个。
 // 这里需要手动导入#import <ReactiveCocoa/RACReturnSignal.h>，才能使用RACReturnSignal。
 [[_textField.rac_textSignal bind:^RACStreamBindBlock{
 
 // 什么时候调用:
 // block作用:表示绑定了一个信号.
 
 return ^RACStream *(id value, BOOL *stop){
 
 // 什么时候调用block:当信号有新的值发出，就会来到这个block。
 
 // block作用:做返回值的处理
 
 // 做好处理，通过信号返回出去.
 return [RACReturnSignal return:[NSString stringWithFormat:@"输出:%@",value]];
 };
 
 }] subscribeNext:^(id x) {
 
 NSLog(@"%@",x);
 
 }];
 
 ###############################
 However, RAC guarantees that no two signal events will ever arrive concurrently. While an event is being processed, no other events will be delivered. The senders of any other events will be forced to wait until the current event has been handled.
 意思是订阅者执行时的block一定非并发执行，也就是说不会执行到一半被另一个线程进入，也意味着写subscribeXXX block的时候没必要做加锁处理了。
 
 */
