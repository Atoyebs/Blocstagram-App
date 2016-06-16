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

#import <UICKeyChainStore.h>
#import <AFNetworking/AFNetworking.h>


@interface BLCDataSource() {
    
    NSMutableArray *_mediaItems;
    
}

@property (nonatomic, assign) BOOL isRefreshing;
@property (nonatomic, assign) BOOL isLoadingOlderItems;
@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, assign) BOOL thereAreNoMoreOlderMessages;
@property (nonatomic, strong) AFHTTPSessionManager *instagramOperationManager;

@end



@implementation BLCDataSource

NSString *const BLCImageFinishedNotification = @"BLCImageFinishedNotification";

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
        
        NSURL *baseURL = [NSURL URLWithString:@"https://api.instagram.com/v1/"];
        self.instagramOperationManager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
        
        AFJSONResponseSerializer *jsonSerializer = [AFJSONResponseSerializer serializer];
        
        AFImageResponseSerializer *imageSerializer = [AFImageResponseSerializer serializer];
        imageSerializer.imageScale = 1.0;
        
        AFCompoundResponseSerializer *serializer = [AFCompoundResponseSerializer compoundSerializerWithResponseSerializers:@[jsonSerializer, imageSerializer]];
        self.instagramOperationManager.responseSerializer = serializer;
        
        self.accessToken = [UICKeyChainStore stringForKey:@"access token"];
        
        if(!self.accessToken){
            
            [self registerForAccessTokenNotification];
            
        }
        else {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                //get the fullPath of the same file you saved/wrote to earlier
                NSString *fullPath = [self pathForFilename:NSStringFromSelector(@selector(mediaItems))];
                
                //unarchive the file into the SAME DATA/OBJECT TYPE YOU SAVED/WROTE it with
                NSArray *storedMediaItems = [NSKeyedUnarchiver unarchiveObjectWithFile:fullPath];
                
                //go back to the main queue as you've now finished the heavy lifting
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (storedMediaItems.count > 0) {
                        NSMutableArray *mutableMediaItems = [storedMediaItems mutableCopy];
                        BLCMedia *dummyMediaItem = [self createTestMediaItem];
                        
                        [mutableMediaItems insertObject:dummyMediaItem atIndex:0];
                        
                        [self willChangeValueForKey:@"mediaItems"];
                         _mediaItems = mutableMediaItems;
                        [self didChangeValueForKey:@"mediaItems"];
//                        [self populateDataWithParameters:nil completionHandler:nil];
                    }
                    else {
                        [self populateDataWithParameters:nil completionHandler:nil];
                    }
                });
            });
            
        }
    }
    
    return self;
}


- (void) registerForAccessTokenNotification {

    [[NSNotificationCenter defaultCenter] addObserverForName:BLCLoginViewControllerDidGetAccessTokenNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        
        self.accessToken = note.object;
        
        [UICKeyChainStore setString:self.accessToken forKey:@"access token"];
        
        NSDictionary *appScope = @{@"scope": @"public_content+likes+comments"};
        
        [self populateDataWithParameters:appScope completionHandler:nil];
    }];

}


- (void)documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(NSString *)application {
    [[NSNotificationCenter defaultCenter] postNotificationName:BLCImageFinishedNotification object:self];
}


- (void) populateDataWithParameters:(NSDictionary *)parameters completionHandler:(BLCNewItemCompletionBlock)completionHandler {
    
    if (self.accessToken) {
        // only try to get the data if there's an access token
    
        NSMutableDictionary *mutableParameters = [@{@"access_token": self.accessToken} mutableCopy];
        
        [mutableParameters addEntriesFromDictionary:parameters];
        
        [self.instagramOperationManager GET:@"users/self/media/recent" parameters:mutableParameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                [self parseDataFromFeedDictionary:responseObject fromRequestWithParameters:parameters];
                
                if (completionHandler) {
                    completionHandler(nil);
                }
            }
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
           
            if (completionHandler) {
                completionHandler(error);
            }
            
        }];
    }
    
    
    
}


- (void) downloadImageForMediaItem:(BLCMedia *)mediaItem {
    
    if (mediaItem.mediaURL && !mediaItem.image) {
        
        mediaItem.downloadState = BLCMediaDownloadStateDownloadInProgress;
        
        [self.instagramOperationManager GET:mediaItem.mediaURL.absoluteString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            if ([responseObject isKindOfClass:[UIImage class]]) {
                mediaItem.image = responseObject;
                mediaItem.downloadState = BLCMediaDownloadStateHasImage;
                NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"];
                NSUInteger index = [mutableArrayWithKVO indexOfObject:mediaItem];
                [mutableArrayWithKVO replaceObjectAtIndex:index withObject:mediaItem];
            }
            else {
                mediaItem.downloadState = BLCMediaDownloadStateNonRecoverableError;
            }
        }
        failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            NSLog(@"Error downloading image: %@", error);
            
            mediaItem.downloadState = BLCMediaDownloadStateNonRecoverableError;
            
            if ([error.domain isEqualToString:NSURLErrorDomain]) {
                // A networking problem
                if (error.code == NSURLErrorTimedOut ||
                    error.code == NSURLErrorCancelled ||
                    error.code == NSURLErrorCannotConnectToHost ||
                    error.code == NSURLErrorNetworkConnectionLost ||
                    error.code == NSURLErrorNotConnectedToInternet ||
                    error.code == kCFURLErrorInternationalRoamingOff ||
                    error.code == kCFURLErrorCallIsActive ||
                    error.code == kCFURLErrorDataNotAllowed ||
                    error.code == kCFURLErrorRequestBodyStreamExhausted) {
                    
                    // It might work if we try again
                    mediaItem.downloadState = BLCMediaDownloadStateNeedsImage;
                }
            }
            
        }];
    }
    
}


- (void) parseDataFromFeedDictionary:(NSDictionary *) feedDictionary fromRequestWithParameters:(NSDictionary *)parameters {
    
    NSArray *mediaArray = feedDictionary[@"data"];
    
    NSMutableArray *tmpMediaItems = [NSMutableArray array];
    
    for (NSDictionary *mediaDictionary in mediaArray) {
        BLCMedia *mediaItem = [[BLCMedia alloc] initWithDictionary:mediaDictionary];
        
        if (mediaItem) {
            [tmpMediaItems addObject:mediaItem];
//            [self downloadImageForMediaItem:mediaItem];
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
            [self populateCommentDataWithParameters:@{@"scope": @"basic+public_content+likes"} withMediaItem:mediaItem];
        }];
        
        [commentRetreivalOperationQueue addOperation:retrieveComments];
    }
    
    
    if (tmpMediaItems.count > 0) {
        // Write the changes to disk
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSUInteger numberOfItemsToSave = MIN(self.mediaItems.count, 50);
            NSArray *mediaItemsToSave = [self.mediaItems subarrayWithRange:NSMakeRange(0, numberOfItemsToSave)];
            
            NSString *fullPath = [self pathForFilename:NSStringFromSelector(@selector(mediaItems))];
            NSData *mediaItemData = [NSKeyedArchiver archivedDataWithRootObject:mediaItemsToSave];
            
            NSError *dataError;
            BOOL wroteSuccessfully = [mediaItemData writeToFile:fullPath options:NSDataWritingAtomic | NSDataWritingFileProtectionCompleteUnlessOpen error:&dataError];
            
            if (!wroteSuccessfully) {
                NSLog(@"Couldn't write file: %@", dataError);
            }
        });
        
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
                    if (!jsonError && [commentsDictionary objectForKey:@"data"]){
                        
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

#pragma mark - NSKeyed Archiver

- (NSString *) pathForFilename:(NSString *) filename {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:filename];
    return dataPath;
}


#pragma mark - Utilty Methods

+(NSString*)commentURLForMediaItemWithID:(NSString*)identifier {
    
    NSString *fullURL = [NSMutableString stringWithFormat:@"https://api.instagram.com/v1/media/%@/comments?access_token=", identifier];
    return fullURL;
}

-(BLCMedia *) createTestMediaItem {
    
    NSDictionary *userDictionary = @{@"full_name": @"IfeOluwa Oduyale",
                                     @"id": @"1222900248",
                                     @"profile_picture": @"https://scontent.cdninstagram.com/t51.2885-19/11202455_1389755414684441_1383627008_a.jpg",
                                     @"username":@"rosy.cheeks"
                                     };
    
    BLCMedia *testMediaItem = [[BLCMedia alloc] init];
    BLCUser *testUser = [[BLCUser alloc] initWithDictionary:userDictionary];
    
    testMediaItem.idNumber = @"2202938159725758095_1251900268";
    testMediaItem.user = testUser;
    testMediaItem.image = [UIImage imageNamed:@"stephen-curry.jpg"];
    testMediaItem.caption = @"#stephGonnaSteph";
    testMediaItem.likeState = BLCLikeStateLiked;
    
    return testMediaItem;
}


#pragma mark - Liking Media Items

- (void) toggleLikeOnMediaItem:(BLCMedia *)mediaItem {
    NSString *urlString = [NSString stringWithFormat:@"media/%@/likes", mediaItem.idNumber];
    NSMutableDictionary *parameters = [@{@"access_token": self.accessToken} mutableCopy];
    
    if (mediaItem.likeState == BLCLikeStateNotLiked) {
        
        mediaItem.likeState = BLCLikeStateLiking;

        [self.instagramOperationManager POST:urlString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            mediaItem.likeState = BLCLikeStateLiked;
            [self reloadMediaItem:mediaItem];
        }
        failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            mediaItem.likeState = BLCLikeStateNotLiked;
            [self reloadMediaItem:mediaItem];
        }];
        
        
        
    } else if (mediaItem.likeState == BLCLikeStateLiked) {
        
        mediaItem.likeState = BLCLikeStateUnliking;
        
        [self.instagramOperationManager DELETE:urlString parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            mediaItem.likeState = BLCLikeStateNotLiked;
            [self reloadMediaItem:mediaItem];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            mediaItem.likeState = BLCLikeStateLiked;
            [self reloadMediaItem:mediaItem];
        }];
        
        
    }
    
    [self reloadMediaItem:mediaItem];
}

#pragma mark - Comments

- (void) commentOnMediaItem:(BLCMedia *)mediaItem withCommentText:(NSString *)commentText {
    if (!commentText || commentText.length == 0) {
        return;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"media/%@/comments", mediaItem.idNumber];
    NSDictionary *parameters = @{@"access_token": self.accessToken, @"text": commentText};
    
    [self.instagramOperationManager POST:urlString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSString *refreshMediaUrlString = [NSString stringWithFormat:@"media/%@", mediaItem.idNumber];
        NSDictionary *parameters = @{@"access_token": self.accessToken};
        
        [self.instagramOperationManager GET:refreshMediaUrlString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            BLCMedia *newMediaItem = [[BLCMedia alloc] initWithDictionary:responseObject[@"data"]];
            NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"];
            NSUInteger index = [mutableArrayWithKVO indexOfObject:mediaItem];
            [mutableArrayWithKVO replaceObjectAtIndex:index withObject:newMediaItem];
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [self reloadMediaItem:mediaItem];
        }];
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Error: %@", error);
        NSLog(@"Response: %@", task.response);
        [self reloadMediaItem:mediaItem];
    }];
    
}



- (void) reloadMediaItem:(BLCMedia *)mediaItem {
    NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"];
    NSUInteger index = [mutableArrayWithKVO indexOfObject:mediaItem];
    [mutableArrayWithKVO replaceObjectAtIndex:index withObject:mediaItem];
}

@end
