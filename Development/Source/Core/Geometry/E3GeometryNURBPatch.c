/*  NAME:
        E3GeometryNURBPatch.c

    DESCRIPTION:
        Implementation of Quesa Pixmap Marker geometry class.

    COPYRIGHT:
        Quesa Copyright � 1999-2000, Quesa Developers.
        
        For the list of Quesa Developers, and contact details, see:
        
            Documentation/contributors.html

        For the current version of Quesa, see:

        	<http://www.quesa.org/>

		This library is free software; you can redistribute it and/or
		modify it under the terms of the GNU Lesser General Public
		License as published by the Free Software Foundation; either
		version 2 of the License, or (at your option) any later version.

		This library is distributed in the hope that it will be useful,
		but WITHOUT ANY WARRANTY; without even the implied warranty of
		MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
		Lesser General Public License for more details.

		You should have received a copy of the GNU Lesser General Public
		License along with this library; if not, write to the Free Software
		Foundation Inc, 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
    ___________________________________________________________________________
*/
//=============================================================================
//      Include files
//-----------------------------------------------------------------------------
#include "E3Prefix.h"
#include "E3View.h"
#include "E3Geometry.h"
#include "E3GeometryNURBPatch.h"





//=============================================================================
//      Internal functions
//-----------------------------------------------------------------------------
//      e3geom_nurbpatch_new : NURBPatch new method.
//-----------------------------------------------------------------------------
static TQ3Status
e3geom_nurbpatch_new(TQ3Object theObject, void *privateData, const void *paramData)
{	TQ3NURBPatchData		*instanceData  = (TQ3NURBPatchData *)       privateData;
	const TQ3NURBPatchData	*nurbpatchData = (const TQ3NURBPatchData *) paramData;
#pragma unused(theObject)



	// Initialise our instance data
	return(kQ3Success);
}





//=============================================================================
//      e3geom_nurbpatch_delete : NURBPatch delete method.
//-----------------------------------------------------------------------------
static void
e3geom_nurbpatch_delete(TQ3Object theObject, void *privateData)
{	TQ3NURBPatchData		*instanceData = (TQ3NURBPatchData *) privateData;
#pragma unused(theObject)



	// Dispose of our instance data
}





//=============================================================================
//      e3geom_nurbpatch_duplicate : NURBPatch duplicate method.
//-----------------------------------------------------------------------------
static TQ3Status
e3geom_nurbpatch_duplicate(TQ3Object fromObject, const void *fromPrivateData,
						  TQ3Object toObject,   void       *toPrivateData)
{	const TQ3NURBPatchData	*fromInstanceData = (const TQ3NURBPatchData *) fromPrivateData;
	TQ3NURBPatchData			*toInstanceData   = (TQ3NURBPatchData *)       toPrivateData;
	TQ3Status				qd3dStatus;
#pragma unused(fromObject)
#pragma unused(toObject)



	// Validate our parameters
	Q3_REQUIRE_OR_RESULT(Q3_VALID_PTR(fromObject),      kQ3Failure);
	Q3_REQUIRE_OR_RESULT(Q3_VALID_PTR(fromPrivateData), kQ3Failure);
	Q3_REQUIRE_OR_RESULT(Q3_VALID_PTR(toObject),        kQ3Failure);
	Q3_REQUIRE_OR_RESULT(Q3_VALID_PTR(toPrivateData),   kQ3Failure);



	// Initialise the instance data of the new object
	qd3dStatus = kQ3Success;



	// Handle failure
	if (qd3dStatus != kQ3Success)
		;

	return(qd3dStatus);
}





//=============================================================================
//      e3geom_nurbpatch_cache_new : NURBPatch cache new method.
//-----------------------------------------------------------------------------
static TQ3Object
e3geom_nurbpatch_cache_new(TQ3ViewObject theView, TQ3GeometryObject theGeom, const TQ3NURBPatchData *geomData)
{	TQ3GroupObject		theGroup;
#pragma unused(theView)



	// Create a group to hold the cached geometry
	theGroup = Q3DisplayGroup_New();
	if (theGroup == NULL)
		return(NULL);



	// Add the cached form to the group



	// Finish off the group state (in-line, since we don't make any view state changes)
	Q3DisplayGroup_SetState(theGroup, kQ3DisplayGroupStateMaskIsInline |
									  kQ3DisplayGroupStateMaskIsDrawn  |
									  kQ3DisplayGroupStateMaskIsPicked);

	return(theGroup);
}





//=============================================================================
//      e3geom_nurbpatch_pick : NURBPatch picking method.
//-----------------------------------------------------------------------------
static TQ3Status
e3geom_nurbpatch_pick(TQ3ViewObject theView, TQ3ObjectType objectType, TQ3Object theObject, const void *objectData)
{
#pragma unused(objectType)



	// To be implemented...
	return(kQ3Failure);
}





//=============================================================================
//      e3geom_nurbpatch_bounds : NURBPatch bounds method.
//-----------------------------------------------------------------------------
static TQ3Status
e3geom_nurbpatch_bounds(TQ3ViewObject theView, TQ3ObjectType objectType, TQ3Object theObject, const void *objectData)
{	const TQ3NURBPatchData			*instanceData = (const TQ3NURBPatchData *) objectData;
#pragma unused(objectType)
#pragma unused(theObject)



	// Update the bounds
	
	return(kQ3Success);
}





//=============================================================================
//      e3geom_nurbpatch_get_attribute : NURBPatch get attribute set pointer.
//-----------------------------------------------------------------------------
static TQ3AttributeSet *
e3geom_nurbpatch_get_attribute(TQ3GeometryObject theObject)
{	TQ3NURBPatchData		*instanceData = (TQ3NURBPatchData *) theObject->instanceData;



	// Return the address of the geometry attribute set
	return(NULL);
}





//=============================================================================
//      e3geom_nurbpatch_metahandler : NURBPatch metahandler.
//-----------------------------------------------------------------------------
static TQ3XFunctionPointer
e3geom_nurbpatch_metahandler(TQ3XMethodType methodType)
{	TQ3XFunctionPointer		theMethod = NULL;



	// Return our methods
	switch (methodType) {
		case kQ3XMethodTypeObjectNew:
			theMethod = (TQ3XFunctionPointer) e3geom_nurbpatch_new;
			break;

		case kQ3XMethodTypeObjectDelete:
			theMethod = (TQ3XFunctionPointer) e3geom_nurbpatch_delete;
			break;

		case kQ3XMethodTypeObjectDuplicate:
			theMethod = (TQ3XFunctionPointer) e3geom_nurbpatch_duplicate;
			break;

		case kQ3XMethodTypeGeomCacheNew:
			theMethod = (TQ3XFunctionPointer) e3geom_nurbpatch_cache_new;
			break;

		case kQ3XMethodTypeObjectSubmitPick:
			theMethod = (TQ3XFunctionPointer) e3geom_nurbpatch_pick;
			break;

		case kQ3XMethodTypeObjectSubmitBounds:
			theMethod = (TQ3XFunctionPointer) e3geom_nurbpatch_bounds;
			break;
		
		case kQ3XMethodTypeGeomGetAttribute:
			theMethod = (TQ3XFunctionPointer) e3geom_nurbpatch_get_attribute;
			break;
		
		case kQ3XMethodTypeGeomUsesSubdivision:
			theMethod = (TQ3XFunctionPointer) kQ3True;
			break;
		}
	
	return(theMethod);
}





//=============================================================================
//      Public functions
//-----------------------------------------------------------------------------
//      E3GeometryNURBPatch_RegisterClass : Register the class.
//-----------------------------------------------------------------------------
#pragma mark -
TQ3Status
E3GeometryNURBPatch_RegisterClass(void)
{	TQ3Status		qd3dStatus;



	// Register the class
	qd3dStatus = E3ClassTree_RegisterClass(kQ3ShapeTypeGeometry,
											kQ3GeometryTypeNURBPatch,
											kQ3ClassNameGeometryNURBPatch,
											e3geom_nurbpatch_metahandler,
											sizeof(TQ3NURBPatchData));

	return(qd3dStatus);
}





//=============================================================================
//      E3GeometryNURBPatch_UnregisterClass : Unregister the class.
//-----------------------------------------------------------------------------
TQ3Status
E3GeometryNURBPatch_UnregisterClass(void)
{	TQ3Status		qd3dStatus;



	// Unregister the class
	qd3dStatus = E3ClassTree_UnregisterClass(kQ3GeometryTypeNURBPatch, kQ3True);
	
	return(qd3dStatus);
}





//=============================================================================
//      E3NURBPatch_New : Create a NURB patch object.
//-----------------------------------------------------------------------------
#pragma mark -
TQ3GeometryObject
E3NURBPatch_New(const TQ3NURBPatchData *nurbPatchData)
{	TQ3Object		theObject;



	// Create the object
	theObject = E3ClassTree_CreateInstance(kQ3GeometryTypeNURBPatch, kQ3False, nurbPatchData);
	return(theObject);
}





//=============================================================================
//      E3NURBPatch_Submit : Submit a NURB patch.
//-----------------------------------------------------------------------------
TQ3Status
E3NURBPatch_Submit(const TQ3NURBPatchData *nurbPatchData, TQ3ViewObject theView)
{	TQ3Status		qd3dStatus;



	// Submit the geometry
	qd3dStatus = E3View_SubmitImmediate(theView, kQ3GeometryTypeNURBPatch, nurbPatchData);
	return(qd3dStatus);
}





//=============================================================================
//      E3NURBPatch_SetData : One-line description of the method.
//-----------------------------------------------------------------------------
//		Note : More detailed comments can be placed here if required.
//-----------------------------------------------------------------------------
TQ3Status
E3NURBPatch_SetData(TQ3GeometryObject nurbPatch, const TQ3NURBPatchData *nurbPatchData)
{


	// To be implemented...
	Q3Shared_Edited(nurbPatch);
	return(kQ3Failure);
}





//=============================================================================
//      E3NURBPatch_GetData : One-line description of the method.
//-----------------------------------------------------------------------------
//		Note : More detailed comments can be placed here if required.
//-----------------------------------------------------------------------------
TQ3Status
E3NURBPatch_GetData(TQ3GeometryObject nurbPatch, TQ3NURBPatchData *nurbPatchData)
{


	// To be implemented...
	return(kQ3Failure);
}





//=============================================================================
//      E3NURBPatch_SetControlPoint : One-line description of the method.
//-----------------------------------------------------------------------------
//		Note : More detailed comments can be placed here if required.
//-----------------------------------------------------------------------------
TQ3Status
E3NURBPatch_SetControlPoint(TQ3GeometryObject nurbPatch, unsigned long rowIndex, unsigned long columnIndex, const TQ3RationalPoint4D *point4D)
{


	// To be implemented...
	Q3Shared_Edited(nurbPatch);
	return(kQ3Failure);
}





//=============================================================================
//      E3NURBPatch_GetControlPoint : One-line description of the method.
//-----------------------------------------------------------------------------
//		Note : More detailed comments can be placed here if required.
//-----------------------------------------------------------------------------
TQ3Status
E3NURBPatch_GetControlPoint(TQ3GeometryObject nurbPatch, unsigned long rowIndex, unsigned long columnIndex, TQ3RationalPoint4D *point4D)
{


	// To be implemented...
	return(kQ3Failure);
}





//=============================================================================
//      E3NURBPatch_SetUKnot : One-line description of the method.
//-----------------------------------------------------------------------------
//		Note : More detailed comments can be placed here if required.
//-----------------------------------------------------------------------------
TQ3Status
E3NURBPatch_SetUKnot(TQ3GeometryObject nurbPatch, unsigned long knotIndex, float knotValue)
{


	// To be implemented...
	Q3Shared_Edited(nurbPatch);
	return(kQ3Failure);
}





//=============================================================================
//      E3NURBPatch_SetVKnot : One-line description of the method.
//-----------------------------------------------------------------------------
//		Note : More detailed comments can be placed here if required.
//-----------------------------------------------------------------------------
TQ3Status
E3NURBPatch_SetVKnot(TQ3GeometryObject nurbPatch, unsigned long knotIndex, float knotValue)
{


	// To be implemented...
	Q3Shared_Edited(nurbPatch);
	return(kQ3Failure);
}





//=============================================================================
//      E3NURBPatch_GetUKnot : One-line description of the method.
//-----------------------------------------------------------------------------
//		Note : More detailed comments can be placed here if required.
//-----------------------------------------------------------------------------
TQ3Status
E3NURBPatch_GetUKnot(TQ3GeometryObject nurbPatch, unsigned long knotIndex, float *knotValue)
{


	// To be implemented...
	return(kQ3Failure);
}





//=============================================================================
//      E3NURBPatch_GetVKnot : One-line description of the method.
//-----------------------------------------------------------------------------
//		Note : More detailed comments can be placed here if required.
//-----------------------------------------------------------------------------
TQ3Status
E3NURBPatch_GetVKnot(TQ3GeometryObject nurbPatch, unsigned long knotIndex, float *knotValue)
{


	// To be implemented...
	return(kQ3Failure);
}





//=============================================================================
//      E3NURBPatch_EmptyData : One-line description of the method.
//-----------------------------------------------------------------------------
//		Note : More detailed comments can be placed here if required.
//-----------------------------------------------------------------------------
TQ3Status
E3NURBPatch_EmptyData(TQ3NURBPatchData *nurbPatchData)
{


	// To be implemented...
	return(kQ3Failure);
}



