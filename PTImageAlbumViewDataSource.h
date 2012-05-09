//
// Copyright (C) 2012 Ali Servet Donmez. All rights reserved.
//
// This file is part of PTImageAlbumViewController.
// modify it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// PTImageAlbumViewController is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with PTImageAlbumViewController. If not, see <http://www.gnu.org/licenses/>.
// PTImageAlbumViewController is free software: you can redistribute it and/or
//

#import <Foundation/Foundation.h>

@class PTImageAlbumView;

@protocol PTImageAlbumViewDataSource <NSObject>

@required
- (NSInteger)numberOfImagesInAlbumView:(PTImageAlbumView *)imageAlbumView;
- (CGSize)imageAlbumView:(PTImageAlbumView *)imageAlbumView sizeForImageAtIndex:(NSInteger)index;

@optional
- (UIImage *)imageAlbumView:(PTImageAlbumView *)imageAlbumView imageAtIndex:(NSInteger)index;
- (UIImage *)imageAlbumView:(PTImageAlbumView *)imageAlbumView thumbnailImageAtIndex:(NSInteger)index;

- (NSString *)imageAlbumView:(PTImageAlbumView *)imageAlbumView sourceForImageAtIndex:(NSInteger)index;
- (NSString *)imageAlbumView:(PTImageAlbumView *)imageAlbumView sourceForThumbnailImageAtIndex:(NSInteger)index;

@end
