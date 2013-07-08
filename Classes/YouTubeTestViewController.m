//
//  YouTubeTestViewController.m
//  YouTubeTest
//
//  Created by Uri Nieto on 10/15/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import "YouTubeTestViewController.h"
#import "GDataServiceGoogleYouTube.h"
#import "GDataEntryYouTubeUpload.h"

// Developer Key
// To get your developer key go to: http://code.google.com/apis/youtube/dashboard/gwt/index.html#newProduct
#define DEVELOPER_KEY @""
#define CLIENT_ID @"" // ID of your registered app at Google


@interface YouTubeTestViewController (PrivateMethods)

- (GDataServiceTicket *)uploadTicket;
- (void)setUploadTicket:(GDataServiceTicket *)ticket;
- (GDataServiceGoogleYouTube *)youTubeService;

@end


@implementation YouTubeTestViewController

@synthesize mUsernameField;
@synthesize mPasswordField;
@synthesize mProgressView;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Too lazy to create different IBOutlets, they are UITextFields for the future...
    mDeveloperKeyField = [[UITextField alloc] init];
    mClientIDField = [[UITextField alloc] init];
    mTitleField = [[UITextField alloc] init];
    mDescriptionField = [[UITextField alloc] init];
    mKeywordsField = [[UITextField alloc] init];
    mCategoryField = [[UITextField alloc] init];
    
    [mDeveloperKeyField setText: DEVELOPER_KEY];
    [mClientIDField setText: CLIENT_ID];
    [mTitleField setText: @"Upload Test"];
    [mDescriptionField setText: @"video"];
    [mKeywordsField setText: @"video"];
    [mCategoryField setText: @"Entertainment"];
    mIsPrivate = NO;
    
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}


- (void)dealloc {
    [mUsernameField release];
    [mPasswordField release];
    [mDeveloperKeyField release];
    [mClientIDField release];
    [mTitleField release];
    [mDescriptionField release];
    [mKeywordsField release];
    [mCategoryField release];
    [mProgressView release];
    
    [mUploadTicket release];
    
    [super dealloc];
}

#pragma mark -Common
#pragma mark IBAction

- (IBAction)uploadPressed:(id)sender {
    [mUsernameField resignFirstResponder];
    [mPasswordField resignFirstResponder];
    NSString *devKey = [mDeveloperKeyField text];
    
    GDataServiceGoogleYouTube *service = [self youTubeService];
    [service setYouTubeDeveloperKey:devKey];
    
//    NSString *username = [mUsernameField text];
    NSString *clientID = [mClientIDField text];
    
    NSURL *url = [GDataServiceGoogleYouTube youTubeUploadURLForUserID:@"default"
                                                             clientID:clientID];
    NSLog(@"URL: %@",url);
    
    // load the file data
    NSString *path = [[NSBundle mainBundle] pathForResource:@"me" ofType:@"mp4"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSString *filename = [path lastPathComponent];
    
    // gather all the metadata needed for the mediaGroup
    NSString *titleStr = [mTitleField text];
    GDataMediaTitle *title = [GDataMediaTitle textConstructWithString:titleStr];
    
    NSString *categoryStr = [mCategoryField text];
    GDataMediaCategory *category = [GDataMediaCategory mediaCategoryWithString:categoryStr];
    [category setScheme:kGDataSchemeYouTubeCategory];
    
    NSString *descStr = [mDescriptionField text];
    GDataMediaDescription *desc = [GDataMediaDescription textConstructWithString:descStr];
    
    NSString *keywordsStr = [mKeywordsField text];
    GDataMediaKeywords *keywords = [GDataMediaKeywords keywordsWithString:keywordsStr];
    
    BOOL isPrivate = mIsPrivate;
    
    GDataYouTubeMediaGroup *mediaGroup = [GDataYouTubeMediaGroup mediaGroup];
    [mediaGroup setMediaTitle:title];
    [mediaGroup setMediaDescription:desc];
    [mediaGroup addMediaCategory:category];
    [mediaGroup setMediaKeywords:keywords];
    [mediaGroup setIsPrivate:isPrivate];
    
    NSString *mimeType = [GDataUtilities MIMETypeForFileAtPath:path
                                               defaultMIMEType:@"video/mp4"];
    
    // create the upload entry with the mediaGroup and the file data
    GDataEntryYouTubeUpload *entry;
    entry = [GDataEntryYouTubeUpload uploadEntryWithMediaGroup:mediaGroup
                                                          data:data
                                                      MIMEType:mimeType
                                                          slug:filename];
    
    SEL progressSel = @selector(ticket:hasDeliveredByteCount:ofTotalByteCount:);
    [service setServiceUploadProgressSelector:progressSel];
    
    GDataServiceTicket *ticket;
    ticket = [service fetchEntryByInsertingEntry:entry
                                      forFeedURL:url
                                        delegate:self
                               didFinishSelector:@selector(uploadTicket:finishedWithEntry:error:)];
    
    [self setUploadTicket:ticket];
    
}

#pragma mark -


// get a YouTube service object with the current username/password
//
// A "service" object handles networking tasks.  Service objects
// contain user authentication information as well as networking
// state information (such as cookies and the "last modified" date for
// fetched data.)

- (GDataServiceGoogleYouTube *)youTubeService {
    
    static GDataServiceGoogleYouTube* service = nil;
    
    if (!service) {
        service = [[GDataServiceGoogleYouTube alloc] init];
        
        [service setShouldCacheDatedData:YES];
        [service setServiceShouldFollowNextLinks:YES];
        [service setIsServiceRetryEnabled:YES];
    }
    
    // update the username/password each time the service is requested
    NSString *username = [mUsernameField text]; //[[mUsernameField text] stringByAppendingString:@"@gmail.com"];
    NSString *password = [mPasswordField text];
    
    if ([username length] > 0 && [password length] > 0) {
        [service setUserCredentialsWithUsername:username
                                       password:password];
    } else {
        // fetch unauthenticated
        [service setUserCredentialsWithUsername:nil
                                       password:nil];
    }
    
    NSString *devKey = [mDeveloperKeyField text];
    [service setYouTubeDeveloperKey:devKey];
    
    return service;
}

// progress callback
- (void)ticket:(GDataServiceTicket *)ticket
hasDeliveredByteCount:(unsigned long long)numberOfBytesRead
ofTotalByteCount:(unsigned long long)dataLength {
    
    [mProgressView setProgress:(double)numberOfBytesRead / (double)dataLength];
}

// upload callback
- (void)uploadTicket:(GDataServiceTicket *)ticket
   finishedWithEntry:(GDataEntryYouTubeVideo *)videoEntry
               error:(NSError *)error {
    if (error == nil) {
//        NSLog(@"videoEntry: %@",videoEntry);
        NSLog(@"Post Link: %@",videoEntry.HTMLLink.href);
        // tell the user that the add worked
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:[NSString stringWithFormat:@"%@ Uploaded! video.",[[videoEntry title] stringValue]]
                              message:[NSString stringWithFormat:@"%@",videoEntry.HTMLLink.href]
                              delegate:nil
                              cancelButtonTitle:@"Ok"
                              otherButtonTitles:nil];
        
        [alert show];
        [alert release];
    } else {
        NSLog(@"%@",error.description);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                        message:[NSString stringWithFormat:@"Error: %@",
                                                                 [error description]]
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
        
        [alert show];
        [alert release];
    }
    [mProgressView setProgress: 0.0];
    
    [self setUploadTicket:nil];
}

#pragma mark -
#pragma mark Setters

- (GDataServiceTicket *)uploadTicket {
    return mUploadTicket;
}

- (void)setUploadTicket:(GDataServiceTicket *)ticket {
    [mUploadTicket release];
    mUploadTicket = [ticket retain];
}


@end
