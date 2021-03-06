//
//  DMBlockUtilities.h
//  DMBlockUtilities
//
//  Created by Jonathon Mah on 2012-06-07.
//  Copyright (c) 2012 Delicious Monster Software.
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


@interface DMBlockUtilities : NSObject

+ (BOOL)isObject:(id)object implicitlyRetainedByBlock:(id)block;

@end


extern void DMBlockRetainCycleDetected(NSString *msg); // Logs msg and stuff, provide a function to break on
