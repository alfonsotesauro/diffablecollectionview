//
//  ViewController.m
//  Prova Icons
//
//  Created by Alfonso Maria Tesauro on 20/07/21.
//

#import "ViewController.h"
#import "ViewController+Utilities.h"
#import "Prova_Icons-Swift.h"

@interface ViewController ()

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.gridWindowControllers = [[NSMutableArray alloc] init];
    
    self.isProcessing = YES;
    
    self.topLabelString = @"Loading html files...";
    
    [self downloadHtmlPagesWithCompletionHandler:^(BOOL success, NSData *outputData, NSMutableArray *outputUrlArray) {
       
        self.differentURLs = outputUrlArray;
        self.isProcessing = NO;
        
        self.topLabelString = @"Images Loaded";
        
    }];
}

- (IBAction)userDidSelectShowCollectionWindowButton:(id)sender {
    
    GridWindowController *newWindowController = [[GridWindowController alloc] initWithWindowNibName:@"GridWindow"];
    
    newWindowController.imageURLs = self.differentURLs;
    
    newWindowController.mainViewController = self;
    
    [self.gridWindowControllers addObject:newWindowController];
    
    dispatch_async( dispatch_get_main_queue(), ^{
        [newWindowController showWindow:self];
        dispatch_async( dispatch_get_main_queue(), ^{
            [newWindowController.window makeKeyAndOrderFront:self];
        });
    });
}

- (NSArray *)extractURLS:(NSString *)string {
    
    NSError *error = nil;
    
    NSMutableArray *returnValue = [[NSMutableArray alloc] init];
    
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink
                                                               error:&error];
    NSArray *matches = [detector matchesInString:string
                                         options:0
                                           range:NSMakeRange(0, [string length])];
    for (NSTextCheckingResult *match in matches) {
        if ([match resultType] == NSTextCheckingTypeLink) {
            NSURL *url = [match URL];
            if ([[[url absoluteString] pathExtension] isEqualToString:@"png"] || [[[url absoluteString] pathExtension] isEqualToString:@"svg"]) {
                
                NSString *urlString = [url absoluteString];
                
                urlString = [urlString stringByReplacingOccurrencesOfString:@"/128/" withString:@"/1024/"];
                
                urlString = [urlString stringByReplacingOccurrencesOfString:@"/256/" withString:@"/1024/"];
                
                [returnValue addObject:[NSURL URLWithString:urlString]];
            }
        }
    }
    
    return [returnValue copy];
    
}


- (void)downloadHtmlPageAtURL:(NSURL *)url completionHandler:(void (^)(BOOL success, NSData *outputData, NSString *outputString))completionHandler {
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error) {
            completionHandler(NO, nil, nil);
            return;
        }
        
        NSString *outputString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        completionHandler(YES, data, outputString);

        
        
    }];
    
    [dataTask resume];
    
}

- (void)downloadHtmlPagesWithCompletionHandler:(void (^)(BOOL success, NSData *outputData, NSMutableArray *outputUrlArray))completionHandler {
    
    dispatch_queue_t backgroundQueue =
    dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    dispatch_async(backgroundQueue, ^{
        // Do Work
    
    __block NSMutableArray *differentURLs = [[NSMutableArray alloc] init];
    
    dispatch_group_t dispgroup = dispatch_group_create();
            
    dispatch_group_enter(dispgroup);
        
    [self downloadHtmlPageAtURL:[NSURL URLWithString:@"https://www.macosicongallery.com"] completionHandler:^(BOOL success, NSData *outputData, NSString *outputString) {
        NSLog(@"Eccoci");
        
        differentURLs = [[differentURLs arrayByAddingObjectsFromArray:[self extractURLS:outputString]] mutableCopy];
        
        long ctr = 2;
        
    // https://www.macosicongallery.com/p/7/
        
        while (ctr < 19) {
            
            NSString *urlString = [NSString stringWithFormat:@"https://www.macosicongallery.com/p/%ld/", ctr];
            
            dispatch_group_enter(dispgroup);

            [self downloadHtmlPageAtURL:[NSURL URLWithString:urlString] completionHandler:^(BOOL success, NSData *outputData, NSString *outputString) {
                
                differentURLs = [[differentURLs arrayByAddingObjectsFromArray:[self extractURLS:outputString]] mutableCopy];
                dispatch_group_leave(dispgroup);
                
            }];
            
            ctr++;
        }
        dispatch_group_leave(dispgroup);
        
    }];
    
    
    dispatch_group_notify(dispgroup, backgroundQueue, ^{
        dispatch_async( dispatch_get_main_queue(), ^{
            
            differentURLs = [[[NSOrderedSet orderedSetWithArray:differentURLs] array] mutableCopy];
            completionHandler(YES,nil,differentURLs);
            NSLog(@"Eccoci");
        });
    });
        
        
    });
    
}

@end
