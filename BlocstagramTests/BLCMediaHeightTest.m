//
//  BLCMediaHeightTest.m
//  Blocstagram
//
//  Created by Inioluwa Work Account on 15/06/2016.
//  Copyright © 2016 bloc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AppDelegate.h"
#import "BLCImagesTableViewController.h"
#import "BLCMediaTableViewCell.h"
#import "BLCComposeCommentView.h"
#import "BLCMedia.h"
#import "BLCUser.h"

@interface BLCMediaHeightTest : XCTestCase

@end

@implementation BLCMediaHeightTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void) testHeightForMediaItem {

    
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSDictionary *userDictionary = @{@"full_name": @"IfeOluwa Oduyale",
                                     @"id": @"1222900248",
                                     @"profile_picture": @"https://scontent.cdninstagram.com/t51.2885-19/11202455_1389755414684441_1383627008_a.jpg",
                                     @"username":@"rosy.cheeks"
                                     };
    
    BLCUser *testUser = [[BLCUser alloc] initWithDictionary:userDictionary];
    
    UIImage *stephCurryImage = [UIImage imageNamed:@"stephen-curry.jpg"];
    
    BLCImagesTableViewController *tableVC = app.imagesVC;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    BLCMediaTableViewCell *testCell = (BLCMediaTableViewCell *)[tableVC tableView:tableVC.tableView cellForRowAtIndexPath:indexPath];
    
    BLCMedia *testMediaItem = [[BLCMedia alloc] init];
    testMediaItem.image = stephCurryImage;
    testMediaItem.caption = @"#stephGonnaSteph";
    testMediaItem.user = testUser;
    
    
    CGFloat mediaCellHeight = [BLCMediaTableViewCell heightForMediaItem:testMediaItem width:tableVC.tableView.frame.size.width];
    
    CGFloat cellHeight = testCell.frame.size.height;
    
    XCTAssertTrue(cellHeight == mediaCellHeight);
    
    
}


- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
