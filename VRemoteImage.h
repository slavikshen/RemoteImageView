//
//  VRemoteImage.h
//  Youplay
//
//  Created by Shen Slavik on 11/6/12.
//  Copyright (c) 2012 apollobrowser.com. All rights reserved.
//



#if TARGET_OS_IPHONE
    #import <UIKit/UIKit.h>
    #import "UIRoundCornerImageView.h"
    #define VRemoteImageSuperClass UIImage
    #define VRemoteImageViewSuperClass UIImageView
#else
    #import <Cocoa/Cocoa.h>
    #define VRemoteImageSuperClass NSImage
    #define VRemoteImageViewSuperClass NSImageView
#endif

@interface VRemoteImage : VRemoteImageSuperClass

@property (nonatomic,readonly) NSDate* timestamp;

+ (void)setCachePathURL:(NSURL*)URL;
+ (NSURL*)cacehPathURL;
+ (NSURL*)fileURLForURLStr:(NSString*)urlStr;

+ (void)saveImage:(NSData*)data forURL:(NSString*)URLStr;

+ (VRemoteImage*)imageForURL:(NSString*)URLStr;
+ (NSData*)imageDataForURL:(NSString*)URLStr;
+ (BOOL)cacheExistsForURL:(NSString*)URLStr;

+ (void)clearImageCache;
+ (void)clearExpiredImageCache;
+ (void)clearImageCacheForHost:(NSString*)host;
+ (void)clearImageCacheBySizeLimit:(NSUInteger)limit;

+ (CGSize)sizeOfCachedImage:(NSString*)URLStr;

+ (NSDate*)baselineTime;

@end
