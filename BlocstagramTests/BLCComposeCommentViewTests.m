//
//  BLCComposeCommentViewTests.m
//  Blocstagram
//
//  Created by Inioluwa Work Account on 15/06/2016.
//  Copyright © 2016 bloc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BLCComposeCommentView.h"
#import "BLCImagesTableViewController.h"
#import "AppDelegate.h"
#import "BLCMediaTableViewCell.h"

@interface BLCComposeCommentViewTests : XCTestCase

@end

@implementation BLCComposeCommentViewTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void)testComposeCommentViewisWritingCommentYes {
    
    
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    BLCImagesTableViewController *tableVC = app.imagesVC;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
    
    BLCMediaTableViewCell *testCell = (BLCMediaTableViewCell *)[tableVC tableView:tableVC.tableView cellForRowAtIndexPath:indexPath];
    
    BLCComposeCommentView *commentView = testCell.commentView;

    commentView.textView.text = @"testString";
    
    [commentView.textView.delegate textViewShouldBeginEditing:commentView.textView];
    
    [commentView.textView.delegate textViewShouldEndEditing:commentView.textView];
    
    
    BOOL result = commentView.isWritingComment;
    
    XCTAssertTrue(result, @"if commentView.textView.text is not empty then result should = YES");
    
}


-(void)testComposeCommentViewisWritingCommentNo {
    
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        BLCImagesTableViewController *tableVC = app.imagesVC;
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
        
        BLCMediaTableViewCell *testCell = (BLCMediaTableViewCell *)[tableVC tableView:tableVC.tableView cellForRowAtIndexPath:indexPath];
        
        BLCComposeCommentView *commentView = testCell.commentView;
        
        commentView.textView.text = @"";
        
        [commentView.textView.delegate textViewShouldBeginEditing:commentView.textView];
        
        [commentView.textView.delegate textViewShouldEndEditing:commentView.textView];
    
        BOOL result = commentView.isWritingComment;
        
        XCTAssertFalse(result, @"if commentView.textView.text is empty then result should = NO");
    
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
