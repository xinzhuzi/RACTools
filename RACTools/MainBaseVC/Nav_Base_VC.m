//
//  Nav_Base_VC.m
//  SOFTDA
//
//  Created by 郑冰津 on 16/7/20.
//  Copyright © 2016年 IceGod. All rights reserved.
//

#import "Nav_Base_VC.h"

@interface Nav_Base_VC ()

@end

@implementation Nav_Base_VC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    if(self.viewControllers.count>0){
        viewController.hidesBottomBarWhenPushed=YES; //当push 的时候隐藏底部兰
    }
    [super pushViewController:viewController animated:animated];
}
- (UIViewController *)popViewControllerAnimated:(BOOL)animated{
    UIViewController *VC=(self.viewControllers[self.viewControllers.count-1]);
    if ([(self.viewControllers[0]) isEqual:self.viewControllers[self.viewControllers.count-1]]) {
        VC.hidesBottomBarWhenPushed=NO;
    }else{
        VC.hidesBottomBarWhenPushed=YES;
    }
    [super popViewControllerAnimated:animated];
    return self.viewControllers[self.viewControllers.count-1];
}
- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated{
    if ([(UIViewController *)(self.viewControllers[0]) isEqual:viewController]) {
        viewController.hidesBottomBarWhenPushed=NO;
    }else{
        viewController.hidesBottomBarWhenPushed=YES;
    }
    [super popToViewController:viewController animated:animated];
    return self.viewControllers;
}
- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated{
    UIViewController *VC=(self.viewControllers[0]);
    VC.hidesBottomBarWhenPushed=NO;
    [super popToRootViewControllerAnimated:animated];
    return self.viewControllers;
}


@end
