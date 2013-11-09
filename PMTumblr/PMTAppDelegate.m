//
//  PMTAppDelegate.m
//  PMTumblr
//
//  Created by 桜井雄介 on 2013/11/09.
//  Copyright (c) 2013年 Yusuke Sakurai. All rights reserved.
//

#import "PMTAppDelegate.h"

@implementation PMTAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    self.webView.autoresizingMask = NSViewWidthSizable|NSViewHeightSizable;
    NSURL* url = [NSURL URLWithString:@"https://tumblr.com/dashboard"];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    [self.webView.mainFrame loadRequest:req];
//    [self.window makeFirstResponder:self];
}

- (void)keyUp:(NSEvent *)theEvent
{
    NSLog(@"%@",theEvent);
    [self.window sendEvent:theEvent];
}

- (void)keyDown:(NSEvent *)theEvent
{
    NSLog(@"%@",theEvent);
    [self.window sendEvent:theEvent];
}


@end
