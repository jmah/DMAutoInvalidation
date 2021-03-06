//
//  DMNotificationObserver.h
//  DMAutoInvalidation
//
//  Created by Jonathon Mah on 2011-07-11.
//  Copyright (c) 2011 Delicious Monster Software.
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

#import <Foundation/Foundation.h>


/* The action block is passed the notification, the owner as a parameter (to avoid retain cycles),
 * and the triggering observer (so it can easily invalidate it if it needs to). */
@class DMNotificationObserver;
typedef void(^DMNotificationActionBlock)(NSNotification *notification, id localSelf, DMNotificationObserver *observer); // ‘localSelf’ param is actually the owner, which is almost always used as ‘self’


/* DMNotificationObserver is thread-safe. It's safe to create and call its method from any thread. Note that
 * if you create an observer on the main thread, and another object posts a notification on a background
 * thread, the action block will be run on the posting thread. (This is normal NSNotificationCenter behavior,
 * and we might want to define the environment better if lots of our clients end up doing a dispatch_async in
 * their action block.) */

/* The lifetime of a DMNotificationObserver is tied to its owner. Observers are automatically invalidated when
 * its owner is deallocated. Owners don't need to explicitly keep observers in strong storage (such as ivars);
 * instead, observers attach themselves to their owner with the associated objects API. */
@interface DMNotificationObserver : NSObject

+ (NSArray *)observersForNames:(NSArray *)notificationNameArray
                        object:(id)notificationSender
               attachedToOwner:(id)owner
                        action:(DMNotificationActionBlock)actionBlock
                               __attribute__((nonnull(1,3,4)));

+ (instancetype)observerForName:(NSString *)notificationName
                         object:(id)notificationSender
                attachedToOwner:(id)owner
                         action:(DMNotificationActionBlock)actionBlock
                                __attribute__((nonnull(3,4)));

- (id)initWithName:(NSString *)notificationName
            object:(id)notificationSender
   attachedToOwner:(id)owner
            action:(DMNotificationActionBlock)actionBlock
                   __attribute__((nonnull(3,4)));

- (id)initWithName:(NSString *)notificationName
            object:(id)notificationSender
   attachedToOwner:(id)owner
notificationCenter:(NSNotificationCenter *)notificationCenter
            action:(DMNotificationActionBlock)actionBlock
                   __attribute__((nonnull(3,4,5))); // Designated initializer

- (void)fireAction:(NSNotification *)notification;
- (void)invalidate;

@end
