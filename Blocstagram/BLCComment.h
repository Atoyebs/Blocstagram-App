//
//  BLCComment.h
//  Blocstagram
//
//  Created by Inioluwa Work Account on 21/04/2016.
//  Copyright © 2016 bloc. All rights reserved.
//
@class BLCUser;

#import <Foundation/Foundation.h>

@interface BLCComment : NSObject <NSCoding>

@property (nonatomic, strong) NSString *idNumber;

@property (nonatomic, strong) BLCUser *from;
@property (nonatomic, strong) NSString *text;


-(instancetype) initWithDictionary:(NSDictionary *)commentDictionary;

@end
