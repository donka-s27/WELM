//
//  WelmAlertController.h
//  Welm
//
//  Created by Donka Stoyanov on 1/9/16.
//  Copyright © 2016 Donka Stoyanov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WelmAlertController : UIAlertController

+ (instancetype)alertControllerWithTitle:(NSString *)title message:(NSString *)message;

@end
