//
//  DMBackgroundFetchObserver.h
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

#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

typedef void (^DMBackgroundFetchCompletionHandler)(UIBackgroundFetchResult);
typedef void (^DMBackgroundFetchActionBlock)(NSDictionary *__nullable notificationUserInfo, id localSelf, DMBackgroundFetchCompletionHandler fetchCompletionHandler);


@interface DMBackgroundFetchObserver : NSObject

+ (instancetype)observerAttachedToOwner:(id)owner action:(DMBackgroundFetchActionBlock)actionBlock;

- (instancetype)initAttachedToOwner:(id)owner action:(DMBackgroundFetchActionBlock)actionBlock NS_DESIGNATED_INITIALIZER;

- (void)fireActionWithRemoteNotification:(nullable NSDictionary *)userInfo fetchCompletionHandler:(DMBackgroundFetchCompletionHandler)fetchCompletionHandler;
- (void)invalidate;

+ (void)fireBackgroundFetchActionsWithRemoteNotification:(nullable NSDictionary *)userInfo fetchCompletionHandler:(DMBackgroundFetchCompletionHandler)fetchCompletionHandler;

@end

NS_ASSUME_NONNULL_END
