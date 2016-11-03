//
//  ResultViewController.m
//  Welm
//
//  Created by Luke Stanley on 1/10/16.
//  Copyright © 2016 Luke Stanley. All rights reserved.
//

#import "ResultViewController.h"
#import "SelexCell.h"
#import "CommonUtils.h"
#import "AppDelegate.h"


@interface ResultViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
{
    UICollectionView        *_collectionView;
    UIView*                 _parentView;
    NSMutableArray          *_models;
    SelexMovieModel         *_selectedModel;
    
    CommonUtils             *utils;
    
    CGSize                  _cellSize;
}
@end


@implementation ResultViewController

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

- (instancetype)initWithCollectionView:(UICollectionView *)view viewController:(UIViewController*)viewController{
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

    NSArray* photos = [utils getResultList];
    
    for (PHAsset* asset in photos) {
        
        [_models addObject:[SelexMovieModel modelWithAsset:asset]];
    }
    
    [_collectionView reloadData];
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
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handlePress:)];
    tapGesture.numberOfTouchesRequired = 1;
    [_collectionView addGestureRecognizer:tapGesture];
}

#pragma mark - Gesture Recognizer

- (void)handlePress:(UITapGestureRecognizer *)gesture {
    CGPoint point = [gesture locationInView:_collectionView];
    
    if (gesture.state == UIGestureRecognizerStateBegan||
        gesture.state == UIGestureRecognizerStateEnded) {
        
        NSIndexPath *indexPath = [_collectionView indexPathForItemAtPoint:point];
        if (indexPath != nil) {
            _selectedModel = [_models objectAtIndex:indexPath.item];
            
            // calculate point in parent view
            point = [gesture locationInView:_parentView];
            
            if(self.delegate && [self.delegate respondsToSelector:@selector(didSelectedPreviewItem:position:)])
                [self.delegate didSelectedPreviewItem:_selectedModel position:point];
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
    [cell.btClose removeFromSuperview];
    cell.btClose = nil;
    
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
