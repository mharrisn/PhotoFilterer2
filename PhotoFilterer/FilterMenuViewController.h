//
//  FilterMenuViewController.h
//  
//
//  Created by Marlon Harrison on 4/10/12.
//  Copyright (c) 2012 . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDGModel.h"
#import "GMGridDataViewController.h"

@interface FilterMenuViewController : UITableViewController <SDGModelDelegate,UITableViewDelegate, UITableViewDataSource>
{
    NSMutableArray *marketDict;
    NSMutableArray *tagsDict;
    NSDictionary *feedDict;
    NSDictionary *typeDict;
    NSDictionary *newDict;
    
    NSMutableArray *photoSwitches;
    NSMutableArray *feedSwitches;
    
    NSMutableArray *marketButtons;
    NSMutableArray *tagButtons;
    
    NSMutableArray *subpredicates;
    UISwitch *newSwitch;
    NSUserDefaults *defaults;
}
@property (nonatomic,strong) SDGModel *model;
@property (nonatomic,strong) GMGridDataViewController *gridVC;


@end
