//
//  MyAwesomeViewController.m
//  
//
//  Created by Marlon Harrison on 4/12/12.
//  Copyright (c) 2012 . All rights reserved.
//

#import "MyAwesomeViewController.h"
#import "Photo.h"

@interface MyAwesomeViewController ()

@end

@implementation MyAwesomeViewController

@synthesize images;

- (id)initWithImageAtIndex:(NSInteger)index andPhotoArray:(NSArray *)photoArray
{
    self = [self initWithImageAtIndex:index];
    if (self) {
        images = photoArray;
    }
    return self;
}

- (CGSize)imageAlbumView:(PTImageAlbumView *)imageAlbumView sizeForImageAtIndex:(NSInteger)index {
    return CGSizeMake(1024, 768);
}

- (NSInteger)numberOfImagesInAlbumView:(PTImageAlbumView *)imageAlbumView {
    return [images count];;
}
- (UIImage *)imageAlbumView:(PTImageAlbumView *)imageAlbumView imageAtIndex:(NSInteger)index
{
    
    Photo * photo = [images objectAtIndex:index];
    NSString *path = [[self documentDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"/test/%@",[photo full_path]]];
    UIImage *img = [[UIImage alloc] initWithContentsOfFile:path]; 
    return img;
}


 
- (NSString *)imageAlbumView:(PTImageAlbumView *)imageAlbumView sourceForThumbnailImageAtIndex:(NSInteger)index
{
    Photo * photo = [images objectAtIndex:index];
    return [[self documentDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"/test/%@",[photo thumb_path]]];
}

-(void) didReceiveMemoryWarning {
    [self.thumbnailImageCache reduceMemoryUsage];
    [super didReceiveMemoryWarning];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //self.navigationController.navigationBarHidden = NO;
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

-(NSString *)documentDirectory
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    //NSLog(@"docDirectory IS  %@", documentDirectory);
    return documentDirectory;
}

@end
