// MLLTapGestureRecognizer.h

@interface MYTapGestureRecognizer : UITapGestureRecognizer

@property (nonatomic, copy) mengbanBlock block;
@property (nonatomic, strong) UIView *shadowView;
@end
