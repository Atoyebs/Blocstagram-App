//
//  BLCMediaTableViewCell.h
//  Blocstagram
//
//  Created by Inioluwa Work Account on 22/04/2016.
//  Copyright © 2016 bloc. All rights reserved.
//

@class BLCMedia, BLCMediaTableViewCell;

#import <UIKit/UIKit.h>

@protocol BLCMediaTableViewCellDelegate <NSObject>

-(void) cell:(BLCMediaTableViewCell *)cell didTapImageView:(UIImageView *)imageView;
- (void) cell:(BLCMediaTableViewCell *)cell didLongPressImageView:(UIImageView *)imageView;
- (void) cellDidPressLikeButton:(BLCMediaTableViewCell *)cell;

@end

@interface BLCMediaTableViewCell : UITableViewCell

@property (nonatomic, strong) BLCMedia *mediaItem;
@property (nonatomic, weak) id <BLCMediaTableViewCellDelegate> delegate;

+ (CGFloat) heightForMediaItem:(BLCMedia *)mediaItem width:(CGFloat)width;

@end
