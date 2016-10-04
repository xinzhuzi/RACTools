//
//  RACSignal_VC.h
//  RACTools
//
//  Created by 郑冰津 on 2016/10/4.
//  Copyright © 2016年 IceGod. All rights reserved.
//

#import "Parent_Class_VC.h"

@interface RACSignal_VC : Parent_Class_VC

@end

/*
 NSAssert / NSCAssert
 NSParameterAssert / NSCParameterAssert
 这两组宏主要在功能和语义上有所差别，这些区别主要有以下两点：
 
 如果我们需要确保方法或函数的输入参数的正确性，则应该在方法(函数)的顶部使用NSParameterAssert / NSCParameterAssert；而在其它情况下，使用NSAssert / NSCAssert。
 另一个不同是介于C和Objective-C之间。NSAssert / NSParameterAssert应该用于Objective-C的上下文(方法)中，而NSCAssert / NSCParameterAssert应该用于C的上下文(函数)中。
 */
