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

	override var acceptsFirstResponder: Bool {
		return true
	}
	
	private func sendEventToDelegate(_ inEvent: NSEvent) {
		qd3dDelegate?.qd3dView?(self, eventOccurred: inEvent)
	}
	
	override func keyDown(with event: NSEvent) {
		sendEventToDelegate(event)
	}
	
	override func keyUp(with event: NSEvent) {
		sendEventToDelegate(event)
	}
	
	override func mouseDown(with event: NSEvent) {
		sendEventToDelegate(event)
	}
	
	override func flagsChanged(with event: NSEvent) {
		sendEventToDelegate(event)
	}
	
	/// This shouldn't be called directly, but is here for subclasses to override
	/// (although they shouldn't need to...).
	/// if you want to 'force' a Quesa3DView to draw a frame, use `-setNeedsDisplay:YES`
	/// or `-display`.
	func drawQD3D() {
		var qd3dStatus: TQ3Status = kQ3Failure
		qd3dDelegate?.qd3dViewWillRender?(self)
		
		guard let qd3dView = qd3dView else {
			print("qd3dView is still NULL!")
			return
		}
		
		qd3dStatus = Q3View_StartRendering(qd3dView)
		
		if qd3dStatus == kQ3Success {
			repeat {
				qd3dDelegate?.qd3dViewRenderFrame?(self)
			} while Q3View_EndRendering(qd3dView) == kQ3ViewStatusRetraverse
		}
		
		// Call the post-render callback, if any
		qd3dDelegate?.qd3dViewDidRender?(self)
	}
	
	override func resetCursorRects() {
		if cursor == nil {
			self.cursor = NSCursor.arrow
		}
		addCursorRect(bounds, cursor: cursor)
	}

    override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)
		
		if qd3dView == nil {
			setupQD3D()
		}
		drawQD3D()
    }
    
	private func setupQD3D() {
		initQ3DrawContext()
		initQ3View()
	}
	
	private func initQ3DrawContext() {
		var cocoaDrawContextData = TQ3CocoaDrawContextData()
		let frame = bounds
		var qd3dStatus: TQ3Status = kQ3Failure
		var resetDrawContext = true
		
		// See if we've got an existing draw context we can reuse. If we
		// do, we grab as much of its state data as we can - this means we
		// wil preserve any changes made by the app's view-configure method.
		if let qd3dView = qd3dView {
			qd3dStatus = Q3View_GetDrawContext(qd3dView, &drawContext)
			resetDrawContext = false
			Q3DrawContext_GetData(self.drawContext!, &cocoaDrawContextData.drawContextData)
			Q3Object_Dispose(self.drawContext)

		}
		
		// Reset the draw context data if required
		if resetDrawContext {
			// Fill in the draw context data
			cocoaDrawContextData.drawContextData.clearImageMethod  = kQ3ClearMethodWithColor
			cocoaDrawContextData.drawContextData.clearImageColor.a = 1.0
			cocoaDrawContextData.drawContextData.clearImageColor.r = 0.0
			cocoaDrawContextData.drawContextData.clearImageColor.g = 0.0
			cocoaDrawContextData.drawContextData.clearImageColor.b = 0.2
			cocoaDrawContextData.drawContextData.paneState         = kQ3False
			cocoaDrawContextData.drawContextData.maskState		   = kQ3False
			cocoaDrawContextData.drawContextData.doubleBufferState = kQ3True
		}

		cocoaDrawContextData.drawContextData.pane.min.x = Float(frame.origin.x)
		cocoaDrawContextData.drawContextData.pane.min.y = Float(frame.origin.y)
		cocoaDrawContextData.drawContextData.pane.max.x = Float(frame.origin.x+frame.size.width)
		cocoaDrawContextData.drawContextData.pane.max.y = Float(frame.origin.y+frame.size.height)
		
		cocoaDrawContextData.nsView  = Unmanaged.passUnretained(self).toOpaque()

		// Create the draw context object
		self.drawContext = Q3CocoaDrawContext_New(&cocoaDrawContextData);
		if self.drawContext == nil {
			NSLog("Unable to create draw context in initQ3DrawContext");
		}
		
		
		// Sync to monitor refresh
		if let drawCtx = self.drawContext {
			var doSync: TQ3Boolean = kQ3True;
			Q3Object_SetProperty(drawCtx, kQ3DrawContextPropertySyncToRefresh,
								 TQ3Uns32(MemoryLayout<TQ3Boolean>.size), &doSync)
		}
	}
	
	private func initQ3View() {
		// Create the view
		if self.drawContext != nil {
			// Create the view
			self.qd3dView = Q3View_New()
			if let qd3dView = self.qd3dView {
				// Configure the view
				Q3View_SetDrawContext(qd3dView,    self.drawContext!)
				Q3View_SetRendererByType(qd3dView, kQ3RendererTypeOpenGL)
				createDefaultCamera()
				createDefaultLights()

				qd3dDelegate?.qd3dViewDidInit?(self)
			}
		}
	}
	
	private func createDefaultLights() {
		let sunDirection = TQ3Vector3D(x: -1, y: 0, z: -1)
		let eyeDirection = TQ3Vector3D(x: 0, y: 0, z: -1)
		let pointLocation = TQ3Point3D(x: -10, y: 0, z: 10)
		let colourWhite = TQ3ColorRGB(r: 1, g: 1, b: 1)
		
		var ambientLight = TQ3LightData()
		var sunLight = TQ3DirectionalLightData()
		var eyeLight = TQ3DirectionalLightData()
		var pointLight = TQ3PointLightData()

		// Set up the ambient light
		ambientLight.isOn       = kQ3True
		ambientLight.color      = colourWhite
		ambientLight.brightness = 0.3

		// Set up the directional lights
		sunLight.lightData.isOn       = kQ3True;
		sunLight.lightData.color      = colourWhite;
		sunLight.lightData.brightness = 0.8;
		sunLight.castsShadows         = kQ3True;
		sunLight.direction            = sunDirection;

		eyeLight.lightData.isOn       = kQ3True;
		eyeLight.lightData.color      = colourWhite;
		eyeLight.lightData.brightness = 0.2;
		eyeLight.castsShadows         = kQ3False;
		eyeLight.direction            = eyeDirection;


		// Set up the point light
		pointLight.lightData.isOn       = kQ3True;
		pointLight.lightData.color      = colourWhite;
		pointLight.lightData.brightness = 0.8;
		pointLight.castsShadows         = kQ3True;
		pointLight.location				= pointLocation;
		pointLight.attenuation			= kQ3AttenuationTypeNone;

		createLight(withData: ambientLight)
		createLight(withData: sunLight)
		createLight(withData: eyeLight)
		createLight(withData: pointLight)
	}
	
	func createDefaultCamera() {
		let cameraFrom = TQ3Point3D(x: 0, y: 0, z: 5)
		let cameraTo = TQ3Point3D(x: 0, y: 0, z: 0)
		let cameraUp = TQ3Vector3D(x: 0, y: 1, z: 0)
		let fieldOfView = Q3Math_DegreesToRadians(50.0)
		let hither: Float = 0.1
		let yon: Float = 10
		
		var theArea = TQ3Area()
		
		guard let qd3dView = qd3dView else {
			return
		}
		// Get the size of the image we're rendering
		Q3DrawContext_GetPane(self.drawContext!, &theArea)
		var cameraData = TQ3ViewAngleAspectCameraData()
		
		// Fill in the camera data
		cameraData.cameraData.placement.cameraLocation 	= cameraFrom
		cameraData.cameraData.placement.pointOfInterest = cameraTo
		cameraData.cameraData.placement.upVector 		= cameraUp
		cameraData.cameraData.range.hither				= hither
		cameraData.cameraData.range.yon					= yon
		cameraData.cameraData.viewPort.origin.x			= -1.0
		cameraData.cameraData.viewPort.origin.y			=  1.0
		cameraData.cameraData.viewPort.width			=  2.0
		cameraData.cameraData.viewPort.height			=  2.0
		cameraData.fov									= fieldOfView

		let rectWidth: Float           = theArea.max.x - theArea.min.x
		let rectHeight: Float          = theArea.max.y - theArea.min.y
		cameraData.aspectRatioXToY = (rectWidth / rectHeight)

		// Create the camera object
		let theCamera = Q3ViewAngleAspectCamera_New(&cameraData);
		Q3View_SetCamera(qd3dView, theCamera);
		if theCamera != nil {
			Q3Object_Dispose(theCamera)
		}
	}
	
	override func reshape() {
		super.reshape()
		if let _ = qd3dView, let qd3dDelegate = qd3dDelegate {
			qd3dDelegate.qd3dViewReshaped?(self)
		}
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
