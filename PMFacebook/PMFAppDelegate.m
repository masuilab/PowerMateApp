//
//  PMAAppDelegate.m
//  PMFacebook
//
//  Created by 桜井雄介 on 2013/11/09.
//  Copyright (c) 2013年 Yusuke Sakurai. All rights reserved.
//

#import "PMFAppDelegate.h"

@implementation PMFAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    self.webView.autoresizingMask = NSViewWidthSizable|NSViewHeightSizable;
    NSURL* url = [NSURL URLWithString:@"https://facebook.com"];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    [self.webView.mainFrame loadRequest:req];
}

@end
