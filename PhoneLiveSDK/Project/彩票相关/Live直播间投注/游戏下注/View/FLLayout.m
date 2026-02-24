//
//  FLLayout.m
//  FLTag
//
//  Created by Felix on 2017/5/11.
//  Copyright © 2017年 FREEDOM. All rights reserved.
//

#import "FLLayout.h"

@interface FLLayout ()
{
    CGFloat _contentHeight;
}
@property (nonatomic, assign) CGFloat columnSpace;
@property (nonatomic, assign) CGFloat minColumnSpace;
@property (nonatomic, assign) CGFloat rowSpace;
@property (nonatomic, assign) CGFloat maxRowSpace;
@property (nonatomic, assign) CGFloat itemHeight;
@property (nonatomic, assign) CGFloat textInset;        //字距离边界的距离
@property (nonatomic, assign) CGFloat minItemWidth;
@property (nonatomic, assign) NSInteger processingLine;

@property (nonatomic, strong) NSMutableDictionary *dic;
@property (nonatomic, strong) NSMutableArray *array;
@property (nonatomic, strong) NSMutableDictionary *attributeDic;

@property (nonatomic, assign) CGPoint point;            //记录每一个item的origin


@end

@implementation FLLayout
- (instancetype)init{
    if (self = [super init]) {
        _columnSpace = 8;
        _minColumnSpace = 6;
        _rowSpace = 16;
        _maxRowSpace = 10;
        _textInset = 23;
        _minItemWidth = 102;
        _insets = UIEdgeInsetsMake(2, 7, 2, 7); // top, left, bottom, right
        _point = CGPointMake(_insets.left, _insets.top);
        _array = [NSMutableArray array];
        _dic = [NSMutableDictionary dictionary];
        _attributeDic = [NSMutableDictionary dictionary];
    }
    return self;
}

-(void)setInsets:(UIEdgeInsets)insets
{
    _insets = insets;
    _point = CGPointMake(_insets.left, _insets.top);
    _dic = [NSMutableDictionary dictionary];
    _array = [NSMutableArray array];
    
}
-(void)resetDict{
    _attributeDic = [NSMutableDictionary dictionary];
}
- (CGSize)collectionViewContentSize{
    return CGSizeMake(kWidth, _contentHeight);
}
- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect{
    NSMutableArray * array = [NSMutableArray array];
    NSInteger sectionCount = [self.collectionView numberOfSections];
    if(!sectionCount || sectionCount == 0){
        return array;
    }
    NSInteger count = [self.collectionView numberOfItemsInSection:0];
    if(!count || count == 0){
        return array;
    }
    for (int i = 0; i < count; i++) {
        UICollectionViewLayoutAttributes * attrs = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
        [array addObject:attrs];
    }
    CGSize size = [self.dataSource collectionView:self.collectionView sizeForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    
    NSInteger lineCount = _dic.count;
    if(_dic.count > 0){
        NSInteger lastIndex = _dic.count - 1;
        
        NSArray * keys = [_dic allKeys];
        NSString * keyName = [keys objectAtIndex:lastIndex];
        NSArray * arr = _dic[keyName];
        if(arr.count <= 0){
            lineCount -= 1;
        }
    }
    
    // 行距
    _rowSpace = MAX((self.collectionView.height - size.height * lineCount) / lineCount, _maxRowSpace);
    if (count >= 14) {
        _rowSpace = MAX((self.collectionView.height - size.height * lineCount) / lineCount, _maxRowSpace);
    }
    if (count == 7) {
        _rowSpace = 0;
    }
    // 列距
    _columnSpace = MAX((kWidth - _insets.left - _insets.right - size.width * count) / count, _minColumnSpace);
    
    _processingLine = 0;
    [_dic enumerateKeysAndObjectsUsingBlock:^(NSString *y, NSArray *arr, BOOL * _Nonnull stop) {
        CGFloat width = 0;
        CGFloat originX = 0;
        for (int i=0; i<arr.count; i++) {
            UICollectionViewLayoutAttributes *att = arr[i];
            width += att.frame.size.width;
            if (i == 0) originX = att.frame.origin.x;
        }
        width += (arr.count-1)*_columnSpace;
        CGFloat startX = (kWidth-width)/2.;
        CGFloat cha = startX - originX;
        for (int i=0; i<arr.count; i++) {
            UICollectionViewLayoutAttributes *att = arr[i];
            att.frame = CGRectMake(att.frame.origin.x+cha,  + att.frame.origin.y , att.frame.size.width, att.frame.size.height);
            [_attributeDic setObject:att forKey:att.indexPath];
        }
        _processingLine ++;
    }];
    
    [_dic removeAllObjects];
    [_array removeAllObjects];
    
    for(UICollectionViewLayoutAttributes* attrs in array) {
        
        if([attrs representedElementKind] == UICollectionElementKindSectionFooter) {
            
            CGRect headerRect = [attrs frame];
            
            headerRect.size.height = 100;
            
            headerRect.size.width = kWidth;
            
            [attrs setFrame:headerRect];
            
            break;
            
        }
        
    }
    
//    return attributes;
    
    return  array;
}

- (nullable UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath{
    if ([_attributeDic objectForKey:indexPath]) {
        UICollectionViewLayoutAttributes *att = [_attributeDic objectForKey:indexPath];
        return att;
    }
    CGSize size = [self.dataSource collectionView:self.collectionView sizeForItemAtIndexPath:indexPath];
    CGSize nextSize;
    if (indexPath.item != [self.collectionView numberOfItemsInSection:0]-1) {
        nextSize = [self.dataSource collectionView:self.collectionView sizeForItemAtIndexPath:[NSIndexPath indexPathForRow:indexPath.item+1 inSection:0]];
    }else{
//        nextText = nil;
    }
    
    CGFloat x = _point.x;
    CGFloat y = _point.y;
    
    UICollectionViewLayoutAttributes * attribute = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    attribute.frame = CGRectMake(x, y, size.width, size.height);
    
    NSInteger count = [self.collectionView numberOfItemsInSection:0];
    // 列距
    _columnSpace = MAX((kWidth - _insets.left - _insets.right - size.width * count) / count, _minColumnSpace);
    BOOL bNeedChangeLine = false;
    if(count > 5 && count <= 12){
        if(_array.count + 1 == ceil(count*1.0/2) && _array.count + 1 >= count/2.0){
            bNeedChangeLine = true;
        }
    }
    
    
    if (_point.x > kWidth-size.width-_columnSpace*_array.count-nextSize.width+_insets.left+_insets.right|| bNeedChangeLine) {
        //下一个item需要换行了
        [_array addObject:attribute];
        [_dic setObject:[NSArray arrayWithArray:_array] forKey:[NSString stringWithFormat:@"%.f",_point.y]];
        [_array removeAllObjects];

//        bNeedChangeLine = true;
        _point = CGPointMake(_insets.left, _point.y+size.height);
    }else{
        [_array addObject:attribute];
        _point = CGPointMake(_point.x+size.width+_columnSpace, _point.y);
    }
    
    if (indexPath.item == [self.collectionView numberOfItemsInSection:0]-1) {
        [_dic setObject:_array forKey:[NSString stringWithFormat:@"%.f",_point.y]];
        
        if (count<=14) {
            _point.y -= size.height;
            _contentHeight = _point.y+size.height+_insets.bottom;
        }else if (count >= 20){
            _contentHeight = _point.y+_insets.bottom+60;
        } else{
            _contentHeight = _point.y+size.height+_insets.bottom+20;
        }
        
        
        
        _point = CGPointMake(_insets.left, _insets.top);
        
    }else if(bNeedChangeLine){
        //_point = CGPointMake(_insets.left, _point.y+size.height/*+_rowSpace*/);
    }
    return attribute;
}
-(CGFloat)getWidthByString:(NSString*)string withFont:(UIFont*)font
{
    CGSize size = [string boundingRectWithSize:CGSizeMake(LONG_MAX, 20) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil].size;
    return size.width ;
}


//- (nullableNSArray<__kindofUICollectionViewLayoutAttributes*> *)layoutAttributesForElementsInRect:(CGRect)rect{
//
//    NSMutableArray*attributes = [[super layoutAttributesForElementsInRect:rect]mutableCopy];
//
//    for(NSIntegeri =0; i <_numberOfCells; i++) {
//
//        NSIndexPath*indexPath = [NSIndexPathindexPathForItem:iinSection:0];
//
//        UICollectionViewLayoutAttributes*attribute = [selflayoutAttributesForItemAtIndexPath:indexPath];
//
//        [attributes addObject:attribute];
//
//    }
//
//    for(UICollectionViewLayoutAttributes* attrs in attributes) {
//
//        if([attrs representedElementKind] ==UICollectionElementKindSectionFooter) {
//
//            CGRect headerRect = [attrs frame];
//
//            headerRect.size.height=100;
//
//            headerRect.size.width=SCREEN_SIZE.width;
//
//            [attrs setFrame:headerRect];
//
//            break;
//
//        }
//
//    }
//
//    return attributes;
//
//}
//
//作者：驰宝
//链接：https://www.jianshu.com/p/eea2fe47692b
//来源：简书
//著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。
@end
