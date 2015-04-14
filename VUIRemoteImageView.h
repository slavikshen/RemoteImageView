//
//  VUIRemoteImageView.h
//  Youplay
//
//  Created by Shen Slavik on 12/4/12.
//  Copyright (c) 2012 apollobrowser.com. All rights reserved.
//


#import "VRemoteImage.h"
#import "VRemoteImageDownloader.h"

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
@property(nonatomic,assign) BOOL keepImageOfOldSrc;

- (void)didReceiveImage:(VRemoteImage*)image;

- (VRemoteImageSuperClass*)defaultImage;

- (void)setup;
- (void)imageRequestDidFail;

@end
