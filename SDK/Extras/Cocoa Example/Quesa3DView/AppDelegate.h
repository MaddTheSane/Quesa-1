/*  NAME:
        AppDelegate.h

    DESCRIPTION:
        Header file for AppDelegate.m.

    COPYRIGHT:
        Copyright (c) 1999-2020, Quesa Developers. All rights reserved.

        For the current release of Quesa, please see:

            <https://github.com/jwwalker/Quesa>
        
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
#import <Quesa/Quesa.h>
#import <Quesa/QuesaStyle.h>
#import "Quesa3DView.h"



/*!
	@class		AppDelegate
	
	@abstract	Controller for the dialog and delegate of the Quesa view.
	
	@discussion	Contrary to the name, this object is not a delegate of the
				application.
				
				Most of the window controls are set up using bindings rather
				than action methods.
*/
@interface AppDelegate : NSObject <Quesa3DViewDelegate>
{
	IBOutlet Quesa3DView*		quesa3dView;
	IBOutlet NSPopUpButton*		rendererMenu;
	IBOutlet NSPopUpButton*		objectMenu;
	
	NSTimer*			mAnimationTimer;
	BOOL				mAnimates;
	BOOL				mDrawsShadows;
	BOOL				_directionalLight;
	BOOL				_pointLight;
	BOOL				_ambientLight;
	BOOL				_flatInterpolation;
	BOOL				_testViewport;
	BOOL				_fisheyeCamera;
	TQ3Object			mSceneBounds;
	BOOL				mFullScreenAntialias;
	TQ3ObjectType		mRendererType;
	TQ3Matrix4x4		mCurrentMatrix;
	TQ3Matrix4x4		_currentRotation;
	TQ3Matrix4x4		mRotationFactor;
	TQ3Point3D			_centerOfRotation;
	TQ3ShaderObject		mIlluminationShader;
	TQ3StyleObject		_backfacingStyleObject;
	TQ3StyleObject		_fillStyleObject;
	TQ3StyleObject		_interpolationStyleObject;
	TQ3StyleObject		_fogStyleObject;
	TQ3ShapeObject		mSceneGeometry;
	float				mXRotation;
	float				mYRotation;
	float				mZRotation;
	int					mIlluminationShaderType;
	TQ3BackfacingStyle	_backfacingStyle;
	TQ3FillStyle		_fillStyle;
	int					_fogStyleTag;
	int					_cameraType;
	int					_fisheyeCropFormat;
	int					_fisheyeMappingFunc;
	float				_fisheyeAngleOfView;
	NSCursor*			_windowRectPickCursor;
}

@property (nonatomic, assign) BOOL		drawsShadows;
@property (nonatomic, assign) BOOL		animates;
@property (assign) BOOL		drawsBounds;
@property (nonatomic, assign) BOOL		fullScreenAntialias;
@property (nonatomic, assign) BOOL		directionalLight;
@property (nonatomic, assign) BOOL		pointLight;
@property (nonatomic, assign) BOOL		ambientLight;
@property (nonatomic, assign) BOOL		flatInterpolation;
@property (nonatomic, assign) BOOL		testViewport;

@property (nonatomic, assign) TQ3ObjectType	rendererType;

@property (nonatomic, assign)	float	xRotation;
@property (nonatomic, assign)	float	yRotation;
@property (nonatomic, assign)	float	zRotation;

@property (nonatomic, assign)	int		illuminationType;
@property (nonatomic, assign) TQ3BackfacingStyle	backfacingStyle;
@property (nonatomic, assign) TQ3FillStyle			fillStyle;
@property (nonatomic, assign) int		fogStyleTag;
@property (nonatomic, assign)	int		cameraType;
@property (assign) BOOL fisheyeCamera;
@property (nonatomic, assign) int fisheyeCropFormat;
@property (nonatomic, assign) int fisheyeMappingFunc;
@property (nonatomic, assign) float fisheyeAngleOfView;
@property (retain) NSCursor* windowRectPickCursor;

- (IBAction)setGeometryFromTag:(id)sender;

- (IBAction)loadTexture:(id)sender;

- (IBAction)loadObject:(id)sender;

- (IBAction)saveObject:(id)sender;

- (IBAction)refreshImage:(id)sender;

@end
