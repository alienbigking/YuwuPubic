//
//  PSAuthenticationHomePageViewController.h
//  PrisonService
//
//  Created by 狂生烈徒 on 2018/10/15.
//  Copyright © 2018年 calvin. All rights reserved.
//
#import "SDCycleScrollView.h"
#import "PSBusinessViewController.h"

@interface PSAuthenticationHomePageViewController : PSBusinessViewController
@property (nonatomic, strong, readonly) SDCycleScrollView *advView;
//是否显示广告
- (BOOL)showAdv;
@end
