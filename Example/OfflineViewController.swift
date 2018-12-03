import UIKit
import Mapbox
import MapboxDirections
import MapboxCoreNavigation

class OfflineViewController: UIViewController {
    
    var mapView: MGLMapView!
    var resizableView: ResizableView!
    var backgroundLayer = CAShapeLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView = MGLMapView(frame: view.bounds)
        view.addSubview(mapView)
        
        backgroundLayer.frame = view.bounds
        backgroundLayer.fillColor = #colorLiteral(red: 0.1450980392, green: 0.2588235294, blue: 0.3725490196, alpha: 0.196852993).cgColor
        view.layer.addSublayer(backgroundLayer)
        
        resizableView = ResizableView(frame: CGRect(origin: view.center, size: CGSize(width: 50, height: 50)),
                                      backgroundLayer: backgroundLayer)
        
        view.addSubview(resizableView)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Download", style: .done, target: self, action: #selector(downloadRegion))
    }
    
    @objc func downloadRegion() {
        
        // Hide the download button so we can't download the same region twice
        navigationItem.rightBarButtonItem = nil
        
        let northWest = mapView.convert(resizableView.frame.minXY, toCoordinateFrom: nil)
        let southEast = mapView.convert(resizableView.frame.maxXY, toCoordinateFrom: nil)
        
        let coordinateBounds = CoordinateBounds([northWest, southEast])
        
        updateTitle("Fetching versions")
        
        Directions.shared.fetchAvailableOfflineVersions { [weak self] (versions, error) in
            
            let nonEmptyVersions = versions?.filter { !$0.isEmpty }
            guard let version = nonEmptyVersions?.first else { return }
            
            self?.updateTitle("Downloading tiles")
            
            Directions.shared.downloadTiles(in: coordinateBounds, version: version, completionHandler: { (url, response, error) in
                guard let url = url else { return assert(false, "Unable to locate temporary file") }
                
                let outputDirectoryURL = Bundle.mapboxCoreNavigation.suggestedTilePathURL(for: version)
                outputDirectoryURL?.ensureDirectoryExists()
                
                NavigationDirections.unpackTilePack(at: url, outputDirectoryURL: outputDirectoryURL!, progressHandler: { (totalBytes, bytesRemaining) in

                    let progress = (Float(bytesRemaining) / Float(totalBytes)) * 100
                    self?.updateTitle("Unpacking \(Int(progress))%")

                }, completionHandler: { (result, error) in

                    self?.navigationController?.popViewController(animated: true)
                })
            }).resume()
        }.resume()
    }
    
    func updateTitle(_ string: String) {
        DispatchQueue.main.async { [weak self] in
            self?.navigationItem.title = string
        }
    }
}

extension CGRect {
    
    var minXY: CGPoint {
        return CGPoint(x: minX, y: minY)
    }
    
    var maxXY: CGPoint {
        return CGPoint(x: maxX, y: maxY)
    }
}

extension URL {
    
    func ensureDirectoryExists() {
        try? FileManager.default.createDirectory(at: self, withIntermediateDirectories: true, attributes: nil)
    }
}
