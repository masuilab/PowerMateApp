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
#define SNAP_THRESHOLD 20
#define SnapDepthNone NSUIntegerMax

typedef enum NSUInteger{
    PowerMateActionRotationLeft = 123,
    PowerMateActionRotationRight = 124
}PowerMateAction;


@interface MainWindowController ()
{
    // シークエンスの回転数。正負は左右と対応
    NSInteger rotationCount;
    // シークエンス終了検知のためのタイマー
    NSTimer *timer;
    // ノードの選択がプログラム中で行われたか
    // <=> PowerMate経由での選択かを判別するためのフラグ
    BOOL selectionChangedBySelf;
    // スナップに用いる配列
    NSMutableDictionary *snapHash;
    // 現在の前方向への最大移動値
    NSInteger maxForwardIndex;
    // 現在の後ろ方向への最大移動値
    NSInteger maxBackwordIndex;
    // 最後のアクション
    PowerMateAction lastAction;
}

/* View Outlets */
@property (weak) IBOutlet NSSplitView *splitView;
@property (weak) IBOutlet NSOutlineView *outlineView;
@property (strong) IBOutlet NSTreeController *treeController;
@property (weak) IBOutlet NSTableColumn *tableColumn;
@property (weak) IBOutlet NSTextField *label;
@property (weak) IBOutlet NSImageView *imageView;
@property (weak) IBOutlet WebView *webView;
@property (weak) IBOutlet NSPathControl *pathControl;
@property (weak) IBOutlet NSProgressIndicator *indicator;
@property (weak) IBOutlet NSClipView *leftClipView;
@property (weak) IBOutlet NSScrollView *scrollView;

// 現在選択中のノード
@property (nonatomic) NodeItem *selectedNode;
@property (nonatomic) NSTreeNode *selectedTreeNode;

@end

@implementation MainWindowController

- (void)awakeFromNib
{
    [super awakeFromNib];
    snapHash = [NSMutableDictionary new];
    NodeItem *rootNode = [NodeItem rootNodeWithJSON];
    [self setRootNode:rootNode];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
}

- (void)finishRotation
{
    NSLog(@"rotation finished direction:times: %li",(long)rotationCount);
    // 計算
    [self calculateSnapArray];
    // リセット
    rotationCount = 0;
    lastAction = 0;
    [self.label setTextColor:[NSColor redColor]];
    [self.label setIntegerValue:rotationCount];
}

- (void)calculateSnapArray
{
    // ルートに戻った場合でないのみ回転方向によって子孫の葉を選択
    if (self.selectedNode != self.rootNode) {
        if (lastAction == PowerMateActionRotationRight) {
            // 右方向への回転で終わったら直近の子孫の葉を選択
            [self setSelectedNode:self.selectedNode.closestDescendantLeaf silent:YES];
        }else if (PowerMateActionRotationLeft) {
            // 左方向への回転で終わったら最遠の子孫の葉を選択
            [self setSelectedNode:self.selectedNode.farestDescendantLeaf silent:YES];
        }
    }else{
        [self setSelectedNode:self.rootNode.closestDescendantLeaf silent:YES];
    }
    
    // snapHashをリセット
    [snapHash removeAllObjects];
    [snapHash setObject:self.selectedNode forKey:@0];
    maxBackwordIndex = maxForwardIndex = 0;
    // 前方向への道筋を計算
    NodeItem *item = self.selectedNode;
    while (item) {
        // itemは必ず葉なので一定の回数移動したら移動距離を増やす
        NodeItem *next = item;
        for (NSUInteger i = 0; i < SNAP_THRESHOLD; i++) {
            next = next.nextNode;
            // 階層の最後に来たら次にとばす
            if (!next) {
                break;
            }
            maxForwardIndex++;
            [snapHash setObject:next forKey:@(maxForwardIndex)];
        }
        item = item.parent;
    }
    // 後ろへの道筋を計算
    item = self.selectedNode;
    while (item) {
        // itemは必ず葉なので一定の回数移動したら移動距離を増やす
        NodeItem *prev = item;
        for (NSUInteger i = 0; i < SNAP_THRESHOLD; i++) {
            prev = prev.previousNode;
            // 次が親ならば親を追加してbreak
            if (!prev) {
                if (item.parent) {
                    maxBackwordIndex--;
                    [snapHash setObject:item.parent forKey:@(maxBackwordIndex)];
                }
                break;
            }
            maxBackwordIndex--;
            [snapHash setObject:prev forKey:@(maxBackwordIndex)];
        }
        item = item.parent;
    }
    NSLog(@"caluculation finished");
    NSLog(@"%@",snapHash);
}

- (void)setRootNode:(NodeItem *)rootNode
{
    if (rootNode != _rootNode) {
        _rootNode = rootNode;
        self.contents = @[rootNode];
    }
}

- (void)setSelectedNode:(NodeItem *)selectedNode silent:(BOOL)silent
{
    if (selectedNode != _selectedNode) {
        void (^block)() = ^{
            _selectedNode = selectedNode;
            [self.treeController setSelectionIndexPath:selectedNode.indexPath];
            self.selectedIndexPaths = @[selectedNode.indexPath];
            // 葉ならファイルを表示
            if (selectedNode.isLeaf) {
                [self showFile:selectedNode.url];
                NSLog(@"%@",selectedNode.url);
            }
            // スクロールビューを移動する
//            NSView *contentView = self.scrollView.contentView;
//            NSPoint p = contentView.bounds.origin;
//            NSLog(@"%@",NSStringFromPoint(p));
////            p.y = CGRectGetHeight(contentView.bounds)/2 - self.leftClipView.documentVisibleRect.size.height/2;
//            [self.leftClipView scrollToPoint:p];
            NSInteger row = [self.outlineView rowForItem:self.selectedTreeNode];
            [self.outlineView scrollRowToVisible:row];
        };
        if (silent) {
            block();
        }else{
            [self changeSelectionProgramatically:^{
                block();
            }];
        }
        // PathControlを設定
        [self.pathControl setPathComponentCells:[self pathComponentArray]];
    }
}

- (NSArray *)pathComponentArray
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NodeItem *item = self.selectedNode;
    while (item.parent) {
        NSPathComponentCell *cell = [[NSPathComponentCell alloc] init];
        [cell setTitle:item.title];
        [cell setURL:item.url];
        [array insertObject:cell atIndex:0];
        item = item.parent;
    }
    return array;
}

- (void)setSelectedNode:(NodeItem *)selectedNode
{
    [self setSelectedNode:selectedNode silent:NO];
}

- (void)showFile:(NSURL*)url
{
//    NSError *e = nil;
//    NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:@"(png|jpg|gif)" options:NSRegularExpressionCaseInsensitive error:&e];
//    NSString *ext = url.pathExtension;
//    if (ext) {
//        NSRange result = [regexp rangeOfFirstMatchInString:ext options:0 range:NSMakeRange(0, ext.length)];
//        if (result.location != NSNotFound){
//            NSImage *image = [[NSImage alloc] initWithContentsOfFile:url.path];
//            self.imageView.image = image;
//        }
//    }
    
    // request
    NSURLRequest *req = [NSURLRequest requestWithURL:self.selectedNode.url];
    [self.webView.mainFrame stopLoading];
    [self.webView.mainFrame loadRequest:req];
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
            break;
        case PowerMateActionRotationRight:
            rotationCount++;
            break;
        default:
            break;
    }
    // 移動可能なノードがsnapHashに存在する場合のみ
    if (maxBackwordIndex <= rotationCount && rotationCount <= maxForwardIndex){
        NodeItem *selectedNode = [snapHash objectForKey:@(rotationCount)];
        // 階層が上がった場合は閉じる
        if (selectedNode == self.selectedNode.parent ||
            selectedNode == self.selectedNode.parent.nextNode) {
            [self changeSelectionProgramatically:^{
                [self.outlineView collapseItem:self.selectedTreeNode.parentNode collapseChildren:YES];
            }];
        }
        NSLog(@"%@ was selected",selectedNode);
        [self setSelectedNode:selectedNode];
        [self.label setIntegerValue:rotationCount];
    }
    lastAction = action;
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
            [self setSelectedNode:item.closestDescendantLeaf];
        }
        [self finishRotation];
    }
}

#pragma mark - WebView

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame
{
    NSLog(@"load finished");
    [self.indicator stopAnimation:self];
    // web viewにフォーカスがあたるとイベントが効かなくなるため
    [self.window makeFirstResponder:self.outlineView];
}

- (void)webView:(WebView *)sender didStartProvisionalLoadForFrame:(WebFrame *)frame
{
    NSLog(@"start loading frame");
    [self.indicator startAnimation:self];
}

@end
