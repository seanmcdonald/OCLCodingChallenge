//
//  GithubJobPosting.h
//  OCLCodingChallenge
//
//  Created by Sean McDonald on 7/21/15.
//  Copyright © 2015 Sean McDonald. All rights reserved.
//

@import Foundation;

@interface GithubJobPosting : NSObject
@property (nonatomic, retain, readonly) NSString *postingId;
@property (nonatomic, retain, readonly) NSString *companyName;
@property (nonatomic, retain, readonly) NSURL *companyLogoUrl;
@property (nonatomic, retain, readonly) NSURL *companyUrl;
@property (nonatomic, retain, readonly) NSString *dateListed;
@property (nonatomic, retain, readonly) NSString *title;
@property (nonatomic, retain, readonly) NSString *positionDescription;
@property (nonatomic, retain, readonly) NSString *location;
@property (nonatomic, retain, readonly) NSString *type;
@property (nonatomic, retain, readonly) NSString *howToApply;
@property (nonatomic, retain, readonly) NSURL *postingUrl;

+ (instancetype) jobPostingWithInformation: (NSDictionary*) jobInformation;
- (instancetype) initJobPostingWithInformation: (NSDictionary*) jobInformation;
@end
