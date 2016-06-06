//
//  BLCCropImageViewController.m
//  Blocstagram
//
//  Created by Inioluwa Work Account on 02/06/2016.
//  Copyright © 2016 bloc. All rights reserved.
//

#import "BLCCropImageViewController.h"
#import "BLCCropBox.h"
#import "BLCMedia.h"
#import "UIImage+BLCImageUtilities.h"
#import <PureLayout/PureLayout.h>

@interface BLCCropImageViewController()

@property (nonatomic, strong) BLCCropBox *cropBox;
@property (nonatomic, assign) BOOL hasLoadedOnce;
@property (nonatomic, strong) UIToolbar *bottomToolBar;
@property (nonatomic, assign) BOOL hasExecutedConstraints;

@end

@implementation BLCCropImageViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.clipsToBounds = YES;
    
    self.hasExecutedConstraints = NO;
    
    [self.view addSubview:self.cropBox];
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Crop", @"Crop command") style:UIBarButtonItemStyleDone target:self action:@selector(cropPressed:)];
    
    self.navigationItem.title = NSLocalizedString(@"Crop Image", nil]);
    self.navigationItem.rightBarButtonItem = rightButton;
    
    [self.navigationController.navigationBar setTranslucent:YES];
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.alpha = 0.7f;
    
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.bottomToolBar = [[UIToolbar alloc] init];
    
    [self.bottomToolBar setBarStyle:UIBarStyleBlackTranslucent];
    self.bottomToolBar.alpha = 0.7f;
    
    [self.view addSubview:self.bottomToolBar];
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1];
}


- (instancetype) initWithImage:(UIImage *)sourceImage {
    self = [super init];
    
    if (self) {
        self.media = [[BLCMedia alloc] init];
        self.media.image = sourceImage;
        
        self.cropBox = [BLCCropBox new];
    }
    
    return self;
}


- (void) viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    
    CGRect cropRect = CGRectZero;
    
    CGFloat edgeSize = MIN(CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
    cropRect.size = CGSizeMake(edgeSize, edgeSize);
    
    CGSize size = self.view.frame.size;
    
    self.cropBox.frame = cropRect;
    self.cropBox.center = CGPointMake(size.width / 2, size.height / 2);
    self.scrollView.frame = self.cropBox.frame;
    self.scrollView.clipsToBounds = NO;
    
    CGFloat toolbarHeight = screenSize.height * 0.098;
    
    self.bottomToolBar.frame = CGRectMake(0, (screenSize.height - toolbarHeight), screenSize.width, toolbarHeight);
    
    [self recalculateZoomScale];
    
    if (self.hasLoadedOnce == NO) {
        self.scrollView.zoomScale = self.scrollView.minimumZoomScale;
        self.hasLoadedOnce = YES;
    }
}


-(void)viewWillDisappear:(BOOL)animated {
    
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:(247.0f/255.0f) green:(247.0f/255.0f) blue:(247.0f/255.0f) alpha:1];
    self.navigationController.navigationBar.tintColor = self.view.tintColor;
    self.navigationController.navigationBar.alpha = 1.0f;

    
    [super viewWillDisappear:YES];
}


- (void) cropPressed:(UIBarButtonItem *)sender {
    CGRect visibleRect;
    float scale = 1.0f / self.scrollView.zoomScale / self.media.image.scale;
    visibleRect.origin.x = self.scrollView.contentOffset.x * scale;
    visibleRect.origin.y = self.scrollView.contentOffset.y * scale;
    visibleRect.size.width = self.scrollView.bounds.size.width * scale;
    visibleRect.size.height = self.scrollView.bounds.size.height * scale;
    
    UIImage *scrollViewCrop = [self.media.image imageWithFixedOrientation];
    scrollViewCrop = [scrollViewCrop imageCroppedToRect:visibleRect];
    
    [self.delegate cropControllerFinishedWithImage:scrollViewCrop];
}





@end
