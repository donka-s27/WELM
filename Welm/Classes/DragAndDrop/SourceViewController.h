//
//  SourceViewController.h
//  Welm
//
//  Created by Luke Stanley on 12/2/15.
//  Copyright © 2015 Luke Stanley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SelexMovieModel.h"
#import "EditorViewController.h"


@protocol SourceViewDelegate <NSObject>

@optional
- (void)didSelectedDraggingItem:(SelexMovieModel*)model position:(CGPoint)pos;
- (void)didReleasedDraggingItem:(SelexMovieModel*)model position:(CGPoint)pos;

@end

@interface SourceViewController : NSObject

- (void)setUpModels;

- (void)setCellSize:(CGSize)size;
- (NSUInteger)count;

@property (nonatomic, assign) id <SourceViewDelegate> delegate;

- (instancetype)initWithCollectionView:(UICollectionView *)view viewController:(UIViewController*)viewController;

- (void)removeItem:(SelexMovieModel*)model;


@end
