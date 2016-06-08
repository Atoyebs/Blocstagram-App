//
//  BLCCollectionViewCell.m
//  Blocstagram
//
//  Created by Inioluwa Work Account on 08/06/2016.
//  Copyright © 2016 bloc. All rights reserved.
//

#import "BLCCollectionViewCell.h"

@interface BLCCollectionViewCell()

@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, strong) UIImageView *thumbnail;
@property (nonatomic, assign) CGFloat thumbnailEdgeSize;


@end


@implementation BLCCollectionViewCell



-(void)layoutSubviews {
    
    [super layoutSubviews];
    
    NSLog(@"laying out subviews of cell");
    
}


-(instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    NSLog(@"Init With Frame Called");
    
    self.imageViewTag = 1000;
    self.labelTag = 10001;
    
    return self;
}


-(void)setThumbnailImage:(UIImage *)image {
    
    NSLog(@"Set Thumbnail Image Method Run");
    
    self.flowLayout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    self.thumbnail = (UIImageView *)[self.contentView viewWithTag:self.imageViewTag];
    self.thumbnailEdgeSize = self.flowLayout.itemSize.width;
    
    if (!self.thumbnail) {
        self.thumbnail = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.thumbnailEdgeSize, self.thumbnailEdgeSize)];
        self.thumbnail.contentMode = UIViewContentModeScaleAspectFill;
        self.thumbnail.tag = self.imageViewTag;
        self.thumbnail.clipsToBounds = YES;
        
        [self.contentView addSubview:self.thumbnail];
    }

    
    self.thumbnail.image = image;
    
}

-(void)setLabelText:(NSString *)text {
    
    NSLog(@"Set Label Text Method Run");
    
    self.label = (UILabel *)[self.contentView viewWithTag:self.labelTag];
    
    if (!self.label) {
        self.label = [[UILabel alloc] initWithFrame:CGRectMake(0, self.thumbnailEdgeSize, self.thumbnailEdgeSize, 20)];
        self.label.tag = self.labelTag;
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:10];
        [self.contentView addSubview:self.label];
    }
    
    self.label.text = text;
}

@end
