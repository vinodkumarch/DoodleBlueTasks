//
//  Model.swift
//  Demo
//
//  Created by MXMACMINI1 on 10/01/19.
//  Copyright © 2019 MB. All rights reserved.
//

import Foundation
struct ImagesModel : Decodable {
    let photos:PhotoData?
    let stat:String?
}
struct PhotoData : Decodable {
    let page:Int?
    let pages:Int?
    let perpage:Int?
    let total:Int?
    let photo:[ImagesData]?
}
struct ImagesData : Decodable {
    let id:String?
    let owner:String?
    let secret:String?
    let server:String?
    let farm:Int?
    let title:String?
    let ispublic:Int?
    let isfriend:Int?
    let isfamily:Int?
}
