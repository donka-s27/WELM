//
//  SelexCell.h
//  Welm
//
//  Created by Donka Stoyanov on 12/2/15.
//  Copyright © 2015 Donka Stoyanov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SelexMovieModel;

@interface SelexCell : UICollectionViewCell

@property (nonatomic, weak)     SelexMovieModel* model;
@property (nonatomic, strong)   UIButton* btClose;

- (UIImage*)image;

@end
