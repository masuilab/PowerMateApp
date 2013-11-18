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

@end

@implementation PowerMateDialTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
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
    NSURL *url = [NodeItem contentTreeURL];
    NodeItem *root = [NodeItem rootNodeWithURL:url];
    // 深さ優先探索で全部のノードをテスト
    NSMutableArray *stack = @[].mutableCopy;
    [stack addObject:root];
    while (stack.count != 0) {
        NodeItem *item = [stack lastObject];
        [stack removeLastObject];
        XCTAssertNotNil(item, );
        XCTAssertNotNil(item.name, );
        XCTAssertNotNil(item.url, );
        XCTAssertNotNil(item.iconImage, );
        if (item.isLeaf) {
            XCTAssertNil(item.children, );
        }else{
            XCTAssertNotNil(root.children, );
            [stack addObjectsFromArray:item.children];
        }
    }
}

@end
