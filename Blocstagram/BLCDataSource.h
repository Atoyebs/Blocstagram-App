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


#pragma mark - Methods

+(instancetype)sharedInstance;

-(void)deleteMediaItem:(BLCMedia *)item;

-(void)requestNewItemsWithCompletionHandler:(BLCNewItemCompletionBlock)completionHandler;

-(void)requestOldItemsWithCompletionHandler:(BLCNewItemCompletionBlock)completionHandler;

+ (NSString *) instagramClientID;


#pragma mark - Properties

@property (nonatomic, strong, readonly) NSArray *mediaItems;

@property (nonatomic, strong, readonly) NSString *accessToken;

@end
