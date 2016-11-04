//
//  SharedMovieView.h
//  Welm
//
//  Created by Donka Stoyanov on 1/8/16.
//  Copyright © 2016 Donka Stoyanov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SharedMovieCell : UICollectionViewCell

@property (nonatomic, strong) UIImage* userProfileImage;
@property (nonatomic, strong) NSString* videoID;
@property (nonatomic, strong) NSString* videoTitle;

@end
