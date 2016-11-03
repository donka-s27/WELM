//
//  TwilioSMS.h
//  Twilio
//
//  Created by Luke Stanley on 11/30/15.
//  Copyright © 2015 Luke Stanley. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TwilioSMS : NSObject

+ (TwilioSMS*) shared;
+ (void) setAccountSid:(NSString*)accountSid authToken:(NSString*)authToken;
+ (void) sendTo:(NSString*)to from:(NSString*)from message:(NSString*)message;

@end