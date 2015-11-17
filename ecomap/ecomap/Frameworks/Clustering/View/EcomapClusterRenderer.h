
#import <Foundation/Foundation.h>
#import <GoogleMaps/GoogleMaps.h>
#import "GClusterRenderer.h"

@interface EcomapClusterRenderer : NSObject <GClusterRenderer> 

- (id)initWithMapView:(GMSMapView*)googleMap;

@end
