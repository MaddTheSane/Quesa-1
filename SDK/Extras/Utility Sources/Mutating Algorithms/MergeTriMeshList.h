/*  NAME:
        MergeTriMeshes.h

    DESCRIPTION:
        Quesa utility header.
	
	AUTHORSHIP:
		Initial version written by James W. Walker.

    COPYRIGHT:
        Copyright (c) 2007, Quesa Developers. All rights reserved.

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
#ifndef QUESA_MERGETRIMESHLIST_HDR
#define QUESA_MERGETRIMESHLIST_HDR

#if !TARGET_RT_MAC_MACHO
	#include "CQ3ObjectRef.h"
#else
	#include <Quesa/CQ3ObjectRef.h>
#endif

#include <vector>


/*!
	@function	MergeTriMeshList
	
	@abstract	Merge a vector of compatible TriMeshes into a single TriMesh.
	
	@discussion	The merging takes into account face normals, vertex normals,
				vertex diffuse colors, vertex specular colors, vertex specular
				controls, vertex transparency colors, and vertex surface UVs.
				Therefore, for each of these attributes, either all of the
				TriMeshes should have the attribute, or none should.
	
	@param		inObs		Two or more TriMeshes.
	@result		A new TriMesh.
*/
CQ3ObjectRef	MergeTriMeshList( const std::vector< CQ3ObjectRef >& inObs );

#endif
