//
//  KSBoxLayoutButton.h
//  KSUserInterface
//
//  Created by Kinsun on 2021/1/11.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KSBoxLayoutButton <__covariant ContentView: UIView *> : UIControl

@property (nonatomic, assign, getter=isRoundedCorners) BOOL roundedCorners;
@property (nonatomic, weak) ContentView contentView;
@property (nonatomic, assign) UIEdgeInsets contentInset;

@end

@interface KSImageButton : KSBoxLayoutButton<UIImageView *>

@property (nonatomic, weak) UIImageView *contentView;
@property (nullable, nonatomic) UIImage *normalImage;
@property (nullable, nonatomic) UIImage *selectedImage;

@end

@interface KSTextButton : KSBoxLayoutButton<UILabel *>

@property (nonatomic, weak) UILabel *contentView;
@property (nullable, nonatomic, copy) NSString *normalTitle;
@property (nullable, nonatomic, copy) NSString *selectedTitle;

@end

NS_ASSUME_NONNULL_END
