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
		if let faceAttrib = faceAttributes[n] {
			Q3AttributeSet_Add(faceAttrib, TQ3AttributeType(kQ3AttributeTypeDiffuseColor.rawValue), &faceColour[n]);
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
	/*
	 TQ3ColorRGB			topColour    = { 0.0f, 0.0f, 1.0f };
		 TQ3ColorRGB			bottomColour = { 0.0f, 1.0f, 0.0f };
		 TQ3ColorRGB			faceColour   = { 1.0f, 0.0f, 0.0f };
		 TQ3ColorRGB			specColour	 = { 1.0f, 1.0f, 0.5f };
		 TQ3CylinderData		cylinderData;
		 TQ3GeometryObject	theCylinder;



		 // Set up the data
		 Q3Point3D_Set(&cylinderData.origin,       0.0f, -1.0f,  0.0f);
		 Q3Vector3D_Set(&cylinderData.orientation, 0.0f,  2.0f,  0.0f);
		 Q3Vector3D_Set(&cylinderData.majorRadius, 0.0f,  0.0f,  1.0f);
		 Q3Vector3D_Set(&cylinderData.minorRadius, 1.0f,  0.0f,  0.0f);
		 cylinderData.uMin = 0.0f;
		 cylinderData.uMax = 1.0f;
		 cylinderData.vMin = 0.0f;
		 cylinderData.vMax = 1.0f;
		 cylinderData.caps = kQ3EndCapMaskBottom | kQ3EndCapMaskTop;

		 cylinderData.cylinderAttributeSet     = NULL;
		 cylinderData.faceAttributeSet     = NULL;
		 cylinderData.interiorAttributeSet = NULL;
		 cylinderData.topAttributeSet   = NULL;
		 cylinderData.bottomAttributeSet   = NULL;


		 cylinderData.cylinderAttributeSet = Q3AttributeSet_New();
		 if (cylinderData.cylinderAttributeSet != NULL)
			 Q3AttributeSet_Add(cylinderData.cylinderAttributeSet, kQ3AttributeTypeSpecularColor, &specColour);

		 cylinderData.faceAttributeSet = Q3AttributeSet_New();
		 if (cylinderData.faceAttributeSet != NULL)
			 Q3AttributeSet_Add(cylinderData.faceAttributeSet, kQ3AttributeTypeDiffuseColor, &faceColour);

		 cylinderData.topAttributeSet = Q3AttributeSet_New();
		 if (cylinderData.topAttributeSet != NULL)
			 Q3AttributeSet_Add(cylinderData.topAttributeSet, kQ3AttributeTypeDiffuseColor, &topColour);

		 cylinderData.bottomAttributeSet = Q3AttributeSet_New();
		 if (cylinderData.bottomAttributeSet != NULL)
			 Q3AttributeSet_Add(cylinderData.bottomAttributeSet, kQ3AttributeTypeDiffuseColor, &bottomColour);



		 // Create the geometry
		 theCylinder = Q3Cylinder_New(&cylinderData);



		 // Clean up
		 if (cylinderData.cylinderAttributeSet != NULL)
			 Q3Object_Dispose(cylinderData.cylinderAttributeSet);
			 
		 if (cylinderData.interiorAttributeSet != NULL)
			 Q3Object_Dispose(cylinderData.interiorAttributeSet);
			 
		 if (cylinderData.faceAttributeSet != NULL)
			 Q3Object_Dispose(cylinderData.faceAttributeSet);
			 
		 if (cylinderData.topAttributeSet != NULL)
			 Q3Object_Dispose(cylinderData.topAttributeSet);

		 if (cylinderData.bottomAttributeSet != NULL)
			 Q3Object_Dispose(cylinderData.bottomAttributeSet);
			 
		 return(theCylinder);
	 */
	return nil
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

	diskData.diskAttributeSet = Q3AttributeSet_New();
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

	ellipseData.ellipseAttributeSet = Q3AttributeSet_New();
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
	ellipsoidData.ellipsoidAttributeSet = Q3AttributeSet_New();
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
	/*
	 TQ3Point3D						vertPoints[6] = { {-0.5f, -1.0f, 0.0f},
														   {-1.0f,  1.0f, 0.0f},
														   {-0.2f,  0.0f, 0.0f},
														   { 0.2f,  0.0f, 0.0f},
														   { 1.0f,  1.0f, 0.0f},
														   { 0.5f, -1.0f, 0.0f} };
		 TQ3ColorRGB						vertColours[6] = { {1.0f, 0.0f, 0.0f},
															{0.0f, 1.0f, 0.0f},
															{0.0f, 0.0f, 1.0f},
															{1.0f, 0.0f, 1.0f},
															{1.0f, 1.0f, 0.0f},
															{0.0f, 1.0f, 1.0f} };
		 TQ3GeneralPolygonData			generalPolygonData;
		 TQ3GeneralPolygonContourData	theContours[1];
		 TQ3Vertex3D						theVertices[6];
		 TQ3GeometryObject				theGeneralPoly;
		 TQ3Param2D						vertUVs[6];
		 TQ3Uns32						n;



		 // Set up the data
		 generalPolygonData.numContours                = 1;
		 generalPolygonData.contours                   = theContours;
		 generalPolygonData.shapeHint                  = kQ3GeneralPolygonShapeHintComplex;
		 generalPolygonData.generalPolygonAttributeSet = NULL;

		 theContours[0].numVertices = 6;
		 theContours[0].vertices = theVertices;

		 createUVsFromPoints(theContours[0].numVertices, vertPoints, vertUVs);
		 
		 for (n = 0; n < 6; n++)
			 {
			 theContours[0].vertices[n].point        = vertPoints[n];
			 theContours[0].vertices[n].attributeSet = Q3AttributeSet_New();

			 if (theContours[0].vertices[n].attributeSet != NULL)
				 {
				 Q3AttributeSet_Add(theContours[0].vertices[n].attributeSet,
									 kQ3AttributeTypeDiffuseColor,
									 &vertColours[n]);

				 Q3AttributeSet_Add(theContours[0].vertices[n].attributeSet,
									 kQ3AttributeTypeSurfaceUV,
									 &vertUVs[n]);
				 }
			 }



		 // Create the geometry
		 theGeneralPoly = Q3GeneralPolygon_New(&generalPolygonData);



		 // Clean up
		 for (n = 0; n < 6; n++)
			 {
			 if (theContours[0].vertices[n].attributeSet != NULL)
				 Q3Object_Dispose(theContours[0].vertices[n].attributeSet);
			 }
			 
		 return(theGeneralPoly);
	 */
	return nil
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
	return Q3Line_New(&lineData);
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
		return Q3Marker_New(&markerData);
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
	let theAttributes = Q3AttributeSet_New();
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
	/*
	 TQ3ColorRGB			theColour = { 0.8f, 0.2f, 0.6f };
		 TQ3RationalPoint4D	thePoints[7] = { { -2.0f,  0.0f,  0.0f, 1.0f },
											  { -1.0f,  1.0f,  0.0f, 1.0f },
											  { -0.5f,  0.0f,  0.0f, 1.0f },
											  {  0.0f,  1.0f,  0.0f, 1.0f },
											  {  0.5f,  0.0f,  0.0f, 1.0f },
											  {  1.0f,  1.0f,  0.0f, 1.0f },
											  {  2.0f,  0.0f,  0.0f, 1.0f } };
		 float				theKnots[11] = { 0.0f,  0.0f, 0.0f,  0.0f,
											  0.25f, 0.5f, 0.75f, 1.0f,
											  1.0f,  1.0f, 1.0f };
		 TQ3NURBCurveData	curveData;
		 TQ3GeometryObject	theCurve;



		 // Set up the data
		 curveData.order 			= 4;
		 curveData.numPoints			= 7;
		 curveData.controlPoints		= thePoints;
		 curveData.knots 			= theKnots;
		 curveData.curveAttributeSet = Q3AttributeSet_New();
		 
		 if (curveData.curveAttributeSet != NULL)
			 Q3AttributeSet_Add(curveData.curveAttributeSet, kQ3AttributeTypeDiffuseColor, &theColour);



		 // Create the geometry
		 theCurve = Q3NURBCurve_New(&curveData);



		 // Clean up
		 if (curveData.curveAttributeSet != NULL)
			 Q3Object_Dispose(curveData.curveAttributeSet);

		 return(theCurve);
	 */
	return nil
}

/// Create a NURB patch object.
func createGeomNURBPatch() -> TQ3GeometryObject! {
	/*
	 TQ3RationalPoint4D		thePoints[12] = { { -1.5f, -1.0f,  0.0f, 1.0f },
												   { -0.5f, -1.0f,  2.0f, 1.0f },
												   {  0.5f, -1.0f,  0.0f, 1.0f },
												   {  1.5f, -1.0f,  0.0f, 1.0f },

												   { -1.5f, -0.0f,  0.0f, 1.0f },
												   { -0.5f, -0.0f,  2.0f, 1.0f },
												   {  0.5f, -0.0f, -2.0f, 1.0f },
												   {  1.5f, -0.0f, -2.0f, 1.0f },

												   { -1.5f,  1.0f,  0.0f, 1.0f },
												   { -0.5f,  1.0f,  0.0f, 1.0f },
												   {  0.5f,  1.0f,  0.0f, 1.0f },
												   {  1.5f,  1.0f,  0.0f, 1.0f } };

		 float					vKnots[6] = { 0.0f, 0.0f, 0.0f, 1.0f, 1.0f, 1.0f };
		 float					uKnots[8] = { 0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 1.0f, 1.0f, 1.0f };

		 TQ3RationalPoint3D		trimPointsZero[5] = { { 0.1f, 0.1f, 1.0f },
													   { 0.9f, 0.1f, 1.0f },
													   { 0.4f, 0.4f, 1.0f },
													   { 0.1f, 0.4f, 1.0f },
													   { 0.1f, 0.1f, 1.0f } };
		 TQ3RationalPoint3D		trimPointsOne[5] =  { { 0.3f, 0.6f, 1.0f },
													   { 0.9f, 0.6f, 1.0f },
													   { 0.4f, 0.9f, 1.0f },
													   { 0.2f, 0.9f, 1.0f },
													   { 0.3f, 0.6f, 1.0f } };

		 float					trimKnotsZero[9] = { 0.0f, 0.0f, 0.0f, 0.0f, 0.5f,
													  1.0f, 1.0f, 1.0f, 1.0f };
		 float					trimKnotsOne[9]  = { 0.0f, 0.0f, 0.0f, 0.0f, 0.5f,
													  1.0f, 1.0f, 1.0f, 1.0f };

		 TQ3ColorRGB							theColour = { 0.9f, 0.2f, 0.9f };
		 TQ3NURBPatchTrimCurveData			trimCurveZero, trimCurveOne;
		 TQ3NURBPatchTrimLoopData			trimLoops[2];
		 TQ3NURBPatchData					patchData;
		 TQ3GeometryObject					thePatch;



		 // Set up the data
		 trimLoops[0].numTrimCurves 	= 1;
		 trimLoops[0].trimCurves		= &trimCurveZero;
		 trimLoops[1].numTrimCurves 	= 1;
		 trimLoops[1].trimCurves		= &trimCurveOne;

		 trimCurveZero.order			= 4;
		 trimCurveZero.numPoints		= 5;
		 trimCurveZero.knots			= trimKnotsZero;
		 trimCurveZero.controlPoints = trimPointsZero;

		 trimCurveOne.order		   = 4;
		 trimCurveOne.numPoints	   = 5;
		 trimCurveOne.knots		   = trimKnotsOne;
		 trimCurveOne.controlPoints = trimPointsOne;
								 
		 patchData.uOrder		= 4;
		 patchData.vOrder		= 3;
		 patchData.numColumns	= 4;
		 patchData.numRows		= 3;
		 patchData.uKnots		= uKnots;
		 patchData.vKnots		= vKnots;
		 patchData.controlPoints = thePoints;
		 patchData.numTrimLoops	= 0;
		 patchData.trimLoops 	= NULL;

		 patchData.patchAttributeSet = Q3AttributeSet_New();
		 if (patchData.patchAttributeSet != NULL)
			 Q3AttributeSet_Add(patchData.patchAttributeSet, kQ3AttributeTypeDiffuseColor, &theColour);



		 // Create the geometry
		 thePatch = Q3NURBPatch_New(&patchData);



		 // Clean up
		 Q3Object_Dispose(patchData.patchAttributeSet);

		 return(thePatch);
	 */
	return nil
}

/// Create a Pixmap marker object.
func createGeomPixmapMarker() -> TQ3GeometryObject! {
	/*
	 TQ3PixmapMarkerData		pixmapMarkerData = { { -1.0f, 0.5f, 0.5f },
														-50, -50,
													{ NULL, 0, 0, 0, 32,
													  kQ3PixelTypeRGB32,
													  kQ3EndianBig,
													  kQ3EndianBig },
													  NULL };
		 TQ3Uns32				theImage[64][64];
		 TQ3Uns32				x, y, r, g;
		 TQ3GeometryObject		theMarker;



		 // Create an image
		 for (y = 0; y < 64; y++)
			 {
			 g = (y * 4);
			 for (x = 0; x < 64; x++)
				 {
				 r = (x * 4);
				 theImage[y][x] = (r << 16) | (g << 8);
				 }
			 }



		 // Initialise the pixmap
		 pixmapMarkerData.pixmap.width    = 64;
		 pixmapMarkerData.pixmap.height   = 64;
		 pixmapMarkerData.pixmap.rowBytes = pixmapMarkerData.pixmap.width * sizeof(TQ3Uns32);
		 pixmapMarkerData.pixmap.image    = Q3MemoryStorage_New((TQ3Uns8 *) theImage, sizeof(theImage));

		 if (pixmapMarkerData.pixmap.image == NULL)
			 return(NULL);



		 // Create the geometry
		 theMarker = Q3PixmapMarker_New(&pixmapMarkerData);



		 // Clean up
		 Q3Object_Dispose(pixmapMarkerData.pixmap.image);

		 return(theMarker);
	 */
	return nil
}

/// Create a Point object.
func createGeomPoint() -> TQ3GeometryObject! {
	var pointData =  TQ3PointData(point: TQ3Point3D(x: -1, y: -1, z: -1), pointAttributeSet: nil)
	
	// Create the geometry
	let thePoint = Q3Point_New(&pointData);
	
	return thePoint
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
	/*
	 TQ3Point3D			vertPoints[5] = { {-1.0f, -1.0f, -1.0f},
											   {-1.0f, -0.5f,  1.0f},
											   { 1.0f,  0.0f,  1.0f},
											   { 1.0f,  0.5f, -1.0f},
											   { 0.0f,  1.0f,  0.0f} };
		 TQ3ColorRGB			vertColours[5] = { {1.0f, 0.0f, 0.0f},
												{0.0f, 1.0f, 0.0f},
												{0.0f, 0.0f, 1.0f},
												{1.0f, 1.0f, 0.0f},
												{0.0f, 1.0f, 1.0f} };
		 TQ3Vertex3D			theVertices[5];
		 TQ3PolyLineData		polyLineData;
		 TQ3GeometryObject	thePolyLine;
		 TQ3Uns32			n;



		 // Set up the data
		 polyLineData.numVertices          = 5;
		 polyLineData.vertices             = theVertices;
		 polyLineData.polyLineAttributeSet = NULL;
		 polyLineData.segmentAttributeSet  = NULL;

		 for (n = 0; n < 5; n++)
			 {
			 polyLineData.vertices[n].point        = vertPoints[n];
			 polyLineData.vertices[n].attributeSet = Q3AttributeSet_New();

			 if (polyLineData.vertices[n].attributeSet != NULL)
				 Q3AttributeSet_Add(polyLineData.vertices[n].attributeSet,
									 kQ3AttributeTypeDiffuseColor,
									 &vertColours[n]);
			 }



		 // Create the geometry
		 thePolyLine = Q3PolyLine_New(&polyLineData);



		 // Clean up
		 for (n = 0; n < 5; n++)
			 {
			 if (polyLineData.vertices[n].attributeSet != NULL)
				 Q3Object_Dispose(polyLineData.vertices[n].attributeSet);
			 }

		 return(thePolyLine);
	 */
	return nil
}

/// Create the Quesa logo geometry.
func createGeomQuesa() -> TQ3GroupObject! {
	var	transformData = TQ3RotateTransformData( axis: kQ3AxisZ, radians: Q3Math_DegreesToRadians(45.0))
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
		Q3Group_AddObject(theGroup, theTransform);
		Q3Object_Dispose(theTransform);
	}

	// Create the Torus
	torusData.torusAttributeSet = Q3AttributeSet_New();
	if let tas = torusData.torusAttributeSet {
		Q3AttributeSet_Add(tas, kQ3AttributeTypeDiffuseColor.rawValue, &colourTorus);
	}

	if let theTorus = Q3Torus_New(&torusData) {
		Q3Group_AddObject(theGroup, theTorus);
		Q3Object_Dispose(theTorus);
	}

	
	// Create the Sphere
	sphereData.ellipsoidAttributeSet = Q3AttributeSet_New();
	if let eas = sphereData.ellipsoidAttributeSet {
		Q3AttributeSet_Add(eas, kQ3AttributeTypeDiffuseColor.rawValue, &colourSphere);
	}

	if let theSphere = Q3Ellipsoid_New(&sphereData) {
		Q3Group_AddObject(theGroup, theSphere);
		Q3Object_Dispose(theSphere);
	}

	// Create the Cone
	coneData.coneAttributeSet = Q3AttributeSet_New();
	if let cas = coneData.coneAttributeSet {
		Q3AttributeSet_Add(cas, kQ3AttributeTypeDiffuseColor.rawValue, &colourCone);
	}

	if let theCone = Q3Cone_New(&coneData) {
		Q3Group_AddObject(theGroup, theCone);
		Q3Object_Dispose(theCone);
	}

	// Clean up
	if (torusData.torusAttributeSet != nil) {
		Q3Object_Dispose(torusData.torusAttributeSet);
	}

	if (sphereData.ellipsoidAttributeSet != nil) {
		Q3Object_Dispose(sphereData.ellipsoidAttributeSet);
	}

	if (coneData.coneAttributeSet != nil) {
		Q3Object_Dispose(coneData.coneAttributeSet);
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
	
	torusData.torusAttributeSet = Q3AttributeSet_New();
	if let tas = torusData.torusAttributeSet {
		Q3AttributeSet_Add(tas,
						   kQ3AttributeTypeDiffuseColor.rawValue,
						   &color);
	}
	
	defer {
		// Clean up
		if let tas = torusData.torusAttributeSet {
			Q3Object_Dispose(tas);
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
		Q3AttributeSet_Add(atts, kQ3AttributeTypeSurfaceShader.rawValue, &theShader );
		Q3Object_Dispose(theShader)
	}
	return atts;
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

	let iter = CQ3Group(group: decomp, type: kQ3GeometryTypeTriMesh);
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
