//
//  PSMailBoxesDetailRequest.m
//  PrisonService
//
//  Created by kky on 2018/12/27.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSMailBoxesDetailRequest.h"
#import "PSFeedbackDetailResponse.h"

@implementation PSMailBoxesDetailRequest

- (id)init {
    self = [super init];
    if (self) {
        self.method = PSHttpMethodGet;
        self.serviceName = @"detail";
    }
    return self;
}

- (NSString *)businessDomain {
    return @"/api/mailboxes/";
}

- (void)buildParameters:(PSMutableParameters *)parameters {
    [parameters addParameter:[NSString stringWithFormat:@"%@",self.id] forKey:@"id"];
    [super buildParameters:parameters];
}

- (Class)responseClass {
    return [PSFeedbackDetailResponse class];
}

@end