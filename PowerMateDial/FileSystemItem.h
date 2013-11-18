//
//  PMDAppDelegate.h
//  PowerMateDial
//
//  Created by 桜井雄介 on 2013/11/11.
//  Copyright (c) 2013年 Yusuke Sakurai. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface FileSystemItem : NSObject <NSCoding, NSCopying>

@property (strong) NSString *title;
@property (strong) NSImage *iconImage;
@property (strong) NSArray *children;
@property (strong) NSString *urlString;
@property (assign) BOOL isLeaf;

- (id)initLeaf;

- (BOOL)isDraggable;

- (NSComparisonResult)compare:(FileSystemItem *)aNode;

- (NSArray *)mutableKeys;

- (NSDictionary *)dictionaryRepresentation;
- (id)initWithDictionary:(NSDictionary *)dictionary;

- (id)parentFromArray:(NSArray *)array;
//- (void)removeObjectFromChildren:(id)obj;
- (NSArray *)descendants;
- (NSArray *)allChildLeafs;
- (NSArray *)groupChildren;
- (BOOL)isDescendantOfOrOneOfNodes:(NSArray *)nodes;
- (BOOL)isDescendantOfNodes:(NSArray *)nodes;
- (NSIndexPath *)indexPathInArray:(NSArray *)array;

@end
