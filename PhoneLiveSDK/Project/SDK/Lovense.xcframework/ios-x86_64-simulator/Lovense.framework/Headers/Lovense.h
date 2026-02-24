//
//  Lovense.h
//  Lovense
//
//  Created by Lovense on 2019/3/4.
//  Copyright © 2019 Hytto. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LovenseToy.h"
#import "LovenseDefine.h"
#import "LovenseHelper.h"
#import "PatternPlayerHeader.h"

@interface Lovense : NSObject

+ (Lovense * _Nonnull)shared;
 
/**
 Pass your token into Lovense framework
 */
- (void)setDeveloperToken:(NSString * _Nonnull)token;

/**
 Search for Lovense toys
 */
- (void)searchToys;

/**
 Stop searching
 */
- (void)stopSearching;

/**
 Remove a toy from the saved list

 @param toyId toy's ID
 */
- (void)removeToyById:(NSString * _Nonnull)toyId;

/**
 Connect a toy

 @param toyId toy ID
 */
- (void)connectToy:(NSString * _Nonnull)toyId;

/**
 Disconnect a toy

 @param toyId toy ID
 */
- (void)disconnectToy:(NSString * _Nonnull)toyId;

/**
 Save a toy to the local list

 */
-(void)saveToys:(NSArray<LovenseToy *>* _Nonnull)toys;

/**
 Retrieve the saved toy list
 */
-(NSArray<LovenseToy *>* _Nullable)listToys;


/**
 Send a command to the toy

 @param toyId toy ID
 @param commandType command
 @param paramDict command parameters
 */
- (void)sendCommandWithToyId:(NSString * _Nonnull)toyId andCommandType:(LovenseCommandType)commandType andParamDict:(NSDictionary* _Nullable)paramDict;


#pragma mark- Pattern player

/// setup pattern player
/// @param toyIds toyIds
/// @param pf pf
- (void)setupPatternPlayerWithToyIds: (NSArray*) toyIds pf: (NSString*) pf;

/// prepare pattern file
/// @param mediaID  media ID
/// @param completion PatternPrepareState
- (void)prepareForPatternWithMediaID: (NSString*) mediaID completion: (void(^)(PatternPrepareState state)) completion;

/// play the pattern
/// @param currentTime  current time (ms)
/// @param totalTime  total time (ms)
- (void) playPatternWithCurrentTime: (NSTimeInterval) currentTime andTotalTime: (NSTimeInterval) totalTime;

/// set pattern play rate
/// @param rate  rate
- (void)setRate: (CGFloat)rate;

/// sync the play time
/// @param currentTime current time (ms)
- (void) syncCurrentTime: (NSTimeInterval) currentTime;

/// pause pattern
- (void) pausePattern;

/// stop pattern
- (void) stopPattern;

@end

