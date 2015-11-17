//
//  Spot.h
//  Google Maps iOS Example
//
//  Created by Colin Edwards on 2/1/14.
//
//

#import <Foundation/Foundation.h>
@import CoreLocation;
#import "GClusterItem.h"
#import "EcomapProblem.h"

@interface Spot : NSObject <GClusterItem>

@property (nonatomic) CLLocationCoordinate2D location;
@property (nonatomic, strong)EcomapProblem *problem;

@end
