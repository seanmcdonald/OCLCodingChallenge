//
//  GithubJobPosting.m
//  OCLCodingChallenge
//
//  Created by Sean McDonald on 7/21/15.
//  Copyright © 2015 Sean McDonald. All rights reserved.
//

#import "GithubJobPosting.h"

@implementation GithubJobPosting

+ (instancetype) jobPostingWithInformation: (NSDictionary*) jobInformation
{
    return [[self alloc] initJobPostingWithInformation:jobInformation];
}

- (instancetype) init
{
    return [self initJobPostingWithInformation:@{}];
}

- (instancetype) initJobPostingWithInformation: (NSDictionary*) jobInformation
{
    if (self = [super init])
    {
        _postingId = jobInformation[@"id"];
        _companyName = jobInformation[@"company"];
        if (![jobInformation[@"company_logo"] isEqual:[NSNull null]])
            _companyLogoUrl = [NSURL URLWithString:jobInformation[@"company_logo"]];
        if (![jobInformation[@"company_url"] isEqual:[NSNull null]])
            _companyUrl = [NSURL URLWithString:jobInformation[@"company_url"]];
        _dateListed = jobInformation[@"created_at"];
        _title = jobInformation[@"title"];
        _positionDescription = jobInformation[@"description"];
        _location = jobInformation[@"location"];
        _type = jobInformation[@"type"];
        _howToApply = jobInformation[@"how_to_apply"];
        _postingUrl = [NSURL URLWithString:jobInformation[@"url"]];
        return self;
    }
    return nil;
}
@end
