//
//  BMELoginViewController.m
//  BeMyEyes
//
//  Created by Morten Bøgh on 15/09/12.
//  Copyright (c) 2012 Morten Bøgh. All rights reserved.
//

#import "BMELoginViewController.h"

@interface BMELoginViewController (/*private*/)
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@end

@implementation BMELoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"BackgroundImage"]];
    [self.navigationController setNavigationBarHidden:YES];
    
    [UIView animateWithDuration:0.5 animations:^(void){
        _loginButton.frame = CGRectOffset(_loginButton.frame, 0, -70.f);
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewDidUnload {
    [self setLoginButton:nil];
    [self setLoginButton:nil];
    [super viewDidUnload];
}
@end
