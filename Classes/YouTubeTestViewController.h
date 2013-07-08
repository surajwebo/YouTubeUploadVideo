//
//  YouTubeTestViewController.h
//  YouTubeTest
//
//  Created by Uri Nieto on 10/15/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GData.h"

@interface YouTubeTestViewController : UIViewController {
    IBOutlet UITextField *mUsernameField;
    IBOutlet UITextField *mPasswordField;
    IBOutlet UIProgressView *mProgressView;
    
    UITextField *mDeveloperKeyField;
    UITextField *mClientIDField;
    UITextField *mTitleField;
    UITextField *mDescriptionField;
    UITextField *mKeywordsField;
    UITextField *mCategoryField;
    BOOL mIsPrivate;
    
    GDataServiceTicket *mUploadTicket;
}

@property (nonatomic, retain) IBOutlet UITextField *mUsernameField;
@property (nonatomic, retain) IBOutlet UITextField *mPasswordField;
@property (nonatomic, retain) IBOutlet UIProgressView *mProgressView;

- (IBAction)uploadPressed:(id)sender;



@end

