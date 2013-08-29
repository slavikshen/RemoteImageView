//
//  VRemoteImage.h
//  Youplay
//
//  Created by Shen Slavik on 11/6/12.
//  Copyright (c) 2012 apollobrowser.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#if TARGET_OS_IPHONE
#define VRemoteImageSuperClass UIImage
#else
#define VRemoteImageSuperClass NSImage
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
