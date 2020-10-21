import Foundation
import MapboxCommon

public enum OfflineRegionStatus {
    case pending
    case downloading
    case available
    case incomplete
    case verifying
    case expired
    case errored(error: OfflineRegionError)
    case deleting
    case deleted
}

/**
 The usage domain of an offline pack.
 */
public enum OfflineRegionDomain {
    case maps
    case navigation

    static func common(domain: MapboxCommon.OfflineDataDomain) -> OfflineRegionDomain{
        return domain == .maps ? .maps : .navigation
    }

    var commonDomain: MapboxCommon.OfflineDataDomain {
        return self == .maps ? .maps : .navigation
    }
}

/**
 A record describing the current status of an offline pack that is being downloaded.
 */
public struct OfflineRegionPack {
    /**
     Error description for status=Errored
     */
    public var error: OfflineRegionError? {
        if let error = commonPack.error {
            return OfflineRegionError(error)
        }
        return nil
    }

    /**
     The file path on disk this offline pack is being downloaded to
     */
    public var path: String {
        commonPack.path
    }

    /**
     The number of bytes that have been downloaded to disk
     */
    public var bytes: UInt64 {
        commonPack.bytes
    }

    /**
     The total number of bytes of this offline pack
     */
    public var totalBytes: UInt64? {
        commonPackMetadata?.bytes
    }

    /**
     The URL the offline pack can be downloaded from.
     */
    public var url: String? {
        commonPackMetadata?.url
    }

    /**
     A numeric version of the format. An SDK version only supports one format version and uses this field to verify compatibility.
     */
    public var format: UInt32? {
        commonPackMetadata?.format
    }

    /**
     A version identifier. Some data can only be used together with matching versions.
     */
    public var dataVersion: String? {
        commonPackMetadata?.data_version
    }

    let commonPack: OfflineDataPack
    var commonPackMetadata: OfflineDataPackMetadata?

    init(pack: OfflineDataPack) {
        self.commonPack = pack
    }
}

/**
 A metadata record for an offline region.

 The key for looking up offline regions should be a compound of id and revision.
 */
public class OfflineRegion: Equatable {
    /**
     A machine-readable identifier
     */
    public var id: String {
        region.id
    }

    /**
     A numeric revision ID
     */
    public var revision: UInt32 {
        region.revision
    }

    /**
     A human readable name
     */
    public var name: String {
        region.name
    }

    /**
     A human readable description
     */
    public var description: String {
        region.description
    }

    /**
     When this region was last updated
     */
    public var lastUpdated: Date {
        region.last_updated
    }

    /**
     A GeoJSON geometry definition describing the extent of this region
     */
    public var geography: MBXGeometry {
        region.geography
    }

    /**
     Shows if there is data related to the region downloaded to disk
     */
    public var isDownloaded: Bool {
        mapsPack != nil || navigationPack != nil
    }

    public var mapsPack: OfflineRegionPack?

    public var navigationPack: OfflineRegionPack?

    private(set) var region: OfflineDataRegionMetadata

    init(region: OfflineDataRegionMetadata, mapsPack: OfflineDataPack? = nil, navigationPack: OfflineDataPack? = nil) {
        self.region = region
        self.mapsPack = mapsPack != nil ? OfflineRegionPack(pack: mapsPack!) : nil
        self.navigationPack = navigationPack != nil ? OfflineRegionPack(pack: navigationPack!) : nil
    }

    init(region: OfflineDataRegionMetadata, mapsPack: OfflineRegionPack?, navigationPack: OfflineRegionPack?) {
        self.region = region
        self.mapsPack = mapsPack
        self.navigationPack = navigationPack
    }

    public static func == (lhs: OfflineRegion, rhs: OfflineRegion) -> Bool {
        return lhs.region == rhs.region
    }
}
