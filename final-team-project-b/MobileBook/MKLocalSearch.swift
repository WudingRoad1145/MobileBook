////
////  MKLocalSearch.swift
////  MobileBook
////
////  Created by Yezhou Chen on 2022/4/9.
////
//
//import UIKit
//import MapKit
//
//
//
//
//
//
//
//
//class MKLocalSearch_1: MKLocalSearch {
//    
//    
//    
////    // 初始化
//    init(request: MKLocalSearch.Request){
//        var naturalLanguageQuery : String
//        var region : String
//        var resultTypes : String
//        
//        
//        //seems 这个在我们的map app 当中并不需要
//        var pointOfInterestFilter :String
//        
//    }
//    
//    
////    init(request: MKLocalPointsOfInterestRequest)
////
////    // 开始搜索
////    func start(completionHandler: @escaping MKLocalSearch.CompletionHandler)
////
////    // 取消搜索
////    func cancel()
//    
//    private func search(using searchRequest: MKLocalSearch.Request) {
//        // Confine the map search area to an area around the user's current location.
//        searchRequest.region = boundingRegion
//        
//        // Include only point of interest results. This excludes results based on address matches.
//        searchRequest.resultTypes = .pointOfInterest
//        
//        localSearch = MKLocalSearch(request: searchRequest)
//        localSearch?.start { [unowned self] (response, error) in
//            guard error == nil else {
//                self.displaySearchError(error)
//                return
//            }
//            
//            self.places = response?.mapItems
//            
//            // Used when setting the map's region in `prepareForSegue`.
//            if let updatedRegion = response?.boundingRegion {
//                self.boundingRegion = updatedRegion
//            }
//        }
//    }
//    
//    
//    //自动补全
//    
//    func completerDidUpdateResults(_ completer: LocalSearchCompleter) {
//      // results 中是 MKLocalSearchCompletion，只包含 title, subtitle 和相应的 Ranges 信息
//      results = completer.results.map { $0.title }
//      tableView.reloadData()
//    }
//    
    
    //计算路径
    
    
    //self.hide -> view ->hierachy -> ui view -> reference -> hide -> 

//}
