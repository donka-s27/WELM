//
//  VideoPlayerOverlayView.h
//  Welm
//
//  Created by Donka Stoyanov on 12/5/15.
//  Copyright © 2015 Donka Stoyanov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoPlayerOverlayView : UIView

@property (nonatomic, readonly, strong) UIButton *playButton;


- (id)initWithTopView:(UIView *)topView videoPlayerView:(UIView *)videoPlayerView;

@end
