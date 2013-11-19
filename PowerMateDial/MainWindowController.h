//
//  PMFMainWindowController.h
//  PowerMateApp
//
//  Created by 桜井雄介 on 2013/11/18.
//  Copyright (c) 2013年 Yusuke Sakurai. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MainWindowController : NSWindowController
<NSOutlineViewDelegate>

@property (assign) NSArray *contents;
@property (readonly) NSArray *selectedIndexPaths;
@property (readonly) NSArray *sortDescriptors;

@end
