//
//  UIImage+BLCImageUtilities.h
//  Blocstagram
//
//  Created by Inioluwa Work Account on 31/05/2016.
//  Copyright © 2016 bloc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (BLCImageUtilities)

- (UIImage *) imageWithFixedOrientation;
- (UIImage *) imageResizedToMatchAspectRatioOfSize:(CGSize)size;
- (UIImage *) imageCroppedToRect:(CGRect)cropRect;

@end
