//
//  BLCMediaFullScreenAnimator.h
//  Blocstagram
//
//  Created by Inioluwa Work Account on 13/05/2016.
//  Copyright © 2016 bloc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface BLCMediaFullScreenAnimator : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign) BOOL presenting;
@property (nonatomic, weak) UIImageView *cellImageView;

@end
