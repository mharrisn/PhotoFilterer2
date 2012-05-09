//
//  SDGModel.m
//  
//
//  Created by Marlon Harrison on 4/18/12.
//  Copyright (c) 2012 . All rights reserved.
//

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

#import "SDGModel.h"
#import "AFJSONRequestOperation.h"
#import "ZipArchive.h"
#import "Photo.h"
#import "PhotoType.h"
#import "FeedType.h"
#import "Tag.h"
#import "Market.h"

@implementation SDGModel

@synthesize delegate,predicateString;
@synthesize availablePhotos = _availablePhotos;

-(id)init
{
    self = [super init];
    
    if(self) {
        
        //Read bundled xcdatamodeld
        model = [NSManagedObjectModel mergedModelFromBundles:nil];
        
        
        psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
        
        //SQLite file location
        //NSString *path = [self itemArchivePath];
        //NSURL *pathURL = [NSURL fileURLWithPath:path isDirectory:NO];
        storeURL = [[self documentDirectoryURL] URLByAppendingPathComponent:@"TestCoreData.sqlite"];
        NSLog(@" Store URL %@", storeURL);
        
        NSError *error = nil;
        
        if(![psc addPersistentStoreWithType:NSSQLiteStoreType
                              configuration:nil
                                        URL:storeURL
                                    options:nil
                                      error:&error]) {
            [NSException raise:@"Open PSC Failed!" format:@"Reason: %@",[error localizedDescription]];
        }
        
        //Create the context
        context = [[NSManagedObjectContext alloc] init];
        [context setPersistentStoreCoordinator:psc];
        
        checkerMoc = [[NSManagedObjectContext alloc] init];
        [checkerMoc setPersistentStoreCoordinator:psc];
        
        //No need for the undo manager
        [context setUndoManager:nil];
        
        
        afClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://Marlon-Harrison.local"]];
        
        fetcher  = [[NSFetchRequest alloc] init];
        
        //[self loadAllPhotos];
    }
    
    return self;
}


-(id)initWithDelegate:(id)theDelegate {
    self = [self init];
    
    [self setDelegate:theDelegate];
    
    [self loadAllPhotos];
    
    return self;
}

-(NSPersistentStoreCoordinator *)getPersistentStore{
    return psc;
}

-(BOOL)saveChanges {
    NSError *error = nil;
    
    BOOL successful = [context save:&error];
    
    if(!successful) {
        NSLog(@"ERROR SAVING: %@", [error localizedDescription]);
    }
    return successful;
}

-(NSArray *)filterArray:(NSArray *)photoArray withPredicate:(NSPredicate *)predicate {
    return [photoArray filteredArrayUsingPredicate:predicate];
}

-(void) loadAllPhotos {
    if(!allPhotos) {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        NSEntityDescription *e = [NSEntityDescription entityForName:@"Photo" inManagedObjectContext:context];
        
        NSSortDescriptor *sorter = [NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES];
        
        [request setEntity:e];
        [request setSortDescriptors:[NSArray arrayWithObject:sorter]];
        
        NSError *error;
        
        NSArray *result = [context executeFetchRequest:request error:&error];
        
        if(!result) {
            [NSException raise:@"FetchAll Failed" format:@"Reason: %@",[error localizedDescription]];
        }
        
        if([result count]<1) {
            NSLog(@"NO RESULTS....DELEGATE %@", self.delegate);
            [self.delegate modelWillInitialize];
            NSOperationQueue *queue = [NSOperationQueue new];
            NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(initDataFromBundle) object:nil];
            [queue addOperation:operation];
        } else {
          _availablePhotos = result;  
        }
    }
}

-(void)initDataFromBundle {
    
    NSString *zipInBundle = [[NSBundle mainBundle] pathForResource:@"test_small" ofType:@"zip"];
    NSLog(@"zip in bundle: %@", zipInBundle);
    
    ZipArchive *zipArchive = [[ZipArchive alloc] init];
    
    if ([zipArchive UnzipOpenFile:zipInBundle])
    {
        if ([zipArchive UnzipFileTo:[self documentDirectory]  overWrite:YES])
        {
            NSLog(@"Archive unzip success");
            [zipArchive UnzipCloseFile];
            //[self processPayloadJSON];
            //[[NSFileManager defaultManager] removeItemAtPath:zipInBundle error:NULL];
            [self performSelectorOnMainThread:@selector(modelDidInit) withObject:nil waitUntilDone:YES];
        }
        else
        {
            NSLog(@"Failure to unzip archive");
        }
    }
    else
    {
        NSLog(@"Failure to open archive");
    }
}

-(void)modelDidInit {
    NSLog(@"DID INIT");
    [self processPayloadJSON];
    [self.delegate modelDidInitialize];
}

-(void)checkForUpdateswithReferrer:(id)referrer {
    NSURL *url = [NSURL URLWithString:@"http://marlonharrison.com/test/version.php"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSLog(@"CHECKING");
    
    //[afClient 
    
    //NSError *error = nil;
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        float version = [[JSON valueForKeyPath:@"version"] floatValue];
        if(version > 1) {
            NSLog(@"UPDATE ME");
            [referrer modelDidFindUpdate:JSON]; 
        } else {
            NSLog(@"NO UPDATE");
            [referrer modelDidNotFindUpdate:JSON];
        }
        
        
        //NSLog(@"Name: %@ %@", [JSON valueForKeyPath:@"first_name"], [JSON valueForKeyPath:@"last_name"]);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
        NSLog(@"ERROR UPDATE %@", [error localizedDescription]);
        [referrer modelCheckUpdateError:error];
    }];
    
    [operation start];
}


-(void)checkForUpdates {
    NSURL *url = [NSURL URLWithString:@"http://marlonharrison.com/test/version.php"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSLog(@"CHECKING");
    
    //[afClient 
    
    //NSError *error = nil;
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        float version = [[JSON valueForKeyPath:@"version"] floatValue];
        if(version > 1) {
            NSLog(@"UPDATE ME");
           [self.delegate modelDidFindUpdate:JSON]; 
        } else {
            NSLog(@"NO UPDATE");
            [self.delegate modelDidNotFindUpdate:JSON];
        }
        
        
        //NSLog(@"Name: %@ %@", [JSON valueForKeyPath:@"first_name"], [JSON valueForKeyPath:@"last_name"]);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
        NSLog(@"ERROR UPDATE %@", [error localizedDescription]);
        [self.delegate modelCheckUpdateError:error];
    }];
    
    [operation start];
    
}

-(void)performUpdate {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://marlonharrison.com/test/test.zip"]];
    //NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://192.168.10.140/sdg/test.zip"]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"test.zip"];
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:path append:NO];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Successfully downloaded file to %@", path);
       // progressLabel.text = @"Unzipping archive and building data...";
        
        ZipArchive *zipArchive = [[ZipArchive alloc] init];
        
        if ([zipArchive UnzipOpenFile:path])
        {
            if ([zipArchive UnzipFileTo:[self documentDirectory]  overWrite:YES])
            {
                NSLog(@"Archive unzip success");
                //progressLabel.text = @"All done!";
                //[[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
                //[[NSFileManager defaultManager] removeItemAtPath:filePath error:NULL];
                //zipArchive = nil;
                [zipArchive UnzipCloseFile];
                //[self processPayloadJSON];
            }
            else
            {
                NSLog(@"Failure to unzip archive");
            }
        }
        else
        {
            NSLog(@"Failure to open archive");
        }
       [self processPayloadJSON];
        //[self dismissModalViewControllerAnimated:YES];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Fail" message:@"HTTPOperation failed" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }];
    
    [operation setDownloadProgressBlock:^(NSInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite) {
        
        [self.delegate modelHasDownloadProgress:totalBytesWritten outOfTotalBytes:totalBytesExpectedToWrite];
        //float percentDone = ((float)((int)totalBytesWritten) / (float)((int)totalBytesExpectedToWrite));
        //float labelDone = (percentDone) * 100;
        //progressView.progress = percentDone;
        //progressLabel.text = [NSString stringWithFormat:@"%f percent complete",labelDone];
        
        //NSLog(@"Sent %d of %d bytes, %@", totalBytesWritten, totalBytesExpectedToWrite, path);
    }];
    
    [operation start];
}

-(void)purgeCoredata {
    NSError * error =nil;
    // retrieve the store URL
    NSURL * dataStoreURL = [[context persistentStoreCoordinator] URLForPersistentStore:[[[context persistentStoreCoordinator] persistentStores] lastObject]];
    // lock the current context
    [context lock];
    [context reset];//to drop pending changes
    //delete the store from the current managedObjectContext
    if ([[context persistentStoreCoordinator] removePersistentStore:[[[context persistentStoreCoordinator] persistentStores] lastObject] error:&error])
    {
        // remove the file containing the data
        [[NSFileManager defaultManager] removeItemAtURL:dataStoreURL error:&error];
        //recreate the store like in the  appDelegate method
        [[context persistentStoreCoordinator] addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error];//recreates the persistent store
    }
    [context unlock];
    //that's it !
}

- (void)fetchedData:(NSData *)responseData {
    //parse out the json data
    //NSLog(@"Fetched Data: %@", responseData);
    NSError* error = nil;
    NSDictionary* json = [NSJSONSerialization 
                          JSONObjectWithData:responseData
                          options:kNilOptions 
                          error:&error];
    if (error != nil) {
        NSLog(@"Error : %@", error);
        //return;
    } else { 
        //init the fetch to be used while parsing
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        
        [self purgeCoredata];
        
        
        NSArray* tags = [json objectForKey:@"tags"];
        
        for (id tag in tags)
        {
            Tag *tago = [NSEntityDescription insertNewObjectForEntityForName:@"Tag" inManagedObjectContext:context];
            tago.name = [tag valueForKey:@"name"];
            NSString *val = [tag valueForKey:@"id"];
            tago.id = [NSNumber numberWithInt:[val intValue]];
            NSLog(@"TAG: %@",tago.name);
            
        }
        
        NSArray* markets = [json objectForKey:@"markets"];
        for (id market in markets)
        {
            Market *marketo = [NSEntityDescription insertNewObjectForEntityForName:@"Market" inManagedObjectContext:context];
            marketo.name = [market valueForKey:@"name"];
            NSString *val = [market valueForKey:@"id"];
            marketo.id = [NSNumber numberWithInt:[val intValue]];
            NSLog(@"MARKET: %@",marketo.name);
            
        }
        
        NSArray* afeed_types = [json objectForKey:@"feed_types"];
        for (id feed_type in afeed_types)
        {
            FeedType *fto = [NSEntityDescription insertNewObjectForEntityForName:@"FeedType" inManagedObjectContext:context];
            fto.label = [feed_type valueForKey:@"label"];
            NSString *val = [feed_type valueForKey:@"id"];
            fto.id = [NSNumber numberWithInt:[val intValue]];
            NSLog(@"ADDING FEEDTYPE: %@",fto.label);
            
        }
        
        NSArray* aphoto_types = [json objectForKey:@"photo_types"];
        for (id photo_type in aphoto_types)
        {
            PhotoType *pto = [NSEntityDescription insertNewObjectForEntityForName:@"PhotoType" inManagedObjectContext:context];
            pto.label = [photo_type valueForKey:@"label"];
            NSString *val = [photo_type valueForKey:@"id"];
            pto.id = [NSNumber numberWithInt:[val intValue]];
            NSLog(@"ADDING PHOTOTYPE: %@",pto.label);
            
        }
        
        
        [context save:&error];
        
        //NSLog(@"FEED TYPES %@", [self feedTypes]);
        
        //NSLog(@"Photo TYPES %@", [self photoTypes]);
        
        
        
        if(error) {
            NSLog(@"Ohnose UNO! %@", [error localizedDescription]);
        }
        //NSLog(@"PHOTOS: %@", [json objectForKey:@"photos"]);
        NSArray* photos = [json objectForKey:@"photos"]; //2
        NSLog(@"photos: %d", [photos count]); //3
        
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Market"
                                                  inManagedObjectContext:context];
        [fetchRequest setEntity:entity];
        NSArray *fetchedMarkets = [context executeFetchRequest:fetchRequest error:&error];
        NSLog(@"FetchedMarkets! %d", [fetchedMarkets count]);
        entity = [NSEntityDescription entityForName:@"Tag"
                             inManagedObjectContext:context];
        
        [fetchRequest setEntity:entity];
        
        NSArray *fetchedTags = [context executeFetchRequest:fetchRequest error:&error];
        NSLog(@"FetchedTags! %d", [fetchedTags  count]);
        for (id photo in photos)
        {
            Photo *mo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:context];
            mo.full_path = [photo valueForKey:@"full_path"];
            mo.thumb_path = [photo valueForKey:@"thumb_path"];
            NSString *val = [photo valueForKey:@"id"];
            mo.is_new = [NSNumber numberWithInt:[[photo valueForKey:@"is_new"] intValue]];
            

            NSPredicate *fpred = [NSPredicate predicateWithFormat:@"label == %@", [photo valueForKey:@"feed_type"]];
            
            //NSLog(@"FETCHING FEED TYPE: %@  with id %@ AND and %@", [photo valueForKey:@"feed_type"],[photo valueForKey:@"id"], [[self feedTypes] filteredArrayUsingPredicate:fpred]);
            //NSLog(@"FEED TYPES COUNT %d", [[self feedTypes] count]);
            FeedType *ft = [[[self feedTypes] filteredArrayUsingPredicate:fpred] objectAtIndex:0];
            
            NSPredicate *pred = [NSPredicate predicateWithFormat:@"label == %@", [photo valueForKey:@"photo_type"]];
            
            NSLog(@"id %@", val);
            
            //NSLog(@"FETCHING PHOTO TYPE: %@  with id %@ and ARR %@", [photo valueForKey:@"photo_type"], [photo valueForKey:@"id"], [[self photoTypes] filteredArrayUsingPredicate:pred]);
            
            //NSLog(@"PHOTO TYPES COUNT %d", [[self photoTypes] count]);
            PhotoType *pt = [[[self photoTypes] filteredArrayUsingPredicate:pred ]  objectAtIndex:0];
            
            mo.feed_type = ft;
            mo.photo_type = pt;
            
            
            //FeedType *feedType = 
            
            mo.id = [NSNumber numberWithInt:[val intValue]];
            
            NSArray * photo_tags = [photo valueForKey:@"tags"];
            NSArray * market_tags = [photo valueForKey:@"markets"];
            
            //[tagPred];
            
            for (id idx in photo_tags) {
                NSString *val = (NSString *) idx;
                NSNumber *n = [NSNumber numberWithInt:[val intValue]];
                NSPredicate *tagPred = [NSPredicate predicateWithFormat:@"id == %@", n];
                
                NSArray *filtered = [fetchedTags filteredArrayUsingPredicate:tagPred];
                //NSLog(@"TAG Filtered to %@ filtered %d", idx, [filtered count]);
                if(filtered && [filtered count]>0) {
                    //NSLog(@"Tags Filtered to %@ filtered %@", n, filtered);
                    [mo addTagsObject:[filtered objectAtIndex:0]];   
                }
            }
            
            
            
            for (id mdx in market_tags) {
                NSString *val = (NSString *) mdx;
                NSNumber *n = [NSNumber numberWithInt:[val intValue]];
                NSPredicate *marketPred = [NSPredicate predicateWithFormat:@"id == %@", n];
                
                NSArray *filtered = [fetchedMarkets filteredArrayUsingPredicate:marketPred];
                //NSLog(@"Market Filtered to %@ filtered %d", mdx, [filtered count]);
                if(filtered && [filtered count]>0) {
                    //NSLog(@"Market Filtered to %@", filtered);
                    [mo addMarketsObject:[filtered objectAtIndex:0]];   
                }

            }
            
        }
        NSLog(@"ALL PHOTOS DONE");
        [context save:&error];
        //[fetcher setEntity:[NSEntityDescription entityForName:@"Photo" inManagedObjectContext:context]];
        //NSArray * myphotos = [context executeFetchRequest:fetcher error:&error];
        NSLog(@"ANY ERROR? %@",error);
        //Our data is all set with filters applied at this point!
        
        if(error) {
            [self.delegate modelDidPerformUpdate:NO withErrorString:[error localizedDescription]];
            NSLog(@"Ohnose! %@", [error localizedDescription]);
        } else {
            [self.delegate modelDidPerformUpdate:YES withErrorString:@""];
        }
        
    }
}

-(NSArray *)feedTypes {
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"FeedType"
                                              inManagedObjectContext:context];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"label" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sort]; 
    [req setSortDescriptors:sortDescriptors];
    [req setReturnsDistinctResults:YES];
    [req setEntity:entity];
    NSError *error;
    return [context executeFetchRequest:req error:&error];
    
}

-(NSArray *)photoTypes {
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PhotoType"
                                              inManagedObjectContext:context];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"label" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sort]; 
    [req setSortDescriptors:sortDescriptors];
    [req setReturnsDistinctResults:YES];
    [req setEntity:entity];
    NSError *error;
    return [context executeFetchRequest:req error:&error];
    
}

-(NSArray *)availableMarkets {
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Market"
                                              inManagedObjectContext:context];
    NSSortDescriptor * sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    NSArray *sorts = [NSArray arrayWithObject:sort];
    [req setSortDescriptors:sorts];
    [req setReturnsDistinctResults:YES];
    [req setEntity:entity];
    NSError *error;
    return [context executeFetchRequest:req error:&error];
}


-(NSArray *)availableTags {
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Tag"
                                              inManagedObjectContext:context];
    NSSortDescriptor * sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    NSArray *sorts = [NSArray arrayWithObject:sort];
    [req setSortDescriptors:sorts];
    [req setReturnsDistinctResults:YES];
    [req setEntity:entity];
    NSError *error;
    return [context executeFetchRequest:req error:&error];
}


-(NSArray *)fetchThreadedPhotoswithPredicate:(NSPredicate *)predicate {
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Photo"
                                              inManagedObjectContext:context];
    NSSortDescriptor * sort = [NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES];
    NSArray *sorts = [NSArray arrayWithObject:sort];
    [req setSortDescriptors:sorts];
    [req setPredicate:predicate];
    [req setEntity:entity];
    NSError *error;
    [checkerMoc save:&error];
    return [checkerMoc executeFetchRequest:req error:&error];
}

-(NSArray *)fetchPhotoswithPredicate:(NSPredicate *)predicate {
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Photo"
                                              inManagedObjectContext:context];
    NSSortDescriptor * sort = [NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES];
    NSArray *sorts = [NSArray arrayWithObject:sort];
    [req setSortDescriptors:sorts];
    [req setPredicate:predicate];
    [req setEntity:entity];
    NSError *error;
    [context save:&error];
    return [context executeFetchRequest:req error:&error];
}


-(NSInteger)countPhotoswithPredicate:(NSPredicate *)predicate {
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Photo"
                                              inManagedObjectContext:context];
    [req setPredicate:predicate];
    [req setEntity:entity];
    NSError *error;
    //[context save:&error];
    return [context countForFetchRequest:req error:&error];
    //return [[self.availablePhotos filteredArrayUsingPredicate:predicate] count];
}

-(NSInteger)countThreadedPhotoswithPredicate:(NSPredicate *)predicate {
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Photo"
                                              inManagedObjectContext:context];
    [req setPredicate:predicate];
    [req setEntity:entity];
    NSError *error;
    [checkerMoc save:&error];
    return [checkerMoc countForFetchRequest:req error:&error];
}



- (NSDictionary *) indexKeyedDictionaryFromArray:(NSArray *)array 
{
    id objectInstance;
    NSUInteger indexKey = 0;
    
    NSMutableDictionary *mutableDictionary = [[NSMutableDictionary alloc] init];
    for (objectInstance in array)
        [mutableDictionary setObject:objectInstance forKey:[NSNumber numberWithUnsignedInt:indexKey++]];
        
        return mutableDictionary;
}


-(void) processPayloadJSON
{
    NSLog(@"Payload!");
    //NSURL *dataURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"data.js"]; 
    NSString *path = [[self documentDirectory] stringByAppendingPathComponent:@"/test/data.js"];
    NSLog(@"dataURL is : %@", path);
    NSFileManager * fm = [[NSFileManager alloc] init];
    BOOL exists = [fm fileExistsAtPath:path];
    dispatch_async(kBgQueue, ^{
        NSData* data = [NSData dataWithContentsOfFile:path];
        NSLog(@" DATA? %d \n %@", exists, data);
        [self performSelectorOnMainThread:@selector(fetchedData:) 
                               withObject:data waitUntilDone:YES];
    });
    
}




#pragma mark - Application's Documents directory
-(NSString *)documentDirectory
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    //NSLog(@"docDirectory IS  %@", documentDirectory);
    return documentDirectory;
}
/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)documentDirectoryURL
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


@end
