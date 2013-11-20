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
#define SNAP_THRESHOLD 10
#define SnapDepthNone NSUIntegerMax

typedef enum NSUInteger{
    PowerMateActionRotationLeft = 123,
    PowerMateActionRotationRight = 124
}PowerMateAction;


@interface MainWindowController ()
{
    // シークエンスの回転数。正負は左右と対応
    NSInteger rotationCount;
    //
    NSUInteger rotationToLeft;
    //
    NSUInteger rotationToRight;
    // シークエンス終了検知のためのタイマー
    NSTimer *timer;
    // ノードの選択がプログラム中で行われたか
    // <=> PowerMate経由での選択かを判別するためのフラグ
    BOOL selectionChangedBySelf;
    // 次のスナップの単位が変わるとき
    NSUInteger nextThreshold;
    // 現在スナップしている階層
    NSUInteger snapDepth;
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
//    self.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES]];
//    NSURL *treeURL = [NodeItem homeURL];
    NodeItem *rootNode = [NodeItem rootNodeWithJSON];
    //    NSURL *treeURL = [NodeItem contentTreeURL];
    [self setRootNode:rootNode];
    nextThreshold = SNAP_THRESHOLD;
    snapDepth = SnapDepthNone;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
}

- (void)finishRotation
{
    NSLog(@"rotation finished direction:times: %li",(long)rotationCount);
    rotationCount = 0;
    rotationToRight = 0;
    rotationToLeft = 0;
    nextThreshold = SNAP_THRESHOLD;
    snapDepth = SnapDepthNone;
    [self.label setTextColor:[NSColor redColor]];
}

- (void)setRootNode:(NodeItem *)rootNode
{
    if (rootNode != _rootNode) {
        _rootNode = rootNode;
        self.contents = @[rootNode];
        self.selectedNode = rootNode.children.firstObject;
    }
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
    if (ext) {
        NSRange result = [regexp rangeOfFirstMatchInString:ext options:0 range:NSMakeRange(0, ext.length)];
        if (result.location != NSNotFound){
            NSImage *image = [[NSImage alloc] initWithContentsOfFile:url.path];
            self.imageView.image = image;
        }
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
    
    // アクションによって
    PowerMateAction action = theEvent.keyCode;
    switch (action) {
        case PowerMateActionRotationLeft:
            rotationCount--;
            rotationToLeft++;
            break;
        case PowerMateActionRotationRight:
            rotationCount++;
            rotationToLeft++;
            break;
        default:
            break;
    }
    // 回転が閾値を超えたら
    if ((NSUInteger)ABS(rotationCount) > nextThreshold) {
        // スナップする深さを固定
        nextThreshold += SNAP_THRESHOLD;
        snapDepth = self.selectedNode.parent.indexPath.length;
        // 今の階層を一旦閉じて
        [self changeSelectionProgramatically:^{
            [self.outlineView collapseItem:self.selectedTreeNode.parentNode collapseChildren:YES];
        }];
        // 親の次に移動
        [self setSelectedNode:self.selectedNode.parent.nextNode];
    }
    // ノードの移動
    NodeItem *selectedNode = [self nodeItemWithAction:action];
    NSLog(@"%@ was selected",selectedNode);
    if (selectedNode) {
        [self setSelectedNode:selectedNode];
    }
    [self.label setIntegerValue:rotationCount];
}

- (NodeItem*)nodeItemWithAction:(PowerMateAction)action
{
    switch (action) {
        case PowerMateActionRotationLeft:
            // left
            if (snapDepth == SnapDepthNone) {
                // スナップ中でないなら
                NodeItem *previous = self.selectedNode.previousNode;
                if(!previous) return nil;
                
                if (self.selectedNode.parent == previous) {
                    // 親への移動なら現在のexpandを閉じる
                    [self changeSelectionProgramatically:^{
                        [self.outlineView collapseItem:self.selectedTreeNode.parentNode collapseChildren:YES];
                    }];
                    return previous;
                }else{
                    // バックワードの移動なら
                    if (previous.children) {
                        //次の要素に子どもが居たら末子
                        return previous.children.lastObject;
                    }else{
                        // 居なければ前
                        return previous;
                    }
                }
            }else{
                // スナップ中なら
                
            }
            break;
        case PowerMateActionRotationRight:
            // right
            if (snapDepth == SnapDepthNone) {
                // スナップ中でないなら
                if (self.selectedNode.children) {
                    // 子供がいるなら
                    // 最初の子
                    return self.selectedNode.children.firstObject;
                }else{
                    // 居ないなら
                    if (self.selectedNode.nextNode) {
                        // 次があれば
                        NodeItem *next =  self.selectedNode.nextNode;
                        // 別階層への移動なら現在のexpandを閉じる
                        if (self.selectedNode.parent != next.parent) {
                            // スナップを一つ上に
                            snapDepth--;
                            nextThreshold -= nextThreshold%SNAP_THRESHOLD;
                            [self changeSelectionProgramatically:^{
                                [self.outlineView collapseItem:self.selectedTreeNode.parentNode collapseChildren:YES];
                            }];
                        }
                        return next;
                    }
                }
            }else{
                // スナップ中なら
                if (self.selectedNode.nextNode) {
                    NodeItem *next = self.selectedNode.nextNode;
                    // 次は同階層か？
                    // 別階層への移動なら現在のexpandを閉じる
                    if (self.selectedNode.parent != next.parent) {
                        // スナップを一つ上に
                        snapDepth--;
                        nextThreshold -= nextThreshold%SNAP_THRESHOLD;
                        [self changeSelectionProgramatically:^{
                            [self.outlineView collapseItem:self.selectedTreeNode.parentNode collapseChildren:YES];
                        }];
                    }
                    return next;
                }
            }
            
    }
    return nil;
}

#pragma mark - NSOutlineView delegate

- (void)outlineViewSelectionDidChange:(NSNotification *)notification
{
    NSInteger row = [self.outlineView selectedRow];
    self.selectedTreeNode = [self.outlineView itemAtRow:row];
    // プログラム上での選択変更でない <=> クリックでの操作変更の場合
    if (!selectionChangedBySelf) {
        NodeItem *item = self.selectedTreeNode.representedObject;
        if (item) {
            [self setSelectedNode:item];
        }
        NSLog(@"%@",item);
    }
}

@end
