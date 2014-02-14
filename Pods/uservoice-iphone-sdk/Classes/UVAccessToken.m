//
//  UVAccessToken.m
//  UserVoice
//
//  Created by Scott Rutherford on 16/05/2010.
//  Copyright 2010 UserVoice Inc. All rights reserved.
//

#import "UVAccessToken.h"
#import "UVRequestToken.h"
#import "YOAuthToken.h"
#import "UVSession.h"
#import "UVConfig.h"

@implementation UVAccessToken

+ (BOOL)exists {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    return [prefs stringForKey:@"uv-iphone-k"] != nil;
}

- (void)remove {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs removeObjectForKey:@"uv-iphone-k"];
    [prefs removeObjectForKey:@"uv-iphone-s"];
    [prefs synchronize];
}

- (id)revoke:(id) delegate {
    NSString *path = [[self class] apiPath:[NSString stringWithFormat:@"/oauth/revoke.json"]];

    SEL didRevokeToken = sel_registerName("didRovokeToken:");
    id returnValue;
    if ([delegate respondsToSelector:didRevokeToken]){
        returnValue = [[self class] getPath:path
                                withParams:nil
                                    target:delegate
                                  selector:didRevokeToken
                                   rootKey:@"token"];
    }
    
    [self remove];
    [UVSession currentSession].user = nil;
    return returnValue;
}

// check to see if a token exists on the device and if so load it
// if not get a request token from the api
- (id)initWithExisting {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    return [self initWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
                                     [prefs stringForKey:@"uv-iphone-k"], @"oauth_token",
                                     [prefs stringForKey:@"uv-iphone-s"], @"oauth_token_secret", nil]];
}

+ (id)getAccessTokenWithDelegate:(id)delegate andEmail:(NSString *)email andPassword:(NSString *)password {
    NSString *path = [[self class] apiPath:[NSString stringWithFormat:@"/oauth/authorize.json"]];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            password, @"password",
                            email, @"email",
                            [UVSession currentSession].requestToken.oauthToken.key, @"request_token", nil];

    SEL didRetrieveAccessToken = sel_registerName("didRetrieveAccessToken:");
    if ([delegate respondsToSelector:didRetrieveAccessToken]) {
        return [self getPath:path
                  withParams:params
                      target:delegate
                    selector:didRetrieveAccessToken
                     rootKey:@"token"];
    }
    return nil;
}

- (void)persist {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];

    [prefs setObject:_oauthToken.key forKey:@"uv-iphone-k"];
    [prefs setObject:_oauthToken.secret forKey:@"uv-iphone-s"];
    [prefs synchronize];
}

- (id)initWithDictionary:(NSDictionary *)dict {
    if (self = [super init]) {
        _oauthToken = [YOAuthToken tokenWithDictionary:dict];
    }
    return self;
}

@end
