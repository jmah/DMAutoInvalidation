//
//  DMFilesystemEventObserver.h
//  DMAutoInvalidation
//
//  Created by William Shipley on 2007-01-03.
//  Copyright (c) 2007 Delicious Monster Software.
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

#if !TARGET_OS_IPHONE

#import <Foundation/Foundation.h>
#import "DMAutoInvalidation.h"

@class DMFilesystemEventObserver;
// Not all info is passed to block callback, just because no-one needs it (yet).
typedef void(^DMFilesystemEventActionBlock)(id localSelf, DMFilesystemEventObserver *observer); // ‘localSelf’ param is actually the owner, which is almost always used as ‘self’


@interface DMFilesystemEventObserver : NSObject <DMAutoInvalidation>

+ (instancetype)observerForDirectoryPaths:(NSArray *)paths attachedToOwner:(id)owner action:(DMFilesystemEventActionBlock)actionBlock __attribute__((nonnull(1,2,3)));

- (id)initWithDirectoryPaths:(NSArray *)paths attachedToOwner:(id)owner since:(FSEventStreamEventId)since latency:(NSTimeInterval)latency action:(DMFilesystemEventActionBlock)actionBlock __attribute__((nonnull(1,2,5)));

- (void)fireAction;
- (void)invalidate;

@end

#endif
