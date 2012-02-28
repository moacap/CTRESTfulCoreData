//
//  NSString+CTCoreDataAPI.h
//  CTCoreDataAPI
//
//  Created by Oliver Letterer on 24.02.12.
//  Copyright (c) 2012 ebf. All rights reserved.
//



@interface NSString (CTRESTfulCoreData)

@property (nonatomic, readonly) NSDate *CTRESTfulCoreDataDateRepresentation;
@property (nonatomic, readonly) NSString *stringByCamelizingString;
@property (nonatomic, readonly) NSString *stringByUnderscoringString;

@end
