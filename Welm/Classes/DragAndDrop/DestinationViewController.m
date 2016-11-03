//
//  DestinationViewController.m
//  Welm
//
//  Created by Luke Stanley on 12/2/15.
//  Copyright © 2015 Luke Stanley. All rights reserved.
//

#import "DestinationViewController.h"
#import "SelexEditCell.h"
#import "constant.h"
#import "AppDelegate.h"
#import "VideoFilterView.h"

@interface DestinationViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
{
    UICollectionView        *_collectionView;
    NSMutableArray          *_editModels;

    UIView                  *_parentView;
    
    CGSize                  _cellSize;
    
    NSInteger               _rearrangeIndex;
    SelexMovieModel*        _rearrangeModel;
}

@end

@implementation DestinationViewController

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView viewController:(UIViewController*)viewController
{
    if (self = [super init]) {
        
        _cellSize = CGSizeZero;

        _collectionView = collectionView;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[SelexEditCell class] forCellWithReuseIdentifier:SELEX_TRACK_CELL_REUSE_ID];
        
        _editModels = [NSMutableArray array];

        _parentView = viewController.view;

        [self setUpGestures];
    }
    return self;
}

- (void)setUpGesture {
    
}

- (void)refresh:(NSArray*)items {
    
    NSMutableArray* reloadItems = [[NSMutableArray alloc] init];
    for (NSInteger i=0; i<_editModels.count; i++) {
        [reloadItems addObject:[NSIndexPath indexPathForItem:i inSection:0]];
    }
    [_collectionView reloadItemsAtIndexPaths:reloadItems];
//    [_collectionView reloadItemsAtIndexPaths:items];
}

- (void)addModel:(SelexMovieModel *)model index:(int)index
{
    SelexMovieModel* newModel = [SelexMovieModel modelWithAsset:model.asset];
    NSArray* updateIitems;
    
    if (index == INT_MAX) {
        
        [_editModels addObject:newModel];
        
        NSIndexPath* lastItem = [NSIndexPath indexPathForItem:_editModels.count-1 inSection:0];
        updateIitems = [NSArray arrayWithObject:lastItem];
        [_collectionView insertItemsAtIndexPaths:updateIitems];
        [_collectionView reloadItemsAtIndexPaths:updateIitems];
        [_collectionView scrollToItemAtIndexPath:lastItem atScrollPosition:UICollectionViewScrollPositionRight animated:YES];
    }
    else
    {
        [_editModels insertObject:newModel atIndex:index];
        
        NSIndexPath* item = [NSIndexPath indexPathForItem:index inSection:0];
        updateIitems = [NSArray arrayWithObject:item];
        [_collectionView insertItemsAtIndexPaths:updateIitems];
        [_collectionView reloadItemsAtIndexPaths:updateIitems];
        [_collectionView scrollToItemAtIndexPath:item atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    }
    
    [self performSelector:@selector(refresh:) withObject:nil afterDelay:0.5];
}

- (void)removeItem:(int)index
{
    if (index == INT_MAX || index < 0)
        return;
    
    [_editModels removeObjectAtIndex:index];
    
    NSIndexPath* item = [NSIndexPath indexPathForItem:index inSection:0];
    NSMutableArray* reloadItems = [[NSMutableArray alloc] init];
    
    [_collectionView deleteItemsAtIndexPaths:[NSArray arrayWithObject:item]];
    
    for (int i=index; i<_editModels.count; i++) {
        [reloadItems addObject:[NSIndexPath indexPathForItem:i inSection:0]];
    }
    [_collectionView reloadItemsAtIndexPaths:reloadItems];
}

- (void)removeItemWithMoviePath:(NSURL*)url
{
    NSMutableArray* newModels       = [[NSMutableArray alloc] init];
    
    for (SelexMovieModel* model in _editModels) {

        if ([url.absoluteString isEqualToString:model.movieURL.absoluteString])
            continue;
        
        [newModels addObject:model];
    }

    _editModels = newModels;
    
    [_collectionView reloadData];
}

- (void)clear
{
    [_editModels removeAllObjects];
}

- (void)setCellSize:(CGSize)size
{
    _cellSize = size;
}

- (NSUInteger)count
{
    return _editModels.count;
}

- (NSArray*)exportMovieInfo
{
    NSMutableArray* exportInfo = [[NSMutableArray alloc] init];
    CGSize      size = CGSizeZero;
    
    for (SelexMovieModel* model in _editModels) {
        
        size = CGSizeMake(model.asset.pixelWidth, model.asset.pixelHeight);

        [exportInfo addObject:@{kMovieURLKey    : model.movieURL,
                                kMovieWidthKey  : [NSNumber numberWithFloat:size.width],
                                kMovieHeightKey : [NSNumber numberWithFloat:size.height],
                                kMovieFilterKey : [VideoFilterView filterImageWithType:model.vFilter]}];
                                
    }

    return exportInfo;
}

#pragma mark - Gesture Recognizer

- (void)setUpGestures {
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handlePress:)];
    longPressGesture.numberOfTouchesRequired = 1;
    longPressGesture.minimumPressDuration    = 0.2f;
    [_collectionView addGestureRecognizer:longPressGesture];
}

- (void)handlePress:(UILongPressGestureRecognizer *)gesture {
    CGPoint point = [gesture locationInView:_collectionView];
    
    if (gesture.state == UIGestureRecognizerStateBegan ||
        gesture.state == UIGestureRecognizerStateEnded)
    {
        NSIndexPath *indexPath = [_collectionView indexPathForItemAtPoint:point];
        if (indexPath != nil) {
            
            // calculate point in parent view
            point = [gesture locationInView:_parentView];
  
            if(gesture.state == UIGestureRecognizerStateBegan)
            {
                _rearrangeIndex = indexPath.item;
                _rearrangeModel = [_editModels objectAtIndex:indexPath.item];
                if(self.delegate && [self.delegate respondsToSelector:@selector(didSelectedRearrangeItem:position:)])
                    [self.delegate didSelectedRearrangeItem:_rearrangeModel position:point];
            }
            else if(gesture.state == UIGestureRecognizerStateEnded)
            {
                if(self.delegate && [self.delegate respondsToSelector:@selector(didReleasedRearrangeItem:index:)])
                    [self.delegate didReleasedRearrangeItem:_rearrangeModel index:_rearrangeIndex];
            }
        }
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _editModels.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SelexEditCell *cell = (SelexEditCell *)[_collectionView dequeueReusableCellWithReuseIdentifier:SELEX_TRACK_CELL_REUSE_ID forIndexPath:indexPath];
    
    SelexMovieModel *model = [_editModels objectAtIndex:indexPath.item];
    [cell setModel:model];
    
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return _cellSize;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(8, 8, 8, 8);
}

@end
