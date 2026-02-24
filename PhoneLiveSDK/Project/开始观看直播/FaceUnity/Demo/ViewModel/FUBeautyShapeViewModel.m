//
//  FUBeautyShapeViewModel.m
//  FUDemo
//
//  Created by 项林平 on 2021/6/11.
//

#import "FUBeautyShapeViewModel.h"

@interface FUBeautyShapeViewModel ()

@property (nonatomic, copy) NSArray<FUBeautyShapeModel *> *beautyShapes;
@property (nonatomic, assign) BOOL isDefaultValue;

@end

@implementation FUBeautyShapeViewModel

#pragma mark - NSCoding

+ (instancetype)loadCacheForKey:(NSString *)key {
    return [NSObject loadCacheForKey:key];
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.beautyShapes forKey:@"beautyShapes"];
    [coder encodeInteger:self.selectedIndex forKey:@"selectedIndex"];
    [coder encodeInteger:self.performanceLevel forKey:@"performanceLevel"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _beautyShapes = [coder decodeObjectForKey:@"beautyShapes"];
        _selectedIndex = [coder decodeIntegerForKey:@"selectedIndex"];
        _performanceLevel = [coder decodeIntegerForKey:@"performanceLevel"];
        
        // 确保加载后立即应用美型参数
        [self setAllShapeValues];
    }
    return self;
}

+ (NSDictionary *)mj_objectClassInArray {
    return @{
        @"beautyShapes": [FUBeautyShapeModel class]
    };
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.beautyShapes = [self defaultShapes];
        self.selectedIndex = -1;
        self.performanceLevel = [FURenderKit devicePerformanceLevel];
        
        [self setAllShapeValues];
    }
    return self;
}

#pragma mark - Instance methods

- (void)setShapeValue:(double)value {
    if (self.selectedIndex < 0 || self.selectedIndex >= self.beautyShapes.count) {
        return;
    }
    FUBeautyShapeModel *model = self.beautyShapes[self.selectedIndex];
    model.currentValue = value;
    [self setValue:model.currentValue forType:model.type];
}

- (void)setAllShapeValues {
    for (FUBeautyShapeModel *shape in self.beautyShapes) {
        [self setValue:shape.currentValue forType:shape.type];
    }
}

- (void)recoverAllShapeValuesToDefault {
    for (FUBeautyShapeModel *shape in self.beautyShapes) {
        shape.currentValue = shape.defaultValue;
        [self setValue:shape.currentValue forType:shape.type];
    }
}

#pragma mark - Private methods

- (void)setValue:(double)value forType:(FUBeautyShape)type {
    switch (type) {
        case FUBeautyShapeCheekThinning:
            [FURenderKit shareRenderKit].beauty.cheekThinning = value;
            break;
        case FUBeautyShapeCheekV:
            [FURenderKit shareRenderKit].beauty.cheekV = value;
            break;
        case FUBeautyShapeCheekNarrow:
            [FURenderKit shareRenderKit].beauty.cheekNarrow = value;
            break;
        case FUBeautyShapeCheekShort:
            [FURenderKit shareRenderKit].beauty.cheekShort = value;
            break;
        case FUBeautyShapeCheekSmall:
            [FURenderKit shareRenderKit].beauty.cheekSmall = value;
            break;
        case FUBeautyShapeCheekbones:
            [FURenderKit shareRenderKit].beauty.intensityCheekbones = value;
            break;
        case FUBeautyShapeLowerJaw:
            [FURenderKit shareRenderKit].beauty.intensityLowerJaw = value;
            break;
        case FUBeautyShapeEyeEnlarging:
            [FURenderKit shareRenderKit].beauty.eyeEnlarging = value;
            break;
        case FUBeautyShapeEyeCircle:
            [FURenderKit shareRenderKit].beauty.intensityEyeCircle = value;
            break;
        case FUBeautyShapeChin:
            [FURenderKit shareRenderKit].beauty.intensityChin = value;
            break;
        case FUBeautyShapeForehead:
            [FURenderKit shareRenderKit].beauty.intensityForehead = value;
            break;
        case FUBeautyShapeNose:
            [FURenderKit shareRenderKit].beauty.intensityNose = value;
            break;
        case FUBeautyShapeMouth:
            [FURenderKit shareRenderKit].beauty.intensityMouth = value;
            break;
        case FUBeautyShapeLipThick:
            [FURenderKit shareRenderKit].beauty.intensityLipThick = value;
            break;
        case FUBeautyShapeEyeHeight:
            [FURenderKit shareRenderKit].beauty.intensityEyeHeight = value;
            break;
        case FUBeautyShapeCanthus:
            [FURenderKit shareRenderKit].beauty.intensityCanthus = value;
            break;
        case FUBeautyShapeEyeLid:
            [FURenderKit shareRenderKit].beauty.intensityEyeLid = value;
            break;
        case FUBeautyShapeEyeSpace:
            [FURenderKit shareRenderKit].beauty.intensityEyeSpace = value;
            break;
        case FUBeautyShapeEyeRotate:
            [FURenderKit shareRenderKit].beauty.intensityEyeRotate = value;
            break;
        case FUBeautyShapeLongNose:
            [FURenderKit shareRenderKit].beauty.intensityLongNose = value;
            break;
        case FUBeautyShapePhiltrum:
            [FURenderKit shareRenderKit].beauty.intensityPhiltrum = value;
            break;
        case FUBeautyShapeSmile:
            [FURenderKit shareRenderKit].beauty.intensitySmile = value;
            break;
        case FUBeautyShapeBrowHeight:
            [FURenderKit shareRenderKit].beauty.intensityBrowHeight = value;
            break;
        case FUBeautyShapeBrowSpace:
            [FURenderKit shareRenderKit].beauty.intensityBrowSpace = value;
            break;
        case FUBeautyShapeBrowThick:
            [FURenderKit shareRenderKit].beauty.intensityBrowThick = value;
            break;
    }
}

#pragma mark - Getters

- (NSArray<FUBeautyShapeModel *> *)defaultShapes {
    NSBundle *bundle = [XBundle mainBundle];
    NSString *shapePath = [bundle pathForResource:@"beauty_shape" ofType:@"json"];
    NSArray<NSDictionary *> *shapeData = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:shapePath] options:NSJSONReadingMutableContainers error:nil];
    NSMutableArray *shapes = [[NSMutableArray alloc] init];
    for (NSDictionary *dictionary in shapeData) {
        FUBeautyShapeModel *model = [[FUBeautyShapeModel alloc] init];
        [model setValuesForKeysWithDictionary:dictionary];
        [shapes addObject:model];
    }
    return [shapes copy];
}


- (BOOL)isDefaultValue {
    for (FUBeautyShapeModel *shape in self.beautyShapes) {
        int currentIntValue = shape.defaultValueInMiddle ? (int)(shape.currentValue * 100 - 50) : (int)(shape.currentValue * 100);
        int defaultIntValue = shape.defaultValueInMiddle ? (int)(shape.defaultValue * 100 - 50) : (int)(shape.defaultValue * 100);
        if (currentIntValue != defaultIntValue) {
            return NO;
        }
    }
    return YES;
}

@end
