//
//  BAAPI.m
//  BalancedPayments
//
//  Created by Victor Lin on 2014/12/29.
//  Copyright (c) 2014年 Balanced Payments. All rights reserved.
//

#import <DDLog.h>
#import <AFNetworking+PromiseKit.h>
#import "BAAPI.h"
#import "BAMarketplace.h"

static const int ddLogLevel = LOG_LEVEL_INFO;

@implementation BAAPI

- (id) init {
    return [self initWithBaseURL:@"https://api.balancedpayments.com"];
}

- (id) initWithBaseURL:(NSString *)baseURL {
    self = [super init];
    if (self) {
        _baseURL = baseURL;
        _httpManager = [AFHTTPRequestOperationManager manager];
        _httpManager.requestSerializer = [AFJSONRequestSerializer serializer];
        _httpManager.responseSerializer = [AFJSONResponseSerializer serializer];
        [_httpManager.requestSerializer setValue:@"application/vnd.api+json;revision=1.1" forHTTPHeaderField:@"Accept"];
    }
    return self;
}

- (NSString *)apiURLFromPath:(NSString *)path {
    return [NSString stringWithFormat:@"%@%@", self.baseURL, path];
}

- (PMKPromise *) loadResourcesFromPath:(NSString *)path {
    DDLogInfo(@"Loading resources from %@", path);
    NSString *url = [self apiURLFromPath:path];
    PMKPromise *promise = [self.httpManager GET:url parameters:nil].then(^(id responseObject, AFHTTPRequestOperation *operation) {
        DDLogInfo(@"Loading resources from %@ recived response %@", path, responseObject);
        return responseObject;
    }).catch(^(NSError *error){
        DDLogError(@"error happened: %@", error.localizedDescription);
        DDLogError(@"original operation: %@", error.userInfo[AFHTTPRequestOperationErrorKey]);
        return error;
    });
    return promise;
}

- (void) setApiKey:(NSString *)apiKey {
    _apiKey = apiKey;
    [_httpManager.requestSerializer setAuthorizationHeaderFieldWithUsername:apiKey password:@""];
}

+ (BAAPI *) api {
    return [[BAAPI alloc] init];
}

@end
