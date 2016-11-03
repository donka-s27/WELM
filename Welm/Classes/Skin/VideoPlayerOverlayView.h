//
//  VideoPlayerOverlayView.h
//  Welm
//
//  Created by Luke Stanley on 12/5/15.
//  Copyright © 2015 Luke Stanley. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoPlayerOverlayView : UIView

@property (nonatomic, readonly, strong) UIButton *playButton;


- (id)initWithTopView:(UIView *)topView videoPlayerView:(UIView *)videoPlayerView;

@end
