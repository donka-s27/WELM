//
//  WelmTabBarController.h
//  Welm
//
//  Created by Luke Stanley on 1/7/16.
//  Copyright © 2016 Luke Stanley. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WelmTabBarController : UITabBarController

@property (nonatomic, assign) NSUInteger initialSeletedIndex;

- (void)moveToLeft;
- (void)moveToRight;

@end
