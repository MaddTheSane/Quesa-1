/*  NAME:
        E3Prefix.h

    DESCRIPTION:
        Global prefix file for Quesa.

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
#ifndef __E3PREFIX__
#define __E3PREFIX__
//=============================================================================
//      Include files
//-----------------------------------------------------------------------------
// Sigh - there's always one...
//
// Windows needs to have <Windows.h> as the very first #include, or things
// won't compile. We also turn off the unknown #pragma warning for VC++.
#if _MSC_VER
	#include <Windows.h>
	#pragma warning(disable:4068)
#endif


// QD3D
#include <QD3D.h>
#include <QD3DAcceleration.h>
#include <QD3DCamera.h>
#include <QD3DController.h>
#include <QD3DCustomElements.h>
#include <QD3DDrawContext.h>
#include <QD3DErrors.h>
#include <QD3DExtension.h>
#include <QD3DGeometry.h>
#include <QD3DGroup.h>
#include <QD3DIO.h>
#include <QD3DLight.h>
#include <QD3DMath.h>
#include <QD3DPick.h>
#include <QD3DRenderer.h>
#include <QD3DSet.h>
#include <QD3DShader.h>
#include <QD3DStorage.h>
#include <QD3DString.h>
#include <QD3DStyle.h>
#include <QD3DTransform.h>
#include <QD3DView.h>
#include <QD3DViewer.h>
#include <QD3DWinViewer.h>


// Quesa (public, extensions to QD3D)
#include "QuesaDrawContext.h"
#include "QuesaErrors.h"
#include "QuesaStorage.h"
#include "QuesaRenderer.h"


// Quesa (private, platform specific for platforms without makefiles)
#if OS_MACINTOSH
	#include "E3MacPrefix.h"
#endif


// Quesa (private, platform independent)
#include "E3Debug.h"
#include "E3Globals.h"
#include "E3Utils.h"
#include "E3System.h"
#include "E3Memory.h"
#include "E3ErrorManager.h"


// ANSI
#include <string.h>
#include <math.h>





//=============================================================================
//      Build constants
//-----------------------------------------------------------------------------
// Dumps class tree stats on Q3Exit
#ifndef QUESA_DUMP_STATS_ON_EXIT
	#define QUESA_DUMP_STATS_ON_EXIT							0
#endif


// Should we register the built-in plug-ins?
#ifndef QUESA_REGISTER_BUILTIN_PLUGINS
	#define QUESA_REGISTER_BUILTIN_PLUGINS						1
#endif


// Should we overwrite the QD3D renderers?
#ifndef QUESA_REPLACE_QD3D_RENDERERS
	#define QUESA_REPLACE_QD3D_RENDERERS						0
#endif


// Do we have QuickTime?
#ifndef QUESA_SUPPORT_QUICKTIME
	#define QUESA_SUPPORT_QUICKTIME								1
#endif


// Do we put numbers the Right Way round?
#ifndef QUESA_HOST_IS_BIG_ENDIAN
	#define QUESA_HOST_IS_BIG_ENDIAN							1
#endif





#endif
