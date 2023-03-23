//
//  KSUserInterface.h
//  KSUserInterface
//
//  Created by Kinsun on 2020/11/30.
//  Copyright © 2020 Kinsun. All rights reserved.
//

#import <Foundation/Foundation.h>

//! Project version number for KSUserInterface.
FOUNDATION_EXPORT double KSUserInterfaceVersionNumber;

//! Project version string for KSUserInterface.
FOUNDATION_EXPORT const unsigned char KSUserInterfaceVersionString[];

#if __has_include(<KSUserInterface/KSBaseView.h>)
#import <KSUserInterface/KSBaseView.h>
#import <KSUserInterface/KSBaseViewController.h>
#import <KSUserInterface/KSLoadingView.h>
#import <KSUserInterface/KSNavigationView.h>
#import <KSUserInterface/KSTabBar.h>
#import <KSUserInterface/KSTabBarController.h>
#import <KSUserInterface/KSTabBarItem.h>
#import <KSUserInterface/UIColor+Hex.h>
#import <KSUserInterface/UIScrollview+Extension.h>
#import <KSUserInterface/UIControl+Convenient.h>
#import <KSUserInterface/KSToast.h>
#import <KSUserInterface/UIWindow+KSToast.h>
#import <KSUserInterface/KSUITools.h>
#endif

#if __has_include(<KSUserInterface/KSBaseWebView.h>)
#import <KSUserInterface/KSBaseWebView.h>
#import <KSUserInterface/KSBaseWebViewController.h>
#import <KSUserInterface/KSScriptWebView.h>
#endif

#if __has_include(<KSUserInterface/KSActionSheetViewController.h>)
#import <KSUserInterface/KSActionSheetViewController.h>
#import <KSUserInterface/KSAlertViewController.h>
#import <KSUserInterface/KSTransparentNavigationController.h>
#endif

#if __has_include(<KSUserInterface/KSTextBubbleView.h>)
#import <KSUserInterface/KSTextBubbleView.h>
#endif

#if __has_include(<KSUserInterface/KSImageView.h>)
#import <KSUserInterface/KSImageView.h>
#import <KSUserInterface/KSAnimationImageView.h>
#endif

#if __has_include(<KSUserInterface/KSBannerView.h>)
#import <KSUserInterface/KSBannerView.h>
#endif

#if __has_include(<KSUserInterface/KSButton.h>)
#import <KSUserInterface/KSBorderButton.h>
#import <KSUserInterface/KSButton.h>
#import <KSUserInterface/KSItemButton.h>
#import <KSUserInterface/KSBoxLayoutButton.h>
#import <KSUserInterface/KSGradientButton.h>
#endif

#if __has_include(<KSUserInterface/KSDialogView.h>)
#import <KSUserInterface/KSDialogView.h>
#endif

#if __has_include(<KSUserInterface/KSTriangleIndicatorButton.h>)
#import <KSUserInterface/KSIndicatorLabelControl.h>
#import <KSUserInterface/KSTriangleDisclosureIndicator.h>
#import <KSUserInterface/KSTriangleIndicatorButton.h>
#endif

#if __has_include(<KSUserInterface/KSImagePickerController.h>)
#import <KSUserInterface/KSImagePickerController.h>
#endif

#if __has_include(<KSUserInterface/KSMediaViewerController.h>)
#import <KSUserInterface/KSMediaViewerCell.h>
#import <KSUserInterface/KSMediaViewerController.h>
#import <KSUserInterface/KSMediaViewerView.h>
#endif

#if __has_include(<KSUserInterface/KSPageControl.h>)
#import <KSUserInterface/KSPageControl.h>
#endif

#if __has_include(<KSUserInterface/KSStackView.h>)
#import <KSUserInterface/KSStackView.h>
#endif

#if __has_include(<KSUserInterface/KSSegmentedControl.h>)
#import <KSUserInterface/KSSegmentedControl.h>
#import <KSUserInterface/KSPageSlideSegmented.h>
#endif

#if __has_include(<KSUserInterface/KSVideoLayer.h>)
#import <KSUserInterface/KSVideoLayer.h>
#import <KSUserInterface/KSVideoPlayerLiteView.h>
#endif

#if __has_include(<KSUserInterface/KSViewPager.h>)
#import <KSUserInterface/KSViewPager.h>
#endif
