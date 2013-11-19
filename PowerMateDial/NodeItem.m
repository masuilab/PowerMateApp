//
//  PMDAppDelegate.m
//  PowerMateDial
//
//  Created by 桜井雄介 on 2013/11/11.
//  Copyright (c) 2013年 Yusuke Sakurai. All rights reserved.
//

#import "NodeItem.h"

#define kFetchProperties @[NSURLIsDirectoryKey,NSURLNameKey,NSURLPathKey]

static NSMutableDictionary *iconImageCache;

@interface NodeItem()
// コンストラクタ
- (instancetype)initWithURL:(NSURL*)url parent:(NodeItem*)parent index:(NSUInteger)index;

@end

@implementation NodeItem

+ (void)load
{
    [super load];
    iconImageCache = @{}.mutableCopy;
}

+ (NSURL *)contentTreeURL
{
    // リソースのTreeディレクトリを取得
    NSError *e = nil;
    NSArray *resources = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:[[NSBundle mainBundle] resourceURL]  includingPropertiesForKeys:kFetchProperties options:NSDirectoryEnumerationSkipsHiddenFiles error:&e];
    for (NSURL *url in resources) {
        if ([url.path rangeOfString:@"Tree"].location != NSNotFound) {
            return url;
        }
    }
    // 来ない
    return nil;
}

+ (instancetype)rootNodeWithURL:(NSURL *)url
{
    return [[self alloc] initWithURL:url parent:nil index:0];
}

- (instancetype)initWithURL:(NSURL *)url parent:(NodeItem *)parent index:(NSUInteger)index
{
    NSError *e = nil;
    NSDictionary *prop = [url resourceValuesForKeys:kFetchProperties error:&e];
    if (self = [super init]) {
        _iconImage = [[NSWorkspace sharedWorkspace] iconForFile:url.path];
        _name = prop[NSURLNameKey];
        _url = url;
        _parent = parent;
        _index = index;
        if (parent) {
            // 階層なら
            _indexPath = [self.parent.indexPath indexPathByAddingIndex:index];
        }else{
            // トップディレクトリなら
            _indexPath = [NSIndexPath indexPathWithIndex:0];
        }
        _isLeaf = ![prop[NSURLIsDirectoryKey] boolValue];
        NSMutableArray *children = @[].mutableCopy;
        // 子供をインスタンス化
        if (!_isLeaf) {
            NSArray *childNodes = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:url includingPropertiesForKeys:kFetchProperties options:NSDirectoryEnumerationSkipsHiddenFiles error:&e];
            [childNodes enumerateObjectsUsingBlock:^(NSURL *childURL, NSUInteger idx, BOOL *stop) {
                NodeItem *newNode = [[NodeItem alloc] initWithURL:childURL parent:self index:idx];
                [children addObject:newNode];
            }];
            _children = children;
        }        
    }
    return self;
}

- (NSUInteger)numberOfChildren
{
    return self.children.count;
}

- (NSComparisonResult)compare:(NodeItem *)aNode
{
	return [[[self name] lowercaseString] compare:[[aNode name] lowercaseString]];
}

- (NodeItem *)nextNode
{
    if ([self.parent.children lastObject] != self) {
        // 階層で最後のオブジェクトでなければ
        return [self.parent.children objectAtIndex:self.index+1];
    }else{
        // 階層で最後のオブジェクトならば親のnextNode
        return self.parent.nextNode;
    }
}

- (NodeItem *)previousNode
{
    if ([self.parent.children firstObject] != self) {
        return [self.parent.children objectAtIndex:self.index-1];
    }else{
        return self.parent.previousNode;
    }
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<NodeItem: %@>",self.name];
}

@end
