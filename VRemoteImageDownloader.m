//
//  VRemoteImageDownloader.m
//  Youplay
//
//  Created by Shen Slavik on 11/6/12.
//  Copyright (c) 2012 apollobrowser.com. All rights reserved.
//

#import "VRemoteImageDownloader.h"

@implementation VRemoteImageDownloader

@dynamic maxConcurrentDownload;

- (void)dealloc {
    [_queue cancelAllOperations];
    #if !__has_feature(objc_arc)
    [super dealloc];
    #endif
}

- (void)_setup {
    NSOperationQueue* queue = [NSOperationQueue new];
    self.queue = queue;
    self.maxConcurrentDownload = 3;
}

- (id)init {
    self = [super init];
    [self _setup];
    return self;
}

+ (VRemoteImageDownloader*)sharedInstance {

    static VRemoteImageDownloader* inst = nil;
    @synchronized(self) {
        if( nil == inst ) {
            inst = [VRemoteImageDownloader new];
        }
    }
    return inst;

}

- (NSInteger)maxConcurrentDownload {
    return _queue.maxConcurrentOperationCount;
}

- (void)setMaxConcurrentDownload:(NSInteger)max {
    _queue.maxConcurrentOperationCount = max;
}

- (void)downloadImageForURL:(NSString*)urlStr; {

#if DEBUG
    NSLog(@"downloadImageForURL: %@", urlStr);
#endif
    
    NSArray* operations = _queue.operations;
    VRemoteImageDownloadOperation* oper = nil;
    for( VRemoteImageDownloadOperation* op in operations ) {
        if( [op.urlString isEqualToString:urlStr] ) {
            oper = op;
            break;
        }
    }
    
    if( nil == oper ) {
        oper = [VRemoteImageDownloadOperation new];
        oper.urlString = urlStr;
        [_queue addOperation:oper];
    }
    
    // increase request count
    oper.requestCount = oper.requestCount +1;

}

- (void)cancelDownloadImageForURL:(NSString*)urlStr {
    NSArray* operations = _queue.operations;
    for( VRemoteImageDownloadOperation* op in operations ) {
        if( [op.urlString isEqualToString:urlStr] ) {
            NSUInteger requestCount = op.requestCount;
            if( requestCount > 0 ) {
                op.requestCount = --requestCount;
            }
            if( 0 == requestCount && !op.isExecuting ) {
                [op cancel];
            }
            break;
        }
    }
}
@end
