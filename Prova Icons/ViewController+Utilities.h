//
//  ViewController+Utilities.h
//  Prova Icons
//
//  Created by Alfonso Maria Tesauro on 22/07/21.
//

#import "ViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface ViewController (Utilities)

- (void)downloadImageAtURL:(NSURL *)url completionHandler:(void (^)(BOOL success, NSData *outputData, NSImage *outputImage))completionHandler;

- (void)downloadImagesWithCompletionHandler:(void (^)(BOOL success, NSData *outputData, NSMutableArray *outputImages))completionHandler;

@end

NS_ASSUME_NONNULL_END
