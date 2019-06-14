//
//  SPUURLRequest.m
//  Sparkle
//
//  Created by Mayur Pawashe on 5/19/16.
//  Copyright © 2016 Sparkle Project. All rights reserved.
//

#import "SPUURLRequest.h"


#include "AppKitPrevention.h"

static NSString *SPUURLRequestURLKey = @"SPUURLRequestURL";
static NSString *SPUURLRequestCachePolicyKey = @"SPUURLRequestCachePolicy";
static NSString *SPUURLRequestTimeoutIntervalKey = @"SPUURLRequestTimeoutInterval";
static NSString *SPUURLRequestHttpHeaderFieldsKey = @"SPUURLRequestHttpHeaderFields";
static NSString *SPUURLRequestNetworkServiceTypeKey = @"SPUURLRequestNetworkServiceType";
static NSString *SPUURLRequestMethodKey = @"SPUURLRequestMethodKey";
static NSString *SPUURLRequestHTTPBodyKey = @"SPUURLRequestHTTPBodyKey";

@interface SPUURLRequest ()

@property (nonatomic, readonly) NSURL *url;
@property (nonatomic, readonly) NSString *method;
@property (nonatomic, readonly) NSData *httpBody;
@property (nonatomic, readonly) NSURLRequestCachePolicy cachePolicy;
@property (nonatomic, readonly) NSTimeInterval timeoutInterval;
@property (nonatomic, readonly, nullable) NSDictionary<NSString *, NSString *> *httpHeaderFields;
@property (nonatomic, readonly) NSURLRequestNetworkServiceType networkServiceType;

@end

@implementation SPUURLRequest

@synthesize url = _url;
@synthesize method = _method;
@synthesize httpBody = _httpBody;
@synthesize cachePolicy = _cachePolicy;
@synthesize timeoutInterval = _timeoutInterval;
@synthesize httpHeaderFields = _httpHeaderFields;
@synthesize networkServiceType = _networkServiceType;

- (instancetype)initWithURL:(NSURL *)url method:(NSString *)method httpBody:(NSData*)httpBody cachePolicy:(NSURLRequestCachePolicy)cachePolicy timeoutInterval:(NSTimeInterval)timeoutInterval httpHeaderFields:(NSDictionary<NSString *, NSString *> *)httpHeaderFields networkServiceType:(NSURLRequestNetworkServiceType)networkServiceType
{
    self = [super init];
    if (self != nil) {
        _url = url;
        _method = method;
        _httpBody = httpBody;
        _cachePolicy = cachePolicy;
        _timeoutInterval = timeoutInterval;
        _httpHeaderFields = httpHeaderFields;
        _networkServiceType = networkServiceType;
    }
    return self;
}

+ (instancetype)URLRequestWithRequest:(NSURLRequest *)request
{
    return [(SPUURLRequest *)[[self class] alloc] initWithURL:request.URL method:request.HTTPMethod httpBody:request.HTTPBody cachePolicy:request.cachePolicy timeoutInterval:request.timeoutInterval httpHeaderFields:request.allHTTPHeaderFields networkServiceType:request.networkServiceType];
}

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.url forKey:SPUURLRequestURLKey];
    [coder encodeInteger:self.cachePolicy forKey:SPUURLRequestCachePolicyKey];
    [coder encodeDouble:self.timeoutInterval forKey:SPUURLRequestTimeoutIntervalKey];
    [coder encodeInteger:self.networkServiceType forKey:SPUURLRequestNetworkServiceTypeKey];
    
    if (self.httpHeaderFields != nil) {
        [coder encodeObject:self.httpHeaderFields forKey:SPUURLRequestHttpHeaderFieldsKey];
    }

    [coder encodeObject:self.method forKey:SPUURLRequestMethodKey];
    if(self.httpBody != nil) {
        [coder encodeObject:self.httpBody forKey:SPUURLRequestHTTPBodyKey];
    }
}

- (instancetype)initWithCoder:(NSCoder *)decoder
{
    if (@available(macOS 10.8, *)) {
        NSURL *url = [decoder decodeObjectOfClass:[NSURL class] forKey:SPUURLRequestURLKey];
        NSURLRequestCachePolicy cachePolicy = (NSURLRequestCachePolicy)[decoder decodeIntegerForKey:SPUURLRequestCachePolicyKey];
        NSTimeInterval timeoutInterval = [decoder decodeDoubleForKey:SPUURLRequestTimeoutIntervalKey];
        NSDictionary<NSString *, NSString *> *httpHeaderFields = [decoder decodeObjectOfClasses:[NSSet setWithArray:@[[NSDictionary class], [NSString class]]] forKey:SPUURLRequestHttpHeaderFieldsKey];
        NSURLRequestNetworkServiceType networkServiceType = (NSURLRequestNetworkServiceType)[decoder decodeIntegerForKey:SPUURLRequestNetworkServiceTypeKey];
        NSString *method = [decoder decodeObjectOfClass:[NSString class] forKey:SPUURLRequestMethodKey];
        if(method == nil) {
            method = @"GET";
        }
        NSData* httpBody = [decoder decodeObjectOfClass:[NSData class] forKey:SPUURLRequestHTTPBodyKey];

        return [self initWithURL:url method:method httpBody:httpBody cachePolicy:cachePolicy timeoutInterval:timeoutInterval httpHeaderFields:httpHeaderFields networkServiceType:networkServiceType];
    } else {
        abort(); // Not used on 10.7
    }
}

- (NSURLRequest *)request
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.url cachePolicy:self.cachePolicy timeoutInterval:self.timeoutInterval];
    if (self.httpHeaderFields != nil) {
        request.allHTTPHeaderFields = self.httpHeaderFields;
    }
    request.networkServiceType = self.networkServiceType;

    if(self.method != nil) {
        request.HTTPMethod = self.method;
    }

    if(self.httpBody != nil) {
        request.HTTPBody = self.httpBody;
    }

    return [request copy];
}

@end
