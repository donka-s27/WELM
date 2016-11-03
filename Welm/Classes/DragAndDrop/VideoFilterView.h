//
//  VideoFilterView.h
//  Welm
//
//  Created by Luke Stanley on 12/19/15.
//  Copyright © 2015 Luke Stanley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SelexMovieModel.h"


@protocol VideoFilterViewDelegate <NSObject>

@required
- (void) didSelectedFilter:(VideoFilterType)type;

@end


@interface VideoFilterView : UIView

@property (nonatomic, weak) id <VideoFilterViewDelegate> delegate;
@property (nonatomic, assign) VideoFilterType filterType;

+ (UIImage*)filterImageWithType:(VideoFilterType)type;

- (instancetype)initWithImage:(UIImage*)image;

@end
