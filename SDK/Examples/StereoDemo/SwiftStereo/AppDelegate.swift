//
//  AppDelegate.swift
//  SwiftStereo
//
//  Created by C.W. Betts on 4/1/18.
//

import Cocoa
import Quesa
import Quesa.QuesaDrawContext
import Quesa.QuesaCamera
import Quesa.QuesaShader
import Quesa.QuesaMath
import Quesa.QuesaView
import Quesa.QuesaMath
import Quesa.QuesaLight
import Quesa.QuesaStyle
import Quesa.QuesaGroup
import Quesa.QuesaGeometry
import Quesa.QuesaTransform
import Quesa.QuesaRenderer
import OpenGL.GL

enum MenuItemGeometry: Int, @unchecked Sendable {
	case box = 1
	case cone
	case cylinder
	case disk
	case ellipse
	case ellipsoid
	case generalPolygon
	case line
	case marker
	case mesh
	case NURBCurve
	case NURBPatch
	case pixmapMarker
	case point
	case polyLine
	case polygon
	case polyhedron
	case QuesaLogo
	case torus
	case triangle
	case triGrid
	case triMesh
	case pastelGroup
}

public enum LeftRightFormat : Int, @unchecked Sendable {
	case redCyan = 1

	case greenMagenta = 2

	case blueYellow = 3

	case cyanRed = 4

	case magentaGreen = 5

	case yellowBlue = 6

	
	case evenOdd = 7

	case oddEven = 8
}


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, QD3DViewDelegate {

	@IBOutlet weak var window: NSWindow!

	@IBOutlet weak var quesa3dView:  QD3DView!
	@IBOutlet weak var rendererMenu: NSPopUpButton!
	@IBOutlet weak var objectMenu: NSPopUpButton!

	private var mAnimationTimer: Timer? = nil

	private var mCurrentMatrix = TQ3Matrix4x4()
	private var mRotationFactor = TQ3Matrix4x4()

	
	func applicationDidFinishLaunching(_ aNotification: Notification) {
		// Insert code here to initialize your application
	}

	func applicationWillTerminate(_ aNotification: Notification) {
		// Insert code here to tear down your application
	}

	private var mSceneGeometry: TQ3ShapeObject? = nil
	private var mSceneBounds: TQ3Object? = nil
	private var mIlluminationShader: TQ3ShaderObject! = nil
	private var mViewPlaneCamera: TQ3CameraObject? = nil

	private var mIsFirstPassForEye = false

	private let mPixelFormat: NSOpenGLPixelFormat = {
		let glAttributes: [NSOpenGLPixelFormatAttribute] = [
			NSOpenGLPixelFormatAttribute(NSOpenGLPFADoubleBuffer),
			NSOpenGLPixelFormatAttribute(NSOpenGLPFADepthSize), 24,
			NSOpenGLPixelFormatAttribute(NSOpenGLPFAStencilSize), 8,
			NSOpenGLPixelFormatAttribute(NSOpenGLPFASampleBuffers), 1,
			NSOpenGLPixelFormatAttribute(NSOpenGLPFASamples), 4,
//			NSOpenGLPixelFormatAttribute(NSOpenGLPFAWindow),
			0,
		]

		return NSOpenGLPixelFormat(attributes: glAttributes)!
	}()

	dynamic var drawsShadows: Bool = false {
		didSet {
			if drawsShadows != oldValue {
				updateRendererShadowFlag()
			}
		}
	}
	
	dynamic var animates: Bool = false {
		didSet {
			guard animates != oldValue else {
				return
			}
			if animates {
				mAnimationTimer = Timer(timeInterval: 0.05, target: self, selector: #selector(AppDelegate.animationTimerFired(_:)), userInfo: nil, repeats: true)
			} else {
				mAnimationTimer?.invalidate()
				mAnimationTimer = nil
				updateManualRotation()
			}
		}
	}
	
	override func awakeFromNib() {
		buildRendererMenu()
		objectMenu.selectItem(withTag: MenuItemGeometry.pastelGroup.rawValue)
		setGeometryFromTag(objectMenu)

		Q3Matrix4x4_SetIdentity(&mCurrentMatrix)
		Q3Matrix4x4_SetRotate_XYZ(&mRotationFactor, 0.03, 0.05, 0.005)
		mIlluminationShader = Q3PhongIllumination_New()
		initViewPlaneCamera()
	}
	
	private func buildRendererMenu() {
		var rendererData = TQ3SubClassData()
		var qd3dStatus: TQ3Status = kQ3Failure
		var theStr = [CChar](repeating: 0, count: 1024)
		
		//build the renderer menu
		rendererMenu.removeAllItems()
		
		// Collect the renderers which are available
		qd3dStatus = Q3ObjectHierarchy_GetSubClassData(kQ3SharedTypeRenderer, &rendererData)
		guard qd3dStatus == kQ3Success else {
			return
		}
		defer {
			// Clean up
			Q3ObjectHierarchy_EmptySubClassData(&rendererData)
		}
		
		// If we can find any renderers, add them to the menu
		for val in UnsafeBufferPointer(start: rendererData.classTypes, count: Int(rendererData.numClasses)) {
			// Skip the generic renderer, since it can't actually render
			guard val != kQ3RendererTypeGeneric else {
				continue
			}
			// Grab the nick name, falling back to the class name if that fails
			qd3dStatus = Q3RendererClass_GetNickNameString(val,
														   &theStr);
			if qd3dStatus == kQ3Failure || theStr[0] == 0x00 {
				qd3dStatus = Q3ObjectHierarchy_GetStringFromType(val, &theStr);
			}
			
			
			// Add the menu item and save the type
			if (qd3dStatus == kQ3Success) && (theStr[0] != 0x00) {
				rendererMenu.addItem(withTitle: String(utf8String: theStr)!)
				rendererMenu.lastItem?.tag = Int(val)
			}
		}
	}
	
	private func initViewPlaneCamera() {
		// Most of the camera data will be reset just before we render, so the
		// values do not matter, so long as they are somewhat sane.
		var camData = TQ3ViewPlaneCameraData(cameraData: TQ3CameraData(placement: TQ3CameraPlacement(cameraLocation: TQ3Point3D(x: 0, y: 0, z: 1), pointOfInterest: TQ3Point3D(x: 0, y: 0, z: 0), upVector: TQ3Vector3D(x: 0, y: 1, z: 0)), range: TQ3CameraRange(hither: 0.10, yon: 1000), viewPort: TQ3CameraViewPort(origin: TQ3Point2D(x: -1, y: 1), width: 2, height: 2)), viewPlane: 1, halfWidthAtViewPlane: 1, halfHeightAtViewPlane: 1, centerXOnViewPlane: 0, centerYOnViewPlane: 0)
		mViewPlaneCamera = Q3ViewPlaneCamera_New(&camData)
	}
	
	var drawsBounds: Bool {
		get {
			return mSceneBounds != nil
		}
		set {
			if let mSceneBounds = mSceneBounds {
				Q3Object_Dispose(mSceneBounds)
				self.mSceneBounds = nil
			}
			
			if newValue {
				mSceneBounds = createGeomBounds(mSceneGeometry!, in: quesa3dView.quesaView!)
			}
		}
	}
	
	var rendererType: TQ3ObjectType = 0 {
		didSet {
			guard rendererType != oldValue else {
				return
			}
			Q3View_SetRendererByType(quesa3dView.quesaView!, rendererType)
			updateRendererShadowFlag()
			quesa3dView.needsDisplay = true
		}
	}
	
	func updateRendererShadowFlag() {
		var theRenderer: TQ3RendererObject? = nil
		Q3View_GetRenderer(quesa3dView.quesaView!, &theRenderer)
		if let theRenderer = theRenderer {
			var shadowFlag: TQ3Boolean = drawsShadows ? kQ3True : kQ3False
			Q3Object_SetProperty(theRenderer, kQ3RendererPropertyShadows, TQ3Uns32(MemoryLayout<TQ3Boolean>.size), &shadowFlag)
			
			Q3Object_Dispose(theRenderer)
		}
		
		quesa3dView.needsDisplay = true
	}
	
	dynamic var fullScreenAntialias: Bool = false {
		didSet {
			guard fullScreenAntialias != oldValue else {
				return
			}
			let dc = quesa3dView.drawContext!
			
			if fullScreenAntialias {
				var pixFmt = mPixelFormat
				Q3Object_SetProperty(dc, kQ3DrawContextPropertyGLPixelFormat,
									 TQ3Uns32(MemoryLayout.size(ofValue: mPixelFormat)), &pixFmt)
			} else {
				Q3Object_RemoveProperty(dc, kQ3DrawContextPropertyGLPixelFormat)
			}
			
			// In some cases, the driver disregards disabling of GL_MULTISAMPLE,
			// so the only way to be sure we can turn antialiasing on and off is
			// to recreate the renderer.
			var theRenderer: TQ3RendererObject? = nil
			Q3View_GetRenderer(quesa3dView.quesaView!, &theRenderer)
			if let theRenderer = theRenderer {
				let theType = Q3Renderer_GetType( theRenderer )
				Q3View_SetRendererByType(quesa3dView.quesaView!, theType)
				Q3Object_Dispose(theRenderer)
			}
			quesa3dView.needsDisplay = true
		}
	}
	
	dynamic var xRotation: Float = 0 {
		didSet {
			quesa3dView.needsDisplay = true
		}
	}
	
	dynamic var yRotation: Float = 0 {
		didSet {
			quesa3dView.needsDisplay = true
		}
	}
	
	dynamic var zRotation: Float = 0 {
		didSet {
			quesa3dView.needsDisplay = true
		}
	}

	dynamic var projectionDistance: Float = 3 {
		didSet {
			quesa3dView.needsDisplay = true
		}
	}
	
	dynamic var separationDistance: Float = 0.08 {
		didSet {
			quesa3dView.needsDisplay = true
		}
	}

	dynamic var leftRightFormat: LeftRightFormat = .redCyan {
		didSet {
			quesa3dView.needsDisplay = true
		}
	}
	
	@IBAction func setGeometryFromTag(_ sender: NSPopUpButton?) {
		guard let tagVal = sender?.selectedItem?.tag, let itemGeom = MenuItemGeometry(rawValue: tagVal) else {
			NSSound.beep()
			return
		}
		var theGeom: TQ3GeometryObject? = nil
		
		switch itemGeom {
		case .box:
			theGeom = createGeomBox()
		case .cone:
			theGeom = createGeomCone()
		case .cylinder:
			theGeom = createGeomCylinder()
		case .disk:
			theGeom = createGeomDisk()
		case .ellipse:
			theGeom = createGeomEllipse()
		case .ellipsoid:
			theGeom = createGeomEllipsoid()
		case .generalPolygon:
			theGeom = createGeomGeneralPolygon()
		case .line:
			theGeom = createGeomLine()
		case .marker:
			theGeom = createGeomMarker()
		case .mesh:
			theGeom = createGeomMesh()
		case .NURBCurve:
			theGeom = createGeomNURBCurve()
		case .NURBPatch:
			theGeom = createGeomNURBPatch()
		case .pixmapMarker:
			theGeom = createGeomPixmapMarker()
		case .point:
			theGeom = createGeomPoint()
		case .polyLine:
			theGeom = createGeomPolyLine()
		case .polygon:
			theGeom = createGeomPolygon()
		case .polyhedron:
			theGeom = createGeomPolyhedron()
		case .QuesaLogo:
			theGeom = createGeomQuesa()
		case .torus:
			theGeom = createGeomTorus()
		case .triangle:
			theGeom = createGeomTriangle()
		case .triGrid:
			theGeom = createGeomTriGrid()
		case .triMesh:
			theGeom = createGeomTriMesh()
		case .pastelGroup:
			theGeom = createPastelGroup()
		}
		
		// If we created it, replace the current geometry
		if let theGeom = theGeom {
			if let mSceneGeometry = mSceneGeometry {
				Q3Object_Dispose(mSceneGeometry)
			}
			
			mSceneGeometry = theGeom
			
			drawsBounds = drawsBounds
		}
		
		Q3Matrix4x4_SetIdentity(&mCurrentMatrix)
		quesa3dView.needsDisplay = true
	}
	
	func updateManualRotation() {
		Q3Matrix4x4_SetRotate_XYZ(&mCurrentMatrix,
								  Q3Math_DegreesToRadians(xRotation),
								  Q3Math_DegreesToRadians(yRotation),
								  Q3Math_DegreesToRadians(zRotation))
		quesa3dView.needsDisplay = true
	}
	
	@objc private func animationTimerFired(_ timer: Timer) {
		mCurrentMatrix *= mRotationFactor
		quesa3dView.needsDisplay = true
	}
	
	private func submitStyles(_ theView: TQ3ViewObject) {
		var fullAntialias = TQ3AntiAliasStyleData(state: fullScreenAntialias ? kQ3On : kQ3Off, mode: kQ3AntiAliasModeMaskFullScreen.rawValue, quality: 1)
		var subdivStyle = TQ3SubdivisionStyleData(method: kQ3SubdivisionMethodConstant, c1: 30, c2: 30)
		
		// Submit the styles
		Q3BackfacingStyle_Submit(kQ3BackfacingStyleBoth, theView)
		Q3InterpolationStyle_Submit(kQ3InterpolationStyleVertex, theView)
		Q3SubdivisionStyle_Submit(&subdivStyle, theView)
		Q3AntiAliasStyle_Submit(&fullAntialias, theView)
	}
	
	private func submitObjects(_ theView: TQ3ViewObject) {
		submitStyles(theView)
		
		Q3Shader_Submit(mIlluminationShader, theView)

		// Submit the scene
		Q3MatrixTransform_Submit(&mCurrentMatrix, theView)
		Q3Object_Submit(mSceneGeometry!, theView)

		if drawsBounds {
			Q3BackfacingStyle_Submit(kQ3BackfacingStyleBoth, theView)
			Q3Object_Submit(mSceneBounds!, theView)
		}
	}
	
	func isMarkingPass(_ view:TQ3ViewObject) -> Bool {
		var isMarking = false
		
		var theRenderer: TQ3RendererObject? = nil
		Q3View_GetRenderer(view, &theRenderer)
		
		var passInfo = TQ3RendererPassInfo()
		if kQ3Success == Q3Object_GetProperty(theRenderer!,
											  kQ3RendererPropertyPassType,
											  TQ3Uns32(MemoryLayout.size(ofValue: passInfo)),
											  nil, &passInfo) {
			isMarking = passInfo.passType == kQ3RendererPassShadowMarking
		}
		
		Q3Object_Dispose(theRenderer!)
		
		return isMarking
	}
	
	private var isColorMaskFormat: Bool {
		var isColorMask: Bool
		switch leftRightFormat {
		case .evenOdd, .oddEven:
			isColorMask = false
			
		default:
			isColorMask = true
		}
		
		return isColorMask
	}
	
	private func setUpCamera(atOffset xOffset: Float) {
		if mViewPlaneCamera == nil {
			initViewPlaneCamera()
		}
		
		// Get data about the default view angle aspect camera
		var aspectCamData = TQ3ViewAngleAspectCameraData()
		Q3ViewAngleAspectCamera_GetData(quesa3dView.camera!, &aspectCamData)
		
		// Find the direction of the positive x axis in camera coordinates
		let viewDir = Q3FastPoint3D_Subtract(aspectCamData.cameraData.placement.pointOfInterest, aspectCamData.cameraData.placement.cameraLocation)
		var rightDir = Q3FastVector3D_Cross(viewDir, aspectCamData.cameraData.placement.upVector)
		rightDir.normalize()
		
		// Offset the placement
		let theOffset = rightDir * xOffset
		aspectCamData.cameraData.placement.pointOfInterest += theOffset
		aspectCamData.cameraData.placement.cameraLocation += theOffset
		Q3Camera_SetData(mViewPlaneCamera!, &aspectCamData.cameraData)
		
		// The dimensions of the view plane are determined by the aspect ratio, the
		// field of view, and the projection distance.
		let fovLength = projectionDistance * 2.0 * tan(aspectCamData.fov / 2.0)
		var planeWidth: Float, planeHeight: Float
		if (aspectCamData.aspectRatioXToY >= 1.0) {	// fov is vertical
			planeHeight = fovLength
			planeWidth = planeHeight * aspectCamData.aspectRatioXToY
		} else {	// fov is horizontal
			planeWidth = fovLength
			planeHeight = planeWidth / aspectCamData.aspectRatioXToY
		}
		Q3ViewPlaneCamera_SetHalfWidth( mViewPlaneCamera!, planeWidth / 2.0 )
		Q3ViewPlaneCamera_SetHalfHeight( mViewPlaneCamera!, planeHeight / 2.0 )
		
		Q3ViewPlaneCamera_SetViewPlane( mViewPlaneCamera!, projectionDistance )
		
		Q3ViewPlaneCamera_SetCenterX( mViewPlaneCamera!, -xOffset )
	}
	
	private func clearColorWithStipple() {
		// We need to clear the colors of the pixels admitted by the stipple mask,
		// but glClear does not respect glPolygonStipple...
		glMatrixMode(GLenum(GL_MODELVIEW))
		glPushMatrix()
		glLoadIdentity()	// set modelview matrix to identity
		glMatrixMode(GLenum(GL_PROJECTION))
		glPushMatrix()
		glLoadIdentity()	// set projection matrix to identity
		
		glPushAttrib(GLbitfield(GL_ENABLE_BIT | GL_DEPTH_BUFFER_BIT))
		
		glDisable(GLenum(GL_LIGHTING))
		glDisable(GLenum(GL_TEXTURE_2D))
		glDisable(GLenum(GL_BLEND))
		glDisable(GLenum(GL_CULL_FACE))
		glDisable(GLenum(GL_DEPTH_TEST))
		glDisable(GLenum(GL_STENCIL_TEST))
		glDepthMask(GLboolean(GL_FALSE))

		glColor3f(clearColor.r, clearColor.g, clearColor.b)
		
		glBegin(GLenum(GL_QUADS))
		
		glVertex2f(-1.0, -1.0 )
		glVertex2f(-1.0, 1.0 )
		glVertex2f(1.0, 1.0 )
		glVertex2f(1.0, -1.0 )
		
		glEnd()
		
		glPopAttrib()
		
		glPopMatrix()	// restore projection
		glMatrixMode(GLenum(GL_MODELVIEW))
		glPopMatrix()	// restore modelview
	}
	
	/// Set the parity of the stipple pattern according to the parity of the y
	/// coordinate of the bottom of the view, in screen coordinates.
	///
	/// If you want to keep the image up to date even if the rendered image is
	/// not continually changing, you would need to watch for notifications of
	/// the window being moved, or the view moving inside the window.
	private func setStipple() {
		let windowCoordOrigin = quesa3dView.convert(NSPoint.zero, to: nil)
		let screenCoordOrigin = quesa3dView.window!.convertPoint(toScreen: windowCoordOrigin)
		let yCoord = lround(screenCoordOrigin.y)
		let isEvenBase = (yCoord % 2) == 0
		let useEvenOnRight = leftRightFormat == .oddEven
		if (isEvenBase == useEvenOnRight) {
			ColorMask.evenRowStipple.withUnsafeBytes { body in
				let preStipple = body.bindMemory(to: GLubyte.self)
				glPolygonStipple(preStipple.baseAddress)
			}
		} else {
			ColorMask.oddRowStipple.withUnsafeBytes { body in
				let preStipple = body.bindMemory(to: GLubyte.self)
				glPolygonStipple(preStipple.baseAddress)
			}
		}
	}
	
	private func setUpLeftEye() {
		let theDC = quesa3dView.drawContext!
		
		// Do not swap buffers at the end of this render
		var swapAtEnd = kQ3False
		Q3Object_SetProperty(theDC, kQ3DrawContextPropertySwapBufferInEndPass,
							 TQ3Uns32(MemoryLayout.size(ofValue: swapAtEnd)), &swapAtEnd)
		
		setUpCamera(atOffset: -(separationDistance / 2))
	}
	
	private func setUpRightEye() {
		let theDC = quesa3dView.drawContext!
		
		// Do swap buffers at the end of this render
		var swapAtEnd = kQ3True
		Q3Object_SetProperty(theDC, kQ3DrawContextPropertySwapBufferInEndPass,
							 TQ3Uns32(MemoryLayout.size(ofValue: swapAtEnd)), &swapAtEnd)
		
		setUpCamera(atOffset: (separationDistance / 2))
	}
	
	private func beginLeftPass(_ view: TQ3ViewObject) {
		if !isMarkingPass(view) {
			glDisable(GLenum(GL_POLYGON_STIPPLE))
			ColorMask.left[leftRightFormat.rawValue - 1].set()
		}
	}
	
	private func beginRightPass(_ view: TQ3ViewObject) {
		if !isMarkingPass(view) {
			ColorMask.right[leftRightFormat.rawValue - 1].set()
			
			if !isColorMaskFormat {
				glEnable(GLenum(GL_POLYGON_STIPPLE))
				setStipple()
				
				if mIsFirstPassForEye {
					clearColorWithStipple()
				}
			}
		}
	}

	private func renderLeftEye(_ view: TQ3ViewObject) {
		if Q3View_StartRendering(view) == kQ3Success {
			// Clear the color buffer
			glColorMask(GLboolean(GL_TRUE), GLboolean(GL_TRUE), GLboolean(GL_TRUE), GLboolean(GL_TRUE))
			glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
			mIsFirstPassForEye = true;
			
			repeat {
				beginLeftPass(view)
				submitObjects(view)
				mIsFirstPassForEye = false
			} while (Q3View_EndRendering(view) == kQ3ViewStatusRetraverse);
		}
	}
	
	private func renderRightEye(_ view: TQ3ViewObject) {
		if Q3View_StartRendering(view) == kQ3Success {
			mIsFirstPassForEye = true;
			
			repeat {
				beginRightPass(view)
				submitObjects(view)
				mIsFirstPassForEye = false
			} while (Q3View_EndRendering(view) == kQ3ViewStatusRetraverse);
		}
	}

	// MARK: - Quesa3DView delegate methods

	func qd3dViewDidInit(_ inView: QD3DView) {
		rendererType = kQ3RendererTypeOpenGL
		animates = true
	}
	
	func qd3dViewRenderFrame(_ inView: QD3DView) {
		var kClearColor = clearColor
		Q3DrawContext_SetClearImageColor(quesa3dView.drawContext!, &kClearColor)

		// No automatic clearing by Quesa, we will handle it manually
		Q3DrawContext_SetClearImageMethod(quesa3dView.drawContext!, kQ3ClearMethodNone)

		let theView = inView.quesaView!
		
		Q3View_SetCamera(theView, mViewPlaneCamera!)
		
		setUpLeftEye()
		renderLeftEye(theView)
		
		setUpRightEye()
		renderRightEye(theView)
	}
}

func Q3FastPoint3D_Subtract(_ p1: TQ3Point3D, _ p2: TQ3Point3D) -> TQ3Vector3D {
	return TQ3Vector3D(x: p1.x - p2.x, y: p1.y - p2.y, z: p1.z - p2.z)
}

func Q3FastVector3D_Cross(_ v1: TQ3Vector3D, _ v2: TQ3Vector3D) -> TQ3Vector3D {
	let rx = (v1.y * v2.z) - (v1.z * v2.y)
	let ry = (v1.z * v2.x) - (v1.x * v2.z)
	let rz = (v1.x * v2.y) - (v1.y * v2.x)
	
	return TQ3Vector3D(x: rx, y: ry, z: rz)
}

struct ColorMask {
	var red: GLboolean
	var green: GLboolean
	var blue: GLboolean
	var alpha: GLboolean
	
	static let white = ColorMask(red: GLboolean(GL_TRUE), green: GLboolean(GL_TRUE), blue: GLboolean(GL_TRUE), alpha: GLboolean(GL_TRUE))
	
	static let red = ColorMask(red: GLboolean(GL_TRUE), green: GLboolean(GL_FALSE), blue: GLboolean(GL_FALSE), alpha: GLboolean(GL_TRUE))
	static let green = ColorMask(red: GLboolean(GL_FALSE), green: GLboolean(GL_TRUE), blue: GLboolean(GL_FALSE), alpha: GLboolean(GL_TRUE))
	static let blue = ColorMask(red: GLboolean(GL_FALSE), green: GLboolean(GL_FALSE), blue: GLboolean(GL_TRUE), alpha: GLboolean(GL_TRUE))

	static let cyan = ColorMask(red: GLboolean(GL_FALSE), green: GLboolean(GL_TRUE), blue: GLboolean(GL_TRUE), alpha: GLboolean(GL_TRUE))
	static let magenta = ColorMask(red: GLboolean(GL_TRUE), green: GLboolean(GL_FALSE), blue: GLboolean(GL_TRUE), alpha: GLboolean(GL_TRUE))
	static let yellow = ColorMask(red: GLboolean(GL_TRUE), green: GLboolean(GL_TRUE), blue: GLboolean(GL_FALSE), alpha: GLboolean(GL_TRUE))
	
	func set() {
		glColorMask(red, green, blue, alpha)
	}
	
	static let left: [ColorMask] = [.red,
									.green,
									.blue,
									.cyan,
									.magenta,
									.yellow,
									.white,
									.white]
	
	static let right: [ColorMask] = [.cyan,
									 .magenta,
									 .yellow,
									 .red,
									 .green,
									 .blue,
									 .white,
									 .white]
	
	static let evenRowStipple: [UInt32] =
	[
		0x00000000, 0xFFFFFFFF, 0x00000000, 0xFFFFFFFF,
		0x00000000, 0xFFFFFFFF, 0x00000000, 0xFFFFFFFF,
		0x00000000, 0xFFFFFFFF, 0x00000000, 0xFFFFFFFF,
		0x00000000, 0xFFFFFFFF, 0x00000000, 0xFFFFFFFF,
		0x00000000, 0xFFFFFFFF, 0x00000000, 0xFFFFFFFF,
		0x00000000, 0xFFFFFFFF, 0x00000000, 0xFFFFFFFF,
		0x00000000, 0xFFFFFFFF, 0x00000000, 0xFFFFFFFF,
		0x00000000, 0xFFFFFFFF, 0x00000000, 0xFFFFFFFF
	]
	
	static let oddRowStipple: [UInt32] =
	[
		0xFFFFFFFF, 0x00000000, 0xFFFFFFFF, 0x00000000,
		0xFFFFFFFF, 0x00000000, 0xFFFFFFFF, 0x00000000,
		0xFFFFFFFF, 0x00000000, 0xFFFFFFFF, 0x00000000,
		0xFFFFFFFF, 0x00000000, 0xFFFFFFFF, 0x00000000,
		0xFFFFFFFF, 0x00000000, 0xFFFFFFFF, 0x00000000,
		0xFFFFFFFF, 0x00000000, 0xFFFFFFFF, 0x00000000,
		0xFFFFFFFF, 0x00000000, 0xFFFFFFFF, 0x00000000,
		0xFFFFFFFF, 0x00000000, 0xFFFFFFFF, 0x00000000
	]

}

let clearColor = TQ3ColorARGB(a: 1, r: 0, g: 0.1, b: 0)

