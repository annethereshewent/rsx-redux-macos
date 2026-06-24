//
//  CloudService.swift
//  RSX Redux
//
//  Created by Anne Castrillon on 6/22/26.
//

import Foundation
import Combine
import GoogleSignIn


class CloudService: ObservableObject {
    var user: GIDGoogleUser

    private var rsxFolderId: String? = nil

    private let googleBase = "https://www.googleapis.com"
    private let drivesUrl = "https://www.googleapis.com/drive/v3/files"

    private let jsonDecoder = JSONDecoder()
    private let jsonEncoder = JSONEncoder()

    init (user: GIDGoogleUser) {
        self.user = user

        let defaults = UserDefaults.standard

        if let rsxFolderId = defaults.string(forKey: "rsxFolderId") {
            self.rsxFolderId = rsxFolderId
        }
    }

    func getCardInfo(_ cardName: String) async -> DriveResponse? {
        if let folderId = await checkForFolder() {
            let params = [URLQueryItem(name: "q", value: "name = \"\(cardName)\" and parents in \"\(folderId)\""), URLQueryItem(name: "fields", value: "files/id,files/parents,files/name,files/modifiedTime")]

            let url = buildUrl(params: params)

            let request = URLRequest(url: url)

            if let data = await self.cloudRequest(request: request) {
                do {
                    return try jsonDecoder.decode(DriveResponse.self, from: data)
                } catch {
                    print(error)
                }
            }
        }

        return nil
    }

    func getCard(_ cardName: String) async -> Data? {
        print("getting card \(cardName)")
        if let info = await getCardInfo(cardName) {
            if info.files.count > 0 {
                let fileId = info.files[0].id

                let params = [URLQueryItem(name: "alt", value: "media")]

                let url = buildUrl(params: params, urlStr: "\(drivesUrl)/\(fileId)")

                let request = URLRequest(url: url)

                return await self.cloudRequest(request: request)
            }
        }

        return nil
    }

    private func checkForFolder() async -> String? {
        if let rsxFolderId = self.rsxFolderId {
            return rsxFolderId
        }

        let params = [URLQueryItem(name: "q", value: "mimeType = \"application/vnd.google-apps.folder\" and name=\"rsx-cards\"")]

        let url = buildUrl(params: params)

        let request = URLRequest(url: url)

        if let data = await self.cloudRequest(request: request) {
            do {
                let driveResponse = try jsonDecoder.decode(DriveResponse.self, from: data)
                if driveResponse.files.count > 0 {
                    let defaults = UserDefaults.standard

                    self.rsxFolderId = driveResponse.files[0].id
                    defaults.set(self.rsxFolderId, forKey: "rsxFolderId")

                    return driveResponse.files[0].id
                }
            } catch {
                print(error)
            }
        }

        // create the folder
        let folderParams = [URLQueryItem(name: "uploadType", value: "media"), URLQueryItem(name: "fields", value: "id,name")]
        do {
            let url = buildUrl(params: folderParams)

            var request = URLRequest(url: url)

            let headers = ["Content-Type": "application/json"]

            request.httpMethod = "POST"

            request.httpBody = try jsonEncoder.encode(FileJSON(
                name: "rsx-cards",
                mimeType: "application/vnd.google-apps.folder"
            ))

            if let data = await self.cloudRequest(request: request, headers: headers) {
                do {
                    let fileResponse = try jsonDecoder.decode(File.self, from: data)

                    let defaults = UserDefaults.standard

                    self.rsxFolderId = fileResponse.id
                    defaults.set(self.rsxFolderId, forKey: "rsxFolderId")

                    return fileResponse.id
                } catch {
                    print(error)
                }
            }

        } catch {
            print(error)
        }

        return nil
    }

    private func cloudRequest(request: URLRequest, headers: [String:String]? = nil) async -> Data? {
        do {
            let user = try await self.user.refreshTokensIfNeeded()

            self.user = user
        } catch {
            print(error)
        }

        var request = request

        request.setValue("Bearer \(self.user.accessToken.tokenString)", forHTTPHeaderField: "Authorization")

        if let headers = headers {
            for header in headers {
                request.setValue(header.value, forHTTPHeaderField: header.key)
            }
        }

        do {
            let (data, _) = try await URLSession.shared.data(for: request)

            return data
        } catch {
            print(error)
        }

        return nil
    }

    private func buildUrl(params: [URLQueryItem], urlStr: String? = nil) -> URL {

        var urlComponents = URLComponents(string: urlStr ?? drivesUrl)

        urlComponents?.queryItems = params

        return urlComponents!.url!
    }
}
