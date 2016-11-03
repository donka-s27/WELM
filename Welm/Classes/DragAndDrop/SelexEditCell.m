//
//  SelexEditCell.m
//  Welm
//
//  Created by Luke Stanley on 12/4/15.
//  Copyright © 2015 Luke Stanley. All rights reserved.
//

#import "SelexEditCell.h"
#import "CommonUtils.h"
#import "VideoFilterView.h"

@interface SelexEditCell ()
{
    UIImageView* _imgFilter;
}
@end

@implementation SelexEditCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        [self.btClose removeFromSuperview];
        self.btClose = nil;
        
        _imgFilter = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:_imgFilter];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handlePress:)];
        tapGesture.numberOfTouchesRequired = 1;
        [self addGestureRecognizer:tapGesture];
    }
    return self;
}

- (void)setModel:(SelexMovieModel *)model
{
    [super setModel:model];
    
    _imgFilter.image = [VideoFilterView filterImageWithType:model.vFilter];
}

- (void)setVideoFilter:(VideoFilterType)videoFilter
{
    self.model.vFilter = videoFilter;
    
    _imgFilter.image = [VideoFilterView filterImageWithType:videoFilter];
}

#pragma mark - Gesture Recognizer

- (void)handlePress:(UITapGestureRecognizer *)gesture {

    if (gesture.state == UIGestureRecognizerStateEnded) {

        [[NSNotificationCenter defaultCenter] postNotificationName:kVideoTrackSelectedNotification object:self];
    }
}

#pragma mark - Overriden methods

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    _imgFilter.frame = self.bounds;
}

@end
