
//
//  HeaderZSJPractive.h
//  ZSJPractice
//
//  Created by ZhouLord on 16/1/21.
//  Copyright © 2016年 junL. All rights reserved.
//

// 帮助实现单例设计模式

// .h文件的实现
#define SingletonH(methodName) + (instancetype)shared##methodName;

// .m文件的实现
#if __has_feature(objc_arc) // 是ARC
#define SingletonM(methodName) \
static id _instace = nil; \
+ (id)allocWithZone:(struct _NSZone *)zone \
{ \
if (_instace == nil) { \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
_instace = [super allocWithZone:zone]; \
}); \
} \
return _instace; \
} \
\
- (id)init \
{ \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
_instace = [super init]; \
}); \
return _instace; \
} \
\
+ (instancetype)shared##methodName \
{ \
return [[self alloc] init]; \
} \
+ (id)copyWithZone:(struct _NSZone *)zone \
{ \
return _instace; \
} \
\
+ (id)mutableCopyWithZone:(struct _NSZone *)zone \
{ \
return _instace; \
}

#else // 不是ARC

#define SingletonM(methodName) \
static id _instace = nil; \
+ (id)allocWithZone:(struct _NSZone *)zone \
{ \
if (_instace == nil) { \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
_instace = [super allocWithZone:zone]; \
}); \
} \
return _instace; \
} \
\
- (id)init \
{ \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
_instace = [super init]; \
}); \
return _instace; \
} \
\
+ (instancetype)shared##methodName \
{ \
return [[self alloc] init]; \
} \
\
- (oneway void)release \
{ \
\
} \
\
- (id)retain \
{ \
return self; \
} \
\
- (NSUInteger)retainCount \
{ \
return 1; \
} \
+ (id)copyWithZone:(struct _NSZone *)zone \
{ \
return _instace; \
} \
\
+ (id)mutableCopyWithZone:(struct _NSZone *)zone \
{ \
return _instace; \
}

#endif

#pragma mark ---------------第三方库--------------
#import "ReactiveObjC/ReactiveObjC.h"

#pragma mark ---------------小工具--------------

#pragma mark ---------------UI宏定义--------------
#define Screen_H [UIScreen mainScreen].bounds.size.height
#define Screen_W [UIScreen mainScreen].bounds.size.width

#define HEXCOLOR(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define RGBA_Color(r,g,b,a)      [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]

#define KeyBoardDisappear [[[UIApplication sharedApplication] keyWindow] endEditing:YES]

#pragma mark ---------------辅助工具宏定义--------------
#define BeginCodeTime   [[NSUserDefaults standardUserDefaults] setDouble:CACurrentMediaTime() forKey:@"代码运行开始时间"];\
[[NSUserDefaults standardUserDefaults] synchronize]
#define EndCodeTime NSLog(@"代码执行耗费了:%8.2f ms",(CACurrentMediaTime() - [[NSUserDefaults standardUserDefaults] doubleForKey:@"代码运行开始时间"]) *1000)
#define weakSelf(ws)  __weak typeof(&*self)ws = self

///iOS版本
#define iOS_9_Later  [[[UIDevice currentDevice] systemVersion] doubleValue] >= 9.0
#define iOS_8_Later  [[[UIDevice currentDevice] systemVersion] doubleValue] >= 8.0
#define iOS_7  [[[UIDevice currentDevice] systemVersion] doubleValue] >= 7.0 && [[[UIDevice currentDevice] systemVersion] floatValue] < 8.0
#define iOS_6  [[[UIDevice currentDevice] systemVersion] doubleValue] >= 6.0 && [[[UIDevice currentDevice] systemVersion] floatValue] < 7.0

//（1）__OPTIMIZE__  :用于release和debug的判断，当选择了__OPTIMIZE__  时，可以让代码在release时执行，在debug时不执行。示例如下：
//（2）__i386__ 与 __x86_64__   ：用于模拟器环境和真机环境的判断。满足该条件的代码只在模拟器下执行。示例代码如下：
#if defined (__i386__) || defined (__x86_64__)
//模拟器
#else

#endif
//（3）__IPHONE_OS_VERSION_MAX_ALLOWED  :当前编译的SDK版本，可以与__IPHONE_9_0等宏定义进行比较，进行不同版本下代码的执行。示例如下：
// (4)预编译宏 #ifdef     #else   #endif 如果标识符aaaaa已被#define命令定义过，则对代码1进行编译，否则对代码2进行编译。
#define aaaaa
#ifdef aaaaa
///声明则执行这里面的东西 1
#else
///不声明则执行这里面的东西 2
#endif

#if __has_feature(objc_arc)
#define MemoryTypeAPP @"ARC情况下"
#else
#define MemoryTypeAPP @"MRC情况下"
#endif



#pragma mark ------------iOS10版本产生的问题-------------
/*
 iOS10相册相机闪退bug
 http://www.jianshu.com/p/5085430b029f
 iOS 10 因苹果健康导致闪退 crash
 http://www.jianshu.com/p/545bd1bf5a23
 麦克风、多媒体、地图、通讯录
 ios10相机等崩溃
 http://www.jianshu.com/p/ec15dadd38f3
 iOS10 配置须知
 http://www.jianshu.com/p/65f21dc5c556
 iOS开发 适配iOS10以及Xcode8
 http://www.jianshu.com/p/9756992a35ca
 iOS 10 的适配问题
 http://www.jianshu.com/p/f8151d556930
 */
