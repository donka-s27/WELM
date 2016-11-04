//
//  HomeViewController.m
//  Welm
//
//  Created by Donka Stoyanov on 11/25/15.
//  Copyright © 2015 Donka Stoyanov. All rights reserved.
//

#import "HomeViewController.h"
#import "SharedMovieCell.h"
#import "CommonUtils.h"
#import "SelexMovieModel.h"

#import <Parse.h>
#import <Photos/Photos.h>

@interface HomeViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
{
    BOOL                _bInited;

    CGSize              _cellSize;
    
    NSMutableArray*     _sharedMovies;
    NSString*           _strUserName;

    CommonUtils*        utils;
}

@property (weak, nonatomic) IBOutlet UILabel *lblWelm;
@property (weak, nonatomic) IBOutlet UIView *welmContainer;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    utils = [CommonUtils sharedObject];
    
    _strUserName = [PFUser currentUser].username;
    _sharedMovies = [[NSMutableArray alloc] init];

    [self initCollectionView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews
{
    [self.collectionView reloadData];
    
    if(_bInited)    return;
    
    _bInited = YES;
    
    CGFloat diff = 0;
    
    CGSize size = [[UIScreen mainScreen] bounds].size;
    
    if (size.height == 480)
        diff = 48;
    else if(size.height == 568)
        diff = 24;
    else
        diff = 12;
    
    CGFloat height = (int)(CGRectGetHeight(self.collectionView.bounds) - diff);
    
    _cellSize = CGSizeMake((int)(height*1.2), height);
    
    self.welmContainer.clipsToBounds = YES;
    self.welmContainer.layer.cornerRadius = 8.0;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self loadSharedMovies];
}

#pragma mark - Setup methods

- (void)loadSharedMovies {

    [_sharedMovies removeAllObjects];
    
    PFQuery* query = [[PFQuery queryWithClassName:kSelexInfoName] whereKey:kSharingTypeKey equalTo:@"public"];

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
                
                [_sharedMovies addObject:dic];
                
            }
            dispatch_async(dispatch_get_main_queue(), ^{
               [self.collectionView reloadData];
            });
        }
    }];
}

- (void)initCollectionView {

    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.backgroundView  = [[UIView alloc] initWithFrame:CGRectZero];
    
    _collectionView.delegate   = self;
    _collectionView.dataSource = self;
    
    [_collectionView registerNib:[UINib nibWithNibName:@"SharedMovieCell" bundle:nil] forCellWithReuseIdentifier:SHARED_MOVIE_CELL_REUSE_ID];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return _sharedMovies.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    SharedMovieCell *cell = [_collectionView dequeueReusableCellWithReuseIdentifier:SHARED_MOVIE_CELL_REUSE_ID forIndexPath:indexPath];

    NSDictionary* info = [_sharedMovies objectAtIndex:indexPath.row];

    cell.videoTitle = info[kTitleKey];
    cell.videoID    = info[kVideoIDKey];

    [cell layoutIfNeeded];
    
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return _cellSize;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(4, 4, 4, 4);
}

@end
