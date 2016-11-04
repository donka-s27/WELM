//
//  SharedMovieView.m
//  Welm
//
//  Created by Donka Stoyanov on 1/8/16.
//  Copyright © 2016 Donka Stoyanov. All rights reserved.
//

#import "SharedMovieCell.h"
#import "CommonUtils.h"

@interface SharedMovieCell ()

@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UIImageView *movieThumnail;
@property (weak, nonatomic) IBOutlet UIImageView *userImage;

@end


@implementation SharedMovieCell

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    [self setup];
}

- (void)setup
{
    self.movieThumnail.layer.masksToBounds = YES;
    self.movieThumnail.image = [UIImage imageNamed:@"testThumbnail"];
    
    self.userImage.clipsToBounds = YES;
    self.userImage.layer.cornerRadius = CGRectGetHeight(self.userImage.bounds)/2;
    self.userImage.image = [UIImage imageNamed:@"user_icon"];
    
    self.title.text = @"Tesiting Image";
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CALayer* mask = [CALayer layer];
    mask.contents = (id)[UIImage imageNamed:@"mask"].CGImage;
    self.movieThumnail.layer.mask = mask;
    self.movieThumnail.layer.mask.frame = self.movieThumnail.bounds;
}

#pragma mark - property

- (void)setVideoTitle:(NSString *)videoTitle
{
    self.title.text = videoTitle;
}

- (void)setVideoID:(NSString *)videoID
{
    _videoID = videoID;
    
    [self performSelector:@selector(updateVideoImage) withObject:nil afterDelay:0.3];
}

- (void)setUserProfileImage:(UIImage *)userProfileImage
{
    self.userImage.image = userProfileImage;
}

#pragma mark - internal

- (void)updateVideoImage
{
    [[CommonUtils sharedObject] imageWithMovieID:_videoID completionHandler:^(UIImage *image) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if(image)
                self.movieThumnail.image = image;
        });
    }];
}
@end
