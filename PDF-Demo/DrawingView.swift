//
//  DrawingView.swift
//
//  Created by Max on 10/31/17.
//  Copyright (c) 2017 Max. All rights reserved.
//

import UIKit
import PDFKit
protocol DrawingViewDelegate: class {
    func didEndDrawLine(bezierPath: UIBezierPath)
}
class DrawingView: UIView {
	
	var drawColor = UIColor.black
	var lineWidth: CGFloat = 1
	weak var delegate: DrawingViewDelegate?
	private var lastPoint: CGPoint!
	private var bezierPath: UIBezierPath!
	private var pointCounter: Int = 0
	private let pointLimit: Int = 150
	private var preRenderImage: UIImage!
	var pdfview : PDFView?
	// MARK: - Initialization
	
	override init(frame: CGRect) {
		super.init(frame: frame)
        
		initBezierPath()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		initBezierPath()
	}
	
	func initBezierPath() {
		bezierPath = UIBezierPath()
		bezierPath.lineCapStyle = CGLineCap.round
		bezierPath.lineJoinStyle = CGLineJoin.round
	}
	
    
	// MARK: - Touch handling
	
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
         print("touchesBegan")
    
        
        let touch: AnyObject? = touches.first
        lastPoint = touch!.location(in: self)
        pointCounter = 0
         print(lastPoint)
    
        
      //  print(touch)
    }

    
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
          print("touchesMoved")
		let touch: AnyObject? = touches.first
		let newPoint = touch!.location(in: self)
        print(newPoint)
       
        // disable pdf gesture because when we move fast then gesture call touch end force fully.
        if (pdfview?.gestureRecognizers?.count)! > 0
        {
            if  let objGesture = pdfview?.gestureRecognizers?[0]
            {
                pdfview?.removeGestureRecognizer(objGesture)
            }
        }
        
		bezierPath.move(to: lastPoint)
		bezierPath.addLine(to: newPoint)
		lastPoint = newPoint
		
      
		//pointCounter += 1
	      
           print(lastPoint)
          print(pointCounter)
        
		if pointCounter == pointLimit {
			pointCounter = 0
			renderToImage()
			setNeedsDisplay()
			bezierPath.removeAllPoints()
		}
		else
        {
			setNeedsDisplay()
		}
	}
    
 
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        

        print("touchesEnded")
        print(lastPoint)
        print(touches)
        
      
    //    pdfview?.removeGestureRecognizer((pdfview?.gestureRecognizers?[0])!)
        
        
		pointCounter = 0
		renderToImage()
		setNeedsDisplay()
        delegate?.didEndDrawLine(bezierPath: bezierPath)
		clear()
        
	}
	
	override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?) {
		touchesEnded(touches!, with: event)
	}
	
	// MARK: - Pre render
	
	func renderToImage() {
		
		UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, 0.0)
		if preRenderImage != nil {
			preRenderImage.draw(in: self.bounds)
		}
		
		bezierPath.lineWidth = lineWidth
		drawColor.setFill()
		drawColor.setStroke()
		bezierPath.stroke()
		
		preRenderImage = UIGraphicsGetImageFromCurrentImageContext()
		
		UIGraphicsEndImageContext()
	}
	
	// MARK: - Render
	
	override func draw(_ rect: CGRect) {
		super.draw(rect)
		
		if preRenderImage != nil {
			preRenderImage.draw(in: self.bounds)
		}
		
		bezierPath.lineWidth = lineWidth
		drawColor.setFill()
		drawColor.setStroke()
		bezierPath.stroke()
        
	}

	// MARK: - Clearing
	
	func clear() {
		preRenderImage = nil
		bezierPath.removeAllPoints()
		setNeedsDisplay()
	}
	
	// MARK: - Other

	func hasLines() -> Bool {
		return preRenderImage != nil || !bezierPath.isEmpty
	}

}
