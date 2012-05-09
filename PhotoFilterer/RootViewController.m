//
//  RootViewController.m
//  
//
//  Created by Marlon Harrison on 4/10/12.
//  Copyright (c) 2012 . All rights reserved.
//

#import "RootViewController.h"
#import "FilterMenuViewController.h"
#import "IIViewDeckController.h"
#import "GMGridDataViewController.h"
#import "MyViewDeckViewController.h"
#import "UpdateViewController.h"
#import "SDGModel.h"
#import "MBProgressHUD.h"


@interface RootViewController ()

@end


@implementation RootViewController
@synthesize model;

-(id) init {
    self = [super init];
    
    if(self) {
        //model = [[SDGModel alloc] init];
        //model.delegate = self;
    }
    
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    
//    for ( int n = 0; n<100; n++) {
//        NSString *filename = [NSString stringWithFormat:@"thumb_%d",index];
//        
//        NSLog(@"fn is %@",filename);
//        
//        NSString *path = [[NSBundle mainBundle] pathForResource:filename ofType:@"jpg"];
//        
//        [thumbs addObject:path];
//    }
    //UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    //AQViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"AQVC"];
    //vc.images = thumbs;
    //self.topViewController = vc;
    //self.topViewController = [storyboard instantiateViewControllerWithIdentifier:@"TopUno"]; 
    //self.topViewController = [[AQViewController alloc] initWithImages:thumbs];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}
-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark -
#pragma mark Model Delegates
-(void)modelDidFindUpdate:(id)data {
    NSLog(@"RVC NEEDS UPDATE!");
    //
    UpdateViewController *vc = [[self storyboard] instantiateViewControllerWithIdentifier:@"UpdateVC"];
    vc.model = self.model;
    vc.model.delegate = vc;
    //vc.managedObjectContext = self.managedObjectContext;
    [model performUpdate];
    [[self navigationController] presentModalViewController:vc animated:YES];
}

-(void)modelWillInitialize {
    MBProgressHUD *toast = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [toast setLabelText:@"Setting Up Library"];
}

-(void)modelDidInitialize {
    NSLog(@"RVC modelDidInit");
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

-(void)modelDidNotFindUpdate:(id)data {
    NSLog(@"RVC NO UPDATE!");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Update Needed" message:@"You're up to date!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
    
}
-(void)modelCheckUpdateError:(NSError *)error {
    NSLog(@"RVC UPDATE ERROR!");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Fail" message:@"HTTPOperation failed" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}
-(void)modelDidPerformUpdate:(BOOL)updatePerformed withErrorString:(NSString *)errorString{
    //NSLog(@"RVC UPDATE DONE WITH ERROR? %@", updatePerformed);
    if(!updatePerformed) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Update Failed" message:@"HTTPOperation failed" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];   
    }
}
//-(void)modelHasDownloadProgress:(NSInteger)totalBytesWritten outOfTotalBytes:(NSInteger)totalBytesExpected{
//    NSLog(@"RVC GETTING PROGRESS: %d OUT OF %d", totalBytesWritten, totalBytesExpected);
//}


#pragma mark -
#pragma mark IBActions
- (IBAction)libraryTouch:(id)sender {
//    NSArray * paths = [NSBundle pathsForResourcesOfType: @"jpg" inDirectory: [[NSBundle mainBundle] bundlePath]];
//    NSMutableArray *thumbs = [[NSMutableArray alloc] init];
//    
//    for ( NSString * path in paths )
//    {
//        if ( ![[path lastPathComponent] hasPrefix: @"thumb"] )
//            continue;
//        NSLog(@"Adding Path %@", path);
//        
//        [thumbs addObject: path];
//    }
    
    
    FilterMenuViewController *leftController = [self.storyboard instantiateViewControllerWithIdentifier:@"Menu"];
    leftController.model = self.model;
    leftController.model.delegate = leftController;
    
    leftController.view.backgroundColor = [UIColor colorWithRed:.2 green:.2 blue:.2 alpha:1];
    
    //TopUnoViewController *center = [self.storyboard instantiateViewControllerWithIdentifier:@"TopUno"];
    
    //AQTestViewController *center = [[AQTestViewController alloc] init];
    GMGridDataViewController *center = [[GMGridDataViewController alloc] init];
    
    center.model = self.model;
    //center.model.delegate = center;
    
    //center.gridView.dataSource = thumbs;
    
    leftController.gridVC = center;
    
    MyViewDeckViewController * deckController = [[MyViewDeckViewController alloc] initWithCenterViewController:center leftViewController:leftController];
    deckController.panningMode = IIViewDeckFullViewPanning;
    deckController.centerhiddenInteractivity = IIViewDeckCenterHiddenUserInteractive;
    deckController.navigationControllerBehavior = IIViewDeckNavigationControllerContained;
    //deckController.rotationBehavior = IIViewDeckRotationKeepsLedgeSizes;
    deckController.leftLedge = self.view.bounds.size.width - 320;
    //[deckController openLeftViewAnimated:NO];

    
    [self.navigationController pushViewController:deckController animated:YES];
}


- (IBAction)checkForUpdate:(id)sender {
    [model checkForUpdateswithReferrer:self];
    //UpdateViewController *vc = [[self storyboard] instantiateViewControllerWithIdentifier:@"UpdateVC"];
    //NSLog(@"ROOT VC Context: %@",self.managedObjectContext);
    //vc.managedObjectContext = self.managedObjectContext;
    //[[self navigationController] presentModalViewController:vc animated:YES];
}

-(void)downloadPackage {
    
}

-(void)unzipPackage {
    
}

//- (IBAction)saveData:(id)sender {
//    NSManagedObjectContext *cxt = [self managedObjectContext];
//    NSManagedObject *newContinent = [NSEntityDescription insertNewObjectForEntityForName:@"Continent" inManagedObjectContext:cxt];
//    [newContinent setValue:self.continentNameFld.text forKey:@"name"];
//    _continentNameFld.text = @"";
//    
//    NSManagedObject *newCountry = [NSEntityDescription insertNewObjectForEntityForName:@"Country" inManagedObjectContext:cxt];
//    [newCountry setValue:self.countryNameFld.text forKey:@"name"];
//    _countryNameFld.text = @"";
//    
//    NSError *err;
//    if (![cxt save:&err]) {
//        NSLog(@"An error has occured: %@", [err localizedDescription]);
//    }
//    
//}


@end
