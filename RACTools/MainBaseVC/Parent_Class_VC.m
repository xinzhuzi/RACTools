//
//  Parent_Class_VC.m
//  SOFTDA
//
//  Created by 郑冰津 on 16/7/20.
//  Copyright © 2016年 IceGod. All rights reserved.
//

#import "Parent_Class_VC.h"

@interface Parent_Class_VC ()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation Parent_Class_VC



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets=NO;
    self.view.backgroundColor=[UIColor whiteColor];
    self.extendedLayoutIncludesOpaqueBars = YES;
    ///这一句不注明,会因为按下home键,再次启动APP信号栏会有黑色的问题!,因为NAV本身是黑色的
    [self.navigationController.view setBackgroundColor:[UIColor whiteColor]];
    
    UITableView *tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 64, Screen_W, Screen_H-64) style:UITableViewStyleGrouped];
    tableView.delegate=self;
    tableView.dataSource=self;
    [self.view addSubview:tableView];
    [tableView setSeparatorColor:[UIColor purpleColor]];
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
    }
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
    }
    baseTableView = tableView;
}

#pragma mark -------------------------UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return arrayVClass.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01f;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.01f;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *IDCell=@"IDCell";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:IDCell];
    if (!cell) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:IDCell];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
            [cell setSeparatorInset:UIEdgeInsetsZero];
        }
        if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
            [cell setLayoutMargins:UIEdgeInsetsZero];
        }
        cell.layer.shouldRasterize = YES;
        cell.layer.rasterizationScale = [UIScreen mainScreen].scale;
    }
    cell.textLabel.text=arrayVClass[indexPath.row];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *nameVC=arrayVClass[indexPath.row];
    Class VC=NSClassFromString(nameVC);
    //    NSLog(@"push---> %@",arrayVClass[indexPath.row]);
    if (VC) {
        [self.navigationController pushViewController:[VC new] animated:YES];
    }
    //    NSBundle *bundle=[NSBundle mainBundle];
    //    NSString *path=[bundle pathForResource:nameVC ofType:@"class"];
    //    Class newClass=[bundle classNamed:nameVC];
    //    if (newClass) {
    //        NSLog(@"bundle: 可以用这个东西跳转VC");
    //    }
}


@end
