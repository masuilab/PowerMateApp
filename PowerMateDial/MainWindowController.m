//
//  PMFMainWindowController.m
//  PowerMateApp
//
//  Created by 桜井雄介 on 2013/11/18.
//  Copyright (c) 2013年 Yusuke Sakurai. All rights reserved.
//

#import "MainWindowController.h"

@interface MainWindowController ()
{
    NSImage *folderImage;
}

@property (weak) IBOutlet NSSplitView *splitView;
@property (weak) IBOutlet NSOutlineView *outlineView;
@property (strong) IBOutlet NSTreeController *treeController;
@property (weak) IBOutlet NSTableColumn *tableColumn;

@end

@implementation MainWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self.outlineView setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleSourceList];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *e = nil;
    NSArray *contents = [fm contentsOfDirectoryAtPath:@"/Users/keroxp" error:&e];
    if (e) {
        NSLog(@"%@",e);
    }
    NSLog(@"%@",contents);
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    NSLog(@"windowDidLoad");
    // KeyEventをこのクラスでキャッチする
    [self.window makeFirstResponder:self];
}

- (void)windowWillLoad
{
    [super windowWillLoad];
    NSLog(@"windowWillLoad");
}

- (void)keyUp:(NSEvent *)theEvent
{
    // <-(123) -> left
    //->(124) -> right
    // k(37) -> press
    // r(15) -> long press
//    NSLog(@"%@",theEvent);
}

#pragma mark - NSOutlineView Datasource

#pragma mark - NSOutlineView delegate

// ------------------------------------------------------------------------------

// ----------------------------------------------------------------------------------------
// outlineView:isGroupItem:item
// ----------------------------------------------------------------------------------------

#pragma mark - NSOutlineView Delegate

@end
