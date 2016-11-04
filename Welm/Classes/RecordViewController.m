//
//  RecordViewController.m
//  Welm
//
//  Created by Donka Stoyanov on 11/25/15.
//  Copyright © 2015 Donka Stoyanov. All rights reserved.
//

#import "RecordViewController.h"
#import "CommonUtils.h"
#import "AppDelegate.h"
#import "WelmTabBarController.h"

#import <SCRecorder/SCRecorder.h>

#define kDefaultDuration    60

@interface RecordViewController () <UIGestureRecognizerDelegate, SCRecorderDelegate>
{
    BOOL                        _isFlashMode;
    
    NSTimer*                    _recordTimer;
    
    SCRecorder*                 _recorder;
    UIInterfaceOrientationMask  _orientationMask;
}

@property (weak, nonatomic) IBOutlet UIView *previewView;
@property (weak, nonatomic) IBOutlet SCRecorderToolsView *overlayView;

@property (weak, nonatomic) IBOutlet UIButton *btFlash;
@property (weak, nonatomic) IBOutlet UIButton *btCamera;

@property (weak, nonatomic) IBOutlet UILabel *lblTime;

@end

@implementation RecordViewController

- (void)viewDidLoad {

    [super viewDidLoad];
    
    _isFlashMode    = NO;

    [self setupRecorder];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [_recorder previewViewFrameChanged];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    topViewController = nil;
    
    if(_recorder)
        [self prepareSession];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if(_recorder)
    {
        [_recorder startRunning];
        [_recorder record];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if(_recorder)
        [_recorder stopRunning];
}

- (void)dealloc {
    
    _recorder = nil;
    _recorder.previewView = nil;
}

#pragma mark - init & control SRCRecord

- (void)setupRecorder
{
    NSNumber *value = [[UIDevice currentDevice] valueForKey:@"orientation"];

    AVCaptureVideoOrientation recordOrientation = AVCaptureVideoOrientationLandscapeLeft;
    
    switch (value.integerValue) {
        case UIInterfaceOrientationLandscapeLeft:
            _orientationMask = UIInterfaceOrientationMaskLandscapeLeft;
            break;
        case UIInterfaceOrientationLandscapeRight:
            _orientationMask = UIInterfaceOrientationMaskLandscapeRight;
            recordOrientation = AVCaptureVideoOrientationLandscapeRight;
            break;
            
        default:
            _orientationMask = UIInterfaceOrientationMaskLandscapeLeft;
            break;
    }
    
    _recorder = [SCRecorder recorder];
    _recorder.captureSessionPreset = [SCRecorderTools bestCaptureSessionPresetCompatibleWithAllDevices];
//    _recorder.maxRecordDuration = CMTimeMake(kDefaultDuration, 1);
//    _recorder.fastRecordMethodEnabled = YES;
    
    _recorder.flashMode = SCFlashModeOff;
    _recorder.device = AVCaptureDevicePositionBack;
    
    _recorder.delegate = self;
    _recorder.autoSetVideoOrientation = NO;
    _recorder.videoOrientation = recordOrientation;
    
    UIView *previewView = self.previewView;
    _recorder.previewView = previewView;
    
    NSLog(@"==== %@", NSStringFromCGRect(previewView.bounds));
    self.overlayView.recorder = _recorder;
    
    self.overlayView.outsideFocusTargetImage = [UIImage imageNamed:@"focus"];
    self.overlayView.insideFocusTargetImage = nil;
    
    _recorder.initializeSessionLazily = NO;
    
    NSError *error;
    if (![_recorder prepare:&error]) {
        NSLog(@"Prepare error: %@", error.localizedDescription);
    }
}

- (void)prepareSession {
    if (_recorder.session == nil) {
        
        SCRecordSession *session = [SCRecordSession recordSession];
        session.fileType = AVFileTypeQuickTimeMovie;
        
        _recorder.session = session;
    }
    
    [self updateTimeRecordedLabel];
}

#pragma mark - buttion action...

- (IBAction)OnChangeFlashMode:(id)sender {
    
    _recorder.flashMode = !(_recorder.flashMode);
}

- (IBAction)OnChangeCamera:(id)sender {
    
    [_recorder switchCaptureDevices];
}

#pragma mark - orientation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"recordToEdit"])
    {
        WelmTabBarController   *tabVC = segue.destinationViewController;
        tabVC.initialSeletedIndex = 3;
    }
}

#pragma mark - internal

- (void)saveAndShow
{
    _previewView.hidden = YES;
    self.overlayView.hidden = YES;
    
    [_recorder pause:^{

        CommonUtils* utils = [CommonUtils sharedObject];
        
        utils.recordSession = _recorder.session;

        dispatch_async(dispatch_get_main_queue(), ^{
        
            [utils saveSelex];

            [self editSelex];
        });
    }];
}

- (void)editSelex
{
    _recorder.previewView = nil;
    _recorder = nil;
    
    CGSize size = [UIScreen mainScreen].bounds.size;
    
    if (size.width > size.height)
    {
        _orientationMask = UIInterfaceOrientationMaskPortrait;
        
        NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
        [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    }

    [self performSegueWithIdentifier:@"recordToEdit" sender:nil];
}

- (void)updateTimeRecordedLabel {
    CMTime currentTime = kCMTimeZero;
    
    if (_recorder.session != nil) {
        currentTime = _recorder.session.duration;
    }
    
    Float64 remainingTime = MAX(0, kDefaultDuration - CMTimeGetSeconds(currentTime));
    int seconds = (int)remainingTime;
    
    self.lblTime.text = [NSString stringWithFormat:@"%d:%02d", (int)seconds, (int)((remainingTime - seconds)*100)];
    
    if(remainingTime == 0)
    {
        [self saveAndShow];
    }
}

#pragma mark - SCRecordViewController Delegate

- (void)recorder:(SCRecorder *)recorder didAppendVideoSampleBufferInSession:(SCRecordSession *)recordSession {
    [self updateTimeRecordedLabel];
}

- (void)recorder:(SCRecorder *)recorder didSkipVideoSampleBufferInSession:(SCRecordSession *)recordSession {
    NSLog(@"Skipped video buffer");
}

- (void)recorder:(SCRecorder *)recorder didReconfigureAudioInput:(NSError *)audioInputError {
    NSLog(@"Reconfigured audio input: %@", audioInputError);
}

- (void)recorder:(SCRecorder *)recorder didReconfigureVideoInput:(NSError *)videoInputError {
    NSLog(@"Reconfigured video input: %@", videoInputError);
}

- (void)recorder:(SCRecorder *)recorder didCompleteSession:(SCRecordSession *)recordSession {
    NSLog(@"didCompleteSession:");

}

- (void)recorder:(SCRecorder *)recorder didInitializeAudioInSession:(SCRecordSession *)recordSession error:(NSError *)error {
    if (error == nil) {
        NSLog(@"Initialized audio in record session");
    } else {
        NSLog(@"Failed to initialize audio in record session: %@", error.localizedDescription);
    }
}

- (void)recorder:(SCRecorder *)recorder didInitializeVideoInSession:(SCRecordSession *)recordSession error:(NSError *)error {
    if (error == nil) {
        NSLog(@"Initialized video in record session");
    } else {
        NSLog(@"Failed to initialize video in record session: %@", error.localizedDescription);
    }
}

- (void)recorder:(SCRecorder *)recorder didBeginSegmentInSession:(SCRecordSession *)recordSession error:(NSError *)error {
    NSLog(@"Began record segment: %@", error);
}

- (void)recorder:(SCRecorder *)recorder didCompleteSegment:(SCRecordSessionSegment *)segment inSession:(SCRecordSession *)recordSession error:(NSError *)error {
    NSLog(@"Completed record segment at %@: %@ (frameRate: %f)", segment.url, error, segment.frameRate);
}

#pragma mark - orientation

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator
{
    if(size.width < size.height)
    {
        [self saveAndShow];
    }
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        
    }];

    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}


- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    NSLog(@"--- record ori : %d", _recorder.isRecording);
    if(_recorder.isRecording)
        return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown | _orientationMask;
    else
        return _orientationMask;
}

@end
