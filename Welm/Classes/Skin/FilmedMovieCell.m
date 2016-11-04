//
//  FilmedMovieCell.m
//  Welm
//
//  Created by Donka Stoyanov on 1/8/16.
//  Copyright © 2016 Donka Stoyanov. All rights reserved.
//

#import "FilmedMovieCell.h"
#import "CommonUtils.h"

@interface FilmedMovieCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imgMovie;
@property (weak, nonatomic) IBOutlet UILabel *lblPermission;
@property (weak, nonatomic) IBOutlet UILabel *lblDuraion;
@property (weak, nonatomic) IBOutlet UILabel *lblLocation;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;

@end

@implementation FilmedMovieCell

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
    self.imgMovie.image = [UIImage imageNamed:@"testThumbnail"];
}


#pragma mark - property

- (void)setVideoTitle:(NSString *)videoTitle
{
    self.lblTitle.text = videoTitle;
}

- (void)setVideoDuration:(NSString *)videoDuration
{
    self.lblDuraion.text = videoDuration;
}

- (void)setVideoType:(NSString *)videoType
{
    self.lblPermission.text = videoType;

    if([videoType isEqualToString:@"public"])
        self.lblPermission.backgroundColor = [UIColor greenColor];
    else if([videoType isEqualToString:@"lock"])
        self.lblPermission.backgroundColor = [UIColor orangeColor];
}

- (void)setVrLocation:(NSString *)vrLocation
{
    self.lblLocation.text = vrLocation;
}

- (void)setVideoID:(NSString *)videoID
{
    _videoID = videoID;
    
    [self performSelector:@selector(updateVideoImage) withObject:nil afterDelay:0.3];
}

#pragma mark - internal

- (void)updateVideoImage
{
    [[CommonUtils sharedObject] imageWithMovieID:_videoID completionHandler:^(UIImage *image) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if(image)
                self.imgMovie.image = image;;
        });
    }];
}

@end
