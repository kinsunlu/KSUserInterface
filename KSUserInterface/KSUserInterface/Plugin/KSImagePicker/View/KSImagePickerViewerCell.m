//
//  KSImagePickerViewerCell.m
//  KSUserInterface
//
//  Created by Kinsun on 2018/12/4.
//  Copyright © 2018年 Kinsun. All rights reserved.
//

#import "KSImagePickerViewerCell.h"
#import "KSMediaViewerController.h"

@implementation KSImagePickerViewerCell
@dynamic mainView, data;

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UIImageView *imageView = UIImageView.alloc.init;
        [self.scrollView addSubview:imageView];
        self.mainView = imageView;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self settingImageViewFrameWithImage:self.mainView.image];
}

- (void)setData:(KSImagePickerItemModel *)data {
    [super setData:data];
    UIScrollView *scrollView = self.scrollView;
    scrollView.contentSize = scrollView.bounds.size;
    scrollView.contentOffset = CGPointZero;
    
    UIImageView *imageView = self.mainView;
    imageView.transform = CGAffineTransformIdentity;
    
    PHAsset *asset = data.asset;
    CGSize size = self.bounds.size;
    __weak typeof(self) weakSelf = self;
    UIImage *image = [KSImagePickerItemModel.photosCache objectForKey:asset.localIdentifier];
    if (image == nil) {
        [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeAspectFill options:KSImagePickerItemModel.pictureViewerOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            [weakSelf settingImageViewFrameWithImage:result];
            [KSImagePickerItemModel.photosCache setObject:result forKey:asset.localIdentifier];
            imageView.image = result;
        }];
    } else {
        [self settingImageViewFrameWithImage:image];
        imageView.image = image;
    }
}

- (void)settingImageViewFrameWithImage:(UIImage *)image {
    if (image != nil) {
        UIScrollView *scrollView = self.scrollView;
        UIImageView *imageView = self.mainView;
        CGSize windowSize = scrollView.bounds.size;
        CGFloat windowWidth = windowSize.width;
        CGFloat windowHeight = windowSize.height;
        CGSize size = image.size;
        CGFloat viewW = windowWidth;
        CGFloat viewH = size.height/size.width*viewW;
        if (viewH < windowHeight) {
            viewH = windowHeight;
            imageView.contentMode = UIViewContentModeScaleAspectFit;
        } else {
            imageView.contentMode = UIViewContentModeScaleToFill;
        }
        imageView.frame = (CGRect){CGPointZero, viewW, viewH};
        scrollView.contentSize = imageView.bounds.size;
    }
}

- (CGRect)mainViewFrameInSuperView {
    UIImageView *imageView = self.mainView;
    UIScrollView *scrollView = self.scrollView;
    return [KSMediaViewerController transitionThumbViewFrameInSuperView:scrollView atImage:imageView.image];
}

@end
