//
//  UIImage+BLCImageUtilities.h
//  Blocstagram
//
//  Created by Inioluwa Work Account on 31/05/2016.
//  Copyright © 2016 bloc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (BLCImageUtilities)

- (UIImage *) imageByScalingToSize:(CGSize)size andCroppingWithRect:(CGRect)rect;

@end
