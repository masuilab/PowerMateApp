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
    NodeItem *jsonRoot;
}

@end

@implementation PowerMateDialTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    if (!root) {
//        NSURL *url = [NodeItem homeURL];
        root = [NodeItem rootNodeWithJSON];
    }
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testFileManager
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *e = nil;
    // pre-fetchするプロパティ一覧
    NSArray *props = @[NSURLIsDirectoryKey,NSURLEffectiveIconKey,NSURLNameKey,NSURLPathKey];
    NSArray *c = [fm contentsOfDirectoryAtURL:[NodeItem homeURL] includingPropertiesForKeys:props options:NSDirectoryEnumerationSkipsHiddenFiles error:&e];
    XCTAssertNil(e, );
    XCTAssertNotNil(c, );
//    NSLog(@"%@",c);
    for (NSURL *url in c) {
        NSDictionary *prop = [url resourceValuesForKeys:props error:&e];
        XCTAssertNotNil(prop, );
        XCTAssertNil(e, );
//        NSLog(@"%@",prop);
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
        XCTAssertNotNil(item.title, );
//        XCTAssertNotNil(item.url, );
//        XCTAssertNotNil(item.iconImage, );
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
//    NSUInteger nod = [root numberOfDescendant];
//    XCTAssert(_nodeCount == nod + 1,);
}

//- (void)testDescendant
//{
//    NodeItem *cdl = [root closestDescendantLeaf];
//    XCTAssert([cdl.title isEqualToString:@"add_file.py"], );
//    NodeItem *fdl = [root farestDescendantLeaf];
//    XCTAssert([fdl.title isEqualToString:@"tree.md"], );
//}
//
- (void)testNumberOfDecsendant
{
    NSUInteger nod = [root numberOfDescendant];
    XCTAssert(nod > 9700, );
}

- (void)testLoadDataJson
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"json"];
    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
    NSError *e = nil;
    id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&e];
    XCTAssertNil(e, );
    XCTAssert([json isKindOfClass:[NSArray class]], );
    for (NSDictionary *d in json) {
        XCTAssertNotNil(d[@"title"], );
        NSLog(@"%@",d[@"title"]);
    }
}

- (void)testFronJSON
{
    
}

@end
