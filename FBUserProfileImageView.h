//
//  FBUserProfileImageView.h
//  
//
//  Created by Shen Slavik on 2/1/13.
//  Copyright (c) 2013 Shen Slavik. All rights reserved.
//

#import "VUIRemoteImageView.h"

@interface FBUserProfileImageView : VUIRemoteImageView

@property(nonatomic,copy) NSString* userID;
@property(nonatomic,assign) CGFloat cornerRadius;
@property(nonatomic,assign) BOOL ignoreSize;


- (void)cancelLoadingUserProfileImage;
- (void)startLoadingUserProfileImage;

+ (VRemoteImage*)localCacheImageForUser:(NSString*)userID;

@end
