//
//  PMDAppDelegate.h
//  PowerMateDial
//
//  Created by 桜井雄介 on 2013/11/11.
//  Copyright (c) 2013年 Yusuke Sakurai. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PMDMainWindowController.h"
#import "PMDDebugWindowController.h"

@interface PMDAppDelegate : NSResponder <NSApplicationDelegate>

+ (PMDAppDelegate*)sharedDelegate;

@property PMDMainWindowController *mainWindowContorller;
@property PMDDebugWindowController *debugWindowController;

@end
