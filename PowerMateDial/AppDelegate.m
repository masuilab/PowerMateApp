//
//  PMDAppDelegate.m
//  PowerMateDial
//
//  Created by 桜井雄介 on 2013/11/11.
//  Copyright (c) 2013年 Yusuke Sakurai. All rights reserved.
//

#import "AppDelegate.h"
#import "NodeItem.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

+ (AppDelegate *)sharedDelegate
{
    return (AppDelegate*)[[NSApplication sharedApplication] delegate];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    self.mainWindowContorller = [[MainWindowController alloc] initWithWindowNibName:@"MainWindow"];
    [self.mainWindowContorller showWindow:self];
}

- (IBAction)onFileOpen:(id)sender {
    NSLog(@"file open");
    NSOpenPanel *op = [NSOpenPanel openPanel];
    [op setCanChooseDirectories:YES];
    [op setCanChooseFiles:NO];
    [op setAllowsMultipleSelection:NO];
    [op setTitle:NSLocalizedString(@"ブラウズするフォルダを選択", )];
    switch ([op runModal]) {
        case NSFileHandlingPanelOKButton: {
            NSURL *url = [[op URLs] firstObject];
            NSLog(@"%@",url);
            // 新しいフォルダを設定
            NodeItem *newRoot = [NodeItem rootNodeWithURL:url];
            [self.mainWindowContorller setRootNode:newRoot];
        }
            break;
        case NSFileHandlingPanelCancelButton:
            NSLog(@"canceled");
        default:
            break;
    }
}

@end
