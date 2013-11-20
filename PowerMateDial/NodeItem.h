//
//  PMDAppDelegate.h
//  PowerMateDial
//
//  Created by 桜井雄介 on 2013/11/11.
//  Copyright (c) 2013年 Yusuke Sakurai. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NodeItem : NSObject

// ノードの名前。ファイル名orディレクトリ名
@property (readonly) NSString *name;
// アイコンの画像
@property (readonly) NSImage *iconImage;
// 子ノード
@property (readonly) NSArray *children;
// ノードのファイルシステム上でのURL
@property (readonly) NSURL *url;
// ノードが葉かどうか <=> ファイルかどうか
@property (readonly) BOOL isLeaf;
// あれば親
@property (readonly) NodeItem *parent;
// グラフの中でのindex path
@property (readonly) NSIndexPath *indexPath;
// 同階層の中での順番
@property (readonly) NSUInteger index;

+ (NSURL*)contentTreeURL;
+ (NSURL*)homeURL;

// ルートオブジェクトを生成する
+ (instancetype)rootNodeWithURL:(NSURL*)url;

// 同階層の次のノード
- (NodeItem*)nextNode;
// 同階層の前のノード
- (NodeItem*)previousNode;
// 最も近い子孫の葉
- (NodeItem*)closestDescendantLeaf;
// 最も遠い子孫の葉
- (NodeItem*)farestDescendantLeaf;
// KVO用の子要素のカウントプロパティ
- (NSUInteger)numberOfChildren;
// 子孫の数
- (NSUInteger)numberOfDescendant;
// compare
- (NSComparisonResult)compare:(NodeItem *)aNode;

@end
