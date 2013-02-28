//
//  VRemoteImageDownloadOperation.h
//  Youplay
//
//  Created by Shen Slavik on 11/6/12.
//  Copyright (c) 2012 apollobrowser.com. All rights reserved.
//

#import <Foundation/Foundation.h>

APPKIT_EXTERN NSString* const VRemoteImageDownloadCompletedNotication;

@interface VRemoteImageDownloadOperation : NSOperation

@property(nonatomic, copy) NSString * urlString;
@property(nonatomic, copy) NSString * refererUrl;

@property(nonatomic, assign) NSUInteger requestCount;

@end
