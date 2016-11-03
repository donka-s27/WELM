//
//  WelmTabBarController.m
//  Welm
//
//  Created by Luke Stanley on 1/7/16.
//  Copyright © 2016 Luke Stanley. All rights reserved.
//

#import "WelmTabBarController.h"
#import "StartViewController.h"


@interface WelmTabBarController () <UIScrollViewDelegate>
{
    UIScrollView*   _tabItemContainter;
    UIView*         _contentView;
    CGFloat         _itemWidth;
    CGFloat         _beginPos;
    
    BOOL            _isProcessing;
    
    NSMutableArray* _realVCArray;
    
    NSUInteger      _realIndex;
}
@end

@implementation WelmTabBarController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    _isProcessing   = NO;
    _realIndex      = 0;
    
    // init viewcontrollers array
    _realVCArray = [[NSMutableArray alloc] initWithArray:self.viewControllers];
    
    NSMutableArray* vcs = [[NSMutableArray alloc] initWithArray:_realVCArray];
    [vcs removeLastObject];
    self.viewControllers = vcs;
    
    CGRect frame = self.tabBar.frame;
    CGFloat x, y, itemWidth, itemHeight, w = 40, h = 40;
    
    frame.size.width = CGRectGetWidth(self.view.bounds);
    
    itemWidth = CGRectGetWidth(frame) / 5;
    itemHeight = CGRectGetHeight(frame);
    
    _tabItemContainter = [[UIScrollView alloc] initWithFrame:frame];
    _tabItemContainter.showsHorizontalScrollIndicator = NO;
    _tabItemContainter.showsVerticalScrollIndicator = NO;
    _tabItemContainter.bounces = NO;
    _tabItemContainter.pagingEnabled = NO;
    _tabItemContainter.directionalLockEnabled = YES;
    _tabItemContainter.delegate = self;
    
    [self.view addSubview:_tabItemContainter];
    
    frame = _tabItemContainter.bounds;
    frame.size.width = itemWidth*6;
    
    _contentView = [[UIView alloc] initWithFrame:frame];
    _contentView.backgroundColor = [UIColor colorWithRed:130.0/255.0 green:150.0/255.0 blue:200.0/255.0 alpha:1.0];
    
    _tabItemContainter.contentSize = frame.size;
    [_tabItemContainter addSubview:_contentView];
    
    NSArray* normal_images = [NSArray arrayWithObjects:[UIImage imageNamed:@"home_normal"],
                              [UIImage imageNamed:@"profile_normal"],
                              [UIImage imageNamed:@"notes_normal"],
                              [UIImage imageNamed:@"editSuite_normal"],
                              [UIImage imageNamed:@"under_normal"],
                              [UIImage imageNamed:@"VR_normal"],
                              nil];
    
    NSArray* selected_images = [NSArray arrayWithObjects:[UIImage imageNamed:@"home_selected"],
                                [UIImage imageNamed:@"profile_selected"],
                                [UIImage imageNamed:@"notes_selected"],
                                [UIImage imageNamed:@"editSuite_selected"],
                                [UIImage imageNamed:@"under_selected"],
                                [UIImage imageNamed:@"VR_selected"],
                                nil];
    
    // tabItems
    x = (itemWidth - w)/ 2;
    y = (itemHeight - h)/2 + 2;
    
    for (int i=0; i<6; i++) {
        UIButton* btTabItem = [[UIButton alloc] initWithFrame:CGRectMake(x, y, w, h)];
        [btTabItem setImage:normal_images[i] forState:UIControlStateNormal];
        [btTabItem setImage:selected_images[i] forState:UIControlStateSelected];
        [btTabItem setImage:selected_images[i] forState:UIControlStateHighlighted];
        [btTabItem setImage:selected_images[i] forState:UIControlStateDisabled];
        [btTabItem addTarget:self action:@selector(tabChanged:) forControlEvents:UIControlEventTouchUpInside];
        
        btTabItem.tag = 200+i;
        [btTabItem setSelected:NO];
        
        if(i == [self selectedIndex])
            [btTabItem setSelected:YES];
        
        [_contentView addSubview:btTabItem];
        
        x += itemWidth;
    }
    
    // swipe Left
    frame = _contentView.bounds;
    CGSize size = CGSizeMake(12, 30);
    
    UIImageView* swipeLeftImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, (CGRectGetHeight(frame)- size.height)/2, size.width, size.height)];
    swipeLeftImgView.image = [UIImage imageNamed:@"swipeTabLeft"];
    [_contentView addSubview:swipeLeftImgView];
    
    UIImageView* swipeRightImgView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(frame) - size.width, (CGRectGetHeight(frame)- size.height)/2, size.width, size.height)];
    swipeRightImgView.image = [UIImage imageNamed:@"swipeTabRight"];
    [_contentView addSubview:swipeRightImgView];
    
    _itemWidth = itemWidth;
    
    [self removeOtherViewControllers];
    
    [self setSelectedIndex:_initialSeletedIndex];
}

- (void)removeOtherViewControllers
{
    UIViewController* rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController* navigationController = (UINavigationController *)rootViewController;
        navigationController.viewControllers = @[self];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)tabChanged:(UIButton*)selectedItem
{
    if(!_contentView || _isProcessing)
        return;
    
    _isProcessing = YES;
    
    for (int i=0; i<6; i++) {
        UIButton* btTabItem = (UIButton*)[_contentView viewWithTag:200+i];
        
        if(btTabItem.tag == selectedItem.tag)
        {
            _realIndex = i;
            
            if(!btTabItem.selected)
            {
                NSMutableArray* vcs = [[NSMutableArray alloc] initWithArray:_realVCArray];
                
                if(i > 4)
                {
                    [vcs removeObjectAtIndex:0];
                    self.viewControllers = vcs;
                    
                    [super setSelectedIndex:i-1];
                }
                else
                {
                    [vcs removeLastObject];
                    self.viewControllers = vcs;
                    
                    [super setSelectedIndex:i];
                }
                
                [btTabItem setSelected:YES];
            }
        }
        else
            [btTabItem setSelected:NO];
    }
    
    [self update];
    
    _isProcessing = NO;
}

- (void)moveToLeft
{
    if(_realIndex > 0)
    {
        UIButton* btTabItem = (UIButton*)[_contentView viewWithTag:200 + _realIndex - 1];
        [self tabChanged:btTabItem];
    }
}

- (void)moveToRight
{
    if(_realIndex < 5)
    {
        UIButton* btTabItem = (UIButton*)[_contentView viewWithTag:200 + _realIndex + 1];
        [self tabChanged:btTabItem];
    }
}

- (void)update
{
    if(_tabItemContainter.contentOffset.x > 0)
    {
        if(_realIndex == 0)
            _tabItemContainter.contentOffset = CGPointMake(0, 0);
    }
    else
    {
        if(_realIndex > 4)
            _tabItemContainter.contentOffset = CGPointMake(_itemWidth, 0);
    }
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex
{
    UIButton* btTabItem = (UIButton*)[_contentView viewWithTag:200+selectedIndex];

    [self tabChanged:btTabItem];
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
    return NO;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    _beginPos = scrollView.contentOffset.x;
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    CGFloat diff = scrollView.contentOffset.x - _beginPos;
    
    if(ABS(diff) > _itemWidth/2)
    {
        if(diff > 0)
            (*targetContentOffset).x = _itemWidth;
        else
            (*targetContentOffset).x = 0;
    }
    else
        (*targetContentOffset).x = _beginPos;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
}

@end
