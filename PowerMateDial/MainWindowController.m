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
#define FINISH_TIMER_VALUE 1.3
#define SNAP_THRESHOLD 20
#define SNAP_LENGTH 5
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
    //
    NSOperationQueue *imageloadQueue;
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
@property (strong) IBOutlet NSPanel *debugWindow;

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
    imageloadQueue = [[NSOperationQueue alloc] init];
    [self setRootNode:rootNode];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
#ifdef Release
    [self.debugWindow close];
#endif
}

- (void)finishRotation
{
    NSLog(@"rotation finished direction:times: %li",(long)rotationCount);
    // 選択されたノードがコンテナだった場合直近の子孫の葉を選択
    [self setSelectedNode:self.selectedNode.closestDescendantLeaf silent:YES];
    // 計算
    [self calculateSnapArray];
    // 写真の場合コンテンツを再表示
//    if ([self isImageResource:self.selectedNode.url]){
//        [self showFile:self.selectedNode.url];
//    }
    // リセット
    rotationCount = 0;
    lastAction = 0;
    [self.label setTextColor:[NSColor redColor]];
    [self.label setIntegerValue:rotationCount];
}

- (void)calculateSnapArray
{
    // snapHashをリセット
    [snapHash removeAllObjects];
    [snapHash setObject:self.selectedNode forKey:@0];
    maxBackwordIndex = maxForwardIndex = 0;
    // 前方向への道筋を計算
    NodeItem *item = self.selectedNode;
    NSUInteger snapUnitInCurrentDepth = 1;
    while (item) {
        // itemは必ず葉なので一定の回数移動したら移動距離を増やす
        // 1,2,3,4,5,10,20,30,40,50,100,...........
        if (item.parent) {
            NSArray *forwards = [item youngerBrothers];
            int i ,cnt , snaplength;
            for (i = 0, cnt = 0, snaplength = 1; i < (int)forwards.count; i+=snaplength, cnt++) {
                NodeItem *next = [forwards objectAtIndex:i];
                // 階層によって回転の精度を下げる
                for (NSUInteger j = 0; j < snapUnitInCurrentDepth; j++) {
                    maxForwardIndex++;
                    [snapHash setObject:next forKey:@(maxForwardIndex)];
                }
                if (cnt != 0 && cnt%SNAP_THRESHOLD == 0) {
                    // 1,5,10,15,20
                    snaplength += SNAP_LENGTH;
                }
            }
            // 同階層フォワードスナップの最後は末弟
            if (forwards.count > 0 && [snapHash objectForKey:@(maxForwardIndex)] != forwards.lastObject) {
                maxForwardIndex++;
                [snapHash setObject:forwards.lastObject forKey:@(maxForwardIndex)];
            }
        }
        snapUnitInCurrentDepth++;
        item = item.parent;
    }
    // 後ろへの道筋を計算
    item = self.selectedNode;
    snapUnitInCurrentDepth = 1;
    while (item) {
        // itemは必ず葉なので一定の回数移動したら移動距離を増やす
        if (item.parent) {
            NSArray *backwards = [item elderBrothers];
            // ルートまでは戻らない
            if (item.parent != self.rootNode) {
                backwards  = [@[item.parent] arrayByAddingObjectsFromArray:backwards];
            }
            int i ,cnt , snaplength;
            for (i = (int)backwards.count-1, cnt = 0, snaplength = 1; i >= 0; i-=snaplength, cnt++) {
                NodeItem *prev = [backwards objectAtIndex:i];
                for (NSUInteger j = 0; j < snapUnitInCurrentDepth; j++) {
                    maxBackwordIndex--;
                    [snapHash setObject:prev forKey:@(maxBackwordIndex)];
                }
                if (cnt != 0 && cnt%SNAP_THRESHOLD == 0) {
                    // 1,5,10,15,20
                    snaplength += SNAP_LENGTH;
                }
            }
            // 同階層のバックスナップの最後は長兄
            if(backwards.count > 0 && [snapHash objectForKey:@(maxBackwordIndex)] != backwards.firstObject){
                maxBackwordIndex--;
                [snapHash setObject:backwards.firstObject forKey:@(maxBackwordIndex)];
            }
        }
        snapUnitInCurrentDepth++;
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
                if ([self isImageResource:self.selectedNode.url]) {
                    [self showFile:[self imageURLWithLargeSize:self.selectedNode.url]];
                }else{
                    [self showFile:self.selectedNode.url];
                }
//                NSLog(@"%@",selectedNode.url);
            }
            // スクロールビューをセンタリングスナップする
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

- (BOOL)isImageResource:(NSURL*)URL
{
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(jpg|png)" options:NSRegularExpressionCaseInsensitive error:nil];
    NSString *str = URL.pathExtension;
    NSRange range = [regex rangeOfFirstMatchInString:str options:0 range:NSMakeRange(0, str.length)];
    return (range.location != NSNotFound);
}

- (NSURL*)imageURLWithLargeSize:(NSURL*)URL
{
    NSError *e = nil;
    NSString *pat = @"http:\\/\\/masui\\.sfc\\.keio\\.ac\\.jp\\/Photos\\/(.+?)\\.(jpg|png)";
    NSString *urlstr = URL.absoluteString;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pat
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&e];
    NSTextCheckingResult *result = [regex firstMatchInString:urlstr
                                                     options:0
                                                       range:NSMakeRange(0, urlstr.length)];
    if (result) {
        urlstr = [urlstr stringByReplacingOccurrencesOfString:@".jpg" withString:@"l.jpg"];
        urlstr = [urlstr stringByReplacingOccurrencesOfString:@".png" withString:@"l.png"];
        return [NSURL URLWithString:urlstr];
    }
    return URL;
}

- (void)showFile:(NSURL*)url
{
    if ([self isImageResource:url]) {
        [self.webView setHidden:YES];
        [self.imageView setHidden:NO];
        NSURLRequest *req = [NSURLRequest requestWithURL:url];
        __block __weak typeof (self) __self = self;
        [NSURLConnection sendAsynchronousRequest:req queue:imageloadQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            if (!connectionError) {
                NSURL *curentURL = [[__self selectedNode] url];
                if ([curentURL.absoluteString isEqualToString:url.absoluteString]) {
                    NSImage *iamge = [[NSImage alloc] initWithData:data];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.imageView setImage:iamge];
                    });
                }
            }
        }];
        [self.imageView setImageWithURL:url placeholderImage:nil];
    }else{
        [self.imageView setHidden:YES];
        [self.webView setHidden:NO];
        // request
        NSURLRequest *req = [NSURLRequest requestWithURL:url];
        [self.webView.mainFrame stopLoading];
        [self.webView.mainFrame loadRequest:req];
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
    // 文字色を戻す
    if (rotationCount == 0) {
        [self.label setTextColor:[NSColor alternateSelectedControlTextColor]];
    }
    // 回転終了のチェック
    [timer invalidate];
    timer = [NSTimer scheduledTimerWithTimeInterval:FINISH_TIMER_VALUE target:self selector:@selector(finishRotation) userInfo:nil repeats:NO];
    
    // アクションによって
    PowerMateAction action = theEvent.keyCode;
    switch (action) {
        case PowerMateActionRotationLeft:
            if(maxBackwordIndex < rotationCount){
                rotationCount--;
            }
            break;
        case PowerMateActionRotationRight:
            if (rotationCount < maxForwardIndex) {
                rotationCount++;
            }
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
    // プログラム上での選択変更でない <=> クリックでの操作変更の場合にプログラム中に反映
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
//    NSLog(@"load finished");
    [self.indicator stopAnimation:self];
    // web viewにフォーカスがあたるとイベントが効かなくなるためレスポンダを変える
    [self.window makeFirstResponder:self.outlineView];
}

- (void)webView:(WebView *)sender didStartProvisionalLoadForFrame:(WebFrame *)frame
{
//    NSLog(@"start loading frame");
    [self.indicator startAnimation:self];
}

@end
