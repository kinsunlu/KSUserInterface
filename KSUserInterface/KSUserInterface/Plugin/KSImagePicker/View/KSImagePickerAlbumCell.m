//
//  KSImagePickerAlbumCell.m
//  KSUserInterface
//
//  Created by Kinsun on 2018/12/2.
//  Copyright © 2018年 Kinsun. All rights reserved.
//

#import "KSImagePickerAlbumCell.h"
 

@implementation KSImagePickerAlbumCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        UIImageView *imageView = self.imageView;
        imageView.image = [UIImage imageNamed:@"KSUserInterface.bundle/icon_transparent"];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        
        UILabel *textLabel = self.textLabel;
        textLabel.font = [UIFont systemFontOfSize:18.f];
        textLabel.textColor = UIColor.blackColor;
        
        UILabel *detailTextLabel = self.detailTextLabel;
        detailTextLabel.font = [UIFont systemFontOfSize:15.f];
        detailTextLabel.textColor = [UIColor.blackColor colorWithAlphaComponent:0.5f];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGSize windowSize = self.contentView.bounds.size;
    CGFloat windowWidth = windowSize.width;
    CGFloat windowHeight = windowSize.height;
    
    UIImageView *imageView = self.imageView;
    CGFloat viewW = 70.0;
    CGFloat viewH = viewW;
    CGFloat viewX = 18.0;
    CGFloat viewY = 9.0;
    imageView.frame = (CGRect){viewX, viewY, viewW, viewH};
    
    UILabel *textLabel = self.textLabel;
    viewX = CGRectGetMaxX(imageView.frame)+12.0;
    viewW = windowWidth-viewX-18.0;
    viewH = (windowHeight-18.0)*0.5;
    textLabel.frame = (CGRect){viewX, viewY, viewW, viewH};
    
    UILabel *detailTextLabel = self.detailTextLabel;
    viewY = CGRectGetMaxY(textLabel.frame);
    detailTextLabel.frame = (CGRect){viewX, viewY, viewW, viewH};
}

- (void)setAlbumModel:(KSImagePickerAlbumModel *)albumModel {
    _albumModel = albumModel;
    NSArray <KSImagePickerItemModel *> *assetList = albumModel.assetList;
    KSImagePickerItemModel *itemModel = assetList.firstObject;
    if (assetList.count > 2 && itemModel.isCameraCell) {
        itemModel = [albumModel.assetList objectAtIndex:1];
    }
    PHAsset *asset = itemModel.asset;
    if (asset == nil) {
        self.imageView.image = nil;
    } else {
        __weak typeof(self) weakSelf = self;
        [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:(CGSize){70.f, 70.f} contentMode:PHImageContentModeAspectFill options:KSImagePickerItemModel.pictureViewerOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            weakSelf.imageView.image = result;
        }];
    }
    self.textLabel.text = albumModel.albumTitle;
    self.detailTextLabel.text = [NSNumber numberWithUnsignedInteger:albumModel.assetList.count].stringValue;
}

@end
