//
//  SourceViewController.m
//  Welm
//
//  Created by Donka Stoyanov on 12/2/15.
//  Copyright © 2015 Donka Stoyanov. All rights reserved.
//

#import "SourceViewController.h"
#import "SelexCell.h"
#import "CommonUtils.h"
#import "AppDelegate.h"

@interface SourceViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
{
    UICollectionView        *_collectionView;
    UIView*                 _parentView;
    NSMutableArray          *_models;
    SelexMovieModel         *_selectedModel;
    
    CommonUtils             *utils;
    
    CGSize                  _cellSize;
}
@end


@implementation SourceViewController

- (CGSize)cellSize
{
    return _cellSize;
}

- (void)setCellSize:(CGSize)size
{
    _cellSize = size;
}

- (NSUInteger)count
{
    return _models.count;
}

- (instancetype)initWithCollectionView:(UICollectionView *)view  viewController:(UIViewController*)viewController{
    if (self = [super init]) {

        utils = [CommonUtils sharedObject];

        _cellSize = CGSizeZero;
        
        [self initCollectionView:view];
        [self setUpGestures];
        
        _parentView = viewController.view;

        _models = [NSMutableArray array];
    }
    return self;
}

#pragma mark - Setup methods

- (void)setUpModels {
    
    [_models removeAllObjects];
    
     NSArray* photos = [utils getSelexList];
    
    for (PHAsset* asset in photos) {

        [_models addObject:[SelexMovieModel modelWithAsset:asset]];
    }
    
    [_collectionView reloadData];
}

- (void)removeItem:(SelexMovieModel*)model
{
    NSInteger index = [_models indexOfObject:model];
    
    if (index < 0)
        return;
    
    [_models removeObjectAtIndex:index];
    
    NSIndexPath* item = [NSIndexPath indexPathForItem:index inSection:0];
    NSMutableArray* reloadItems = [[NSMutableArray alloc] init];
    
    [_collectionView deleteItemsAtIndexPaths:[NSArray arrayWithObject:item]];
    
    for (NSInteger i=index; i<_models.count; i++) {
        [reloadItems addObject:[NSIndexPath indexPathForItem:i inSection:0]];
    }
    [_collectionView reloadItemsAtIndexPaths:reloadItems];
}

- (void)initCollectionView:(UICollectionView *)view {
    _collectionView                 = view;
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.backgroundView  = [[UIView alloc] initWithFrame:CGRectZero];

    _collectionView.delegate   = self;
    _collectionView.dataSource = self;
    
    [_collectionView registerClass:[SelexCell class] forCellWithReuseIdentifier:SELEX_CELL_REUSE_ID];
}

- (void)setUpGestures {
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handlePress:)];
    longPressGesture.numberOfTouchesRequired = 1;
    longPressGesture.minimumPressDuration    = 0.3f;
    [_collectionView addGestureRecognizer:longPressGesture];
}

#pragma mark - Gesture Recognizer

- (void)handlePress:(UILongPressGestureRecognizer *)gesture {
    CGPoint point = [gesture locationInView:_collectionView];
    
    if (gesture.state == UIGestureRecognizerStateBegan||
        gesture.state == UIGestureRecognizerStateEnded) {
        
        NSIndexPath *indexPath = [_collectionView indexPathForItemAtPoint:point];
        if (indexPath != nil) {
            _selectedModel = [_models objectAtIndex:indexPath.item];
            
            // calculate point in parent view
            point = [gesture locationInView:_parentView];
            
            if (gesture.state == UIGestureRecognizerStateBegan) {
                
                if(self.delegate && [self.delegate respondsToSelector:@selector(didSelectedDraggingItem:position:)])
                    [self.delegate didSelectedDraggingItem:_selectedModel position:point];
            }
            else if (gesture.state == UIGestureRecognizerStateEnded) {

                if(self.delegate && [self.delegate respondsToSelector:@selector(didReleasedDraggingItem:position:)])
                    [self.delegate didReleasedDraggingItem:_selectedModel position:point];
            }
        }
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _models.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SelexCell *cell = [_collectionView dequeueReusableCellWithReuseIdentifier:SELEX_CELL_REUSE_ID forIndexPath:indexPath];
    
    SelexMovieModel *model = [_models objectAtIndex:indexPath.item];
    [cell setModel:model];
    
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return _cellSize;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(12, 12, 12, 12);
}

@end
