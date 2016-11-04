//
//  CommonUtils.m
//  Welm
//
//  Created by Donka Stoyanov on 11/30/15.
//  Copyright © 2015 Donka Stoyanov. All rights reserved.
//

#import "CommonUtils.h"
#import "SelexMovieModel.h"
#import "VideoUploader.h"

#import <SCRecorder.h>
#import <SVProgressHUD.h>
#import <Parse.h>

UIViewController* topViewController;

CGRect calculateRect(CGSize drawSize, CGSize imgSize)
{
    CGFloat r1 = imgSize.width / imgSize.height;
    CGFloat r2 = drawSize.width / drawSize.height;
    CGFloat w, h;
    if(r1 < r2)
    {
        w = drawSize.width;
        h = imgSize.height*w/imgSize.width;
    }
    else{
        
        h = drawSize.height;
        w = imgSize.width*h/imgSize.height;
    }
    
    return CGRectMake(0,0, w, h);
}


@interface CommonUtils () <SCAssetExportSessionDelegate>
{
    VideoUploader* _uploader;
}

@property (strong, nonatomic) SCAssetExportSession *exportSession;

@property (copy, nonatomic) NSString* existingAlbumIdentifier;
@property (copy, nonatomic) NSString* existingResultAlbumIdentifier;

@end

@implementation CommonUtils

+ (id)sharedObject {
    static CommonUtils* utils = nil;
    
    if(utils == nil) {
        
        utils = [[CommonUtils alloc] init];
    }
    
    return utils;
}

- (instancetype)init
{
    self = [super init];
    if(self)
    {
        [self setUp];
    }
    return self;
}

- (void)setUp
{
    self.existingAlbumIdentifier        = [[NSUserDefaults standardUserDefaults] objectForKey:kAlbumIdentifierKey];
    self.existingResultAlbumIdentifier  = [[NSUserDefaults standardUserDefaults] objectForKey:kResultAlbumIdentifierKey];
}

- (void)loadGoogleInfo
{
    _uploader = [[VideoUploader alloc] init];
}

+ (void)showModalAlertWithTitle:(NSString *)title description:(NSString*)description
{
    if(description.length == 0)
        description = @"Unknown error!";
    
    UIAlertView     *alert = [[UIAlertView alloc] initWithTitle:title message:description delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    
    [alert show];
}

+ (void)createAlbum
{
    PHFetchResult *fetchResult = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    for (NSInteger i = 0; i < fetchResult.count; i++) {
        // 获取一个相册（PHAssetCollection）
        PHCollection *collection = fetchResult[i];
        if ([collection isKindOfClass:[PHAssetCollection class]]) {
            PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
            if ([assetCollection.localizedTitle isEqualToString:@"Rd"]) {
                
                NSLog(@"localizedTitle %@",assetCollection.localizedTitle);
                return;
            }
        }
    }
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:kAlbumName];
    } completionHandler:^(BOOL success, NSError *error){
        if (!success) {
            NSLog(@"Error creating album: %@", error);
        }
    }];
}

- (void)saveSelex:(NSString *)selexPath
{
    __block NSString* albumIdentifier = self.existingAlbumIdentifier;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD show];
    });
    
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        
        PHFetchResult* fetchCollectionResult;
        
        if (albumIdentifier) {
            
            fetchCollectionResult = [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[albumIdentifier] options:nil];
        }
        
        PHAssetCollectionChangeRequest *collectionRequest = nil;
        
        if (!fetchCollectionResult || [fetchCollectionResult count] ==0) {
            
            collectionRequest = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:kAlbumName];
            albumIdentifier = collectionRequest.placeholderForCreatedAssetCollection.localIdentifier;
            
        } else {
            
            PHAssetCollection* exisitingCollection = fetchCollectionResult.firstObject;
            collectionRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:exisitingCollection];
        }
        
        PHAssetChangeRequest* createAssetRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:[NSURL fileURLWithPath:selexPath]];
        
        [collectionRequest addAssets:@[createAssetRequest.placeholderForCreatedAsset]];
        
    } completionHandler:^(BOOL success, NSError *error) {
        
        if (success) {
            
            self.existingAlbumIdentifier = albumIdentifier;
            [[NSUserDefaults standardUserDefaults] setObject:self.existingAlbumIdentifier forKey:kAlbumIdentifierKey];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kSelexAddedNotification object:nil];
            });
            
        } else {
            NSLog(@"=== = = %@", error);
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
    }];
}

- (void)saveSelex
{

    SCAssetExportSession *exportSession = [[SCAssetExportSession alloc] initWithAsset:self.recordSession.assetRepresentingSegments];
    exportSession.videoConfiguration.preset = SCPresetHighestQuality;
    exportSession.audioConfiguration.preset = SCPresetHighestQuality;
    exportSession.videoConfiguration.maxFrameRate = 35;
    exportSession.outputUrl = self.recordSession.outputUrl;
    exportSession.outputFileType = AVFileTypeQuickTimeMovie;
    exportSession.delegate = self;
    exportSession.contextType = SCContextTypeAuto;
    self.exportSession = exportSession;
    
    NSLog(@"Starting exporting");
    
    CFTimeInterval time = CACurrentMediaTime();

    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        
        if (!exportSession.cancelled) {
            NSLog(@"Completed compression in %fs", CACurrentMediaTime() - time);
        }
        
        NSError *error = exportSession.error;
        if (exportSession.cancelled) {
            NSLog(@"Export was cancelled");

            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
            });
            
        } else if (error == nil) {           
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];

                [self saveSelex:exportSession.outputUrl.path];
            });
            
        } else {
            if (!exportSession.cancelled) {
                NSLog(@"Failed to save : %@", error.localizedDescription);
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
            });
        }
    }];
}

- (void)removeSelex:(PHAsset*)asset completionHandler:(void (^)(BOOL success))handler;
{
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        
        [PHAssetChangeRequest deleteAssets:@[asset]];
        
    } completionHandler:^(BOOL success, NSError *error) {
        
        if (success) {
            handler(YES);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kSelexRemovedNotification object:nil];
            });
            
        } else {
            handler(NO);
        }
    }];
}

- (void)saveResult:(NSString *)resultPath completionHandler:(void (^)(BOOL success, NSString* errString))handler
{
    __block NSString* albumIdentifier = self.existingResultAlbumIdentifier;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD showWithStatus:@"Saving to ROUGH CUT BIN..."];
    });

    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        
        PHFetchResult* fetchCollectionResult;
        
        if (albumIdentifier) {
            
            fetchCollectionResult = [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[albumIdentifier] options:nil];
        }
        
        PHAssetCollectionChangeRequest *collectionRequest = nil;
        
        if (!fetchCollectionResult || [fetchCollectionResult count] ==0) {
            
            collectionRequest = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:kResultAlbumName];
            albumIdentifier = collectionRequest.placeholderForCreatedAssetCollection.localIdentifier;
            
        } else {
            
            PHAssetCollection* exisitingCollection = fetchCollectionResult.firstObject;
            collectionRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:exisitingCollection];
        }
        
        PHAssetChangeRequest* createAssetRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:[NSURL fileURLWithPath:resultPath]];
        
        [collectionRequest addAssets:@[createAssetRequest.placeholderForCreatedAsset]];
        
    } completionHandler:^(BOOL success, NSError *error) {
       
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });

        if (success) {
            
            self.existingResultAlbumIdentifier = albumIdentifier;
            [[NSUserDefaults standardUserDefaults] setObject:self.existingResultAlbumIdentifier forKey:kResultAlbumIdentifierKey];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kResultAddedNotification object:nil];
            });
            
            handler(YES, nil);
            
        } else {
            
            NSLog(@"%@", error);
            handler(NO, error.localizedDescription);
        }
    }];
}

- (void)postVideo:(NSURL*)movieURL hashTag:(NSString*)hashTag title:(NSString*)title sharingType:(NSString*)strType location:(NSString*)strLocation duration:(int64_t)duration completionHandler:(void (^)(BOOL success, NSString* errString))handler
{
    [_uploader uploadVideo:movieURL completionHandler:^(NSString *videoID, NSError *error) {
        
        if (videoID) {
            
            PFObject* movieInfo = [PFObject objectWithClassName:kSelexInfoName];
            
            movieInfo[kUsernameKey]     = [PFUser currentUser].username;
            movieInfo[kHashTagKey]      = hashTag;
            movieInfo[kTitleKey]        = title;
            movieInfo[kVideoIDKey]      = videoID;
            movieInfo[kSharingTypeKey]  = strType;
            movieInfo[kDurationKey]     = @(duration);
            movieInfo[kVRLocationKey]   = strLocation;
            movieInfo[kViewCountKey]    = @(0);
            
            [movieInfo saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                
                if (succeeded) {
                    handler(YES, nil);
                }
                else
                    handler(NO, error.localizedDescription);
            }];
        }
        else
            handler(NO, error.localizedDescription);
    }];
}

- (NSArray *)getSelexList
{
    NSMutableArray* photos = [NSMutableArray array];

    __block NSString* albumIdentifier = self.existingAlbumIdentifier;
    
    PHFetchResult* fetchCollectionResult;
    PHFetchResult* fetchVideoResult;
    if (albumIdentifier) {
        
        fetchCollectionResult = [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[albumIdentifier] options:nil];

        if (fetchCollectionResult && [fetchCollectionResult count] > 0) {
            
            PHAssetCollection* collection = fetchCollectionResult.firstObject;
            fetchVideoResult = [PHAsset fetchAssetsInAssetCollection:collection options:nil];

            for (PHAsset* asset in fetchVideoResult) {

                if(asset.duration < 1.0)
                    continue;
                
                [photos addObject:asset];
            }
        }
    }
    
    
    return photos;
}

- (NSArray *)getResultList
{
    NSMutableArray* photos = [NSMutableArray array];
    
    __block NSString* albumIdentifier = self.existingResultAlbumIdentifier;
    
    PHFetchResult* fetchCollectionResult;
    PHFetchResult* fetchVideoResult;
    if (albumIdentifier) {
        
        fetchCollectionResult = [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[albumIdentifier] options:nil];
        
        if (fetchCollectionResult && [fetchCollectionResult count] > 0) {
            
            PHAssetCollection* collection = fetchCollectionResult.firstObject;
            fetchVideoResult = [PHAsset fetchAssetsInAssetCollection:collection options:nil];
            
            for (PHAsset* asset in fetchVideoResult) {
                
                if(asset.duration < 1.0)
                    continue;
                
                [photos addObject:asset];
            }
        }
    }
    
    return photos;
}

- (void)getImageWithAsset:(PHAsset*)asset imageSize:(CGSize)size completionHandler:(void (^)(UIImage* thumbnail))handler;
{
    CGFloat scale = [UIScreen mainScreen].scale;
    size.width *= scale;
    size.height *= scale;
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc]init];
    options.resizeMode = PHImageRequestOptionsResizeModeExact;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage * result, NSDictionary * info) {
        
        handler(result);
    }];
}

- (void)getVideoPathWithAsset:(PHAsset*)asset completionHandler:(void (^)(NSURL* movieURL))handler
{
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc]init];
    options.synchronous = YES;
    [[PHImageManager defaultManager] requestImageDataForAsset:asset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {

        handler([info objectForKey:@"PHImageFileURLKey"]);
    }];
}

- (void)getAVAssetWithPHAsset:(PHAsset*)asset completionHandler:(void (^)(AVAsset* avasset))handler
{
    PHImageManager* imageManager = [PHImageManager defaultManager];
    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc]init];
    
    [imageManager requestAVAssetForVideo:asset options:options resultHandler:^(AVAsset *avasset, AVAudioMix *audioMix, NSDictionary *info)
     {
         handler(avasset);
     }];
}


- (void)imageWithAsset:(AVAsset*)asset frameTime:(NSTimeInterval)time visibleSize:(CGSize)size drawRect:(CGRect)drawRect completionHandler:(void (^)(UIImage* image))handler
{
    AVAssetImageGenerator *imgGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    CMTime          frameTime, actualTime;
    CGImageRef      cgImage;
    UIImage*        image;
    
    frameTime = CMTimeMakeWithSeconds(time, 600);
    cgImage = [imgGenerator copyCGImageAtTime:frameTime actualTime:&actualTime error:nil];
    
    image = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    
    UIGraphicsBeginImageContext(size);
    [image drawInRect:drawRect];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    handler(image);
}

- (void)imageWithMovieID:(NSString*)movieID completionHandler:(void (^)(UIImage* image))handler
{
    [_uploader getAccessToken:^(NSString *accessToken) {
        
        NSURL* videoURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@&access_token=%@", movieID, accessToken]];
        NSLog(@"---- start : %@", videoURL);
        AVURLAsset* asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
        AVAssetImageGenerator *imgGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        CMTime          frameTime, actualTime;
        CGImageRef      cgImage;
        UIImage*        image;
        
        frameTime = CMTimeMakeWithSeconds(0, 600);
        cgImage = [imgGenerator copyCGImageAtTime:frameTime actualTime:&actualTime error:nil];
        
        image = [UIImage imageWithCGImage:cgImage];
        CGImageRelease(cgImage);
        
        handler(image);
        NSLog(@"---- end : image = %@", image);
    }];
}

#pragma mark - SCAssetExportSessionDelegate

- (void)assetExportSessionDidProgress:(SCAssetExportSession *)assetExportSession {
    dispatch_async(dispatch_get_main_queue(), ^{

        [SVProgressHUD showProgress:assetExportSession.progress];
    });
}


@end
