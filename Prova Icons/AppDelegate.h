//
//  AppDelegate.h
//  Prova Icons
//
//  Created by Alfonso Maria Tesauro on 20/07/21.
//

#import <Cocoa/Cocoa.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (readonly, strong) NSPersistentCloudKitContainer *persistentContainer;


@end

