//
//  VideoUploader.h
//  Welm
//
//  Created by Donka Stoyanov on 11/30/15.
//  Copyright © 2015 Donka Stoyanov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "GTMOAuth2ViewControllerTouch.h"

@interface VideoUploader : NSObject

- (void)setAuthorizer:(id <GTMFetcherAuthorizationProtocol>)authorizer;

- (void)uploadVideo:(NSURL *)videoURL completionHandler:(void (^)(NSString* videoID, NSError*error))handler;
- (void)cancelUploading;

- (BOOL)isAuthorized;

- (void)getAccessToken:(void (^)(NSString* accessToken))handler;
- (void)getVideoURL:(NSString*)videoID completionHandler:(void (^)(NSString* accessToken))handler;

@property (nonatomic, strong) NSString *sharableLinkOnFolder;
@property (nonatomic) CGFloat uploadingProgress;

@property (nonatomic, strong) NSString *engineName;

@end
