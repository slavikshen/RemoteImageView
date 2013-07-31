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

@implementation VRemoteImage


+ (void)setCachePathURL:(NSURL*)URL {
    gThumbImageCacheURL = URL;
}

+ (NSURL*)cacehPathURL {
    return gThumbImageCacheURL;    
}

+ (void)initialize {

    [super initialize];
    
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
    NSData* data = [self imageDataForURL:URLStr];
    VRemoteImage* image = ( data ? [[VRemoteImage alloc] initWithData:data] : nil );
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