import Foundation

extension Locale {
    /// Given the app's localized language setting, returns a string representing the user's localization.
    public static var preferredLocalLanguageCountryCode: String {
        let firstBundleLocale = Bundle.main.preferredLocalizations.first!
        let bundleLocale = firstBundleLocale.components(separatedBy: "-")

        if bundleLocale.count > 1 {
            return firstBundleLocale
        }

        if let countryCode = (Locale.current as NSLocale).object(forKey: .countryCode) as? String {
            return "\(bundleLocale.first!)-\(countryCode)"
        }

        return firstBundleLocale
    }

    /// Returns a `Locale` from ``Foundation/Locale/preferredLocalLanguageCountryCode``.
    public static var nationalizedCurrent: Locale {
        Locale(identifier: preferredLocalLanguageCountryCode)
    }
}
