//
//  PMTAppDelegate.h
//  PMTumblr
//
//  Created by 桜井雄介 on 2013/11/09.
//  Copyright (c) 2013年 Yusuke Sakurai. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
@interface PMTAppDelegate : NSResponder <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet WebView *webView;

@end
