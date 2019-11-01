//
//  Custom MapView.swift
//  Custom MapView
//
//  Created by logesh on 10/28/19.
//  Copyright © 2019 logesh. All rights reserved.
//

import Foundation
import MapKit
import UIKit

//MARK: - Class
class CustomMapView : UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initScreen()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.initScreen()
    }
    
  
    
    func initScreen()  {
        
        print("1")
                let mapView = MKMapView()
               let leftMargin:CGFloat = 10
               let topMargin:CGFloat = 60
            //   let mapWidth:CGFloat = view.frame.size.width-20
               let mapHeight:CGFloat = 876
               
        //       mapView.frame = CGRect(x: leftMargin, y: topMargin, width: mapWidth, height: mapHeight)
               
               mapView.mapType = MKMapType.standard
               mapView.isZoomEnabled = true
               mapView.isScrollEnabled = true
        self.inputView?.addSubview(mapView)
              
    }
    
    
    
    
}
