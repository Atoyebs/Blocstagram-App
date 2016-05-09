//
//  BLCLoginViewController.m
//  Blocstagram
//
//  Created by Inioluwa Work Account on 27/04/2016.
//  Copyright © 2016 bloc. All rights reserved.
//

#import "BLCLoginViewController.h"
#import "BLCDataSource.h"

@interface BLCLoginViewController() <UIWebViewDelegate>

@property (nonatomic, weak) UIWebView *webView;

@end


@implementation BLCLoginViewController


NSString *const BLCLoginViewControllerDidGetAccessTokenNotification = @"BLCLoginViewControllerDidGetAccessTokenNotification";

#pragma mark - Inherited Methods

-(void)loadView {
    
    UIWebView *webView = [[UIWebView alloc] init];
    webView.delegate = self;
    
    self.webView = webView;
    self.view = webView;
    
}

-(void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.hidesBackButton = YES;
    
    
    
    NSString *urlString = [NSString stringWithFormat:@"https://instagram.com/oauth/authorize/?client_id=%@&redirect_uri=%@&response_type=token", [BLCDataSource instagramClientID], [self redirectURI]];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    if (url) {
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        [self.webView loadRequest:request];
        
        self.navigationItem.title = @"LOGIN";
    }
    
}



-(void)dealloc {
    
    // Removing this line causes a weird flickering effect when you relaunch the app after logging in, as the web view is briefly displayed, automatically authenticates with cookies, returns the access token, and dismisses the login view, sometimes in less than a second.
    [self clearInstagramCookies];
    
    // see https://developer.apple.com/library/ios/documentation/uikit/reference/UIWebViewDelegate_Protocol/Reference/Reference.html#//apple_ref/doc/uid/TP40006951-CH3-DontLinkElementID_1
    self.webView.delegate = nil;
}


- (void) clearInstagramCookies {
    
    for(NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
        NSRange domainRange = [cookie.domain rangeOfString:@"instagram.com"];
        if(domainRange.location != NSNotFound) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
        }
    }
    
}


#pragma mark - Web Delegate Methods

- (BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    NSString *urlString = request.URL.absoluteString;
    
    if ([urlString hasPrefix:[self redirectURI]]) {
        // This contains our auth token
        NSRange rangeOfAccessTokenParameter = [urlString rangeOfString:@"access_token="];
        NSUInteger indexOfTokenStarting = rangeOfAccessTokenParameter.location + rangeOfAccessTokenParameter.length;
        NSString *accessToken = [urlString substringFromIndex:indexOfTokenStarting];
        [[NSNotificationCenter defaultCenter] postNotificationName:BLCLoginViewControllerDidGetAccessTokenNotification object:accessToken];
        return NO;
    }

    [self updateNavigationBarBackButton];

    
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSString* title = [webView stringByEvaluatingJavaScriptFromString: @"document.title"];
    self.navigationItem.title = title;
}


#pragma mark - Actions/Trigger Methods

- (void)backWasClicked:(id)sender {
    if ([self.webView canGoBack]) {
        [self.webView goBack];
    }
}



#pragma mark - Helper Methods

- (NSString *)redirectURI {
    return @"http://bloc.io";
}


- (UIBarButtonItem *) generateLeftBarButtonItemWithImageNamed:(NSString*)imageNamed {
    
    //create a UIImage from an image name "imageNamed" (variable)
    UIImage *homeBarButtonImage = [UIImage imageNamed:imageNamed];
    
    //calculate the height of the image relative to the navigation bar, its 1.5 times shorter than the height of the navigation bar
    CGFloat heightOfImageFromNavigationBar = self.navigationController.navigationBar.frame.size.height / 1.5;
    
    //get the ratio between the height and width to keep the image proportional when its put in the navigation bar
    CGFloat imageRatioHeightToWidth = homeBarButtonImage.size.height/homeBarButtonImage.size.width;
    
    /* create the frame for the button that will hold the image IN THE NAVIGATION BAR
       the width will be = (the height you want your icon to be in the nav bar / the ratio between height and width)
       the height will just be the height of the image that was calculated earlier
     */
    CGRect frameForHomeButton = CGRectMake(0, 0, (heightOfImageFromNavigationBar/imageRatioHeightToWidth), heightOfImageFromNavigationBar);
    
    //create a button with the size and frame you just created above
    UIButton *goHomeButton = [[UIButton alloc] initWithFrame:frameForHomeButton];
    
    //set the background image for the button as the image we created as a very first step
    [goHomeButton setBackgroundImage:homeBarButtonImage forState:UIControlStateNormal];
    
    //add an action for when the button is touched/clicked by using @selector syntax, it means when this button is touched it will execute the backWasClicked: method, you can name this to whatever you want as long as the method exists in this class
    [goHomeButton addTarget:self action:@selector(backWasClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    //create a UIBarButtonItem (not to be confused with a normal UIButton) this button is specifically for navigationBars
    UIBarButtonItem *barButtonLeft = [[UIBarButtonItem alloc] initWithCustomView:goHomeButton];
    
    //return the newly created UIBarButtonItem
    return barButtonLeft;
}

-(void)updateNavigationBarBackButton {
    
    //if the leftBarButtonItem is empty/nil NOT Initialized/Created
    
    UIBarButtonItem *barButtonItemCustomImage = [self generateLeftBarButtonItemWithImageNamed:@"back_arrow"];
    
    if(self.webView.canGoBack) {
        
        if (!self.navigationItem.leftBarButtonItem) {
            [self.navigationItem setHidesBackButton:YES animated:YES];
            [self.navigationItem setLeftBarButtonItem:barButtonItemCustomImage animated:YES];
        }
    }
    else {
        [self.navigationItem setLeftBarButtonItem:nil animated:YES];
        //        [self.navigationItem setHidesBackButton:NO animated:NO];
    }
    
}


@end
