//
//  QD3DView.swift
//  QuesaSwiftTest
//
//  Created by C.W. Betts on 4/13/22.
//

import Cocoa
import Quesa
import Quesa.QuesaDrawContext
import Quesa.QuesaCamera
import Quesa.QuesaView
import Quesa.QuesaMath
import Quesa.QuesaLight
import Quesa.QuesaStyle
import Quesa.QuesaGroup

class QD3DView: NSOpenGLView {

	@IBOutlet weak open var qd3dDelegate: QD3DViewDelegate?

	
	var cursor: NSCursor!

	
	private(set) var drawContext: TQ3DrawContextObject? = nil

	private(set) var qd3dView: TQ3ViewObject? = nil

	
	func createLight(withData lightData: Any) {
		guard let quesaView = qd3dView else {
			return
		}
		var theLight: TQ3LightObject?
		var lightGroup: TQ3GroupObject? = nil
		// Get the light group for the view
		let qd3dStatus = Q3View_GetLightGroup(quesaView, &lightGroup)
		
		guard qd3dStatus == kQ3Success else {
			return
		}

		// If we don't have a light group yet, create one
		if lightGroup == nil {
			lightGroup = Q3LightGroup_New();
			
			guard let lightGroup = lightGroup else {
				return
			}
			Q3View_SetLightGroup(quesaView, lightGroup)
		}
		defer {
			Q3Object_Dispose(lightGroup)
		}
		
		// Create the light object
		if var lightData = lightData as? TQ3LightData {
			// kQ3LightTypeAmbient
			theLight = Q3AmbientLight_New(&lightData)
		} else if var lightData = lightData as? TQ3DirectionalLightData {
			// kQ3LightTypeDirectional
			theLight = Q3DirectionalLight_New(&lightData)
		} else if var lightData = lightData as? TQ3PointLightData {
			// kQ3LightTypePoint
			theLight = Q3PointLight_New(&lightData)
		} else if var lightData = lightData as? TQ3SpotLightData {
			// kQ3LightTypeSpot
			theLight = Q3SpotLight_New(&lightData)
		}
		
		// Add the light to the light group
		if let theLight = theLight, let lightGroup = lightGroup {
			Q3Group_AddObject(lightGroup, theLight)
			Q3Object_Dispose(theLight)
		}
	}
	
	@objc func createLight(_ lightType: TQ3ObjectType, withData lightData: UnsafeMutableRawPointer?) {
		let newLightData: Any?
		switch lightType {
		case kQ3LightTypeAmbient:
			newLightData = lightData?.bindMemory(to: TQ3LightData.self, capacity: 1).pointee
			
		case kQ3LightTypeDirectional:
			newLightData = lightData?.bindMemory(to: TQ3DirectionalLightData.self, capacity: 1).pointee

		case kQ3LightTypePoint:
			newLightData = lightData?.bindMemory(to: TQ3PointLightData.self, capacity: 1).pointee

		case kQ3LightTypeSpot:
			newLightData = lightData?.bindMemory(to: TQ3SpotLightData.self, capacity: 1).pointee

		default:
			return
		}
		if let newLightData = newLightData {
			createLight(withData: newLightData)
		}
	}

	deinit {
		if let qd3dView = qd3dView {
			Q3Object_Dispose(qd3dView)
			self.qd3dView = nil
		}
		
		if let drawContext = drawContext {
			Q3Object_Dispose(drawContext)
			self.drawContext = nil
		}
	}

	
	/// This shouldn't be called directly, but is here for subclasses to override
	/// (although they shouldn't need to...).
	/// if you want to 'force' a Quesa3DView to draw a frame, use `-setNeedsDisplay:YES`
	/// or `-display`.
	func drawQD3D() {
		
	}

    override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)
		
		if qd3dView == nil {
			setupQD3D()
		}
		drawQD3D()
    }
    
	private func setupQD3D() {
//		[self initQ3DrawContext];
//		[self initQ3View];
	}
}


///	The `QD3DViewDelegate` is called upon to actually submit the application
///	specific QD3D objects to the `TQ3ViewObject`.
///
///	The first time through the draw loop, after the `QD3DView` is visible, the
///	view initializes the draw context and calls `qd3dViewDidInit(_:)` on it's qd3dDelegate.
///	This is a good time to setup lights (default lights are created).
///
///	Each frame, `qd3dViewWillRender(_:)` is called then starts the
///	Q3View rendering loop. Inside, `qd3dViewRenderFrame(_:)` is called on the qd3dDelegate
///	on each pass through the frame. This is where the qd3dDelegate should submit the
///	objects to the view's `TQ3ViewObject`.
///
///	After rendering is finished, `qd3dViewDidRender(_:)` is called.
///	At the moment, KeyUp and KeyDown events are also passed to the qd3dView. I'm not sure
///	if this is a good idea or not, but they seem useful there.
@objc protocol QD3DViewDelegate : NSObjectProtocol {

	
	@objc optional func qd3dViewDidInit(_ inView: QD3DView)

	@objc optional func qd3dViewWillRender(_ inView: QD3DView)

	@objc optional func qd3dViewRenderFrame(_ inView: QD3DView)

	@objc optional func qd3dViewDidRender(_ inView: QD3DView)

	@objc optional func qd3dView(_ inView: QD3DView, eventOccurred inEvent: NSEvent)

	@objc optional func qd3dViewReshaped(_ inView: QD3DView)
}
