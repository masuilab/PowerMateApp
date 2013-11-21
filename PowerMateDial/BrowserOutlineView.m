//
//  BrowserOutlineView.m
//  PowerMateApp
//
//  Created by 桜井雄介 on 2013/11/21.
//  Copyright (c) 2013年 Yusuke Sakurai. All rights reserved.
//

#import "BrowserOutlineView.h"

@implementation BrowserOutlineView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
	
    // Drawing code here.
}

- (void)scrollRowToVisible:(NSInteger)row
{
    NSRect rowRect = [self rectOfRow:row];
    NSRect viewRect = [[self superview] frame];
    NSPoint scrollOrigin = rowRect.origin;
    scrollOrigin.y = scrollOrigin.y + (rowRect.size.height - viewRect.size.height) / 2;
    if (scrollOrigin.y < 0) scrollOrigin.y = 0;
    [[self superview] setBoundsOrigin:scrollOrigin];
}

@end
