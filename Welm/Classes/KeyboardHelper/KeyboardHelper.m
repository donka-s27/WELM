//
//  KeyboardHelper.m
//  KeyboardHelperDemo
//
//  Created by Shaikh Sonny Aman on 7/23/12.
//  Copyright (c) 2012 XappLab!. All rights reserved.
//

#import "KeyboardHelper.h"
#import "WelmTabBarController.h"

@interface KeyboardHelper()<UITextFieldDelegate, UITextViewDelegate>

@property (nonatomic, strong) NSMutableArray* textFieldsAndViews;

@property (nonatomic, strong) UIToolbar* barHelper;
@property (nonatomic, strong) NSArray* barButtonSetNormal;
@property (nonatomic, strong) NSArray* barButtonSetAtFirst;
@property (nonatomic, strong) NSArray* barButtonSetAtLast;
@property (nonatomic, assign) UIView* selectedTextFieldOrView;

@property (nonatomic, strong) t_KeyboardHelperOnDone onDoneBlock;
@property (nonatomic, assign) SEL onDoneSelector;
@property (nonatomic, assign) UIViewController* viewController;
@property (nonatomic, assign) CGRect initialFrame;
@property (nonatomic, assign) CGRect kbRect;
@property (nonatomic, assign) float distanceFromKeyBoardTop;
@property (nonatomic, assign) BOOL shouldSelectNextOnEnter;

@property (nonatomic, strong) UISegmentedControl* segPrevNext;


@end

@implementation KeyboardHelper
@synthesize textFieldsAndViews, barHelper, barButtonSetAtFirst, barButtonSetAtLast, barButtonSetNormal;
@synthesize textViewDelegate, textFieldDelegate, selectedTextFieldOrView;
@synthesize onDoneBlock, onDoneSelector, viewController;
@synthesize initialFrame, kbRect, distanceFromKeyBoardTop, shouldSelectNextOnEnter;
@synthesize segPrevNext;

- (id) initWithViewController:(UIViewController*)vc onDoneSelector:(SEL)done{
    self = [self initWithViewController:vc];
    if (self) {
        self.onDoneSelector = done;
    }
    return self;
}
- (id) initWithViewController:(UIViewController*)vc onDoneAction:(t_KeyboardHelperOnDone)onDone{
    self = [self initWithViewController:vc];
    if (self) {
        self.onDoneBlock = onDone;
    }
    return self;
}

- (id) initWithViewController:(UIViewController*)vc{
    if ( !vc.isViewLoaded ) {
        [NSException raise:@"KeyboardHelperException" format:@"KeyboardHelper Error: View not loaded.\n Initialize keyboard helper in viewDidLoad method."];
        return nil;
    }
    
    self = [super init];
    if (self) {
        enabled = NO;
        self.viewController = vc;
        self.distanceFromKeyBoardTop = 5;
        self.shouldSelectNextOnEnter = YES;
        
        self.textFieldsAndViews = [NSMutableArray new];
        
        NSLog(@"Initial frame: %@", NSStringFromCGRect([[UIApplication sharedApplication] statusBarFrame]));
        CGRect initFrame = vc.view.frame;
        
        if([vc isKindOfClass:[WelmTabBarController class]])
        {
            UITabBar* tabBar = vc.tabBarController.tabBar;
            
            if(tabBar)
                initFrame.size.height -= CGRectGetHeight(tabBar.frame);
        }

        self.initialFrame = initFrame;

        statusBarHeight = 0;
        //		if (![UIApplication sharedApplication].isStatusBarHidden) {
        //			CGRect rect =   [[UIApplication sharedApplication] statusBarFrame];
        //			initialFrame.origin.y += rect.size.height;
        //			statusBarHeight = rect.size.height;
        //		}
        
        self.barHelper = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, vc.view.bounds.size.width, 44)];
        barHelper.barStyle = UIBarStyleBlackTranslucent;
        
        // segmented control idea was given by Adam Roberts, Managing Director at Enigmatic Flare, 2012
        self.segPrevNext = [[UISegmentedControl alloc] initWithItems: [NSArray arrayWithObjects:NSLocalizedString(@"Prev", @"Prev"), NSLocalizedString(@"Next", @"Next"), nil]];
        segPrevNext.momentary = YES;
        [segPrevNext addTarget:self
                        action:@selector(segmentValueChanged:)
              forControlEvents:UIControlEventValueChanged];
        
        
        UIBarButtonItem* btnDone = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", @"Done")
                                                                    style:UIBarButtonItemStyleDone
                                                                   target:self
                                                                   action:@selector(onDone:)];
        UIBarButtonItem* seperator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                   target:nil
                                                                                   action:NULL];
        [barHelper setItems:[NSArray arrayWithObjects:[[UIBarButtonItem alloc] initWithCustomView:segPrevNext], seperator, btnDone, nil]];
        [self reload];
    }
    return self;
}

- (void) addTextFieldAndViews:(UIView*)view
{
    for (UIView* aview in view.subviews) {
        if ( !aview.hidden
            && aview.alpha
            && aview.isUserInteractionEnabled
            )
        {
            
            if( [aview isKindOfClass:[UITextField class]] ||
               [aview isKindOfClass:[UITextView class]])
            {
                if([aview respondsToSelector:@selector(setInputAccessoryView:)]){
                    [aview performSelector:@selector(setInputAccessoryView:) withObject:self.barHelper];
                }
                
                [aview performSelector:@selector(setDelegate:) withObject:self];
                [textFieldsAndViews addObject:aview];
            }
            
            [self addTextFieldAndViews:aview];
        }
    }
}

- (void) reload{
    [textFieldsAndViews removeAllObjects];
    
    [self addTextFieldAndViews:viewController.view];
    
    // order
    [textFieldsAndViews sortUsingComparator:^NSComparisonResult(id obj1, id obj2){
        CGPoint origin1 = [(UIView*)obj2 frame].origin;
        CGPoint origin2 = [(UIView*)obj1 frame].origin;
        
        if (origin1.y < origin2.y || origin1.x < origin2.x){
            return  NSOrderedDescending;
        }
        return NSOrderedAscending;
    }];
    [self enable];
}

- (void) enable{
    if (!enabled) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
        enabled = YES;
    }
    
}
- (void) disable{
    if (enabled) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        enabled = NO;
    }
}

- (void) segmentValueChanged:(UISegmentedControl*)sender{
    switch (sender.selectedSegmentIndex) {
        case 0:
            [self onPrev:nil];
            break;
        case 1:
            [self onNext:nil];
            break;
        default:
            break;
    }
}

- (CGPoint)getOriginInScreen:(UIView*)view
{
    CGPoint ptOrg = view.frame.origin, ptParent = CGPointZero;
    
    if (view.superview)
        ptParent = [self getOriginInScreen:view.superview];
    
    if([view.superview isKindOfClass:[UIScrollView class]])
    {
        UIScrollView* scrollView = (UIScrollView*)view.superview;
        CGPoint ptOffset = scrollView.contentOffset;
        ptOrg.x -= ptOffset.x;
        ptOrg.y -= ptOffset.y;
    }
        
    ptOrg.x += ptParent.x;
    ptOrg.y += ptParent.y;
    
    return ptOrg;
}

- (void) updateViewPosition{
    float kbTopY = kbRect.origin.y;
    float visibleYWithPadding = kbTopY - distanceFromKeyBoardTop - statusBarHeight;
    CGRect txtFrame =  [selectedTextFieldOrView frame];
    
    txtFrame.origin = [self getOriginInScreen:selectedTextFieldOrView];
    
    float visibleY = visibleYWithPadding - txtFrame.size.height;
    
    CGRect currentFrame =   viewController.view.frame;
    
    CGRect newFrame = initialFrame;
    
    if (txtFrame.origin.y > visibleY ) {
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        
        if (UIInterfaceOrientationIsPortrait(orientation)) {
            float offset = initialFrame.origin.y - currentFrame.origin.y;
            float diff = txtFrame.origin.y - visibleY - offset;
            if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
                newFrame = CGRectMake(currentFrame.origin.x
                                      , currentFrame.origin.y + diff /* update y */
                                      , currentFrame.size.width,
                                      currentFrame.size.height);
            } else {
                newFrame = CGRectMake(currentFrame.origin.x
                                      , currentFrame.origin.y - diff /* update y */
                                      , currentFrame.size.width,
                                      currentFrame.size.height);
            }
            
            
        } else {
            
            
            if (orientation == UIInterfaceOrientationLandscapeRight) {
                NSLog(@"KeyboardHelper: TBD: LandScape Mode");
            } else {
                float offset = initialFrame.origin.x - currentFrame.origin.x;
                float diff = txtFrame.origin.y - visibleY - offset;
                newFrame = CGRectMake(currentFrame.origin.x - diff + kbRect.origin.x
                                      , currentFrame.origin.y/* update y */
                                      , currentFrame.size.width,
                                      currentFrame.size.height);
            }
            
        }
        
    }
    if (!CGRectEqualToRect(newFrame, currentFrame)) {
        [UIView animateWithDuration:0.3
                         animations:^(void){
                             viewController.view.frame = newFrame;
                         }];
    }
}

- (void) updateBarHelper{
    //	if (!CGRectIsEmpty(self.kbRect)) {
    //		[self updateViewPosition];
    //	}
    
    id obj = [textFieldsAndViews objectAtIndex:0];
    if ( obj == selectedTextFieldOrView) {
        [segPrevNext setEnabled:NO forSegmentAtIndex:0];
        [segPrevNext setEnabled:YES forSegmentAtIndex:1];
    } else if ( [textFieldsAndViews lastObject] == selectedTextFieldOrView ) {
        [segPrevNext setEnabled:NO forSegmentAtIndex:1];
        [segPrevNext setEnabled:YES forSegmentAtIndex:0];
    } else {
        [segPrevNext setEnabled:YES forSegmentAtIndex:0];
        [segPrevNext setEnabled:YES forSegmentAtIndex:1];
    }
}

- (void) onNext:(id)sender{
    if ( selectedTextFieldOrView != [textFieldsAndViews lastObject]) {
        int index = (int)[textFieldsAndViews indexOfObject:selectedTextFieldOrView];
        id nextObj = [textFieldsAndViews objectAtIndex:index + 1];
        [nextObj becomeFirstResponder];
    }
    
}
- (void) onPrev:(id)sender{
    if ( selectedTextFieldOrView != [textFieldsAndViews objectAtIndex:0]) {
        int index = (int)[textFieldsAndViews indexOfObject:selectedTextFieldOrView];
        id nextObj = [textFieldsAndViews objectAtIndex:index - 1];
        [nextObj becomeFirstResponder];
    }
}
- (void) onDone:(id)sender{
    [selectedTextFieldOrView resignFirstResponder];
    if (self.onDoneSelector) {
        if ([viewController respondsToSelector:onDoneSelector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [viewController performSelector:onDoneSelector];
#pragma clang diagnostic pop
            
        }
    } else if ( self.onDoneBlock) {
        onDoneBlock();
    }
}

#pragma mark - UITextFieldDelegate methods
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    self.selectedTextFieldOrView = textField;
    [self updateBarHelper];
    
    if (self.textFieldDelegate && [textFieldDelegate respondsToSelector:@selector(textFieldShouldBeginEditing:)]) {
        return [textFieldDelegate textFieldShouldBeginEditing:textField];
    }
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    if (self.textFieldDelegate && [textFieldDelegate respondsToSelector:@selector(textFieldDidBeginEditing:)]) {
        [textFieldDelegate textFieldDidBeginEditing:textField];
    }
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    if (self.textFieldDelegate && [textFieldDelegate respondsToSelector:@selector(textFieldShouldEndEditing:)]) {
        return [textFieldDelegate textFieldShouldEndEditing:textField];
    }
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    if (self.textFieldDelegate && [textFieldDelegate respondsToSelector:@selector(textFieldDidEndEditing:)]) {
        [textFieldDelegate textFieldDidEndEditing:textField];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (self.textFieldDelegate && [textFieldDelegate respondsToSelector:@selector(textField: shouldChangeCharactersInRange: replacementString:)]) {
        return [textFieldDelegate textField:textField shouldChangeCharactersInRange:range replacementString:string];
    }
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField{
    if (self.textFieldDelegate && [textFieldDelegate respondsToSelector:@selector(textFieldShouldClear:)]) {
        return [textFieldDelegate textFieldShouldClear:textField];
    }
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (shouldSelectNextOnEnter) {
        [self onNext:nil];
    }
    return YES;
}

#pragma mark - UITextViewDelegate methods
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    self.selectedTextFieldOrView = textView;
    [self updateBarHelper];
    
    if (self.textViewDelegate && [textViewDelegate respondsToSelector:@selector(textViewShouldBeginEditing:)]) {
        return [textViewDelegate textViewShouldBeginEditing:textView];
    }
    return YES;
}
- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
    if (self.textViewDelegate && [textViewDelegate respondsToSelector:@selector(textViewShouldEndEditing:)]) {
        return [textViewDelegate textViewShouldEndEditing:textView];
    }
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView{	
    if (self.textViewDelegate && [textViewDelegate respondsToSelector:@selector(textViewDidBeginEditing:)]) {
        [textViewDelegate textViewDidBeginEditing:textView];
    }
}
- (void)textViewDidEndEditing:(UITextView *)textView{
    if (self.textViewDelegate && [textViewDelegate respondsToSelector:@selector(textViewDidEndEditing:)]) {
        [textViewDelegate textViewDidEndEditing:textView];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if (self.textViewDelegate && [textViewDelegate respondsToSelector:@selector(textView: shouldChangeTextInRange: replacementText:)]) {
        return [textViewDelegate textView:textView shouldChangeTextInRange:range replacementText:text];
    }
    return YES;
}
- (void)textViewDidChange:(UITextView *)textView{
    if (self.textViewDelegate && [textViewDelegate respondsToSelector:@selector(textViewDidChange:)]) {
        [textViewDelegate textViewDidChange:textView];
    }
}

- (void)textViewDidChangeSelection:(UITextView *)textView{
    if (self.textViewDelegate && [textViewDelegate respondsToSelector:@selector(textViewDidChangeSelection:)]) {
        [textViewDelegate textViewDidChangeSelection:textView];
    }
}

#pragma mark - KeyBoard notifications
- (void) keyboardWillShow:(NSNotification*)notify{	
    self.kbRect = [(NSValue*)[notify.userInfo valueForKey:@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];
    [self updateViewPosition];	
}
- (void) keyboardWillHide:(NSNotification*)notify{
    [UIView animateWithDuration:0.25 
                     animations:^(void){						 
                         self.viewController.view.frame = initialFrame;
                     }];	
}
@end
