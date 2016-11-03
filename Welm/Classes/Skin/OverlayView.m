//
//  OverlayView.m
//  Welm
//
//  Created by Luke Stanley on 11/30/15.
//  Copyright © 2015 Luke Stanley. All rights reserved.
//

#import "OverlayView.h"
#import "constant.h"

@implementation OverlayView

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGRect rt = self.bounds;
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [[UIColor clearColor] setFill];
    CGContextFillRect(context, rt);
    
    rt = CGRectInset(self.bounds, kDefaultMargin, kDefaultMargin);
    [[UIColor greenColor] setStroke];
    CGContextSetLineWidth(context, kDefaultBorderWidth);
    CGContextStrokeRect(context, rt);
}
@end
