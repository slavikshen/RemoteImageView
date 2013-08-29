//
//  VRemoteImage.m
//  Youplay
//
//  Created by Shen Slavik on 11/6/12.
//  Copyright (c) 2012 apollobrowser.com. All rights reserved.
//

#import "VRemoteImage.h"
#import "NSString+Extention.h"
#import <ImageIO/ImageIO.h>

NSURL* gThumbImageCacheURL = nil;
NSMutableDictionary* gHostCachePathURLs = nil;
NSDate* gBaselineTime = nil;

@implementation VRemoteImage {

    NSDate* _timestamp;

}

@synthesize timestamp = _timestamp;

+ (NSDate*)baselineTime {
    return gBaselineTime;
}

+ (void)setCachePathURL:(NSURL*)URL {
    gThumbImageCacheURL = URL;
}

+ (NSURL*)cacehPathURL {
    return gThumbImageCacheURL;    
}

+ (void)initialize {

    [super initialize];
    
    gBaselineTime = [NSDate date];
    
    // prepare default cache path
    NSFileManager* fm = [NSFileManager defaultManager];
    NSError* err = nil;
    NSURL* rootURL = [fm URLForDirectory:NSCachesDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:&err];
    NSURL* cachePath = [NSURL URLWithString:@"VThumbImages/" relativeToURL:rootURL];
    
    gHostCachePathURLs = [NSMutableDictionary dictionaryWithCapacity:8];
    
    [self setCachePathURL:cachePath];

}

+ (NSURL*)cachePathURLForHost:(NSString*)host {

    NSURL* url = gHostCachePathURLs[host];
    if( nil == url ) {
        // make a new host url
        
        NSFileManager* fm = [NSFileManager defaultManager];
        NSString* path = [NSString stringWithFormat:@"%@/", host];
        NSURL* cachePath = [NSURL URLWithString:path relativeToURL:gThumbImageCacheURL];
    
        if( ![fm fileExistsAtPath:cachePath.path] ) {
            NSError* err = nil;
            [fm createDirectoryAtURL:cachePath withIntermediateDirectories:YES attributes:nil error:&err];
            #ifdef DEBUG
            if( err ) {
                NSLog(@"Error in creating thumb path: %@", err);
            }
            #endif
        }
    
        gHostCachePathURLs[host] = cachePath;
        
        url = cachePath;        
    }
    
    return url;
    

}

+ (NSURL*)fileURLForURLStr:(NSString*)urlStr {

    NSString* md5 = [urlStr MD5];
    NSURL* url = [NSURL URLWithString:urlStr];
    NSString* host = [url host];
    
    NSURL* cachePath = [self cachePathURLForHost:host];
    
    NSString* fileName = [NSString stringWithFormat:@"thumb_%@.png", md5];
    
    NSURL* fileURL = [NSURL URLWithString:fileName relativeToURL:cachePath];
    
    return fileURL;
    
}

+ (void)saveImage:(NSData*)data forURL:(NSString*)URLStr {
    NSURL* fileURL = [self fileURLForURLStr:URLStr];
    [data writeToURL:fileURL atomically:YES];
}

+ (VRemoteImage*)imageForURL:(NSString*)URLStr {
    NSURL* fileURL = [self fileURLForURLStr:URLStr];
    NSString* path = fileURL.path;
    
    VRemoteImage* image = nil;
    
    NSFileManager* fm = [NSFileManager defaultManager];
    if( [fm fileExistsAtPath:path] ) {
        image = [[VRemoteImage alloc] initWithContentsOfURL:fileURL];
        NSError* err = nil;
        NSDictionary* attrs = [fm attributesOfItemAtPath:path error:&err];
        NSDate* timestamp = attrs[NSFileModificationDate];
        image->_timestamp = timestamp;
    }
    return image;
}

+ (NSData*)imageDataForURL:(NSString*)URLStr {
    NSURL* fileURL = [self fileURLForURLStr:URLStr];
    NSData* data = [NSData dataWithContentsOfURL:fileURL];
    return data;
}


+ (BOOL)cacheExistsForURL:(NSString*)URLStr {

    NSURL* fileURL = [self fileURLForURLStr:URLStr];
    NSFileManager* fm = [NSFileManager defaultManager];
    
    BOOL exists = [fm fileExistsAtPath:fileURL.path];

    return exists;
}

+ (void)clearImageCache {

    NSFileManager* fm = [NSFileManager defaultManager];
    NSError* err = nil;
    NSURL* cachePath = [self cacehPathURL];
    
    [fm removeItemAtURL:cachePath error:&err];
    [fm createDirectoryAtURL:cachePath withIntermediateDirectories:YES attributes:nil error:&err];
    
    gHostCachePathURLs = [NSMutableDictionary dictionaryWithCapacity:8];

}

+ (void)clearExpiredImageCache {


#define MAX_THUMB_CACHE_RESERVED 256

    NSFileManager* fm = [NSFileManager defaultManager];
    NSError* err = nil;
    NSURL* url = [self cacehPathURL];

    NSArray* allFiles = [fm contentsOfDirectoryAtURL:url includingPropertiesForKeys:@[NSURLCreationDateKey] options:0 error:&err];
    
    NSMutableArray* files = [NSMutableArray arrayWithCapacity:allFiles.count];
    for( NSURL* f in allFiles ) {
        NSString* path = [f path];
        if( [path rangeOfString:@"thumb_"].location != NSNotFound ) {
            [files addObject:f];
        }
    }
    
    NSUInteger count = files.count;
    if( count < MAX_THUMB_CACHE_RESERVED ) {
        return;
    }
    
    NSArray* sorted = [files sortedArrayUsingComparator:^NSComparisonResult (NSURL* f1, NSURL* f2) {
        // ascending sort
        NSError* e1 = nil;
        NSDate* d1 = nil;
        [f1 getResourceValue:&d1 forKey:NSURLCreationDateKey error:&e1];
        NSError* e2 = nil;
        NSDate* d2 = nil;
        [f2 getResourceValue:&d2 forKey:NSURLCreationDateKey error:&e2];
        return [d1 compare:d2];
    }];
    
    NSUInteger removeCount = count - MAX_THUMB_CACHE_RESERVED;
    NSRange range = NSMakeRange(0, removeCount);
    
    NSArray* sub = [sorted subarrayWithRange:range];
    
    for( NSURL* f in sub ) {
        NSError* e = nil;
        [fm removeItemAtURL:f error:&e];
    }
    
}

+ (void)clearImageCacheForHost:(NSString*)host {

    [gHostCachePathURLs removeObjectForKey:host];
    NSFileManager* fm = [NSFileManager defaultManager];
    NSString* path = [NSString stringWithFormat:@"%@/", host];
    NSURL* cachePath = [NSURL URLWithString:path relativeToURL:gThumbImageCacheURL];
    
    if( [fm fileExistsAtPath:cachePath.path] ) {
        NSError* err = nil;
        [fm removeItemAtURL:cachePath error:&err];
    }

}

+ (void)clearImageCacheBySizeLimit:(NSUInteger)limit {

    // enum all images under the cache folder
    NSFileManager* fm = [NSFileManager defaultManager];
    NSURL* root = [self cacehPathURL];
    
    NSString *file = nil;
    NSMutableArray* allFiles = [NSMutableArray arrayWithCapacity:1024];

    NSDirectoryEnumerator *dirEnum = [fm enumeratorAtPath:root.path];
    
    NSUInteger total = 0;
    while ((file = [dirEnum nextObject])) {
        if ( [[[file pathComponents] lastObject] hasPrefix:@"thumb_"] ) {
            NSURL* url = [NSURL URLWithString:file relativeToURL:root];
            NSError* err = nil;
            NSDictionary* attrs = [fm attributesOfItemAtPath:url.path error:&err];
            NSUInteger fileSize = [attrs[NSFileSize] unsignedIntegerValue];
            total += fileSize;
            [allFiles addObject:url];
        }
    }
    
    if( total > limit ) {
        // drop old files
        [allFiles sortUsingComparator:^NSComparisonResult(NSURL* url1, NSURL* url2) {
            NSError *err1 = nil, *err2 = nil;
            NSDictionary* a1 = [fm attributesOfItemAtPath:url1.path error:&err1];
            NSDictionary* a2 = [fm attributesOfItemAtPath:url2.path error:&err2];
            NSDate* d1 = a1[NSFileCreationDate];
            NSDate* d2 = a2[NSFileCreationDate];
            return [d1 compare:d2];
        }];
        
//        #if DEBUG
//        
//        for( NSURL* url in allFiles ) {
//            NSError* err = nil;
//            NSDictionary* attrs = [fm attributesOfItemAtPath:url.path error:&err];
//            NSDate* d = attrs[NSFileCreationDate];
//            NSLog(@"%@: %@", [d shortDateAndTimeString], url );
//        }
//        
//        #endif
        
        NSUInteger i = 0;
        while( total > limit && allFiles.count > i ) {
            
            NSError* err = nil;
            NSURL* url = allFiles[i++];
            NSDictionary* attrs = [fm attributesOfItemAtPath:url.path error:&err];
            NSUInteger fileSize = [attrs[NSFileSize] unsignedIntegerValue];
            
            if( [fm removeItemAtURL:url error:&err] ) {
                total -= fileSize;
            }
        }
    }

}

+ (CGSize)sizeOfCachedImage:(NSString*)URLStr {

    CGSize size = CGSizeZero;
    
    if( URLStr ) {

        NSURL* fileURL = [self fileURLForURLStr:URLStr];
        NSDictionary* exif = [self exif:fileURL];
        
        if( exif ) {
        
            NSString* widthStr = [exif objectForKey:(__bridge NSString*)kCGImagePropertyPixelWidth];
            NSString* heightStr = [exif objectForKey:(__bridge NSString*)kCGImagePropertyPixelHeight];
            
            NSInteger width = [widthStr integerValue];
            NSInteger height = [heightStr integerValue];
        
            size = CGSizeMake(width, height);
        }
    }
    
    return size;

}

+ (NSDictionary*) exif : (NSURL*)url {

    NSDictionary* dic   =   nil;  
    
    if ( url ) {  
        CGImageSourceRef source = CGImageSourceCreateWithURL ( (__bridge CFURLRef) url, NULL);
          
        if ( NULL == source ) {
//#ifdef DEBUG
//            CGImageSourceStatus status = CGImageSourceGetStatus ( source );  
//            NSLog ( @"Error: file name : %@ - Status: %d", [url absoluteString], status );
//#endif            
        } else {
            CFDictionaryRef metadataRef = 
            CGImageSourceCopyPropertiesAtIndex ( source, 0, NULL );  
            if ( metadataRef ) {
                NSDictionary* immutableMetadata = (__bridge NSDictionary *)metadataRef;
                if ( immutableMetadata ) {
                    dic = [NSDictionary dictionaryWithDictionary : immutableMetadata];
                }
                CFRelease ( metadataRef );
            }  
              
            CFRelease(source);  
            source = nil;  
        }  
    }  
      
    return dic;  
} 

@end