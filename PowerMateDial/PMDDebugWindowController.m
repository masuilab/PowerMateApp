//
//  PMDDebugWindowController.m
//  PowerMateApp
//
//  Created by 桜井雄介 on 2013/11/18.
//  Copyright (c) 2013年 Yusuke Sakurai. All rights reserved.
//

#import "PMDDebugWindowController.h"

// 回転が止まってから何秒後に終了検知するか
#define FINISH_TIMER_VALUE 0.8

typedef enum NSUInteger{
    RotationDirectionLeft = 123,
    RotationDirectionRight = 124
}RotationDirection;

@interface PMDDebugWindowController ()
{
    NSInteger rotationCount;
    NSTimer *timer;
}

@property (weak) IBOutlet NSTextField *label;

@end

@implementation PMDDebugWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    [self.window makeFirstResponder:self];
}

- (void)finishRotation
{
    NSLog(@"rotation finished direction:times: %li",(long)rotationCount);
    rotationCount = 0;
    [self.label setTextColor:[NSColor redColor]];
}

-(void)keyDown:(NSEvent *)theEvent
{
    NSLog(@"%@",theEvent);
    // 文字色を戻す
    if (rotationCount == 0) {
        [self.label setTextColor:[NSColor whiteColor]];
    }
    // 回転終了のチェック
    [timer invalidate];
    timer = [NSTimer scheduledTimerWithTimeInterval:FINISH_TIMER_VALUE target:self selector:@selector(finishRotation) userInfo:nil repeats:NO];
    
    // 方向によって回転数を上げ下げ
    switch (theEvent.keyCode) {
        case RotationDirectionLeft:
            // left
            rotationCount--;
            break;
        case RotationDirectionRight:
            // right
            rotationCount++;
            break;
        default:
            break;
    }
    [self.label setIntegerValue:rotationCount];
}

@end
