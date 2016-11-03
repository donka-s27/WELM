//
//  TrackView.h
//  Welm
//
//  Created by Luke Stanley on 12/2/15.
//  Copyright © 2015 Luke Stanley. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PHAsset;


@interface TrackView : UIImageView

- (void)setHighlightSelection:(BOOL)highlight;
- (void)setImageWithAsset:(PHAsset*)asset;

@end
