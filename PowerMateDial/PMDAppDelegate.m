//
//  PMDAppDelegate.m
//  PowerMateDial
//
//  Created by 桜井雄介 on 2013/11/11.
//  Copyright (c) 2013年 Yusuke Sakurai. All rights reserved.
//

#import "PMDAppDelegate.h"
#import "PMDMainWindowController.h"
#import "PMDDebugWindowController.h"

@interface PMDAppDelegate ()
{
    NSTimeInterval _previous;
    NSMutableArray *_stack;
}

@property PMDMainWindowController *mainWindowContorller;
@property PMDDebugWindowController *debugWindowController;

@end

@implementation PMDAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    self.mainWindowContorller = [[PMDMainWindowController alloc] initWithWindowNibName:@"MainWindow"];
    [self.mainWindowContorller showWindow:self];
    self.debugWindowController = [[PMDDebugWindowController alloc] initWithWindowNibName:@"DebugWindow"];
    [self.debugWindowController showWindow:self];
}

@end
