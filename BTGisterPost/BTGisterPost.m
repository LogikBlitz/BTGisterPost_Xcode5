//
//  BTGisterPost.m
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

#import "BTGisterPost.h"
#import "GitHubUserInfo.h"
#include "GisterPostWindowController.h"


@interface BTGisterPost()

@property (nonatomic, strong) NSBundle *bundle;
@property (nonatomic, strong) GitHubUserInfo *userCredential;
@property (nonatomic, strong) GisterPostWindowController *gistPostController;
@property (nonatomic, strong) NSString *selectedText;

@end

@implementation BTGisterPost


+ (void)pluginDidLoad:(NSBundle *)plugin
{
    static id sharedPlugin = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedPlugin = [[self alloc] initWithBundle: plugin];
    });
}

- (id)init
{
    if (self = [super init]) {
        [self addMenuItems];
    }
    return self;
}

- (id)initWithBundle:(NSBundle *)plugin {
    if (self = [super init]) {
        _bundle = plugin;
        self.gistPostController = [[GisterPostWindowController alloc]init];
        [self addMenuItems];
        [self registrerForSelectionChanges];
    }
    return self;
}

- (void)addMenuItems {
    NSMenuItem* editMenuItem = [[NSApp mainMenu] itemWithTitle:@"Edit"];
    if (editMenuItem) {
        [[editMenuItem submenu] addItem:[NSMenuItem separatorItem]];
        
        NSMenuItem* newMenuItem = [[NSMenuItem alloc] initWithTitle:@"Post Gist to GitHub"
                                                             action:@selector(postGistToGitHub)
                                                      keyEquivalent:@"c"];
        [newMenuItem setTarget:self];
        [newMenuItem setKeyEquivalentModifierMask: NSAlternateKeyMask];
        [[editMenuItem submenu] addItem:newMenuItem];;
    }

}

- (void)registrerForSelectionChanges{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(selectionDidChange:)
                                                 name:NSTextViewDidChangeSelectionNotification
                                               object:nil];
}

- (void) selectionDidChange: (NSNotification*) notification {
    
    if ([[notification object] isKindOfClass:[NSTextView class]]) {
        NSTextView* textView = (NSTextView *)[notification object];
        
        NSArray* selectedRanges = [textView selectedRanges];
        
        NSRange selectedRange = [[selectedRanges objectAtIndex:0] rangeValue];
        NSString* text = textView.textStorage.string;
        self.selectedText = [text substringWithRange:selectedRange];
        
        if (!self.selectedText || [self.selectedText isEqualToString:@""]){
            self.selectedText = textView.textStorage.string;
        }        
    }
}


- (void) postGistToGitHub{
    [self.gistPostController showGistDialogWindowWithGistText:self.selectedText];
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
