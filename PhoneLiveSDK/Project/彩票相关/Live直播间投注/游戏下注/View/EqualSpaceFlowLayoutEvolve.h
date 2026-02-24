//
//  EqualSpaceFlowLayoutEvolve.h
//
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,AlignType){
    AlignWithLeft,
    AlignWithCenter,
    AlignWithRight
};
@interface EqualSpaceFlowLayoutEvolve : UICollectionViewFlowLayout

//两个Cell之间的距离
@property (nonatomic,assign)CGFloat betweenOfCell;
//cell对齐方式
@property (nonatomic,assign)AlignType cellType;
-(instancetype)initWthType : (AlignType)cellType;

@end