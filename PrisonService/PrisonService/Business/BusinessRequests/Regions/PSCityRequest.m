//
//  PSCityRequest.m
//  PrisonService
//
//  Created by calvin on 2018/4/8.
//  Copyright © 2018年 calvin. All rights reserved.
//

#import "PSCityRequest.h"

@implementation PSCityRequest

- (id)init {
    self = [super init];
    if (self) {
        self.method = PSHttpMethodGet;
        self.serviceName = @"citys";
    }
    return self;
}

- (void)buildParameters:(PSMutableParameters *)parameters {
    
    NSArray *langArr = [[NSUserDefaults standardUserDefaults] valueForKey:@"AppleLanguages"];
    
    NSString *language = langArr.firstObject;
    
    if ([language isEqualToString:@"vi-US"]||[language isEqualToString:@"vi-CN"]||[language isEqualToString:@"vi-VN"]) {
        self.language=@"vie";
    }
    [parameters addParameter:self.language forKey:@"language"];
    [parameters addParameter:self.provicesId forKey:@"provicesId"];
    [super buildParameters:parameters];
}

- (Class)responseClass {
    return [PSCityResponse class];
}

@end