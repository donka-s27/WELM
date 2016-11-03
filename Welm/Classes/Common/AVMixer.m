//
//  AVMixer.m
//  Welm
//
//  Created by Luke Stanley on 12/5/15.
//  Copyright © 2015 Luke Stanley. All rights reserved.
//

#import "AVMixer.h"
#import "constant.h"
#import "SVProgressHUD.h"

#import <AVFoundation/AVFoundation.h>
#import "CommonUtils.h"
#import "WaterMarkCreator.h"

@interface AVMixer ()
{
    NSUInteger              _curIndex;
    float                   _completeProgress;
    
    NSArray*                _movies;
    NSMutableArray*         _outMovies;
    AVAssetExportSession*   _exportSession;

    WaterMarkCreator*       _watermarkCreator;
}
@end

@implementation AVMixer

- (instancetype)initWithDelegate:(id <AVMixerDelegate>)delegate
{
    self = [super init];
    if(self)
    {
        _delegate = delegate;

        _outMovies = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)reset
{
    if(_exportSession)
    {
        [_exportSession cancelExport];
        _exportSession  = nil;
    }
    
    _curIndex = 0;
    _completeProgress = 0;
    
    _movies = nil;
    
    for (NSURL* movieURL in _outMovies) {
        [[NSFileManager defaultManager] removeItemAtURL:movieURL error:nil];
    }
    
    [_outMovies removeAllObjects];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
    });
}

- (void)exportMovies:(NSArray*)selexArray
{
    [self reset];
    
    _movies = selexArray;
    
    for (NSDictionary* info in selexArray) {
        [_outMovies addObject:info[kMovieURLKey]];
    }
    
    [SVProgressHUD show];
    
    [self startExport];
}

- (void)startExport
{
    if(_curIndex >= _movies.count)
    {
        [SVProgressHUD dismiss];
        
        [self completeExport];
        return;
    }
    
    NSDictionary* movieInfo = _movies[_curIndex];
    NSNumber* width = movieInfo[kMovieWidthKey];
    NSNumber* height = movieInfo[kMovieHeightKey];
    
    [self exportMovie:movieInfo[kMovieURLKey]
         overlayImage:movieInfo[kMovieFilterKey]
           exportSize:CGSizeMake(width.floatValue, height.floatValue)
           completionHandler:^(NSURL *savePath) {
               
               if(savePath)
                   _outMovies[_curIndex] = savePath;

               _completeProgress = 1.0 / _movies.count * _curIndex;

               _curIndex ++;
               
               [self startExport];
    }];
}

- (void)completeExport
{
    _exportSession = nil;
    
    AVMutableComposition* mixComposition = [[AVMutableComposition alloc] init];

    AVAssetTrack* videoTrack;
    AVAssetTrack* audioTrack;
    AVMutableCompositionTrack *videoCompTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableCompositionTrack *audioCompTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];

    AVURLAsset* asset;
    CMTime totalDuration= kCMTimeZero;
    
    for (NSURL* movieURL in _outMovies) {
        
        asset = [AVURLAsset URLAssetWithURL:movieURL options:nil];
        
        videoTrack = [asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
        audioTrack = [asset tracksWithMediaType:AVMediaTypeAudio].firstObject;

        [videoCompTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) ofTrack:videoTrack atTime:totalDuration error:nil];
        [audioCompTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) ofTrack:audioTrack atTime:totalDuration error:nil];
        
        totalDuration = CMTimeAdd(totalDuration, asset.duration);
    }
    
    NSURL* savePath = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:kPreviewMoviePath]];
    [[NSFileManager defaultManager] removeItemAtPath:savePath.path error:nil];
    
    _exportSession = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetPassthrough];
    _exportSession.outputFileType = AVFileTypeQuickTimeMovie;
    _exportSession.outputURL = savePath;
    
    CMTimeValue val = mixComposition.duration.value;
    CMTime      start = CMTimeMake(0, mixComposition.duration.timescale);
    CMTime      duration = CMTimeMake(val, mixComposition.duration.timescale);
    CMTimeRange range = CMTimeRangeMake(start, duration);
    
    _exportSession.timeRange = range;
    
    [_exportSession exportAsynchronouslyWithCompletionHandler:^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            switch ((int)[_exportSession status]) {
                case AVAssetExportSessionStatusFailed:
                {
                    NSLog(@" == Mix Error : %@", _exportSession.error);
                    
                    if(self.delegate)
                        [self.delegate didFailAVMix:self errorString:[[_exportSession error] localizedDescription]];
                    
                    [self reset];
                    break;
                }
                case AVAssetExportSessionStatusCancelled:
                {
                    if(self.delegate)
                        [self.delegate didCanceledAVMix:self errorString:[[_exportSession error] localizedDescription]];
                    
                    [self reset];
                    
                    break;
                }
                case AVAssetExportSessionStatusCompleted:
                {
                    if(self.delegate)
                        [self.delegate didCompleteAVMix:self output:savePath];
                    
                    [self reset];
                    
                    break;
                }
            };
            
        });
    }];
    
    [self performSelector:@selector(updateMixProgress) withObject:nil afterDelay:0.1];
}

- (void)updateMixProgress
{
    if(_exportSession && self.delegate)
    {
        if ([self.delegate respondsToSelector:@selector(didChangeMixProgress:progress:)])
            [self.delegate didChangeMixProgress:self progress:_exportSession.progress];
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD showProgress:_exportSession.progress];
            });
        }
        
        [self performSelector:@selector(updateMixProgress) withObject:nil afterDelay:0.1];
    }
}

- (void)exportMovie:(NSURL*)moviePath overlayImage:(UIImage*)image exportSize:(CGSize)exportSize completionHandler:(void (^)(NSURL* savePath))handler
{
    WaterMarkImageItem *imageItem = [[WaterMarkImageItem alloc] init];
    imageItem.watermarkImage = image;
    imageItem.watermarkFrameOnOriginalImageView = CGRectMake(0, 0, exportSize.width, exportSize.height);
    
    WaterMarkCreatorModel *model = [[WaterMarkCreatorModel alloc] init];
    model.originalVideoURLString = moviePath.path;
    model.originalImageSize = exportSize;
    model.originalImageViewSize = exportSize;
    model.itemArray = @[imageItem];
    model.successBlock = ^(WaterMarkCreatorModel *originItem, UIImage *processedImage, NSURL *processedVideoUrl) {
        if(processedVideoUrl)
        {
            handler(processedVideoUrl);
        }
    };
    model.failedBlock = ^(NSError *error) {
        
        handler(nil);
    };

    _watermarkCreator = [[WaterMarkCreator alloc] init];
    [_watermarkCreator createWatermarkWithCreatorModels:@[model]];
}

@end
