//
//  PassthroughTextView.m
//  phonelive2
//
//  Created by s5346 on 2024/9/10.
//  Copyright © 2024 toby. All rights reserved.
//

#import "PassthroughTextView.h"

@implementation PassthroughTextView

- (BOOL)isLinkAtPoint:(CGPoint)point {
    NSUInteger characterIndex = [self characterIndexAtPoint:point];
    if (characterIndex == NSNotFound) {
        return NO;
    }

    NSUInteger length = [self.attributedText length];
    if (characterIndex >= length) {
        return NO;
    }

    NSDictionary *attributes = [self.attributedText attributesAtIndex:characterIndex effectiveRange:NULL];
    return attributes[NSLinkAttributeName] != nil;
}

- (NSUInteger)characterIndexAtPoint:(CGPoint)point {
    NSUInteger glyphIndex = NSNotFound;
    CGRect glyphRect = CGRectZero;

    NSLayoutManager *layoutManager = self.layoutManager;
    NSTextContainer *textContainer = self.textContainer;

    // 調整點擊位置，考慮文本容器的內邊距
    CGPoint adjustedPoint = CGPointMake(point.x - self.textContainerInset.left,
                                        point.y - self.textContainerInset.top);

    glyphIndex = [layoutManager glyphIndexForPoint:adjustedPoint
                                   inTextContainer:textContainer
                    fractionOfDistanceThroughGlyph:NULL];

    glyphRect = [layoutManager boundingRectForGlyphRange:NSMakeRange(glyphIndex, 1)
                                         inTextContainer:textContainer];

    if (!CGRectContainsPoint(glyphRect, adjustedPoint)) {
        return NSNotFound;
    }

    return [layoutManager characterIndexForGlyphAtIndex:glyphIndex];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (!self.userInteractionEnabled || self.hidden || self.alpha <= 0.01) {
        return nil;
    }

    if ([self pointInside:point withEvent:event]) {
        if ([self isLinkAtPoint:point]) {
            return [super hitTest:point withEvent:event];
        } else {
            // 不是連結，讓事件穿透
            return nil;
        }
    }

    return nil;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if ([self isLinkAtPoint:point]) {
        return YES;
    }
    return NO;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    return NO;
}

@end
