//
//  GisterPostWindowController.h
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

#import <Cocoa/Cocoa.h>
#import "GitHubUserInfo.h"
#import "LoginProtocol.h"

@interface GisterPostWindowController : NSWindowController <NSUserNotificationCenterDelegate, LoginProtocol, NSTextViewDelegate>

@property (nonatomic, weak) id<LoginProtocol> delegate;

@property (nonatomic, copy) NSString *gistText;

@property (nonatomic, strong) GitHubUserInfo *userCredential;

@property (weak) IBOutlet NSView *commitView;

@property (weak) IBOutlet NSWindow *mainWindow;

@property (weak) IBOutlet NSButton *privateGistCheckBox;

@property (weak) IBOutlet NSTextField *gistDescriptionTextField;

@property (weak) IBOutlet NSTextField *fileNameTextField;


- (IBAction)CommitGistButtonPushed:(id)sender;

- (IBAction)CancelCommitButtonPushed:(id)sender;

- (IBAction)fileNameTextFieldEnterPushed:(id)sender;

- (IBAction)descriptionTextFieldEnterPushed:(id)sender;

- (void)showGistDialogWindowWithGistText:(NSString *)gistText;

- (id)init;
@end
