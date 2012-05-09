//
//  GMGridDataViewController.h
//  
//
//  Created by Marlon Harrison on 4/20/12.
//  Copyright (c) 2012 . All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "GMGridView.h"
#import "SDGModel.h"

@interface GMGridDataViewController : UIViewController<GMGridViewDataSource, GMGridViewSortingDelegate, GMGridViewTransformationDelegate, GMGridViewActionDelegate,SDGModelDelegate,NSFetchedResultsControllerDelegate>
@property (nonatomic,strong) SDGModel *model;


-(void) reloadGrid;
@end
