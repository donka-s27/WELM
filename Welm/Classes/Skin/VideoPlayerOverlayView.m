//
//  VideoPlayerOverlayView.m
//  Welm
//
//  Created by Luke Stanley on 12/5/15.
//  Copyright © 2015 Luke Stanley. All rights reserved.
//

#import "VideoPlayerOverlayView.h"

@interface VideoPlayerOverlayView()

@property (nonatomic, weak) UIView *topView;
@property (nonatomic, weak) UIView *videoPlayerView;
@property (nonatomic, readwrite, strong) UIButton *playButton;

@end

@implementation VideoPlayerOverlayView

- (id)initWithTopView:(UIView *)topView videoPlayerView:(UIView *)videoPlayerView
{
    if ((self = [super init])) {
        self.playButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [self.playButton setTitle:@"Play Video" forState:UIControlStateNormal];
        [self addSubview:self.playButton];
        self.backgroundColor = [UIColor whiteColor];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGRect bounds = self.bounds;
    self.playButton.frame = CGRectMake((bounds.size.width - 100)/2.0,
                                       (bounds.size.height - 50)/2.0,
                                       100,
                                       50);
    
}

@end
