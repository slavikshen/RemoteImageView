//
//  VUIRemoteImageView.m
//  Youplay
//
//  Created by Shen Slavik on 12/4/12.
//  Copyright (c) 2012 apollobrowser.com. All rights reserved.
//

#import "VUIRemoteImageView.h"

static dispatch_queue_t gThumbImageViewDecodeQueue;

@interface VUIRemoteImageView()

@property(nonatomic,readwrite,assign) BOOL isLoading;

@end

@implementation VUIRemoteImageView {

    BOOL _shouldNotifiyRemoteImageReceived;

}

+ (void)initialize {
    [super initialize];
    gThumbImageViewDecodeQueue = dispatch_queue_create("thumb_image_decode_queue", 0);
}

- (id)initWithFrame:(NSRect)frameRect {

    self = [super initWithFrame:frameRect];
    [self setup];
    return self;

}

- (id)initWithCoder:(NSCoder *)aDecoder {

    self = [super initWithCoder:aDecoder];
    [self setup];
    return self;

}

- (void)setup {

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_thumbDownloadCompleted:) name:VRemoteImageDownloadCompletedNotication object:nil];

}

-(void)dealloc {

    // cancel request
    self.src = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:VRemoteImageDownloadCompletedNotication object:nil];
    
    #if !__has_feature(objc_arc)
    [super dealloc];
    #endif

}

- (void)setDelegate:(id<ThumbImageViewDelegate>)delegate {

    _delegate = delegate;
    _shouldNotifiyRemoteImageReceived = [delegate respondsToSelector:@selector(thumbImageViewDidReceiveRemoteImage:)];

}

//- (void)_loadImageInBackground {
//    if( 0 == _thumbURLStr.length ) {
//        return;
//    }
//    ThumbImage* image = [ThumbImage thumbForURL:_thumbURLStr];
//    [self performSelectorOnMainThread:@selector(_loadImage:) withObject:image waitUntilDone:NO];
//}
//
//- (void)_loadImage:(NSImage*)image {
//    if( 0 == _thumbURLStr.length ) {
//        return;
//    }
//    if( image ) {
//        self.image = image;
//    } else {
//        [[ThumbDownloader sharedInstance] downloadThumbForURL:_thumbURLStr];
//    }
//}

- (void)_thumbDownloadCompleted:(NSNotification*)n {
    
    if( 0 == _src.length ) {
        return;
    }
    NSString* urlStr = n.object;
    if( [_src isEqualToString:urlStr] ) {
        if( _isLoading ) {
            self.isLoading = NO;
        }
        VRemoteImage* image = [VRemoteImage imageForURL:_src];
        if( image ) {
            [self didReceiveImage:image];
        }
    }
}

- (void)didReceiveImage:(VRemoteImage*)image {
    self.image = image;
    if( _shouldNotifiyRemoteImageReceived ) {
        [_delegate thumbImageViewDidReceiveRemoteImage:self];
    }
}

- (void)setSrc:(NSString *)thumbURLStr {

    if( [_src isEqualToString:thumbURLStr] ) {
        return;
    }

    if( _src.length ) {
        // cancel previous loading request
        [[VRemoteImageDownloader sharedInstance] cancelDownloadImageForURL:_src];
    }
    
    if( _isLoading ) {
        self.isLoading = NO;
    }

    _src = [thumbURLStr copy];
    
    if( _src.length ) {
        
        //取消之前的请求
        //请求图片

        VRemoteImage* image = [VRemoteImage imageForURL:_src];
        if( image ) {
            self.image = image;
        } else {
            self.isLoading = YES;
            self.image = [self defaultImage];
            [[VRemoteImageDownloader sharedInstance] downloadImageForURL:_src];
        }
        
    }

}


- (VRemoteImageSuperClass*)defaultImage {
    return nil;
}

@end
