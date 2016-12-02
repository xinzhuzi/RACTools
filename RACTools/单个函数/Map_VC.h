//
//  Map_VC.h
//  RACTools
//
//  Created by 郑冰津 on 2016/12/1.
//  Copyright © 2016年 IceGod. All rights reserved.
//

#import "Parent_Class_VC.h"

@interface TestMapView : UIView

- (instancetype)initWithFrame:(CGRect)frame;

@end

@interface Map_VC : Parent_Class_VC

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
