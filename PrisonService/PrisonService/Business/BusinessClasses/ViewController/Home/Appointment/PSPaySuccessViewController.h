//
//  PSPaySuccessViewController.h
//  PrisonService
//
//  Created by calvin on 2018/4/23.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSBusinessViewController.h"
#import "PSPaymentBlock.h"

@interface PSPaySuccessViewController : PSBusinessViewController

@property (nonatomic, copy) PaymentClosed closeAction;

@end