//
//  UIRoundCornerImageView.m
//  Apollo
//
//  Created by Slavik on 11-3-30.
//  Copyright 2011年 ihanghai.com. All rights reserved.
//

#import "UIRoundCornerImageView.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIRoundCornerImageView

- (void)setCornerRadius:(CGFloat)cornerRadius {
 
    if( ABS(_cornerRadius-cornerRadius) >= 1.0f ) {
        _cornerRadius = cornerRadius;
        [self _updateMask];
    }
    
}

- (void)setFrame:(CGRect)frame {
 
    CGSize prevSize = self.bounds.size;
    [super setFrame:frame];
    CGSize size = self.bounds.size;
    
    if( !CGSizeEqualToSize(prevSize, size) ) {
        [self _updateMask];
    }
    
}

- (void)_updateMask {
    
    CALayer* layer = self.layer;
    
    CAShapeLayer* mask = (CAShapeLayer*)layer.mask;
    if( nil == mask ) {
        mask = [CAShapeLayer layer];
    }
    UIBezierPath* path = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                                    cornerRadius:self.cornerRadius];
    mask.path = [path CGPath];
    
    if( mask != layer.mask ) {
        layer.mask = mask;
    }
    
}

@end
