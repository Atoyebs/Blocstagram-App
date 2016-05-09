//
//  BLCMediaTableViewCell.h
//  Blocstagram
//
//  Created by Inioluwa Work Account on 22/04/2016.
//  Copyright © 2016 bloc. All rights reserved.
//

@class BLCMedia;

#import <UIKit/UIKit.h>

@interface BLCMediaTableViewCell : UITableViewCell

@property (nonatomic, strong) BLCMedia *mediaItem;

+ (CGFloat) heightForMediaItem:(BLCMedia *)mediaItem width:(CGFloat)width;

@end
