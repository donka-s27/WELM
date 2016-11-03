//
//  FilmedMovieCell.h
//  Welm
//
//  Created by Luke Stanley on 1/8/16.
//  Copyright © 2016 Luke Stanley. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FilmedMovieCell : UICollectionViewCell

@property (nonatomic, strong) NSString* videoID;

@property (nonatomic, strong) NSString* videoTitle;
@property (nonatomic, strong) NSString* videoType;
@property (nonatomic, strong) NSString* videoDuration;
@property (nonatomic, strong) NSString* vrLocation;

@end
