//
//  SDGModel.h
//  
//
//  Created by Marlon Harrison on 4/18/12.
//  Copyright (c) 2012 . All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"

@protocol SDGModelDelegate <NSObject>
@optional
-(void)modelDidNotFindUpdate:(id)data;
-(void)modelCheckUpdateError:(NSError *)error;
-(void)modelHasDownloadProgress:(NSInteger)totalBytesWritten outOfTotalBytes:(NSInteger)totalBytesExpected;
-(void)modelDidPerformUpdate:(BOOL)updatePerformed withErrorString:(NSString *)errorString;
-(void)modelDidFindUpdate:(id)data;
-(void)modelHasPhotoArrayResult:(NSArray *)photoArray;
-(void)modelWillInitialize;
-(void)modelDidInitialize;

@end


@interface SDGModel : NSObject
{
    NSMutableArray *allPhotos;
    NSMutableArray *allTags;
    NSMutableArray *allMarkets;
    
    NSMutableArray *filteredPhotos;
    //NSMutableArray *filteredTags;
    //NSMutableArray *filteredMarkets;
    
    NSManagedObjectContext *context;
    NSManagedObjectContext *checkerMoc;
    NSManagedObjectModel *model;
    NSPersistentStoreCoordinator *psc;
    AFHTTPClient *afClient;
    NSURL *storeURL;
    NSFetchRequest *fetcher;
}

@property (nonatomic, weak) id <SDGModelDelegate> delegate;
@property (nonatomic, strong) NSString * predicateString;
@property (nonatomic, strong) NSArray * availablePhotos;

-(id)initWithDelegate:(id)theDelegate;

-(void)checkForUpdates;
-(void)checkForUpdateswithReferrer:(id)referrer;
-(void)performUpdate;

-(BOOL)saveChanges;
-(void) loadAllPhotos;
-(NSPersistentStoreCoordinator *)getPersistentStore;
//-(void) loadAllMarkets;
//-(void) loadAllTags;

//-(NSArray *)filterArray:(NSArray *)photoArray withPredicate:(NSPredicate *)predicate;
-(NSArray *)fetchPhotoswithPredicate:(NSPredicate *)predicate;
-(NSArray *)fetchThreadedPhotoswithPredicate:(NSPredicate *)predicate;
-(NSInteger)countPhotoswithPredicate:(NSPredicate *)predicate;
-(NSInteger)countThreadedPhotoswithPredicate:(NSPredicate *)predicate;


//- (NSPersistentStore *)addPersistentStoreWithType:(NSString *)storeType configuration:(NSString *)configuration URL:(NSURL *)storeURL options:(NSDictionary *)options error:(NSError **)error;    
-(NSString *)documentDirectory;
//-(NSArray *)filteredTags;
//-(NSArray *)filteredMarkets;
-(NSArray *)feedTypes;
-(NSArray *)photoTypes;

-(NSArray *)availableMarkets;
-(NSArray *)availableTags;

@end
