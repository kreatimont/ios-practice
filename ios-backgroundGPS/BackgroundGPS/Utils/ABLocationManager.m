//
//  ABLocationManager.m
//  TestLocationInBackgroundMode
//
//  Created by gringo on 7/29/16.
//  Copyright © 2016 gringo. All rights reserved.
//

#import "ABLocationManager.h"

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

@interface ABLocationManager ()

@property (nonatomic) CLLocationManager* locationManager;

@property (nonatomic) NSMutableArray* locations;

@property (nonatomic) NSTimer* timer;
@property (nonatomic) NSTimer* delayTimer;

@property (nonatomic, strong) NSMutableArray* bgTaskIdList;
@property (assign) UIBackgroundTaskIdentifier masterTaskId;

@end

@implementation ABLocationManager

#pragma mark - Singleton

+ (instancetype)sharedABLocationManager
{
    static ABLocationManager* _manager = nil;

    @synchronized(self)
    {
        if (!_manager) {
            _manager = [ABLocationManager new];
        }
    }
    return _manager;
}

- (CLLocationManager*)locationManager
{
    @synchronized(self)
    {
        if (_locationManager == nil) {
            _locationManager = [[CLLocationManager alloc] init];
            _locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
            _locationManager.allowsBackgroundLocationUpdates = YES;
            _locationManager.pausesLocationUpdatesAutomatically = NO;
            _locationManager.delegate = self;
        }
    }
    return _locationManager;
}

#pragma mark - Init

- (instancetype)init
{
    self = [super init];

    if (self) {
        self.locations = [NSMutableArray new];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }

    return self;
}

#pragma mark - Public

- (void)startTrackingLocation
{
    if ([CLLocationManager locationServicesEnabled] == NO) {
        NSLog(@"locationServicesEnabled false");
        UIAlertView* servicesDisabledAlert = [[UIAlertView alloc] initWithTitle:@"Location Services Disabled" message:@"You currently have all location services for this device disabled" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [servicesDisabledAlert show];
    }
    else {
        CLAuthorizationStatus authorizationStatus = [CLLocationManager authorizationStatus];

        if (authorizationStatus == kCLAuthorizationStatusDenied || authorizationStatus == kCLAuthorizationStatusRestricted) {
            NSLog(@"authorizationStatus failed");
        }
        else {
            NSLog(@"authorizationStatus authorized");
            [self startTracking];
        }
    }
}

- (void)stopTrackingLocation
{
    [self resetTimer];
    [self.locationManager stopUpdatingLocation];
}

- (NSArray*)getLocations
{
    return self.locations;
}

#pragma mark - Pivate

- (void)startTracking
{
    if (IS_OS_8_OR_LATER) {
        [self.locationManager requestAlwaysAuthorization];
    }
    [self.locationManager startUpdatingLocation];
}

- (void)restartTrackingLocation
{
    [self resetTimer];
    [self startTracking];
}

- (void)resetTimer
{
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)applicationEnterBackground
{
    [self startTracking];
    [self beginNewBackgroundTask];
}

- (void)stopTrackingLocationAfterDelay
{
    [self.locationManager stopUpdatingLocation];

    if ([self.delegate respondsToSelector:@selector(didUpdateLocation:)])
        [self.delegate didUpdateLocation:self.locations];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager*)manager didUpdateLocations:(NSArray*)locations
{
    NSLog(@"locationManager didUpdateLocations");

    for (int i = 0; i < locations.count; i++) {
        CLLocation* newLocation = [locations objectAtIndex:i];
        CLLocationCoordinate2D theLocation = newLocation.coordinate;
        CLLocationAccuracy theAccuracy = newLocation.horizontalAccuracy;

        NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];

        if (locationAge > 30.0) {
            continue;
        }

        //Select only valid location and also location with good accuracy
        if (newLocation != nil && theAccuracy > 0
            && theAccuracy < 2000
            && (!(theLocation.latitude == 0.0 && theLocation.longitude == 0.0))) {

            NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
            [dict setObject:[NSNumber numberWithFloat:theLocation.latitude] forKey:@"latitude"];
            [dict setObject:[NSNumber numberWithFloat:theLocation.longitude] forKey:@"longitude"];
            [dict setObject:[NSNumber numberWithFloat:theAccuracy] forKey:@"theAccuracy"];

            NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            [dict setObject:[dateFormatter stringFromDate:[NSDate date]] forKey:@"time"];

            //Add the vallid location with good accuracy into an array
            //Every 1 minute, I will select the best location based on accuracy and send to server
            [self.locations addObject:dict];
        }
    }

    //If the timer still valid, return it (Will not run the code below)
    if (self.timer) {
        return;
    }

    [self beginNewBackgroundTask];

    //Restart the locationMaanger after 1 minute
    self.timer = [NSTimer scheduledTimerWithTimeInterval:60 target:self
                                                selector:@selector(restartTrackingLocation)
                                                userInfo:nil
                                                 repeats:NO];

    //Will only stop the locationManager after 10 seconds, so that we can get some accurate locations
    //The location manager will only operate for 10 seconds to save battery
    if (self.delayTimer) {
        [self.delayTimer invalidate];
        self.delayTimer = nil;
    }

    self.delayTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self
                                                     selector:@selector(stopTrackingLocationAfterDelay)
                                                     userInfo:nil
                                                      repeats:NO];
}

- (void)locationManager:(CLLocationManager*)manager didFailWithError:(NSError*)error
{
    switch ([error code]) {
    case kCLErrorNetwork: // general, network-related error
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Network Error" message:@"Please check your network connection." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];

    } break;
    case kCLErrorDenied: {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Enable Location Service" message:@"You have to enable the Location Service to use this App. To enable, please go to Settings->Privacy->Location Services" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    } break;
    default:
        break;
    }
}

#pragma mark - Background Task Manager

- (UIBackgroundTaskIdentifier)beginNewBackgroundTask
{
    UIApplication* application = [UIApplication sharedApplication];

    __block UIBackgroundTaskIdentifier bgTaskId = UIBackgroundTaskInvalid;
    if ([application respondsToSelector:@selector(beginBackgroundTaskWithExpirationHandler:)]) {
        bgTaskId = [application beginBackgroundTaskWithExpirationHandler:^{
            NSLog(@"background task %lu expired", (unsigned long)bgTaskId);

            [self.bgTaskIdList removeObject:@(bgTaskId)];
            [application endBackgroundTask:bgTaskId];
            bgTaskId = UIBackgroundTaskInvalid;

        }];
        if (self.masterTaskId == UIBackgroundTaskInvalid) {
            self.masterTaskId = bgTaskId;
            NSLog(@"started master task %lu", (unsigned long)self.masterTaskId);
        }
        else {
            //add this id to our list
            NSLog(@"started background task %lu", (unsigned long)bgTaskId);
            [self.bgTaskIdList addObject:@(bgTaskId)];
            [self endBackgroundTasks];
        }
    }

    return bgTaskId;
}

- (void)endBackgroundTasks
{
    [self drainBGTaskList:NO];
}

- (void)endAllBackgroundTasks
{
    [self drainBGTaskList:YES];
}

- (void)drainBGTaskList:(BOOL)all
{
    //mark end of each of our background task
    UIApplication* application = [UIApplication sharedApplication];
    if ([application respondsToSelector:@selector(endBackgroundTask:)]) {
        NSUInteger count = self.bgTaskIdList.count;
        for (NSUInteger i = (all ? 0 : 1); i < count; i++) {
            UIBackgroundTaskIdentifier bgTaskId = [[self.bgTaskIdList objectAtIndex:0] integerValue];
            NSLog(@"ending background task with id -%lu", (unsigned long)bgTaskId);
            [application endBackgroundTask:bgTaskId];
            [self.bgTaskIdList removeObjectAtIndex:0];
        }
        if (self.bgTaskIdList.count > 0) {
            NSLog(@"kept background task id %@", [self.bgTaskIdList objectAtIndex:0]);
        }
        if (all) {
            NSLog(@"no more background tasks running");
            [application endBackgroundTask:self.masterTaskId];
            self.masterTaskId = UIBackgroundTaskInvalid;
        }
        else {
            NSLog(@"kept master background task id %lu", (unsigned long)self.masterTaskId);
        }
    }
}

@end