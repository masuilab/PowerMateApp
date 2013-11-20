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
    // ルートになるノード
    NodeItem *rootNode;
    // シークエンスの回転数。正負は左右と対応
    NSInteger rotationCount;
    // シークエンスの右への合計回転数
    NSUInteger rotationToRight;
    // シークエンスの左への合計回転数
    NSUInteger rotationToLeft;
    // シークエンス終了検知のためのタイマー
    NSTimer *timer;
    // ノードの選択がプログラム中で行われたか
    // <=> PowerMate経由での選択かを判別するためのフラグ
    BOOL selectionChangedBySelf;
}

/* View Outlets */
@property (weak) IBOutlet NSSplitView *splitView;
@property (weak) IBOutlet NSOutlineView *outlineView;
@property (strong) IBOutlet NSTreeController *treeController;
@property (weak) IBOutlet NSTableColumn *tableColumn;
@property (strong) IBOutlet NSPanel *debugWindow;
@property (weak) IBOutlet NSTextField *label;
@property (weak) IBOutlet NSImageView *imageView;

// 現在選択中のノード
@property (nonatomic) NodeItem *selectedNode;

@end

@implementation MainWindowController

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Content Treeを読み込み
//    NSURL *treeURL = [NodeItem contentTreeURL];
    NSURL *treeURL = [NodeItem homeURL];
    rootNode = [NodeItem rootNodeWithURL:treeURL];
    self.contents = @[rootNode];
    self.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    self.selectedNode = rootNode.children.firstObject;
}

- (void)finishRotation
{
    NSLog(@"rotation finished direction:times: %li",(long)rotationCount);
    rotationCount = 0;
    [self.label setTextColor:[NSColor redColor]];
}

- (void)setSelectedNode:(NodeItem *)selectedNode
{
    if (selectedNode != _selectedNode) {
        selectionChangedBySelf = YES;
        _selectedNode = selectedNode;
        [self.treeController setSelectionIndexPath:selectedNode.indexPath];
        self.selectedIndexPaths = @[selectedNode.indexPath];
        if (selectedNode.isLeaf) {
            NSError *e = nil;
            NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:@"(png|jpg|gif)" options:NSRegularExpressionCaseInsensitive error:&e];
            NSString *ext = selectedNode.url.pathExtension;
            NSRange result = [regexp rangeOfFirstMatchInString:ext options:0 range:NSMakeRange(0, ext.length)];
            if (result.location != NSNotFound){
                NSImage *image = [[NSImage alloc] initWithContentsOfFile:selectedNode.url.path];
                self.imageView.image = image;
            }
        }
        selectionChangedBySelf = NO;
    }
}

-(void)keyDown:(NSEvent *)theEvent
{
//    NSLog(@"%@",theEvent);
    // 文字色を戻す
    if (rotationCount == 0) {
        [self.label setTextColor:[NSColor blackColor]];
    }
    // 回転終了のチェック
    [timer invalidate];
    timer = [NSTimer scheduledTimerWithTimeInterval:FINISH_TIMER_VALUE target:self selector:@selector(finishRotation) userInfo:nil repeats:NO];
    
    // 方向によって回転数を上げ下げ
    switch (theEvent.keyCode) {
        case RotationDirectionLeft:
            // left
            rotationCount--;
            if (self.selectedNode.children) {
                self.selectedNode = self.selectedNode.children.lastObject;
            }else{
                if (self.selectedNode.previousNode) {
                    self.selectedNode = self.selectedNode.previousNode;
                }
            }
            break;
        case RotationDirectionRight:
            // right
            rotationCount++;
            if (self.selectedNode.children) {
                self.selectedNode = self.selectedNode.children.firstObject;
            }else{
                if (self.selectedNode.nextNode) {
                    self.selectedNode = self.selectedNode.nextNode;
                }
            }
            break;
        case 37: {
            NSLog(@"%@",self.treeController.selectedObjects);
        }
            break;
        default:
            break;
    }
    NSLog(@"%@ was selected",self.selectedNode);
    [self.label setIntegerValue:rotationCount];
}

#pragma mark - NSOutlineView delegate

- (void)outlineViewSelectionDidChange:(NSNotification *)notification
{
    // プログラム上での選択変更でない <=> クリックでの操作変更の場合
    if (!selectionChangedBySelf) {
        NSInteger row = [self.outlineView selectedRow];
        NodeItem *item = [[self.outlineView itemAtRow:row] representedObject];
        [self setSelectedNode:item];
        NSLog(@"%@",item);
    }
}

@end
