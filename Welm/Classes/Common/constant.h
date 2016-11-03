//
//  constant.h
//  Welm
//
//  Created by Luke Stanley on 11/30/15.
//  Copyright © 2015 Luke Stanley. All rights reserved.
//

#ifndef constant_h
#define constant_h

#define SELEX_CELL_REUSE_ID             @"SELEX_CELL_ID"
#define SELEX_TRACK_CELL_REUSE_ID       @"SELEX_TRACK_CELL_ID"

#define SHARED_MOVIE_CELL_REUSE_ID      @"SHARED_MOVIE_CELL_ID"
#define FILMED_MOVIE_CELL_REUSE_ID      @"FILMED_MOVIE_CELL_ID"

#define kRemoveSelexNotification        @"RemoveSelex"
#define kVideoTrackSelectedNotification @"VideoTrackSelected"

#define kAlbumName                      @"SelexVideo"
#define kAlbumIdentifierKey             @"AlbumKey"

#define kResultAlbumName                @"ResultVideo"
#define kResultAlbumIdentifierKey       @"ResultAlbumKey"

#define kDefaultMargin                  24
#define kDefaultBorderWidth             4.0


//////////////////////////////////////////////////////////////////
// preview

#define kPreviewMoviePath               @"Preview.m4v"
#define kFilteredMovieNamePrefix        @"Filtered"
#define kMovieExtension                 @"m4v"

#define kMovieURLKey                    @"MovieURL"
#define kMovieWidthKey                  @"MovieWidth"
#define kMovieHeightKey                 @"MovieHeight"
#define kMovieFilterKey                 @"MovieFilter"
#define kTimesKey                       @"Times"
#define kVideoFilterKey                 @"VideoFilter"
#define kAudioFilterKey                 @"AudioFilter"

//////////////////////////////////////////////////////////////////
// parse server

#define kSelexInfoName      @"SelexInfo"

#define kUsernameKey        @"username"
#define kHashTagKey         @"hasgTag"
#define kTitleKey           @"title"
#define kVideoIDKey         @"videoID"
#define kSharingTypeKey     @"sharingType"
#define kDurationKey        @"duration"
#define kVRLocationKey      @"VRLocation"
#define kViewCountKey       @"viewCount"

//////////////////////////////////////////////////////////////////

#endif /* constant_h */
