//
//  ABLocationManager.h
//  TestLocationInBackgroundMode
//
//  Created by gringo on 7/29/16.
//  Copyright © 2016 gringo. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>

@protocol ABLocationManagerDelegate <NSObject>

- (void)didUpdateLocation:(NSArray*)locations;

@end

@interface ABLocationManager : NSObject <CLLocationManagerDelegate>

@property (nonatomic, weak) id<ABLocationManagerDelegate> delegate;

+ (instancetype)sharedABLocationManager;

- (CLLocationManager*)locationManager;
- (void)startTrackingLocation;
- (void)stopTrackingLocation;
- (NSArray*)getLocations;

@end