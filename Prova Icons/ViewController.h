//
//  ViewController.h
//  Prova Icons
//
//  Created by Alfonso Maria Tesauro on 20/07/21.
//

#import <Cocoa/Cocoa.h>

@interface ViewController : NSViewController

@property (strong) NSString *topLabelString;
@property (assign) BOOL isProcessing;
@property (strong) NSMutableArray<NSWindowController *> *gridWindowControllers;

@property (strong) NSMutableArray *differentURLs;
@end


