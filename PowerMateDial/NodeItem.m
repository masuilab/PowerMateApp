//
//  PMDAppDelegate.m
//  PowerMateDial
//
//  Created by 桜井雄介 on 2013/11/11.
//  Copyright (c) 2013年 Yusuke Sakurai. All rights reserved.
//

#import "NodeItem.h"

static NSMutableDictionary *iconImageCache;

@interface NodeItem()
// コンストラクタ
- (instancetype)initWithURL:(NSURL*)url parent:(NodeItem*)parent index:(NSUInteger)index;
- (instancetype)initWithDictionary:(NSDictionary*)dictionary parent:(NodeItem *)parent index:(NSUInteger)index;

@end

@implementation NodeItem

@synthesize title = _title;

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

+ (NSURL*)homeURL
{
    NSString *un = NSUserName();
    NSError *e = nil;
    NSURL *url = [NSURL fileURLWithPath:[@"/Users/" stringByAppendingPathComponent:un]];
    NSArray *resources = [[NSFileManager defaultManager]
                          contentsOfDirectoryAtURL:url
                          includingPropertiesForKeys:kFetchProperties
                          options:NSDirectoryEnumerationSkipsHiddenFiles
                          error:&e];
    for (NSURL *url in resources) {
        if ([url.path rangeOfString:@"Pictures"].location != NSNotFound) {
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

+ (instancetype)rootNodeWithJSON
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"json"];
    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
    NSError *e = nil;
    NSArray *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&e];
    NSMutableDictionary *root = @{@"title": @"root"}.mutableCopy;
    [root setObject:json forKey:@"children"];
    return [[self alloc] initWithDictionary:root parent:nil index:0];
}

- (instancetype)initWithDictionary:(NSDictionary*)dictionary parent:(NodeItem *)parent index:(NSUInteger)index
{
    if (self = [super init]) {
        _title = dictionary[@"title"];
        if (dictionary[@"url"]) {
            _url = [NSURL URLWithString:dictionary[@"url"]];
            NSError *e = nil;
            NSString *pat = @"http:\\/\\/masui\\.sfc\\.keio\\.ac\\.jp\\/Photos\\/(.+?)\\.(jpg|png)";
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pat options:NSRegularExpressionCaseInsensitive error:&e];
            NSString *url = dictionary[@"url"];
            NSTextCheckingResult *result = [regex firstMatchInString:url options:0 range:NSMakeRange(0, url.length)];
            if (result) {
                url = [url stringByReplacingOccurrencesOfString:@".jpg" withString:@"l.jpg"];
                url = [url stringByReplacingOccurrencesOfString:@".png" withString:@"l.png"];
            }
            _url = [NSURL URLWithString:url];
        }
        _parent = parent;
        _index = index;
        if (parent) {
            // 階層なら
            _indexPath = [self.parent.indexPath indexPathByAddingIndex:index];
        }else{
            // トップディレクトリなら
            _indexPath = [NSIndexPath indexPathWithIndex:0];
        }
        if (dictionary[@"children"]) {
            _isLeaf = NO;
        }else{
            _isLeaf = YES;
        }
        NSMutableArray *children = @[].mutableCopy;
        // 子供をインスタンス化
        if (!_isLeaf) {
            NSArray *childNodes = dictionary[@"children"];
            [childNodes enumerateObjectsUsingBlock:^(NSDictionary *childDict, NSUInteger idx, BOOL *stop) {
                // からオブジェクトが混ざってることがある
                if (childDict.keyEnumerator.allObjects.count != 0) {
                    NodeItem *newNode = [[NodeItem alloc] initWithDictionary:childDict parent:self index:idx];
                    [children addObject:newNode];
                }
            }];
            _children = children;
        }
    }
    return self;
}

- (instancetype)initWithURL:(NSURL *)url parent:(NodeItem *)parent index:(NSUInteger)index
{
    NSError *e = nil;
    NSDictionary *prop = [url resourceValuesForKeys:kFetchProperties error:&e];
    if (self = [super init]) {
        _iconImage = [[NSWorkspace sharedWorkspace] iconForFile:url.path];
        _title = prop[NSURLNameKey];
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

- (NSUInteger)numberOfDescendant
{
    NSUInteger sum = 0;
    for (NodeItem *i in self.children) {
        sum += i.numberOfDescendant;
    }
    return self.numberOfChildren+sum;
}

- (NSString *)path
{
    if (self.parent) {
        return [NSString stringWithFormat:@"%@/%@",self.parent.path,self.title];
    }
    return @"";
}

- (NSString *)title
{
    if (!_title) {
        return self.url.lastPathComponent;
    }
    return _title;
}

- (NSComparisonResult)compare:(NodeItem *)aNode
{
	return [[[self title] lowercaseString] compare:[[aNode title] lowercaseString]];
}

- (NodeItem *)nextNode
{
    if ([self.parent.children lastObject] != self) {
        // 階層で最後のオブジェクトでなければ
        return [self.parent.children objectAtIndex:self.index+1];
    }else{
        // 階層で最後のオブジェクトならば親のnextNode
        return nil;
    }
}

- (NodeItem *)previousNode
{
    if ([self.parent.children firstObject] != self) {
        // 階層で最初のオブジェクトでなければひとつindexが前
        return [self.parent.children objectAtIndex:self.index-1];
    }else{
        // 最初の子なら親
        return nil;
    }
}

- (NodeItem *)closestDescendantLeaf
{
    return [self _decsendantLeaf:YES];
}

- (NodeItem *)farestDescendantLeaf
{
    return [self _decsendantLeaf:NO];
}

- (NodeItem*)_decsendantLeaf:(BOOL)closest
{
    NodeItem *item = self;
    while (!item.isLeaf) {
        item = (closest) ? item.children.firstObject : item.children.lastObject;
    }
    return item;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@",self.title];
}

@end
