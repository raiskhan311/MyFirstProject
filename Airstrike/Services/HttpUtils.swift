//
//  HttpUtils.swift
//  Airstrike
//
//  Created by Bret Smith on 1/24/17.
//  Copyright © 2017 Airstrike. All rights reserved.
//

import UIKit

class HttpUtils: NSObject {

    static func makeUnsignedRequest(url: String, body: String?, method: String = "POST", completion: @escaping (_ response: [String:AnyObject]?) -> Void) {
        let sessionConfig = URLSessionConfiguration.default
        
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        
        guard let URL = URL(string: url) else { return }
        var request = URLRequest(url: URL)
        request.httpMethod = method
        
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        if let b = body {
            request.httpBody = b.data(using: String.Encoding.utf8)
        }
        
        let task = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            if let d = data, let jsonOpt = try? JSONSerialization.jsonObject(with: d, options: []) as? [String:AnyObject], let json = jsonOpt {
                completion(json)
            } else {
                completion(.none)
            }
        })
        task.resume()
        session.finishTasksAndInvalidate()
    }
    
    static func makeSignedRequest(url: String, body: String?, method: String = "POST", completion: @escaping (_ response: [String:AnyObject]?) -> Void) {
        let sessionConfig = URLSessionConfiguration.default
        
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        
        guard let URL = URL(string: url) else { return }
        var request = URLRequest(url: URL)
        request.httpMethod = method
        
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        if let token = KeychainHelper.get(Constants.authTokenKey) {
            request.addValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        } else {
            completion(.none)
        }
        
        if let b = body {
            request.httpBody = b.data(using: String.Encoding.utf8)
        }
        
        let task = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            if let d = data, let jsonOpt = try? JSONSerialization.jsonObject(with: d, options: []) as? [String:AnyObject], let json = jsonOpt {
                completion(json)
            } else {
                completion(.none)
            }
        })
        task.resume()
        session.finishTasksAndInvalidate()
    }
    
    static func makeSignedPagedRequest(url: String, method: String = "GET", cursor: Int = 0, responseSoFar: [[String:AnyObject]]? = .none, completion: @escaping (_ response: [[String:AnyObject]]?) -> Void) {
        let sessionConfig = URLSessionConfiguration.default
        
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        
        guard let URL = URL(string: url + "?cursor=" + String(cursor)) else { return }
        var request = URLRequest(url: URL)
        request.httpMethod = method
        
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        if let token = KeychainHelper.get(Constants.authTokenKey) {
            request.addValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        } else {
            completion(.none)
        }
        
        let task = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            if  let d = data,
                let jsonOpt = try? JSONSerialization.jsonObject(with: d, options: []) as? [String:AnyObject],
                let jsonResponse = jsonOpt?["response"] as? [String:AnyObject],
                let jsonResults = jsonResponse["results"] as? [[String:AnyObject]],
                let remaining = jsonResponse["remaining"] as? Int {
                let allResults = jsonResults + (responseSoFar ?? [[String:AnyObject]]())
                if remaining == 0 {
                    completion(allResults)
                } else {
                    makeSignedPagedRequest(url: url, cursor: cursor + 100, responseSoFar: allResults, completion: completion)
                }
            } else {
                completion(.none)
            }
        })
        task.resume()
        session.finishTasksAndInvalidate()
    }
    
    static func postImage(url: String, filename:String, image:UIImage, completion: @escaping (_ response: String?) -> Void) {
        
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)

        let UPLOAD_BOUNDARY = "__X_PAW_BOUNDARY__"
        guard let url = NSURL(string: url) else { return }
        var request = URLRequest(url: url as URL, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let MPboundary = "--\(UPLOAD_BOUNDARY)"
        let endMPboundary = "\(MPboundary)--"
        
        
        
        guard let data = UIImageJPEGRepresentation(image, 0.8) else { return }
        
        
        
        var body = "\(MPboundary)\r\n"
        body.append("Content-Disposition: form-data; name=\"public\"\r\n\r\n")
        body.append("true\r\n")
        body.append("\(MPboundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"service\"\r\n\r\n")
        body.append("bubble\r\n")
        body.append("\(MPboundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"contents\"; filename=\"\(filename).jpg\"\r\n")
        body.append("Content-Type: image/jpeg\r\n\r\n")
        
        
        
        let end = "\r\n\(endMPboundary)"
        var myRequestData = Data()
        if let bodyData = body.data(using: String.Encoding.utf8) {
            myRequestData.append(bodyData)
        }
        myRequestData.append(data)
        if let endData = end.data(using: String.Encoding.utf8) {
            myRequestData.append(endData)
        }
        let content = "multipart/form-data; boundary=\(UPLOAD_BOUNDARY)"
        request.setValue(content, forHTTPHeaderField: "Content-Type")
        request.setValue("\(myRequestData.count)", forHTTPHeaderField: "Content-Length")
        request.httpBody = myRequestData
        request.httpMethod = "POST"

        
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
            if let d = data, let imagePath = String(data: d, encoding: .utf8) {
                completion(imagePath.replacingOccurrences(of: "\"", with: ""))
            } else {
                completion(.none)
            }
            if let e = error {
                print(e.localizedDescription)
            }
        })
        task.resume()
        session.finishTasksAndInvalidate()
    }

}
