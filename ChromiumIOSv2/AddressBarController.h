//
//  AddressBarController.h
//  ChromiumIOSv2
//
//  Address bar controller with crash fixes and iOS 26 compatibility
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol AddressBarControllerDelegate;

@interface AddressBarController : UIViewController <UITextFieldDelegate>

@property (nonatomic, weak, nullable) id<AddressBarControllerDelegate> delegate;
@property (nonatomic, strong) UITextField *addressTextField;
@property (nonatomic, strong) UIButton *goButton;
@property (nonatomic, strong) UIButton *refreshButton;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *forwardButton;

- (instancetype)initWithFrame:(CGRect)frame;
- (void)updateURLDisplay:(NSString *)urlString;
- (void)setLoadingState:(BOOL)isLoading;

@end

@protocol AddressBarControllerDelegate <NSObject>

@required
- (void)addressBarController:(AddressBarController *)controller didRequestNavigationToURL:(NSURL *)url;
- (void)addressBarControllerDidRequestRefresh:(AddressBarController *)controller;
- (void)addressBarControllerDidRequestGoBack:(AddressBarController *)controller;
- (void)addressBarControllerDidRequestGoForward:(AddressBarController *)controller;

@end

NS_ASSUME_NONNULL_END