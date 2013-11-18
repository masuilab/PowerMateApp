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

+ (NSURL*)contentTreeURL;
// ルートオブジェクトを生成する
+ (instancetype)rootNodeWithURL:(NSURL*)url;

- (NSComparisonResult)compare:(NodeItem *)aNode;

- (NSArray *)descendants;
- (NSArray *)allChildLeafs;
- (NSArray *)groupChildren;
- (BOOL)isDescendantOfOrOneOfNodes:(NSArray *)nodes;
- (BOOL)isDescendantOfNodes:(NSArray *)nodes;
- (NSIndexPath *)indexPathInArray:(NSArray *)array;

@end
