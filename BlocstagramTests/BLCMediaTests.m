//
//  BLCMediaTests.m
//  Blocstagram
//
//  Created by Inioluwa Work Account on 15/06/2016.
//  Copyright © 2016 bloc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BLCMedia.h"
#import "BLCUser.h"
#import "BLCLikeButton.h"

@interface BLCMediaTests : XCTestCase

@end

@implementation BLCMediaTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


-(void)testThatInitializationWorks {

    NSDictionary *sourceDictionary = @{@"id":@"1202918159720658095_1251900268",
                                      @"user":@{@"full_name": @"Ini Atoyebi",
                                                 @"id": @"1251900268",
                                                 @"profile_picture": @"https://scontent.cdninstagram.com/t51.2885-19/11202455_1389755414684441_1383627008_a.jpg",
                                                 @"username":@"atoyebs"
                                               },
                                       @"images":@{@"standard_resolution":@{@"height": @640,
                                                                            @"url": @"https://scontent.cdninstagram.com/t51.2885-15/s640x640/sh0.08/e35/12826319_1531805197113396_1419536869_n.jpg",
                                                                            @"width": @640}
                                                 },
                                       @"caption": @{@"created_time" : @1457619040,
                                                     @"id": @17845172719104847,
                                                     @"text": @"Family & Friends #pdaAt50 #cuttingcakenigerianstyle"
                                                    },
                                       @"comments": @{@"count": @0 },
                                       @"user_has_liked": @1
                                     };
    
    
    BLCMedia *testMediaItem = [[BLCMedia alloc] initWithDictionary:sourceDictionary];
    BLCUser *testUser = [[BLCUser alloc] initWithDictionary:sourceDictionary[@"user"]];
    
    XCTAssertEqualObjects(testMediaItem.idNumber, sourceDictionary[@"id"], @"The ID number should be equal");
    XCTAssertEqualObjects(testMediaItem.user.userName, testUser.userName, @"The username(s) should be the same");
    XCTAssertEqualObjects(testMediaItem.user.fullName, testUser.fullName, @"The user's fullname should be the same");
    XCTAssertEqualObjects(testMediaItem.user.profilePictureURL, testUser.profilePictureURL, @"The user's profilePicURL should be the same");
    NSString *dictionaryMediaURL = sourceDictionary[@"images"][@"standard_resolution"][@"url"];
    XCTAssertTrue([dictionaryMediaURL isEqualToString:testMediaItem.mediaURL.absoluteString], @"The mediaURLs should be the same");
    XCTAssertNil(testMediaItem.image, @"image should not be nil if it has been initialized properly");
    XCTAssertEqualObjects(testMediaItem.caption, sourceDictionary[@"caption"][@"text"]);
    
    
    BLCLikeState likeButtonState;
    if ([sourceDictionary[@"user_has_liked"] isEqual: @1]) {
        likeButtonState = BLCLikeStateLiked;
        XCTAssertEqual(testMediaItem.likeState, likeButtonState, @"likeButtonState(s) should be equal");
    }
    else {
        likeButtonState = BLCLikeStateNotLiked;
        XCTAssertEqual(testMediaItem.likeState, likeButtonState, @"likeButtonState(s) should be equal");
    }
    
    
    
    
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
