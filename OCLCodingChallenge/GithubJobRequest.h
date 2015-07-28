//
//  GithubJobRequest.h
//  OCLCodingChallenge
//
//  Created by Sean McDonald on 7/21/15.
//  Copyright © 2015 Sean McDonald. All rights reserved.
//

@import Foundation;

#import "GithubJobPosting.h"

@class GithubJobRequest;

@protocol GithubJobRequestDelegate
@required
- (void) jobRequest: (GithubJobRequest*) request withError: (NSError*) error;
- (void) jobRequest: (GithubJobRequest*) request withResults: (NSArray*) results;
@optional
- (void) jobRequestFinished: (GithubJobRequest*) request;
@end

@interface GithubJobRequest : NSObject
@property (nonatomic, weak) NSObject<GithubJobRequestDelegate> *delegate;
@property (nonatomic, retain) NSString *jobDescription;
@property (nonatomic, retain) NSString *location;
@property (nonatomic) float longitude, latitude;
@property (nonatomic) BOOL isFullTime;
+ (instancetype) requestWithProperties: (NSDictionary*) properties;
- (instancetype) initRequestWithProperties: (NSDictionary*) properties;
- (NSURL*) queryUrl;
- (void) send;
@end
