//
//  DMBackgroundFetchObserver.m
//  DMAutoInvalidation
//
//  Created by Jonathon Mah on 2015-05-15.
//  Copyright (c) 2015 Atomic Labs.
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#if TARGET_OS_IPHONE

#import "DMBackgroundFetchObserver.h"

#import "DMAutoInvalidation.h"
#import "DMBlockUtilities.h"


@interface DMBackgroundFetchObserver () <DMAutoInvalidation>
@end


@implementation DMBackgroundFetchObserver {
    BOOL _invalidated;

    __unsafe_unretained id _unsafeOwner;
    DMBackgroundFetchActionBlock _actionBlock;
}

#pragma mark NSObject

static NSHashTable *backgroundFetchObservers;

+ (void)initialize
{
    if (self == [DMBackgroundFetchObserver class]) {
        backgroundFetchObservers = [NSHashTable weakObjectsHashTable];
    }
}

- (void)dealloc
{
    [self invalidate];
}

- (NSString *)description
{
    if (_invalidated)
        return [NSString stringWithFormat:@"<%@ %p (invalidated)>", [self class], self];
    return [NSString stringWithFormat:@"<%@ %p owner: <%@ %p>>", [self class], self, [_unsafeOwner class], _unsafeOwner];
}


#pragma mark <DMAutoInvalidation>

- (void)invalidate
{
    if (_invalidated)
        return;
    _invalidated = YES;

    _actionBlock = nil;
    _unsafeOwner = nil;
    [DMObserverInvalidator observerDidInvalidate:self];
    @synchronized (backgroundFetchObservers) {
        [backgroundFetchObservers removeObject:self];
    }
}


#pragma mark HLTPhotoLibraryObserver

+ (instancetype)observerAttachedToOwner:(id)owner action:(DMBackgroundFetchActionBlock)actionBlock
{
    return [[self alloc] initAttachedToOwner:owner action:actionBlock];
}

- (instancetype)initAttachedToOwner:(id)owner action:(DMBackgroundFetchActionBlock)actionBlock
{
    NSParameterAssert(owner && actionBlock);
    if (!(self = [super init]))
        return nil;

    _unsafeOwner = owner;
    _actionBlock = [actionBlock copy];

    [DMObserverInvalidator attachObserver:self toOwner:owner];

    @synchronized (backgroundFetchObservers) {
        [backgroundFetchObservers addObject:self];
    }

#ifndef NS_BLOCK_ASSERTIONS
    if ([DMBlockUtilities isObject:owner implicitlyRetainedByBlock:actionBlock])
        DMBlockRetainCycleDetected([NSString stringWithFormat:@"%s action captures owner; use localSelf (localOwner) parameter to fix.", __func__]);
#endif

    return self;
}

- (void)fireActionWithRemoteNotification:(nullable NSDictionary *)userInfo fetchCompletionHandler:(DMBackgroundFetchCompletionHandler)fetchCompletionHandler
{
    if (_invalidated)
        return;

    // If our owner has deallocated, we should be invalidated at this point. Since we're not, our owner must still be alive.
    DMBackgroundFetchActionBlock actionBlock = [_actionBlock copy]; // Use a local reference, as the actionBlock could call -invalidate on us
    actionBlock(userInfo, _unsafeOwner, fetchCompletionHandler);
}

+ (void)fireBackgroundFetchActionsWithRemoteNotification:(nullable NSDictionary *)userInfo fetchCompletionHandler:(DMBackgroundFetchCompletionHandler)fetchCompletionHandler
{
    NSAssert([NSThread isMainThread], nil);

    NSArray *observers;
    @synchronized (backgroundFetchObservers) {
        observers = backgroundFetchObservers.allObjects;
    }

    __block NSInteger observersRemaining = observers.count;
    if (observersRemaining > 0) {
        __block NSUInteger newDataCount = 0, noDataCount = 0, failedCount = 0;

        void (^callFinalCompletion)(void) = [^{
            if (newDataCount > 0) {
                fetchCompletionHandler(UIBackgroundFetchResultNewData);
            } else if (failedCount > 0) {
                fetchCompletionHandler(UIBackgroundFetchResultFailed);
            } else {
                fetchCompletionHandler(UIBackgroundFetchResultNoData);
            }
        } copy];

        for (DMBackgroundFetchObserver *observer in observers) {
            __block BOOL completionCalled = NO;
            DMBackgroundFetchCompletionHandler compositeCompletion = ^(UIBackgroundFetchResult fetchResult) {
                NSCAssert(!completionCalled, @"Fetch completion block called multiple times");
                completionCalled = YES;

                switch (fetchResult) {
                    case UIBackgroundFetchResultNewData:
                        newDataCount++; break;
                    case UIBackgroundFetchResultNoData:
                        noDataCount++; break;
                    case UIBackgroundFetchResultFailed:
                        failedCount++; break;
                }

                if (--observersRemaining == 0) {
                    callFinalCompletion();
                }
            };

            [observer fireActionWithRemoteNotification:userInfo fetchCompletionHandler:compositeCompletion];
        }
    } else {
        fetchCompletionHandler(UIBackgroundFetchResultNoData);
    }
}

@end

#endif
