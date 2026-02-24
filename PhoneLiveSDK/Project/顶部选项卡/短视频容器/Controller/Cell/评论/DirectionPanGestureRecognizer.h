//
//  DirectionPanGestureRecognizer.h
//  phonelive2
//
//  Created by user on 2024/8/10.
//  Copyright © 2024 toby. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIGestureRecognizerSubclass.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum {
    DirectionPangestureRecognizerVertical,
    DirectionPanGestureRecognizerHorizontal
} DirectionPangestureRecognizerDirection;
@interface DirectionPanGestureRecognizer : UIPanGestureRecognizer {
    BOOL _drag;
    int _moveX;
    int _moveY;
    DirectionPangestureRecognizerDirection _direction;
}
@property (nonatomic, assign) DirectionPangestureRecognizerDirection direction;
@end

NS_ASSUME_NONNULL_END
