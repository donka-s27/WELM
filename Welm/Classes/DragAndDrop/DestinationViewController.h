//
//  DestinationViewController.h
//  Welm
//
//  Created by Donka Stoyanov on 12/2/15.
//  Copyright © 2015 Donka Stoyanov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SelexMovieModel.h"
#import "EditorViewController.h"

@class SelexEditCell;

@protocol DestinationViewDelegate <NSObject>

@optional
- (void)didSelectedRearrangeItem:(SelexMovieModel*)model position:(CGPoint)pos;
- (void)didReleasedRearrangeItem:(SelexMovieModel*)model index:(int)index;

@end

@interface DestinationViewController : NSObject

@property (nonatomic, assign) id <DestinationViewDelegate> delegate;

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView  viewController:(UIViewController*)viewController;
- (void)addModel:(SelexMovieModel *)model index:(int)index;
- (void)removeItem:(int)index;
- (void)removeItemWithMoviePath:(NSURL*)url;

- (void)clear;
- (void)setCellSize:(CGSize)size;

- (NSUInteger)count;

- (NSArray*)exportMovieInfo;

@end
