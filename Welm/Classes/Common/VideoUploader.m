//
//  VideoUploader.m
//  Welm
//
//  Created by Donka Stoyanov on 11/30/15.
//  Copyright © 2015 Donka Stoyanov. All rights reserved.
//

#import "VideoUploader.h"
#import "GTLDrive.h"

#import <SVProgressHUD.h>
#import <AFNetworking.h>
#import "CommonUtils.h"
#import <Parse.h>

#define WELM_DIR_NAME                       @"Welm_Selex_Films"

#define kGoogleInfoName                     @"GoogleInfo"

#define kClientIDKey                        @"client_id"
#define kClientSecretKey                    @"client_secret"

#define kRefreshTokenKey                    @"refresh_token"
#define kTokenTypeKey                       @"tokenType"
#define kEmailKey                           @"email"
#define kIsVerifiedKey                      @"isVerified"
#define kScopeKey                           @"scope"
#define kServiceProviderKey                 @"serviceProvider"
#define kUserIDKey                          @"userID"

#define WELM_GOOGLE_DRIVE_CLIENT_KEY        @"943298472381-jsio4f38gh82n9l7vfmfnj3dsulg6pak.apps.googleusercontent.com"
#define WELM_GOOGLE_DRIVE_CLIENT_SECRET     @"XHNDFVK0j5KqE9MYiqXx61VP"
#define WELM_GOOGLE_KEYCHAIN_ITEM_NAME      WELM_DIR_NAME

@interface VideoUploader ()
{
    NSString*       _devCode;
    NSString*       _userCode;
    NSString*       _accessToken;
    NSString*       _refreshToken;
    NSString*       _tokenType;
    NSArray*        _scopes;

    NSString*       _client_id;
    NSString*       _client_secret;
    
    GTMOAuth2Authentication* _auth;
}

@property (nonatomic, retain) GTLServiceDrive *driveService;
@property (nonatomic, retain) NSString *destinationDirectoryName;
@property (nonatomic, retain) GTLServiceTicket *uploadingTicket;
@property (nonatomic, retain) NSString *parentFolderID;

@end

@implementation VideoUploader

-(id)init {
    self = [super init];
    
    if (self) {
        self.driveService = [[GTLServiceDrive alloc] init];
        _auth = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:WELM_GOOGLE_KEYCHAIN_ITEM_NAME
                                                                                              clientID:WELM_GOOGLE_DRIVE_CLIENT_KEY
                                                                                          clientSecret:WELM_GOOGLE_DRIVE_CLIENT_SECRET];
        self.driveService.authorizer = _auth;
        
        NSLog(@"=-=-= %@", _auth);
        self.engineName = @"GoogleDrive";

//        [self getUserCode];
        PFQuery *query = [PFQuery queryWithClassName:kGoogleInfoName];
        [query findObjectsInBackgroundWithBlock:^(NSArray*  objects, NSError*  error) {
            if (!error)
            {
                PFObject* info = objects.firstObject;
                
                _client_id      = info[kClientIDKey];
                _client_secret  = info[kClientSecretKey];
                _refreshToken   = info[kRefreshTokenKey];
                _tokenType      = info[kTokenTypeKey];
                
                NSDictionary* parameters = @{kEmailKey: info[kEmailKey],
                                             kIsVerifiedKey: info[kIsVerifiedKey],
                                             kRefreshTokenKey: info[kRefreshTokenKey],
                                             kScopeKey: info[kScopeKey],
                                             kServiceProviderKey: info[kServiceProviderKey],
                                             kUserIDKey: info[kUserIDKey]};
                
                _auth.parameters = [[NSMutableDictionary alloc] initWithDictionary:parameters];
                _auth.refreshToken = info[kRefreshTokenKey];
                
                self.driveService.authorizer = _auth;

                [self createFolderForUploading];

            } else{
                    // Log details of the failure
                    NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
            
        }];
    }
    return self;
}

-(void)setAuthorizer:(id <GTMFetcherAuthorizationProtocol>)authorizer {
    self.driveService.authorizer = authorizer;
}

-(void)dealloc {
//    [self.driveService release];
//    [super dealloc];
}


#pragma mark -
#pragma mark Authorization
#pragma mark -

// Helper to check if user is authorized
- (BOOL)isAuthorized {
    if (!self.driveService.authorizer)
        return NO;
    else
        return [((GTMOAuth2Authentication *)self.driveService.authorizer) canAuthorize];
}

- (void)getAccessToken:(void (^)(NSString* accessToken))handler
{
    [self refreshTokenWithCompletionHander:^(NSString *accessToken) {
        
        _accessToken = accessToken;
        _auth.accessToken = accessToken;
        handler(accessToken);
    }];
}

- (void)getVideoURL:(NSString*)videoID completionHandler:(void (^)(NSString* accessToken))handler
{
    
}

#pragma mark -

- (void)folderExist:(NSString*)folderName completion:(void (^)(GTLDriveFile* existFolder)) handler
{
    GTLDriveFile *folder = [GTLDriveFile object];
    GTLQueryDrive *query;
    
    folder.title = folderName;
    folder.mimeType = @"application/vnd.google-apps.folder";
    
    self.destinationDirectoryName = folder.title;
    
    query = [GTLQueryDrive queryForFilesList];
    query.q =@"trashed=false";
    
    [self.driveService executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLDriveFileList* files, NSError *error) {
        
        if(error == nil)
        {
            NSArray* items = files.items;
            
            for (GTLDriveFile* item in items) {
                
                if([item.title isEqualToString:folderName])
                {
                    handler(item);
                    return;
                }
            }
        }

        handler(nil);
    }];
}

- (void)createFolderForUploading {
    
    GTLDriveFile *folder = [GTLDriveFile object];
    
    folder.title = WELM_DIR_NAME;
    folder.mimeType = @"application/vnd.google-apps.folder";
    
    self.destinationDirectoryName = folder.title;
    
    [self folderExist:folder.title completion:^(GTLDriveFile* existFolder) {
        
        if(existFolder)
        {
            self.parentFolderID = existFolder.identifier;
            self.sharableLinkOnFolder = existFolder.alternateLink;
        }
        else
        {
            GTLQueryDrive *query = [GTLQueryDrive queryForFilesInsertWithObject:folder uploadParameters:nil];
            [self.driveService executeQuery:query completionHandler:^(GTLServiceTicket *ticket,
                                                                      GTLDriveFile *updatedFile,
                                                                      NSError *error) {
                if (error == nil) {
                    NSLog(@"Created folder");
                    
                    self.parentFolderID = updatedFile.identifier;
                    
                    GTLDrivePermission *drivePermission = [GTLDrivePermission object];
                    drivePermission.role = @"reader";
                    drivePermission.withLink = [NSNumber numberWithBool:YES];
                    drivePermission.type = @"anyone";
                    drivePermission.value = @"";
                    
                    GTLQueryDrive *permQuery = [GTLQueryDrive queryForPermissionsInsertWithObject:drivePermission fileId:self.parentFolderID];
                    [self.driveService executeQuery:permQuery completionHandler:^(GTLServiceTicket *ticket,
                                                                                  GTLDrivePermission *drivePermission,
                                                                                  NSError *error) {
                        if (error == nil) {
                            self.sharableLinkOnFolder = updatedFile.alternateLink;
                            NSLog(@"sharable link %@", updatedFile.alternateLink);
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"FolderCreatedByUploadingEngine" object:nil];
                        }
                        else {
                            NSLog(@"Sharing folder failed. An error occurred: %@", error);
                        }
                    }];
                }
                else {
                    NSLog(@"Folder creating failed. An error occurred: %@", error);
                }
            }];
        }
    }];
}

- (void)uploadVideo:(NSURL *)videoURL completionHandler:(void (^)(NSString* videoID, NSError*error))handler
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"'Quickstart Uploaded File ('EEEE MMMM d, YYYY h:mm a, zzz')"];
    
    GTLDriveParentReference *parent = [GTLDriveParentReference object];
    parent.identifier = self.parentFolderID;

    GTLDriveFile *file = [GTLDriveFile object];
    file.title = [dateFormat stringFromDate:[NSDate date]];
    file.descriptionProperty = @"Uploaded from the Google Drive iOS Quickstart";
    file.mimeType = @"video/quicktime";
    file.parents = @[parent];

    NSError *error_ = nil;
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingFromURL:videoURL error:&error_];

    GTLUploadParameters *uploadParameters = [GTLUploadParameters uploadParametersWithFileHandle:fileHandle MIMEType:file.mimeType];
    GTLQueryDrive *query = [GTLQueryDrive queryForFilesInsertWithObject:file
                                                       uploadParameters:uploadParameters];
    
    self.uploadingTicket = [self.driveService executeQuery:query
                  completionHandler:^(GTLServiceTicket *ticket,
                                      GTLDriveFile* insertedFile, NSError* err) {

        if (err == nil)
        {
            NSLog(@"File ID: %@", insertedFile.identifier);
            [SVProgressHUD showSuccessWithStatus:@"Video uploading complete!"];
            
            handler(insertedFile.downloadUrl, nil);
        }
        else
        {
            NSLog(@"An error occurred: %@", err);
            [SVProgressHUD showErrorWithStatus:@"Video uploading fail!"];

            handler(nil, err);
        }
    }];
    
    __weak typeof(self) wSelf = self;
    self.uploadingTicket.uploadProgressBlock = ^(GTLServiceTicket *ticket,
                                                 unsigned long long numberOfBytesRead,
                                                 unsigned long long dataLength) {
        
        __strong typeof(self) strongSelf = wSelf;
        strongSelf.uploadingProgress = (1.0 / dataLength * numberOfBytesRead);
        
        dispatch_async(dispatch_get_main_queue(), ^{

            [SVProgressHUD showProgress:strongSelf.uploadingProgress status:@"Uploading..."];
        });
    };
}

- (void)cancelUploading {
    if (self.uploadingTicket) {
        [self.uploadingTicket cancelTicket];
    }
}

#pragma mark - utils...

- (NSData*)encodeDictionary:(NSDictionary*)dictionary {
    
    NSMutableArray *parts = [[NSMutableArray alloc] init];
    NSString *encodedValue;
    
    for (NSString *key in dictionary) {
        
        id value = [dictionary objectForKey:key];
        
        encodedValue = [(NSString*)value stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        NSString *encodedKey = [key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *part = [NSString stringWithFormat: @"%@=%@", encodedKey, encodedValue];
        [parts addObject:part];
    }
    NSString *encodedDictionary = [parts componentsJoinedByString:@"&"];
    return [encodedDictionary dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSDictionary*)decodeData_withdraw:(NSData*)data {
    
    NSString *str = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    NSString *normal = [str stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSArray* values = [normal componentsSeparatedByString:@"&"];
    NSMutableDictionary* dic = [[NSMutableDictionary alloc] init];
    
    for (NSString* value in values) {
        
        NSArray* tmpArry = [value componentsSeparatedByString:@"="];
        
        if(tmpArry.count ==2)
        {
            [dic setObject:tmpArry[1] forKey:tmpArry[0]];
        }
    }
    
    if(dic.count == 0)
        dic = nil;
    
    return dic;
}

#pragma mark - Payment management

- (void)getUserCode
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD show];
    });

    NSURL                   *url = [NSURL URLWithString:@"https://accounts.google.com/o/oauth2/device/code"];
    NSMutableURLRequest     *request = [[NSMutableURLRequest alloc] init];

    NSDictionary *parameters = @{@"client_id": WELM_GOOGLE_DRIVE_CLIENT_KEY,
                                 @"scope" : @"email profile"};

    NSData* postData = [self encodeDictionary:parameters];

    [request setURL:[url standardizedURL]];
    [request setHTTPMethod:@"POST"];
    [request setValue:[NSString stringWithFormat:@"%d", (int)postData.length] forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"en_US" forHTTPHeaderField:@"Accept-Language"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPBody:postData];

    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable error) {

         dispatch_async(dispatch_get_main_queue(), ^{
             [SVProgressHUD dismiss];
         });

         if(error)
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 [CommonUtils showModalAlertWithTitle:@"Get Call History" description:error.localizedDescription];
                 NSLog(@" Error = : %@", error);
             });
             
             if (data) {
                 NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                 NSLog(@"==== dic : %@", dic);
                 
             }
         }
         else
         {
             NSError* error;
             NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
             
             if(dic)
             {
                 _userCode  = dic[@"user_code"];
                 _devCode   = dic[@"device_code"];
                 
                 [self accessToken];
             }
         }
     }];
}

- (void)accessToken
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD show];
    });
    
    NSURL                   *url = [NSURL URLWithString:@"https://www.googleapis.com/oauth2/v4/token"];
    NSMutableURLRequest     *request = [[NSMutableURLRequest alloc] init];

#if 0
    NSDictionary *parameters = @{@"client_id": WELM_GOOGLE_DRIVE_CLIENT_KEY,
                                 @"client_secret": WELM_GOOGLE_DRIVE_CLIENT_SECRET,
                                 @"code": _devCode,
                                 @"redirect_uri": @"https://oauth2-login-demo.appspot.com/code",
                                 @"grant_type": @"authorization_code"};
#else
    NSDictionary *parameters = @{@"client_id": WELM_GOOGLE_DRIVE_CLIENT_KEY,
                                 @"client_secret": WELM_GOOGLE_DRIVE_CLIENT_SECRET,
                                 @"code": _devCode,
                                 @"grant_type": @"http://oauth.net/grant_type/device/1.0"};
#endif
    
    NSData* postData = [self encodeDictionary:parameters];
    
    [request setURL:[url standardizedURL]];
    [request setHTTPMethod:@"POST"];
    [request setValue:[NSString stringWithFormat:@"%d", (int)postData.length] forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"en_US" forHTTPHeaderField:@"Accept-Language"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPBody:postData];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
        
        if(error)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [CommonUtils showModalAlertWithTitle:@"Get Call History" description:error.localizedDescription];
                NSLog(@" Error = : %@", error);
            });
            
            if (data) {
                NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                NSLog(@"==== dic : %@", dic);
                
            }
        }
        else
        {
            NSError* error;
            NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            
            if(dic)
            {
                _accessToken    = dic[@"access_token"];
                _refreshToken   = dic[@"refresh_token"];
                _tokenType      = dic[@"token_type"];
            }
        }
    }];
}

- (void)refreshTokenWithCompletionHander:(void (^)(NSString* accessToken)) handler
{
    NSURL                   *url = [NSURL URLWithString:@"https://www.googleapis.com/oauth2/v4/token"];
    NSMutableURLRequest     *request = [[NSMutableURLRequest alloc] init];
    
    NSDictionary *parameters = @{@"client_id": WELM_GOOGLE_DRIVE_CLIENT_KEY,
                                 @"client_secret": WELM_GOOGLE_DRIVE_CLIENT_SECRET,
                                 @"refresh_token": _refreshToken,
                                 @"grant_type": @"refresh_token"};
    
    NSData* postData = [self encodeDictionary:parameters];
    
    [request setURL:[url standardizedURL]];
    [request setHTTPMethod:@"POST"];
    [request setValue:[NSString stringWithFormat:@"%d", (int)postData.length] forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"en_US" forHTTPHeaderField:@"Accept-Language"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPBody:postData];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable error) {
        
        
        if(error)
            handler(nil);
        else
        {
            NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            if(dic)
                handler(dic[@"access_token"]);
            else
                handler(nil);
        }
    }];
}

@end
