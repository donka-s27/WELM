//
//  EditorViewController.m
//  Welm
//
//  Created by Donka Stoyanov on 11/25/15.
//  Copyright © 2015 Donka Stoyanov. All rights reserved.
//

#import "EditorViewController.h"
#import "CommonUtils.h"
#import "PreviewViewController.h"
#import "SourceViewController.h"
#import "DestinationViewController.h"
#import "ResultViewController.h"
#import "TrackView.h"
#import "SelexMovieModel.h"
#import "SelexEditCell.h"
#import "VideoFilterView.h"
#import "WelmAlertController.h"
#import "SVProgressHUD.h"
#import "WelmTabBarController.h"

@interface EditorViewController () <UIGestureRecognizerDelegate, SourceViewDelegate, DestinationViewDelegate, ResultViewDelegate, VideoFilterViewDelegate>
{
    SourceViewController        * _sourceViewController;
    DestinationViewController   * _destinationViewController;
    ResultViewController        * _resultViewController;
    TrackView                   * _draggedTrackView;
    VideoFilterView             * _vFilterView;
    SelexMovieModel             * _model;

    SelexEditCell               * _curEditingCell;
    int                         _curIndex;
    
    CGPoint _originalPosition;
    CGPoint _touchOffset;
    
    CommonUtils* utils;
}

@property (weak, nonatomic) IBOutlet UIView *projectBgView;
@property (weak, nonatomic) IBOutlet UILabel *lblIntroduction;
@property (weak, nonatomic) IBOutlet UICollectionView *destinationCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionView *sourceCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionView *resultCollectionView;



@property (weak, nonatomic) IBOutlet UIView *editorContainer;

@property (nonatomic,strong) NSMutableArray *photos;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *layoutDstCollectionViewHeight;

@end

@implementation EditorViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    CGSize size = [UIScreen mainScreen].bounds.size;
    CGFloat rate = (MAX(size.width, size.height) - 50) / 500.0;
    
    self.layoutDstCollectionViewHeight.constant *= rate;    

    [self setup];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setup
{
    CGFloat height;
    CGSize  size;
    CGFloat screenHeight = CGRectGetHeight([UIScreen mainScreen].bounds);
    
    _sourceViewController = [[SourceViewController alloc] initWithCollectionView:self.sourceCollectionView viewController:self];
    _sourceViewController.delegate = self;
    height = screenHeight/2 - 125 - self.layoutDstCollectionViewHeight.constant/2 - 48
    ;
    size = CGSizeMake((int)(height/0.75), (int)(height));
    [_sourceViewController setCellSize:size];
    [_sourceViewController setUpModels];

    _destinationViewController = [[DestinationViewController alloc] initWithCollectionView:self.destinationCollectionView viewController:self ];
    _destinationViewController.delegate = self;
    height = self.layoutDstCollectionViewHeight.constant - 130;
    size = CGSizeMake((int)(height/0.75), (int)(height));
    [_destinationViewController setCellSize:size];

    _resultViewController = [[ResultViewController alloc] initWithCollectionView:self.resultCollectionView viewController:self];
    _resultViewController.delegate = self;
    height = screenHeight/2 - 130 - self.layoutDstCollectionViewHeight.constant/2 - 16;
    size = CGSizeMake((int)(height/0.75), (int)(height));
    [_resultViewController setCellSize:size];
    [_resultViewController setUpModels];

    self.projectBgView.clipsToBounds = YES;
    self.projectBgView.layer.cornerRadius = 8.0;
    
    [self initDraggedTrackView];
    
    _draggedTrackView.frame = CGRectMake(0, 0, size.width, size.height);

    UIPanGestureRecognizer *panGesture =
    [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    panGesture.delegate = self;
    [self.view addGestureRecognizer:panGesture];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    topViewController = self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.sourceCollectionView reloadData];
    [_resultViewController setUpModels];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectedVideoTrack:) name:kVideoTrackSelectedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeSelex:) name:kRemoveSelexNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changedSelex:) name:kSelexAddedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changedResult:) name:kResultAddedNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - VideoFilterView Delegate

- (void)changedSelex:(NSNotification*)notification
{
    [_sourceViewController setUpModels];
}

- (void)changedResult:(NSNotification*)notification
{
    [_resultViewController setUpModels];
}

#pragma mark - VideoFilterView Delegate

- (void)didSelectedFilter:(VideoFilterType)type
{
    if(_vFilterView)
    {
        [_vFilterView removeFromSuperview];
        _vFilterView = nil;
    }
    
    if(_curEditingCell)
        [_curEditingCell setVideoFilter:type];
        
    self.editorContainer.userInteractionEnabled = NO;
    self.editorContainer.backgroundColor = [UIColor clearColor];
}

#pragma mark - selexCell remove

- (void)removeSelex:(NSNotification*)notification
{
    _model = (SelexMovieModel*)notification.object;

    [SVProgressHUD show];
    [[CommonUtils sharedObject] getVideoPathWithAsset:_model.asset completionHandler:^(NSURL* movieURL) {
        
        [[CommonUtils sharedObject] removeSelex:_model.asset completionHandler:^(BOOL success) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if(success)
                {
                    [_sourceViewController removeItem:_model];
                    [_destinationViewController removeItemWithMoviePath:movieURL];
                }
                
                [SVProgressHUD dismiss];
            });
        }];
    }];

}

#pragma mark - SourceView Delegate

- (void)didSelectedDraggingItem:(SelexMovieModel *)model position:(CGPoint)pos
{
    _model = model;
    
    if (_model != nil) {
        [_draggedTrackView setImageWithAsset:model.asset];
        _draggedTrackView.center = pos;
        _draggedTrackView.hidden = NO;
        
        [self updateTrackViewDragState:[self isValidDragPoint:pos]];
    } else {
        _draggedTrackView.hidden = YES;
    }
}

- (void)didReleasedDraggingItem:(SelexMovieModel *)model position:(CGPoint)pos
{
    int index = [self isValidDragPoint:pos];
    
    if(index < 0)
        _draggedTrackView.hidden = YES;
}

#pragma mark - DestinationView Delegate

- (void)didSelectedRearrangeItem:(SelexMovieModel *)model position:(CGPoint)pos
{
    _model = model;
    
    if (_model != nil) {
        [_draggedTrackView setImageWithAsset:model.asset];
        _draggedTrackView.center = pos;
        _draggedTrackView.hidden = NO;
        
        _curIndex = [self isValidDragPoint:pos];
        [self updateTrackViewDragState:_curIndex];
        
        [_destinationViewController removeItem:_curIndex];
        
    } else {
        _draggedTrackView.hidden = YES;
    }
}

//- (void)didReleasedRearrangeItem:(SelexMovieModel *)model index:(int)index
//{
//    if(index == INT_MAX || index == _curIndex)
//    {
//        [_destinationViewController addModel:model index:_curIndex];
//        _draggedTrackView.hidden = YES;
//        _model = nil;
//    }
//}

#pragma mark - ResultView Delegate
- (void)didSelectedPreviewItem:(SelexMovieModel *)model position:(CGPoint)pos
{
    [self performSegueWithIdentifier:@"EditToPreview" sender:model.movieURL];
}

#pragma mark - buttion action

- (IBAction)OnPlay:(id)sender {
    
    [self performSegueWithIdentifier:@"EditToPreview" sender:nil];
//    [_destinationViewController clear];
}

#pragma mark - Validation helper methods on drag and drop

- (int)isValidDragPoint:(CGPoint)point {
    
    CGRect dstFrame = self.projectBgView.frame;//[self.destinationCollectionView convertRect:self.destinationCollectionView.frame toView:self.view];
    if (!CGRectContainsPoint(dstFrame, point))
        return -1;

    UICollectionViewLayoutAttributes* attributes;
    NSInteger nCount = [self.destinationCollectionView numberOfItemsInSection:0];
    
    for (int i=0; i<nCount; i++) {
        
        attributes = [self.destinationCollectionView layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
        CGRect cellFrameInSuperview = [self.destinationCollectionView convertRect:attributes.frame toView:self.view];
        
        if (CGRectContainsPoint(cellFrameInSuperview, point)) {
            return i;
        }
    }
    
    return INT_MAX;
}

- (void)updateTrackViewDragState:(int)validDropPos {
    if (validDropPos >= 0) {
        _draggedTrackView.alpha = 1.0f;
    } else {
        _draggedTrackView.alpha = 0.4f;
    }
}

#pragma mark - initialization code

- (void)initDraggedTrackView {
    _draggedTrackView = [[TrackView alloc] initWithFrame:CGRectZero];
    _draggedTrackView.hidden = YES;
    
    [self.view addSubview:_draggedTrackView];
}

#pragma mark - Pan Gesture Recognizers/delegate

- (void)handlePan:(UIPanGestureRecognizer *)gesture {
    CGPoint touchPoint = [gesture locationInView:self.view];
    if (gesture.state == UIGestureRecognizerStateChanged && !_draggedTrackView.hidden)
    {
        // track is dragged
        _draggedTrackView.center = touchPoint;

        [self updateTrackViewDragState:[self isValidDragPoint:touchPoint]];
        
    }
    else if (gesture.state == UIGestureRecognizerStateCancelled)
    {
        _draggedTrackView.hidden = YES;
        
    }
    else if (gesture.state == UIGestureRecognizerStateRecognized && _model != nil)
    {
        _draggedTrackView.hidden = YES;
        
        int validDropPos = [self isValidDragPoint:touchPoint];

        if (validDropPos >= 0) {
            [_destinationViewController addModel:_model index:validDropPos];
        }
        _model = nil;
    }

    if([_destinationViewController count] > 0)
        self.lblIntroduction.hidden = YES;
    else
        self.lblIntroduction.hidden = NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

#pragma mark - selected track methods

- (void)selectedVideoTrack:(NSNotification*)notification
{
    _curEditingCell = (SelexEditCell*)notification.object;
    
    _vFilterView = [[VideoFilterView alloc] initWithImage:[_curEditingCell image]];
    _vFilterView.delegate = self;
    [self.editorContainer addSubview:_vFilterView];
    self.editorContainer.userInteractionEnabled = YES;
    self.editorContainer.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
}

#pragma mark - orientation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"EditToPreview"])
    {
        PreviewViewController   *previewVC = segue.destinationViewController;
        
        if(sender)
        {
            previewVC.movieURL      = sender;
            previewVC.previewInfo   = nil;
        }
        else
        {
            previewVC.movieURL      = nil;
            previewVC.previewInfo   = [_destinationViewController exportMovieInfo];
        }
    }
}

//#pragma mark - orientation
//
//- (BOOL)shouldAutorotate
//{
//    return NO;
//}
//
//- (UIInterfaceOrientationMask)supportedInterfaceOrientations
//{
//    return UIInterfaceOrientationMaskPortrait;
//}

@end
