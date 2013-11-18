//
//  PMDAppDelegate.m
//  PowerMateDial
//
//  Created by 桜井雄介 on 2013/11/11.
//  Copyright (c) 2013年 Yusuke Sakurai. All rights reserved.
//

#import "PMDAppDelegate.h"

@interface PMDAppDelegate ()
{
    NSTimeInterval _previous;
    NSMutableArray *_stack;
}

@property (weak) IBOutlet NSTextField *_textField;

@end

@implementation PMDAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    _stack = [NSMutableArray new];
    [self.window makeFirstResponder:self];
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
    if (diff < 0.01) {
        // 高速
        [self._textField setStringValue:@"Fast"];
    }else if (0.01 <= diff && diff <= 0.1) {
        // 中速
        [self._textField setStringValue:@"Normal"];
    }else if (0.1 < diff){
        // 低速
        [self._textField setStringValue:@"Slow"];
    }
    NSLog(@"%@",_stack);
}

@end
