//
//  UpdateViewController.h
//  
//
//  Created by Marlon Harrison on 4/16/12.
//  Copyright (c) 2012 . All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "SDGModel.h"

@interface UpdateViewController : UIViewController <SDGModelDelegate>
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) SDGModel *model;

- (IBAction)cancelPressed:(id)sender;

@end
