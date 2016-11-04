//
//  RoundTextField.m
//  Raze
//
//  Created by Donka Stoyanov on 11/30/15.
//  Copyright © 2015 Donka Stoyanov. All rights reserved.
//

#import "RoundTextField.h"

@implementation RoundTextField


- (instancetype)init{
    
    self = [super init];
    if(self)
    {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if(self)
    {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    self.clipsToBounds = YES;
    self.layer.cornerRadius = 4.0;
}

- (CGRect)textRectForBounds:(CGRect)bounds
{
    return CGRectInset(bounds, 12, 0);
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    return CGRectInset(bounds, 12, 0);
}


@end

