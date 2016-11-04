//
//  SelexMovieModel.m
//  Welm
//
//  Created by Donka Stoyanov on 12/2/15.
//  Copyright © 2015 Donka Stoyanov. All rights reserved.
//

#import "SelexMovieModel.h"

@implementation SelexMovieModel

+ (instancetype)modelWithAsset:(PHAsset *)asset
{
    SelexMovieModel *model = [[self alloc] init];
    model.asset = asset;
    model.isSelected = NO;
    model.vFilter = VideoFilterTypeNormal;
    
    return model;
}

@end
