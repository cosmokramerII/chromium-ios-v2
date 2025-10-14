//
//  BlinkEngine.h
//  ChromiumIOSv2
//
//  Core Blink rendering engine management for iOS
//  NOTE: This is a conceptual implementation. iOS does not support alternative browser engines.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BlinkEngine : NSObject

@property (nonatomic, readonly) BOOL isInitialized;
@property (nonatomic, readonly) NSString *version;
@property (nonatomic, readonly) NSString *userAgent;

+ (instancetype)sharedInstance;

- (BOOL)initializeEngine;
- (void)shutdownEngine;
- (void)setUserAgent:(NSString *)userAgent;

// Memory management
- (void)clearCache;
- (void)clearCookies;
- (NSUInteger)memoryUsage;

// JavaScript engine (V8)
- (void)enableV8;
- (void)disableV8;
- (BOOL)isV8Enabled;

@end

NS_ASSUME_NONNULL_END
