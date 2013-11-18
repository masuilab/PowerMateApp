//
//  PMDAppDelegate.m
//  PowerMateDial
//
//  Created by 桜井雄介 on 2013/11/11.
//  Copyright (c) 2013年 Yusuke Sakurai. All rights reserved.
//

#import "PMDAppDelegate.h"
#import "PMDMainWindowController.h"

@interface PMDAppDelegate ()
{
    NSTimeInterval _previous;
    NSMutableArray *_stack;
}

@property PMDMainWindowController *mainWindowContorller;

@end

@implementation PMDAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    self.mainWindowContorller = [[PMDMainWindowController alloc] initWithWindowNibName:@"MainWindow"];
    [self.mainWindowContorller showWindow:self];
}

- (void)keyUp:(NSEvent *)theEvent
{
    // j(40) -> left
    // k(38) -> right
    // k(37) -> press
    // r(15) -> long press
//    NSLog(@"%@",theEvent);
    NSTimeInterval timestamp = [theEvent timestamp];
    unsigned short keyCode = [theEvent keyCode];
    NSTimeInterval diff = timestamp - _previous;
    NSLog(@"%u, %f",keyCode,diff);
    if (_stack.count > 5) {
        [_stack removeLastObject];
    }
    [_stack insertObject:@(diff) atIndex:0];
    _previous = timestamp;
    NSLog(@"%@",_stack);
}

@end
