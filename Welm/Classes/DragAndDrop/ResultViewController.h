//
//  ResultViewController.h
//  Welm
//
//  Created by Donka Stoyanov on 1/10/16.
//  Copyright © 2016 Donka Stoyanov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SelexMovieModel.h"
#import "EditorViewController.h"


@protocol ResultViewDelegate <NSObject>

@optional
- (void)didSelectedPreviewItem:(SelexMovieModel*)model position:(CGPoint)pos;

@end

@interface ResultViewController : NSObject

- (void)setUpModels;

- (void)setCellSize:(CGSize)size;
- (NSUInteger)count;

@property (nonatomic, assign) id <ResultViewDelegate> delegate;

- (instancetype)initWithCollectionView:(UICollectionView *)view  viewController:(UIViewController*)viewController;


@end
