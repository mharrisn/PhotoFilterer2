//
//  FilterMenuViewController.m
//  
//
//  Created by Marlon Harrison on 4/10/12.
//  Copyright (c) 2012 . All rights reserved.
//

#define CELL_CONTENT_WIDTH 320.0f
#define CELL_CONTENT_PADDING 10.0f

#import "FilterMenuViewController.h"
#import "PhotoType.h"
#import "FeedType.h"
#import "Tag.h"
#import "Market.h"
#import "GMGridDataViewController.h"
#import "MyViewDeckViewController.h"
#import "UIButton+Property.h"
#import "UISwitch+Property.h"
#import "MBProgressHUD.h"
#import <QuartzCore/QuartzCore.h>


@interface FilterMenuViewController ()

@end

@implementation FilterMenuViewController {
    MBProgressHUD *toast;
}
@synthesize model, gridVC;

- (id)init
{
    self = [super init];
    if (self) {
        tagsDict = [[NSMutableArray alloc] init];
        marketDict = [[NSMutableArray alloc] init];
        feedSwitches = [[NSMutableArray alloc] init];
        photoSwitches = [[NSMutableArray alloc] init];
        subpredicates = [[NSMutableArray alloc] init];
        marketButtons = [[NSMutableArray alloc] init];
        tagButtons = [[NSMutableArray alloc] init];
        defaults = [NSUserDefaults standardUserDefaults];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self.tableView setSeparatorColor:[UIColor blackColor]];
    
}
-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //if(![model availablePhotos]
    [self refilterPhotos];
    [NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(showFilterView) userInfo:nil repeats:NO] ;
    
}
-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

-(void)showFilterView {
    NSLog(@"showFilterView");
    MyViewDeckViewController * deckController = (MyViewDeckViewController *) [self parentViewController];
    [deckController  openLeftViewAnimated:YES];
    
}

-(void)hideFilterView {
    NSLog(@"hideFilterView");
    MyViewDeckViewController * deckController = (MyViewDeckViewController *) [self parentViewController];
    [deckController  closeLeftViewAnimated:YES];
}

-(void) headerClearButton:(id)sender {
    UIButton *button = (UIButton *)sender;
    NSLog(@"Clear section %d", button.tag);
    
    if(button.tag == 1) {
        //Phototype
        for (UISwitch *control in photoSwitches) {
            [control setOn:NO animated:YES];
            [control.property setValue:0 forKey:@"selected"];
        }
    }
    if(button.tag == 2) {
            //Feedtype
            for (UISwitch *control in feedSwitches) {
                [control setOn:NO animated:YES];
                [control.property setValue:0 forKey:@"selected"];
            }
    }
    if(button.tag == 3) {
        //Markets
        for (UIButton *control in marketButtons) {
            control.selected = NO;
            [control.property setValue:0 forKey:@"selected"];
        }
    }
    if(button.tag == 4) {
        //Tags
        for (UIButton *control in tagButtons) {
            control.selected = NO;
            [control.property setValue:0 forKey:@"selected"];
        }
    }
    
    [self refilterPhotos];
    
}

-(void)feedSwitchToggled:(id)sender {
    UISwitch *ui = (UISwitch *)sender;
    //if (ui.on) {
        for (UISwitch *control in feedSwitches) {
            //UISwitch *offon = (UISwitch *)control;
            if(ui != control && ui.on) {
                [control setOn:NO animated:YES];
            }
            FeedType * type = (FeedType *) control.property;
            type.selected = [NSNumber numberWithBool:control.on];
        }
    //}
    //NSLog(@"Feed Switch! %d", ui.on);
    [self refilterPhotos];
}
-(void)newSwitchToggled:(id)sender {
    UISwitch *ui = (UISwitch *)sender;
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithBool:ui.enabled],@"enabled",[NSNumber numberWithBool:ui.on],@"selected", nil];
    [defaults setObject:dict forKey:@"newSwitchSettings"];
    BOOL synched = [defaults synchronize];
    NSLog(@"newSwitch saved to %d", synched);
    [self refilterPhotos];
}

-(void)photoSwitchToggled:(id)sender {
    UISwitch *ui = (UISwitch *)sender;
    
    
    
    //NSLog(@"controls! %@", photoSwitches);
    //if (ui.on) {
        for (UISwitch *control in photoSwitches) {
            //UISwitch *offon = (UISwitch *)control;
            if(ui != control  && ui.on) {
               [control setOn:NO animated:YES]; 
            }
            PhotoType * type = (PhotoType *) control.property;
            type.selected = [NSNumber numberWithBool:control.on];
       // }
    }
    
    //NSLog(@"Photo Switch! %d", ui.on);
    [self refilterPhotos];
}

-(void)fetchPhotos {
    NSManagedObjectContext *checkerMoc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    checkerMoc.persistentStoreCoordinator = [model getPersistentStore];
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Photo"
                                              inManagedObjectContext:checkerMoc];
    [req setEntity:entity];
    
    subpredicates = [[NSMutableArray alloc] init];
    
    NSPredicate *isNewPredicate;
    if(newSwitch.on) {
        isNewPredicate = [NSPredicate predicateWithFormat:@"is_new == 1"];
    } else {
        isNewPredicate = [NSPredicate predicateWithFormat:@"is_new == 0"];
    }
    
    [subpredicates addObject:isNewPredicate];
    
    //Photo Types
    PhotoType *photoType;
    NSPredicate *photoTypePredicate;
    for (UISwitch *photoSwitch in photoSwitches) {
        PhotoType * type = (PhotoType *) photoSwitch.property;
        if([type.selected boolValue] == YES) {
            NSLog(@"photo_type.label == %@", type.label);
            photoType = type;
            photoTypePredicate = [NSPredicate predicateWithFormat:@"photo_type.label == %@", type.label];
            break;
        }
    }
    
    //Feed Types
    FeedType *feedType;
    NSPredicate *feedTypePredicate;
    for (UISwitch *feedSwitch in feedSwitches) {
        FeedType * type = (FeedType *) feedSwitch.property;
        if([type.selected boolValue] == YES) {
            NSLog(@"feed_type.label == %@", type.label);
            feedType = type;
            feedTypePredicate = [NSPredicate predicateWithFormat:@"feed_type.label == %@", type.label];
            break;
        }
    }
    
    //Markets
    //NSMutableString *str;
    // NSMutableArray *searchMarkets = [[NSMutableArray alloc] init];
    //NSString *qMarket = nil;
    NSArray *filteredMarkets = [model.availableMarkets filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"selected == 1"]];
    for (Market *market in filteredMarkets) {
        //if([market.selected boolValue] == YES) {
        NSLog(@"ANY markets.name == %@",market.name);
        [subpredicates addObject:[NSPredicate predicateWithFormat:@"ANY markets.name == %@", market.name]];
        //}
    }
    //qMarket = @"marktets in %@",markets;
    
    
    //Tags
    //NSMutableString *str;
    NSArray *filteredTags = [model.availableTags filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"selected == 1"]];
    //NSLog(@"FILTERED %@", filteredTag);
    for (Tag *tag in filteredTags) {
        NSLog(@"ANY tags.name == %@",tag.name);
        [subpredicates addObject:[NSPredicate predicateWithFormat:@"ANY tags.name == %@", tag.name]];
    }
    
    if(photoTypePredicate)
        [subpredicates addObject:photoTypePredicate];
    if(feedTypePredicate)
        [subpredicates addObject:feedTypePredicate];
    
    NSPredicate *finished = [NSCompoundPredicate andPredicateWithSubpredicates:subpredicates];//Your final predicate
    
    [req setPredicate:finished];
    
    //NSLog(@"FINAL PREDITCATE:::: %@", subpredicates);
    
    //NSError *error;
    //[checkerMoc save:&error];
    
    model.availablePhotos = [model fetchThreadedPhotoswithPredicate:finished];
    NSLog(@"FILTERED PHOTOS:::: %d", [model.availablePhotos count]);
    //[checkerMoc executeFetchRequest:req error:&error];
    //[model fetchPhotoswithPredicate:finished];
    [[self parentViewController] setTitle:[NSString stringWithFormat:@"%d items",[model.availablePhotos count]]];
    
    NSLog(@"GRID: Reload");
    [gridVC reloadGrid];
    
    /*
     *  UI Filtering to disabled 0 result controls.
     */
    
    [subpredicates removeObject:isNewPredicate];
    //New Toggle
    NSPredicate *newRemainderPredicate = [NSPredicate predicateWithFormat:@"is_new == %d",newSwitch.on?0:1];
    [subpredicates addObject:newRemainderPredicate];
    
    NSInteger newCount = [model countThreadedPhotoswithPredicate:[NSCompoundPredicate andPredicateWithSubpredicates:subpredicates]];
    
    if(newCount<1) {
        [newSwitch setEnabled:NO];
        newSwitch.enabled = NO;
        NSLog(@"NEW %d count = %d", newSwitch.enabled, newCount);
    } else {
        [newSwitch setEnabled:YES];
    }
    
    NSLog(@"NEW %d count = %d", !newSwitch.on, newCount);
    [subpredicates removeObject:newRemainderPredicate];
    [subpredicates addObject:isNewPredicate];
    
    
    
    
    [subpredicates removeObject:photoTypePredicate];
    //Photo Type Toggles
    NSArray *remainderPhotoTypes = [photoSwitches filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"on == NO"]];
    for( UISwitch*control in remainderPhotoTypes) {
        PhotoType *remainderPhotoType = (PhotoType*)control.property;
        
        [subpredicates addObject:[NSPredicate predicateWithFormat:@"photo_type == %@", remainderPhotoType]];
        int count = [model countThreadedPhotoswithPredicate:[NSCompoundPredicate andPredicateWithSubpredicates:subpredicates]];
        NSLog(@"PhotoType Count for %@: %d", remainderPhotoType.label, count);
        if(count<1) {
            control.enabled = NO;
        } else {
            control.enabled = YES;
        }
        remainderPhotoType.enabled = [NSNumber numberWithBool:control.enabled];
        [subpredicates removeObject:[NSPredicate predicateWithFormat:@"photo_type == %@", remainderPhotoType]];
    }
    if(photoTypePredicate)
        [subpredicates addObject:photoTypePredicate];
    
    
    
    
    [subpredicates removeObject:feedTypePredicate];
    //Feed Type Toggles
    NSArray *remainderFeedTypes = [feedSwitches filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"on == NO"]];
    for( UISwitch*control in remainderFeedTypes) {
        PhotoType *remainderFeedType = (PhotoType*)control.property;
        
        [subpredicates addObject:[NSPredicate predicateWithFormat:@"feed_type == %@", remainderFeedType]];
        int count = [model countThreadedPhotoswithPredicate:[NSCompoundPredicate andPredicateWithSubpredicates:subpredicates]];
        NSLog(@"FeedType Count for %@: %d", remainderFeedType.label, count);
        if(count<1) {
            control.enabled = NO;
        } else {
            control.enabled = YES;
            
        }
        remainderFeedType.enabled = [NSNumber numberWithBool:control.enabled];
        [subpredicates removeObject:[NSPredicate predicateWithFormat:@"feed_type == %@", remainderFeedType]];
    }
    if(feedTypePredicate)
        [subpredicates addObject:feedTypePredicate];
    
    //Markets
    NSArray *remainderMarkets = [[model availableMarkets] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"selected == 0"]];
    for( Market *remainderMarket in remainderMarkets) {
        [subpredicates addObject:[NSPredicate predicateWithFormat:@"ANY markets == %@", remainderMarket]];
        NSInteger countForTag = [model countThreadedPhotoswithPredicate:[NSCompoundPredicate andPredicateWithSubpredicates:subpredicates]];
        if(countForTag<1) {
            remainderMarket.enabled = [NSNumber numberWithInt:0];
        } else {
            remainderMarket.enabled = [NSNumber numberWithInt:1];
        }
        [subpredicates removeObject:[NSPredicate predicateWithFormat:@"ANY markets == %@", remainderMarket]];
    }
    
    
    //Tags
    NSArray *remainderTags = [[model availableTags] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"selected == 0"]];
    NSLog(@"TAG UI: %d total buttons :: %d filtered ",[[model availableTags] count], [remainderTags count]);
    int tagCounter = 0;
    for( Tag *remainderTag in remainderTags) {
        [subpredicates addObject:[NSPredicate predicateWithFormat:@"ANY tags.name == %@", remainderTag.name]];
        NSInteger countForTag = [model countThreadedPhotoswithPredicate:[NSCompoundPredicate andPredicateWithSubpredicates:subpredicates]];
        if(countForTag<1) {
            NSLog(@"TAG OFF %@", remainderTag.name);
            remainderTag.enabled = 0;
        } else {
            NSLog(@"TAG ON %@ count = %d", remainderTag.name, countForTag);
            remainderTag.enabled = [NSNumber numberWithInt:1];
        }
        [subpredicates removeObject:[NSPredicate predicateWithFormat:@"ANY tags.name == %@", remainderTag.name]];
        tagCounter ++;
    }

    
    
    
    [self performSelectorOnMainThread:@selector(photosFetched) withObject:nil waitUntilDone:YES];
}

-(void) photosFetched {
    //[toast setLabelText:@"Updating Controls"];     
    NSLog(@"photosFetched");
    [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(hideToast) userInfo:nil repeats:NO] ;
//    NSOperationQueue *queue = [NSOperationQueue new];
//    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(updateControls) object:nil];
//    [queue addOperation:operation];
}

-(void)hideToast {
    NSLog(@"hideToast");
    [MBProgressHUD hideHUDForView:gridVC.view animated:YES];
}

-(void)updateControls {
    /**
     *  Filtering Section Here, I'm running count requests for each grouping of controls to ensure if they're selected, results will be returned.
     *  If zero results, I'll disable that control. For the switch-based controls, I need to removed them before running my fetches since there can only be
     *  one switch value per photo.
     */
    [gridVC reloadGrid];
    [self.tableView reloadData];
    [self performSelectorOnMainThread:@selector(controlsUpdated) withObject:nil waitUntilDone:YES];
}

-(void) controlsUpdated {
    [MBProgressHUD hideHUDForView:gridVC.view animated:YES];
}

-(void) refilterPhotos {
    toast = [MBProgressHUD showHUDAddedTo:gridVC.view animated:YES];
    [toast setLabelText:@"Filtering Photos"];
    NSOperationQueue *queue = [NSOperationQueue new];
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(fetchPhotos) object:nil];
    [queue addOperation:operation];
    
    
    
    
    
   
    
    
    
    
    //Now lets update the controls for any that won't yield results.
    
    //NSLog(@"Removing predicates %@ \n %@ \n %@", isNewPredicate, photoTypePredicate, feedTypePredicate);
    
    
    //[subpredicates removeObject:photoTypePredicate];
    //[subpredicates removeObject:feedTypePredicate];
    
    
    
}


- (void) populateFilterCell:(UITableViewCell *) cell withControlData:(id)controlData forSection:(NSInteger) section {
    UISwitch *toggler = (UISwitch *)[cell viewWithTag:10];
    UIColor *tint;
    
    switch (section) {
        case 0:
            //94.0	13.0	42.0	
            tint = [UIColor colorWithRed:.94 green:.13 blue:.42 alpha:1];
            break;
        case 1:
            //99.0	58.0	13.0	
            tint = [UIColor colorWithRed:.99 green:.58 blue:.13 alpha:1];
            break;
        default:
            //56.0	17.0	76.0	
            tint = [UIColor colorWithRed:.56 green:.17 blue:.76 alpha:1];
            break;
    }
    // = section == 0?[UIColor orangeColor]:[UIColor purpleColor];
    toggler.onTintColor = tint;
    //NSLog(@"TOGGLER %@", toggler);
    
    toggler.property = (NSObject *)controlData;
   
    
    if(section == 0) {
        newSwitch = toggler;
        
        
        if(controlData) {
        BOOL selected = [[controlData valueForKey:@"selected"] intValue] == 1;
        BOOL enabled = [[controlData valueForKey:@"enabled"] intValue] == 1;
        toggler.on = selected;
        toggler.enabled = enabled;
        } else {
            defaults = [NSUserDefaults standardUserDefaults];
            NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:1],@"enabled",[NSNumber numberWithInt:0],@"selected", nil];
            [defaults setObject:dict forKey:@"newSwitchSettings"];
            [defaults synchronize]; 
        }
        [toggler addTarget:self  action:@selector(newSwitchToggled:) forControlEvents:UIControlEventTouchUpInside];
        return;
    }
     BOOL selected = [[controlData valueForKey:@"selected"] intValue] == 1;
    toggler.on = selected;
    
     if(section<2) {
         if(photoSwitches == nil) {
             photoSwitches = [[NSMutableArray alloc] init];
         }
         [toggler addTarget:self  action:@selector(photoSwitchToggled:) forControlEvents:UIControlEventTouchUpInside];
         [photoSwitches addObject:toggler]; 
         //NSLog(@"FEEDTYPE COUNT %@", photoSwitches);
     } else {
         if(feedSwitches == nil) {
             feedSwitches = [[NSMutableArray alloc] init];
         }
         [toggler addTarget:self action:@selector(feedSwitchToggled:) forControlEvents:UIControlEventTouchUpInside];
         [feedSwitches addObject:toggler];
         //NSLog(@"FEEDTYPE COUNT %d", [feedSwitches count]);
     }
    
}

- (void )populateCell:(UITableViewCell *) cell withButtonsFromArray:(NSArray *) buttonArray forSection:(NSInteger) section toStoreInArray:(NSMutableArray *)storageArray {
    //NSMutableArray *dict = section<3? marketDict:tagsDict;
    
    NSLog(@"Popuplating Cell for section %d with count of %d",section, [buttonArray count]);
    //Clear all subviews
    if([[cell.contentView subviews] count]>0)  {
        for (UIView *view in [cell.contentView subviews]) {
            [view removeFromSuperview];
        }
    }
    
    int col = 0;
    int cols = 2;
    int sx = 0;
    int sy = 6;
    
    for (int i = 0; i<[buttonArray count]; i++) {
        id obj = (id) [buttonArray objectAtIndex:i];
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(sx, sy, 140, 44)];
        NSString *button_on = section<4?@"market_on":@"tag_on";
        [button setBackgroundImage:[UIImage imageNamed:@"button_off"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:button_on] forState:UIControlStateSelected];
        [button setBackgroundImage:[UIImage imageNamed:@"tag_disabled"] forState:UIControlStateDisabled];
        if (section == 3) {
            [button addTarget:self action:@selector(marketPressed:) forControlEvents:UIControlEventTouchUpInside];
        } else {
            [button addTarget:self action:@selector(tagPressed:) forControlEvents:UIControlEventTouchUpInside];
        }
        button.property = (NSObject *)[buttonArray objectAtIndex:i];
        button.enabled = [[obj valueForKey:@"enabled"] boolValue];
        bool selected = [[obj valueForKey:@"selected"] intValue] == 1;
        [button setTitle:[obj valueForKey:@"name"] forState:UIControlStateNormal];
        //[button setTitle:[obj valueForKey:@"name"] forState:UIControlStateSelected];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
        //button.titleLabel.frame = CGRectMake(0, 0, 40, 44);
        //button.titleLabel.autoresizingMask = UIViewAutoresizingNone;
        button.titleLabel.textAlignment = UITextAlignmentCenter;
        [button.titleLabel sizeToFit];
        [button setSelected:selected];
        [button setNeedsLayout];
        
        [cell.contentView addSubview:button];
        //[tagsDict setObject:obj forKey:button];
        //[dict addObject:button];
        [storageArray addObject:button];
        //[dict a
        
        sx += button.frame.size.width + 10;
        col++;
        if(col == cols) {
            sx = 0;
            col = 0;
            sy += button.frame.size.height + 6;
        }
        
    }
    
    if(section == 4) {
        //NSLog(@"filling tags %d count vs tagButtons %@", [buttonArray count], tagButtons);
    }
    cell.contentView.center = CGPointMake(160, 0);
    //[self rebuildPredicateString];
    
    //NSLog(@"DICT %d \n %d", section, [storageArray count]);
    
}




-(void)marketPressed:(id)sender {
    UIButton *button = (UIButton *) sender;
    [button setSelected:!button.selected];
    //NSInteger index = [[[button superview] subviews] indexOfObjectIdenticalTo:button ];
    Market *market = (Market *) button.property;
    //[[model availableMarkets] objectAtIndex:index];
    market.selected = [NSNumber numberWithBool:button.selected];
    //id obj = [tagsDict objectForKey:button];
    //NSLog(@"Button Pressed! %@", market.name);
    [self refilterPhotos];
}

-(void)tagPressed:(id)sender {
    UIButton *button = (UIButton *) sender;
    [button setSelected:!button.selected];
    //[button.property setValue:[button.selected intValue]; forKey:@"selected"];
    //NSInteger index = [[[button superview] subviews] indexOfObjectIdenticalTo:button ];
    Tag *tag = (Tag *) button.property;//[[model availableTags] objectAtIndex:index];
    tag.selected = [NSNumber numberWithBool:button.selected];
    
   //NSLog(@"Button Pressed! %@", tag.name);
    [self refilterPhotos];
}
#pragma mark TableView Delegate
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width, 44)];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = headerView.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor darkGrayColor] CGColor], (id)[[UIColor blackColor] CGColor], nil];
    [headerView.layer insertSublayer:gradient atIndex:0];
    
    NSString *title;
    switch (section) {
        case 1:
            title = @"Image Type";
            break;
        case 2:
            title = @"Feed Type";
            break;
        case 3:
            title = @"Market Segments";
            break;
        case 4:
            title = @"Tags";
            break;
            
        default:
            break;
    }
    
    // create the label
	UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 300, headerView.frame.size.height)];
	headerLabel.backgroundColor = [UIColor clearColor];
	headerLabel.opaque = NO;
	headerLabel.textColor = [UIColor whiteColor];
	headerLabel.highlightedTextColor = [UIColor whiteColor];
    //headerLabel.
	headerLabel.font = [UIFont boldSystemFontOfSize:16];
	headerLabel.text = title;
    [headerView addSubview:headerLabel];
    
    // create the button object
    UIButton * headerBtn = [[UIButton alloc] initWithFrame:CGRectMake(220, 9, 55, 25)];
    headerBtn.backgroundColor = [UIColor clearColor];
    [headerBtn setImage:[UIImage imageNamed:@"btn-clear"] forState:UIControlStateNormal];
    [headerBtn setImage:[UIImage imageNamed:@"btn-clear-down"] forState:UIControlStateHighlighted];
    
    headerBtn.opaque = YES;
    headerBtn.tag = section;
    //headerBtn.frame = CGRectMake(100.0, 10.0, 100.0, 44.0);
    //[headerBtn setTitle:@"CLEAR" forState:UIControlStateNormal];
    [headerBtn addTarget:self action:@selector(headerClearButton:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:headerBtn];
    
    return section>0?headerView:nil;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return section==0?0:44;
}




#pragma mark TableViewDataSource Delgate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    switch ([indexPath section]) {
        case 3:
            return  6+((ceilf([[model availableMarkets] count]/2)) * 50);
            break;
        case 4:
            return 6+((ceilf([[model availableTags] count]/2)) * 50);
            break;
        default:
            return 60;
            break;
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 1:
            NSLog(@"Photo Types %d", [[model photoTypes] count]);
            return [[model photoTypes] count];
            break;
        case 2:
            NSLog(@"Feed Types %d", [[model feedTypes] count]);
            return [[model feedTypes] count];
            break;
        case 3:
            marketButtons = [[NSMutableArray alloc] init];
            return 1;
            break;
        case 4:
            tagButtons = [[NSMutableArray alloc] init];
            return 1;
            break;
        default:
            return 1;
            break;
    }
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    defaults = [NSUserDefaults standardUserDefaults];
    NSInteger section = [indexPath section];
    UITableViewCell *cell;
    NSString *str;
    UILabel *label;
    id obj;
    switch (section) {
        case 0:
            cell = [tableView dequeueReusableCellWithIdentifier:@"TypeFilterCell"];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TypeFilterCell"];
            }
            label = (UILabel *) [cell viewWithTag:1];
            [label setText:@"new"];
            obj = [defaults objectForKey:@"newSwitchSettings"];
            [self populateFilterCell:cell withControlData:obj forSection:section];
            break;
        case 1:
            obj = [[model photoTypes] objectAtIndex:[indexPath row]];
            str = [[[model photoTypes] objectAtIndex:[indexPath row]] label];    
            cell = [tableView dequeueReusableCellWithIdentifier:@"TypeFilterCell"];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TypeFilterCell"];
            }
            label = (UILabel *) [cell viewWithTag:1];
            [label setText:str];
            [self populateFilterCell:cell withControlData:obj forSection:section];
            break;
        case 2:
            obj = [[model feedTypes] objectAtIndex:[indexPath row]];
            str = [[[model feedTypes] objectAtIndex:[indexPath row]] label];
            cell = [tableView dequeueReusableCellWithIdentifier:@"TypeFilterCell"];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TypeFilterCell"];
            }
            label = (UILabel *) [cell viewWithTag:1];
            [label setText:str];
            [self populateFilterCell:cell withControlData:obj forSection:section];
            break;
        case 3:
            cell = [tableView dequeueReusableCellWithIdentifier:@"TagCell"];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TagCell"];
            }
            if(!marketButtons)
                marketButtons = [[NSMutableArray alloc] init];
            [self populateCell:cell withButtonsFromArray:[model availableMarkets] forSection:section toStoreInArray: marketButtons];
            break;
        case 4:
            cell = [tableView dequeueReusableCellWithIdentifier:@"TagCell"];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TagCell"];
            }
            if(!tagButtons)
                tagButtons = [[NSMutableArray alloc] init];
            [self populateCell:cell withButtonsFromArray:[model availableTags] forSection:section toStoreInArray: tagButtons];
            break;
        default:
            cell = [tableView dequeueReusableCellWithIdentifier:@"TagCell"];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TagCell"];
            }
            break;
    }
    
    cell.contentView.backgroundColor = [UIColor clearColor];//[[UIColor alloc] initWithRed:.22 green:.22 blue:.22 alpha:1];
    return cell;
    
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 5;
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    switch (section) {
//        case 0:
//            return @"Photo Types";
//            break;
//        case 1:
//            return @"Feed Types";
//            break;
//        case 2:
//            return @"Markets";
//            break;
//        case 3:
//            return @"Tags";
//            break;
//        default:
//            return  @"**";
//            break;
//    }
//}


@end
