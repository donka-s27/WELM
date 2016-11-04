//
//  SelexMovieModel.h
//  Welm
//
//  Created by Donka Stoyanov on 12/2/15.
//  Copyright © 2015 Donka Stoyanov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

typedef NS_ENUM(NSInteger, VideoFilterType) {
    VideoFilterTypeSuper8,
    VideoFilterTypeUltra16,
    VideoFilterTypeNormal,
    VideoFilterTypeCount
};

@interface SelexMovieModel : NSObject

@property (nonatomic,strong) PHAsset    *asset;
@property (nonatomic,strong) NSURL      *movieURL;

@property (nonatomic,assign,setter=setSelected:) BOOL isSelected;
@property (nonatomic,assign) VideoFilterType vFilter;

+ (instancetype)modelWithAsset:(PHAsset *)asset;

@end
