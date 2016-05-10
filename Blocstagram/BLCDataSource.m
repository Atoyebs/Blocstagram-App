//
//  BLCDataSource.m
//  Blocstagram
//
//  Created by Inioluwa Work Account on 21/04/2016.
//  Copyright © 2016 bloc. All rights reserved.
//

#import "BLCDataSource.h"
#import "BLCLoginViewController.h"

#import "BLCUser.h"
#import "BLCMedia.h"
#import "BLCComment.h"


@interface BLCDataSource() {
    
    NSMutableArray *_mediaItems;
    
}

@property (nonatomic, assign) BOOL isRefreshing;

@property (nonatomic, assign) BOOL isLoadingOlderItems;

@property (nonatomic, strong) NSString *accessToken;

@property (nonatomic, assign) BOOL thereAreNoMoreOlderMessages;

@end



@implementation BLCDataSource

#pragma mark - Class Constructors

+ (instancetype) sharedInstance {
    
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (instancetype) init {
    self = [super init];
    
    if (self) {
        [self registerForAccessTokenNotification];
    }
    
    return self;
}


- (void) registerForAccessTokenNotification {

    [[NSNotificationCenter defaultCenter] addObserverForName:BLCLoginViewControllerDidGetAccessTokenNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        
        self.accessToken = note.object;
        
        NSDictionary *appScope = @{@"scope": @"public_content"};
        
        [self populateDataWithParameters:appScope completionHandler:nil];
    }];

}



- (void) populateDataWithParameters:(NSDictionary *)parameters completionHandler:(BLCNewItemCompletionBlock)completionHandler {
    
    if (self.accessToken) {
        // only try to get the data if there's an access token
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            // do the network request in the background, so the UI doesn't lock up
            
            NSMutableString *urlString = [NSMutableString stringWithFormat:@"https://api.instagram.com/v1/users/self/media/recent/?access_token=%@", self.accessToken];
            
            for (NSString *parameterName in parameters) {
                // for example, if dictionary contains {count: 50}, append `&count=50` to the URL
                [urlString appendFormat:@"&%@=%@", parameterName, parameters[parameterName]];
            }
            
            NSURL *url = [NSURL URLWithString:urlString];
            
            if (url) {
                NSURLRequest *request = [NSURLRequest requestWithURL:url];
                
                NSURLResponse *response;
                NSError *webError;
                NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&webError];
                
                if (responseData) {
                    NSError *jsonError;
                    NSDictionary *feedDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&jsonError];
                    
                    if (feedDictionary) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            // done networking, go back on the main thread
                            [self parseDataFromFeedDictionary:feedDictionary fromRequestWithParameters:parameters];
                            if (completionHandler) {
                                completionHandler(nil);
                            }
                        });
                    } else if (completionHandler) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completionHandler(jsonError);
                        });
                    }
                }
                else if (completionHandler) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        // done networking, go back on the main thread
                        completionHandler(webError);
                    });
                }
            }
        });
    }
    
    
    
}


- (void) downloadImageForMediaItem:(BLCMedia *)mediaItem {
    
    if (mediaItem.mediaURL && !mediaItem.image) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
           
            NSURLRequest *request = [NSURLRequest requestWithURL:mediaItem.mediaURL];
            
            NSURLResponse *response;
            NSError *error;
            NSData *imageData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            
            if (imageData) {
                UIImage *image = [UIImage imageWithData:imageData];
                
                if (image) {
                    mediaItem.image = image;
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"];
                        NSUInteger index = [mutableArrayWithKVO indexOfObject:mediaItem];
                        [mutableArrayWithKVO replaceObjectAtIndex:index withObject:mediaItem];
                    });
                }
            } else {
                NSLog(@"Error downloading image: %@", error);
            }
        });
    }
    
    
}


- (void) parseDataFromFeedDictionary:(NSDictionary *) feedDictionary fromRequestWithParameters:(NSDictionary *)parameters {
    
    NSArray *mediaArray = feedDictionary[@"data"];
    
    NSMutableArray *tmpMediaItems = [NSMutableArray array];
    
    for (NSDictionary *mediaDictionary in mediaArray) {
        BLCMedia *mediaItem = [[BLCMedia alloc] initWithDictionary:mediaDictionary];
        
        if (mediaItem) {
            [tmpMediaItems addObject:mediaItem];
            [self downloadImageForMediaItem:mediaItem];
        }
    }
    
    NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"];
    
    if (parameters[@"min_id"]) {
        // This was a pull-to-refresh request
        
        NSRange rangeOfIndexes = NSMakeRange(0, tmpMediaItems.count);
        NSIndexSet *indexSetOfNewObjects = [NSIndexSet indexSetWithIndexesInRange:rangeOfIndexes];
        
        [mutableArrayWithKVO insertObjects:tmpMediaItems atIndexes:indexSetOfNewObjects];
    }
    else if (parameters[@"max_id"]) {
        // This was an infinite scroll request
        
        if (tmpMediaItems.count == 0) {
            // disable infinite scroll, since there are no more older messages
            self.thereAreNoMoreOlderMessages = YES;
        }
        
        [mutableArrayWithKVO addObjectsFromArray:tmpMediaItems];
    }
    else {
        [self willChangeValueForKey:@"mediaItems"];
        _mediaItems = tmpMediaItems;
        [self didChangeValueForKey:@"mediaItems"];
    }
    
    
    NSOperationQueue *commentRetreivalOperationQueue = [NSOperationQueue new];
    
    for (BLCMedia *mediaItem in _mediaItems) {
        
        NSBlockOperation *retrieveComments = [NSBlockOperation blockOperationWithBlock:^{
            [self populateCommentDataWithParameters:@{@"scope": @"basic+public_content"} withMediaItem:mediaItem];
        }];
        
        [commentRetreivalOperationQueue addOperation:retrieveComments];
    }
    
}


+ (NSString *) getRandomImageWithNameAsNumberBetween:(int)from to:(int)upperBound withExtension:(NSString*)ext {
    
    int randomNumberGenerated = arc4random_uniform(upperBound) + from;
    
    NSString *generatedImageName = [NSString stringWithFormat:@"%d.%@", randomNumberGenerated, ext];
    
    return generatedImageName;
}


#pragma mark - Instagram Authentication Methods

+ (NSString *) instagramClientID {
    return @"e3f743d478bc4aafb7309c1b572e8964";
}




#pragma mark - Data Source (Accessor) Utitlity Methods

- (NSUInteger) countOfMediaItems {
    return self.mediaItems.count;
}

- (id) objectInMediaItemsAtIndex:(NSUInteger)index {
    return [self.mediaItems objectAtIndex:index];
}

- (NSArray *) mediaItemsAtIndexes:(NSIndexSet *)indexes {
    return [self.mediaItems objectsAtIndexes:indexes];
}

- (void)deleteMediaItem:(BLCMedia *)item {
    
    NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"];
    [mutableArrayWithKVO removeObject:item];
}

- (void) insertObject:(BLCMedia *)object inMediaItemsAtIndex:(NSUInteger)index {
    [_mediaItems insertObject:object atIndex:index];
}

- (void) removeObjectFromMediaItemsAtIndex:(NSUInteger)index {
    [_mediaItems removeObjectAtIndex:index];
}

- (void) replaceObjectInMediaItemsAtIndex:(NSUInteger)index withObject:(id)object {
    [_mediaItems replaceObjectAtIndex:index withObject:object];
}


#pragma mark - Completion Handlers

-(void)requestNewItemsWithCompletionHandler:(BLCNewItemCompletionBlock)completionHandler {
    
    self.thereAreNoMoreOlderMessages = NO;
    
    if (self.isRefreshing == NO) {
        
        self.isRefreshing = YES;
       
        //Need to add images here
        NSString *minID = [[self.mediaItems firstObject] idNumber];
        
        NSMutableDictionary *parameters = [NSMutableDictionary new];
        
        if(minID){
            [parameters addEntriesFromDictionary:@{@"min_id": minID}];
        }
        
        [parameters addEntriesFromDictionary:@{@"scope": @"public_content"}];
        
        [self populateDataWithParameters:parameters completionHandler:^(NSError *error) {
            self.isRefreshing = NO;
            
            if (completionHandler) {
                completionHandler(error);
            }
        }];
        
    }
    
}

-(void)requestOldItemsWithCompletionHandler:(BLCNewItemCompletionBlock)completionHandler {
    
    if (self.isLoadingOlderItems == NO && self.thereAreNoMoreOlderMessages == NO) {
        
        self.isLoadingOlderItems = YES;
        
        //Need to add images here
        NSString *maxID = [[self.mediaItems lastObject] idNumber];
        NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:@{@"max_id": maxID}];
        [parameters addEntriesFromDictionary:@{@"scope": @"public_content"}];
        
        
        [self populateDataWithParameters:parameters completionHandler:^(NSError *error) {
            self.isLoadingOlderItems = NO;
            
            if (completionHandler) {
                completionHandler(error);
            }
        }];
    }
}


#pragma mark - Retrieving Comments Via API

-(void)populateCommentDataWithParameters:(NSDictionary*)parameters withMediaItem:(BLCMedia*)mediaItem {
    
    NSDictionary *commentsDictionary;
    
    //if the accessToken isn't empty
    if (self.accessToken) {
        
            NSString *instagramCommentsForMediaItemURL = [BLCDataSource commentURLForMediaItemWithID:mediaItem.idNumber];
            
            NSMutableString *urlString = [NSMutableString stringWithString:[instagramCommentsForMediaItemURL stringByAppendingString:self.accessToken]];
            
            for (NSString *parameterName in parameters) {
                // for example, if dictionary contains {count: 50}, append `&count=50` to the URL
                [urlString appendFormat:@"&%@=%@", parameterName, parameters[parameterName]];
            }
            
            NSURL *url = [NSURL URLWithString:urlString];
            
            if (url) {
                
                NSURLRequest *request = [NSURLRequest requestWithURL:url];
                
                NSURLResponse *response;
                NSError *webError;
                NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&webError];
                
                if (responseData) {
                    NSError *jsonError;
                    commentsDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&jsonError];
                    
                    //if there is no json error found
                    if (!jsonError && [commentsDictionary objectForKey:@"data"]) {
                        
                        //holds an array of dictionary objects
                        NSArray *dataArray = commentsDictionary[@"data"];
                        
                        NSMutableArray *commentsForMediaItem = [NSMutableArray new];
                        
                        //loop through the comment information in dictionary format. 1 comment per iteration
                        for (NSDictionary *comment in dataArray) {
                            BLCComment *blcComment = [[BLCComment alloc] initWithDictionary:comment];
                            [commentsForMediaItem addObject:blcComment];
                        }
                        
                        //set the retrieved comments Array to the mediaItem
                        mediaItem.comments = commentsForMediaItem;
                        
                    }
                    
                }
                
            }//if url
            
        }
    
    
}


+(NSString*)commentURLForMediaItemWithID:(NSString*)identifier {
    
    NSString *fullURL = [NSMutableString stringWithFormat:@"https://api.instagram.com/v1/media/%@/comments?access_token=", identifier];
    return fullURL;
}

@end
