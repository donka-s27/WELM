//
//  TrackView.m
//  Welm
//
//  Created by Donka Stoyanov on 12/2/15.
//  Copyright © 2015 Donka Stoyanov. All rights reserved.
//

#import "TrackView.h"
#import "CommonUtils.h"
#import <Photos/Photos.h>

@interface TrackView ()
{
}

@end

@implementation TrackView

- (instancetype)init
{
    self = [super init];
    if(self)
    {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        [self setup];
    }
    return self;
}

- (instancetype)initWithImage:(UIImage *)image
{
    self = [super initWithImage:image];
    if(self)
    {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.clipsToBounds = YES;
    self.layer.cornerRadius = 8.0;
}

- (void)setImageWithAsset:(PHAsset*)asset
{
    [[CommonUtils sharedObject] getImageWithAsset:asset imageSize:self.bounds.size completionHandler:^(UIImage *thumbnail) {

//        dispatch_async(dispatch_get_main_queue(), ^{

            self.image = thumbnail;
//        });
    }];
}

#pragma mark - Public methods

- (void)setHighlightSelection:(BOOL)highlight {
    if (highlight) {
        self.layer.borderColor = [UIColor redColor].CGColor;
        self.layer.borderWidth = 5.0f;
    } else {
        self.layer.borderWidth = 0.0f;
    }
}

@end
