//
//  SignalTestView.h
//  RACTools
//
//  Created by 郑冰津 on 2016/10/5.
//  Copyright © 2016年 IceGod. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RACToolsHeader.h"


@protocol SignalTestViewDelegate <NSObject>

@optional
- (void)testButtonClickDelegate:(id )obj;

@end

@interface SignalTestView : UIScrollView<SignalTestViewDelegate>

///替代代理的信号,其实这种方式的用法是非常LOW比的方式
@property (nonatomic,strong)RACSubject *delegateSignal;

- (instancetype)initWithFrame:(CGRect)frame;

@end
