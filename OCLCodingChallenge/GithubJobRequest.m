//
//  GithubJobRequest.m
//  OCLCodingChallenge
//
//  Created by Sean McDonald on 7/21/15.
//  Copyright © 2015 Sean McDonald. All rights reserved.
//

#import "GithubJobRequest.h"

@implementation GithubJobRequest

+ (instancetype) requestWithProperties: (NSDictionary*) properties
{
    return [[self alloc] initRequestWithProperties:properties];
}

- (instancetype) init
{
    if (self = [super init])
    {
        _jobDescription = @"";
        _location = @"";
        _isFullTime = false;
        return self;
    }
    return nil;
}

- (instancetype) initRequestWithProperties: (NSDictionary*) properties
{
    if (self = [self init])
    {
        _jobDescription = properties[@"description"];
        _location = properties[@"location"];
        _latitude = [properties[@"latitude"] floatValue];
        _longitude = [properties[@"longitude"] floatValue];
        _isFullTime = [properties[@"isFullTime"] boolValue];
        
        if (!_jobDescription || _jobDescription.length == 0)
            _jobDescription = @"php";
        if (!_location || _jobDescription.length == 0)
            _location = @"San Francisco, CA";
        
        return self;
    }
    return nil;
}

- (NSURL*) queryUrl
{
    return [NSURL URLWithString:[NSString stringWithFormat:@"https://jobs.github.com/positions.json?description=%@&location=%@&latitude=%f&longitude=%f&full_time=%@", self.jobDescription, self.location, self.latitude, self.longitude, (self.isFullTime ? @"true" : @"false")]];
}

- (void) send
{
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:[self queryUrl] completionHandler:^(NSData * __nullable data, NSURLResponse * __nullable response, NSError * __nullable error) {
        if (data && !error)
        {
            NSError *jsonParseError = nil;
            NSArray *jsonJobPostingsArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParseError];
            if (jsonJobPostingsArray && !jsonParseError)
            {
                NSMutableArray *jobPostingsArray = [NSMutableArray array];
                
                for (int index = 0; index < jsonJobPostingsArray.count; index++)
                {
                    NSDictionary *jsonJobPosting = [jsonJobPostingsArray objectAtIndex:index];
                    GithubJobPosting *jobPosting = [GithubJobPosting jobPostingWithInformation:jsonJobPosting];
                    [jobPostingsArray addObject:jobPosting];
                }

                if ([self.delegate respondsToSelector:@selector(jobRequest:withResults:)])
                {
                    [self.delegate jobRequest:self withResults:jobPostingsArray];
                }
            }
            else
            {
               if ([self.delegate respondsToSelector:@selector(jobRequest:withError:)])
               {
                   [self.delegate jobRequest:self withError:jsonParseError];
               }
            }
        }
        else if (error)
        {
            if ([self.delegate respondsToSelector:@selector(jobRequest:withError:)])
            {
                [self.delegate jobRequest:self withError:error];
            }
        }
        
        if ([self.delegate respondsToSelector:@selector(jobRequestFinished:)])
        {
            [self.delegate jobRequestFinished:self];
        }
    }];
    [dataTask resume];
}
@end
