import XCTest
import MapboxDirections
@testable import MapboxCoreNavigation
#if !SWIFT_PACKAGE
import TestHelper

class SimulatedLocationManagerTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testSimulateRouteDoublesBack() {
        let coordinates:[CLLocationCoordinate2D] = [
            .init(latitude: 59.337928, longitude: 18.076841),
            .init(latitude: 59.337661, longitude: 18.075897),
            .init(latitude: 59.337129, longitude: 18.075478),
            .init(latitude: 59.336866, longitude: 18.075273),
            .init(latitude: 59.336623, longitude: 18.075806),
            .init(latitude: 59.336391, longitude: 18.076943),
            .init(latitude: 59.338731, longitude: 18.079343),
            .init(latitude: 59.339058, longitude: 18.07774),
            .init(latitude: 59.338901, longitude: 18.076929),
            .init(latitude: 59.338333, longitude: 18.076467),
            .init(latitude: 59.338156, longitude: 18.075723),
            .init(latitude: 59.338311, longitude: 18.074968),
            .init(latitude: 59.33865, longitude: 18.074935),
        ]
        let route = Fixture.routesFromMatches(at: "sthlm-double-back", options: NavigationMatchOptions(coordinates: coordinates))![0]
        let locationManager = SimulatedLocationManager(route: route)
        let locationManagerSpy = SimulatedLocationManagerSpy()
        locationManager.delegate = locationManagerSpy
        locationManager.speedMultiplier = 5
        
        while locationManager.currentDistance < route.distance {
            locationManager.tick()
        }
        
        locationManager.delegate = nil
        
        let testCoordinates:[CLLocationCoordinate2D] = locationManagerSpy.locations.map { $0.coordinate }
        
        XCTAssert(testCoordinates == coordinates)
    }
}

class SimulatedLocationManagerSpy: NSObject, CLLocationManagerDelegate {
    var locations = [CLLocation]()
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.locations.append(contentsOf: locations)
    }
}
#endif