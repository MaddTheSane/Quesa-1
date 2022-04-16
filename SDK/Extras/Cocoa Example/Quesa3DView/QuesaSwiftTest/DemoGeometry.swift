//
//  DemoGeometry.swift
//  SwiftStereo
//
//  Created by C.W. Betts on 3/13/19.
//

import Foundation
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
import Quesa.QuesaStorage
import Quesa.QuesaGeometry

/// Create UV values from points.
///
/// We generate UVs by mapping the X/Y coordinates onto the UV
/// plane (bit of a hack, but works OK for this app).
///
/// The smallest coordinate value is mapped to 0, and the largest
/// coordinate value is mapped to 1.0.
private func createUVsFromPoints(_ thePoints: [TQ3Point3D], _ theUVs: inout [TQ3Param2D]) {
	// Initialise ourselves
	var minX: Float = 0.0
	var maxX: Float = 1.0
	var minY: Float = 0.0
	var maxY: Float = 1.0
	
	// First find the minimum and maximum values
	for n in 0 ..< thePoints.count {
		if thePoints[n].x < minX || n == 0 {
			minX = thePoints[n].x
		}
		
		if thePoints[n].x > maxX || n == 0 {
			maxX = thePoints[n].x
		}
		
		if thePoints[n].y < minY || n == 0 {
			minY = thePoints[n].y
		}
		
		if thePoints[n].y > maxY || n == 0 {
			maxY = thePoints[n].y
		}
	}
	
	let diffX = maxX - minX
	let diffY = maxY - minY
	
	// Now generate the UVs
	theUVs.removeAll(keepingCapacity: true)
	theUVs.reserveCapacity(thePoints.count)
	for n in 0 ..< thePoints.count {
		let u = (thePoints[n].x - minX) / diffX
		let v = (thePoints[n].y - minY) / diffY
		theUVs.append(TQ3Param2D(u: u, v: v))
	}
}

/// Create a Box object.
func createGeomBox() -> TQ3GeometryObject? {
	var faceColour = [TQ3ColorRGB(r: 1.0, g: 0.0, b: 0.0),
					  TQ3ColorRGB(r: 0.0, g: 1.0, b: 0.0),
					  TQ3ColorRGB(r: 0.0, g: 0.0, b: 1.0),
					  TQ3ColorRGB(r: 1.0, g: 1.0, b: 0.0),
					  TQ3ColorRGB(r: 1.0, g: 0.0, b: 1.0),
					  TQ3ColorRGB(r: 0.0, g: 1.0, b: 1.0)]
	var faceAttributes = [TQ3AttributeSet?](repeating: nil, count: 6)
	var theMatrix = TQ3Matrix4x4()
	var boxData = TQ3BoxData()
	var theBox: TQ3GeometryObject?
	
	// Set up the data
	Q3Point3D_Set(&boxData.origin,      -0.5, -1.0,  0.5)
	Q3Vector3D_Set(&boxData.orientation, 0.0,  2.0,  0.0)
	Q3Vector3D_Set(&boxData.majorAxis,   0.0,  0.0,  1.0)
	Q3Vector3D_Set(&boxData.minorAxis,   1.0,  0.0,  0.0)
	boxData.boxAttributeSet  = nil
	
	for n in 0 ..< 6 {
		faceAttributes[n] = Q3AttributeSet_New()
		if let faceAttrib = faceAttributes[n] {
			Q3AttributeSet_Add(faceAttrib, TQ3AttributeType(kQ3AttributeTypeDiffuseColor.rawValue), &faceColour[n])
		}
	}
	defer {
		// Clean up
		for n in 0 ..< 6 {
			if let faceAttrib = faceAttributes[n] {
				Q3Object_Dispose(faceAttrib)
			}
		}
	}
	
	// Rotate it so that we can see all the faces
	Q3Matrix4x4_SetRotate_XYZ(&theMatrix,
							  Q3Math_DegreesToRadians(45.0),
							  Q3Math_DegreesToRadians(45.0),
							  Q3Math_DegreesToRadians(45.0))
	var aVec = TQ3Vector3D()
	Q3Vector3D_Transform(&boxData.orientation, &theMatrix, &aVec)
	boxData.orientation = aVec
	Q3Vector3D_Transform(&boxData.majorAxis,   &theMatrix, &aVec)
	boxData.majorAxis = aVec
	Q3Vector3D_Transform(&boxData.minorAxis,   &theMatrix, &aVec)
	boxData.minorAxis = aVec

	// Create the geometry
	theBox = faceAttributes.withUnsafeMutableBufferPointer { (attrSet) -> TQ3GeometryObject? in
		boxData.faceAttributeSet = attrSet.baseAddress!

		return Q3Box_New(&boxData)
	}
	
	return theBox
}

/// Create a Cone object.
func createGeomCone() -> TQ3GeometryObject! {
	var coneColour = TQ3ColorRGB(r: 1, g: 1, b: 1)
	var bottomColour = TQ3ColorRGB(r: 1, g: 0, b: 0)
	var faceTrans = TQ3ColorRGB(r: 0.2, g: 0.2, b: 0.2)
	var coneData = TQ3ConeData()
	
	// Set up the data
	coneData.origin = TQ3Point3D(x: 0, y: -1, z: 0)
	coneData.orientation = TQ3Vector3D(x: 0, y: 2, z: 0)
	coneData.majorRadius = TQ3Vector3D(x: 0, y: 0, z: 1)
	coneData.minorRadius = TQ3Vector3D(x: 1, y: 0, z: 0)
	coneData.uMin = 0.0
	coneData.uMax = 1.0
	coneData.vMin = 0.0
	coneData.vMax = 1.0
	coneData.caps = kQ3EndCapMaskBottom.rawValue

	coneData.coneAttributeSet = Q3AttributeSet_New()
	if let attribSet = coneData.coneAttributeSet {
		Q3AttributeSet_Add(attribSet, kQ3AttributeTypeDiffuseColor.rawValue, &coneColour)
	}
	
	coneData.faceAttributeSet = Q3AttributeSet_New()
	if let attribSet = coneData.faceAttributeSet {
		Q3AttributeSet_Add(attribSet, kQ3AttributeTypeTransparencyColor.rawValue, &faceTrans)
	}

	coneData.bottomAttributeSet = Q3AttributeSet_New()
	if let attribSet = coneData.bottomAttributeSet {
		Q3AttributeSet_Add(attribSet, kQ3AttributeTypeDiffuseColor.rawValue, &bottomColour)
	}

	defer {
		// Clean up
		if let attribSet = coneData.coneAttributeSet {
			Q3Object_Dispose(attribSet)
		}
			
		 if let attribSet = coneData.interiorAttributeSet {
			Q3Object_Dispose(attribSet)
		}
			
		if let attribSet = coneData.faceAttributeSet {
			Q3Object_Dispose(attribSet)
		}
			
		if let attribSet = coneData.bottomAttributeSet {
			Q3Object_Dispose(attribSet)
		}
	}
	
	// Create the geometry
	return Q3Cone_New(&coneData)
}

/// Create a Cylinder object.
func createGeomCylinder() -> TQ3GeometryObject! {
	var topColour =		TQ3ColorRGB(r: 0.0, g: 0.0, b: 1.0)
	var bottomColour =	TQ3ColorRGB(r: 0.0, g: 1.0, b: 0.0)
	var faceColour =	TQ3ColorRGB(r: 1.0, g: 0.0, b: 0.0)
	var specColour =	TQ3ColorRGB(r: 1.0, g: 1.0, b: 0.5)
	
	var cylinderData = TQ3CylinderData()
	
	// Set up the data
	cylinderData.origin = TQ3Point3D(x: 0.0, y: -1.0, z: 0.0)
	cylinderData.orientation = TQ3Vector3D(x: 0, y: 2, z: 0)
	cylinderData.majorRadius = TQ3Vector3D(x: 0, y: 0, z: 1)
	cylinderData.minorRadius = TQ3Vector3D(x: 1, y: 0, z: 0)
	cylinderData.uMin = 0.0
	cylinderData.uMax = 1.0
	cylinderData.vMin = 0.0
	cylinderData.vMax = 1.0
	cylinderData.caps = kQ3EndCapMaskBottom.rawValue | kQ3EndCapMaskTop.rawValue

	cylinderData.cylinderAttributeSet = Q3AttributeSet_New()
	if let attrSet = cylinderData.cylinderAttributeSet {
		Q3AttributeSet_Add(attrSet, kQ3AttributeTypeSpecularColor.rawValue, &specColour)
	}

	cylinderData.faceAttributeSet = Q3AttributeSet_New()
	if let attrSet = cylinderData.faceAttributeSet {
		Q3AttributeSet_Add(attrSet, kQ3AttributeTypeDiffuseColor.rawValue, &faceColour)
	}

	cylinderData.topAttributeSet = Q3AttributeSet_New()
	if let attrSet = cylinderData.topAttributeSet {
		Q3AttributeSet_Add(attrSet, kQ3AttributeTypeDiffuseColor.rawValue, &topColour)
	}

	cylinderData.bottomAttributeSet = Q3AttributeSet_New()
	if let attrSet = cylinderData.bottomAttributeSet {
		Q3AttributeSet_Add(attrSet, kQ3AttributeTypeDiffuseColor.rawValue, &bottomColour)
	}

	defer {
		if let attrSet = cylinderData.cylinderAttributeSet {
			Q3Object_Dispose(attrSet)
		}

		if let attrSet = cylinderData.faceAttributeSet {
			Q3Object_Dispose(attrSet)
		}

		if let attrSet = cylinderData.topAttributeSet {
			Q3Object_Dispose(attrSet)
		}

		if let attrSet = cylinderData.bottomAttributeSet {
			Q3Object_Dispose(attrSet)
		}
	}
	
	return Q3Cylinder_New(&cylinderData)
}

/// Create a Disk object.
func createGeomDisk() -> TQ3GeometryObject! {
	var diskColour = TQ3ColorRGB(r: 1, g: 1, b: 0)
	var diskData = TQ3DiskData()
	
	// Set up the data
	diskData.origin = TQ3Point3D(x: 0, y: 0, z: 0)
	diskData.majorRadius = TQ3Vector3D(x: 0, y: 0, z: 1)
	diskData.minorRadius = TQ3Vector3D(x: 1, y: 0, z: 0)
	diskData.uMin = 0.0
	diskData.uMax = 1.0
	diskData.vMin = 0.0
	diskData.vMax = 1.0

	diskData.diskAttributeSet = Q3AttributeSet_New()
	if let attrSet = diskData.diskAttributeSet {
		Q3AttributeSet_Add(attrSet, kQ3AttributeTypeDiffuseColor.rawValue, &diskColour)
	}
	
	defer {
		if let attrSet = diskData.diskAttributeSet {
			Q3Object_Dispose(attrSet)
		}
	}
	
	return Q3Disk_New(&diskData)
}

/// Create an Ellipse object.
func createGeomEllipse() -> TQ3GeometryObject! {
	var ellipseColour = TQ3ColorRGB(r: 1, g: 0, b: 0)
	var ellipseData = TQ3EllipseData()
	
	
	// Set up the data
	Q3Point3D_Set(&ellipseData.origin,       0.0,  0.0,  0.0)
	Q3Vector3D_Set(&ellipseData.majorRadius, 0.0,  0.0,  1.0)
	Q3Vector3D_Set(&ellipseData.minorRadius, 1.0,  0.0,  0.0)
	ellipseData.uMin = 0.0
	ellipseData.uMax = 0.75

	ellipseData.ellipseAttributeSet = Q3AttributeSet_New()
	if let attrSet = ellipseData.ellipseAttributeSet {
		Q3AttributeSet_Add(attrSet, kQ3AttributeTypeDiffuseColor.rawValue, &ellipseColour)
	}
	
	defer {
		if let attrSet = ellipseData.ellipseAttributeSet {
			Q3Object_Dispose(attrSet)
		}
	}

	// Create the geometry
	return Q3Ellipse_New(&ellipseData)
}

/// Create an Ellipsoid object.
func createGeomEllipsoid() -> TQ3GeometryObject! {
	var ellipsoidColour = TQ3ColorRGB(r: 1, g: 0, b: 0)
	var ellipsoidData = TQ3EllipsoidData(origin: TQ3Point3D(x: 0, y: 0, z: 0),
										 orientation: TQ3Vector3D(x: 0, y: 0, z: 0.5),
										 majorRadius: TQ3Vector3D(x: 1, y: 0, z: 0),
										 minorRadius: TQ3Vector3D(x: 0, y: 1.5, z: 0),
										 uMin: 0, uMax: 1, vMin: 0, vMax: 1,
										 caps: kQ3EndCapNone.rawValue,
										 interiorAttributeSet: nil,
										 ellipsoidAttributeSet: nil)
	
	// Set up the data
	ellipsoidData.ellipsoidAttributeSet = Q3AttributeSet_New()
	if let ellipsDat = ellipsoidData.ellipsoidAttributeSet {
		Q3AttributeSet_Add(ellipsDat, kQ3AttributeTypeDiffuseColor.rawValue, &ellipsoidColour)
	}

	defer {
		// Clean up
		if let ellipsDat = ellipsoidData.ellipsoidAttributeSet {
			Q3Object_Dispose(ellipsDat)
		}
	}
	
	// Create the geometry
	return Q3Ellipsoid_New(&ellipsoidData)
}

/// Create an General Polygon object.
func createGeomGeneralPolygon() -> TQ3GeometryObject! {
	let vertPoints = [TQ3Point3D(x: -0.5, y: -1, z: 0),
					  TQ3Point3D(x: -1.0, y:  1, z: 0),
					  TQ3Point3D(x: -0.2, y:  0, z: 0),
					  TQ3Point3D(x:  0.2, y:  0, z: 0),
					  TQ3Point3D(x:  1.0, y:  1, z: 0),
					  TQ3Point3D(x:  0.5, y: -1, z: 0)]
	var vertColours = [TQ3ColorRGB(r: 1, g: 0, b: 0),
					   TQ3ColorRGB(r: 0, g: 1, b: 0),
					   TQ3ColorRGB(r: 0, g: 0, b: 1),
					   TQ3ColorRGB(r: 1, g: 0, b: 1),
					   TQ3ColorRGB(r: 1, g: 1, b: 0),
					   TQ3ColorRGB(r: 0, g: 1, b: 1)]
	var vertUVs = [TQ3Param2D]()
	var theVertices = [TQ3Vertex3D](repeating: TQ3Vertex3D(), count: 6)
	
	createUVsFromPoints(vertPoints, &vertUVs)
	
	return theVertices.withUnsafeMutableBufferPointer { bufPtr -> TQ3GeometryObject? in
		var theContours = [TQ3GeneralPolygonContourData(numVertices: TQ3Uns32(bufPtr.count), vertices: bufPtr.baseAddress!)]
		
		var generalPolygonData = TQ3GeneralPolygonData(numContours: 1, contours: &theContours, shapeHint: kQ3GeneralPolygonShapeHintComplex, generalPolygonAttributeSet: nil)
		
		for n in 0 ..< 6 {
			theContours[0].vertices[n].point        = vertPoints[n]
			theContours[0].vertices[n].attributeSet = Q3AttributeSet_New()
			if let attrSet = theContours[0].vertices[n].attributeSet {
				Q3AttributeSet_Add(attrSet,
								   kQ3AttributeTypeDiffuseColor.rawValue,
								   &vertColours[n])

				Q3AttributeSet_Add(attrSet,
								   kQ3AttributeTypeSurfaceUV.rawValue,
								   &vertUVs[n])
			}
		}
		
		defer {
			// Clean up
			for n in 0 ..< 6 {
				if let attrSet = theContours[0].vertices[n].attributeSet {
					Q3Object_Dispose(attrSet)
				}
			}
		}
		
		// Create the geometry
		return Q3GeneralPolygon_New(&generalPolygonData)
	}
}

/// Create a Line object.
func createGeomLine() -> TQ3GeometryObject! {
	let vertPoints = [TQ3Point3D(x: -1, y: -1, z: -1), TQ3Point3D(x: 1, y: 1, z: 1)]
	var vertColours = [TQ3ColorRGB(r: 1, g: 0, b: 0), TQ3ColorRGB(r: 0, g: 0, b: 1)]
	
	var lineData = TQ3LineData()
	
	//Unroll loop!
	do {
		lineData.vertices.0.point = vertPoints[0]
		lineData.vertices.1.point = vertPoints[1]
		
		lineData.vertices.0.attributeSet = Q3AttributeSet_New()
		if let attrib = lineData.vertices.0.attributeSet {
			Q3AttributeSet_Add(attrib,
							   kQ3AttributeTypeDiffuseColor.rawValue,
							   &vertColours[0])
		}
		
		lineData.vertices.1.attributeSet = Q3AttributeSet_New()
		if let attrib = lineData.vertices.1.attributeSet {
			Q3AttributeSet_Add(attrib,
							   kQ3AttributeTypeDiffuseColor.rawValue,
							   &vertColours[1])
		}
	}
	
	defer {
		// Clean up
		if let attrib = lineData.vertices.0.attributeSet {
			Q3Object_Dispose(attrib)
		}
		
		if let attrib = lineData.vertices.1.attributeSet {
			Q3Object_Dispose(attrib)
		}
	}
	
	// Create the geometry
	return Q3Line_New(&lineData)
}

/// Create a Marker object.
func createGeomMarker() -> TQ3GeometryObject! {
	var imageData = Data([UInt8](arrayLiteral: 0x7E, 0x3C, 0x3C, 0x66, 0x7E, 0x7C, 0x18,
								 0x60, 0x60, 0x66, 0x66, 0x60, 0x66, 0x18,
								 0x7C, 0x3C, 0x60, 0x7E, 0x7C, 0x66, 0x18,
								 0x60, 0x06, 0x60, 0x66, 0x60, 0x7C, 0x18,
								 0x60, 0x06, 0x66, 0x66, 0x60, 0x66, 0x00,
								 0x7E, 0x3C, 0x3C, 0x66, 0x7E, 0x66, 0x18))
	var theColour = TQ3ColorRGB(r: 0, g: 1, b: 1)
	return imageData.withUnsafeMutableBytes { usbp -> TQ3GeometryObject? in
		let buf = usbp.bindMemory(to: TQ3Uns8.self)
		var markerData = TQ3MarkerData(location: TQ3Point3D(x: -1, y: 0.5, z: 0.5), xOffset: -20, yOffset: 20, bitmap: TQ3Bitmap(image: nil, width: 56, height: 6, rowBytes: 7, bitOrder: kQ3EndianBig), markerAttributeSet: nil)
		markerData.bitmap.image       = buf.baseAddress
		markerData.markerAttributeSet = Q3AttributeSet_New()
		if let markerAttrib = markerData.markerAttributeSet {
			Q3AttributeSet_Add(markerAttrib,
							   kQ3AttributeTypeDiffuseColor.rawValue,
							   &theColour)
		}
		
		defer {
			// Clean up
			if let markerAttrib = markerData.markerAttributeSet {
				Q3Object_Dispose(markerAttrib)
			}
		}
		
		// Create the geometry
		return Q3Marker_New(&markerData)
	}
}

/// Create a Mesh object.
func createGeomMesh() -> TQ3GeometryObject! {
	var theVertices = [TQ3Vertex3D(point: TQ3Point3D(x: -1.5, y: 1.5, z: 0), attributeSet: nil),
					   TQ3Vertex3D(point: TQ3Point3D(x: -1.5, y: -1.5, z: 0), attributeSet: nil),
					   TQ3Vertex3D(point: TQ3Point3D(x: 0, y: 1.5, z: 0.9), attributeSet: nil),
					   TQ3Vertex3D(point: TQ3Point3D(x: 1.5, y: -1.5, z: 0), attributeSet: nil),
					   TQ3Vertex3D(point: TQ3Point3D(x: 1.5, y: 1.5, z: 0), attributeSet: nil),
					   TQ3Vertex3D(point: TQ3Point3D(x: 0, y: 1.5, z: 0.9), attributeSet: nil),
					   TQ3Vertex3D(point: TQ3Point3D(x: -1.2, y: 0.6, z: 0), attributeSet: nil),
					   TQ3Vertex3D(point: TQ3Point3D(x: 0, y: 0, z: 0), attributeSet: nil),
					   TQ3Vertex3D(point: TQ3Point3D(x: -1.2, y: -0.6, z: 0), attributeSet: nil)]
	var vertUVs = [TQ3Param2D(u: 0.0, v: 1.0), TQ3Param2D(u: 0.0, v: 0.0),
				   TQ3Param2D(u: 0.5, v: 0.0), TQ3Param2D(u: 1.0, v: 0.0),
				   TQ3Param2D(u: 1.0, v: 1.0), TQ3Param2D(u: 0.5, v: 1.0),
				   TQ3Param2D(u: 0.1, v: 0.8), TQ3Param2D(u: 0.5, v: 0.5),
				   TQ3Param2D(u: 0.1, v: 0.4)]
	var theColour = TQ3ColorRGB(r: 0.3, g: 0.9, b: 0.5)
	var meshVertices = [TQ3MeshVertex]()

	// Create the mesh
	guard let theMesh = Q3Mesh_New() else {
		return nil
	}
	Q3Mesh_DelayUpdates(theMesh)

	// Create the vertices
	for n in 0 ..< 9 {
		meshVertices.append(Q3Mesh_VertexNew(theMesh, &theVertices[n]))
		
		if let theAttributes = Q3AttributeSet_New() {
			Q3AttributeSet_Add(theAttributes, kQ3AttributeTypeSurfaceUV.rawValue, &vertUVs[n])
			Q3Mesh_SetVertexAttributeSet(theMesh, meshVertices[n], theAttributes)
			Q3Object_Dispose(theAttributes)
		}
	}
	
	// Add the face
	let theAttributes = Q3AttributeSet_New()
	if let theAttributes = theAttributes {
		Q3AttributeSet_Add(theAttributes, kQ3AttributeTypeDiffuseColor.rawValue, &theColour)
		
		let theFace = Q3Mesh_FaceNew(theMesh, 6, meshVertices, theAttributes)
//		if let theFace = theFace {
			Q3Mesh_FaceToContour(theMesh, theFace, Q3Mesh_FaceNew(theMesh, 3, &meshVertices[6], nil))
//		}
		
		// Resume updates and clean up
		Q3Mesh_ResumeUpdates(theMesh)
		
		Q3Object_Dispose(theAttributes)
	}

	return theMesh
}

/// Create a NURB curve object.
func createGeomNURBCurve() -> TQ3GeometryObject! {
	var theColour = TQ3ColorRGB(r: 0.8, g: 0.2, b: 0.6)
	var thePoints = [TQ3RationalPoint4D(x: -2.0, y:  0.0, z:  0.0, w: 1),
					 TQ3RationalPoint4D(x: -1.0, y:  1.0, z:  0.0, w: 1),
					 TQ3RationalPoint4D(x: -0.5, y:  0.0, z:  0.0, w: 1),
					 TQ3RationalPoint4D(x:  0.0, y:  1.0, z:  0.0, w: 1),
					 TQ3RationalPoint4D(x:  0.5, y:  0.0, z:  0.0, w: 1),
					 TQ3RationalPoint4D(x:  1.0, y:  1.0, z:  0.0, w: 1),
					 TQ3RationalPoint4D(x:  2.0, y:  0.0, z:  0.0, w: 1)]
	var theKnots: [Float] = [0.0,  0.0, 0.0,  0.0,
							 0.25, 0.5, 0.75, 1.0,
							 1.0,  1.0, 1.0]
	
	var curveData = TQ3NURBCurveData(order: 4, numPoints: 7, controlPoints: &thePoints, knots: &theKnots, curveAttributeSet: Q3AttributeSet_New())
	
	if let attrSet = curveData.curveAttributeSet {
		Q3AttributeSet_Add(attrSet, kQ3AttributeTypeDiffuseColor.rawValue, &theColour)
	}

	defer {
		if let attrSet = curveData.curveAttributeSet {
			Q3Object_Dispose(attrSet)
		}
	}
	
	return Q3NURBCurve_New(&curveData)
}

/// Create a NURB patch object.
func createGeomNURBPatch() -> TQ3GeometryObject! {
	var thePoints = [TQ3RationalPoint4D(x: -1.5, y: -1.0, z:  0.0, w: 1),
					 TQ3RationalPoint4D(x: -0.5, y: -1.0, z:  2.0, w: 1),
					 TQ3RationalPoint4D(x:  0.5, y: -1.0, z:  0.0, w: 1),
					 TQ3RationalPoint4D(x:  1.5, y: -1.0, z:  0.0, w: 1),
					 
					 TQ3RationalPoint4D(x: -1.5, y: -0.0, z:  0.0, w: 1),
					 TQ3RationalPoint4D(x: -0.5, y: -0.0, z:  2.0, w: 1),
					 TQ3RationalPoint4D(x:  0.5, y: -0.0, z: -2.0, w: 1),
					 TQ3RationalPoint4D(x:  1.5, y: -0.0, z: -2.0, w: 1),
					 
					 TQ3RationalPoint4D(x: -1.5, y:  1.0, z:  0.0, w: 1),
					 TQ3RationalPoint4D(x: -0.5, y:  1.0, z:  0.0, w: 1),
					 TQ3RationalPoint4D(x:  0.5, y:  1.0, z:  0.0, w: 1),
					 TQ3RationalPoint4D(x:  1.5, y:  1.0, z:  0.0, w: 1)]
	
	var vKnots: [Float] = [0.0, 0.0, 0.0, 1.0, 1.0, 1.0]
	var uKnots: [Float] = [0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0]
	
	var trimPointsZero = [TQ3RationalPoint3D(x: 0.1, y: 0.1, w: 1.0),
						  TQ3RationalPoint3D(x: 0.9, y: 0.1, w: 1.0),
						  TQ3RationalPoint3D(x: 0.4, y: 0.4, w: 1.0),
						  TQ3RationalPoint3D(x: 0.1, y: 0.4, w: 1.0),
						  TQ3RationalPoint3D(x: 0.1, y: 0.1, w: 1.0)]
	var trimPointsOne = [TQ3RationalPoint3D(x: 0.3, y: 0.6, w: 1.0),
						 TQ3RationalPoint3D(x: 0.9, y: 0.6, w: 1.0),
						 TQ3RationalPoint3D(x: 0.4, y: 0.9, w: 1.0),
						 TQ3RationalPoint3D(x: 0.2, y: 0.9, w: 1.0),
						 TQ3RationalPoint3D(x: 0.3, y: 0.6, w: 1.0)]
	
	var trimKnotsZero: [Float] = [0.0, 0.0, 0.0, 0.0, 0.5,
								  1.0, 1.0, 1.0, 1.0]
	var trimKnotsOne: [Float] = [0.0, 0.0, 0.0, 0.0, 0.5,
								 1.0, 1.0, 1.0, 1.0]
	
	var theColour = TQ3ColorRGB(r: 0.9, g: 0.2, b: 0.9)
	var trimCurveZero = TQ3NURBPatchTrimCurveData(order: 4, numPoints: 5, controlPoints: &trimPointsZero, knots: &trimKnotsZero)
	var trimCurveOne = TQ3NURBPatchTrimCurveData(order: 4, numPoints: 5, controlPoints: &trimPointsOne, knots: &trimKnotsOne)
	
	var trimLoops = [TQ3NURBPatchTrimLoopData(numTrimCurves: 1, trimCurves: &trimCurveZero), TQ3NURBPatchTrimLoopData(numTrimCurves: 1, trimCurves: &trimCurveOne)]
	
	var patchData = TQ3NURBPatchData(uOrder: 4, vOrder: 3, numRows: 3, numColumns: 4, controlPoints: &thePoints, uKnots: &uKnots, vKnots: &vKnots, numTrimLoops: 0, trimLoops: nil, patchAttributeSet: nil)
	
	patchData.patchAttributeSet = Q3AttributeSet_New()
	if let attrSet = patchData.patchAttributeSet {
		Q3AttributeSet_Add(attrSet, kQ3AttributeTypeDiffuseColor.rawValue, &theColour)
	}
	
	defer {
		if let attrSet = patchData.patchAttributeSet {
			Q3Object_Dispose(attrSet)
		}
	}
	
	return Q3NURBPatch_New(&patchData)
}

/// Create a Pixmap marker object.
func createGeomPixmapMarker() -> TQ3GeometryObject! {
	var theImage = [TQ3Uns32](repeating: 0, count: 64 * 64)
	for y in 0 ..< 64 {
		let g = TQ3Uns32(y * 4)
		for x in 0 ..< 64 {
			let r = TQ3Uns32(x * 4)
			theImage[y * 64 + x] = (r << 16) | (g << 8)
		}
	}
	
	let bufStore = theImage.withUnsafeBufferPointer { urbp in
		urbp.withMemoryRebound(to: UInt8.self) { buf2 in
			Q3MemoryStorage_New(buf2.baseAddress, TQ3Uns32(buf2.count))
		}
	}
	var pixmapMarkerData = TQ3PixmapMarkerData(position: TQ3Point3D(x: -1, y: 0.5, z: 0.5), xOffset: -50, yOffset: -50, pixmap: TQ3StoragePixmap(image: bufStore, width: 64, height: 64, rowBytes: 0, pixelSize: 32, pixelType: kQ3PixelTypeRGB32, bitOrder: kQ3EndianBig, byteOrder: kQ3EndianBig), pixmapMarkerAttributeSet: nil)
	pixmapMarkerData.pixmap.rowBytes = pixmapMarkerData.pixmap.width * UInt32(MemoryLayout<TQ3Uns32>.stride)

	// Always true!
//	if pixmapMarkerData.pixmap.image == nil {
//		return nil
//	}
	
	defer {
		Q3Object_Dispose(pixmapMarkerData.pixmap.image)
	}
	
	return Q3PixmapMarker_New(&pixmapMarkerData)
}

/// Create a Point object.
func createGeomPoint() -> TQ3GeometryObject! {
	var pointData =  TQ3PointData(point: TQ3Point3D(x: -1, y: -1, z: -1), pointAttributeSet: nil)
	
	// Create the geometry
	let thePoint = Q3Point_New(&pointData)
	
	return thePoint
}

/// Create a Polygon object.
func createGeomPolygon() -> TQ3GeometryObject! {
	var vertPoints = [TQ3Point3D(x: -0.5, y: -1.0, z: 0.0),
					  TQ3Point3D(x: -1.0, y:  0.0, z: 0.0),
					  TQ3Point3D(x:  0.0, y:  1.5, z: 0.0),
					  TQ3Point3D(x:  1.0, y:  0.0, z: 0.0),
					  TQ3Point3D(x:  0.5, y: -1.0, z: 0.0)]
	var vertColours = [TQ3ColorRGB(r: 1.0, g: 0.0, b: 0.0),
					   TQ3ColorRGB(r: 0.0, g: 1.0, b: 0.0),
					   TQ3ColorRGB(r: 0.0, g: 0.0, b: 1.0),
					   TQ3ColorRGB(r: 1.0, g: 1.0, b: 0.0),
					   TQ3ColorRGB(r: 0.0, g: 1.0, b: 1.0)]
	var vertUVs = [TQ3Param2D]()
	var theVertices = [TQ3Vertex3D](repeating: TQ3Vertex3D(), count: vertPoints.count)
	createUVsFromPoints(vertPoints, &vertUVs)
	
	
	var polygonData = TQ3PolygonData(numVertices: TQ3Uns32(theVertices.count), vertices: &theVertices, polygonAttributeSet: nil)

	for (n, vert) in vertPoints.enumerated() {
		polygonData.vertices[n].point        = vert
		polygonData.vertices[n].attributeSet = Q3AttributeSet_New()
		
		if let attrSet = polygonData.vertices[n].attributeSet {
			Q3AttributeSet_Add(attrSet,
							   kQ3AttributeTypeDiffuseColor.rawValue,
							   &vertColours[n])

			Q3AttributeSet_Add(attrSet,
							   kQ3AttributeTypeSurfaceUV.rawValue,
							   &vertUVs[n])
		}
	}
	
	defer {
		for n in 0 ..< vertPoints.count {
			if let attrSet = polygonData.vertices[n].attributeSet {
				Q3Object_Dispose(attrSet)
			}
		}
	}
	
	return Q3Polygon_New(&polygonData)
}

/// Create a Polyhedron object.
func createGeomPolyhedron() -> TQ3GeometryObject! {
	var theTriangles = [TQ3PolyhedronTriangleData(vertexIndices: (0, 2, 3), edgeFlag: kQ3PolyhedronEdge01.rawValue, triangleAttributeSet: nil),
						TQ3PolyhedronTriangleData(vertexIndices: (0, 3, 4), edgeFlag: kQ3PolyhedronEdge12.rawValue, triangleAttributeSet: nil),
						TQ3PolyhedronTriangleData(vertexIndices: (0, 4, 1), edgeFlag: kQ3PolyhedronEdge20.rawValue, triangleAttributeSet: nil),
						TQ3PolyhedronTriangleData(vertexIndices: (1, 4, 5), edgeFlag: kQ3PolyhedronEdge20.rawValue, triangleAttributeSet: nil),
						TQ3PolyhedronTriangleData(vertexIndices: (2, 6, 7), edgeFlag: kQ3PolyhedronEdge01.rawValue, triangleAttributeSet: nil),
						TQ3PolyhedronTriangleData(vertexIndices: (2, 7, 3), edgeFlag: kQ3PolyhedronEdge12.rawValue, triangleAttributeSet: nil),
						TQ3PolyhedronTriangleData(vertexIndices: (3, 7, 8), edgeFlag: kQ3PolyhedronEdgeNone.rawValue, triangleAttributeSet: nil),
						TQ3PolyhedronTriangleData(vertexIndices: (3, 8, 4), edgeFlag: kQ3PolyhedronEdge12.rawValue, triangleAttributeSet: nil),
						TQ3PolyhedronTriangleData(vertexIndices: (4, 8, 9), edgeFlag: kQ3PolyhedronEdgeNone.rawValue, triangleAttributeSet: nil),
						TQ3PolyhedronTriangleData(vertexIndices: (4, 9, 5), edgeFlag: kQ3PolyhedronEdge12.rawValue, triangleAttributeSet: nil),
						TQ3PolyhedronTriangleData(vertexIndices: (6, 10, 7), edgeFlag: kQ3PolyhedronEdge01.rawValue, triangleAttributeSet: nil),
						TQ3PolyhedronTriangleData(vertexIndices: (7, 10, 11), edgeFlag: kQ3PolyhedronEdge12.rawValue, triangleAttributeSet: nil),
						TQ3PolyhedronTriangleData(vertexIndices: (7, 11, 8), edgeFlag: kQ3PolyhedronEdge20.rawValue, triangleAttributeSet: nil),
						TQ3PolyhedronTriangleData(vertexIndices: (8, 11, 9), edgeFlag: kQ3PolyhedronEdge12.rawValue, triangleAttributeSet: nil)]
	let vertPoints = [TQ3Point3D(x: -0.5, y: -1.0, z: 0.0),
					  TQ3Point3D(x:  0.5, y: -1.0, z: 0.0),
					  TQ3Point3D(x: -1.0, y: -0.5, z: 0.0),
					  TQ3Point3D(x: -0.5, y: -0.5, z: 0.0),
					  TQ3Point3D(x:  0.5, y: -0.5, z: 0.0),
					  TQ3Point3D(x:  1.0, y: -0.5, z: 0.0),
					  TQ3Point3D(x: -1.0, y:  0.5, z: 0.0),
					  TQ3Point3D(x: -0.5, y:  0.5, z: 0.0),
					  TQ3Point3D(x:  0.5, y:  0.5, z: 0.0),
					  TQ3Point3D(x:  1.0, y:  0.5, z: 0.0),
					  TQ3Point3D(x: -0.5, y:  1.0, z: 0.0),
					  TQ3Point3D(x:  0.5, y:  1.0, z: 0.0)]
	var vertColours = [TQ3ColorRGB(r: 0.0, g: 0.0, b: 1.0),
					   TQ3ColorRGB(r: 1.0, g: 0.0, b: 0.0),
					   TQ3ColorRGB(r: 1.0, g: 0.0, b: 0.0),
					   TQ3ColorRGB(r: 1.0, g: 1.0, b: 1.0),
					   TQ3ColorRGB(r: 1.0, g: 1.0, b: 1.0),
					   TQ3ColorRGB(r: 0.0, g: 0.0, b: 1.0),
					   TQ3ColorRGB(r: 0.0, g: 0.0, b: 1.0),
					   TQ3ColorRGB(r: 1.0, g: 1.0, b: 1.0),
					   TQ3ColorRGB(r: 1.0, g: 1.0, b: 1.0),
					   TQ3ColorRGB(r: 1.0, g: 0.0, b: 0.0),
					   TQ3ColorRGB(r: 1.0, g: 0.0, b: 0.0),
					   TQ3ColorRGB(r: 0.0, g: 0.0, b: 1.0)]
	var theVertices = [TQ3Vertex3D](repeating: TQ3Vertex3D(), count: vertPoints.count)
	
	var polyhedronData = TQ3PolyhedronData(numVertices: 12, vertices: &theVertices, numEdges: 0, edges: nil, numTriangles: TQ3Uns32(theTriangles.count), triangles: &theTriangles, polyhedronAttributeSet: nil)
	var vertUVs = [TQ3Param2D]()
	
	createUVsFromPoints(vertPoints, &vertUVs)

	for (n, vert) in vertPoints.enumerated() {
		polyhedronData.vertices![n].point        = vert
		polyhedronData.vertices![n].attributeSet = Q3AttributeSet_New()
		
		if let attrSet = polyhedronData.vertices?[n].attributeSet {
			Q3AttributeSet_Add(attrSet,
							   kQ3AttributeTypeDiffuseColor.rawValue,
							   &vertColours[n])
			
			Q3AttributeSet_Add(attrSet,
							   kQ3AttributeTypeSurfaceUV.rawValue,
							   &vertUVs[n])
		}
	}
	
	defer {
		for n in 0 ..< vertPoints.count {
			if let attrSet = polyhedronData.vertices?[n].attributeSet {
				Q3Object_Dispose(attrSet)
			}
		}
	}
	
	return Q3Polyhedron_New(&polyhedronData)
}

/// Create a PolyLine object.
func createGeomPolyLine() -> TQ3GeometryObject! {
	let vertPoints = [TQ3Point3D(x: -1.0, y: -1.0, z: -1.0),
					  TQ3Point3D(x: -1.0, y: -0.5, z:  1.0),
					  TQ3Point3D(x:  1.0, y:  0.0, z:  1.0),
					  TQ3Point3D(x:  1.0, y:  0.5, z: -1.0),
					  TQ3Point3D(x:  0.0, y:  1.0, z:  0.0)]
	var vertColours = [TQ3ColorRGB(r: 1.0, g: 0.0, b: 0.0),
					   TQ3ColorRGB(r: 0.0, g: 1.0, b: 0.0),
					   TQ3ColorRGB(r: 0.0, g: 0.0, b: 1.0),
					   TQ3ColorRGB(r: 1.0, g: 1.0, b: 0.0),
					   TQ3ColorRGB(r: 0.0, g: 1.0, b: 1.0)]
	var theVertices = [TQ3Vertex3D](repeating: TQ3Vertex3D(), count: vertPoints.count)
	var polyLineData = TQ3PolyLineData(numVertices: TQ3Uns32(theVertices.count), vertices: &theVertices, segmentAttributeSet: nil, polyLineAttributeSet: nil)
	
	for (n, vert) in vertPoints.enumerated() {
		polyLineData.vertices[n].point        = vert
		polyLineData.vertices[n].attributeSet = Q3AttributeSet_New()

		if let attrSet = polyLineData.vertices[n].attributeSet {
			Q3AttributeSet_Add(attrSet,
							   kQ3AttributeTypeDiffuseColor.rawValue,
							   &vertColours[n])
		}
	}
	
	defer {
		for n in 0 ..< 5 {
			if let attrSet = polyLineData.vertices[n].attributeSet {
				Q3Object_Dispose(attrSet)
			}
		}
	}
	
	return Q3PolyLine_New(&polyLineData)
}

/// Create the Quesa logo geometry.
func createGeomQuesa() -> TQ3GroupObject! {
	var	transformData = TQ3RotateTransformData(axis: kQ3AxisZ, radians: Q3Math_DegreesToRadians(45.0))
	var colourTorus = TQ3ColorRGB(r: 0.19, g: 0.21, b: 0.60)
	var colourSphere = TQ3ColorRGB(r: 0.66, g: 0.01, b: 0.01)
	var colourCone = TQ3ColorRGB(r: 0.14, g: 0.42, b: 0.18)
	var torusData = TQ3TorusData(origin: TQ3Point3D(x: 0, y: 0.3, z: 0),
								 orientation: TQ3Vector3D(x: 0, y: 0, z: 0.3),
								 majorRadius: TQ3Vector3D(x: 1, y: 0, z: 0),
								 minorRadius: TQ3Vector3D(x: 0, y: 1, z: 0),
								 ratio: 1,
								 uMin: 0, uMax: 1, vMin: 0, vMax: 1,
								 caps: kQ3EndCapNone.rawValue, interiorAttributeSet: nil, torusAttributeSet: nil)
	
	var sphereData = TQ3EllipsoidData(origin: TQ3Point3D(x: 0, y: 0.3, z: 0),
									  orientation: TQ3Vector3D(x: 0, y: 0, z: 0.3),
									  majorRadius: TQ3Vector3D(x: 0.3, y: 0, z: 0),
									  minorRadius: TQ3Vector3D(x: 0, y: 0.3, z: 0),
									  uMin: 0, uMax: 1, vMin: 0, vMax: 1,
									  caps: kQ3EndCapNone.rawValue, interiorAttributeSet: nil, ellipsoidAttributeSet: nil)
	var coneData = TQ3ConeData(origin: TQ3Point3D(x: 0, y: -1.4, z: 0),
							   orientation: TQ3Vector3D(x: 0, y: 1.5, z: 0),
							   majorRadius: TQ3Vector3D(x: 0, y: 0, z: 0.3),
							   minorRadius: TQ3Vector3D(x: 0.3, y: 0, z: 0),
							   uMin: 0, uMax: 1, vMin: 0, vMax: 1,
							   caps: kQ3EndCapMaskBottom.rawValue, interiorAttributeSet: nil, faceAttributeSet: nil, bottomAttributeSet: nil, coneAttributeSet: nil)
	
	// Create the group
	guard let theGroup = Q3OrderedDisplayGroup_New() else {
		return nil
	}
	
	// Create the transform
	if let theTransform = Q3RotateTransform_New(&transformData) {
		Q3Group_AddObject(theGroup, theTransform)
		Q3Object_Dispose(theTransform)
	}

	// Create the Torus
	torusData.torusAttributeSet = Q3AttributeSet_New()
	if let tas = torusData.torusAttributeSet {
		Q3AttributeSet_Add(tas, kQ3AttributeTypeDiffuseColor.rawValue, &colourTorus)
	}

	if let theTorus = Q3Torus_New(&torusData) {
		Q3Group_AddObject(theGroup, theTorus)
		Q3Object_Dispose(theTorus)
	}

	
	// Create the Sphere
	sphereData.ellipsoidAttributeSet = Q3AttributeSet_New()
	if let eas = sphereData.ellipsoidAttributeSet {
		Q3AttributeSet_Add(eas, kQ3AttributeTypeDiffuseColor.rawValue, &colourSphere)
	}

	if let theSphere = Q3Ellipsoid_New(&sphereData) {
		Q3Group_AddObject(theGroup, theSphere)
		Q3Object_Dispose(theSphere)
	}

	// Create the Cone
	coneData.coneAttributeSet = Q3AttributeSet_New()
	if let cas = coneData.coneAttributeSet {
		Q3AttributeSet_Add(cas, kQ3AttributeTypeDiffuseColor.rawValue, &colourCone)
	}

	if let theCone = Q3Cone_New(&coneData) {
		Q3Group_AddObject(theGroup, theCone)
		Q3Object_Dispose(theCone)
	}

	// Clean up
	if (torusData.torusAttributeSet != nil) {
		Q3Object_Dispose(torusData.torusAttributeSet)
	}

	if (sphereData.ellipsoidAttributeSet != nil) {
		Q3Object_Dispose(sphereData.ellipsoidAttributeSet)
	}

	if (coneData.coneAttributeSet != nil) {
		Q3Object_Dispose(coneData.coneAttributeSet)
	}

	return theGroup
}

/// Create a Torus object.
func createGeomTorus() -> TQ3GeometryObject! {
	var color = TQ3ColorRGB(r: 1.0, g: 0.7, b: 0.4)
	var torusData = TQ3TorusData(origin: TQ3Point3D(x: 0, y: 0, z: 0),
								 orientation: TQ3Vector3D(x: 0, y: 0, z: 0.1),
								 majorRadius: TQ3Vector3D(x: 2, y: 0, z: 0),
								 minorRadius: TQ3Vector3D(x: 0, y: 0.8, z: 0),
								 ratio: 1.2,
								 uMin: 0, uMax: 1, vMin: 0, vMax: 1,
								 caps: kQ3EndCapNone.rawValue,
								 interiorAttributeSet: nil,
								 torusAttributeSet: nil)
	
	torusData.torusAttributeSet = Q3AttributeSet_New()
	if let tas = torusData.torusAttributeSet {
		Q3AttributeSet_Add(tas,
						   kQ3AttributeTypeDiffuseColor.rawValue,
						   &color)
	}
	
	defer {
		// Clean up
		if let tas = torusData.torusAttributeSet {
			Q3Object_Dispose(tas)
		}
	}
	
	// Create the geometry
	guard let theTorus = Q3Torus_New(&torusData) else {
		return nil
	}

	return theTorus
}

/// Create a Triangle object.
func createGeomTriangle() -> TQ3GeometryObject! {
	let vertPoints = [TQ3Point3D(x: -1.5, y: -1.5, z: 0),
					  TQ3Point3D(x: 0, y: 1.5, z: 0),
					  TQ3Point3D(x: 1.5, y: -1.5, z: 0)]
	var vertColours = [TQ3ColorRGB(r: 1, g: 0, b: 0),
					   TQ3ColorRGB(r: 0, g: 1, b: 0),
					   TQ3ColorRGB(r: 0, g: 0, b: 1)]
	
	var triangleData = TQ3TriangleData()
	var vertUVs = [TQ3Param2D]()
	
	// Set up the data
	triangleData.triangleAttributeSet = nil

	createUVsFromPoints(vertPoints, &vertUVs)

	// We have to unwrap this loop because Swift doesn't allow subscript access for tuples
	// 0
	do {
		triangleData.vertices.0.point        = vertPoints[0]
		triangleData.vertices.0.attributeSet = Q3AttributeSet_New()
		
		if let attrSet = triangleData.vertices.0.attributeSet {
			Q3AttributeSet_Add(attrSet,
							   kQ3AttributeTypeDiffuseColor.rawValue,
							   &vertColours[0])
			
			Q3AttributeSet_Add(attrSet,
							   kQ3AttributeTypeSurfaceUV.rawValue,
							   &vertUVs[0])
		}
	}

	// 1
	do {
		triangleData.vertices.1.point        = vertPoints[1]
		triangleData.vertices.1.attributeSet = Q3AttributeSet_New()
		
		if let attrSet = triangleData.vertices.1.attributeSet {
			Q3AttributeSet_Add(attrSet,
							   kQ3AttributeTypeDiffuseColor.rawValue,
							   &vertColours[1])
			
			Q3AttributeSet_Add(attrSet,
							   kQ3AttributeTypeSurfaceUV.rawValue,
							   &vertUVs[1])
		}
	}
	
	// 2
	do {
		triangleData.vertices.2.point        = vertPoints[2]
		triangleData.vertices.2.attributeSet = Q3AttributeSet_New()
		
		if let attrSet = triangleData.vertices.2.attributeSet {
			Q3AttributeSet_Add(attrSet,
							   kQ3AttributeTypeDiffuseColor.rawValue,
							   &vertColours[2])
			
			Q3AttributeSet_Add(attrSet,
							   kQ3AttributeTypeSurfaceUV.rawValue,
							   &vertUVs[2])
		}
	}
	
	// Clean up
	defer {
		// 0
		if let attrSet = triangleData.vertices.0.attributeSet {
			Q3Object_Dispose(attrSet)
		}

		// 1
		if let attrSet = triangleData.vertices.1.attributeSet {
			Q3Object_Dispose(attrSet)
		}
		
		// 2
		if let attrSet = triangleData.vertices.2.attributeSet {
			Q3Object_Dispose(attrSet)
		}
	}
	
	// Create the geometry
	return Q3Triangle_New(&triangleData)
}

/// Create a TriGrid object.
func createGeomTriGrid() -> TQ3GeometryObject! {
	return nil
}

/// Create a TriMesh object.
func createGeomTriMesh() -> TQ3GeometryObject? {
	var vertPoints = [TQ3Point3D(x: -1.5, y: -1.5, z: 0.0),
					  TQ3Point3D(x:  0.0, y:  1.5, z: 0.0),
					  TQ3Point3D(x:  1.5, y: -1.5, z: 0.0),
					  TQ3Point3D(x:  0.0, y: -1.5, z: -1.0)]
	var vertColours = [TQ3ColorRGB(r: 1.0, g: 0.0, b: 0.0),
					   TQ3ColorRGB(r: 0.0, g: 1.0, b: 0.0),
					   TQ3ColorRGB(r: 0.0, g: 0.0, b: 1.0),
					   TQ3ColorRGB(r: 1.0, g: 1.0, b: 0.0)]
	var triangles: [TQ3TriMeshTriangleData] = [TQ3TriMeshTriangleData(pointIndices: (1, 0, 3)), TQ3TriMeshTriangleData(pointIndices: (3, 2, 1))]
	var vertUVs = [TQ3Param2D]()
	
	// Set up the data
	createUVsFromPoints(vertPoints, &vertUVs)

	return vertUVs.withUnsafeMutableBytes { (vertUV) -> TQ3GeometryObject? in
		var attrData = [TQ3TriMeshAttributeData](repeating: TQ3TriMeshAttributeData(), count: 2)
		attrData[0] = TQ3TriMeshAttributeData(attributeType: TQ3AttributeType(kQ3AttributeTypeDiffuseColor.rawValue),
											  data: &vertColours,
											  attributeUseArray: nil)
		
		attrData[1].attributeType     = TQ3AttributeType(kQ3AttributeTypeSurfaceUV.rawValue)
		attrData[1].data              = vertUV.baseAddress
		attrData[1].attributeUseArray = nil
		
		var triMeshData = TQ3TriMeshData(triMeshAttributeSet: nil,
										 numTriangles: 2, triangles: &triangles,
										 numTriangleAttributeTypes: 0,
										 triangleAttributeTypes: nil, numEdges: 0,
										 edges: nil, numEdgeAttributeTypes: 0,
										 edgeAttributeTypes: nil, numPoints: 4,
										 points: &vertPoints,
										 numVertexAttributeTypes: 2,
										 vertexAttributeTypes: &attrData,
										 bBox: TQ3BoundingBox())
		
		Q3BoundingBox_SetFromPoints3D(&triMeshData.bBox, triMeshData.points, triMeshData.numPoints, TQ3Uns32(MemoryLayout<TQ3Point3D>.size))
		
		return Q3TriMesh_New(&triMeshData)
	}
}

/// Create a group of pale objects.
func createPastelGroup() -> TQ3GroupObject! {
	guard let theGroup = Q3DisplayGroup_New() else {
		return nil
	}
	do {
		var colorBall = TQ3ColorRGB(r: 1.0, g: 0.7, b: 0.7)
		var ballData = TQ3EllipsoidData(origin: TQ3Point3D(x: 0, y: 0, z: 1.5),
										orientation: TQ3Vector3D(x: 0, y: 0.3, z: 0),
										majorRadius: TQ3Vector3D(x: 0, y: 0, z: 0.3),
										minorRadius: TQ3Vector3D(x: 0.3, y: 0, z: 0),
										uMin: 0, uMax: 1, vMin: 0, vMax: 1,
										caps: kQ3EndCapNone.rawValue,
										interiorAttributeSet: nil,
										ellipsoidAttributeSet: nil)

		
		ballData.ellipsoidAttributeSet = Q3AttributeSet_New()
		Q3AttributeSet_Add(ballData.ellipsoidAttributeSet!,
							kQ3AttributeTypeDiffuseColor.rawValue, &colorBall)
		let theBall = Q3Ellipsoid_New(&ballData)
		Q3Object_Dispose(ballData.ellipsoidAttributeSet)
		Q3Group_AddObject(theGroup, theBall!)
		Q3Object_Dispose(theBall)
	}

	do {
		var colorCube = TQ3ColorRGB(r: 0.8, g: 0.8, b: 0.8)
		var cubeData = TQ3BoxData(origin: TQ3Point3D(x: 0.7, y: 0, z: -0.8),
								  orientation: TQ3Vector3D(x: 0, y: 0.4, z: 0),
								  majorAxis: TQ3Vector3D(x: 0, y: 0, z: 0.4),
								  minorAxis: TQ3Vector3D(x: 0.4, y: 0, z: 0),
								  faceAttributeSet: nil, boxAttributeSet: nil)

		cubeData.boxAttributeSet = Q3AttributeSet_New()
		Q3AttributeSet_Add(cubeData.boxAttributeSet!,
						   kQ3AttributeTypeDiffuseColor.rawValue, &colorCube)
		let theCube = Q3Box_New(&cubeData)!
		Q3Object_Dispose(cubeData.boxAttributeSet)
		Q3Group_AddObject(theGroup, theCube)
		Q3Object_Dispose(theCube)
	}
	
	do {
		var colorCyl = TQ3ColorRGB(r: 0.7, g: 1, b: 0.7)
		var cylData = TQ3CylinderData(origin: TQ3Point3D(x: -0.7, y: 0, z: -0.8),
									  orientation: TQ3Vector3D(x: 0, y: 0.3, z: 0),
									  majorRadius: TQ3Vector3D(x: 0, y: 0, z: 0.3),
									  minorRadius: TQ3Vector3D(x: 0.3, y: 0, z: 0),
									  uMin: 0, uMax: 1, vMin: 0, vMax: 1,
									  caps: TQ3EndCap(kQ3EndCapMaskTop.rawValue | kQ3EndCapMaskBottom.rawValue),
									  interiorAttributeSet: nil,
									  topAttributeSet: nil,
									  faceAttributeSet: nil,
									  bottomAttributeSet: nil,
									  cylinderAttributeSet: nil)
		
		cylData.cylinderAttributeSet = Q3AttributeSet_New()
		Q3AttributeSet_Add(cylData.cylinderAttributeSet!,
						   kQ3AttributeTypeDiffuseColor.rawValue, &colorCyl)
		let theCylinder = Q3Cylinder_New(&cylData)!
		Q3Object_Dispose(cylData.cylinderAttributeSet)
		Q3Group_AddObject(theGroup, theCylinder)
		Q3Object_Dispose(theCylinder)
	}
	
	return theGroup
}

func createGeomBounds(_ theGeom: TQ3GeometryObject, in aView: TQ3ViewObject) -> TQ3GroupObject? {
	var boxColour = TQ3ColorRGB(r: 0.0, g: 1.0, b: 0.0)
	var theBounds = TQ3BoundingBox()
	var theShader: TQ3ShaderObject?
	var theStyle: TQ3StyleObject?
	var boxData = TQ3BoxData()
	
	// Create the group
	guard let theGroup = Q3OrderedDisplayGroup_New() else {
		return nil
	}
	
	// Add the shader/fill style
	theShader = Q3NULLIllumination_New()
	if let theShader = theShader {
		Q3Group_AddObject(theGroup, theShader)
		Q3Object_Dispose(theShader)
	}
	
	theStyle = Q3FillStyle_New(kQ3FillStyleEdges)
	if let theStyle = theStyle {
		Q3Group_AddObject(theGroup, theStyle)
		Q3Object_Dispose(theStyle)
	}
	
	// Calculate the bounding box
	bounds(in: aView, for: theGeom, &theBounds)
	
	// Add the box geometry
	boxData.origin = theBounds.min
	
	Q3Vector3D_Set(&boxData.orientation, 0.0, theBounds.max.y - theBounds.min.y, 0.0)
	Q3Vector3D_Set(&boxData.majorAxis,   0.0, 0.0, theBounds.max.z - theBounds.min.z)
	Q3Vector3D_Set(&boxData.minorAxis,   theBounds.max.x - theBounds.min.x, 0.0, 0.0)
	
	boxData.faceAttributeSet = nil
	boxData.boxAttributeSet  = Q3AttributeSet_New()
	if let bas = boxData.boxAttributeSet {
		Q3AttributeSet_Add(bas, TQ3AttributeType(kQ3AttributeTypeDiffuseColor.rawValue), &boxColour)
	}
	defer {
		// Clean up
		if let attrSet = boxData.boxAttributeSet {
			Q3Object_Dispose(attrSet)
		}
	}
	
	if let theBox = Q3Box_New(&boxData) {
		Q3Group_AddObject(theGroup, theBox)
		Q3Object_Dispose(theBox)
	}
	
	return theGroup
}

private func loadTextureShaderFromResource(named inName: String) -> TQ3ShaderObject? {
	var theShader: TQ3ShaderObject? = nil
	let name2 = inName as NSString
	let namePart = name2.deletingPathExtension
	let extPart = name2.pathExtension
	
	if let theURL = Bundle.main.url(forResource: namePart, withExtension: extPart) {
		theShader = theURL.withUnsafeFileSystemRepresentation { fileRep in
			QutTexture_CreateTextureFromTGAFile(fileRep)
		}
	}
	
	return theShader
}

private func makeTextureAttrs(fromName inName: String) -> TQ3AttributeSet? {
	guard let atts = Q3AttributeSet_New() else {
		return nil
	}
	if var theShader = loadTextureShaderFromResource(named: inName) {
		Q3AttributeSet_Add(atts, kQ3AttributeTypeSurfaceShader.rawValue, &theShader)
		Q3Object_Dispose(theShader)
	}
	return atts
}

func createBallAboutCamera() -> TQ3GroupObject? {
	guard let theGroup = Q3DisplayGroup_New() else {
		return nil
	}
	var subData = TQ3SubdivisionStyleData(method: kQ3SubdivisionMethodConstant, c1: 100, c2: 100)
	let subStyle = Q3SubdivisionStyle_New(&subData)
	Q3Group_AddObject(theGroup, subStyle)
	defer {
		Q3Object_Dispose(subStyle)
	}
	let tx1 = makeTextureAttrs(fromName: "US_$5_obverse.tga")
	defer {
		if let tx1 = tx1 {
			Q3Object_Dispose(tx1)
		}
	}
	var ballData = TQ3EllipsoidData(origin: TQ3Point3D(x: 0, y: 0, z: 5),
									orientation: TQ3Vector3D(x: 0, y: 4, z: 0),
									majorRadius: TQ3Vector3D(x: 0, y: 0, z: 4),
									minorRadius: TQ3Vector3D(x: 4, y: 0, z: 0),
									uMin: 0, uMax: 1, vMin: 0, vMax: 1,
									caps: kQ3EndCapNone.rawValue, interiorAttributeSet: nil, ellipsoidAttributeSet: tx1)
	
	if let ball = Q3Ellipsoid_New(&ballData) {
		Q3Group_AddObject(theGroup, ball)
		Q3Object_Dispose(ball)
	}
	return theGroup
}

func createBoxAboutCamera() -> TQ3GeometryObject? {
	let tx1 = makeTextureAttrs(fromName: "1.tga")
	defer {
		if let tx1 = tx1 {
			Q3Object_Dispose(tx1)
		}
	}
	let tx2 = makeTextureAttrs(fromName: "2.tga")
	defer {
		if let tx2 = tx2 {
			Q3Object_Dispose(tx2)
		}
	}
	let tx3 = makeTextureAttrs(fromName: "3.tga")
	defer {
		if let tx3 = tx3 {
			Q3Object_Dispose(tx3)
		}
	}
	let tx4 = makeTextureAttrs(fromName: "4.tga")
	defer {
		if let tx4 = tx4 {
			Q3Object_Dispose(tx4)
		}
	}
	let tx5 = makeTextureAttrs(fromName: "5.tga")
	defer {
		if let tx5 = tx5 {
			Q3Object_Dispose(tx5)
		}
	}
	let tx6 = makeTextureAttrs(fromName: "6.tga")
	defer {
		if let tx6 = tx6 {
			Q3Object_Dispose(tx6)
		}
	}
	var faceAtts: [TQ3AttributeSet?] = [tx1, tx2, tx3, tx4, tx5, tx6]
	var boxData = TQ3BoxData(origin: TQ3Point3D(x: -2, y: -2, z: 3),
							 orientation: TQ3Vector3D(x: 0, y: 0, z: 4),
							 majorAxis: TQ3Vector3D(x: 4, y: 0, z: 0),
							 minorAxis: TQ3Vector3D(x: 0, y: 4, z: 0),
							 faceAttributeSet: &faceAtts,
							 boxAttributeSet: nil)
	
	return Q3Box_New(&boxData)
}


func createSubdividedBoxAboutCamera(_ inView: TQ3ViewObject) -> TQ3GroupObject? {
	guard let theBox = createBoxAboutCamera() else {
		return nil
	}
	var dummyBounds = TQ3BoundingBox()
	var decomp: TQ3GroupObject? = nil
	
	if kQ3Success == Q3View_StartBoundingBox(inView, kQ3ComputeBoundsExact) {
		repeat {
			decomp = Q3Geometry_GetDecomposed(theBox, inView)
		} while Q3View_EndBoundingBox(inView, &dummyBounds) == kQ3ViewStatusRetraverse
	}
	
	guard let decomp = decomp else {
		return nil
	}

	let iter = GroupIterator(group: decomp, type: kQ3GeometryTypeTriMesh)
	for theItem in iter {
		guard let subItem = SubdivideTriMesh(theItem.rawValue, 4) else {
			continue
		}
		let subNaked = Q3TriMesh_GetNakedGeometry(subItem)
		Q3TriMesh_SetNakedGeometry(theItem.rawValue, subNaked)
		Q3Object_Dispose(subNaked)
		Q3Object_Dispose(subItem)
	}

	return decomp
}
