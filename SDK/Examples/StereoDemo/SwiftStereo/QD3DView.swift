//
//  QD3DView.swift
//  SwiftStereo
//
//  Created by C.W. Betts on 4/1/18.
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


///	The `QD3DViewDelegate` is called upon to actually submit the application
///	specific QD3D objects to the `TQ3ViewObject`.
///
///	The first time through the draw loop, after the `QD3DView` is visible, the
///	view initializes the draw context and calls `qd3dViewDidInit(_:)` on its
///	`qd3dDelegate`.
///	This is a good time to setup lights (default lights are created).
///
///	Each frame, `qd3dViewWillRender(_:)` is called.  If the delegate implements
///	`quesaViewRenderFrame(_:)`, it is called to handle the whole rendering task;
///	otherwise, the view starts a rendering loop and calls the delegate method
///	`qd3dViewSubmitObjects(_:)` to submit objects for rendering.
///
///	After rendering is finished, `qd3dViewDidRender(_:)` is called.
///	At the moment, `KeyUp` and `KeyDown` events are also passed to the `quesaView`. I'm not sure
///	if this is a good idea or not, but they seem useful there.
@objc protocol QD3DViewDelegate {
	@objc optional func qd3dViewDidInit(_ inView: QD3DView)
	
	@objc optional func qd3dViewWillRender(_ inView: QD3DView)
	
	@objc optional func qd3dViewSubmitObjects(_ inView: QD3DView)
	
	@objc optional func qd3dViewRenderFrame(_ inView: QD3DView)
	
	@objc optional func qd3dViewDidRender(_ inView: QD3DView)
	
	@objc optional func qd3dView(_ inView: QD3DView, eventOccurred inEvent: NSEvent)
}


class QD3DView: NSView {
	weak var qd3dDelegate: QD3DViewDelegate?
	private(set) var drawContext: TQ3DrawContextObject?
	private(set) var quesaView: TQ3ViewObject?
	private(set) var camera: TQ3CameraObject?
	
	private static let __once: () = {
		var qd3dStatus: TQ3Status = kQ3Success
		if Q3IsInitialized() != kQ3True {
			qd3dStatus = Q3Initialize()
		}

		if qd3dStatus != kQ3Success {
			print("Error in Q3Initialize");
		}
	}()
	
	func createLight(withData lightData: Any) {
		guard let quesaView = quesaView else {
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
			Q3View_SetLightGroup(quesaView, lightGroup);
		}
		defer {
			Q3Object_Dispose(lightGroup);
		}
		
		// Create the light object
		if var lightData = lightData as? TQ3LightData {
			// kQ3LightTypeAmbient
			theLight = Q3AmbientLight_New(&lightData);
		} else if var lightData = lightData as? TQ3DirectionalLightData {
			// kQ3LightTypeDirectional
			theLight = Q3DirectionalLight_New(&lightData);
		} else if var lightData = lightData as? TQ3PointLightData {
			// kQ3LightTypePoint
			theLight = Q3PointLight_New(&lightData);
		} else if var lightData = lightData as? TQ3SpotLightData {
			// kQ3LightTypeSpot
			theLight = Q3SpotLight_New(&lightData);
		}
		
		// Add the light to the light group
		if let theLight = theLight, let lightGroup = lightGroup {
			Q3Group_AddObject(lightGroup, theLight);
			Q3Object_Dispose(theLight);
		}
	}
	
	func createLight(_ lightType: TQ3ObjectType, withData lightData: UnsafeMutableRawPointer?) {
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
	
	/// this shouldn't be called directly, but is here for subclasses to override
	/// (although they shouldn't need to...).
	/// if you want to 'force' a Quesa3DView to draw a frame, use `setNeedsDisplay:YES`
	/// or `display`
	func drawQD3D() {
		guard let quesaView = quesaView else  {
			print("quesaView is still NULL!")
			return
		}
		
		if let quesaDelegate = qd3dDelegate {
			// Pre-render delegate notification
			quesaDelegate.qd3dViewRenderFrame?(self)
			
			// Render another frame
			if let renderFrame = quesaDelegate.qd3dViewRenderFrame {
				renderFrame(self)
			} else if let submitObjs = quesaDelegate.qd3dViewSubmitObjects {
				if Q3View_StartRendering(quesaView) == kQ3Success {
					repeat {
						submitObjs(self)
					} while (Q3View_EndRendering(quesaView) == kQ3ViewStatusRetraverse);
				}
			}
			
			// Post-render delegate notification
			quesaDelegate.qd3dViewDidRender?(self)
		}
	}
	
	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		// Listen for frame changes to myself, so that the aspect ratio can be
		// kept up to date.
		postsFrameChangedNotifications = true
		NotificationCenter.default.addObserver(self, selector: #selector(QD3DView.frameChanged(_:)), name: NSView.frameDidChangeNotification, object: self)
	}
	
	required init?(coder decoder: NSCoder) {
		super.init(coder: decoder)
		postsFrameChangedNotifications = true
		NotificationCenter.default.addObserver(self, selector: #selector(QD3DView.frameChanged(_:)), name: NSView.frameDidChangeNotification, object: self)
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
		if let quesaView = quesaView {
			Q3Object_Dispose(quesaView)
		}
		
		if let drawContext = drawContext {
			Q3Object_Dispose(drawContext)
		}
		
		if let camera = camera {
			Q3Object_Dispose(camera)
		}
	}
	
	override func draw(_ dirtyRect: NSRect) {
		if (quesaView == nil) {
			setupQD3D()
		}
		drawQD3D()
    }
	
	private func setupQD3D() {
		initQ3DrawContext()
		initQ3View()
	}
	
	private func initQ3DrawContext() {
		var cocoaDrawContextData = TQ3CocoaDrawContextData(drawContextData: TQ3DrawContextData(), nsView: Unmanaged.passUnretained(self).toOpaque())
		var resetDrawContext: TQ3Boolean
		var qd3dStatus: TQ3Status
		let frame = self.bounds;
		
		// See if we've got an existing draw context we can reuse. If we
		// do, we grab as much of its state data as we can - this means we
		// wil preserve any changes made by the app's view-configure method.
		resetDrawContext = kQ3True;
		if let quesaView = quesaView {
			qd3dStatus = Q3View_GetDrawContext(quesaView, &drawContext);
			if qd3dStatus == kQ3Success, let drawContext = drawContext {
				resetDrawContext = kQ3False;
				Q3DrawContext_GetData(drawContext, &cocoaDrawContextData.drawContextData);
				Q3Object_Dispose(drawContext);
			}
		}
		
		// Reset the draw context data if required
		if (resetDrawContext.boolValue)
		{
			// Fill in the draw context data
			cocoaDrawContextData.drawContextData.clearImageMethod  = kQ3ClearMethodWithColor;
			cocoaDrawContextData.drawContextData.clearImageColor.a = 1.0
			cocoaDrawContextData.drawContextData.clearImageColor.r = 0.0
			cocoaDrawContextData.drawContextData.clearImageColor.g = 0.0
			cocoaDrawContextData.drawContextData.clearImageColor.b = 0.2
			cocoaDrawContextData.drawContextData.paneState         = kQ3False;
			cocoaDrawContextData.drawContextData.maskState		   = kQ3False;
			cocoaDrawContextData.drawContextData.doubleBufferState = kQ3True;
		}
		
		
		
		
		cocoaDrawContextData.drawContextData.pane.min.x = Float(frame.origin.x);
		cocoaDrawContextData.drawContextData.pane.min.y = Float(frame.origin.y);
		cocoaDrawContextData.drawContextData.pane.max.x = Float(frame.origin.x+frame.size.width);
		cocoaDrawContextData.drawContextData.pane.max.y = Float(frame.origin.y+frame.size.height);
		
		cocoaDrawContextData.nsView = Unmanaged.passUnretained(self).toOpaque()
		
		
		
		// Create the draw context object
		drawContext = Q3CocoaDrawContext_New(&cocoaDrawContextData);
		
		// Sync to monitor refresh
		if let drawContext = drawContext {
			var	doSync = kQ3True;
			Q3Object_SetProperty( drawContext, TQ3ObjectType(kQ3DrawContextPropertySyncToRefresh),
								  TQ3Uns32(MemoryLayout<TQ3Boolean>.size), &doSync );
		} else {
			NSLog("Unable to create draw context in initQ3DrawContext")
		}
	}
	
	private func initQ3View() {
		var qd3dStatus: TQ3Status
		
		// Create the view
		if let drawContext = drawContext {
			// Create the view
			quesaView = Q3View_New();
			if let quesaView = quesaView {
				// Configure the view
				qd3dStatus = Q3View_SetDrawContext(quesaView,    drawContext);
				qd3dStatus = Q3View_SetRendererByType(quesaView, kQ3RendererTypeInteractive);
				//[self createDefaultCamera];
				createDefaultLights()
				
				qd3dDelegate?.qd3dViewDidInit?(self)
			}
		} else {
			NSLog("TQ3DrawContext is NULL in initQ3View!");
		}
	}
	
	public func createDefaultCamera() {
		let cameraFrom		= TQ3Point3D(x: 0.0, y: 0.0, z: 5.0)
		let cameraTo		= TQ3Point3D(x: 0.0, y: 0.0, z: 0.0)
		let cameraUp		= TQ3Vector3D(x: 0.0, y: 1.0, z: 0.0)
		let fieldOfView		= Q3Math_DegreesToRadians(50.0);
		let hither: Float	=  0.1
		let yon: Float		= 10.0
		var cameraData		= TQ3ViewAngleAspectCameraData()
		var qd3dStatus: TQ3Status
		var theArea			= TQ3Area()
		
		guard let quesaView = quesaView, let drawContext = drawContext else {
			return
		}
		// Get the size of the image we're rendering
		qd3dStatus = Q3DrawContext_GetPane(drawContext, &theArea);
		
		// Fill in the camera data
		cameraData.cameraData.placement.cameraLocation 	= cameraFrom;
		cameraData.cameraData.placement.pointOfInterest = cameraTo;
		cameraData.cameraData.placement.upVector 		= cameraUp;
		cameraData.cameraData.range.hither				= hither;
		cameraData.cameraData.range.yon					= yon;
		cameraData.cameraData.viewPort.origin.x			= -1.0;
		cameraData.cameraData.viewPort.origin.y			=  1.0;
		cameraData.cameraData.viewPort.width			=  2.0;
		cameraData.cameraData.viewPort.height			=  2.0;
		cameraData.fov									= fieldOfView;
		
		let rectWidth                  = theArea.max.x - theArea.min.x
		let rectHeight                 = theArea.max.y - theArea.min.y
		cameraData.aspectRatioXToY = (rectWidth / rectHeight)
		
		// Create the camera object
		camera = Q3ViewAngleAspectCamera_New( &cameraData )
		if let camera = camera {
			qd3dStatus = Q3View_SetCamera( quesaView, camera )
		}
	}
	
	func createDefaultLights() {
		let sunDirection = TQ3Vector3D(x: -1, y: 0, z: -1)
		let eyeDirection = TQ3Vector3D(x: 0, y: 0, z: -1)
		let colourWhite = TQ3ColorRGB(r: 1, g: 1, b: 1)
		var ambientLight = TQ3LightData()
		var sunLight = TQ3DirectionalLightData()
		var eyeLight = TQ3DirectionalLightData()

		// Set up the ambient light
		ambientLight.isOn       = kQ3True;
		ambientLight.color      = colourWhite;
		ambientLight.brightness = 0.3

		// Set up the directional lights
		sunLight.lightData.isOn       = kQ3True;
		sunLight.lightData.color      = colourWhite;
		sunLight.lightData.brightness = 1.0;
		sunLight.castsShadows         = kQ3True;
		sunLight.direction            = sunDirection;
		
		eyeLight.lightData.isOn       = kQ3True;
		eyeLight.lightData.color      = colourWhite;
		eyeLight.lightData.brightness = 0.2;
		eyeLight.castsShadows         = kQ3True;
		eyeLight.direction            = eyeDirection;

		// Add the lights
		createLight(withData: ambientLight)
		createLight(withData: sunLight)
		createLight(withData: eyeLight)
	}
	
	@objc private func frameChanged(_ note: Notification) {
		guard let drawContext = drawContext, let camera = camera else {
			return
		}
		var theArea = TQ3Area()
		Q3DrawContext_GetPane(drawContext, &theArea);

		let aspect = (theArea.max.x - theArea.min.x) / (theArea.max.y - theArea.min.y)
		
		Q3ViewAngleAspectCamera_SetAspectRatio(camera, aspect)
	}
	
	override func keyDown(with event: NSEvent) {
		sendEventToDelegate(event)
	}
	
	override func keyUp(with event: NSEvent) {
		sendEventToDelegate(event)
	}
	
	private func sendEventToDelegate(_ inEvent: NSEvent) {
		qd3dDelegate?.qd3dView?(self, eventOccurred: inEvent)
	}
}
