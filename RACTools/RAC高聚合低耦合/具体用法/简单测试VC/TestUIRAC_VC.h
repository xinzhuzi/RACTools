//
//  TextUIRAC_VC.h
//  MyTools
//
//  Created by 郑冰津 on 16/8/25.
//  Copyright © 2016年 IceGod. All rights reserved.
//

#import "Parent_Class_VC.h"

@interface TestUIRAC_VC : Parent_Class_VC

@end


/*

 rac_signalForControlEvents
 #########################################################
 class:UITextField/UITextView
    1.主要函数为rac_textSignal
    2.调用方式为:实例对象.rac_textSignal
 class:UITableViewHeaderFooterView / UITableViewCell /UICollectionReusableView
    1.唯一函数为rac_prepareForReuseSignal
    2.调用方式为:takeUntil:实例对象.rac_prepareForReuseSignal,防止内存泄露
 class:UISwitch
    1.唯一函数为- (RACChannelTerminal *)rac_newOnChannel  RACChannelTerminal继承与RACSignal
    2.调用方式为:实例对象.rac_newOnChannel
 class:UIStepper / UISlider
    1.唯一函数为 - (RACChannelTerminal *)rac_newValueChannelWithNilValue:(NSNumber *)nilValue;
    2.调用方式为:实例对象.rac_newValueChannelWithNilValue:@()
 class:UISegmentedControl
    1.唯一函数为 - (RACChannelTerminal *)rac_newSelectedSegmentIndexChannelWithNilValue:(NSNumber *)nilValue;
    2.调用方式为:实例对象.rac_newSelectedSegmentIndexChannelWithNilValue:@()
 class:UISegmentedControl
    1.唯一函数为 - (RACChannelTerminal *)rac_newSelectedSegmentIndexChannelWithNilValue:(NSNumber *)nilValue;
    2.调用方式为:实例对象.rac_newSelectedSegmentIndexChannelWithNilValue:@()
 class:UIRefreshControl
    1.
    2.
 class:UIImagePickerController
    1.主要函数:rac_imageSelectedSignal
    2.调用方式为:实例对象.rac_imageSelectedSignal
 class:UIGestureRecognizer
    1.唯一函数:rac_gestureSignal
    2.调用方式为:实例对象.rac_gestureSignal
 class:UIDatePicker
    1.唯一函数:- (RACChannelTerminal *)rac_newDateChannelWithNilValue:(NSDate *)nilValue
    2.调用方式为:实例对象.rac_newDateChannelWithNilValue:(NSDate *)nilValue
 class:UIControl
    1.唯一函数:- (RACChannelTerminal *)rac_channelForControlEvents:(UIControlEvents)controlEvents key:(NSString *)key nilValue:(id)nilValue
    2.调用方式为,所有继承与UIControl的都可以调用此方法
 class:UIButton
    1.唯一属性:RACCommand<__kindof UIBarButtonItem *> *rac_command
    2.调用方式为,调用UIControl的父类方法,??????????????
 class:UIBarButtonItem
    1.唯一属性:RACCommand<__kindof UIBarButtonItem *> *rac_command
    2.调用方式为,????????????
 */