//
//  WhoIsWhoAppDelegate.m
//  WhoIsWho
//
//  Created by Shirley Carter on 11/1/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "WhoIsWhoAppDelegate.h"
#import "AppViewController.h" 
#import "AppView.h"
#import "user.h"
#import "toFriend.h"

static NSString * kWhoIsWhoDataBaseURLText = @"http://192.168.1.10";


@implementation WhoIsWhoAppDelegate

@synthesize window;
@synthesize viewController; 
@synthesize navigationController = navigationController_; 

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
	
    // Override point for customization after application launch.
	
	//viewController.view.frame = [UIScreen mainScreen].applicationFrame;
	RKObjectManager* objectManager = [RKObjectManager objectManagerWithBaseURL:kWhoIsWhoDataBaseURLText];
	objectManager.objectStore = [RKManagedObjectStore objectStoreWithStoreFilename: @"whoiswho.sqlite"];
	[RKObjectManager setSharedManager:objectManager];
	
	// Set the default refresh rate to 1. This means we should always hit the web if we can.
	// If the server is unavailable, we will load from the Core Data cache.
	//[RKObjectLoaderTTModel setDefaultRefreshRate:1];
	
#if 1
	
	NSManagedObjectContext *context = [self managedObjectContext];
	if (!context) {
		// Handle the error.
		NSLog(@"Unresolved error (no context)");
		exit(-1);  // Fail
	}
	viewController.managedObjectContext = context; 
	//user *aUser = [NSEntityDescription insertNewObjectForEntityForName:@"user" inManagedObjectContext:viewController.managedObjectContext];
	//aUser.userID = @"shirleycarter"; 
	//aUser.firstName = @"Shirley"; 
	//aUser.lastName = @"Carter"; 
	//aUser.email = @"shirley@gmail.com"; 
	
	//toFriend *friend = [NSEntityDescription insertNewObjectForEntityForName:@"toFriend" inManagedObjectContext:viewController.managedObjectContext];
	
	//friend.gameName= @"thisGame"; 
	//[friend addFriendsObject:  aUser]; 
	
	// Presumably the tag was added for the current event, so relate it to the event.
	//[aUser addGamesToObject:friend];
	
	// Save the change.
	//NSError *error = nil;
	//if (![viewController.managedObjectContext save:&error]) {
	//	// Handle the error.
	//	NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	//	exit(-1);  // Fail
	//}
	
	UIView *controllersView = viewController.view;
	//UIView *titleView = viewController.navigationItem.titleView;
	//[window addSubview:viewController.navigationItem.titleView]; 
    [window addSubview:controllersView];
//	[window addSubview:navigationController.view];
	//[(AppView *)controllersView setViewController:viewController]; 
    [window makeKeyAndVisible];
#else 
	UITableViewController *tableViewController = [[UITableViewController alloc]
                                             initWithStyle:UITableViewStylePlain];
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController]; 
	[self setNavigationController: navController]; 
	[window addSubview:[navController view]]; 
	[window makeKeyAndVisible]; 
	[window release]; 
	[navController release]; 
	
#endif 
	return YES;
}
#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *) managedObjectContext {
	
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return managedObjectContext;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
	
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
	
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return managedObjectModel;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
	
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"whoiswho.sqlite"]];
	
	NSError *error;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
		// Handle the error.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
    }    
	
    return persistentStoreCoordinator;
}


#pragma mark -
#pragma mark Application's documents directory

/**
 Returns the path to the application's documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
	
	[managedObjectContext release];
    [managedObjectModel release];
    [persistentStoreCoordinator release];
	
	[viewController release]; 
    [window release];
    [super dealloc];
}


@end
