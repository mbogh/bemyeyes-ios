//
//  BMEViewController.m
//  BeMyEyes
//
//  Created by Morten Bøgh on 15/09/12.
//  Copyright (c) 2012 Morten Bøgh. All rights reserved.
//

#import "BMEViewController.h"
#import <OpenTok/Opentok.h>

@interface BMEViewController () <OTPublisherDelegate, OTSessionDelegate, OTSubscriberDelegate>
@property (weak, nonatomic) IBOutlet UIView *videoPlaceholderView;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UIButton *disconnectButton;
@property (strong) OTSession *session;
@property (strong) OTPublisher *publisher;
@property (strong) OTSubscriber *subscriber;
@property (assign) BMEUserType userType;
@end

@implementation BMEViewController
@synthesize titleLabel = _titleLabel;
@synthesize videoPlaceholderView;
@synthesize startButton;
@synthesize disconnectButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.videoPlaceholderView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"BackgroundImage"]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.userType = [[NSUserDefaults standardUserDefaults] integerForKey:kBMEUserType];
    [self.disconnectButton setTitle:@"Disconnect" forState:UIControlStateNormal];
    [self.startButton setTitle:self.userType == BMEUserTypeBlind ? @"Yes, I'm blind!" : @"Let me help!" forState:UIControlStateNormal];
    
    self.titleLabel.text = self.userType == BMEUserTypeBlind ? @"Do you need help?" : @"Thank you - we appreciate you help!";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)updateSubscriber
{
    for (NSString* streamId in _session.streams) {
        OTStream* stream = [_session.streams valueForKey:streamId];
        if (stream.connection.connectionId != _session.connection.connectionId) {
            self.subscriber = [[OTSubscriber alloc] initWithStream:stream delegate:self];
            break;
        }
    }
}

#pragma mark - Actions

- (IBAction)disconnectAction:(id)sender
{
    [self doDisconnect];
}

- (IBAction)startAction:(id)sender
{
    [self doConnect];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    UIViewController *connectingViewController = [storyboard instantiateViewControllerWithIdentifier:@"BMEConnectingViewController"];
    connectingViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:connectingViewController animated:YES];
}

#pragma mark - OpenTok methods

- (void)doConnect
{
    self.session = [[OTSession alloc] initWithSessionId:kSessionId delegate:self];
    [self.session connectWithApiKey:kApiKey token:kToken];
}

- (void)doDisconnect
{
    [self.session disconnect];
}

- (void)doPublish
{
    self.publisher = [[OTPublisher alloc] initWithDelegate:self name:UIDevice.currentDevice.name];
    self.publisher.publishAudio = YES;
    self.publisher.publishVideo = self.userType == BMEUserTypeBlind ? YES : NO;
    self.publisher.cameraPosition = AVCaptureDevicePositionBack;
    [self.session publish:self.publisher];
    if (self.userType == BMEUserTypeBlind) {
        [self.publisher.view setFrame:self.videoPlaceholderView.frame];
        [self.view insertSubview:self.publisher.view aboveSubview:self.videoPlaceholderView];
    }
}

#pragma mark - OTSessionDelegate methods

- (void)sessionDidConnect:(OTSession*)session
{    
    NSLog(@"sessionDidConnect: %@", session.sessionId);
    NSLog(@"- connectionId: %@", session.connection.connectionId);
    NSLog(@"- creationTime: %@", session.connection.creationTime);
    [self doPublish];
}

- (void)sessionDidDisconnect:(OTSession*)session 
{
    NSLog(@"sessionDidDisconnect: %@", session.sessionId);
    [self dismissModalViewControllerAnimated:YES];
    self.disconnectButton.hidden = YES;
    self.startButton.hidden = NO;
}

- (void)session:(OTSession*)session didFailWithError:(OTError*)error
{
    [self dismissModalViewControllerAnimated:YES];
    self.disconnectButton.hidden = YES;
    self.startButton.hidden = NO;
    
    NSLog(@"session: didFailWithError:");
    NSLog(@"- error code: %d", error.code);
    NSLog(@"- description: %@", error.localizedDescription);
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alert show];
}

- (void)session:(OTSession*)mySession didReceiveStream:(OTStream*)stream
{
    NSLog(@"session: didReceiveStream:");
    NSLog(@"- connection.connectionId: %@", stream.connection.connectionId);
    NSLog(@"- connection.creationTime: %@", stream.connection.creationTime);
    NSLog(@"- session.sessionId: %@", stream.session.sessionId);
    NSLog(@"- streamId: %@", stream.streamId);
    NSLog(@"- type %@", stream.type);
    NSLog(@"- creationTime %@", stream.creationTime);
    NSLog(@"- name %@", stream.name);
    NSLog(@"- hasAudio %@", (stream.hasAudio ? @"YES" : @"NO"));
    NSLog(@"- hasVideo %@", (stream.hasVideo ? @"YES" : @"NO"));
    if (!self.subscriber) {
        self.subscriber = [[OTSubscriber alloc] initWithStream:stream delegate:self];
        self.subscriber.subscribeToAudio = YES;
        self.subscriber.subscribeToVideo = YES;
    }
    NSLog(@"subscriber.session.sessionId: %@", self.subscriber.session.sessionId);
    NSLog(@"- stream.streamId: %@", self.subscriber.stream.streamId);
    NSLog(@"- subscribeToAudio %@", (self.subscriber.subscribeToAudio ? @"YES" : @"NO"));
    NSLog(@"- subscribeToVideo %@", (self.subscriber.subscribeToVideo ? @"YES" : @"NO"));
}

- (void)session:(OTSession*)session didDropStream:(OTStream*)stream
{
    NSLog(@"session didDropStream (%@)", stream.streamId);
    if (self.subscriber && [self.subscriber.stream.streamId isEqualToString: stream.streamId]) {
        self.subscriber = nil;
        [self updateSubscriber];
    }
    
    self.disconnectButton.hidden = YES;
    self.startButton.hidden = NO;
}

#pragma mark - OTPublisherDelegate methods

- (void)publisher:(OTPublisher*)publisher didFailWithError:(OTError*) error
{
    self.disconnectButton.hidden = YES;
    self.startButton.hidden = NO;
    
    [self dismissModalViewControllerAnimated:YES];
    
    NSLog(@"publisher: %@ didFailWithError:", publisher);
    NSLog(@"- error code: %d", error.code);
    NSLog(@"- description: %@", error.localizedDescription);
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alert show];
}

- (void)publisherDidStartStreaming:(OTPublisher *)publisher
{
    self.disconnectButton.hidden = NO;
    self.startButton.hidden = YES;
    
    [self dismissModalViewControllerAnimated:YES];
    
    NSLog(@"publisherDidStartStreaming: %@", publisher);
    NSLog(@"- publisher.session: %@", publisher.session.sessionId);
    NSLog(@"- publisher.name: %@", publisher.name);
}

-(void)publisherDidStopStreaming:(OTPublisher*)publisher
{
    NSLog(@"publisherDidStopStreaming:%@", publisher);
    
    self.disconnectButton.hidden = YES;
    self.startButton.hidden = NO;
}

#pragma mark - OTSubscriberDelegate methods

- (void)subscriberDidConnectToStream:(OTSubscriber*)subscriber
{
    NSLog(@"subscriberDidConnectToStream (%@)", subscriber.stream.connection.connectionId);
    if (self.userType == BMEUserTypeHelper && ![subscriber.stream.connection.connectionId isEqualToString:self.session.connection.connectionId]) {
        [subscriber.view setFrame:self.videoPlaceholderView.frame];
        [self.view insertSubview:subscriber.view aboveSubview:self.videoPlaceholderView];
    }
}

- (void)subscriberVideoDataReceived:(OTSubscriber*)subscriber {
    NSLog(@"subscriberVideoDataReceived (%@)", subscriber.stream.streamId);
}

- (void)subscriber:(OTSubscriber *)subscriber didFailWithError:(OTError *)error
{
    NSLog(@"subscriber: %@ didFailWithError: ", subscriber.stream.streamId);
    NSLog(@"- code: %d", error.code);
    NSLog(@"- description: %@", error.localizedDescription);
}

- (void)viewDidUnload {
    [self setStartButton:nil];
    [self setVideoPlaceholderView:nil];
    [self setDisconnectButton:nil];
    [self setTitleLabel:nil];
    [super viewDidUnload];
}
@end
