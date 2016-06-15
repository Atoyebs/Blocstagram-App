//
//  BLCComposeCommentView.h
//  Blocstagram
//
//  Created by Inioluwa Work Account on 26/05/2016.
//  Copyright © 2016 bloc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BLCComposeCommentView;

@protocol BLCComposeCommentViewDelegate <NSObject>

- (void) commentViewDidPressCommentButton:(BLCComposeCommentView *)sender;
- (void) commentView:(BLCComposeCommentView *)sender textDidChange:(NSString *)text;
- (void) commentViewWillStartEditing:(BLCComposeCommentView *)sender;

@end


@interface BLCComposeCommentView : UIView

@property (nonatomic, weak) NSObject <BLCComposeCommentViewDelegate> *delegate;

@property (nonatomic, assign) BOOL isWritingComment;

@property (nonatomic, strong) NSString *text;

@property (nonatomic, strong) UITextView *textView;

- (void) stopComposingComment;


@end
