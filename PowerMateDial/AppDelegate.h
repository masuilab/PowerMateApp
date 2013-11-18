//
//  PMDAppDelegate.h
//  PowerMateDial
//
//  Created by 桜井雄介 on 2013/11/11.
//  Copyright (c) 2013年 Yusuke Sakurai. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MainWindowController.h"

@interface AppDelegate : NSResponder <NSApplicationDelegate>

+ (AppDelegate*)sharedDelegate;

@property MainWindowController *mainWindowContorller;

@end
