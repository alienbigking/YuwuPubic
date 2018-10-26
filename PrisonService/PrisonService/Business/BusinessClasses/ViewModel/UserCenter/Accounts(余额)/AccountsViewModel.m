//
//  AccountsViewModel.m
//  PrisonService
//
//  Created by 狂生烈徒 on 2018/5/30.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "AccountsViewModel.h"
#import "PSSessionManager.h"
#import "PSPrisonerAccountsRequest.h"
#import "PSPrisonerAcccountsResponse.h"
#import "PSBusinessConstants.h"
#import "PSCache.h"
#import <AFNetworking/AFNetworking.h>
#import "Accounts.h"
@interface AccountsViewModel()

@property(nonatomic ,strong)PSPrisonerAccountsRequest*accountsRequest;
@property (nonatomic, strong) NSMutableArray *accountsArray;
@end


@implementation AccountsViewModel



- (void)requestAccountsCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback {
    PSPrisonerDetail *prisonerDetail = nil;
    NSInteger index = [PSSessionManager sharedInstance].selectedPrisonerIndex;
    NSArray *details = [PSSessionManager sharedInstance].passedPrisonerDetails;
    if (index >= 0 && index < details.count) {
        prisonerDetail = details[index];
    }
    self.accountsRequest=[PSPrisonerAccountsRequest new];
    self.accountsRequest.jailId=prisonerDetail.jailId;
    self.session =[PSCache queryCache:AppUserSessionCacheKey];
    self.accountsRequest.familyId=self.session.families.id;
 
    [self.accountsRequest send:^(PSRequest *request, PSResponse *response) {
        PSPrisonerAcccountsResponse*accountsResponse=(PSPrisonerAcccountsResponse *)response;
        NSString*blance=[[NSString alloc]init];
        Accounts*model=accountsResponse.accounts[0];
        blance=model.balance;
        _blance=blance;
        if (completedCallback) {
            completedCallback(response);
        }
    } errorCallback:^(PSRequest *request, NSError *error) {
        if (failedCallback) {
            failedCallback(error);
        }
    }];
}
@end
