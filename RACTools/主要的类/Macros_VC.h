//
//  Macros_VC.h
//  MyTools
//
//  Created by 郑冰津 on 16/8/31.
//  Copyright © 2016年 IceGod. All rights reserved.
//

#import "Parent_Class_VC.h"

@interface Macros_VC : Parent_Class_VC

@end

/*
 http://blog.sunnyxx.com/2014/03/06/rac_1_macros/
 @weakify(Obj);弱引用宏
 @strongify(Obj);强引用宏
 
 使用RAC(self, outputLabel)或RACObserve(self, name)时输入第二个property的时候会出现完全正确的代码提示
 关键在于:#define keypath(...) \    metamacro_if_eq(1, metamacro_argcount(__VA_ARGS__))(keypath1(__VA_ARGS__))(keypath2(__VA_ARGS__))
 这个metamacro_argcount上面说过，是计算可变参数个数，所以metamacro_if_eq的作用就是判断参数个数，如果个数是1就执行后面的keypath1，若不是1就执行keypath2。
 #define keypath2(OBJ, PATH) \
 (((void)(NO && ((void)OBJ.PATH, NO)), # PATH))
 简化成#define keypath2(OBJ, PATH) (???????, # PATH)
 先不管”??????”是啥，这里不得不说C语言中一个不大常见的语法（第一个忽略）：
 int a = 0, b = 0;
 a = 1, b = 2;
 int c = (a, b);
 这些都是逗号表达式的合理用法，第三个最不常用了，c将被b赋值，而a是一个未使用的值，编译器会给出warning。
 去除warning的方法很简单，强转成void就行了：int c = ((void)a, b);
 再看上面简化的keypath2宏，返回的就是PATH的字符串字面值了(单#号会将传入值转成字面字符串)
 (((void)(NO && ((void)OBJ.PATH, NO)), # PATH))
 对传入的第一个参数OBJ和第二个正要输入的PATH做了点操作，这也正是为什么输入第二个参数时编辑器会给出正确的代码提示。强转void就像上面说的去除了warning。
 　但至于为什么加入与NO做&&，我不太能理解，我测试时其实没有时已经完成了功能，可能是作者为了屏蔽某些隐藏的问题吧。
 这个宏的巧妙的地方就在于使得编译器以为我们要输入“点”出来的属性，保证了输入值的合法性（输了不存在的property直接报错的），同时利用了逗号表达式取逗号最后值的语法返回了正确的keypath。


 */
