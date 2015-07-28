//
//  MainViewController.m
//  OCLCodingChallenge
//
//  Created by Sean McDonald on 7/22/15.
//  Copyright © 2015 Sean McDonald. All rights reserved.
//

#import "MainViewController.h"

#import "GithubJobRequest.h"
#import "DetailViewController.h"

#define kGithubJobPostingCellIdentifier @"GithubJobPostingCell"

@interface MainViewController()<GithubJobRequestDelegate, UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation MainViewController
{
    NSArray *results;
    NSCache *imageCache;
    GithubJobPosting *selectedJobPosting;
    BOOL isFetchingResults;
    
    NSString *filterJobDescription;
    NSString *filterJobLocation;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"Job Postings";
    self.navigationItem.prompt = @"Github";
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    results = [NSArray array];
    isFetchingResults = false;
    imageCache = [[NSCache alloc] init];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshResults:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButton;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Filter" style:UIBarButtonItemStylePlain target:self action:@selector(onFilterButtonPressed)];
    
    [self performSelector:@selector(refreshResults:) withObject:nil afterDelay:1];
}

- (void) viewDidAppear: (BOOL) animated
{
    [super viewDidAppear:animated];
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:true];
}

- (void) prepareForSegue: (nonnull UIStoryboardSegue*) segue sender: (nullable id) sender
{
    NSString *segueIdentifier = [segue identifier];
    if ([segueIdentifier isEqualToString:@"DetailViewController"])
    {
        DetailViewController *detailViewController = [segue destinationViewController];
        detailViewController.jobPosting = selectedJobPosting;
    }
}

- (void) onFilterButtonPressed
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Filter" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * __nonnull textField) {
        textField.placeholder = @"Job Description (Default is PHP)";
        textField.autocorrectionType = UITextAutocorrectionTypeYes;
        if (filterJobDescription)
            textField.text = filterJobDescription;
    }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * __nonnull textField) {
        textField.placeholder = @"Location (Default is San Francisco, CA)";
        textField.autocorrectionType = UITextAutocorrectionTypeYes;
        if (filterJobLocation)
            textField.text = filterJobLocation;
    }];
    
    void (^applyHandler)(UIAlertAction * __nonnull action);
    
    applyHandler = ^(UIAlertAction * __nonnull action)
    {
        filterJobDescription = [alertController.textFields objectAtIndex:0].text;
        filterJobLocation = [alertController.textFields objectAtIndex:1].text;
        [self refreshResults:nil];
    };
    
    void (^clearHandler)(UIAlertAction * __nonnull action);
    
    clearHandler = ^(UIAlertAction * __nonnull action)
    {
        filterJobDescription = nil;
        filterJobLocation = nil;
        [self refreshResults:nil];
    };
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Apply" style:UIAlertActionStyleDefault handler:applyHandler]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Clear" style:UIAlertActionStyleDestructive handler:clearHandler]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:alertController animated:true completion:nil];
}

- (void) refreshResults: (UIRefreshControl*) refreshControl
{
    if (refreshControl)
        [refreshControl endRefreshing];
    
    if (isFetchingResults)
    {
        NSLog(@"%@ Already fetching job results...", self);
        return;
    }
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = true;
    
    NSMutableDictionary *requestProperties = [[NSMutableDictionary alloc] init];
    [requestProperties setObject:(filterJobDescription ? filterJobDescription : @"") forKey:@"description"];
    [requestProperties setObject:(filterJobLocation ? filterJobLocation : @"") forKey:@"location"];
    
    GithubJobRequest *request = [GithubJobRequest requestWithProperties:requestProperties];
    request.delegate = self;
    request.isFullTime = true;
    [request send];
    
    isFetchingResults = true;
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Searching..." message:nil preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:alertController animated:true completion:nil];
    
    NSLog(@"%@ Refreshing job results!", self);
}

#pragma mark - GithubJobRequestDelegate

- (void) jobRequestFinished: (GithubJobRequest*) request
{
    isFetchingResults = false;
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = false;
        [self.presentedViewController dismissViewControllerAnimated:true completion:^{
            [self.tableView reloadData];
        }];
    });
}

- (void) jobRequest: (GithubJobRequest*) request withError: (NSError*) error
{
    NSLog(@"%@ An error occured on job request fetch: %@:%@", self, error.localizedDescription, error.localizedFailureReason);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Unable to fetch job positions" message:@"Make sure airplane mode is not turned on or that you are conencted to an internet enabled network." preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController:alertController animated:true completion:nil];
    });
}

- (void) jobRequest: (GithubJobRequest*) request withResults: (NSArray*) newResults
{
    NSLog(@"%@ Job results recieved!", self);
    results = newResults;
    
    if (results.count == 0)
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"No job postings were found for %@ in %@!", filterJobDescription, filterJobLocation] message:@"Try another description/location." preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
            [self presentViewController:alert animated:true completion:nil];
        });
    }
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger) numberOfSectionsInTableView: (nonnull UITableView*) tableView
{
    return 1;
}

- (NSInteger) tableView: (nonnull UITableView*) tableView numberOfRowsInSection: (NSInteger) section
{
    return results.count;
}

- (NSIndexPath*) tableView: (nonnull UITableView*) tableView willSelectRowAtIndexPath: (nonnull NSIndexPath*) indexPath
{
    GithubJobPosting *jobPosting = [results objectAtIndex:indexPath.row];
    selectedJobPosting = jobPosting;
    return indexPath;
}

- (UITableViewCell*) tableView: (nonnull UITableView*) tableView cellForRowAtIndexPath: (nonnull NSIndexPath*) indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kGithubJobPostingCellIdentifier];
    GithubJobPosting *jobPosting = [results objectAtIndex:indexPath.row];
    cell.textLabel.text = jobPosting.companyName;
    cell.detailTextLabel.text = jobPosting.title;
    cell.imageView.image = [UIImage imageNamed:@"github_logo.png"];
    if (jobPosting.companyLogoUrl)
    {
        UIImage *companyLogo = [imageCache objectForKey:jobPosting.companyLogoUrl.absoluteString];
        if (companyLogo)
        {
            cell.imageView.image = companyLogo;
        }
        else
        {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSData *imageData = [NSData dataWithContentsOfURL:jobPosting.companyLogoUrl];
                if (imageData)
                {
                    UIImage *image = [UIImage imageWithData:imageData scale:2.0];
                    if (image)
                    {
                        [imageCache setObject:image forKey:jobPosting.companyLogoUrl.absoluteString];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            UITableViewCell *cellToUpdate = [tableView cellForRowAtIndexPath:indexPath];
                            if (cellToUpdate)
                            {
                                cellToUpdate.imageView.image = image;
                                [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                            }
                        });
                    }
                }
            });
        }
    }
    return cell;
}
@end
