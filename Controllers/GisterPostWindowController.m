//
//  GisterPostWindowController.m
//  BTGisterPost
//
//  Copyright (c) 2013 Thomas Blitz
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "GisterPostWindowController.h"
#import "UAGitHubEngine.h"
#import "LoginWindowController.h"
#import "Gist.h"
#import "NetworkReachability.h"
#import "NSAlert+EasyAlert.h"
#import <IDEKit/IDEWorkspaceWindowController.h>
#import <IDEKit/IDEEditorArea.h>
#import <IDEKit/IDEEditorDocument.h>
//Libraries/XcodeFrameworks#import <IDEKit/IDEEditorDocument.h>



id objc_getClass(const char* name);

static Class DVTSourceTextViewClass;
static Class IDESourceCodeEditorClass;
static Class IDEApplicationClass;
static Class IDEWorkspaceWindowControllerClass;


@interface GisterPostWindowController ()
@property (nonatomic, strong) id ideWorkspaceWindow;
@property (nonatomic, strong) UAGithubEngine *githubEngine;
@property (nonatomic, strong) NSUserNotificationCenter *notificationCenter;
@property (nonatomic, strong) LoginWindowController *loginWindowController;
@end

@implementation GisterPostWindowController
+(BOOL)checkNet{
    
    NetworkReachability *netStatus=[NetworkReachability reachabilityWithHostname:@"www.google.com"];
    
    if ([netStatus currentReachabilityStatus] == IsNotReachable){
        return NO;
    }
    return YES;
}

#pragma mark - Lifecycle

- (id)init
{
    self = [super init];
    if (self) {
        self.notificationCenter = [NSUserNotificationCenter defaultUserNotificationCenter];
        self.notificationCenter.delegate = self;
        self.loginWindowController = [[LoginWindowController alloc] initWithDelegate:self];
        
        DVTSourceTextViewClass = objc_getClass("DVTSourceTextView");
        IDESourceCodeEditorClass = objc_getClass("IDESourceCodeEditor");
        IDEApplicationClass = objc_getClass("IDEApplication");
        IDEWorkspaceWindowControllerClass = objc_getClass("IDEWorkspaceWindowController");
        
        self.githubEngine = [[UAGithubEngine alloc]initWithUsername:self.userCredential.username password:self.userCredential.password withReachability:YES];
        
        
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self
               selector:@selector(fetchActiveIDEWorkspaceWindow:)
                   name:NSWindowDidUpdateNotification
                 object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Helper
- (NSURL *)activeDocument
{
    for (id workspaceWindowController in [IDEWorkspaceWindowControllerClass workspaceWindowControllers])
    {
        if ([workspaceWindowController workspaceWindow] == self.ideWorkspaceWindow)
        {
            return [[[workspaceWindowController editorArea] primaryEditorDocument] fileURL];
        }
    }

    return nil;
}

- (NSString *)currentDocumentName{
    NSURL *activeDocumentURL = [self activeDocument];
    NSString *activeDocumentFilename = [activeDocumentURL lastPathComponent];
    return activeDocumentFilename;
}

- (void)defineFirstReponderTextField{
    if(!self.fileNameTextField || [self.fileNameTextField.stringValue isEqualToString:@""]){
        [[self.fileNameTextField window]makeFirstResponder:self.fileNameTextField];
    }else{
        [[self.gistDescriptionTextField window]makeFirstResponder:self.gistDescriptionTextField];
    }
}


#pragma mark - LoginProtocol Implementation

- (void)userCancelledLogin{
    [self makeWindowSolid];
}

- (void)credentialCreated:(GitHubUserInfo *)credential{
    [self makeWindowSolid];
    self.userCredential = credential;
    [self commitGist];
}


#pragma mark - View management
- (void)windowDidLoad
{
    [super windowDidLoad];
    
	[self.mainWindow makeKeyAndOrderFront:self];
    [self makeWindowSolid];
}

- (void)resignWindow{
    [self.mainWindow orderOut:self];
}


#pragma mark - View transparancy

- (void)dimWindow{
    [[self.mainWindow animator] setAlphaValue:0.3f];
}

- (void)makeWindowSolid{
    [[self.mainWindow animator] setAlphaValue:1.0f];
    [self.fileNameTextField becomeFirstResponder];
}

- (void)makeWindowInvisible{
    [[self.mainWindow animator] setAlphaValue:0.0f];
}

#pragma mark - Gist handeling

- (void)requestUserCredentials{
    [self dimWindow];
    [self.loginWindowController showModalLoginViewInWindow:self.mainWindow];
}

- (void)postGist{
    NSLog(@"POSTGIST");
    [self makeWindowInvisible];
    [self postGist:self.gistText withDescription:[self.gistDescriptionTextField stringValue] andFilename:[self.fileNameTextField stringValue] andCredential:self.userCredential success:^(Gist *gist) {
        dispatch_async(dispatch_get_main_queue(),
                       ^{
                           NSLog(@"MAIN QUEUE ");
                           [self resignWindow];
                           NSString *text = nil;
                           if (gist.gistUrlString)
                               text = [NSString stringWithFormat:@"%@", gist.gistUrlString ];
                           else
                               text = [NSString stringWithFormat:@"%@ Gist Created", gist.filename];
                           
                           [self notifyWithText:text withTitle:@"Xcode BTGisterPost" andSubTitle:@"Gist Created on GitHub"];
                           NSLog(@"BTGisterPost Message: %@ Gist Created with URL: %@", gist.filename, gist.gistUrlString);
                       });
        
        
    } andFailure:^(NSString *errorMessage) {
        dispatch_async(dispatch_get_main_queue(),
                       ^{
                           [self resetController];
                           [self makeWindowSolid];
                           [self showAlertSheetWithMessage:@"Gist not created" additionalInfo:errorMessage buttonOneText:@"OK" buttonTwoText:nil attachedToWindow:self.mainWindow withSelector:@selector(sheetDidEndShouldDelete:returnCode:contextInfo:)];
                       }
                       );
    }];
}

- (void)commitGist{
    if (!self.userCredential){
        [self requestUserCredentials];
        
    }else{
        [self githubEngineSetup];
        [self postGist];
    }
    
}


//Only public method
- (void)showGistDialogWindowWithGistText:(NSString *)gistText{
    NSLog(@"showGistDialogWindowWithGistText with thext %@", gistText);
    self.gistText = gistText;
    NSString *filename =[self currentDocumentName];
    if (!self.gistText || [self.gistText isEqualToString:@""] ){
        NSRunAlertPanel(@"No Gist text selected", @"No text was submitted for the gist. Please select the text to turn into a gist.", @"OK", nil, nil, nil);
        [self resignWindow];
        return;
    }
    [NSBundle loadNibNamed:@"GisterPostWindow" owner:self];
    
    
    
    [self.mainWindow makeKeyAndOrderFront:self];
    [self.fileNameTextField setStringValue:filename];
    [self defineFirstReponderTextField];
}

- (void)resetController{
    self.githubEngine = nil;
    self.userCredential = nil;
}

- (void)postGist:(NSString *)gistText withDescription:(NSString *)gistDescription andFilename:(NSString *)filename andCredential:(GitHubUserInfo *)credential success:(void (^)(Gist *gist))successBlock andFailure:(void (^)(NSString * errorMessage))failureBlock{
    
    BOOL isPublic = ![self.privateGistCheckBox state] == NSOnState;
    
    Gist *gist = [[Gist alloc]initWithGistText:gistText andFilename:filename andDescription:gistDescription isPrivate:isPublic];
    
    dispatch_queue_t workingQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    dispatch_async(workingQueue,
                   ^{
                       BOOL isOnline = [GisterPostWindowController checkNet];
                       if (!isOnline){
                           failureBlock(@"Network connection seems to be unavailable.");
                       }
                       else{
                           [self.githubEngine createGist:[gist gistAsDictionary] success:^(id success) {
                               NSDictionary *dict = [(NSArray *)success objectAtIndex:0];
                               if (dict)
                                   gist.gistUrlString = [dict objectForKey:@"html_url"];
                               successBlock(gist);
                               
                           } failure:^(NSError *gistError) {
                               failureBlock(@"Github could not create the gist. Check username and password");
                           }];
                       }
                   });
}


#pragma mark - Window Actions and outlets
- (IBAction)CancelCommitButtonPushed:(id)sender {
    [self resignWindow];
    
}

- (IBAction)CommitGistButtonPushed:(id)sender {
    [self commitGist];
}

- (IBAction)fileNameTextFieldEnterPushed:(id)sender{
    [self commitGist];
}

- (IBAction)descriptionTextFieldEnterPushed:(id)sender{
    [self commitGist];
}

#pragma mark - Alerts

- (void)showAlertSheetWithMessage:(NSString *)message additionalInfo:(NSString *)additionalInfo buttonOneText:(NSString *)buttonOneText buttonTwoText:(NSString *)buttonTwoText attachedToWindow:(NSWindow *)window withSelector:(SEL)selector{
    NSBeginAlertSheet(
                      message,                      // sheet message
                      @"Ok",                        // default button label
                      nil,                          // no third button
                      nil,                          // other button label
                      window,                       // window sheet is attached to
                      self,                         // we’ll be our own delegate
                      NULL,                     // did-end selector
                      selector,                   // no need for did-dismiss selector
                      (__bridge void *)(window),                 // context info
                      additionalInfo);
    
    
}

- (void)sheetDidEndShouldDelete: (NSWindow *)sheet
                     returnCode: (NSInteger)returnCode
                    contextInfo: (void *)contextInfo
{
    if (returnCode == NSAlertDefaultReturn){
        
        [self commitGist];
    }
    
}

// ------------------------------------------------------------------------------------------
#pragma mark - Notifications
// ------------------------------------------------------------------------------------------
- (void)fetchActiveIDEWorkspaceWindow:(NSNotification *)notification
{
    id window = [notification object];
    if ([window isKindOfClass:[NSWindow class]] && [window isMainWindow])
    {
        self.ideWorkspaceWindow = window;
    }
}

#pragma mark - User notification OSX 10.8 +10.9

- (void)notifyWithText:(NSString *)text withTitle:(NSString *)title andSubTitle:(NSString *)subTitle{
    
    NSUserNotification *notification = [[NSUserNotification alloc]init];
    notification.title = title;
    notification.subtitle = subTitle;
    notification.informativeText = text;
    [self.notificationCenter deliverNotification:notification];
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification
{
    return YES;
}

- (void) userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification
{
    if (notification){
        if (notification.informativeText){
            NSURL *url = [NSURL URLWithString:notification.informativeText];
             [[NSWorkspace sharedWorkspace] openURL:url];
        }
    }  
}




#pragma mark - Custom property accessors
-(void) githubEngineSetup{
    if (!self.githubEngine){
        self.githubEngine = [[UAGithubEngine alloc]initWithUsername:self.userCredential.username password:self.userCredential.password withReachability:YES];
    }
}



@end
