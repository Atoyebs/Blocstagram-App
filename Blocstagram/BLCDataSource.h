//
//  BLCDataSource.h
//  Blocstagram
//
//  Created by Inioluwa Work Account on 21/04/2016.
//  Copyright © 2016 bloc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BLCMedia;


typedef void (^BLCNewItemCompletionBlock)(NSError *error);



@interface BLCDataSource : NSObject


extern NSString *const BLCImageFinishedNotification;

#pragma mark - Methods

+(instancetype)sharedInstance;

-(void)deleteMediaItem:(BLCMedia *)item;

-(void)requestNewItemsWithCompletionHandler:(BLCNewItemCompletionBlock)completionHandler;

-(void)requestOldItemsWithCompletionHandler:(BLCNewItemCompletionBlock)completionHandler;

- (void) downloadImageForMediaItem:(BLCMedia *)mediaItem;

- (void) toggleLikeOnMediaItem:(BLCMedia *)mediaItem;

- (void) commentOnMediaItem:(BLCMedia *)mediaItem withCommentText:(NSString *)commentText;

+ (NSString *) instagramClientID;


#pragma mark - Properties

@property (nonatomic, strong, readonly) NSArray *mediaItems;

@property (nonatomic, strong, readonly) NSString *accessToken;

@end
