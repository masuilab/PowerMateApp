//
//  PMFMainWindowController.m
//  PowerMateApp
//
//  Created by 桜井雄介 on 2013/11/18.
//  Copyright (c) 2013年 Yusuke Sakurai. All rights reserved.
//

#import "PMDMainWindowController.h"

@interface PMDMainWindowController ()
@property (weak) IBOutlet NSSplitView *splitView;
@property (weak) IBOutlet NSOutlineView *outlineView;
@property (strong) IBOutlet NSTreeController *treeController;

@end

@implementation PMDMainWindowController

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
    NSLog(@"windowDidLoad");
    // KeyEventをこのクラスでキャッチする
    [self.window makeFirstResponder:self];
}

- (void)windowWillLoad
{
    [super windowWillLoad];
    NSLog(@"windowWillLoad");
}

- (void)keyUp:(NSEvent *)theEvent
{
    // <-(123) -> left
    //->(124) -> right
    // k(37) -> press
    // r(15) -> long press
    NSLog(@"%@",theEvent);
}

@end
