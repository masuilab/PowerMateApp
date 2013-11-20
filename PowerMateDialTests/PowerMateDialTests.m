//
//  PowerMateDialTests.m
//  PowerMateDialTests
//
//  Created by 桜井雄介 on 2013/11/18.
//  Copyright (c) 2013年 Yusuke Sakurai. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NodeItem.h"

@interface PowerMateDialTests : XCTestCase
{
    NSUInteger nodeCount;
    NodeItem *root;
}

@end

@implementation PowerMateDialTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    if (!root) {
        NSURL *url = [NodeItem contentTreeURL];
        root = [NodeItem rootNodeWithURL:url];
    }
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testTreeUrl
{
    NSURL *url = [NodeItem contentTreeURL];
    XCTAssertNotNil(url, );
}

- (void)testFileManager
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *e = nil;
    // pre-fetchするプロパティ一覧
    NSArray *props = @[NSURLIsDirectoryKey,NSURLEffectiveIconKey,NSURLNameKey,NSURLPathKey];
    NSArray *c = [fm contentsOfDirectoryAtURL:[NodeItem contentTreeURL] includingPropertiesForKeys:props options:NSDirectoryEnumerationSkipsHiddenFiles error:&e];
    XCTAssertNil(e, );
    XCTAssertNotNil(c, );
    NSLog(@"%@",c);
    for (NSURL *url in c) {
        NSDictionary *prop = [url resourceValuesForKeys:props error:&e];
        XCTAssertNil(e, );
        NSLog(@"%@",prop);
    }
}

- (void)testNodeItem
{
    // 深さ優先探索で全部のノードをテスト
    NSMutableArray *stack = @[].mutableCopy;
    [stack addObject:root];
    nodeCount = 0;
    NodeItem *item = nil;
    while (stack.count != 0) {
        item = [stack lastObject];
        [stack removeLastObject];
        XCTAssertNotNil(item, );
        XCTAssertNotNil(item.name, );
        XCTAssertNotNil(item.url, );
        XCTAssertNotNil(item.iconImage, );
        if (item.isLeaf) {
            XCTAssertNil(item.children, );
        }else{
            XCTAssertNotNil(item.children, );
            [stack addObjectsFromArray:item.children];
        }
        if (item != root) {
            XCTAssert(item.parent, );
            XCTAssert(item.indexPath, );
            XCTAssert([item.indexPath isKindOfClass:[NSIndexPath class]], );
        }
        nodeCount++;
    }
    NSLog(@"%@",item.indexPath);
}

- (void)testNodeLink
{
    NodeItem *item = root;
    NSUInteger _nodeCount = 0;
    do {
        if (item.children) {
            item = [[item children] firstObject];
        }else{
            item = [item nextNode];
        }
        _nodeCount++;
    } while (item.nextNode);
//    XCTAssert(nodeCount == _nodeCount,);
}

- (void)testDescendant
{
    NodeItem *cdl = [root closestDescendantLeaf];
    XCTAssert([cdl.name isEqualToString:@"add_file.py"], );
    NodeItem *fdl = [root farestDescendantLeaf];
    XCTAssert([fdl.name isEqualToString:@"tree.md"], );
}

- (void)testNumberOfDecsendant
{
    NSUInteger nod = [root numberOfDescendant];
    XCTAssert(nod > 9700, );
}

@end
