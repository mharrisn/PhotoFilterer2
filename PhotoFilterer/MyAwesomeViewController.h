//
//  MyAwesomeViewController.h
//  
//
//  Created by Marlon Harrison on 4/12/12.
//  Copyright (c) 2012 . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PTImageAlbumViewController.h"

@interface MyAwesomeViewController : PTImageAlbumViewController

@property (nonatomic, strong) NSArray *images;


- (id)initWithImageAtIndex:(NSInteger)index andPhotoArray:(NSArray *)photoArray;
@end
