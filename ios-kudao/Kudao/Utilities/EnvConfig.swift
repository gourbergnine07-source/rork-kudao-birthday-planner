// EnvConfig.swift - regenerated at build time by Scripts/generate-env-config.sh
//
// Kudao reads its public environment variables through this file instead of the
// platform-generated Config.swift. The generated file is copied verbatim from
// the project settings, so a value pasted from a web page can drag invisible
// characters into Swift source and break every build with
// "unprintable ASCII character found in source file".
//
// The build script parses that file, strips anything that is not printable
// ASCII from each value, and rewrites the values below. Config.swift itself is
// excluded from compilation, so a stray byte can no longer stop the build.
//
// The literals here are intentionally empty in source control: the real values
// only exist on the build machine.

import Foundation

enum Config {
    static let EXPO_PUBLIC_AMAZON_TAG_COM = ""
    static let EXPO_PUBLIC_AMAZON_TAG_DE = ""
    static let EXPO_PUBLIC_AMAZON_TAG_ES = ""
    static let EXPO_PUBLIC_AMAZON_TAG_FR = ""
    static let EXPO_PUBLIC_AMAZON_TAG_IT = ""
    static let EXPO_PUBLIC_PROJECT_ID = ""
    static let EXPO_PUBLIC_RORK_API_BASE_URL = ""
    static let EXPO_PUBLIC_RORK_APP_KEY = ""
    static let EXPO_PUBLIC_RORK_AUTH_URL = ""
    static let EXPO_PUBLIC_RORK_FUNCTIONS_URL = ""
    static let EXPO_PUBLIC_RORK_TOOLKIT_SECRET_KEY = ""
    static let EXPO_PUBLIC_SUPABASE_ANON_KEY = ""
    static let EXPO_PUBLIC_SUPABASE_URL = ""
    static let EXPO_PUBLIC_TEAM_ID = ""
    static let EXPO_PUBLIC_TOOLKIT_URL = ""

    static let allValues: [String: String] = [
        "EXPO_PUBLIC_AMAZON_TAG_COM": EXPO_PUBLIC_AMAZON_TAG_COM,
        "EXPO_PUBLIC_AMAZON_TAG_DE": EXPO_PUBLIC_AMAZON_TAG_DE,
        "EXPO_PUBLIC_AMAZON_TAG_ES": EXPO_PUBLIC_AMAZON_TAG_ES,
        "EXPO_PUBLIC_AMAZON_TAG_FR": EXPO_PUBLIC_AMAZON_TAG_FR,
        "EXPO_PUBLIC_AMAZON_TAG_IT": EXPO_PUBLIC_AMAZON_TAG_IT,
        "EXPO_PUBLIC_PROJECT_ID": EXPO_PUBLIC_PROJECT_ID,
        "EXPO_PUBLIC_RORK_API_BASE_URL": EXPO_PUBLIC_RORK_API_BASE_URL,
        "EXPO_PUBLIC_RORK_APP_KEY": EXPO_PUBLIC_RORK_APP_KEY,
        "EXPO_PUBLIC_RORK_AUTH_URL": EXPO_PUBLIC_RORK_AUTH_URL,
        "EXPO_PUBLIC_RORK_FUNCTIONS_URL": EXPO_PUBLIC_RORK_FUNCTIONS_URL,
        "EXPO_PUBLIC_RORK_TOOLKIT_SECRET_KEY": EXPO_PUBLIC_RORK_TOOLKIT_SECRET_KEY,
        "EXPO_PUBLIC_SUPABASE_ANON_KEY": EXPO_PUBLIC_SUPABASE_ANON_KEY,
        "EXPO_PUBLIC_SUPABASE_URL": EXPO_PUBLIC_SUPABASE_URL,
        "EXPO_PUBLIC_TEAM_ID": EXPO_PUBLIC_TEAM_ID,
        "EXPO_PUBLIC_TOOLKIT_URL": EXPO_PUBLIC_TOOLKIT_URL,
    ]
}
