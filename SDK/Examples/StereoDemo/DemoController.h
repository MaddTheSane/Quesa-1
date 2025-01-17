/*  NAME:
        DemoController.h

    DESCRIPTION:
        Header file for DemoController.m.

    COPYRIGHT:
        Copyright (c) 2009, Quesa Developers. All rights reserved.

        For the current release of Quesa, please see:

            <http://www.quesa.org/>
        
        Redistribution and use in source and binary forms, with or without
        modification, are permitted provided that the following conditions
        are met:
        
            o Redistributions of source code must retain the above copyright
              notice, this list of conditions and the following disclaimer.
        
            o Redistributions in binary form must reproduce the above
              copyright notice, this list of conditions and the following
              disclaimer in the documentation and/or other materials provided
              with the distribution.
        
            o Neither the name of Quesa nor the names of its contributors
              may be used to endorse or promote products derived from this
              software without specific prior written permission.
        
        THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
        "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
        LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
        A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
        OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
        SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
        TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
        PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
        LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
        NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
        SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
    ___________________________________________________________________________
*/
#import <Cocoa/Cocoa.h>
#include <Quesa/Quesa.h>
#import "Quesa3DView.h"

typedef NS_ENUM(NSInteger, ELeftRightFormat)
{
	kLeftRightFormat_RedCyan = 1,
	kLeftRightFormat_GreenMagenta,
	kLeftRightFormat_BlueYellow,
	kLeftRightFormat_CyanRed,
	kLeftRightFormat_MagentaGreen,
	kLeftRightFormat_YellowBlue,
	
	kLeftRightFormat_EvenOdd,
	kLeftRightFormat_OddEven
};


/*!
	@class		DemoController
	
	@abstract	Controller for the dialog and delegate of the Quesa view.
	
	@discussion	Most of the window controls are set up using bindings rather
				than action methods.
*/
@interface DemoController : NSObject <Quesa3DViewDelegate>
{
	IBOutlet Quesa3DView*		quesa3dView;
	IBOutlet NSPopUpButton*		rendererMenu;
	IBOutlet NSPopUpButton*		objectMenu;
	
	NSTimer*			mAnimationTimer;
	BOOL				mAnimates;
	BOOL				mDrawsShadows;
	TQ3Object			mSceneBounds;
	BOOL				mFullScreenAntialias;
	BOOL				mIsFirstPassForEye;
	NSOpenGLPixelFormat*	mPixelFormat;
	TQ3ObjectType		mRendererType;
	TQ3Matrix4x4		mCurrentMatrix;
	TQ3Matrix4x4		mRotationFactor;
	TQ3ShaderObject		mIlluminationShader;
	TQ3ShapeObject		mSceneGeometry;
	float				mXRotation;
	float				mYRotation;
	float				mZRotation;
	
	float				mProjectionDistance;
	float				mSeparationDistance;
	ELeftRightFormat	mLeftRightFormat;
	TQ3CameraObject		mViewPlaneCamera;
}

@property (nonatomic) BOOL drawsShadows;

@property (nonatomic) BOOL animates;

@property (nonatomic) BOOL drawsBounds;

@property (nonatomic) BOOL fullScreenAntialias;

@property (nonatomic) TQ3ObjectType rendererType;

@property (nonatomic) float xRotation;

@property (nonatomic) float yRotation;

@property (nonatomic) float zRotation;

@property (nonatomic) float projectionDistance;

@property (nonatomic) float separationDistance;

@property (nonatomic) ELeftRightFormat leftRightFormat;

- (IBAction)setGeometryFromTag:(id)sender;
@end
