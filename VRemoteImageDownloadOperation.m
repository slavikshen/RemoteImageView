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
#import <ImageIO/ImageIO.h>

NSString* const VRemoteImageDownloadCompletedNotication = @"VRemoteImageDownloadCompletedNotication";
NSString* const VRemoteImageDownloadFailedNotication = @"VRemoteImageDownloadFailedNotication";


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
        NSString* src = self.refererUrl;
        if( nil == src ) {
            src = self.urlString;
        }
        if( data ) {
            // drop the data if it is not an image
            NSDictionary* exif = nil;
            CGImageSourceRef source = CGImageSourceCreateWithData((CFDataRef)data, NULL);
            if( source ) {
                CFDictionaryRef metadataRef =
                CGImageSourceCopyPropertiesAtIndex ( source, 0, NULL );
                if ( metadataRef ) {
                    NSDictionary* immutableMetadata = (__bridge NSDictionary *)metadataRef;
                    if ( immutableMetadata ) {
                        exif = [NSDictionary dictionaryWithDictionary : immutableMetadata];
                    }
                    CFRelease ( metadataRef );
                }
                
                CFRelease(source);
            }
            
            if( nil == exif ) {
                data = nil;
            }
        }
        
        if( data ) {
            
            // save data to file
            [VRemoteImage saveImage:data forURL:src];
            [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:VRemoteImageDownloadCompletedNotication object:src];
        } else {
            [[NSNotificationCenter defaultCenter]
             postNotificationOnMainThreadWithName:VRemoteImageDownloadFailedNotication
                                           object:src];
        }
    }
    _downloading = NO;
}

@end
