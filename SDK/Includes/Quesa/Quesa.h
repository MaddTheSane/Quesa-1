/*! @header Quesa.h
        Declares the fundamental Quesa types and functions.
 */
/*  NAME:
        Quesa.h

    DESCRIPTION:
        Quesa public header.

    COPYRIGHT:
        Quesa Copyright � 1999-2001, Quesa Developers.
        
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
#ifndef QUESA_HDR
#define QUESA_HDR
//=============================================================================
//      Auto-discovery
//-----------------------------------------------------------------------------
//      Note :  Since we normally use a fairly well defined set of compilers,
//              we can attempt to determine what the correct platform is by
//              magic.
//-----------------------------------------------------------------------------
// Mac OS
#if ((defined(__MWERKS__) && macintosh) || (defined(MPW_CPLUS) || defined(MPW_C)))
    #ifndef QUESA_OS_MACINTOSH
        #define QUESA_OS_MACINTOSH              1
    #endif
#endif


// Windows
#if defined(_MSC_VER)
    #ifndef QUESA_OS_WIN32
        #define QUESA_OS_WIN32                  1
    #endif
#endif


// Be
#if defined(__dest_os) && defined(__be_os) && (__dest_os == __be_os)
    #ifndef QUESA_OS_BE
        #define QUESA_OS_BE                     1
    #endif
#endif




//=============================================================================
//      Platform selection
//-----------------------------------------------------------------------------
//      Note :  Build systems are responsible for defining one QUESA_OS_xxxx
//              constant, depending on the current platform.
//
//              The other platform values are then set to 0 here.
//-----------------------------------------------------------------------------
#ifdef QUESA_OS_MACINTOSH
    #undef  QUESA_OS_MACINTOSH
    #define QUESA_OS_MACINTOSH                  1
#else
    #define QUESA_OS_MACINTOSH                  0
#endif

#ifdef QUESA_OS_WIN32
    #undef  QUESA_OS_WIN32
    #define QUESA_OS_WIN32                      1
#else
    #define QUESA_OS_WIN32                      0
#endif

#ifdef QUESA_OS_UNIX
    #undef  QUESA_OS_UNIX
    #define QUESA_OS_UNIX                       1
#else
    #define QUESA_OS_UNIX                       0
#endif

#ifdef QUESA_OS_BE
    #undef  QUESA_OS_BE
    #define QUESA_OS_BE                         1
#else
    #define QUESA_OS_BE                         0
#endif

#ifdef QUESA_OS_COCOA
    #undef  QUESA_OS_COCOA
    #define QUESA_OS_COCOA                      1
#else
    #define QUESA_OS_COCOA                      0
#endif

#if (!QUESA_OS_MACINTOSH && \
     !QUESA_OS_WIN32     && \
     !QUESA_OS_UNIX      && \
     !QUESA_OS_BE        && \
     !QUESA_OS_COCOA)
    #error Target OS not selected!
#endif





//=============================================================================
//      Platform specific pre-amble
//-----------------------------------------------------------------------------
// Mac specific
#if QUESA_OS_MACINTOSH
    // Build constants
    #define QUESA_HOST_IS_BIG_ENDIAN            1
    #define QUESA_SUPPORT_QUICKTIME             1
    #if defined(__GNUC__) && (defined(__APPLE_CPP__) || defined(__APPLE_CC__) || defined(__NEXT_CPP__))
        #define QUESA_UH_IN_FRAMEWORKS          1
    #else
        #define QUESA_UH_IN_FRAMEWORKS          0
    #endif


    // Includes
    #if QUESA_UH_IN_FRAMEWORKS
        #include <HIToolbox/Dialogs.h>
        #include <CarbonCore/MacTypes.h>
    #else
        #include <Dialogs.h>
        #include <MacTypes.h>
    #endif


    // Ensure compiler settings match QD3D, to be binary compatible
    #pragma options        align=power
    #pragma enumsalwaysint on
#endif // QUESA_OS_MACINTOSH


// Windows specific
#if QUESA_OS_WIN32
    // Build constants
    #define QUESA_HOST_IS_BIG_ENDIAN            0
    #ifndef QUESA_SUPPORT_QUICKTIME
        #define QUESA_SUPPORT_QUICKTIME         0
    #endif


    // Includes
    #include <Windows.h>


    // Disable unknown #pragma warning for VC++.
    #if _MSC_VER
        #pragma warning(disable:4068)
    #endif


    // If building a DLL, we need to use our own EXTERN_API_C
    #ifdef WIN32_EXPORTING
        #undef  EXTERN_API_C
        #define EXTERN_API_C(_type) __declspec(dllexport) _type __cdecl  
    #endif
#endif // QUESA_OS_WIN32


// Unix specific
#if QUESA_OS_UNIX
    // Build constants
    #ifndef QUESA_HOST_IS_BIG_ENDIAN
        #define QUESA_HOST_IS_BIG_ENDIAN        1
    #endif
    #define QUESA_SUPPORT_QUICKTIME             0
#endif // QUESA_OS_UNIX


// Be specific
#if QUESA_OS_BE
    // Build constants
    #ifndef QUESA_HOST_IS_BIG_ENDIAN
        #define QUESA_HOST_IS_BIG_ENDIAN        1
    #endif
    #define QUESA_SUPPORT_QUICKTIME             0
#endif // QUESA_OS_BE


// Cocoa specific
#if QUESA_OS_COCOA
    // Build constants
    #ifndef QUESA_HOST_IS_BIG_ENDIAN
        #define QUESA_HOST_IS_BIG_ENDIAN        1
    #endif
    #define QUESA_SUPPORT_QUICKTIME             1
#endif // QUESA_OS_COCOA





//=============================================================================
//      Include files
//-----------------------------------------------------------------------------
#if QUESA_SUPPORT_QUICKTIME
    #if QUESA_OS_MACINTOSH && QUESA_UH_IN_FRAMEWORKS
        #include <QuickTime/Movies.h>
    #else
        #include <Movies.h>
    #endif
#endif

// Disable QD3D header
#if defined(__QD3D__)
#error
#endif

#define __QD3D__

#include <stdio.h>





//=============================================================================
//      C++ preamble
//-----------------------------------------------------------------------------
#ifdef __cplusplus
extern "C" {
#endif





//=============================================================================
//      Bootstrap types/macros
//-----------------------------------------------------------------------------
// Types
typedef unsigned long                           TQ3Uns32;
typedef signed long                             TQ3Int32;
typedef TQ3Int32                                TQ3ObjectType;


// Macros
#ifndef CALLBACK_API_C
    #define CALLBACK_API_C(_type, _name)        _type (*_name)
#endif

#ifndef EXTERN_API_C
    #define EXTERN_API_C(_type)                 extern _type
#endif

#define Q3_FOUR_CHARACTER_CONSTANT(_a, _b, _c, _d)          \
        ((TQ3Uns32)                                         \
        ((TQ3Uns32) (_a) << 24) |                           \
        ((TQ3Uns32) (_b) << 16) |                           \
        ((TQ3Uns32) (_c) <<  8) |                           \
        ((TQ3Uns32) (_d)))

#define Q3_OBJECT_TYPE(_a, _b, _c, _d)                      \
        ((TQ3ObjectType)                                    \
        Q3_FOUR_CHARACTER_CONSTANT((_a), (_b), (_c), (_d))) 

#define Q3_METHOD_TYPE(_a, _b, _c, _d)                      \
        ((TQ3ObjectType)                                    \
        Q3_FOUR_CHARACTER_CONSTANT((_a), (_b), (_c), (_d))) 





//=============================================================================
//      Constants
//-----------------------------------------------------------------------------
/*!
 *  @enum
 *      Miscellaneous constants
 *
 *  @constant kQ3StringMaximumLength    Maximum length of TQ3ObjectClassNameString.
 *  @constant kQ3ArrayIndexNULL         NULL array index.
 */
enum {
    kQ3StringMaximumLength                      = 1024,
    kQ3ArrayIndexNULL                           = ~0
};


/*!
 *  @enum
 *      TQ3Language
 *  @discussion
 *      Languages.
 *
 *  @constant kQ3LanguageDefault        Default language for current OS.
 *  @constant kQ3LanguageEnglishUS      US English.
 */
typedef enum {
    kQ3LanguageDefault                          = 0,
    kQ3LanguageEnglishUS                        = 1
} TQ3Language;


/*!
 *  @enum
 *      TQ3Boolean
 *  @discussion
 *      Fundamental boolean type.
 *
 *  @constant kQ3False      False.
 *  @constant kQ3True       True.
 */
typedef enum {
    kQ3False                                    = 0,
    kQ3True                                     = 1
} TQ3Boolean;


/*!
 *  @enum
 *      TQ3Switch
 *  @discussion
 *      Fundamental switch type.
 *
 *  @constant kQ3Off        Off.
 *  @constant kQ3On         On.
 */
typedef enum {
    kQ3Off                                      = 0,
    kQ3On                                       = 1
} TQ3Switch;


/*!
 *  @enum
 *      TQ3Status
 *  @discussion
 *      Fundamental status type.
 *
 *  @constant kQ3Failure    Indicates failure.
 *  @constant kQ3Success    Indicates success
 */
typedef enum {
    kQ3Failure                                  = 0,
    kQ3Success                                  = 1
} TQ3Status;


/*!
 *  @enum
 *      TQ3Axis
 *  @discussion
 *      Fundamental axis type.
 *
 *  @constant kQ3AxisX      Indicates X axis.
 *  @constant kQ3AxisY      Indicates Y axis.
 *  @constant kQ3AxisZ      Indicates Z axis.
 */
typedef enum {
    kQ3AxisX                                    = 0,
    kQ3AxisY                                    = 1,
    kQ3AxisZ                                    = 2
} TQ3Axis;


// Pixel types
typedef enum {
    kQ3PixelTypeRGB32                           = 0,                // Ignore:8, R:8, G:8, B:8
    kQ3PixelTypeARGB32                          = 1,                // Alpha:8,  R:8, G:8, B:8
    kQ3PixelTypeRGB16                           = 2,                // Ignore:1, R:5, G:5, B:5
    kQ3PixelTypeARGB16                          = 3,                // Alpha:1,  R:5, G:5, B:5
    kQ3PixelTypeRGB16_565                       = 4,                //           R:5, G:6, B:5
    kQ3PixelTypeRGB24                           = 5                 //           R:8, G:8, B:8
} TQ3PixelType;


// Byte order
typedef enum {
    kQ3EndianBig                                = 0,
    kQ3EndianLittle                             = 1
} TQ3Endian;


// Surface caps
typedef enum {
    kQ3EndCapNone                               = 0,
    kQ3EndCapMaskTop                            = (1 << 0),
    kQ3EndCapMaskBottom                         = (1 << 1),
    kQ3EndCapMaskInterior                       = (1 << 2)
} TQ3EndCapMasks;


// Elements
enum {
    kQ3ElementTypeNone                          = 0,
    kQ3ElementTypeUnknown                       = 1,
    kQ3ElementTypeSet                           = 2
};


// Bounds
typedef enum {
    kQ3ComputeBoundsExact                       = 0,
    kQ3ComputeBoundsApproximate                 = 1
} TQ3ComputeBounds;


// Object method types
enum {
    kQ3XMethodTypeObjectUnregister              = Q3_METHOD_TYPE('u', 'n', 'r', 'g'),
    kQ3XMethodTypeObjectIsDrawable              = Q3_METHOD_TYPE('i', 's', 'd', 'r')
};


// Object types
enum {
    kQ3ObjectTypeInvalid                        = ((TQ3ObjectType) 0),
    kQ3ObjectTypeView                           = Q3_OBJECT_TYPE('v', 'i', 'e', 'w'),
    kQ3ObjectTypeElement                        = Q3_OBJECT_TYPE('e', 'l', 'm', 'n'),
        kQ3ElementTypeAttribute                 = Q3_OBJECT_TYPE('e', 'a', 't', 't'),
    kQ3ObjectTypePick                           = Q3_OBJECT_TYPE('p', 'i', 'c', 'k'),
        kQ3PickTypeWindowPoint                  = Q3_OBJECT_TYPE('p', 'k', 'w', 'p'),
        kQ3PickTypeWindowRect                   = Q3_OBJECT_TYPE('p', 'k', 'w', 'r'),
        kQ3PickTypeWorldRay                     = Q3_OBJECT_TYPE('p', 'k', 'r', 'y'),
    kQ3ObjectTypeShared                         = Q3_OBJECT_TYPE('s', 'h', 'r', 'd'),
        kQ3SharedTypeRenderer                   = Q3_OBJECT_TYPE('r', 'd', 'd', 'r'),
            kQ3RendererTypeWireFrame            = Q3_OBJECT_TYPE('w', 'r', 'f', 'r'),
            kQ3RendererTypeGeneric              = Q3_OBJECT_TYPE('g', 'n', 'r', 'r'),
            kQ3RendererTypeInteractive          = Q3_OBJECT_TYPE('c', 't', 'w', 'n'),
        kQ3SharedTypeShape                      = Q3_OBJECT_TYPE('s', 'h', 'a', 'p'),
            kQ3ShapeTypeGeometry                = Q3_OBJECT_TYPE('g', 'm', 't', 'r'),
                kQ3GeometryTypeBox              = Q3_OBJECT_TYPE('b', 'o', 'x', ' '),
                kQ3GeometryTypeGeneralPolygon   = Q3_OBJECT_TYPE('g', 'p', 'g', 'n'),
                kQ3GeometryTypeLine             = Q3_OBJECT_TYPE('l', 'i', 'n', 'e'),
                kQ3GeometryTypeMarker           = Q3_OBJECT_TYPE('m', 'r', 'k', 'r'),
                kQ3GeometryTypePixmapMarker     = Q3_OBJECT_TYPE('m', 'r', 'k', 'p'),
                kQ3GeometryTypeMesh             = Q3_OBJECT_TYPE('m', 'e', 's', 'h'),
                kQ3GeometryTypeNURBCurve        = Q3_OBJECT_TYPE('n', 'r', 'b', 'c'),
                kQ3GeometryTypeNURBPatch        = Q3_OBJECT_TYPE('n', 'r', 'b', 'p'),
                kQ3GeometryTypePoint            = Q3_OBJECT_TYPE('p', 'n', 't', ' '),
                kQ3GeometryTypePolygon          = Q3_OBJECT_TYPE('p', 'l', 'y', 'g'),
                kQ3GeometryTypePolyLine         = Q3_OBJECT_TYPE('p', 'l', 'y', 'l'),
                kQ3GeometryTypeTriangle         = Q3_OBJECT_TYPE('t', 'r', 'n', 'g'),
                kQ3GeometryTypeTriGrid          = Q3_OBJECT_TYPE('t', 'r', 'i', 'g'),
                kQ3GeometryTypeCone             = Q3_OBJECT_TYPE('c', 'o', 'n', 'e'),
                kQ3GeometryTypeCylinder         = Q3_OBJECT_TYPE('c', 'y', 'l', 'n'),
                kQ3GeometryTypeDisk             = Q3_OBJECT_TYPE('d', 'i', 's', 'k'),
                kQ3GeometryTypeEllipse          = Q3_OBJECT_TYPE('e', 'l', 'p', 's'),
                kQ3GeometryTypeEllipsoid        = Q3_OBJECT_TYPE('e', 'l', 'p', 'd'),
                kQ3GeometryTypePolyhedron       = Q3_OBJECT_TYPE('p', 'l', 'h', 'd'),
                kQ3GeometryTypeTorus            = Q3_OBJECT_TYPE('t', 'o', 'r', 's'),
                kQ3GeometryTypeTriMesh          = Q3_OBJECT_TYPE('t', 'm', 's', 'h'),
            kQ3ShapeTypeShader                  = Q3_OBJECT_TYPE('s', 'h', 'd', 'r'),
                kQ3ShaderTypeSurface            = Q3_OBJECT_TYPE('s', 'u', 's', 'h'),
                    kQ3SurfaceShaderTypeTexture = Q3_OBJECT_TYPE('t', 'x', 's', 'u'),
                kQ3ShaderTypeIllumination       = Q3_OBJECT_TYPE('i', 'l', 's', 'h'),
                    kQ3IlluminationTypePhong    = Q3_OBJECT_TYPE('p', 'h', 'i', 'l'),
                    kQ3IlluminationTypeLambert  = Q3_OBJECT_TYPE('l', 'm', 'i', 'l'),
                    kQ3IlluminationTypeNULL     = Q3_OBJECT_TYPE('n', 'u', 'i', 'l'),
            kQ3ShapeTypeStyle                   = Q3_OBJECT_TYPE('s', 't', 'y', 'l'),
                kQ3StyleTypeBackfacing          = Q3_OBJECT_TYPE('b', 'c', 'k', 'f'),
                kQ3StyleTypeInterpolation       = Q3_OBJECT_TYPE('i', 'n', 't', 'p'),
                kQ3StyleTypeFill                = Q3_OBJECT_TYPE('f', 'i', 's', 't'),
                kQ3StyleTypePickID              = Q3_OBJECT_TYPE('p', 'k', 'i', 'd'),
                kQ3StyleTypeReceiveShadows      = Q3_OBJECT_TYPE('r', 'c', 's', 'h'),
                kQ3StyleTypeHighlight           = Q3_OBJECT_TYPE('h', 'i', 'g', 'h'),
                kQ3StyleTypeSubdivision         = Q3_OBJECT_TYPE('s', 'b', 'd', 'v'),
                kQ3StyleTypeOrientation         = Q3_OBJECT_TYPE('o', 'f', 'd', 'r'),
                kQ3StyleTypePickParts           = Q3_OBJECT_TYPE('p', 'k', 'p', 't'),
                kQ3StyleTypeAntiAlias           = Q3_OBJECT_TYPE('a', 'n', 't', 'i'),
                kQ3StyleTypeFog                 = Q3_OBJECT_TYPE('f', 'o', 'g', 'g'),
            kQ3ShapeTypeTransform               = Q3_OBJECT_TYPE('x', 'f', 'r', 'm'),
                kQ3TransformTypeMatrix          = Q3_OBJECT_TYPE('m', 't', 'r', 'x'),
                kQ3TransformTypeScale           = Q3_OBJECT_TYPE('s', 'c', 'a', 'l'),
                kQ3TransformTypeTranslate       = Q3_OBJECT_TYPE('t', 'r', 'n', 's'),
                kQ3TransformTypeRotate          = Q3_OBJECT_TYPE('r', 'o', 't', 't'),
                kQ3TransformTypeRotateAboutPoint= Q3_OBJECT_TYPE('r', 't', 'a', 'p'),
                kQ3TransformTypeRotateAboutAxis = Q3_OBJECT_TYPE('r', 't', 'a', 'a'),
                kQ3TransformTypeQuaternion      = Q3_OBJECT_TYPE('q', 't', 'r', 'n'),
                kQ3TransformTypeReset           = Q3_OBJECT_TYPE('r', 's', 'e', 't'),
            kQ3ShapeTypeLight                   = Q3_OBJECT_TYPE('l', 'g', 'h', 't'),
                kQ3LightTypeAmbient             = Q3_OBJECT_TYPE('a', 'm', 'b', 'n'),
                kQ3LightTypeDirectional         = Q3_OBJECT_TYPE('d', 'r', 'c', 't'),
                kQ3LightTypePoint               = Q3_OBJECT_TYPE('p', 'n', 't', 'l'),
                kQ3LightTypeSpot                = Q3_OBJECT_TYPE('s', 'p', 'o', 't'),
            kQ3ShapeTypeCamera                  = Q3_OBJECT_TYPE('c', 'm', 'r', 'a'),
                kQ3CameraTypeOrthographic       = Q3_OBJECT_TYPE('o', 'r', 't', 'h'),
                kQ3CameraTypeViewPlane          = Q3_OBJECT_TYPE('v', 'w', 'p', 'l'),
                kQ3CameraTypeViewAngleAspect    = Q3_OBJECT_TYPE('v', 'a', 'n', 'a'),
            kQ3ShapeTypeStateOperator           = Q3_OBJECT_TYPE('s', 't', 'o', 'p'),
                kQ3StateOperatorTypePush        = Q3_OBJECT_TYPE('p', 'u', 's', 'h'),
                kQ3StateOperatorTypePop         = Q3_OBJECT_TYPE('p', 'o', 'p', ' '),
            kQ3ShapeTypeGroup                   = Q3_OBJECT_TYPE('g', 'r', 'u', 'p'),
                kQ3GroupTypeDisplay             = Q3_OBJECT_TYPE('d', 's', 'p', 'g'),
                    kQ3DisplayGroupTypeOrdered  = Q3_OBJECT_TYPE('o', 'r', 'd', 'g'),
                    kQ3DisplayGroupTypeIOProxy  = Q3_OBJECT_TYPE('i', 'o', 'p', 'x'),
                kQ3GroupTypeLight               = Q3_OBJECT_TYPE('l', 'g', 'h', 'g'),
                kQ3GroupTypeInfo                = Q3_OBJECT_TYPE('i', 'n', 'f', 'o'),
            kQ3ShapeTypeUnknown                 = Q3_OBJECT_TYPE('u', 'n', 'k', 'n'),
                kQ3UnknownTypeText              = Q3_OBJECT_TYPE('u', 'k', 't', 'x'),
                kQ3UnknownTypeBinary            = Q3_OBJECT_TYPE('u', 'k', 'b', 'n'),
            kQ3ShapeTypeReference               = Q3_OBJECT_TYPE('r', 'f', 'r', 'n'),
                kQ3ReferenceTypeExternal        = Q3_OBJECT_TYPE('r', 'f', 'e', 'x'),
        kQ3SharedTypeSet                        = Q3_OBJECT_TYPE('s', 'e', 't', ' '),
            kQ3SetTypeAttribute                 = Q3_OBJECT_TYPE('a', 't', 't', 'r'),
        kQ3SharedTypeDrawContext                = Q3_OBJECT_TYPE('d', 'c', 't', 'x'),
            kQ3DrawContextTypePixmap            = Q3_OBJECT_TYPE('d', 'p', 'x', 'p'),
            kQ3DrawContextTypeMacintosh         = Q3_OBJECT_TYPE('d', 'm', 'a', 'c'),
            kQ3DrawContextTypeCocoa             = Q3_OBJECT_TYPE('d', 'c', 'c', 'o'),
            kQ3DrawContextTypeWin32DC           = Q3_OBJECT_TYPE('d', 'w', '3', '2'),
            kQ3DrawContextTypeDDSurface         = Q3_OBJECT_TYPE('d', 'd', 'd', 's'),
            kQ3DrawContextTypeX11               = Q3_OBJECT_TYPE('d', 'x', '1', '1'),
        kQ3SharedTypeTexture                    = Q3_OBJECT_TYPE('t', 'x', 't', 'r'),
            kQ3TextureTypePixmap                = Q3_OBJECT_TYPE('t', 'x', 'p', 'm'),
            kQ3TextureTypeMipmap                = Q3_OBJECT_TYPE('t', 'x', 'm', 'm'),
            kQ3TextureTypeCompressedPixmap      = Q3_OBJECT_TYPE('t', 'x', 'c', 'p'),
        kQ3SharedTypeFile                       = Q3_OBJECT_TYPE('f', 'i', 'l', 'e'),
        kQ3SharedTypeStorage                    = Q3_OBJECT_TYPE('s', 't', 'r', 'g'),
            kQ3StorageTypeMemory                = Q3_OBJECT_TYPE('m', 'e', 'm', 's'),
                kQ3MemoryStorageTypeHandle      = Q3_OBJECT_TYPE('h', 'n', 'd', 'l'),
            kQ3StorageTypeUnix                  = Q3_OBJECT_TYPE('u', 'x', 's', 't'),
                kQ3UnixStorageTypePath          = Q3_OBJECT_TYPE('u', 'n', 'i', 'x'),
            kQ3StorageTypeMacintosh             = Q3_OBJECT_TYPE('m', 'a', 'c', 'n'),
                kQ3MacintoshStorageTypeFSSpec   = Q3_OBJECT_TYPE('m', 'a', 'c', 'p'),
            kQ3StorageTypeWin32                 = Q3_OBJECT_TYPE('w', 'i', 's', 't'),
        kQ3SharedTypeString                     = Q3_OBJECT_TYPE('s', 't', 'r', 'n'),
            kQ3StringTypeCString                = Q3_OBJECT_TYPE('s', 't', 'r', 'c'),
        kQ3SharedTypeShapePart                  = Q3_OBJECT_TYPE('s', 'p', 'r', 't'),
            kQ3ShapePartTypeMeshPart            = Q3_OBJECT_TYPE('s', 'p', 'm', 'h'),
                kQ3MeshPartTypeMeshFacePart     = Q3_OBJECT_TYPE('m', 'f', 'a', 'c'),
                kQ3MeshPartTypeMeshEdgePart     = Q3_OBJECT_TYPE('m', 'e', 'd', 'g'),
                kQ3MeshPartTypeMeshVertexPart   = Q3_OBJECT_TYPE('m', 'v', 't', 'x'),
        kQ3SharedTypeControllerState            = Q3_OBJECT_TYPE('c', 't', 's', 't'),
        kQ3SharedTypeTracker                    = Q3_OBJECT_TYPE('t', 'r', 'k', 'r'),
        kQ3SharedTypeViewHints                  = Q3_OBJECT_TYPE('v', 'w', 'h', 'n'),
        kQ3SharedTypeEndGroup                   = Q3_OBJECT_TYPE('e', 'n', 'd', 'g')
};





//=============================================================================
//      Types
//-----------------------------------------------------------------------------
// Basic types
typedef unsigned char                           TQ3Uns8;
typedef signed char                             TQ3Int8;
typedef unsigned short                          TQ3Uns16;
typedef signed short                            TQ3Int16;
typedef float                                   TQ3Float32;
typedef double                                  TQ3Float64;
typedef TQ3Uns32                                TQ3Size;

#if QUESA_HOST_IS_BIG_ENDIAN
    typedef struct {
        TQ3Uns32                                hi;
        TQ3Uns32                                lo;
    } TQ3Uns64;
    
    typedef struct {
        TQ3Int32                                hi;
        TQ3Uns32                                lo;
    } TQ3Int64;

#else
    typedef struct {
        TQ3Uns32                                lo;
        TQ3Uns32                                hi;
    } TQ3Uns64;
    
    typedef struct {
        TQ3Uns32                                lo;
        TQ3Int32                                hi;
    } TQ3Int64;
#endif


// Misc types
typedef TQ3Uns32                                TQ3ElementType;
typedef TQ3Uns32                                TQ3XMethodType;
typedef TQ3Uns32                                TQ3EndCap;
typedef struct OpaqueTQ3XObjectClass            *TQ3XObjectClass;
typedef struct OpaqueTQ3GroupPosition           *TQ3GroupPosition;
typedef char                                    TQ3ObjectClassNameString[kQ3StringMaximumLength];
typedef void                                    *TQ3ControllerRef;


// Function types
typedef CALLBACK_API_C(void,                TQ3XFunctionPointer)(
                            void);

typedef CALLBACK_API_C(TQ3XFunctionPointer, TQ3XMetaHandler)(
                            TQ3XMethodType      methodType);


// Object types
typedef struct OpaqueTQ3Object                  *TQ3Object;

typedef TQ3Object                               TQ3ElementObject;
typedef TQ3Object                               TQ3SharedObject;
    typedef TQ3SharedObject                     TQ3RendererObject;
    typedef TQ3SharedObject                     TQ3DrawContextObject;
    typedef TQ3SharedObject                     TQ3SetObject;
        typedef TQ3SetObject                    TQ3AttributeSet;
    typedef TQ3SharedObject                     TQ3FileObject;
    typedef TQ3SharedObject                     TQ3ShapeObject;
        typedef TQ3ShapeObject                  TQ3GroupObject;
            typedef TQ3GroupObject              TQ3DisplayGroupObject;
        typedef TQ3ShapeObject                  TQ3GeometryObject;
        typedef TQ3ShapeObject                  TQ3ShaderObject;
            typedef TQ3ShaderObject             TQ3SurfaceShaderObject;
            typedef TQ3ShaderObject             TQ3IlluminationShaderObject;
        typedef TQ3ShapeObject                  TQ3StyleObject;
        typedef TQ3ShapeObject                  TQ3TransformObject;
        typedef TQ3ShapeObject                  TQ3LightObject;
        typedef TQ3ShapeObject                  TQ3CameraObject;
        typedef TQ3ShapeObject                  TQ3UnknownObject;
        typedef TQ3ShapeObject                  TQ3ReferenceObject;
        typedef TQ3ShapeObject                  TQ3StateOperatorObject;
    typedef TQ3SharedObject                     TQ3ShapePartObject;
        typedef TQ3ShapePartObject              TQ3MeshPartObject;
            typedef TQ3MeshPartObject           TQ3MeshFacePartObject;
            typedef TQ3MeshPartObject           TQ3MeshEdgePartObject;
            typedef TQ3MeshPartObject           TQ3MeshVertexPartObject;
    typedef TQ3SharedObject                     TQ3ControllerStateObject;
    typedef TQ3SharedObject                     TQ3TrackerObject;
    typedef TQ3SharedObject                     TQ3StringObject;
    typedef TQ3SharedObject                     TQ3StorageObject;
    typedef TQ3SharedObject                     TQ3TextureObject;
    typedef TQ3SharedObject                     TQ3ViewHintsObject;
typedef TQ3Object                               TQ3ViewObject;
typedef TQ3Object                               TQ3PickObject;


// Geometric types
/*!
 *  @struct
 *      TQ3Vector2D
 *  @discussion
 *      Fundamental 2D vector type.
 *
 *  @field x                x coordinate.
 *  @field y                y coordinate.
 */
typedef struct {
    float                                       x;
    float                                       y;
} TQ3Vector2D;

/*!
 *  @struct
 *      TQ3Vector3D
 *  @discussion
 *      Fundamental 3D vector type.
 *
 *  @field x                x coordinate.
 *  @field y                y coordinate.
 *  @field z                z coordinate.
 */
typedef struct {
    float                                       x;
    float                                       y;
    float                                       z;
} TQ3Vector3D;

/*!
 *  @struct
 *      TQ3Point2D
 *  @discussion
 *      Fundamental 2D point type.
 *
 *  @field x                x coordinate.
 *  @field y                y coordinate.
 */
typedef struct {
    float                                       x;
    float                                       y;
} TQ3Point2D;

/*!
 *  @struct
 *      TQ3Point3D
 *  @discussion
 *      Fundamental 3D point type.
 *
 *  @field x                x coordinate.
 *  @field y                y coordinate.
 *  @field z                z coordinate.
 */
typedef struct {
    float                                       x;
    float                                       y;
    float                                       z;
} TQ3Point3D;

typedef struct {
    float                                       x;
    float                                       y;
    float                                       w;
} TQ3RationalPoint3D;

typedef struct {
    float                                       x;
    float                                       y;
    float                                       z;
    float                                       w;
} TQ3RationalPoint4D;

typedef struct {
    float                                       w;
    float                                       x;
    float                                       y;
    float                                       z;
} TQ3Quaternion;

typedef struct {
    TQ3Point3D                                  origin;
    TQ3Vector3D                                 direction;
} TQ3Ray3D;

typedef struct {
    float                                       u;
    float                                       v;
} TQ3Param2D;

typedef struct {
    float                                       u;
    float                                       v;
    float                                       w;
} TQ3Param3D;

typedef struct {
    TQ3Vector3D                                 uTangent;
    TQ3Vector3D                                 vTangent;
} TQ3Tangent2D;

typedef struct {
    TQ3Vector3D                                 uTangent;
    TQ3Vector3D                                 vTangent;
    TQ3Vector3D                                 wTangent;
} TQ3Tangent3D;

typedef struct {
    float                                       r;
    float                                       theta;
} TQ3PolarPoint;

typedef struct {
    float                                       rho;
    float                                       theta;
    float                                       phi;
} TQ3SphericalPoint;


// Color types
typedef struct {
    float                                       r;
    float                                       g;
    float                                       b;
} TQ3ColorRGB;

typedef struct {
    float                                       a;
    float                                       r;
    float                                       g;
    float                                       b;
} TQ3ColorARGB;


// Vertex type
typedef struct {
    TQ3Point3D                                  point;
    TQ3AttributeSet                             attributeSet;
} TQ3Vertex3D;


// Matrix types
typedef struct {
    float                                       value[3][3];
} TQ3Matrix3x3;

typedef struct {
    float                                       value[4][4];
} TQ3Matrix4x4;


// Bitmap/Pixmap types
typedef struct {
    void                                        *image;
    TQ3Uns32                                    width;
    TQ3Uns32                                    height;
    TQ3Uns32                                    rowBytes;
    TQ3Uns32                                    pixelSize;
    TQ3PixelType                                pixelType;
    TQ3Endian                                   bitOrder;
    TQ3Endian                                   byteOrder;
} TQ3Pixmap;

typedef struct {
    TQ3StorageObject                            image;
    TQ3Uns32                                    width;
    TQ3Uns32                                    height;
    TQ3Uns32                                    rowBytes;
    TQ3Uns32                                    pixelSize;
    TQ3PixelType                                pixelType;
    TQ3Endian                                   bitOrder;
    TQ3Endian                                   byteOrder;
} TQ3StoragePixmap;

typedef struct {
    TQ3Uns8                                     *image;
    TQ3Uns32                                    width;
    TQ3Uns32                                    height;
    TQ3Uns32                                    rowBytes;
    TQ3Endian                                   bitOrder;
} TQ3Bitmap;

typedef struct {
    TQ3Uns32                                    width;
    TQ3Uns32                                    height;
    TQ3Uns32                                    rowBytes;
    TQ3Uns32                                    offset;
} TQ3MipmapImage;

typedef struct {
    TQ3StorageObject                            image;
    TQ3Boolean                                  useMipmapping;
    TQ3PixelType                                pixelType;
    TQ3Endian                                   bitOrder;
    TQ3Endian                                   byteOrder;
    TQ3Uns32                                    reserved;
    TQ3MipmapImage                              mipmaps[32];
} TQ3Mipmap;

typedef struct {
    TQ3StorageObject                            compressedImage;
    TQ3Endian                                   imageDescByteOrder;
    TQ3StorageObject                            imageDesc;
    TQ3Boolean                                  makeMipmaps;
    TQ3Uns32                                    width;
    TQ3Uns32                                    height;
    TQ3Uns32                                    pixelSize;
    TQ3PixelType                                pixelType;
} TQ3CompressedPixmap;


// Mathematical types
typedef struct {
    TQ3Point2D                                  min;
    TQ3Point2D                                  max;
} TQ3Area;

typedef struct {
    TQ3Vector3D                                 normal;
    float                                       constant;
} TQ3PlaneEquation;

typedef struct {
    TQ3Point3D                                  min;
    TQ3Point3D                                  max;
    TQ3Boolean                                  isEmpty;
} TQ3BoundingBox;

typedef struct {
    TQ3Point3D                                  origin;
    float                                       radius;
    TQ3Boolean                                  isEmpty;
} TQ3BoundingSphere;


// Subclass type
typedef struct {
    TQ3Uns32                                    numClasses;
    TQ3ObjectType                               *classTypes;
} TQ3SubClassData;





//=============================================================================
//      Function prototypes
//-----------------------------------------------------------------------------
/*!
 *  @function
 *      Q3Initialize
 *  @discussion
 *      Initialises Quesa.
 *
 *      Only Q3IsInitialized, Q3GetVersion, and Q3GetReleaseVersion may be
 *      called before the Quesa library is initialised.
 *
 *  @result                 Success or failure of the operation.
 */
EXTERN_API_C ( TQ3Status  )
Q3Initialize (
    void
);



/*!
 *  @function
 *      Q3Exit
 *  @discussion
 *      Shuts down Quesa, and releases any resources allocated by the library.
 *
 *  @result                 Success or failure of the operation.
 */
EXTERN_API_C ( TQ3Status  )
Q3Exit (
    void
);



/*!
 *  @function
 *      Q3IsInitialized
 *  @discussion
 *      Tests to see if Quesa has been initialised or not.
 *
 *  @result                 True or false as Quesa has been initialised or not.
 */
EXTERN_API_C ( TQ3Boolean  )
Q3IsInitialized (
    void
);



/*!
 *  @function
 *      Q3GetVersion
 *  @discussion
 *      Returns the version of Quesa.
 *
 *  @param majorRevision    Receives the major version number.
 *  @param minorRevision    Receives the minor version number.
 *  @result                 Success or failure of the operation.
 */
EXTERN_API_C ( TQ3Status  )
Q3GetVersion (
    TQ3Uns32                      *majorRevision,
    TQ3Uns32                      *minorRevision
);



/*!
 *  @function
 *      Q3GetReleaseVersion
 *  @discussion
 *      Returns the release version of Quesa.
 *
 *      The version number is returned in the format of the first four
 *      bytes of a Mac 'vers' resource. E.g., 1.6.1 would be identified
 *      as 0x01618000.
 *
 *  @param releaseRevision  Receives the release version number.
 *  @result                 Success or failure of the operation.
 */
EXTERN_API_C ( TQ3Status  )
Q3GetReleaseVersion (
    TQ3Uns32                      *releaseRevision
);



/*!
 *  @function
 *      Q3ObjectHierarchy_GetTypeFromString
 *  @discussion
 *      Returns the class type for a class identified by a class name string.
 *
 *  @param objectClassString    The class name of the class to locate.
 *  @param objectClassType      Receives the class type of the class.
 *  @result                     Success or failure of the operation.
 */
EXTERN_API_C ( TQ3Status  )
Q3ObjectHierarchy_GetTypeFromString (
    TQ3ObjectClassNameString      objectClassString,
    TQ3ObjectType                 *objectClassType
);



/*!
 *  @function
 *      Q3ObjectHierarchy_GetStringFromType
 *  @discussion
 *      Returns the class name string for a class identified by a class type.
 *
 *  @param objectClassType      The class type of the class to locate.
 *  @param objectClassString    Receives the class name string of the class.
 *  @result                     Success or failure of the operation.
 */
EXTERN_API_C ( TQ3Status  )
Q3ObjectHierarchy_GetStringFromType (
    TQ3ObjectType                 objectClassType,
    TQ3ObjectClassNameString      objectClassString
);



/*!
 *  @function
 *      Q3ObjectHierarchy_IsTypeRegistered
 *  @discussion
 *      Check to see if a class is registered with Quesa.
 *
 *  @param objectClassType  The class type of the class to check.
 *  @result                 True or false as the class is registered or not.
 */
EXTERN_API_C ( TQ3Boolean  )
Q3ObjectHierarchy_IsTypeRegistered (
    TQ3ObjectType                 objectClassType
);



/*!
 *  @function
 *      Q3ObjectHierarchy_IsNameRegistered
 *  @discussion
 *      Check to see if a class is registered with Quesa.
 *
 *  @param majorRevision    The class name of the class to check.
 *  @result                 True or false as the class is registered or not.
 */
EXTERN_API_C ( TQ3Boolean  )
Q3ObjectHierarchy_IsNameRegistered (
    const char                    *objectClassName
);



/*!
 *  @function
 *      Q3ObjectHierarchy_GetSubClassData
 *  @discussion
 *      Return the immediate sub-classes of a class.
 *
 *      The data returned must be released with a subsequent call to
 *      Q3ObjectHierarchy_EmptySubClassData.
 *
 *  @param objectClassType  The class type of the class to query.
 *  @param subClassData     Receives the immediate sub-classes of the class.
 *  @result                 Success or failure of the operation.
 */
EXTERN_API_C ( TQ3Status  )
Q3ObjectHierarchy_GetSubClassData (
    TQ3ObjectType                 objectClassType,
    TQ3SubClassData               *subClassData
);



/*!
 *  @function
 *      Q3ObjectHierarchy_EmptySubClassData
 *  @discussion
 *      Release the memory allocated by a previous call to
 *      Q3ObjectHierarchy_GetSubClassData.
 *
 *  @param subClassData     The sub-class data to release.
 *  @result                 Success or failure of the operation.
 */
EXTERN_API_C ( TQ3Status  )
Q3ObjectHierarchy_EmptySubClassData (
    TQ3SubClassData               *subClassData
);



/*!
 *  @function
 *      Q3Object_Dispose
 *  @discussion
 *      Disposes of a Quesa object.
 *
 *      Since TQ3Objects are reference counted, this function decrements the
 *      reference count of the object. When the reference count falls to 0,
 *      the object is disposed of.
 *
 *  @param object           The object to dispose.
 *  @result                 Success or failure of the operation.
 */
EXTERN_API_C ( TQ3Status  )
Q3Object_Dispose (
    TQ3Object                     object
);



/*!
 *  @function
 *      Q3Object_Duplicate
 *  @discussion
 *      Duplicates a Quesa object.
 *
 *      Returns a new copy of the object, with a reference count of 1.
 *
 *  @param object           The object to duplicate.
 *  @result                 A new copy of the object.
 */
EXTERN_API_C ( TQ3Object  )
Q3Object_Duplicate (
    TQ3Object                     object
);



/*!
 *  @function
 *      Q3Object_Submit
 *  @discussion
 *      Submit an object to a view.
 *
 *      The object is submitted to the view's current processing loop,
 *      e.g., for rendering, picking, or writing to a file.
 *
 *  @param object           The object to submit.
 *  @param view             The view to submit the object to.
 *  @result                 Success or failure of the operation.
 */
EXTERN_API_C ( TQ3Status  )
Q3Object_Submit (
    TQ3Object                     object,
    TQ3ViewObject                 view
);



/*!
 *  @function
 *      Q3Object_IsDrawable
 *  @discussion
 *      Tests to see if an object is drawable.
 *
 *      Only drawable objects may be submitted to a view's rendering loop.
 *
 *  @param object           The object to test.
 *  @result                 True or false as the object is drawable or not.
 */
EXTERN_API_C ( TQ3Boolean  )
Q3Object_IsDrawable (
    TQ3Object                     object
);



/*!
 *  @function
 *      Q3Object_IsWritable
 *  @discussion
 *      Tests to see if an object is writable.
 *
 *      Only drawable objects may be submitted to a view's writing loop.
 *
 *  @param object           The object to test.
 *  @result                 True or false as the object is writable or not.
 */
EXTERN_API_C ( TQ3Boolean  )
Q3Object_IsWritable (
    TQ3Object                     object,
    TQ3FileObject                 theFile
);



/*!
 *  @function
 *      Q3Object_GetType
 *  @discussion
 *      Returns the top level type of an object.
 *
 *      Returns kQ3ObjectTypeElement, kQ3ObjectTypePick, kQ3ObjectTypeShared,
 *      or kQ3ObjectTypeView. Returns kQ3ObjectTypeInvalid if the object type
 *      is unknown.
 *
 *  @param object           The object to test.
 *  @result                 The top level type of the object.
 */
EXTERN_API_C ( TQ3ObjectType  )
Q3Object_GetType (
    TQ3Object                     object
);



/*!
 *  @function
 *      Q3Object_GetLeafType
 *  @discussion
 *      Returns the leaf type of an object.
 *
 *      Returns the most specific type that can be identified from the object
 *      (e.g., a camera object may have a leaf type of kQ3CameraTypeViewAngleAspect).
 *      Returns kQ3ObjectTypeInvalid if the object type is unknown.
 *
 *  @param object           The object to test.
 *  @result                 The leaf type of the object.
 */
EXTERN_API_C ( TQ3ObjectType  )
Q3Object_GetLeafType (
    TQ3Object                     object
);



/*!
 *  @function
 *      Q3Object_IsType
 *  @discussion
 *      Tests to see if an object belongs to a given type.
 *
 *      Examines both the object supplied and its parents. E.g., a camera object
 *      would return true for a type of kQ3CameraTypeViewAngleAspect,
 *      kQ3ShapeTypeCamera, kQ3SharedTypeShape, and kQ3ObjectTypeShared but would
 *      return false for kQ3ObjectTypePick.
 *
 *  @param object           The object to test.
 *  @param theType          The type to test the object against.
 *  @result                 True or false as the object belongs to the type or not.
 */
EXTERN_API_C ( TQ3Boolean  )
Q3Object_IsType (
    TQ3Object                     object,
    TQ3ObjectType                 theType
);



/*!
 *  @function
 *      Q3Shared_GetType
 *  @discussion
 *      One-line description of this function.
 *
 *      A more extensive description can be supplied here, covering
 *      the typical usage of this function and any special requirements.
 *
 *  @param sharedObject     Description of the parameter.
 *  @result                 Description of the function result.
 */
EXTERN_API_C ( TQ3ObjectType  )
Q3Shared_GetType (
    TQ3SharedObject               sharedObject
);



/*!
 *  @function
 *      Q3Shared_GetReference
 *  @discussion
 *      One-line description of this function.
 *
 *      A more extensive description can be supplied here, covering
 *      the typical usage of this function and any special requirements.
 *
 *  @param sharedObject     Description of the parameter.
 *  @result                 Description of the function result.
 */
EXTERN_API_C ( TQ3SharedObject  )
Q3Shared_GetReference (
    TQ3SharedObject               sharedObject
);



/*!
 *  @function
 *      Q3Shared_IsReferenced
 *  @discussion
 *      One-line description of this function.
 *
 *      A more extensive description can be supplied here, covering
 *      the typical usage of this function and any special requirements.
 *
 *  @param sharedObject     Description of the parameter.
 *  @result                 Description of the function result.
 */
EXTERN_API_C ( TQ3Boolean  )
Q3Shared_IsReferenced (
    TQ3SharedObject               sharedObject
);



/*!
 *  @function
 *      Q3Shared_GetEditIndex
 *  @discussion
 *      One-line description of this function.
 *
 *      A more extensive description can be supplied here, covering
 *      the typical usage of this function and any special requirements.
 *
 *  @param sharedObject     Description of the parameter.
 *  @result                 Description of the function result.
 */
EXTERN_API_C ( TQ3Uns32  )
Q3Shared_GetEditIndex (
    TQ3SharedObject               sharedObject
);



/*!
 *  @function
 *      Q3Shared_Edited
 *  @discussion
 *      One-line description of this function.
 *
 *      A more extensive description can be supplied here, covering
 *      the typical usage of this function and any special requirements.
 *
 *  @param sharedObject     Description of the parameter.
 *  @result                 Description of the function result.
 */
EXTERN_API_C ( TQ3Status  )
Q3Shared_Edited (
    TQ3SharedObject               sharedObject
);



/*!
 *  @function
 *      Q3Shape_GetType
 *  @discussion
 *      One-line description of this function.
 *
 *      A more extensive description can be supplied here, covering
 *      the typical usage of this function and any special requirements.
 *
 *  @param shape            Description of the parameter.
 *  @result                 Description of the function result.
 */
EXTERN_API_C ( TQ3ObjectType  )
Q3Shape_GetType (
    TQ3ShapeObject                shape
);



/*!
 *  @function
 *      Q3Shape_GetSet
 *  @discussion
 *      One-line description of this function.
 *
 *      A more extensive description can be supplied here, covering
 *      the typical usage of this function and any special requirements.
 *
 *  @param shape            Description of the parameter.
 *  @param theSet           Description of the parameter.
 *  @result                 Description of the function result.
 */
EXTERN_API_C ( TQ3Status  )
Q3Shape_GetSet (
    TQ3ShapeObject                shape,
    TQ3SetObject                  *theSet
);



/*!
 *  @function
 *      Q3Shape_SetSet
 *  @discussion
 *      One-line description of this function.
 *
 *      A more extensive description can be supplied here, covering
 *      the typical usage of this function and any special requirements.
 *
 *  @param shape            Description of the parameter.
 *  @param theSet           Description of the parameter.
 *  @result                 Description of the function result.
 */
EXTERN_API_C ( TQ3Status  )
Q3Shape_SetSet (
    TQ3ShapeObject                shape,
    TQ3SetObject                  theSet
);



/*!
 *  @function
 *      Q3Shape_AddElement
 *  @discussion
 *      One-line description of this function.
 *
 *      A more extensive description can be supplied here, covering
 *      the typical usage of this function and any special requirements.
 *
 *  @param shape            Description of the parameter.
 *  @param theType          Description of the parameter.
 *  @param data             Description of the parameter.
 *  @result                 Description of the function result.
 */
EXTERN_API_C ( TQ3Status  )
Q3Shape_AddElement (
    TQ3ShapeObject                shape,
    TQ3ElementType                theType,
    const void                    *data
);



/*!
 *  @function
 *      Q3Shape_GetElement
 *  @discussion
 *      One-line description of this function.
 *
 *      A more extensive description can be supplied here, covering
 *      the typical usage of this function and any special requirements.
 *
 *  @param shape            Description of the parameter.
 *  @param theType          Description of the parameter.
 *  @param data             Description of the parameter.
 *  @result                 Description of the function result.
 */
EXTERN_API_C ( TQ3Status  )
Q3Shape_GetElement (
    TQ3ShapeObject                shape,
    TQ3ElementType                theType,
    void                          *data
);



/*!
 *  @function
 *      Q3Shape_ContainsElement
 *  @discussion
 *      One-line description of this function.
 *
 *      A more extensive description can be supplied here, covering
 *      the typical usage of this function and any special requirements.
 *
 *  @param shape            Description of the parameter.
 *  @param theType          Description of the parameter.
 *  @result                 Description of the function result.
 */
EXTERN_API_C ( TQ3Boolean  )
Q3Shape_ContainsElement (
    TQ3ShapeObject                shape,
    TQ3ElementType                theType
);



/*!
 *  @function
 *      Q3Shape_GetNextElementType
 *  @discussion
 *      One-line description of this function.
 *
 *      A more extensive description can be supplied here, covering
 *      the typical usage of this function and any special requirements.
 *
 *  @param shape            Description of the parameter.
 *  @param theType          Description of the parameter.
 *  @result                 Description of the function result.
 */
EXTERN_API_C ( TQ3Status  )
Q3Shape_GetNextElementType (
    TQ3ShapeObject                shape,
    TQ3ElementType                *theType
);



/*!
 *  @function
 *      Q3Shape_EmptyElements
 *  @discussion
 *      One-line description of this function.
 *
 *      A more extensive description can be supplied here, covering
 *      the typical usage of this function and any special requirements.
 *
 *  @param shape            Description of the parameter.
 *  @result                 Description of the function result.
 */
EXTERN_API_C ( TQ3Status  )
Q3Shape_EmptyElements (
    TQ3ShapeObject                shape
);



/*!
 *  @function
 *      Q3Shape_ClearElement
 *  @discussion
 *      One-line description of this function.
 *
 *      A more extensive description can be supplied here, covering
 *      the typical usage of this function and any special requirements.
 *
 *  @param shape            Description of the parameter.
 *  @param theType          Description of the parameter.
 *  @result                 Description of the function result.
 */
EXTERN_API_C ( TQ3Status  )
Q3Shape_ClearElement (
    TQ3ShapeObject                shape,
    TQ3ElementType                theType
);



/*!
 *  @function
 *      Q3Bitmap_Empty
 *  @discussion
 *      One-line description of this function.
 *
 *      A more extensive description can be supplied here, covering
 *      the typical usage of this function and any special requirements.
 *
 *  @param bitmap           Description of the parameter.
 *  @result                 Description of the function result.
 */
EXTERN_API_C ( TQ3Status  )
Q3Bitmap_Empty (
    TQ3Bitmap                     *bitmap
);



/*!
 *  @function
 *      Q3Bitmap_GetImageSize
 *  @discussion
 *      One-line description of this function.
 *
 *      A more extensive description can be supplied here, covering
 *      the typical usage of this function and any special requirements.
 *
 *  @param width            Description of the parameter.
 *  @param height           Description of the parameter.
 *  @result                 Description of the function result.
 */
EXTERN_API_C ( TQ3Uns32  )
Q3Bitmap_GetImageSize (
    TQ3Uns32                      width,
    TQ3Uns32                      height
);





//=============================================================================
//      C++ postamble
//-----------------------------------------------------------------------------
#ifdef __cplusplus
}
#endif


#endif


