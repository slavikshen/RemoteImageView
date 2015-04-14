//
//  VRemoteImageDownloadOperation.h
//  Youplay
//
//  Created by Shen Slavik on 11/6/12.
//  Copyright (c) 2012 apollobrowser.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef UIKIT_EXTERN
UIKIT_EXTERN NSString* const VRemoteImageDownloadCompletedNotication;
UIKIT_EXTERN NSString* const VRemoteImageDownloadFailedNotication;
#else
APPKIT_EXTERN NSString* const VRemoteImageDownloadCompletedNotication;
APPKIT_EXTERN NSString* const VRemoteImageDownloadFailedNotication;
#endif

@interface VRemoteImageDownloadOperation : NSOperation

@property(nonatomic, copy) NSString * urlString;
@property(nonatomic, copy) NSString * refererUrl;

@property(nonatomic, assign) NSUInteger requestCount;

@end
