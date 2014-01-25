//
//  LoginWindowController.m
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

#import "LoginWindowController.h"
#import "NSAlert+EasyAlert.h"

@interface LoginWindowController ()

@end

@implementation LoginWindowController

- (id)initWithDelegate:(id<LoginProtocol>)delegate
{
    self = [super init];
    if (self) {
        self.delegate = delegate;
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
}



- (BOOL)inputIsValid{
    BOOL isValid = YES;
    NSString *username = [self.usernameTextField stringValue];
    if (!username || [username isEqualToString:@""]){
        isValid = NO;
    }
    
    NSString *password = [self.passwordTextField stringValue];
    if (!password || [password isEqualToString:@""]){
        isValid = NO;
    }
    
    return isValid;
}

- (void)validateAndCreateUserCredential{
    if (![self inputIsValid]){
        [NSAlert alertWithMessage:@"Username or Password invalid format."];
        return;
    }
    
    [self closeModalWindow:self];
    
    GitHubUserInfo *credential = [[GitHubUserInfo alloc]initWithUsername:[self.usernameTextField stringValue] andPassword:[self.passwordTextField stringValue]];
    
    [self.delegate credentialCreated:credential];
}


- (IBAction)loginButtonPushed:(id)sender {
    [self validateAndCreateUserCredential];
    
}

- (IBAction)cancelButtonPushed:(id)sender {
    [self closeModalWindow:self];
    
    
    if ([self.delegate respondsToSelector:@selector(userCancelledLogin)]){
        [self.delegate userCancelledLogin];
    }
}

- (IBAction)selector:(id)sender{
    [self validateAndCreateUserCredential];
}

- (void)resetFields{
    self.usernameTextField.stringValue = @"";
    self.passwordTextField.stringValue = @"";
    
    [[self.usernameTextField window]makeFirstResponder:self.usernameTextField];
}

- (void)showModalLoginViewInWindow:(NSWindow *)window{
    [self resetFields];
    
    if (!self.loginWindow){
        [NSBundle loadNibNamed:@"LoginWindow" owner:self];
    }
    
    [NSApp beginSheet: self.loginWindow
       modalForWindow: window
        modalDelegate: self
       didEndSelector: @selector(didEndSheet:returnCode:contextInfo:)
          contextInfo: nil];
}


- (void)closeModalWindow: (id)sender
{
    [NSApp endSheet:self.loginWindow];
    [self.loginWindow orderOut:self];
}

- (void)didEndSheet:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
    [sheet orderOut:self];
}



@end
