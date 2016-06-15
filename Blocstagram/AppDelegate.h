//
//  AppDelegate.h
//  Blocstagram
//
//  Created by Inioluwa Work Account on 21/04/2016.
//  Copyright © 2016 bloc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BLCImagesTableViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong) BLCImagesTableViewController *imagesVC;

@end

