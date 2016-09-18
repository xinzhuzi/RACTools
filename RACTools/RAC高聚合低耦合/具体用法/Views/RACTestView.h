//
//  RACDelegateView.h
//  MyTools
//
//  Created by 郑冰津 on 16/8/24.
//  Copyright © 2016年 IceGod. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RACToolsHeader.h"

@protocol RACTestViewDelegate <NSObject>

@optional
- (void)testButtonClickDelegate:(id )obj;

@end


@interface RACTestView : UIScrollView<RACTestViewDelegate>

///代理
@property (nonatomic,strong)RACSubject *delegateSignal;

- (instancetype)initWithFrame:(CGRect)frame;

@end
