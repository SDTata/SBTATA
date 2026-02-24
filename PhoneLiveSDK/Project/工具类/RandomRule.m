//
//  RandomRule.m
//  phonelive
//
//  Created by 400 on 2020/12/14.
//  Copyright © 2020 toby. All rights reserved.
//

#import "RandomRule.h"

@implementation RandomRule
+(NSString*)randomWithColumn:(NSInteger)columnNumber Line:(NSInteger)lineNumber seeds:(NSInteger)seedsNumber others:(NSDictionary*)others
{
    NSInteger N = columnNumber * lineNumber;
    NSMutableArray *arrayNum = [NSMutableArray arrayWithCapacity:N];
    int randomNum = [RandomRule random:seedsNumber others:others];
    int *A = NULL;
    A = (int *)malloc(sizeof(int) * N);
    for (int i = 0; i < N; i++){
        A[i] = i + 1;
//        [arrayNum addObject:minnum(A[i])];
    }
    for (int i = 1; i < N; i++)
        Swap(&A[i], &A[RandInt(0, i,randomNum)]);

    for(int i = 0; i < N; i++)
       [arrayNum addObject:minnum(A[i])];
    
    return [arrayNum componentsJoinedByString:@""];
}
void Swap(int *a, int *b)
{
    int temp;

    temp = *a;
    *a = *b;
    *b = temp;
}

int RandInt(int i, int j,int randomN)
{
    int a;
    
    a = i + randomN % (j - i + 1);
    return a;
}

+(int)random:(NSInteger)seedsNumber others:(NSDictionary*)others
{
    NSString *key1 = @"25214903917";
    NSString *key2 = @"11";
    NSString *key3 = @"24897695";
    
    if (others != nil) {
        key1 = others[@"key1"];
        key2 = others[@"key2"];
        key3 = others[@"key3"];
    }
    
    NSDecimalNumber * amount0 = [NSDecimalNumber decimalNumberWithString:key1];
    NSDecimalNumber * amount1 = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%ld",seedsNumber]];
    NSDecimalNumber * amount2 = [NSDecimalNumber decimalNumberWithString:key2];
    NSDecimalNumber * amount3 = [NSDecimalNumber decimalNumberWithString:key3];
    
    NSDecimalNumber *acountn = [amount0 decimalNumberByMultiplyingBy:amount1];
    NSDecimalNumber *acountn1 = [acountn decimalNumberByAdding:amount2];
    
    NSDecimalNumber *remainder = [acountn1 decimalNumberByDividingBy:amount3 withBehavior:[NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundDown scale:0 raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO]];
    NSDecimalNumber *acountnYushu = [acountn1 decimalNumberBySubtracting:[remainder decimalNumberByMultiplyingBy:amount3]];
    return acountnYushu.intValue;
}
@end
