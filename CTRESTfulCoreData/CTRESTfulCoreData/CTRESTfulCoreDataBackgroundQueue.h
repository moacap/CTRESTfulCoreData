//
//  CTRESTfulCoreDataBackgroundQueue.h
//  CTRESTfulCoreData
//
//  Created by Oliver Letterer on 29.02.12.
//  Copyright (c) 2012 ebf. All rights reserved.
//



@protocol CTRESTfulCoreDataBackgroundQueue <NSObject>

+ (id<CTRESTfulCoreDataBackgroundQueue>)sharedInstance;

/**
 Sends a get request to a given URL.
 */
- (void)getRequestToURL:(NSURL *)URL
      completionHandler:(void(^)(id JSONObject, NSError *error))completionHandler;

@end
