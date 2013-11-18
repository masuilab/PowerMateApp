//
//  PMFMainWindowController.m
//  PowerMateApp
//
//  Created by 桜井雄介 on 2013/11/18.
//  Copyright (c) 2013年 Yusuke Sakurai. All rights reserved.
//

#import "MainWindowController.h"
#import "NodeItem.h"

// 回転が止まってから何秒後に終了検知するか
#define FINISH_TIMER_VALUE 0.8

typedef enum NSUInteger{
    RotationDirectionLeft = 123,
    RotationDirectionRight = 124
}RotationDirection;

@interface MainWindowController ()
{
    NSImage *folderImage;
    NodeItem *rootNode;
    NSInteger rotationCount;
    NSTimer *timer;
}

@property (weak) IBOutlet NSSplitView *splitView;
@property (weak) IBOutlet NSOutlineView *outlineView;
@property (strong) IBOutlet NSTreeController *treeController;
@property (weak) IBOutlet NSTableColumn *tableColumn;
@property (strong) IBOutlet NSPanel *debugWindow;
@property (weak) IBOutlet NSTextField *label;

@end

@implementation MainWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self.outlineView setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleSourceList];
    // Content Treeを読み込み
    NSURL *treeURL = [NodeItem contentTreeURL];
    rootNode = [NodeItem rootNodeWithURL:treeURL];
    self.contents = rootNode.children;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
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
        case 37: {
            NSTreeNode *treenode = [self.treeController.selectedNodes objectAtIndex:0];
            NodeItem *item = [treenode representedObject];
            NSLog(@"%@",item.url.path);
        }
            break;
        default:
            break;
    }
    [self.label setIntegerValue:rotationCount];
}

#pragma mark - NSOutlineView delegate

- (void)outlineViewSelectionDidChange:(NSNotification *)notification
{
    
}

@end
