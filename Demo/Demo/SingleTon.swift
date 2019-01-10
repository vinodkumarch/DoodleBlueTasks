//
//  SingleTon.swift
//  Demo
//
//  Created by MXMACMINI1 on 10/01/19.
//  Copyright © 2019 MB. All rights reserved.
//

import Foundation
import UIKit
import SystemConfiguration
class ServicesSingleton: NSObject {
    static let shared = ServicesSingleton()
    static let imageCache = NSCache<NSString, AnyObject>()
    override init() {
    }
    
    func GETResults<Element: Decodable>(extraParam : String,targetView:UIViewController,myStruct: Element.Type, onTaskCompleted : @escaping (Decodable)->(Void),onTryAgain :  @escaping (Bool) -> (),onAnimationStop : @escaping (Bool) -> ()) {
        
        if ServicesSingleton.shared.isConnectedToNetwork() {
            
            guard let url = URL(string:extraParam) else{return}
            
            print(url)
            
            let urlRequest = URLRequest(url: url)
            
            URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
                
                if error != nil {
                    print(error as Any)
                    if error?._code == NSURLErrorTimedOut {
                        DispatchQueue.main.async {
                            onAnimationStop(true)
                            let alert = UIAlertController(title: "The server request timed out", message: "", preferredStyle: UIAlertController.Style.alert)
                            alert.addAction(UIAlertAction(title: "Try Again", style: UIAlertAction.Style.cancel, handler: { (act) in
                                onTryAgain(true)
                            }))
                            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.destructive, handler: { (act2) in
                                targetView.dismiss(animated: true, completion: nil)
                            }))
                            targetView.present(alert, animated: true, completion: nil)
                        }
                    }
                } else {
                    guard let dataIs = data else { return }
                    
                    do {
                        let res = try JSONDecoder().decode(myStruct.self, from: dataIs)
                        DispatchQueue.main.async {
                            onTaskCompleted(res)
                        }
                        
                    }catch {
                        print(error)
                        DispatchQueue.main.async {
                            let alert = UIAlertController(title: "Unable to Process Your Request", message: "", preferredStyle: UIAlertController.Style.alert)
                            onAnimationStop(true)
                            alert.addAction(UIAlertAction(title: "Try Again", style: UIAlertAction.Style.cancel, handler: { (act) in
                                onTryAgain(true)
                            }))
                            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.destructive, handler: { (act2) in
                                targetView.dismiss(animated: true, completion: nil)
                            }))
                            targetView.present(alert, animated: true, completion: nil)
                        }
                    }
                }
                
                }.resume()
        }else {
            DispatchQueue.main.async {
                onAnimationStop(true)
                let alert = UIAlertController(title: "No Internet Connection", message: "", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Try Again", style: UIAlertAction.Style.default, handler: { (act) in
                    onTryAgain(true)
                }))
                alert.addAction(UIAlertAction(title: "Go To Settings", style: UIAlertAction.Style.default, handler: { (act1) in
                    targetView.dismiss(animated: true, completion: nil)
                    if let url = URL(string:"App-Prefs:root=Settings&path=General") {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.destructive, handler: { (act2) in
                    targetView.dismiss(animated: true, completion: nil)
                }))
                targetView.present(alert, animated: true, completion: nil)
            }
        }
    }
    func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        let ret = (isReachable && !needsConnection)
        
        return ret
        
    }
}
extension UIImageView {
    func loadImageUsingCache(withUrl urlString : String) {
        let url = URL(string: urlString)
        self.image = nil
        
        // check cached image
        if let cachedImage = ServicesSingleton.imageCache.object(forKey: urlString as NSString) as? UIImage {
            self.image = cachedImage
            return
        }
        
        // if not, download image from url
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            if error != nil {
                print(error!)
                return
            }
            
            DispatchQueue.main.async {
                if let image = UIImage(data: data!) {
                    ServicesSingleton.imageCache.setObject(image, forKey: urlString as NSString)
                    self.image = image
                }
            }
            
        }).resume()
    }
}
