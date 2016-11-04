//
//  WelmTabBarController.h
//  Welm
//
//  Created by Donka Stoyanov on 1/7/16.
//  Copyright © 2016 Donka Stoyanov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WelmTabBarController : UITabBarController

@property (nonatomic, assign) NSUInteger initialSeletedIndex;

- (void)moveToLeft;
- (void)moveToRight;

@end
