//
//  SelexCell.h
//  Welm
//
//  Created by Luke Stanley on 12/2/15.
//  Copyright © 2015 Luke Stanley. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SelexMovieModel;

@interface SelexCell : UICollectionViewCell

@property (nonatomic, weak)     SelexMovieModel* model;
@property (nonatomic, strong)   UIButton* btClose;

- (UIImage*)image;

@end
