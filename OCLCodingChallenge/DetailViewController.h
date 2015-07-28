//
//  DetailViewController.h
//  OCLCodingChallenge
//
//  Created by Sean McDonald on 7/23/15.
//  Copyright © 2015 Sean McDonald. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GithubJobPosting;

@interface DetailViewController : UIViewController
@property (nonatomic, retain) GithubJobPosting *jobPosting;
@end
