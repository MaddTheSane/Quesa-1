//
//  QMath.swift
//  QuesaSwift
//
//  Created by C.W. Betts on 3/13/19.
//

import Foundation
import Quesa.QuesaMath

// MARK: - Scalar Multiplication

/// point `=` scalar `*` point (not usual in math, but useful in 3D computing)
@inlinable public func *( _ inScalar: Float, inVec:  TQ3Point3D ) -> TQ3Point3D {
	return TQ3Point3D(x: inVec.x * inScalar, y: inVec.y * inScalar, z: inVec.z * inScalar)
}

/// point `=` scalar `*` point (not usual in math, but useful in 3D computing)
@inlinable public func *( _ inScalar: Float, _ inVec: TQ3Point2D ) -> TQ3Point2D {
	return TQ3Point2D(x: inVec.x * inScalar, y: inVec.y * inScalar)
}


// MARK: - Additive Operations

/// pt = pt + vector
@inlinable public func +(_ inPt2: TQ3Point3D, _ inVec2: TQ3Vector3D  ) -> TQ3Point3D {
	return TQ3Point3D(x: inPt2.x + inVec2.x, y: inPt2.y + inVec2.y, z: inPt2.z + inVec2.z)
}

/// pt = pt + vector [2D]
@inlinable public func +(_ inPt2: TQ3Point2D, _ inVec2: TQ3Vector2D) -> TQ3Point2D {
	return TQ3Point2D(x: inPt2.x + inVec2.x, y: inPt2.y + inVec2.y)
}

/// pt = pt - vector
@inlinable public func -(_ inPt2: TQ3Point3D, _ inVec2: TQ3Vector3D) -> TQ3Point3D {
	let rx = (inPt2).x - (inVec2).x
	let ry = (inPt2).y - (inVec2).y
	let rz = (inPt2).z - (inVec2).z

	return TQ3Point3D(x: rx, y: ry, z: rz)
}

/// pt = pt - vector [2D]
@inlinable public func -(_ inPt2: TQ3Point2D, _ inVec2: TQ3Vector2D) -> TQ3Point2D {
	let rx = inPt2.x - inVec2.x
	let ry = inPt2.y - inVec2.y

	return TQ3Point2D(x: rx, y: ry)
}

/// pt += vector
@inlinable public func +=(_ ioA: inout TQ3Point3D, _ inBa: TQ3Vector3D) {
	ioA.x += inBa.x
	ioA.y += inBa.y
	ioA.z += inBa.z
}

/// pt -= vector
@inlinable public func -=(_ ioA: inout TQ3Point3D, _ inBa: TQ3Vector3D) {
	ioA.x -= inBa.x
	ioA.y -= inBa.y
	ioA.z -= inBa.z
}

/// pt = pt + pt (useful for weighted averages)
@inlinable public func +( _ inA: TQ3Point3D, _ inB: TQ3Point3D) -> TQ3Point3D {
	return TQ3Point3D(x: inA.x + inB.x, y: inA.y + inB.y, z: inA.z + inB.z)
}

/// pt = pt + pt (useful for weighted averages) [2D]
@inlinable public func +( _ inA: TQ3Point2D, _ inB: TQ3Point2D) -> TQ3Point2D {
	return TQ3Point2D(x: inA.x + inB.x, y: inA.y + inB.y)
}


// MARK: - Matrix Operations

/*
// pt * matrix (transform point)
inline TQ3Point3D operator*( const TQ3Point3D& inPt, const TQ3Matrix4x4& inMat )
{
TQ3Point3D result;
Q3Point3D_Transform( &inPt, &inMat, &result );
return result;
}

// pt * matrix (transform rational point)
inline TQ3RationalPoint4D operator*( const TQ3RationalPoint4D& inPt, const TQ3Matrix4x4& inMat )
{
TQ3RationalPoint4D result;
Q3RationalPoint4D_Transform( &inPt, &inMat, &result );
return result;
}

// pt *= matrix (transform point)
inline TQ3Point3D& operator*=( TQ3Point3D& ioPt, const TQ3Matrix4x4& inMat )
{
Q3Point3D_Transform( &ioPt, &inMat, &ioPt );
return ioPt;
}

// vector * matrix (transform vector)
inline TQ3Vector3D operator*( const TQ3Vector3D& inVec, const TQ3Matrix4x4& inMat )
{
TQ3Vector3D result;
Q3Vector3D_Transform( &inVec, &inMat, &result );
return result;
}

// vector *= matrix (transform vector)
inline TQ3Vector3D& operator*=( TQ3Vector3D& ioVec, const TQ3Matrix4x4& inMat )
{
Q3Vector3D_Transform( &ioVec, &inMat, &ioVec );
return ioVec;
}
*/

extension TQ3Matrix4x4: Equatable {
	/// Exact equality (is this what you really want?) of 4x4 matrices
	///
	/// Note that this differs from SIMD's `==`.
	@inlinable public static func == (one: TQ3Matrix4x4, two: TQ3Matrix4x4) -> Bool {
		return one.value.0.0 == two.value.0.0 &&
		(one.value.0.1 == two.value.0.1) &&
		(one.value.0.2 == two.value.0.2) &&
		(one.value.0.3 == two.value.0.3) &&
		(one.value.1.0 == two.value.1.0) &&
		(one.value.1.1 == two.value.1.1) &&
		(one.value.1.2 == two.value.1.2) &&
		(one.value.1.3 == two.value.1.3) &&
		(one.value.2.0 == two.value.2.0) &&
		(one.value.2.1 == two.value.2.1) &&
		(one.value.2.2 == two.value.2.2) &&
		(one.value.2.3 == two.value.2.3) &&
		(one.value.3.0 == two.value.3.0) &&
		(one.value.3.1 == two.value.3.1) &&
		(one.value.3.2 == two.value.3.2) &&
		(one.value.3.3 == two.value.3.3)
	}
	
	/// matrix `*` matrix
	@inlinable public static func *(_ inMata: TQ3Matrix4x4, _ inMat2a: TQ3Matrix4x4) -> TQ3Matrix4x4 {
		var result = TQ3Matrix4x4(); var inMat1 = inMata; var inMat2 = inMat2a
		Q3Matrix4x4_Multiply( &inMat1, &inMat2, &result )
		return result
	}

	/// matrix `*=` matrix
	@inlinable public static func *=(_ ioMat: inout TQ3Matrix4x4 , _ inMat2a: TQ3Matrix4x4) {
		var io = TQ3Matrix4x4(); var inMat2 = inMat2a;
		Q3Matrix4x4_Multiply( &ioMat, &inMat2, &io )
		ioMat = io
	}
}

// MARK: - Common Functions

public extension TQ3RationalPoint4D {
	init(toRational4D: TQ3Point3D) {
		self = TQ3RationalPoint4D(x: toRational4D.x, y: toRational4D.y, z: toRational4D.z, w: 1)
	}

	init(toRational4D: TQ3Vector3D) {
		self = TQ3RationalPoint4D(x: toRational4D.x, y: toRational4D.y, z: toRational4D.z, w: 0)
	}
}

@inlinable public func cross(_ inAb: TQ3Vector3D, _ inBb: TQ3Vector3D) -> TQ3Vector3D {
	let rx = ((inAb).y * (inBb).z) - ((inAb).z * (inBb).y)
	let ry = ((inAb).z * (inBb).x) - ((inAb).x * (inBb).z)
	let rz = ((inAb).x * (inBb).y) - ((inAb).y * (inBb).x)
	return TQ3Vector3D(x: rx, y: ry, z: rz)
}

@inlinable public func dot(_ inA: TQ3Vector3D, _ inB: TQ3Vector3D) -> Float {
	return ((inA).x * (inB).x) +
		((inA).y * (inB).y) +
		((inA).z * (inB).z)
}

@inlinable public func dot(_ inA: TQ3Vector2D, _ inB: TQ3Vector2D) -> Float {
	return (inA.x * inB.x) +
		(inA.y * inB.y)
}

public extension TQ3Matrix4x4 {
	var inverse: TQ3Matrix4x4 {
		var result = TQ3Matrix4x4(); var inMtx = self;
		Q3Matrix4x4_Invert( &inMtx, &result )
		return result
	}
	
	mutating func invert() {
		var inMtx = self
		Q3Matrix4x4_Invert(&inMtx, &self)
	}
}

@inlinable public func Q3Math_DegreesToRadians(_ x: Float) -> Float {
	return ((x) *  kQ3Pi / 180.0)
}

@inlinable public func Q3Math_RadiansToDegrees(_ x: Float) -> Float {
	return ((x) * 180.0 / kQ3Pi)
}

public extension TQ3Vector2D {
	/// vector `=` vector `*` scalar
	@inlinable static func *(_ inVec: TQ3Vector2D, _ inScalar: Float) -> TQ3Vector2D {
		return TQ3Vector2D(x: inVec.x * inScalar, y: inVec.y * inScalar)
	}
	
	/// vector = - vector (unary minus)
	@inlinable static prefix func -(inVec: TQ3Vector2D) -> TQ3Vector2D {
		return TQ3Vector2D(x: -inVec.x, y: -inVec.y)
	}

	@inlinable var lengthSquared: Float {
		let toRet = (x * x) + (y * y)
		return toRet
	}
	
	@inlinable var length: Float {
		return sqrt(lengthSquared)
	}
	
	/// vector `=` scalar `*` vector
	@inlinable static func *(_ inScalar: Float, _ inVec: TQ3Vector2D) -> TQ3Vector2D {
		return TQ3Vector2D(x: inVec.x * inScalar, y: inVec.y * inScalar)
	}

	/// vector `*=` scalar
	@inlinable static func *=(ioA: inout TQ3Vector2D, inScalar: Float) {
		let ioB = inScalar * ioA
		ioA = ioB
	}
	
	/// vector = vector + vector [2D]
	@inlinable static func + (_ inAa: TQ3Vector2D, _ inBa: TQ3Vector2D) -> TQ3Vector2D {
		return TQ3Vector2D(x: inAa.x + inBa.x, y: inAa.y + inBa.y)
	}

	/// vector = vector - vector [2D]
	@inlinable static func - (_ inAa: TQ3Vector2D, _ inBa: TQ3Vector2D) -> TQ3Vector2D {
		return TQ3Vector2D(x: inAa.x - inBa.x, y: inAa.y - inBa.y)
	}
}

public extension TQ3Vector3D {
	@inlinable mutating func normalize() {
		let theLength = self.length + kQ3MinFloat
		self *= (1.0 / theLength)
	}
	
	@inlinable var normalized: TQ3Vector3D {
		let theLength = self.length + kQ3MinFloat
		return self * (1.0 / theLength)
	}
	
	@inlinable var length: Float {
		return sqrt(lengthSquared)
	}
	
	@inlinable var lengthSquared: Float {
		let toRet = (x * x) + (y * y) + (z * z)
		return toRet
	}
	
	/// vector `=` vector `*` scalar
	@inlinable static func *(_ inVec: TQ3Vector3D, _ inScalar: Float) -> TQ3Vector3D {
		return TQ3Vector3D(x: inVec.x * inScalar, y: inVec.y * inScalar, z: inVec.z * inScalar)
	}
	
	/// vector `=` scalar `*` vector
	@inlinable static func *(_ inScalar: Float, _ inVec: TQ3Vector3D) -> TQ3Vector3D {
		return TQ3Vector3D(x: inVec.x * inScalar, y: inVec.y * inScalar, z: inVec.z * inScalar)
	}
	
	/// vector = vector + vector
	@inlinable static func + (_ inAa: TQ3Vector3D, _ inBa: TQ3Vector3D) -> TQ3Vector3D {
		return TQ3Vector3D(x: inAa.x + inBa.x, y: inAa.y + inBa.y, z: inAa.z + inBa.z)
	}
	
	/// vector = vector - vector
	@inlinable static func - (_ inAa: TQ3Vector3D, _ inBa: TQ3Vector3D) -> TQ3Vector3D {
		return TQ3Vector3D(x: inAa.x - inBa.x, y: inAa.y - inBa.y, z: inAa.z - inBa.z)
	}

	/// vector += vector
	@inlinable static func +=(_ ioA: inout TQ3Vector3D, _ inBa: TQ3Vector3D) {
		ioA.x += inBa.x
		ioA.y += inBa.y
		ioA.z += inBa.z
	}

	/// vector -= vector
	@inlinable static func -=(_ ioA: inout TQ3Vector3D, _ inBa: TQ3Vector3D) {
		ioA.x -= inBa.x
		ioA.y -= inBa.y
		ioA.z -= inBa.z
	}

	/// vector `*=` scalar
	@inlinable static func *=(_ ioA: inout TQ3Vector3D, _ inScalar: Float) {
		let ioB = inScalar * ioA
		ioA = ioB
	}

	/// vector = - vector (unary minus)
	@inlinable static prefix func -(_ inVec: TQ3Vector3D) -> TQ3Vector3D {
		return TQ3Vector3D(x: -inVec.x, y: -inVec.y, z: -inVec.z)
	}
}
