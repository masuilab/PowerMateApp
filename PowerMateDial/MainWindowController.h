//
//  PMFMainWindowController.h
//  PowerMateApp
//
//  Created by 桜井雄介 on 2013/11/18.
//  Copyright (c) 2013年 Yusuke Sakurai. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@class NodeItem;
@interface MainWindowController : NSWindowController
<NSOutlineViewDelegate>

/* 以下NSTreeControllerへのバインディングプロパティ　*/

//
@property (nonatomic,assign) NodeItem *rootNode;
// 全ノードが入っているグラフ
@property (assign) NSArray *contents;
// 現在選択中のノードへのIndexPath
@property (assign) NSArray *selectedIndexPaths;
// ノードの同階層での並び順のデスクリプタ
@property (assign) NSArray *sortDescriptors;

@end
