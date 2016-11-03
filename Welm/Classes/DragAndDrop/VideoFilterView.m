//
//  VideoFilterView.m
//  Welm
//
//  Created by Luke Stanley on 12/19/15.
//  Copyright © 2015 Luke Stanley. All rights reserved.
//

#import "VideoFilterView.h"

@interface VideoFilterView ()
{
    UIImage*    _image;
    CGSize      _btSize;
    int         _filterCount;
    
    NSMutableArray* _btFilters;
}

@end

#define kOverlayImageKey        @"OverlayImage"
#define kFilterTypeKey          @"FilterType"
#define kFilterNameKey          @"FilterName"

@implementation VideoFilterView

+ (NSArray*)filterInfo
{
    static NSArray* filterInfoArray = nil;
    if(filterInfoArray == nil) {
        
        filterInfoArray = [NSArray arrayWithObjects: @{kFilterTypeKey:[NSNumber numberWithInteger:VideoFilterTypeSuper8],  kFilterNameKey:@"Super 8mm",  kOverlayImageKey:[UIImage imageNamed:@"vfilter_super8"]},
                           @{kFilterTypeKey:[NSNumber numberWithInteger:VideoFilterTypeUltra16], kFilterNameKey:@"Ultra 16mm", kOverlayImageKey:[UIImage imageNamed:@"vfilter_ultra16"]},
                           @{kFilterTypeKey:[NSNumber numberWithInteger:VideoFilterTypeNormal],  kFilterNameKey:@"Normal",     kOverlayImageKey:[[UIImage alloc] init]}, nil];
    }
    
    return filterInfoArray;
}

+ (UIImage*)filterImageWithType:(VideoFilterType)type
{
    NSArray* filterInfos = [VideoFilterView filterInfo];
    
    for (NSDictionary* info in filterInfos) {
        
        VideoFilterType itemType = [(NSNumber*)info[kFilterTypeKey] integerValue];
        
        if(itemType == type)
            return info[kOverlayImageKey];
    }
    return nil;
}

- (instancetype)initWithImage:(UIImage *)image
{
    self = [super init];
    if(self)
    {
        _image = image;

        [self setup];
    }
    return self;
}

- (void)setup
{
    CGSize size = [[UIScreen mainScreen] bounds].size;
    size = CGSizeMake(MIN(size.width, size.height), MAX(size.width, size.height));

    CGSize containerSize;
    int     rows = 2, cols;
    
    _filterCount = VideoFilterTypeCount;
    cols = _filterCount / 2 + (_filterCount % 2 ? 1 : 0);
    
    _btSize.width = (int)((size.width - 160) / 2);
    _btSize.height = (int)(_btSize.width*2/3);
    
    containerSize.width = _btSize.width + 16;
    containerSize.height = _btSize.height + 16;
    
    self.frame = CGRectMake((size.width - containerSize.width*rows - 16)/2,
                            (size.height - containerSize.height*cols - 16)/2,
                            containerSize.width*rows + 16,
                            containerSize.height*cols + 16);

    self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.6];
    self.clipsToBounds = YES;
    self.layer.cornerRadius = 8;

    _btFilters = [[NSMutableArray alloc] init];
    
    NSArray* filterInfo = [VideoFilterView filterInfo];
    
    for (int i=0; i<_filterCount; i++) {
        
        CGFloat x, y;
        
        if(_filterCount%2 && i==(_filterCount-1))
            x = (CGRectGetWidth(self.frame) - _btSize.width)/2;
        else
            x = i*containerSize.width+(containerSize.width - _btSize.width)/2 + 8;
        
        y = i/rows*containerSize.height+(containerSize.height - _btSize.height)/2 + 8;
        
        UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, _btSize.width, _btSize.height)];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        imageView.image = _image;
        
        UIButton* btFilter = [[UIButton alloc] initWithFrame:CGRectMake(x, y, _btSize.width, _btSize.height)];
        btFilter.tag = i;
        [btFilter setBackgroundImage:[filterInfo[i] objectForKey:kOverlayImageKey] forState:UIControlStateNormal];
        [btFilter setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btFilter setTitle:[filterInfo[i] objectForKey:kFilterNameKey] forState:UIControlStateNormal];
        [btFilter addTarget:self action:@selector(selectFilter:) forControlEvents:UIControlEventTouchDown];
        [btFilter addTarget:self action:@selector(didSelectFilter:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:imageView];
        [self addSubview:btFilter];
        [_btFilters addObject:btFilter];
    }
}

- (IBAction)selectFilter:(id)sender
{
    _filterType = ((UIButton*)sender).tag;
}

- (IBAction)didSelectFilter:(id)sender
{
    if(self.delegate)
        [self.delegate didSelectedFilter:_filterType];
}

@end
