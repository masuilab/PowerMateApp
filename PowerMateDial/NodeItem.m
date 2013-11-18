//
//  PMDAppDelegate.m
//  PowerMateDial
//
//  Created by 桜井雄介 on 2013/11/11.
//  Copyright (c) 2013年 Yusuke Sakurai. All rights reserved.
//

#import "NodeItem.h"

#define kFetchProperties @[NSURLIsDirectoryKey,NSURLEffectiveIconKey,NSURLNameKey,NSURLPathKey]
@interface NodeItem()
// コンストラクタ
- (instancetype)initWithURL:(NSURL*)url parent:(NodeItem*)parent;

@end

@implementation NodeItem

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
    return [[self alloc] initWithURL:url parent:nil];
}

- (instancetype)initWithURL:(NSURL *)url parent:(NodeItem *)parent
{
    NSError *e = nil;
    NSDictionary *prop = [url resourceValuesForKeys:kFetchProperties error:&e];
    if (self = [super init]) {
        _iconImage = prop[NSURLEffectiveIconKey];
        _name = prop[NSURLNameKey];
        _url = url;
        _parent = parent;
        _isLeaf = ![prop[NSURLIsDirectoryKey] boolValue];
        NSMutableArray *children = @[].mutableCopy;
        // 子供をインスタンス化
        if (!_isLeaf) {
            NSArray *childNodes = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:url includingPropertiesForKeys:kFetchProperties options:NSDirectoryEnumerationSkipsHiddenFiles error:&e];
            for (NSURL *childURL in childNodes) {
                NodeItem *newNode = [[NodeItem alloc] initWithURL:childURL parent:self];
                [children addObject:newNode];
            }
            _children = children;
        }
    }
    return self;
}

// -------------------------------------------------------------------------------
//	compare:aNode
// -------------------------------------------------------------------------------
- (NSComparisonResult)compare:(NodeItem *)aNode
{
	return [[[self name] lowercaseString] compare:[[aNode name] lowercaseString]];
}


#pragma mark - Drag and Drop

// -------------------------------------------------------------------------------
//	parentFromArray:array
//
//	Finds the receiver's parent from the nodes contained in the array.
// -------------------------------------------------------------------------------
- (id)parentFromArray:(NSArray *)array
{
	id result = nil;
	
	for (id node in array)
	{
		if (node == self)	// If we are in the root array, return nil
			break;
		
		if ([[node children] indexOfObjectIdenticalTo:self] != NSNotFound)
        {
            result = node;
            break;
        }
            
		if (![node isLeaf])
		{
			id innerNode = [self parentFromArray:[node children]];
			if (innerNode)
			{
				result = innerNode;
				break;
			}
		}
	}
    
	return result;
}

// -------------------------------------------------------------------------------
//	descendants
//
//	Generates an array of all descendants.
// -------------------------------------------------------------------------------
- (NSArray *)descendants
{
    NSMutableArray	*descendants = [NSMutableArray array];
	id node = nil;
	for (node in self.children)
	{
		[descendants addObject:node];
		
		if (![node isLeaf])
			[descendants addObjectsFromArray:[node descendants]];	// Recursive - will go down the chain to get all
	}
	return descendants;
}

// -------------------------------------------------------------------------------
//	allChildLeafs:
//
//	Generates an array of all leafs in children and children of all sub-nodes.
//	Useful for generating a list of leaf-only nodes.
// -------------------------------------------------------------------------------
- (NSArray *)allChildLeafs
{
    NSMutableArray	*childLeafs = [NSMutableArray array];
	id node = nil;
	
	for (node in self.children)
	{
		if ([node isLeaf])
			[childLeafs addObject:node];
		else
			[childLeafs addObjectsFromArray:[node allChildLeafs]];	// Recursive - will go down the chain to get all
	}
	return childLeafs;
}

// -------------------------------------------------------------------------------
//	groupChildren
//
//	Returns only the children that are group nodes.
// -------------------------------------------------------------------------------
- (NSArray *)groupChildren
{
    NSMutableArray	*groupChildren = [NSMutableArray array];
	NodeItem		*child;
	
	for (child in self.children)
	{
		if (![child isLeaf])
			[groupChildren addObject:child];
	}
	return groupChildren;
}

// -------------------------------------------------------------------------------
//	isDescendantOfOrOneOfNodes:nodes
//
//	Returns YES if self is contained anywhere inside the children or children of
//	sub-nodes of the nodes contained inside the given array.
// -------------------------------------------------------------------------------
- (BOOL)isDescendantOfOrOneOfNodes:(NSArray *)nodes
{
    // returns YES if we are contained anywhere inside the array passed in, including inside sub-nodes
 	id node = nil;
    for (node in nodes)
	{
		if (node == self)
			return YES;		// we found ourselv
		
		// check all the sub-nodes
		if (![node isLeaf])
		{
			if ([self isDescendantOfOrOneOfNodes:[node children]])
				return YES;
		}
    }
	
    return NO;
}

// -------------------------------------------------------------------------------
//	isDescendantOfNodes:nodes
//
//	Returns YES if any node in the array passed in is an ancestor of ours.
// -------------------------------------------------------------------------------
- (BOOL)isDescendantOfNodes:(NSArray *)nodes
{
	id node = nil;
    for (node in nodes)
	{
		// check all the sub-nodes
		if (![node isLeaf])
		{
			if ([self isDescendantOfOrOneOfNodes:[node children]])
				return YES;
		}
    }
    
	return NO;
}

// -------------------------------------------------------------------------------
//	indexPathInArray:array
//
//	Returns the index path of within the given array, useful for drag and drop.
// -------------------------------------------------------------------------------
- (NSIndexPath *)indexPathInArray:(NSArray *)array
{
	NSIndexPath	*indexPath = nil;
	NSMutableArray *reverseIndexes = [NSMutableArray array];
	id parent, doc = self;
	NSInteger index;
	
	parent = [doc parentFromArray:array];
    while (parent)
	{
		index = [[parent children] indexOfObjectIdenticalTo:doc];
		if (index == NSNotFound)
			return nil;
		
		[reverseIndexes addObject:@(index)];
		doc = parent;
	}
	
	// If parent is nil, we should just be in the parent array
	index = [array indexOfObjectIdenticalTo:doc];
	if (index == NSNotFound)
		return nil;
	[reverseIndexes addObject:@(index)];
	
	// now build the index path
    NSEnumerator *re = [reverseIndexes reverseObjectEnumerator];
    NSNumber *indexNumber;
    for (indexNumber in re)
    {
        if (indexPath == nil)
            indexPath = [NSIndexPath indexPathWithIndex:[indexNumber intValue]];
        else
            indexPath = [indexPath indexPathByAddingIndex:[indexNumber intValue]];
    }
	
	return indexPath;
}

@end
