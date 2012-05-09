//
//  Photo.h
//  
//
//  Created by Marlon Harrison on 5/1/12.
//  Copyright (c) 2012 . All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FeedType, Market, PhotoType, Tag;

@interface Photo : NSManagedObject

@property (nonatomic, retain) NSDate * created_ts;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSString * full_path;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * is_new;
@property (nonatomic, retain) NSDate * modified_ts;
@property (nonatomic, retain) NSString * thumb_path;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) FeedType *feed_type;
@property (nonatomic, retain) NSSet *markets;
@property (nonatomic, retain) PhotoType *photo_type;
@property (nonatomic, retain) NSSet *tags;
@end

@interface Photo (CoreDataGeneratedAccessors)

- (void)addMarketsObject:(Market *)value;
- (void)removeMarketsObject:(Market *)value;
- (void)addMarkets:(NSSet *)values;
- (void)removeMarkets:(NSSet *)values;

- (void)addTagsObject:(Tag *)value;
- (void)removeTagsObject:(Tag *)value;
- (void)addTags:(NSSet *)values;
- (void)removeTags:(NSSet *)values;

@end
