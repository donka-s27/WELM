//
//  ResultViewController.h
//  Welm
//
//  Created by Luke Stanley on 1/10/16.
//  Copyright © 2016 Luke Stanley. All rights reserved.
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
