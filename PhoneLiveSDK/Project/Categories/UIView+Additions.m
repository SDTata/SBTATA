//
//  UIViewAdditions.m
//

#import "UIView+Additions.h"
#import <QuartzCore/QuartzCore.h>

#define buleColor   [UIColor colorWithRed:60/255.0f green:140/255.0f blue:232/255.0f alpha:1.0]
#define purpleColor [UIColor colorWithRed:171/255.0f green:145/255.0f blue:234/255.0f alpha:1.0]

@implementation UIView (Additions)

static char dataProviderKey;

- (NSObject *)dataProvider {
    return objc_getAssociatedObject(self, &dataProviderKey);
}

- (void)setDataProvider:(NSObject *)dataProvider {
    objc_setAssociatedObject(self, &dataProviderKey, dataProvider, OBJC_ASSOCIATION_RETAIN);
}

/**
添加渐变色特效
*/
-(CAGradientLayer *)addGradientView:(UIColor *)startColor endColor:(UIColor *)endColor
{
    if(!startColor){
        startColor = buleColor;
    }
    if(!endColor){
        endColor = purpleColor;
    }
    CAGradientLayer *layer = [CAGradientLayer layer];
    layer.colors = @[(__bridge id)startColor.CGColor,(__bridge id)endColor.CGColor];
    layer.startPoint = CGPointMake(0, 0);
    layer.endPoint = CGPointMake(1.0, 0);
    layer.frame = self.bounds;
    [self.layer addSublayer:layer];
    layer.zPosition = -1;
    return layer;
}

- (void)vk_slantHorizontal:(CGFloat)value {
    CGAffineTransform matrix = CGAffineTransformMake(1, 0, tanf(value * (CGFloat)M_PI / 180), 1, 0, 0);
    self.transform = matrix;
}

- (id)initWithParent:(UIView *)parent {
	self = [self initWithFrame:CGRectZero];
	
	if (!self)
		return nil;
	
	[parent addSubview:self];
	
	return self;
}

+ (id) viewWithParent:(UIView *)parent {
	return [[self alloc] initWithParent:parent];
}

- (void)setBackgroundImage:(UIImage *)image
{
    UIGraphicsBeginImageContext(self.frame.size);
    [image drawInRect:self.bounds];
    UIImage *bgImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.backgroundColor = [UIColor colorWithPatternImage:bgImage];
}

- (UIImage*)toImage
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0.0);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [self.layer renderInContext:ctx];
    UIImage* tImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return tImage;
}

- (CGPoint)position {
	return self.frame.origin;
}

- (void)setPosition:(CGPoint)position {
	CGRect rect = self.frame;
	rect.origin = position;
	[self setFrame:rect];
}

- (CGFloat)x {
	return self.frame.origin.x;
}

- (void)setX:(CGFloat)x {
	CGRect rect = self.frame;
	rect.origin.x = x;
	[self setFrame:rect];
}

- (CGFloat)y {
	return self.frame.origin.y;
}

- (void)setY:(CGFloat)y {
	CGRect rect = self.frame;
	rect.origin.y = y;
	[self setFrame:rect];
}


- (CGFloat)left {
	return self.frame.origin.x;
}

- (void)setLeft:(CGFloat)x {
	CGRect frame = self.frame;
	frame.origin.x = x;
	self.frame = frame;
}

- (CGFloat)top {
	return self.frame.origin.y;
}

- (void)setTop:(CGFloat)y {
	CGRect frame = self.frame;
	frame.origin.y = y;
	self.frame = frame;
}

- (CGFloat)right {
	return self.frame.origin.x + self.frame.size.width;
}

- (void)setRight:(CGFloat)right {
	CGRect frame = self.frame;
	frame.origin.x = right - frame.size.width;
	self.frame = frame;
}

- (CGFloat)bottom {
	return self.frame.origin.y + self.frame.size.height;
}

- (void)setBottom:(CGFloat)bottom {
	CGRect frame = self.frame;
	frame.origin.y = bottom - frame.size.height;
	self.frame = frame;
}





- (BOOL)visible {
	return !self.hidden;
}

- (void)setVisible:(BOOL)visible {
	self.hidden=!visible;
}


-(void)removeAllSubViews{
	
	for (UIView *subview in self.subviews){
		[subview removeFromSuperview];
	}
	
}


- (CGSize)size {
	return [self frame].size;
}

- (void)setSize:(CGSize)size {
	CGRect rect = self.frame;
	rect.size = size;
	[self setFrame:rect];
}

- (CGFloat)width {
	return self.frame.size.width;
}

- (void)setWidth:(CGFloat)width {
	CGRect rect = self.frame;
	rect.size.width = width;
	[self setFrame:rect];
}

- (CGFloat)height {
	return self.frame.size.height;
}

- (void)setHeight:(CGFloat)height {
	CGRect rect = self.frame;
	rect.size.height = height;
	[self setFrame:rect];
}

@end

@implementation UIImageView (MFAdditions)

- (void) setImageWithName:(NSString *)name {
	
	[self setImage:[ImageBundle imagewithBundleName:name]];
	[self sizeToFit];
}

@end
