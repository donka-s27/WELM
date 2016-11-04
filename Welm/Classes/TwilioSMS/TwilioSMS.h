//
//  TwilioSMS.h
//  Twilio
//
//  Created by Donka Stoyanov on 11/30/15.
//  Copyright © 2015 Donka Stoyanov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TwilioSMS : NSObject

+ (TwilioSMS*) shared;
+ (void) setAccountSid:(NSString*)accountSid authToken:(NSString*)authToken;
+ (void) sendTo:(NSString*)to from:(NSString*)from message:(NSString*)message;

@end