//
//  FBUserProfileImageView.m
//  
//
//  Created by Shen Slavik on 2/1/13.
//  Copyright (c) 2013 Shen Slavik. All rights reserved.
//

#import "FBUserProfileImageView.h"

@interface FBUserProfileImageView()

//#if !TARGET_OS_IPHONE
//+ (NSCache*)globalFBProfileImageCache;
//#endif

@end

@implementation FBUserProfileImageView

//#if !TARGET_OS_IPHONE
//+ (NSCache*)globalFBProfileImageCache {
//    static NSCache* cache = nil;
//    NSAssert([NSThread isMainThread], @"You shall never use the fb profile image cache in none main thread");
//    if( nil == cache ) {
//        cache = [[NSCache alloc] init];
//        [cache setName:@"FBUserProfileImageView_ImageCache"];
//    }
//    return cache;
//}
//#endif

- (void)dealloc {

    [self cancelLoadingUserProfileImage];
    
    #if !__has_feature(objc_arc)
    [super dealloc];
    #endif

}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if( self ) {
        self.updateImageOlderThanBaseline = YES;
    }
    return self;
}

- (id)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if( self ) {
        self.updateImageOlderThanBaseline = YES;
    }
    return self;
}

- (void)setUserID:(NSString *)userID {

    if( [_userID isEqualToString:userID] ) {
        return;
    }
    
    if( _userID ) {
        [self cancelLoadingUserProfileImage];
    }
    
    _userID = userID;
    
    if( userID ) {
        [self startLoadingUserProfileImage];
    }

}

- (void)cancelLoadingUserProfileImage {
    self.src = nil;
}

- (NSString*)_srcPath {
    NSString* userID = self.userID;
    NSString* path = nil;
    
    if( userID ) {
        if( _ignoreSize ) {
            if( [[NSScreen mainScreen] backingScaleFactor] >1 ) {
                path = [NSString stringWithFormat:@"%@/picture?width=128&height=128", userID];
            } else {
                path = [NSString stringWithFormat:@"%@/picture?width=64&height=64", userID];
            }
        } else {
            CGSize size = self.bounds.size;
            NSInteger w = (NSInteger)size.width;
            NSInteger h = (NSInteger)size.height;
            path = [NSString stringWithFormat:@"%@/picture?width=%ld&height=%ld", userID, w, h];
        }
    }
    return path;
}

- (void)startLoadingUserProfileImage {
    
    NSString* path = [self _srcPath];
    if( path ) {
        NSString* ogurl = [NSString stringWithFormat:@"https://graph.facebook.com/%@", path];
        self.src = ogurl;
    }

}

- (void)drawRect:(NSRect)dirtyRect
{
    CGFloat cr = self.cornerRadius;
    if( cr>=1.0f ) {
        CGRect bounds = self.bounds;
        NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:bounds xRadius:cr yRadius:cr];
        [path setLineWidth:0];
        [path addClip];
    }

    [super drawRect:dirtyRect];
}

+ (VRemoteImage*)localCacheImageForUser:(NSString*)userID {
    NSString* path = nil;
    VRemoteImage* img = nil;
    path = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?width=128&height=128", userID];
    img = [VRemoteImage imageForURL:path];
    if( nil == img ) {
        path = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?width=64&height=64", userID];
        img = [VRemoteImage imageForURL:path];
    }
    return img;
}

@end
