//
//  KSImagePickerEditPictureController.m
//  KSUserInterface
//
//  Created by Kinsun on 2018/12/10.
//  Copyright © 2018年 Kinsun. All rights reserved.
//

#import "KSImagePickerEditPictureController.h"
#import "KSImagePickerEditPictureView.h"
#import "KSImagePickerItemModel.h"
#import "KSImagePickerController.h"

@interface KSImagePickerEditPictureController ()

@property (nonatomic, strong) KSImagePickerEditPictureView *view;

@end

@implementation KSImagePickerEditPictureController
@dynamic view;

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.view setNeedsLayout];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"编辑照片";
    CGSize size = UIScreen.mainScreen.bounds.size;
    __weak typeof(self) weakSelf = self;
    [PHImageManager.defaultManager requestImageForAsset:_model.asset targetSize:size contentMode:PHImageContentModeAspectFill options:KSImagePickerItemModel.pictureViewerOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        weakSelf.view.imageView.image = result;
    }];
}

- (void)loadView {
    KSImagePickerEditPictureView *view = [[KSImagePickerEditPictureView alloc] init];
    [view.navigationView.doneButton addTarget:self action:@selector(_didClickDoneButton:) forControlEvents:UIControlEventTouchUpInside];
    view.circularMask = _circularMask;
    self.view = view;
}

- (void)didClickNavigationBackButton:(UIControl *)backButton {
    [self dismissViewController];
}

- (void)dismissViewController {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)_didClickDoneButton:(KSTextButton *)btn {
    if ([_delegate respondsToSelector:@selector(imagePickerEditPicture:didFinishSelectedImage:assetModel:)]) {
        KSImagePickerEditPictureView *view = self.view;
        CGRect contentRect = view.contentRect;
        CGSize size = contentRect.size;
        CGPoint origin = contentRect.origin;
        CGFloat scale = UIScreen.mainScreen.scale;
        CGRect rect = (CGRect){origin.x*scale, origin.y*scale, size.width*scale, size.height*scale};
        UIImage *newimage = [UIImage imageWithCGImage:CGImageCreateWithImageInRect(view.snapshot.CGImage, rect)];
        [_delegate imagePickerEditPicture:self didFinishSelectedImage:newimage assetModel:_model];
        
        NSArray<UIViewController *> *viewControllers = self.navigationController.viewControllers;
        NSUInteger index = [viewControllers indexOfObject:_delegate];
        if (index <= 0) {
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        } else {
            UIViewController *controller = [viewControllers objectAtIndex:index-1];
            [self.navigationController popToViewController:controller animated:YES];
        }
    }
}

@end
