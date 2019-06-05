//
//  PSPasswordViewModel.m
//  PrisonService
//
//  Created by 狂生烈徒 on 2019/5/20.
//  Copyright © 2019年 calvin. All rights reserved.
//

#import "PSPasswordViewModel.h"
#import <AFNetworking/AFNetworking.h>
#import "PSBusinessConstants.h"
#import "NSString+Utils.h"
@implementation PSPasswordViewModel
{
    AFHTTPSessionManager *manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        manager=[AFHTTPSessionManager manager];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        manager.requestSerializer.timeoutInterval = 10.f;
        [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        NSString*token=[NSString stringWithFormat:@"Bearer %@",[LXFileManager readUserDataForKey:@"access_token"]];
        [ manager.requestSerializer setValue:token forHTTPHeaderField:@"Authorization"];
    }
    return self;
}

- (void)checkPhoneDataWithCallback:(CheckDataCallback)callback{
    if (![NSString checkPassword:self.phone_password]) {
        if (callback) {
            callback(NO,@"密码至少包含数字,字母和字符2种组合!");
        }
        return;
    }
    if (callback) {
        callback(YES,nil);
    }
}
- (void)checkNewPhoneDataWithCallback:(CheckDataCallback)callback {
    if (![NSString checkPassword:self.phone_newPassword]) {
        if (callback) {
            callback(NO,@"密码至少包含数字,字母和字符2种组合!");
        }
        return;
    }
    if (callback) {
        callback(YES,nil);
    }
}


- (void)checkDataWithCallback:(CheckDataCallback)callback {
   
    if (![NSString checkPassword:self.phone_password]) {
        if (callback) {
            callback(NO,@"密码至少包含数字,字母和字符2种组合!");
        }
        return;
    }
    if (![NSString checkPassword:self.phone_newPassword]) {
        if (callback) {
            callback(NO,@"密码至少包含数字,字母和字符2种组合!");
        }
        return;
    }
    if (![self.phone_password isEqualToString:self.phone_newPassword]) {
        if (callback) {
            callback(NO,@"新密码与确定密码输入不一致!");
        }
        return;
    }
    
    if (callback) {
        callback(YES,nil);
    }
}

- (void)requestBoolPasswordCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback{
    NSString*url=[NSString stringWithFormat:@"%@/users/me/password",EmallHostUrl];
    [manager GET:url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (completedCallback) {
            completedCallback(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failedCallback) {
            failedCallback(error);
        }
    }];
}

- (void)requestPasswordCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback{
    NSDictionary*parmeters=@{@"newPassword":self.phone_password,};
    NSString*url=[NSString stringWithFormat:@"%@/users/me/password",EmallHostUrl];
    [manager PUT:url parameters:parmeters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (completedCallback) {
            completedCallback(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failedCallback) {
            failedCallback(error);
        }
    }];
}

- (void)requestResetPasswordCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback{
    NSString*url=[NSString stringWithFormat:@"%@/users/me/password/by-old-password",EmallHostUrl];
     NSDictionary*parmeters=
      @{@"oldPassword":self.phone_password,@"newPassword":self.phone_newPassword,};
    [manager PUT:url parameters:parmeters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (completedCallback) {
            completedCallback(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failedCallback) {
            failedCallback(error);
        }
    }];
}


- (void)requestByVerficationCodeCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback{
    NSString*url=[NSString stringWithFormat:@"%@/users/me/password/by-verification-code",EmallHostUrl];
    NSDictionary*parmeters=
    @{@"verificationCode":self.VerificationCode,@"newPassword":self.phone_newPassword,};
    [manager PUT:url parameters:parmeters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (completedCallback) {
            completedCallback(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failedCallback) {
            failedCallback(error);
        }
    }];
}



-(void)requestCodeCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback{
    NSString*url=[NSString stringWithFormat:@"%@/sms/verification-codes",EmallHostUrl];
    NSString*phone=[LXFileManager readUserDataForKey:@"phoneNumber"];
    NSDictionary *params = @{@"phoneNumber":phone};
    [manager POST:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSHTTPURLResponse * responses = (NSHTTPURLResponse *)task.response;
        self.Code=responses.statusCode;
        if (completedCallback) {
            completedCallback(responseObject);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failedCallback) {
            failedCallback(error);
        }
    }];
}


-(void)requestCodeVerificationCompleted:(RequestDataCompleted)completedCallback failed:(RequestDataFailed)failedCallback{
    NSString*url=[NSString stringWithFormat:@"%@/sms/verification-codes/verification",EmallHostUrl];
    
    NSString*phone=[LXFileManager readUserDataForKey:@"phoneNumber"];
    NSDictionary *params = @{@"phoneNumber":phone ,@"code":self.VerificationCode};
    [manager POST:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSHTTPURLResponse * responses = (NSHTTPURLResponse *)task.response;
        self.Code=responses.statusCode;
        if (completedCallback) {
            completedCallback(responseObject);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failedCallback) {
            failedCallback(error);
        }
    }];
}

@end