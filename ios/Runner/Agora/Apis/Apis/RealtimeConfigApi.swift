//
//  RealtimeConfigApi.swift
//  Runner
//

import Foundation

// Self-heals a rotated realtime config on the call path: fetch the latest
// config and, only when `config_version` differs from the mirrored one, rewrite
// the local values (websocket + agora app id). Mirrors PusherManager's
// version-gated refresh so a cold-start call always joins with a fresh app id.
// Always returns (success, mismatch-write, or failure) so the call flow
// proceeds and degrades to the existing prefs / hardcoded fallback.
class RealtimeConfigApi {

    static func sync() async {
        guard let myDetails = MyDetails.loadFromSharedPrefs(),
              let serverUrl = myDetails.serverUrl,
              let token = myDetails.token,
              let url = URL(string: serverUrl + "drivers/realtime-configuration") else {
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
                print("[Realtime] sync: non-200 response")
                return
            }
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let dataObj = json["data"] as? [String: Any] else {
                print("[Realtime] sync: unexpected response shape")
                return
            }

            guard let newVersion = stringValue(dataObj["config_version"]), !newVersion.isEmpty else {
                print("[Realtime] sync: missing config_version")
                return
            }

            if newVersion == MyDetails.realtimeConfigVersion() {
                return
            }

            let websocket = dataObj["websocket"] as? [String: Any]
            let agora = dataObj["agora"] as? [String: Any]

            // Only persist (and advance config_version) when a usable agora app
            // id was parsed — otherwise a transient parse miss / type drift would
            // bump the stored version while leaving a stale app id, wedging the
            // client on the old id under the new version. Skipping lets the next
            // call retry.
            guard let agoraAppId = stringValue(agora?["app_id"]), !agoraAppId.isEmpty else {
                print("[Realtime] sync: agora app_id missing; not advancing version")
                return
            }

            MyDetails.storeRealtimeConfig(
                key: stringValue(websocket?["key"]),
                host: stringValue(websocket?["host"]),
                port: intValue(websocket?["port"]),
                authUrl: stringValue(websocket?["auth_endpoint"]),
                agoraAppId: agoraAppId,
                configVersion: newVersion
            )
            print("[Realtime] native config synced -> version=\(newVersion)")
        } catch {
            print("[Realtime] sync failed: \(error.localizedDescription)")
            return
        }
    }

    // config_version / port may arrive as either a JSON string or number.
    private static func stringValue(_ value: Any?) -> String? {
        if let s = value as? String { return s }
        if let n = value as? NSNumber { return n.stringValue }
        return nil
    }

    private static func intValue(_ value: Any?) -> Int? {
        if let i = value as? Int { return i }
        if let n = value as? NSNumber { return n.intValue }
        if let s = value as? String { return Int(s) }
        return nil
    }
}
