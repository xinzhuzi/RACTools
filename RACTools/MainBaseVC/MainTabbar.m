//
//  MainTabbar.m
//  SOFTDA
//
//  Created by 郑冰津 on 16/7/20.
//  Copyright © 2016年 IceGod. All rights reserved.
//

#import "MainTabbar.h"
#import "Nav_Base_VC.h"

static MainTabbar *tabbar=nil;

@interface MainTabbar ()<UITabBarControllerDelegate>

@end

@implementation MainTabbar

SingletonM(MainTabbar)

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSMutableArray *arrayVC =@[@"RACClass_VC",@"RACCommonFunction_VC",@"RACUI_VC",@"RACCustomSignal_VC"].mutableCopy;
    NSArray *imageArray = @[@"tab_recent_nor",@"tab_buddy_nor",@"tab_conference_nor",@"tab_me_nor"];
    NSArray *sImageArray = @[@"tab_recent_press",@"tab_buddy_press",@"tab_conference_press",@"tab_me_press"];
    
    for (NSInteger i = 0; i<arrayVC.count; i++) {
        NSString *nameVC=arrayVC[i];
        Class VC=NSClassFromString(nameVC);
        Nav_Base_VC *thisNav=[self viewController:VC.new title:@[@"主要类",@"单个函数",@"UI类",@"自定义信号"][i] image:[UIImage imageNamed:imageArray[i]] selectedImage:[UIImage imageNamed:sImageArray[i]]];
        [arrayVC replaceObjectAtIndex:i withObject:thisNav];
    }
    
    self.viewControllers = arrayVC;
    self.delegate=self;
    self.selectedIndex=0;
    
}
-(Nav_Base_VC *)viewController:(UIViewController *)viewController title:(NSString *)title image:(UIImage *)image selectedImage:(UIImage *)selectedImage{
    Nav_Base_VC *nav=[[Nav_Base_VC alloc]initWithRootViewController:viewController];
    nav.tabBarItem.title = title;
    viewController.title = title;
    ///保持图片的原始状态
    nav.tabBarItem.image=[image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    nav.tabBarItem.selectedImage=[selectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [nav.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName:HEXCOLOR(0x666666),NSFontAttributeName:[UIFont systemFontOfSize:17]} forState:UIControlStateNormal];//正常
    [nav.tabBarItem setTitleTextAttributes:                                                         @{NSForegroundColorAttributeName:HEXCOLOR(0x05b8f3),NSFontAttributeName:[UIFont systemFontOfSize:17]} forState:UIControlStateSelected];//被选中
    return nav;
}

@end
