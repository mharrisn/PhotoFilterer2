//
//  RootViewController.h
//  
//
//  Created by Marlon Harrison on 4/10/12.
//  Copyright (c) 2012 . All rights reserved.
//

//#import "ECSlidingViewController.h"
#import "SDGModel.h"

#import <CoreData/CoreData.h>


@interface RootViewController : UIViewController <SDGModelDelegate>
- (IBAction)libraryTouch:(id)sender;
- (IBAction)checkForUpdate:(id)sender;
//- (IBAction)aboutTouch:(id)sender;

@property (nonatomic,strong) SDGModel *model;
@end
