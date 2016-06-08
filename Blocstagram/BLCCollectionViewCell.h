//
//  BLCCollectionViewCell.h
//  Blocstagram
//
//  Created by Inioluwa Work Account on 08/06/2016.
//  Copyright © 2016 bloc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BLCCollectionViewCell : UICollectionViewCell

-(instancetype)initWithCollectionView:(UICollectionView*)collectionView;

-(void)setThumbnailImage:(UIImage *)image;

-(void)setLabelText:(NSString *)text;


@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, assign) NSInteger imageViewTag;
@property (nonatomic, assign) NSInteger labelTag;


@end
