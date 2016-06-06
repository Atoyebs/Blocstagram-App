//
//  BLCMediaFullScreenViewController.h
//  Blocstagram
//
//  Created by Inioluwa Work Account on 13/05/2016.
//  Copyright © 2016 bloc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BLCMedia;

@interface BLCMediaFullScreenViewController : UIViewController

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) BLCMedia *media;

- (instancetype)initWithMedia:(BLCMedia *)media;

- (void)centerScrollView;

- (void) recalculateZoomScale;

@end
