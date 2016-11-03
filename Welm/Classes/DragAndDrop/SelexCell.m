//
//  SelexCell.m
//  Welm
//
//  Created by Luke Stanley on 12/2/15.
//  Copyright © 2015 Luke Stanley. All rights reserved.
//

#import "SelexCell.h"
#import "TrackView.h"
#import "SelexMovieModel.h"
#import "CommonUtils.h"

@interface SelexCell ()
{
    TrackView* _trackView;
}


@end


@implementation SelexCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        _trackView = [[TrackView alloc] init];
        
        _btClose =  [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
        [_btClose setImage:[UIImage imageNamed:@"btCloseSmall"] forState:UIControlStateNormal];
        [_btClose addTarget:self action:@selector(removeVideo) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_trackView];
        [self.contentView addSubview:_btClose];
    }
    return self;
}

- (void)setModel:(SelexMovieModel *)model
{
    _model = model;
    
    [_trackView setImageWithAsset:model.asset];

    [[CommonUtils sharedObject] getVideoPathWithAsset:self.model.asset completionHandler:^(NSURL* movieURL) {
        
        self.model.movieURL = movieURL;
    }];
}

- (UIImage*)image
{
    return _trackView.image;
}

- (void)removeVideo
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kRemoveSelexNotification object:_model];
}

#pragma mark - Overriden methods

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _trackView.frame = self.bounds;
    
    if(_btClose)
        _btClose.frame = CGRectMake(CGRectGetWidth(self.bounds) - 40, 8, 32, 32);
}

@end
