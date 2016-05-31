//
//  BLCCameraViewController.h
//  
//
//  Created by Inioluwa Work Account on 31/05/2016.
//
//

#import <UIKit/UIKit.h>

@class BLCCameraViewController;

@protocol BLCCameraViewControllerDelegate <NSObject>

- (void) cameraViewController:(BLCCameraViewController *)cameraViewController didCompleteWithImage:(UIImage *)image;

@end


@interface BLCCameraViewController : UIViewController

@property (nonatomic, weak) NSObject <BLCCameraViewControllerDelegate> *delegate;

@end
