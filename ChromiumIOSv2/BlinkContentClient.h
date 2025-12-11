//
//  BlinkContentClient.h
//  ChromiumIOSv2
//
//  Chromium content client implementation for iOS
//  NOTE: This is a conceptual implementation. iOS does not support alternative browser engines.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BlinkContentClient : NSObject

@property (nonatomic, readonly) NSString *product;
@property (nonatomic, readonly) NSString *userAgent;

+ (instancetype)sharedInstance;

- (BOOL)initialize;
- (void)shutdown;

// Content module configuration
- (void)setEnableGPUAcceleration:(BOOL)enable;
- (void)setEnableJavaScript:(BOOL)enable;
- (void)setEnableImages:(BOOL)enable;
- (void)setEnablePlugins:(BOOL)enable;

// Renderer configuration
- (void)configureRendererProcess;
- (void)configureBrowserProcess;

@end

NS_ASSUME_NONNULL_END
