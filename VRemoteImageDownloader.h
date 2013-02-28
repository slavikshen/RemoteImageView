//
//  VRemoteImageDownloader.h
//  Youplay
//
//  Created by Shen Slavik on 11/6/12.
//  Copyright (c) 2012 apollobrowser.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VRemoteImageDownloadOperation.h"

@interface VRemoteImageDownloader : NSObject

@property(nonatomic,assign) NSInteger maxConcurrentDownload;

+ (VRemoteImageDownloader*)sharedInstance;

- (void)downloadImageForURL:(NSString*)urlStr;
- (void)cancelDownloadImageForURL:(NSString*)urlStr;

@property(nonatomic,retain) NSOperationQueue* queue;

@end
