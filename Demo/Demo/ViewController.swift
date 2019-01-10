//
//  ViewController.swift
//  Demo
//
//  Created by MXMACMINI1 on 10/01/19.
//  Copyright © 2019 MB. All rights reserved.
//
// https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=5719ac3089fef354bfe8881eaadaceea&per_page=100&page=0&format=json&nojsoncallback=1&auth_token=72157702282633722-9da2dc9992769932&api_sig=df90a753aa368e552f401a836bafacf3
//https://farm5.staticflickr.com/4810/31746771777_3a4c448a85.jpg
import UIKit

class ViewController: UIViewController {
    var isNewDataLoading = false
    var pageCount = 0
    var appData:ImagesModel?
    var array = [String]()
    @IBOutlet weak var galleryTable: UITableView!
    @IBOutlet weak var progs: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.galleryTable.tableFooterView = UIView()
        jsonParsing(pages: pageCount)
    }
    func jsonParsing(pages:Int) {
        progs.startAnimating()
        ServicesSingleton.shared.GETResults(extraParam: "https://api.flickr.com/services/rest/?method=flickr.photos.getRecent&api_key=2e689b6ab54e14bd0e141c1bb4d58da3&format=json&json&nojsoncallback=1&page=\(pageCount)&per_page=10", targetView: self, myStruct: ImagesModel.self
            , onTaskCompleted: { (data) -> (Void) in
            self.appData = data as? ImagesModel
            self.galleryTable.reloadData()
            guard let images = self.appData?.photos?.photo else {return}
                for i in images {
                    let imageURL = "https://farm\(i.farm ?? 0).staticflickr.com/\(i.server ?? "")/\(i.id ?? "")_\(i.secret ?? "").jpg"
                    self.array.append(imageURL)
                }
            self.progs.stopAnimating()
            self.isNewDataLoading = false
            self.galleryTable.reloadData()
        }, onTryAgain: { (network) in
            self.jsonParsing(pages: self.pageCount)
        }) { (data1) in
            self.progs.stopAnimating()
        }
    }
}
extension ViewController : UITableViewDelegate,UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       // let dataParts = appData?.photos?.photo?[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! CustomCell
       // let imageURL = "https://farm\(dataParts?.farm ?? 0).staticflickr.com/\(dataParts?.server ?? "")/\(dataParts?.id ?? "")_\(dataParts?.secret ?? "").jpg"
        cell.images.loadImageUsingCache(withUrl: array[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        let rotationAngleInRadians = 360.0 * CGFloat(.pi/360.0)
//        let rotationTransform = CATransform3DMakeRotation(rotationAngleInRadians, -500, 100, 0)
//        cell.layer.transform = rotationTransform
//        UIView.animate(withDuration: 1.0, animations: {
//            cell.alpha = 1.0
//            cell.layer.transform = CATransform3DIdentity
//        })
        if indexPath.row == array.count - 1{
            // SKActivityIndicator.show("Loading Tasks...", userInteractionStatus: false)
            pageCount = pageCount + 1
            self.jsonParsing(pages: pageCount)
        }
    }
//    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//
//        //Bottom Refresh
//
//        if scrollView == galleryTable {
//
//            if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height)
//            {
//                                if !isNewDataLoading{
//                                        isNewDataLoading = true
//                                       pageCount = pageCount + 1
//                                       jsonParsing(pages: pageCount)
//                                }
//            }
//        }
//    }
}
