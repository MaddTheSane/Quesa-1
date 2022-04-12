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
	Q3Point3D_Set(&boxData.origin,      -0.5, -1.0,  0.5);
	Q3Vector3D_Set(&boxData.orientation, 0.0,  2.0,  0.0);
	Q3Vector3D_Set(&boxData.majorAxis,   0.0,  0.0,  1.0);
	Q3Vector3D_Set(&boxData.minorAxis,   1.0,  0.0,  0.0);
	boxData.boxAttributeSet  = nil;
	
	for n in 0 ..< 6 {
		faceAttributes[n] = Q3AttributeSet_New();
		if (faceAttributes[n] != nil) {
			Q3AttributeSet_Add(faceAttributes[n]!, TQ3AttributeType(kQ3AttributeTypeDiffuseColor.rawValue), &faceColour[n]);
		}
	}
	defer {
		// Clean up
		for n in 0 ..< 6 {
			if faceAttributes[n] != nil {
				Q3Object_Dispose(faceAttributes[n])
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
	return nil
}

/// Create a Cylinder object.
func createGeomCylinder() -> TQ3GeometryObject! {
	return nil
}

/// Create a Disk object.
func createGeomDisk() -> TQ3GeometryObject! {
	return nil
}

/// Create an Ellipse object.
func createGeomEllipse() -> TQ3GeometryObject! {
	return nil
}

/// Create an Ellipsoid object.
func createGeomEllipsoid() -> TQ3GeometryObject! {
	return nil
}

/// Create an General Polygon object.
func createGeomGeneralPolygon() -> TQ3GeometryObject! {
	return nil
}

/// Create a Line object.
func createGeomLine() -> TQ3GeometryObject! {
	return nil
}

/// Create a Marker object.
func createGeomMarker() -> TQ3GeometryObject! {
	return nil
}

/// Create a Mesh object.
func createGeomMesh() -> TQ3GeometryObject! {
	return nil
}

/// Create a NURB curve object.
func createGeomNURBCurve() -> TQ3GeometryObject! {
	return nil
}

/// Create a NURB patch object.
func createGeomNURBPatch() -> TQ3GeometryObject! {
	return nil
}

/// Create a Pixmap marker object.
func createGeomPixmapMarker() -> TQ3GeometryObject! {
	return nil
}

/// Create a Point object.
func createGeomPoint() -> TQ3GeometryObject! {
	return nil
}

/// Create a Polygon object.
func createGeomPolygon() -> TQ3GeometryObject! {
	return nil
}

/// Create a Polyhedron object.
func createGeomPolyhedron() -> TQ3GeometryObject! {
	return nil
}

/// Create a PolyLine object.
func createGeomPolyLine() -> TQ3GeometryObject! {
	return nil
}

/// Create the Quesa logo geometry.
func createGeomQuesa() -> TQ3GroupObject! {
	return nil
}

/// Create a Torus object.
func createGeomTorus() -> TQ3GeometryObject! {
	return nil
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
					  TQ3Point3D(x:  0.0, y: -1.5, z: -1.0)];
	var vertColours = [TQ3ColorRGB(r: 1.0, g: 0.0, b: 0.0),
					   TQ3ColorRGB(r: 0.0, g: 1.0, b: 0.0),
					   TQ3ColorRGB(r: 0.0, g: 0.0, b: 1.0),
					   TQ3ColorRGB(r: 1.0, g: 1.0, b: 0.0)];
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

		cubeData.boxAttributeSet = Q3AttributeSet_New();
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
	
	boxData.faceAttributeSet = nil;
	boxData.boxAttributeSet  = Q3AttributeSet_New()
	if let bas = boxData.boxAttributeSet {
		Q3AttributeSet_Add(bas, TQ3AttributeType(kQ3AttributeTypeDiffuseColor.rawValue), &boxColour)
	}
	defer {
		// Clean up
		if boxData.boxAttributeSet != nil {
			Q3Object_Dispose(boxData.boxAttributeSet)
		}
	}
	
	if let theBox = Q3Box_New(&boxData) {
		Q3Group_AddObject(theGroup, theBox)
		Q3Object_Dispose(theBox)
	}
	
	return theGroup
}
