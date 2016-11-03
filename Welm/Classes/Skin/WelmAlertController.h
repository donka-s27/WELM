//
//  WelmAlertController.h
//  Welm
//
//  Created by Luke Stanley on 1/9/16.
//  Copyright © 2016 Luke Stanley. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WelmAlertController : UIAlertController

+ (instancetype)alertControllerWithTitle:(NSString *)title message:(NSString *)message;

@end
