//
//  ScrollCardFlowLayoutAttributes.m
//  NewDrama
//
//  Created by s5346 on 2024/6/27.
//

#import "ScrollCardFlowLayoutAttributes.h"

@interface ScrollCardFlowLayoutAttributes ()

@end

@implementation ScrollCardFlowLayoutAttributes

- (id)copyWithZone:(NSZone *)zone {
    ScrollCardFlowLayoutAttributes *copy = [super copyWithZone:zone];
    copy.contentView = self.contentView;
    copy.startOffset = self.startOffset;
    copy.middleOffset = self.middleOffset;
    copy.endOffset = self.endOffset;
    return copy;
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[ScrollCardFlowLayoutAttributes class]]) {
        return NO;
    }
    ScrollCardFlowLayoutAttributes *other = (ScrollCardFlowLayoutAttributes *)object;
    return [super isEqual:other]
        && other.contentView == self.contentView
        && other.startOffset == self.startOffset
        && other.middleOffset == self.middleOffset
        && other.endOffset == self.endOffset;
}

@end
