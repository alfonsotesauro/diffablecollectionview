//
//  ViewController+Utilities.m
//  Prova Icons
//
//  Created by Alfonso Maria Tesauro on 22/07/21.
//

#import "ViewController+Utilities.h"

@implementation ViewController (Utilities)

- (void)downloadImageAtURL:(NSURL *)url completionHandler:(void (^)(BOOL success, NSData *outputData, NSImage *outputImage))completionHandler {
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error) {
            completionHandler(NO, nil, nil);
            return;
        }
        
        NSImage *outputImage = [[NSImage alloc] initWithData:data];
        
        completionHandler(YES, data, outputImage);

    }];
    
    [dataTask resume];
    
}

- (void)downloadImagesWithCompletionHandler:(void (^)(BOOL success, NSData *outputData, NSMutableArray *outputImages))completionHandler {
    
    NSMutableArray *images = [[NSMutableArray alloc] init];
    
    dispatch_queue_t backgroundQueue =
    dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    dispatch_async(backgroundQueue, ^{
        // Do Work
        
    dispatch_group_t dispgroup = dispatch_group_create();
                
        long ctr = 0;
                
        while (ctr++ < (self.differentURLs.count - 1)) {
            
            
            dispatch_group_enter(dispgroup);

            [self downloadImageAtURL:self.differentURLs[ctr] completionHandler:^(BOOL success, NSData *outputData, NSImage *outputImage) {
                
                NSString *destFile = @"/Users/fofo/Desktop/untitled folder 2";
                
                destFile = [destFile stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", [[self.differentURLs[ctr] absoluteString] lastPathComponent]]];
                            
                if (outputImage != nil) {
                    [images addObject:outputImage];
                }
                dispatch_group_leave(dispgroup);

            }];
            
        }
        
        dispatch_group_notify(dispgroup, backgroundQueue, ^{
            dispatch_async( dispatch_get_main_queue(), ^{
                NSLog(@"Eccoci");
                completionHandler(YES,nil,[images copy]);
            });
        });
    
    });
    
}

@end
