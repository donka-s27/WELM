//
//  ProfileViewController.m
//  Welm
//
//  Created by Luke Stanley on 11/25/15.
//  Copyright © 2015 Luke Stanley. All rights reserved.
//

#import "ProfileViewController.h"
#import "FilmedMovieCell.h"
#import "CommonUtils.h"

#import <Parse.h>

@interface ProfileViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
{
    CGSize              _cellSize;
    
    NSMutableArray*     _filmedMovies;
    
    NSString*           _strUserName;
    
    CommonUtils*        utils;
}

@property (weak, nonatomic) IBOutlet UIView *imgContainer;
@property (weak, nonatomic) IBOutlet UILabel *lblProfilePic;
@property (weak, nonatomic) IBOutlet UIImageView *imgProfile;

@property (weak, nonatomic) IBOutlet UILabel *lblDescription;
@property (weak, nonatomic) IBOutlet UICollectionView *movieCollectionView;
@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    self.lblProfilePic.text = @"UPLOAD\nPROFILE PIC";
    
    _strUserName = [PFUser currentUser].username;
    
    self.lblDescription.text = [NSString stringWithFormat:@"@%@  |  %d 👁", [_strUserName uppercaseString], 0];

    self.imgContainer.clipsToBounds = YES;
    self.imgContainer.layer.cornerRadius = 8.0;

    utils = [CommonUtils sharedObject];
    
    _filmedMovies = [[NSMutableArray alloc] init];
    
    [self initCollectionView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)AddProfileImage:(id)sender {
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self loadSharedMovies];
}

#pragma mark - Setup methods

- (void)loadSharedMovies {
    
    [_filmedMovies removeAllObjects];
    
    PFQuery* query = [[PFQuery queryWithClassName:kSelexInfoName] whereKey:kUsernameKey equalTo:_strUserName];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        
        if(!error)
        {
            int viewCount = 0;
            
            for (PFObject* object in objects) {
                
                NSMutableDictionary* dic = [[NSMutableDictionary alloc] init];
                
                dic[kUsernameKey]   = object[kUsernameKey];
                dic[kHashTagKey]    = object[kHashTagKey];
                dic[kTitleKey]      = object[kTitleKey];
                dic[kVideoIDKey]    = object[kVideoIDKey];
                dic[kSharingTypeKey] = object[kSharingTypeKey];
                dic[kDurationKey]   = object[kDurationKey];
                dic[kVRLocationKey] = object[kVRLocationKey];
                dic[kViewCountKey]  = object[kViewCountKey];
                
                viewCount += [dic[kViewCountKey] integerValue];
                
                [_filmedMovies addObject:dic];
                
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.movieCollectionView reloadData];
                self.lblDescription.text = [NSString stringWithFormat:@"@%@  |  %d 👁", [_strUserName uppercaseString], viewCount];
            });
        }
    }];
}

- (void)initCollectionView {
    
    self.movieCollectionView.backgroundColor = [UIColor clearColor];
    self.movieCollectionView.backgroundView  = [[UIView alloc] initWithFrame:CGRectZero];
    
    
    self.movieCollectionView.delegate   = self;
    self.movieCollectionView.dataSource = self;
    
    CGSize size = [UIScreen mainScreen].bounds.size;
    CGFloat widht = MIN(size.width, size.height) - 60;
    
    _cellSize = CGSizeMake(widht, widht*0.6);
    
    [self.movieCollectionView registerNib:[UINib nibWithNibName:@"FilmedMovieCell" bundle:nil] forCellWithReuseIdentifier:FILMED_MOVIE_CELL_REUSE_ID];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return _filmedMovies.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    FilmedMovieCell *cell = [_movieCollectionView dequeueReusableCellWithReuseIdentifier:FILMED_MOVIE_CELL_REUSE_ID forIndexPath:indexPath];
    
    NSDictionary* info = [_filmedMovies objectAtIndex:indexPath.row];
    
    int duration = [info[kDurationKey] integerValue];
    
    cell.videoTitle     = info[kTitleKey];
    cell.videoDuration  = [NSString stringWithFormat:@"%d:%02d", duration/60, duration%60];
    cell.videoType      = info[kSharingTypeKey];
    cell.vrLocation     = info[kVRLocationKey];
    cell.videoID        = info[kVideoIDKey];
    
    [cell layoutIfNeeded];
    
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return _cellSize;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

@end
