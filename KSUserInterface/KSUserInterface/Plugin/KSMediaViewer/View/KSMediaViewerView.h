//
//  KSMediaViewerView.h
//  KSUserInterface
//
//  Created by Kinsun on 2018/12/4.
//  Copyright © 2018年 Kinsun. All rights reserved.
//

#import "KSBaseView.h"

NS_ASSUME_NONNULL_BEGIN

@interface KSMediaViewerView : KSSecondaryView

@property (nonatomic, weak, readonly) UIView *barrierView;
@property (nonatomic, weak, readonly) UICollectionView *collectionView;

@end

NS_ASSUME_NONNULL_END
