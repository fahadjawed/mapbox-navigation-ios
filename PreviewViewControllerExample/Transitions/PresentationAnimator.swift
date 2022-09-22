import UIKit
import MapboxNavigation

class PresentationAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.0
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromViewController = transitionContext.viewController(forKey: .from) as? PreviewViewController,
              let toViewController = transitionContext.viewController(forKey: .to) as? NavigationViewController else {
            transitionContext.completeTransition(false)
            return
        }
        
        // Replace already exisiting `NavigationMapView` from `NavigationViewController` with `NavigationMapView`
        // that was used in `PreviewViewController`.
        toViewController.navigationView.navigationMapView = fromViewController.navigationView.navigationMapView
        
        toViewController.navigationMapView?.userLocationStyle = .courseView()
        
        // Switch navigation camera to active navigation mode.
        toViewController.navigationMapView?.navigationCamera.viewportDataSource = NavigationViewportDataSource(toViewController.navigationView.navigationMapView.mapView,
                                                                                                               viewportDataSourceType: .active)
        
        let navigationViewportDataSource = toViewController.navigationMapView?.navigationCamera.viewportDataSource as? NavigationViewportDataSource
        navigationViewportDataSource?.options.followingCameraOptions.centerUpdatesAllowed = true
        navigationViewportDataSource?.options.followingCameraOptions.bearingUpdatesAllowed = true
        navigationViewportDataSource?.options.followingCameraOptions.pitchUpdatesAllowed = true
        navigationViewportDataSource?.options.followingCameraOptions.paddingUpdatesAllowed = true
        navigationViewportDataSource?.options.followingCameraOptions.zoomUpdatesAllowed = true
        
        toViewController.navigationMapView?.navigationCamera.follow()
        
        // Render part of the route that has been traversed with full transparency, to give the illusion of a disappearing route.
        toViewController.routeLineTracksTraversal = true
        
        // Hide top and bottom container views before animating their presentation.
        toViewController.navigationView.topBannerContainerView.isHidden = true
        toViewController.navigationView.topBannerContainerView.show()
        
        toViewController.navigationView.bottomBannerContainerView.isHidden = true
        toViewController.navigationView.bottomBannerContainerView.show()
        
        transitionContext.containerView.addSubview(toViewController.view)
        transitionContext.completeTransition(true)
    }
}
