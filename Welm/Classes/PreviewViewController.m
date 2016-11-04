//
//  PreviewViewController.m
//  Welm
//
//  Created by Donka Stoyanov on 11/27/15.
//  Copyright © 2015 Donka Stoyanov. All rights reserved.
//

#import "PreviewViewController.h"
#import "CommonUtils.h"
#import "AVMixer.h"

#import "KeyboardHelper.h"

#import <SVProgressHUD.h>
#import <AVFoundation/AVFoundation.h>

@interface PreviewViewController () <AVMixerDelegate>
{
    BOOL                    _autoRotate;
    BOOL                    _isPreviewOnly;
    BOOL                    _isInited;
    BOOL                    _isPlaying;
    BOOL                    _isEnding;

    CMTime                  _totalDuration;
    
    AVMixer*                _mixer;
    
    AVPlayer*               _player;
    AVPlayerItem*           _playerItem;
    AVPlayerLayer*          _playerLayer;
    
    UIInterfaceOrientationMask  _orientationMask;
}

@property (nonatomic, strong) KeyboardHelper* kbHelper;


@property (nonatomic) NSTimer* durationTimer;
@property (weak, nonatomic) IBOutlet UIView *movieContainer;
@property (weak, nonatomic) IBOutlet UIView *movieControllerView;

@property (weak, nonatomic) IBOutlet UIButton *btPlay;
@property (weak, nonatomic) IBOutlet UILabel *duration;
@property (weak, nonatomic) IBOutlet UISlider *durationSlider;

@property (weak, nonatomic) IBOutlet UIButton *btClose;


@property (weak, nonatomic) IBOutlet UIView *setupView;

@property (weak, nonatomic) IBOutlet UITextField *txtVideoHashTag;
@property (weak, nonatomic) IBOutlet UITextField *txtVideoTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblSharingType;

@property (weak, nonatomic) IBOutlet UISwitch *switchSaveResult;
@property (weak, nonatomic) IBOutlet UISwitch *switchPostProfile;
@property (weak, nonatomic) IBOutlet UISwitch *switchVideoType;

@end

@implementation PreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _autoRotate     = NO;
    _isPreviewOnly  = NO;
    _isInited       = NO;
    _isPlaying      = NO;
    _isEnding       = NO;
    
    _player         = nil;
    _playerItem     = nil;
    _playerLayer    = nil;

    _orientationMask = UIInterfaceOrientationMaskLandscape;
 
    self.kbHelper = [[KeyboardHelper alloc] initWithViewController:self onDoneSelector:@selector(onDone)];

    [self initControls];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initControls
{
    self.movieControllerView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.2];
    self.durationSlider.minimumValue = 0;
    self.durationSlider.maximumValue = 0;
    self.durationSlider.value = 0;
    
    _mixer = [[AVMixer alloc] initWithDelegate:self];

    self.btClose.hidden = YES;
    self.movieControllerView.hidden = YES;
    
    // setupView
    
    self.setupView.clipsToBounds = YES;
    self.setupView.layer.cornerRadius = 8.0;
    self.setupView.hidden = YES;

    self.lblSharingType.text = @"Sharing Type (public)";
    self.switchVideoType.on = YES;
}

- (void) onDone{
    [self.view endEditing:YES];
}

- (void) viewWillDisappear:(BOOL)animated{
    [self.kbHelper disable];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    topViewController = self;
    
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeLeft];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
}

- (void)viewDidLayoutSubviews
{
    NSLog(@" == %@", NSStringFromCGRect(self.view.bounds));
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.kbHelper enable];

    if(_isInited)
        return;
    
    _isInited = YES;
    
    if(self.movieURL)
    {
        [self initPlayerWithPath:self.movieURL];
        
        _isPreviewOnly = YES;
        self.btClose.hidden = NO;
        self.movieControllerView.hidden = NO;
    }
    else if(self.previewInfo.count)
    {
        _isPreviewOnly = NO;
        [_mixer exportMovies:self.previewInfo];
    }
}

#pragma mark - Action

- (IBAction)onPlay:(id)sender
{
    if (_player) {
        
        _isPlaying = !_isPlaying;
        
        if(_isPlaying)
            [self play];
        else
            [self pause];
    }
}

- (IBAction)OnClose:(id)sender {
    
    [self stop];

    _orientationMask = UIInterfaceOrientationMaskPortrait;
    _autoRotate     = YES;
    
    CGSize size = [UIScreen mainScreen].bounds.size;
    
    if (size.width > size.height) {
        
        NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
        [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    }

    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onDurationChanged:(UISlider *)sender
{
    if (_player) {
        
        CMTime duration = _totalDuration;
        
        duration.value = sender.value* duration.timescale;
        [_player seekToTime:duration];
        
        int64_t seconds = CMTimeGetSeconds(duration);
        int64_t mins    = seconds / 60, hours;
        
        seconds   = seconds % 60;
        hours     = mins / 60;
        mins      = mins % 60;
        
        self.duration.text = [NSString stringWithFormat:@"%d:%02d:%02d", (int)hours, (int)mins, (int)seconds];
    }
    else{
        
        sender.value = 0;
    }
}

#pragma mark - SetupView Action

- (void)resetSetupView
{
    self.txtVideoTitle.text = @"";
    self.txtVideoHashTag.text = @"";
    self.switchSaveResult.on = YES;
    self.switchPostProfile.on = YES;
    self.switchVideoType.on = YES;
    self.lblSharingType.text = @"Sharing Type (public)";
}

- (void)showSetupView
{
    self.setupView.alpha = 0.0;
    self.setupView.hidden = NO;

    [self resetSetupView];
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.setupView.alpha = 1.0;
                     }
                     completion:^(BOOL finished){
                     }];
    
    [UIView commitAnimations];
}

- (void)hideSetupView:(void (^)(void))completionHandler
{
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.setupView.alpha = 0.0;
                     }
                     completion:^(BOOL finished){
                         self.setupView.hidden = YES;
                         
                         completionHandler();
                     }];
    
    [UIView commitAnimations];
}

- (IBAction)ChangePost:(id)sender {
    
    if (self.switchPostProfile.on) {
        
        self.lblSharingType.hidden = NO;
        self.switchVideoType.hidden = NO;

        self.lblSharingType.text = @"Sharing Type (public)";
        self.switchVideoType.on = YES;
    }
    else
    {
        self.lblSharingType.hidden = YES;
        self.switchVideoType.hidden = YES;
    }
}

- (IBAction)ChangeType:(id)sender {

    if (self.switchVideoType.on)
        self.lblSharingType.text = @"Sharing Type (public)";
    else
        self.lblSharingType.text = @"Sharing Type (lock)";
}

- (IBAction)OnCancel:(id)sender {

    [self hideSetupView:^{
        
        [self OnClose:nil];
    }];
}

- (IBAction)OnOk:(id)sender {

    if (self.switchPostProfile.on)
    {
        if ( !self.txtVideoTitle.text.length )
        {
            [CommonUtils showModalAlertWithTitle:@"Sharing" description:@"Fill the movie title"];
            return;
        }
        
        if ( !self.txtVideoHashTag.text.length )
        {
            [CommonUtils showModalAlertWithTitle:@"Sharing" description:@"Fill the hashtag"];
            return;
        }
    }
    
    [self hideSetupView:^{
        
        if (self.switchPostProfile.on) {
            
            CMTime duration = _totalDuration;
            int64_t seconds = CMTimeGetSeconds(duration);
            NSString* strType = self.switchVideoType.on ? @"public" : @"lock";
            
            NSString* strHashTag = self.txtVideoHashTag.text;
            
            if(![strHashTag hasPrefix:@"#"])
                strHashTag = [NSString stringWithFormat:@"#%@", strHashTag];
            
            [[CommonUtils sharedObject] postVideo:self.movieURL hashTag:strHashTag title:self.txtVideoTitle.text sharingType:strType location:@"" duration:seconds completionHandler:^(BOOL success, NSString *errString) {
         
                if (!success) {
                    
                    [SVProgressHUD showErrorWithStatus:errString];
                }
                
                if(self.switchSaveResult.on)
                {
                    [[CommonUtils sharedObject] saveResult:self.movieURL.path completionHandler:^(BOOL success, NSString *errString) {
                        
                        dispatch_async(dispatch_get_main_queue(), ^{

                            if (!success)   [SVProgressHUD showErrorWithStatus:errString];
                            [self OnClose:nil];
                        });
                    }];
                }
                else
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self OnClose:nil];
                    });
            }];
        }
        else if(self.switchSaveResult.on)
            [[CommonUtils sharedObject] saveResult:self.movieURL.path completionHandler:^(BOOL success, NSString *errString) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if (!success)   [SVProgressHUD showErrorWithStatus:errString];
                    [self OnClose:nil];
                });
            }];
    }];
}

#pragma mark - property

- (void)initPlayerWithPath:(NSURL*)movieURL;
{
    self.movieURL   = movieURL;
    
    _playerItem     = [AVPlayerItem playerItemWithURL:movieURL];
    _player         = [AVPlayer playerWithPlayerItem:_playerItem];
    _playerLayer    = [AVPlayerLayer playerLayerWithPlayer:_player];
    
    [self.movieContainer.layer addSublayer:_playerLayer];
    _totalDuration  = _playerItem.asset.duration;
    int64_t seconds = CMTimeGetSeconds(_totalDuration);
    
    self.durationSlider.minimumValue = 0;
    self.durationSlider.maximumValue = seconds;
    
    _playerLayer.frame = self.movieContainer.bounds;

    // other
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieDone) name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem];

    [self onPlay:nil];
}

- (void)movieDone
{
    [self pause];
    
    _isPlaying  = NO;
    _isEnding   = YES;
    
    if(!_isPreviewOnly)
    {
        [self showSetupView];
    }
}

#pragma mark - internal...

- (void)play
{
    if (_player) {
        if(_isEnding)
        {
            [_player seekToTime:kCMTimeZero];
            _isEnding = NO;
        }
        
        [self performSelector:@selector(updateDuration) withObject:nil afterDelay:0.1];
        [self.btPlay setBackgroundImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
        [_player play];
    }
}

- (void)pause
{
    if (_player) {
        
        [self.durationTimer invalidate];
        self.durationTimer = nil;
        
        [self.btPlay setBackgroundImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        [_player pause];
    }
}

- (void)stop
{
    if(self.durationTimer)
    {
        [self.durationTimer invalidate];
        self.durationTimer = nil;
    }
    
    _isPlaying      = NO;
    _isEnding       = NO;
    
    [self pause];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem];
    
    if(_playerLayer)
    {
        [_playerLayer removeFromSuperlayer];
        _playerLayer = nil;
    }
    
    self.duration.text = @"00:00";
    self.durationSlider.value = 0;
    
    _player     = nil;
    _playerItem = nil;
}

- (void)updateDuration
{
    CMTime currentTime = _playerItem.currentTime;
    int64_t seconds = MAX(0,CMTimeGetSeconds(currentTime));
    int64_t mins    = seconds / 60;
    
    
    self.durationSlider.value = seconds;
    
    seconds   = seconds % 60;
    mins      = mins % 60;
    
    self.duration.text = [NSString stringWithFormat:@"%02d:%02d", (int)mins, (int)seconds];
    
    if(_isPlaying)
        [self performSelector:@selector(updateDuration) withObject:nil afterDelay:0.1];
}

#pragma mark - orientation

- (BOOL)shouldAutorotate
{
    return _autoRotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return _orientationMask;
}

#pragma mark - AVMixerDelegate

- (void) didCompleteAVMix:(AVMixer *) mixer output:(NSURL*)outPath
{
    [self initPlayerWithPath:outPath];
}

- (void) didCanceledAVMix:(AVMixer *) mixer errorString:(NSString*)error
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Cancel exporting for preview..." message:error delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

- (void) didFailAVMix:(AVMixer *) mixer errorString:(NSString*)error
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Fail exporting for preview..." message:error delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

@end
