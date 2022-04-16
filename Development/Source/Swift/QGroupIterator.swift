//
//  QGroupIterator.swift
//  Quesa
//
//  Created by C.W. Betts on 4/16/22.
//

import Foundation
import Quesa.QuesaGroup

public class CQ3Object {
	public let rawValue: TQ3Object
	public init?(_ inObject: TQ3Object?) {
		guard let inObject = inObject else {
			return nil
		}

		rawValue = inObject
	}
	
	deinit {
		Q3Object_Dispose(rawValue)
	}
}

public struct CQ3Group: Sequence {
	
	fileprivate var mGroup: TQ3GroupObject
	fileprivate var mType: TQ3ObjectType

	/// - parameter inGroup:		A group object.
	/// - parameter inType:		A type of object to iterate over.
	/// Optional, defaults to `kQ3ObjectTypeShared`.
	public init(group inGroup: TQ3GroupObject, type inType: TQ3ObjectType = kQ3ObjectTypeShared) {
		mGroup = inGroup
		mType = inType
	}

	public func makeIterator() -> GroupIterator {
		return GroupIterator(self)
	}
}

/// Class to simplify iterating through a Quesa group.
/// @discussion
/// Example:
///
///     var iter = GroupIterator(aGroup, kQ3ShapeTypeGeometry)
///     for theItem in iter {
///         // do something with theItem...
///     }
public struct GroupIterator: IteratorProtocol {
	private var mGroup: TQ3GroupObject
	private var mType: TQ3ObjectType
	/// the position of the member most recently returned by `next()`.
	public private(set) var position: TQ3GroupPosition? = nil

	init(_ group: CQ3Group) {
		self.init(group: group.mGroup, type: group.mType)
	}
	
	/// - parameter inGroup:		A group object.
	/// - parameter inType:		A type of object to iterate over.
	/// Optional, defaults to `kQ3ObjectTypeShared`.
	public init(group inGroup: TQ3GroupObject, type inType: TQ3ObjectType = kQ3ObjectTypeShared) {
		mGroup = inGroup
		mType = inType
	}
	
	public typealias Element = CQ3Object
	
	public mutating func next() -> CQ3Object? {
		var theStatus: TQ3Status = kQ3Failure
		if position == nil {
			theStatus = Q3Group_GetFirstPositionOfType(
				mGroup, mType, &position);
		} else {
			theStatus = Q3Group_GetNextPositionOfType(
				mGroup, mType, &position);
		}

		if theStatus == kQ3Failure {
			position = nil;
		}
		var theObject: TQ3Object? = nil
		if let mPos = position {
			Q3Group_GetPositionObject( mGroup, mPos,
				&theObject );
		}
		return CQ3Object(theObject)
	}
}
