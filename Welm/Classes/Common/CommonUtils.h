//
//  CommonUtils.h
//  Welm
//
//  Created by Luke Stanley on 11/30/15.
//  Copyright © 2015 Luke Stanley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "constant.h"

@class PHAsset;
@class AVAsset;
@class SCRecordSession;

#define kSelexAddedNotification         @"SelexAdded"
#define kSelexRemovedNotification       @"SelexRemoved"
#define kResultAddedNotification        @"ResultAdded"

extern UIViewController* topViewController;


@interface CommonUtils : NSObject

@property (nonatomic, strong) SCRecordSession* recordSession;

+ (id) sharedObject;

+ (void)showModalAlertWithTitle:(NSString *)title description:(NSString*)description;

+ (void)createAlbum;

- (void)loadGoogleInfo;

- (void)saveSelex;
- (void)saveSelex:(NSString*)selexPath;
- (void)removeSelex:(PHAsset*)asset completionHandler:(void (^)(BOOL success))handler;

- (void)saveResult:(NSString *)resultPath completionHandler:(void (^)(BOOL success, NSString* errString))handler;

- (void)postVideo:(NSURL*)movieURL
          hashTag:(NSString*)hashTag
            title:(NSString*)title
      sharingType:(NSString*)strType
         location:(NSString*)strLocation
         duration:(int64_t)duration
completionHandler:(void (^)(BOOL success, NSString* errString))handler;

- (NSArray *)getSelexList;
- (NSArray *)getResultList;

- (void)getImageWithAsset:(PHAsset*)asset imageSize:(CGSize)size completionHandler:(void (^)(UIImage* thumbnail))handler;
- (void)getVideoPathWithAsset:(PHAsset*)asset completionHandler:(void (^)(NSURL* movieURL))handler;
- (void)getAVAssetWithPHAsset:(PHAsset*)asset completionHandler:(void (^)(AVAsset* avasset))handler;

- (void)imageWithAsset:(AVAsset*)asset frameTime:(NSTimeInterval)time visibleSize:(CGSize)size drawRect:(CGRect)drawRect completionHandler:(void (^)(UIImage* image))handler;

- (void)imageWithMovieID:(NSString*)movieID completionHandler:(void (^)(UIImage* image))handler;

@end
