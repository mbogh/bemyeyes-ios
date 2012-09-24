//
//  BMESignUpViewController.m
//  BeMyEyes
//
//  Created by Morten Bøgh on 15/09/12.
//  Copyright (c) 2012 Morten Bøgh. All rights reserved.
//

#import "BMESignUpViewController.h"

@interface BMESignUpViewController ()

@end

@implementation BMESignUpViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"BackgroundImage"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Actions

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (IBAction)blindButtonTouchUpInside:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setInteger:BMEUserTypeBlind forKey:kBMEUserType];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)helperButtonTouchUpInside:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setInteger:BMEUserTypeHelper forKey:kBMEUserType];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self dismissModalViewControllerAnimated:YES];
}
@end
