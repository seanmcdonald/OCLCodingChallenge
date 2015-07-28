//
//  DetailViewController.m
//  OCLCodingChallenge
//
//  Created by Sean McDonald on 7/23/15.
//  Copyright © 2015 Sean McDonald. All rights reserved.
//

#import "DetailViewController.h"
#import "GithubJobPosting.h"

@interface DetailViewController()
@property (weak, nonatomic) IBOutlet UILabel *companyNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *jobTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *jobTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *listedDateLabel;
@property (weak, nonatomic) IBOutlet UIWebView *jobDescriptionWebView;
@end

@implementation DetailViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"Job Posting";
    self.navigationItem.prompt = @"Github";
    
    self.companyNameLabel.text = self.jobPosting.companyName;
    self.jobTitleLabel.text = self.jobPosting.title;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Website" style:UIBarButtonItemStylePlain target:self action:@selector(onCompanyWebsiteButtonPressed)];
    self.jobTypeLabel.text = [NSString stringWithFormat:@"Type: %@", self.jobPosting.type];
    self.listedDateLabel.text = [NSString stringWithFormat:@"Created: %@", self.jobPosting.dateListed];
    [self.jobDescriptionWebView loadHTMLString:[self.jobPosting.positionDescription stringByAppendingString:self.jobPosting.howToApply] baseURL:nil];
}

- (void) onCompanyWebsiteButtonPressed
{
    [[UIApplication sharedApplication] openURL:self.jobPosting.companyUrl];
}
@end
