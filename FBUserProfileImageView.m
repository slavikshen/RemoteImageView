//
//  FBUserProfileImageView.m
//  
//
//  Created by Shen Slavik on 2/1/13.
//  Copyright (c) 2013 Shen Slavik. All rights reserved.
//

#import "FBUserProfileImageView.h"

@interface FBUserProfileImageView()

@end

@implementation FBUserProfileImageView

- (void)dealloc {

    [self cancelLoadingUserProfileImage];
    
    #if !__has_feature(objc_arc)
    [super dealloc];
    #endif

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
            path = [NSString stringWithFormat:@"%@/picture", userID];
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
    NSImage* img = ( path ? [NSImage imageNamed:path] : nil );
    if( img ) {
        self.image = img;
    } else {
        NSString* ogurl = [NSString stringWithFormat:@"https://graph.facebook.com/%@", path];
        self.src = ogurl;
    }

}

-(void)didReceiveImage:(VRemoteImage*)image {
    
    [super didReceiveImage:image];
    
    NSString* path = [self _srcPath];
    [image setName:path];

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



@end
