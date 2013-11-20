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
@property (weak) IBOutlet NSTextField *label;
@property (weak) IBOutlet NSImageView *imageView;

// 現在選択中のノード
@property (nonatomic) NodeItem *selectedNode;
@property (nonatomic) NSTreeNode *selectedTreeNode;

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
        [self changeSelectionProgramatically:^{
            _selectedNode = selectedNode;
            [self.treeController setSelectionIndexPath:selectedNode.indexPath];
            self.selectedIndexPaths = @[selectedNode.indexPath];
            // 葉ならファイルを表示
            if (selectedNode.isLeaf) {
                [self showFile:selectedNode.url];
            }
        }];
    }
}

- (void)showFile:(NSURL*)url
{
    NSError *e = nil;
    NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:@"(png|jpg|gif)" options:NSRegularExpressionCaseInsensitive error:&e];
    NSString *ext = url.pathExtension;
    NSRange result = [regexp rangeOfFirstMatchInString:ext options:0 range:NSMakeRange(0, ext.length)];
    if (result.location != NSNotFound){
        NSImage *image = [[NSImage alloc] initWithContentsOfFile:url.path];
        self.imageView.image = image;
    }
}

- (void)changeSelectionProgramatically:(void (^)())block{
    selectionChangedBySelf = YES;
    if (block) {
        block();
    }
    selectionChangedBySelf = NO;
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
    
    NodeItem *selectedNode = nil;
    // 方向によって回転数を上げ下げ
    switch (theEvent.keyCode) {
        case RotationDirectionLeft:
            // left
            rotationCount--;
            if (self.selectedNode.previousNode){
                NodeItem *previous = self.selectedNode.previousNode;
                if (self.selectedNode.parent == previous) {
                    // 親への移動なら現在のexpandを閉じる
                    [self changeSelectionProgramatically:^{
                        [self.outlineView collapseItem:self.selectedTreeNode.parentNode collapseChildren:YES];
                    }];
                    selectedNode = previous;
                }else{
                    // バックワードの移動なら
                    if (previous.children) {
                        //次の要素に子どもが居たら末子
                        selectedNode = previous.children.lastObject;
                    }else{
                        // 居なければ前
                        selectedNode = previous;
                    }
                }
            }
            break;
        case RotationDirectionRight:
            // right
            rotationCount++;
            if (self.selectedNode.children) {
                // 現在が内部ノードなら子の最初
                selectedNode = self.selectedNode.children.firstObject;
            }else{
                // 次のノードがあれば
                if (self.selectedNode.nextNode) {
                    // 次
                    NodeItem *next =  self.selectedNode.nextNode;
                    // 別階層への移動なら現在のexpandを閉じる
                    if (self.selectedNode.parent != next.parent) {
                        [self changeSelectionProgramatically:^{
                            [self.outlineView collapseItem:self.selectedTreeNode.parentNode collapseChildren:YES];
                        }];
                    }
                    selectedNode = next;
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
    NSLog(@"%@ was selected",selectedNode);
    if (selectedNode) {
        [self setSelectedNode:selectedNode];
    }
    [self.label setIntegerValue:rotationCount];
}

#pragma mark - NSOutlineView delegate

- (void)outlineViewSelectionDidChange:(NSNotification *)notification
{
    NSInteger row = [self.outlineView selectedRow];
    self.selectedTreeNode = [self.outlineView itemAtRow:row];
    // プログラム上での選択変更でない <=> クリックでの操作変更の場合
//    if (!selectionChangedBySelf) {
//        NodeItem *item = self.selectedTreeNode.representedObject;
//        if (!item) {
//            
//        }
//        [self setSelectedNode:item];
//        NSLog(@"%@",item);
//    }
}

@end
