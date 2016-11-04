//
//  TrackView.h
//  Welm
//
//  Created by Donka Stoyanov on 12/2/15.
//  Copyright © 2015 Donka Stoyanov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PHAsset;


@interface TrackView : UIImageView

- (void)setHighlightSelection:(BOOL)highlight;
- (void)setImageWithAsset:(PHAsset*)asset;

@end
