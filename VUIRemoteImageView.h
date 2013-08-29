//
//  VUIRemoteImageView.h
//  Youplay
//
//  Created by Shen Slavik on 12/4/12.
//  Copyright (c) 2012 apollobrowser.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "VRemoteImage.h"
#import "VRemoteImageDownloader.h"

#if TARGET_OS_IPHONE
#define VRemoteImageViewSuperClass UIImageView
#else
#define VRemoteImageViewSuperClass NSImageView
#endif


@class VUIRemoteImageView;

@protocol ThumbImageViewDelegate <NSObject>

@optional
- (void)thumbImageViewDidReceiveRemoteImage:(VUIRemoteImageView*)thumbImageView;

@end


@interface VUIRemoteImageView : VRemoteImageViewSuperClass

@property(nonatomic,copy) NSString* src;
@property(nonatomic,assign) id<ThumbImageViewDelegate> delegate;
@property(nonatomic,readonly,assign) BOOL isLoading;
@property(nonatomic,assign) BOOL updateImageOlderThanBaseline;

- (void)didReceiveImage:(VRemoteImage*)image;

- (VRemoteImageSuperClass*)defaultImage;

- (void)setup;

@end
