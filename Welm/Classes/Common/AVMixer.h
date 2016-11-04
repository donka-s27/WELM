//
//  AVMixer.h
//  Welm
//
//  Created by Donka Stoyanov on 12/5/15.
//  Copyright © 2015 Donka Stoyanov. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AVMixer;
@class AVAsset;

@protocol AVMixerDelegate <NSObject>

@optional
- (void) didChangeMixProgress:(AVMixer *) mixer progress:(float)progress;

@required
- (void) didCompleteAVMix:(AVMixer *) mixer output:(NSURL*)outPath;
- (void) didCanceledAVMix:(AVMixer *) mixer errorString:(NSString*)error;
- (void) didFailAVMix:(AVMixer *) mixer errorString:(NSString*)error;
@end

@interface AVMixer : NSObject

@property (nonatomic, weak) id <AVMixerDelegate> delegate;

- (instancetype)initWithDelegate:(id <AVMixerDelegate>)delegate;
- (void)exportMovies:(NSArray*)selexArray;

@end