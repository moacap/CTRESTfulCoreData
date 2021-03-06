//
//  CTRESTfulCoreDataBackgroundQueue.h
//  CTRESTfulCoreData
//
//  Created by Oliver Letterer on 29.02.12.
//  Copyright (c) 2012 ebf. All rights reserved.
//



@protocol CTRESTfulCoreDataBackgroundQueue <NSObject>

+ (id<CTRESTfulCoreDataBackgroundQueue>)sharedQueue;

/**
 Sends a get request to a given URL.
 */
- (void)getRequestToURL:(NSURL *)URL
      completionHandler:(void(^)(id JSONObject, NSError *error))completionHandler;

- (void)deleteRequestToURL:(NSURL *)URL
         completionHandler:(void(^)(NSError *error))completionHandler;

- (void)postJSONObject:(id)JSONObject
                 toURL:(NSURL *)URL
     completionHandler:(void(^)(id JSONObject, NSError *error))completionHandler;

- (void)putJSONObject:(id)JSONObject
                toURL:(NSURL *)URL
    completionHandler:(void(^)(id JSONObject, NSError *error))completionHandler;

@end
