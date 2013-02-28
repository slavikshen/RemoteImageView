//
//  VRemoteImageDownloadOperation.m
//  Youplay
//
//  Created by Shen Slavik on 11/6/12.
//  Copyright (c) 2012 apollobrowser.com. All rights reserved.
//

#import "VRemoteImageDownloadOperation.h"
#import "NSNotification+Additions.h"
#import "VRemoteImage.h"

NSString* const VRemoteImageDownloadCompletedNotication = @"VRemoteImageDownloadCompletedNotication";

@implementation VRemoteImageDownloadOperation {
    BOOL _downloading;
}

- (BOOL)isExecuting {
    return _downloading;
}

- (void)cancel {
    [super cancel];
    self.urlString = nil;
}

- (void)main {

    if( [self isCancelled] ) {
        return;
    }
    NSString* urlStr = self.urlString;
    if( nil == urlStr ) {
        return;
    }
    _downloading = YES;
    NSURL* url = [[NSURL alloc] initWithString:urlStr];
    if( url ) {
        NSData* data = [[NSData alloc] initWithContentsOfURL:url];
        if( data ) {
            // save data to file
            if (self.refererUrl == nil) {
                [VRemoteImage saveImage:data forURL:urlStr];
                [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:VRemoteImageDownloadCompletedNotication object:urlStr];
            } else {
                [VRemoteImage saveImage:data forURL:self.refererUrl];
                [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:VRemoteImageDownloadCompletedNotication object:self.refererUrl];
            }
        }
    }
    _downloading = NO;
}

@end
