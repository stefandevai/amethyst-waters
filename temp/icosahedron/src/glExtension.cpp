///////////////////////////////////////////////////////////////////////////////
// glExtension.cpp
// ===============
// OpenGL extension helper
// NOTE: In order to get valid OpenGL extensions on Windows system, HDC must be
// passed to wglGetExtensionsStringARB() function. The size of HDC in 64bit
// Windows is 8 bytes.
//
// extensions
// ==========
// GL_ARB_framebuffer_object
// GL_ARB_debug_output
// GL_ARB_direct_state_access
// GL_ARB_multisample
// GL_ARB_multitexture
// GL_ARB_pixel_buffer_objects, GL_ARB_vertex_buffer_object
// GL_ARB_shader_objects, GL_ARB_vertex_program, GL_ARB_fragment_program, GL_ARB_vertex_shader, GL_ARB_fragment_shader
// GL_ARB_sync
// GL_ARB_vertex_array_object
// WGL_ARB_extensions_string
// WGL_ARB_pixel_format
// WGL_ARB_create_context
// WGL_EXT_swap_control
//
//  AUTHOR: Song Ho Ahn (song.ahn@gmail.com)
// CREATED: 2013-03-05
// UPDATED: 2018-06-07
///////////////////////////////////////////////////////////////////////////////

#include <iostream>
#include <algorithm>
#include "glExtension.h"


#ifdef _WIN32 //===============================================================
// GL_ARB_framebuffer_object
PFNGLGENFRAMEBUFFERSPROC                        pglGenFramebuffers = 0;                     // FBO name generation procedure
PFNGLDELETEFRAMEBUFFERSPROC                     pglDeleteFramebuffers = 0;                  // FBO deletion procedure
PFNGLBINDFRAMEBUFFERPROC                        pglBindFramebuffer = 0;                     // FBO bind procedure
PFNGLCHECKFRAMEBUFFERSTATUSPROC                 pglCheckFramebufferStatus = 0;              // FBO completeness test procedure
PFNGLGETFRAMEBUFFERATTACHMENTPARAMETERIVPROC    pglGetFramebufferAttachmentParameteriv = 0; // return various FBO parameters
PFNGLGENERATEMIPMAPPROC                         pglGenerateMipmap = 0;                      // FBO automatic mipmap generation procedure
PFNGLFRAMEBUFFERTEXTURE1DPROC                   pglFramebufferTexture1D = 0;                // FBO 1D texture attachement procedure
PFNGLFRAMEBUFFERTEXTURE2DPROC                   pglFramebufferTexture2D = 0;                // FBO 2D texture attachement procedure
PFNGLFRAMEBUFFERTEXTURE3DPROC                   pglFramebufferTexture3D = 0;                // FBO 3D texture attachement procedure
PFNGLFRAMEBUFFERTEXTURELAYERPROC                pglFramebufferTextureLayer = 0;             // FBO 3D texture layer attachement procedure
PFNGLFRAMEBUFFERRENDERBUFFERPROC                pglFramebufferRenderbuffer = 0;             // FBO renderbuffer attachement procedure
PFNGLISFRAMEBUFFERPROC                          pglIsFramebuffer = 0;                       // FBO state = true/false
PFNGLBLITFRAMEBUFFERPROC                        pglBlitFramebuffer = 0;                     // FBO copy
PFNGLGENRENDERBUFFERSPROC                       pglGenRenderbuffers = 0;                    // renderbuffer generation procedure
PFNGLDELETERENDERBUFFERSPROC                    pglDeleteRenderbuffers = 0;                 // renderbuffer deletion procedure
PFNGLBINDRENDERBUFFERPROC                       pglBindRenderbuffer = 0;                    // renderbuffer bind procedure
PFNGLRENDERBUFFERSTORAGEPROC                    pglRenderbufferStorage = 0;                 // renderbuffer memory allocation procedure
PFNGLRENDERBUFFERSTORAGEMULTISAMPLEPROC         pglRenderbufferStorageMultisample = 0;      // renderbuffer memory allocation with multisample
PFNGLGETRENDERBUFFERPARAMETERIVPROC             pglGetRenderbufferParameteriv = 0;          // return various renderbuffer parameters
PFNGLISRENDERBUFFERPROC                         pglIsRenderbuffer = 0;                      // determine renderbuffer object type

// GL_ARB_multisample
PFNGLSAMPLECOVERAGEARBPROC  pglSampleCoverageARB = 0;

// GL_ARB_multitexture
PFNGLACTIVETEXTUREARBPROC   pglActiveTextureARB = 0;

// GL_ARB_pixel_buffer_objects & GL_ARB_vertex_buffer_object
PFNGLGENBUFFERSARBPROC              pglGenBuffersARB = 0;           // VBO Name Generation Procedure
PFNGLBINDBUFFERARBPROC              pglBindBufferARB = 0;           // VBO Bind Procedure
PFNGLBUFFERDATAARBPROC              pglBufferDataARB = 0;           // VBO Data Loading Procedure
PFNGLBUFFERSUBDATAARBPROC           pglBufferSubDataARB = 0;        // VBO Sub Data Loading Procedure
PFNGLDELETEBUFFERSARBPROC           pglDeleteBuffersARB = 0;        // VBO Deletion Procedure
PFNGLGETBUFFERPARAMETERIVARBPROC    pglGetBufferParameterivARB = 0; // return various parameters of VBO
PFNGLMAPBUFFERARBPROC               pglMapBufferARB = 0;            // map VBO procedure
PFNGLUNMAPBUFFERARBPROC             pglUnmapBufferARB = 0;          // unmap VBO procedure

// GL_ARB_shader_objects
PFNGLDELETEOBJECTARBPROC            pglDeleteObjectARB = 0;         // delete shader object
PFNGLGETHANDLEARBPROC               pglGetHandleARB = 0;            // return handle of program
PFNGLDETACHOBJECTARBPROC            pglDetachObjectARB = 0;         // detatch a shader from a program
PFNGLCREATESHADEROBJECTARBPROC      pglCreateShaderObjectARB = 0;   // create a shader
PFNGLSHADERSOURCEARBPROC            pglShaderSourceARB = 0;         // set a shader source(codes)
PFNGLCOMPILESHADERARBPROC           pglCompileShaderARB = 0;        // compile shader source
PFNGLCREATEPROGRAMOBJECTARBPROC     pglCreateProgramObjectARB = 0;  // create a program
PFNGLATTACHOBJECTARBPROC            pglAttachObjectARB = 0;         // attach a shader to a program
PFNGLLINKPROGRAMARBPROC             pglLinkProgramARB = 0;          // link a program
PFNGLUSEPROGRAMOBJECTARBPROC        pglUseProgramObjectARB = 0;     // use a program
PFNGLVALIDATEPROGRAMARBPROC         pglValidateProgramARB = 0;      // validate a program
PFNGLUNIFORM1FARBPROC               pglUniform1fARB = 0;            //
PFNGLUNIFORM2FARBPROC               pglUniform2fARB = 0;            //
PFNGLUNIFORM3FARBPROC               pglUniform3fARB = 0;            //
PFNGLUNIFORM4FARBPROC               pglUniform4fARB = 0;            //
PFNGLUNIFORM1IARBPROC               pglUniform1iARB = 0;            //
PFNGLUNIFORM2IARBPROC               pglUniform2iARB = 0;            //
PFNGLUNIFORM3IARBPROC               pglUniform3iARB = 0;            //
PFNGLUNIFORM4IARBPROC               pglUniform4iARB = 0;            //
PFNGLUNIFORM1FVARBPROC              pglUniform1fvARB = 0;           //
PFNGLUNIFORM2FVARBPROC              pglUniform2fvARB = 0;           //
PFNGLUNIFORM3FVARBPROC              pglUniform3fvARB = 0;           //
PFNGLUNIFORM4FVARBPROC              pglUniform4fvARB = 0;           //
PFNGLUNIFORM1FVARBPROC              pglUniform1ivARB = 0;           //
PFNGLUNIFORM2FVARBPROC              pglUniform2ivARB = 0;           //
PFNGLUNIFORM3FVARBPROC              pglUniform3ivARB = 0;           //
PFNGLUNIFORM4FVARBPROC              pglUniform4ivARB = 0;           //
PFNGLUNIFORMMATRIX2FVARBPROC        pglUniformMatrix2fvARB = 0;     //
PFNGLUNIFORMMATRIX3FVARBPROC        pglUniformMatrix3fvARB = 0;     //
PFNGLUNIFORMMATRIX4FVARBPROC        pglUniformMatrix4fvARB = 0;     //
PFNGLGETOBJECTPARAMETERFVARBPROC    pglGetObjectParameterfvARB = 0; // get shader/program param
PFNGLGETOBJECTPARAMETERIVARBPROC    pglGetObjectParameterivARB = 0; //
PFNGLGETINFOLOGARBPROC              pglGetInfoLogARB = 0;           // get log
PFNGLGETATTACHEDOBJECTSARBPROC      pglGetAttachedObjectsARB = 0;   // get attached shader to a program
PFNGLGETUNIFORMLOCATIONARBPROC      pglGetUniformLocationARB = 0;   // get index of uniform var
PFNGLGETACTIVEUNIFORMARBPROC        pglGetActiveUniformARB = 0;     // get info of uniform var
PFNGLGETUNIFORMFVARBPROC            pglGetUniformfvARB = 0;         // get value of uniform var
PFNGLGETUNIFORMIVARBPROC            pglGetUniformivARB = 0;         //
PFNGLGETSHADERSOURCEARBPROC         pglGetShaderSourceARB = 0;      // get shader source codes
//@@ GLSL core version
PFNGLATTACHSHADERPROC               pglAttachShader = 0;        // attach a shader to a program
PFNGLCOMPILESHADERPROC              pglCompileShader = 0;       // compile shader source
PFNGLCREATEPROGRAMPROC              pglCreateProgram = 0;       // create a program object
PFNGLCREATESHADERPROC               pglCreateShader = 0;        // create a shader object
PFNGLDELETEPROGRAMPROC              pglDeleteProgram = 0;       // delete shader program
PFNGLDELETESHADERPROC               pglDeleteShader = 0;        // delete shader object
PFNGLDETACHSHADERPROC               pglDetachShader = 0;        // detatch a shader object from a program
PFNGLGETACTIVEUNIFORMPROC           pglGetActiveUniform = 0;    // get info of uniform var
PFNGLGETATTACHEDSHADERSPROC         pglGetAttachedShaders = 0;  // get attached shaders to a program
PFNGLGETPROGRAMIVPROC               pglGetProgramiv = 0;        // return param of program object
PFNGLGETPROGRAMINFOLOGPROC          pglGetProgramInfoLog = 0;   // return info log of program
PFNGLGETSHADERIVPROC                pglGetShaderiv = 0;         // return param of shader object
PFNGLGETSHADERINFOLOGPROC           pglGetShaderInfoLog = 0;    // return info log of shader
PFNGLGETSHADERSOURCEPROC            pglGetShaderSource = 0;     // get shader source codes
PFNGLGETUNIFORMLOCATIONPROC         pglGetUniformLocation = 0;  // get index of uniform var
PFNGLGETUNIFORMFVPROC               pglGetUniformfv = 0;        // get value of uniform var
PFNGLGETUNIFORMIVPROC               pglGetUniformiv = 0;        //
PFNGLLINKPROGRAMPROC                pglLinkProgram = 0;         // link a program
PFNGLSHADERSOURCEPROC               pglShaderSource = 0;        // set a shader source(codes)
PFNGLUSEPROGRAMPROC                 pglUseProgram = 0;          // use a program
PFNGLUNIFORM1FPROC                  pglUniform1f = 0;           //
PFNGLUNIFORM2FPROC                  pglUniform2f = 0;           //
PFNGLUNIFORM3FPROC                  pglUniform3f = 0;           //
PFNGLUNIFORM4FPROC                  pglUniform4f = 0;           //
PFNGLUNIFORM1IPROC                  pglUniform1i = 0;           //
PFNGLUNIFORM2IPROC                  pglUniform2i = 0;           //
PFNGLUNIFORM3IPROC                  pglUniform3i = 0;           //
PFNGLUNIFORM4IPROC                  pglUniform4i = 0;           //
PFNGLUNIFORM1FVPROC                 pglUniform1fv = 0;          //
PFNGLUNIFORM2FVPROC                 pglUniform2fv = 0;          //
PFNGLUNIFORM3FVPROC                 pglUniform3fv = 0;          //
PFNGLUNIFORM4FVPROC                 pglUniform4fv = 0;          //
PFNGLUNIFORM1FVPROC                 pglUniform1iv = 0;          //
PFNGLUNIFORM2FVPROC                 pglUniform2iv = 0;          //
PFNGLUNIFORM3FVPROC                 pglUniform3iv = 0;          //
PFNGLUNIFORM4FVPROC                 pglUniform4iv = 0;          //
PFNGLUNIFORMMATRIX2FVPROC           pglUniformMatrix2fv = 0;    //
PFNGLUNIFORMMATRIX3FVPROC           pglUniformMatrix3fv = 0;    //
PFNGLUNIFORMMATRIX4FVPROC           pglUniformMatrix4fv = 0;    //
PFNGLVALIDATEPROGRAMPROC            pglValidateProgram = 0;     // validate a program

// GL_ARB_sync extension
PFNGLFENCESYNCPROC          pglFenceSync = 0;
PFNGLISSYNCPROC             pglIsSync = 0;
PFNGLDELETESYNCPROC         pglDeleteSync = 0;
PFNGLCLIENTWAITSYNCPROC     pglClientWaitSync = 0;
PFNGLWAITSYNCPROC           pglWaitSync = 0;
PFNGLGETINTEGER64VPROC      pglGetInteger64v = 0;
PFNGLGETSYNCIVPROC          pglGetSynciv = 0;

// GL_ARB_vertex_array_object
PFNGLGENVERTEXARRAYSPROC    pglGenVertexArrays = 0;     // VAO name generation procedure
PFNGLDELETEVERTEXARRAYSPROC pglDeleteVertexArrays = 0;  // VAO deletion procedure
PFNGLBINDVERTEXARRAYPROC    pglBindVertexArray = 0;     // VAO bind procedure
PFNGLISVERTEXARRAYPROC      pglIsVertexArray = 0;       // VBO query procedure


// GL_ARB_vertex_shader and GL_ARB_fragment_shader extensions
PFNGLBINDATTRIBLOCATIONARBPROC  pglBindAttribLocationARB = 0;       // bind vertex attrib var with index
PFNGLGETACTIVEATTRIBARBPROC     pglGetActiveAttribARB = 0;          // get attrib value
PFNGLGETATTRIBLOCATIONARBPROC   pglGetAttribLocationARB = 0;        // get lndex of attrib var
//@@ GLSL core version
PFNGLBINDATTRIBLOCATIONPROC     pglBindAttribLocation = 0;      // bind vertex attrib var with index
PFNGLGETACTIVEATTRIBPROC        pglGetActiveAttrib = 0;         // get attrib value
PFNGLGETATTRIBLOCATIONPROC      pglGetAttribLocation = 0;       // get lndex of attrib var

// GL_ARB_vertex_program and GL_ARB_fragment_program
PFNGLVERTEXATTRIB1DARBPROC              pglVertexAttrib1dARB = 0;
PFNGLVERTEXATTRIB1DVARBPROC             pglVertexAttrib1dvARB = 0;
PFNGLVERTEXATTRIB1FARBPROC              pglVertexAttrib1fARB = 0;
PFNGLVERTEXATTRIB1FVARBPROC             pglVertexAttrib1fvARB = 0;
PFNGLVERTEXATTRIB1SARBPROC              pglVertexAttrib1sARB = 0;
PFNGLVERTEXATTRIB1SVARBPROC             pglVertexAttrib1svARB = 0;
PFNGLVERTEXATTRIB2DARBPROC              pglVertexAttrib2dARB = 0;
PFNGLVERTEXATTRIB2DVARBPROC             pglVertexAttrib2dvARB = 0;
PFNGLVERTEXATTRIB2FARBPROC              pglVertexAttrib2fARB = 0;
PFNGLVERTEXATTRIB2FVARBPROC             pglVertexAttrib2fvARB = 0;
PFNGLVERTEXATTRIB2SARBPROC              pglVertexAttrib2sARB = 0;
PFNGLVERTEXATTRIB2SVARBPROC             pglVertexAttrib2svARB = 0;
PFNGLVERTEXATTRIB3DARBPROC              pglVertexAttrib3dARB = 0;
PFNGLVERTEXATTRIB3DVARBPROC             pglVertexAttrib3dvARB = 0;
PFNGLVERTEXATTRIB3FARBPROC              pglVertexAttrib3fARB = 0;
PFNGLVERTEXATTRIB3FVARBPROC             pglVertexAttrib3fvARB = 0;
PFNGLVERTEXATTRIB3SARBPROC              pglVertexAttrib3sARB = 0;
PFNGLVERTEXATTRIB3SVARBPROC             pglVertexAttrib3svARB = 0;
PFNGLVERTEXATTRIB4NBVARBPROC            pglVertexAttrib4NbvARB = 0;
PFNGLVERTEXATTRIB4NIVARBPROC            pglVertexAttrib4NivARB = 0;
PFNGLVERTEXATTRIB4NSVARBPROC            pglVertexAttrib4NsvARB = 0;
PFNGLVERTEXATTRIB4NUBARBPROC            pglVertexAttrib4NubARB = 0;
PFNGLVERTEXATTRIB4NUBVARBPROC           pglVertexAttrib4NubvARB = 0;
PFNGLVERTEXATTRIB4NUIVARBPROC           pglVertexAttrib4NuivARB = 0;
PFNGLVERTEXATTRIB4NUSVARBPROC           pglVertexAttrib4NusvARB = 0;
PFNGLVERTEXATTRIB4BVARBPROC             pglVertexAttrib4bvARB = 0;
PFNGLVERTEXATTRIB4DARBPROC              pglVertexAttrib4dARB = 0;
PFNGLVERTEXATTRIB4DVARBPROC             pglVertexAttrib4dvARB = 0;
PFNGLVERTEXATTRIB4FARBPROC              pglVertexAttrib4fARB = 0;
PFNGLVERTEXATTRIB4FVARBPROC             pglVertexAttrib4fvARB = 0;
PFNGLVERTEXATTRIB4IVARBPROC             pglVertexAttrib4ivARB = 0;
PFNGLVERTEXATTRIB4SARBPROC              pglVertexAttrib4sARB = 0;
PFNGLVERTEXATTRIB4SVARBPROC             pglVertexAttrib4svARB = 0;
PFNGLVERTEXATTRIB4UBVARBPROC            pglVertexAttrib4ubvARB = 0;
PFNGLVERTEXATTRIB4UIVARBPROC            pglVertexAttrib4uivARB = 0;
PFNGLVERTEXATTRIB4USVARBPROC            pglVertexAttrib4usvARB = 0;
PFNGLVERTEXATTRIBPOINTERARBPROC         pglVertexAttribPointerARB = 0;
PFNGLENABLEVERTEXATTRIBARRAYARBPROC     pglEnableVertexAttribArrayARB = 0;
PFNGLDISABLEVERTEXATTRIBARRAYARBPROC    pglDisableVertexAttribArrayARB = 0;
PFNGLPROGRAMSTRINGARBPROC               pglProgramStringARB = 0;
PFNGLBINDPROGRAMARBPROC                 pglBindProgramARB = 0;
PFNGLDELETEPROGRAMSARBPROC              pglDeleteProgramsARB = 0;
PFNGLGENPROGRAMSARBPROC                 pglGenProgramsARB = 0;
PFNGLPROGRAMENVPARAMETER4DARBPROC       pglProgramEnvParameter4dARB = 0;
PFNGLPROGRAMENVPARAMETER4DVARBPROC      pglProgramEnvParameter4dvARB = 0;
PFNGLPROGRAMENVPARAMETER4FARBPROC       pglProgramEnvParameter4fARB = 0;
PFNGLPROGRAMENVPARAMETER4FVARBPROC      pglProgramEnvParameter4fvARB = 0;
PFNGLPROGRAMLOCALPARAMETER4DARBPROC     pglProgramLocalParameter4dARB = 0;
PFNGLPROGRAMLOCALPARAMETER4DVARBPROC    pglProgramLocalParameter4dvARB = 0;
PFNGLPROGRAMLOCALPARAMETER4FARBPROC     pglProgramLocalParameter4fARB = 0;
PFNGLPROGRAMLOCALPARAMETER4FVARBPROC    pglProgramLocalParameter4fvARB = 0;
PFNGLGETPROGRAMENVPARAMETERDVARBPROC    pglGetProgramEnvParameterdvARB = 0;
PFNGLGETPROGRAMENVPARAMETERFVARBPROC    pglGetProgramEnvParameterfvARB = 0;
PFNGLGETPROGRAMLOCALPARAMETERDVARBPROC  pglGetProgramLocalParameterdvARB = 0;
PFNGLGETPROGRAMLOCALPARAMETERFVARBPROC  pglGetProgramLocalParameterfvARB = 0;
PFNGLGETPROGRAMIVARBPROC                pglGetProgramivARB = 0;
PFNGLGETPROGRAMSTRINGARBPROC            pglGetProgramStringARB = 0;
PFNGLGETVERTEXATTRIBDVARBPROC           pglGetVertexAttribdvARB = 0;
PFNGLGETVERTEXATTRIBFVARBPROC           pglGetVertexAttribfvARB = 0;
PFNGLGETVERTEXATTRIBIVARBPROC           pglGetVertexAttribivARB = 0;
PFNGLGETVERTEXATTRIBPOINTERVARBPROC     pglGetVertexAttribPointervARB = 0;
PFNGLISPROGRAMARBPROC                   pglIsProgramARB = 0;
//@@ v2.0 core version
PFNGLDISABLEVERTEXATTRIBARRAYPROC       pglDisableVertexAttribArray = 0;
PFNGLENABLEVERTEXATTRIBARRAYPROC        pglEnableVertexAttribArray = 0;
PFNGLGETVERTEXATTRIBDVPROC              pglGetVertexAttribdv = 0;
PFNGLGETVERTEXATTRIBFVPROC              pglGetVertexAttribfv = 0;
PFNGLGETVERTEXATTRIBIVPROC              pglGetVertexAttribiv = 0;
PFNGLGETVERTEXATTRIBPOINTERVPROC        pglGetVertexAttribPointerv = 0;
PFNGLISPROGRAMPROC                      pglIsProgram = 0;
PFNGLISSHADERPROC                       pglIsShader = 0;
PFNGLVERTEXATTRIB1DPROC                 pglVertexAttrib1d = 0;
PFNGLVERTEXATTRIB1DVPROC                pglVertexAttrib1dv = 0;
PFNGLVERTEXATTRIB1FPROC                 pglVertexAttrib1f = 0;
PFNGLVERTEXATTRIB1FVPROC                pglVertexAttrib1fv = 0;
PFNGLVERTEXATTRIB1SPROC                 pglVertexAttrib1s = 0;
PFNGLVERTEXATTRIB1SVPROC                pglVertexAttrib1sv = 0;
PFNGLVERTEXATTRIB2DPROC                 pglVertexAttrib2d = 0;
PFNGLVERTEXATTRIB2DVPROC                pglVertexAttrib2dv = 0;
PFNGLVERTEXATTRIB2FPROC                 pglVertexAttrib2f = 0;
PFNGLVERTEXATTRIB2FVPROC                pglVertexAttrib2fv = 0;
PFNGLVERTEXATTRIB2SPROC                 pglVertexAttrib2s = 0;
PFNGLVERTEXATTRIB2SVPROC                pglVertexAttrib2sv = 0;
PFNGLVERTEXATTRIB3DPROC                 pglVertexAttrib3d = 0;
PFNGLVERTEXATTRIB3DVPROC                pglVertexAttrib3dv = 0;
PFNGLVERTEXATTRIB3FPROC                 pglVertexAttrib3f = 0;
PFNGLVERTEXATTRIB3FVPROC                pglVertexAttrib3fv = 0;
PFNGLVERTEXATTRIB3SPROC                 pglVertexAttrib3s = 0;
PFNGLVERTEXATTRIB3SVPROC                pglVertexAttrib3sv = 0;
PFNGLVERTEXATTRIB4NBVPROC               pglVertexAttrib4Nbv = 0;
PFNGLVERTEXATTRIB4NIVPROC               pglVertexAttrib4Niv = 0;
PFNGLVERTEXATTRIB4NSVPROC               pglVertexAttrib4Nsv = 0;
PFNGLVERTEXATTRIB4NUBPROC               pglVertexAttrib4Nub = 0;
PFNGLVERTEXATTRIB4NUBVPROC              pglVertexAttrib4Nubv = 0;
PFNGLVERTEXATTRIB4NUIVPROC              pglVertexAttrib4Nuiv = 0;
PFNGLVERTEXATTRIB4NUSVPROC              pglVertexAttrib4Nusv = 0;
PFNGLVERTEXATTRIB4BVPROC                pglVertexAttrib4bv = 0;
PFNGLVERTEXATTRIB4DPROC                 pglVertexAttrib4d = 0;
PFNGLVERTEXATTRIB4DVPROC                pglVertexAttrib4dv = 0;
PFNGLVERTEXATTRIB4FPROC                 pglVertexAttrib4f = 0;
PFNGLVERTEXATTRIB4FVPROC                pglVertexAttrib4fv = 0;
PFNGLVERTEXATTRIB4IVPROC                pglVertexAttrib4iv = 0;
PFNGLVERTEXATTRIB4SPROC                 pglVertexAttrib4s = 0;
PFNGLVERTEXATTRIB4SVPROC                pglVertexAttrib4sv = 0;
PFNGLVERTEXATTRIB4UBVPROC               pglVertexAttrib4ubv = 0;
PFNGLVERTEXATTRIB4UIVPROC               pglVertexAttrib4uiv = 0;
PFNGLVERTEXATTRIB4USVPROC               pglVertexAttrib4usv = 0;
PFNGLVERTEXATTRIBPOINTERPROC            pglVertexAttribPointer = 0;

// GL_ARB_debug_output
PFNGLDEBUGMESSAGECONTROLARBPROC  pglDebugMessageControlARB = 0;
PFNGLDEBUGMESSAGEINSERTARBPROC   pglDebugMessageInsertARB = 0;
PFNGLDEBUGMESSAGECALLBACKARBPROC pglDebugMessageCallbackARB = 0;
PFNGLGETDEBUGMESSAGELOGARBPROC   pglGetDebugMessageLogARB = 0;

// GL_ARB_direct_state_access
PFNGLCREATETRANSFORMFEEDBACKSPROC                 pglCreateTransformFeedbacks = 0; // for transform feedback object
PFNGLTRANSFORMFEEDBACKBUFFERBASEPROC              pglTransformFeedbackBufferBase = 0;
PFNGLTRANSFORMFEEDBACKBUFFERRANGEPROC             pglTransformFeedbackBufferRange = 0;
PFNGLGETTRANSFORMFEEDBACKIVPROC                   pglGetTransformFeedbackiv = 0;
PFNGLGETTRANSFORMFEEDBACKI_VPROC                  pglGetTransformFeedbacki_v = 0;
PFNGLGETTRANSFORMFEEDBACKI64_VPROC                pglGetTransformFeedbacki64_v = 0;
PFNGLCREATEBUFFERSPROC                            pglCreateBuffers = 0;          // for buffer object
PFNGLNAMEDBUFFERSTORAGEPROC                       pglNamedBufferStorage = 0;
PFNGLNAMEDBUFFERDATAPROC                          pglNamedBufferData = 0;
PFNGLNAMEDBUFFERSUBDATAPROC                       pglNamedBufferSubData = 0;
PFNGLCOPYNAMEDBUFFERSUBDATAPROC                   pglCopyNamedBufferSubData = 0;
PFNGLCLEARNAMEDBUFFERDATAPROC                     pglClearNamedBufferData = 0;
PFNGLCLEARNAMEDBUFFERSUBDATAPROC                  pglClearNamedBufferSubData = 0;
PFNGLMAPNAMEDBUFFERPROC                           pglMapNamedBuffer = 0;
PFNGLMAPNAMEDBUFFERRANGEPROC                      pglMapNamedBufferRange = 0;
PFNGLUNMAPNAMEDBUFFERPROC                         pglUnmapNamedBuffer = 0;
PFNGLFLUSHMAPPEDNAMEDBUFFERRANGEPROC              pglFlushMappedNamedBufferRange = 0;
PFNGLGETNAMEDBUFFERPARAMETERIVPROC                pglGetNamedBufferParameteriv = 0;
PFNGLGETNAMEDBUFFERPARAMETERI64VPROC              pglGetNamedBufferParameteri64v = 0;
PFNGLGETNAMEDBUFFERPOINTERVPROC                   pglGetNamedBufferPointerv = 0;
PFNGLGETNAMEDBUFFERSUBDATAPROC                    pglGetNamedBufferSubData = 0;
PFNGLCREATEFRAMEBUFFERSPROC                       pglCreateFramebuffers = 0;     // for framebuffer object
PFNGLNAMEDFRAMEBUFFERRENDERBUFFERPROC             pglNamedFramebufferRenderbuffer = 0;
PFNGLNAMEDFRAMEBUFFERPARAMETERIPROC               pglNamedFramebufferParameteri = 0;
PFNGLNAMEDFRAMEBUFFERTEXTUREPROC                  pglNamedFramebufferTexture = 0;
PFNGLNAMEDFRAMEBUFFERTEXTURELAYERPROC             pglNamedFramebufferTextureLayer = 0;
PFNGLNAMEDFRAMEBUFFERDRAWBUFFERPROC               pglNamedFramebufferDrawBuffer = 0;
PFNGLNAMEDFRAMEBUFFERDRAWBUFFERSPROC              pglNamedFramebufferDrawBuffers = 0;
PFNGLNAMEDFRAMEBUFFERREADBUFFERPROC               pglNamedFramebufferReadBuffer = 0;
PFNGLINVALIDATENAMEDFRAMEBUFFERDATAPROC           pglInvalidateNamedFramebufferData = 0;
PFNGLINVALIDATENAMEDFRAMEBUFFERSUBDATAPROC        pglInvalidateNamedFramebufferSubData = 0;
PFNGLCLEARNAMEDFRAMEBUFFERIVPROC                  pglClearNamedFramebufferiv = 0;
PFNGLCLEARNAMEDFRAMEBUFFERUIVPROC                 pglClearNamedFramebufferuiv = 0;
PFNGLCLEARNAMEDFRAMEBUFFERFVPROC                  pglClearNamedFramebufferfv = 0;
PFNGLCLEARNAMEDFRAMEBUFFERFIPROC                  pglClearNamedFramebufferfi = 0;
PFNGLBLITNAMEDFRAMEBUFFERPROC                     pglBlitNamedFramebuffer = 0;
PFNGLCHECKNAMEDFRAMEBUFFERSTATUSPROC              pglCheckNamedFramebufferStatus = 0;
PFNGLGETNAMEDFRAMEBUFFERPARAMETERIVPROC           pglGetNamedFramebufferParameteriv = 0;
PFNGLGETNAMEDFRAMEBUFFERATTACHMENTPARAMETERIVPROC pglGetNamedFramebufferAttachmentParameteriv = 0;
PFNGLCREATERENDERBUFFERSPROC                      pglCreateRenderbuffers = 0;    // for renderbuffer object
PFNGLNAMEDRENDERBUFFERSTORAGEPROC                 pglNamedRenderbufferStorage = 0;
PFNGLNAMEDRENDERBUFFERSTORAGEMULTISAMPLEPROC      pglNamedRenderbufferStorageMultisample = 0;
PFNGLGETNAMEDRENDERBUFFERPARAMETERIVPROC          pglGetNamedRenderbufferParameteriv = 0;
PFNGLCREATETEXTURESPROC                           pglCreateTextures = 0;         // for texture object
PFNGLTEXTUREBUFFERPROC                            pglTextureBuffer = 0;
PFNGLTEXTUREBUFFERRANGEPROC                       pglTextureBufferRange = 0;
PFNGLTEXTURESTORAGE1DPROC                         pglTextureStorage1D = 0;
PFNGLTEXTURESTORAGE2DPROC                         pglTextureStorage2D = 0;
PFNGLTEXTURESTORAGE3DPROC                         pglTextureStorage3D = 0;
PFNGLTEXTURESTORAGE2DMULTISAMPLEPROC              pglTextureStorage2DMultisample = 0;
PFNGLTEXTURESTORAGE3DMULTISAMPLEPROC              pglTextureStorage3DMultisample = 0;
PFNGLTEXTURESUBIMAGE1DPROC                        pglTextureSubImage1D = 0;
PFNGLTEXTURESUBIMAGE2DPROC                        pglTextureSubImage2D = 0;
PFNGLTEXTURESUBIMAGE3DPROC                        pglTextureSubImage3D = 0;
PFNGLCOMPRESSEDTEXTURESUBIMAGE1DPROC              pglCompressedTextureSubImage1D = 0;
PFNGLCOMPRESSEDTEXTURESUBIMAGE2DPROC              pglCompressedTextureSubImage2D = 0;
PFNGLCOMPRESSEDTEXTURESUBIMAGE3DPROC              pglCompressedTextureSubImage3D = 0;
PFNGLCOPYTEXTURESUBIMAGE1DPROC                    pglCopyTextureSubImage1D = 0;
PFNGLCOPYTEXTURESUBIMAGE2DPROC                    pglCopyTextureSubImage2D = 0;
PFNGLCOPYTEXTURESUBIMAGE3DPROC                    pglCopyTextureSubImage3D = 0;
PFNGLTEXTUREPARAMETERFPROC                        pglTextureParameterf = 0;
PFNGLTEXTUREPARAMETERFVPROC                       pglTextureParameterfv = 0;
PFNGLTEXTUREPARAMETERIPROC                        pglTextureParameteri = 0;
PFNGLTEXTUREPARAMETERIIVPROC                      pglTextureParameterIiv = 0;
PFNGLTEXTUREPARAMETERIUIVPROC                     pglTextureParameterIuiv = 0;
PFNGLTEXTUREPARAMETERIVPROC                       pglTextureParameteriv = 0;
PFNGLGENERATETEXTUREMIPMAPPROC                    pglGenerateTextureMipmap = 0;
PFNGLBINDTEXTUREUNITPROC                          pglBindTextureUnit = 0;
PFNGLGETTEXTUREIMAGEPROC                          pglGetTextureImage = 0;
PFNGLGETCOMPRESSEDTEXTUREIMAGEPROC                pglGetCompressedTextureImage = 0;
PFNGLGETTEXTURELEVELPARAMETERFVPROC               pglGetTextureLevelParameterfv = 0;
PFNGLGETTEXTURELEVELPARAMETERIVPROC               pglGetTextureLevelParameteriv = 0;
PFNGLGETTEXTUREPARAMETERFVPROC                    pglGetTextureParameterfv = 0;
PFNGLGETTEXTUREPARAMETERIIVPROC                   pglGetTextureParameterIiv = 0;
PFNGLGETTEXTUREPARAMETERIUIVPROC                  pglGetTextureParameterIuiv = 0;
PFNGLGETTEXTUREPARAMETERIVPROC                    pglGetTextureParameteriv = 0;
PFNGLCREATEVERTEXARRAYSPROC                       pglCreateVertexArrays = 0;     // for vertex array object
PFNGLDISABLEVERTEXARRAYATTRIBPROC                 pglDisableVertexArrayAttrib = 0;
PFNGLENABLEVERTEXARRAYATTRIBPROC                  pglEnableVertexArrayAttrib = 0;
PFNGLVERTEXARRAYELEMENTBUFFERPROC                 pglVertexArrayElementBuffer = 0;
PFNGLVERTEXARRAYVERTEXBUFFERPROC                  pglVertexArrayVertexBuffer = 0;
PFNGLVERTEXARRAYVERTEXBUFFERSPROC                 pglVertexArrayVertexBuffers = 0;
PFNGLVERTEXARRAYATTRIBBINDINGPROC                 pglVertexArrayAttribBinding = 0;
PFNGLVERTEXARRAYATTRIBFORMATPROC                  pglVertexArrayAttribFormat = 0;
PFNGLVERTEXARRAYATTRIBIFORMATPROC                 pglVertexArrayAttribIFormat = 0;
PFNGLVERTEXARRAYATTRIBLFORMATPROC                 pglVertexArrayAttribLFormat = 0;
PFNGLVERTEXARRAYBINDINGDIVISORPROC                pglVertexArrayBindingDivisor = 0;
PFNGLGETVERTEXARRAYIVPROC                         pglGetVertexArrayiv = 0;
PFNGLGETVERTEXARRAYINDEXEDIVPROC                  pglGetVertexArrayIndexediv = 0;
PFNGLGETVERTEXARRAYINDEXED64IVPROC                pglGetVertexArrayIndexed64iv = 0;
PFNGLCREATESAMPLERSPROC                           pglCreateSamplers = 0;         // for sampler object
PFNGLCREATEPROGRAMPIPELINESPROC                   pglCreateProgramPipelines = 0; // for program pipeline object
PFNGLCREATEQUERIESPROC                            pglCreateQueries = 0;          // for query object
PFNGLGETQUERYBUFFEROBJECTIVPROC                   pglGetQueryBufferObjectiv = 0;
PFNGLGETQUERYBUFFEROBJECTUIVPROC                  pglGetQueryBufferObjectuiv = 0;
PFNGLGETQUERYBUFFEROBJECTI64VPROC                 pglGetQueryBufferObjecti64v = 0;
PFNGLGETQUERYBUFFEROBJECTUI64VPROC                pglGetQueryBufferObjectui64v = 0;


// WGL_ARB_extensions_string
PFNWGLGETEXTENSIONSSTRINGARBPROC    pwglGetExtensionsStringARB = 0;

// WGL_ARB_pixel_format
PFNWGLGETPIXELFORMATATTRIBIVARBPROC  pwglGetPixelFormatAttribivARB = 0;
PFNWGLGETPIXELFORMATATTRIBFVARBPROC  pwglGetPixelFormatAttribfvARB = 0;
PFNWGLCHOOSEPIXELFORMATARBPROC       pwglChoosePixelFormatARB = 0;

// WGL_ARB_create_context
PFNWGLCREATECONTEXTATTRIBSARBPROC   pwglCreateContextAttribsARB = 0;

// WGL_EXT_swap_control
PFNWGLSWAPINTERVALEXTPROC       pwglSwapIntervalEXT = 0;
PFNWGLGETSWAPINTERVALEXTPROC    pwglGetSwapIntervalEXT = 0;

#endif //======================================================================



///////////////////////////////////////////////////////////////////////////////
// ctor / dtor
///////////////////////////////////////////////////////////////////////////////
glExtension::glExtension()
{
    // must be called after OpenGL RC is open
    getExtensionStrings();

#ifdef _WIN32
    getFunctionPointers();
#endif
}
glExtension::~glExtension()
{
}



///////////////////////////////////////////////////////////////////////////////
// instantiate a singleton instance if not exist
///////////////////////////////////////////////////////////////////////////////
glExtension& glExtension::getInstance()
{
    static glExtension self;
    return self;
}



///////////////////////////////////////////////////////////////////////////////
// check if opengl extension is available
///////////////////////////////////////////////////////////////////////////////
bool glExtension::isSupported(const std::string& ext)
{
    // search corresponding extension
    std::vector<std::string>::const_iterator iter = this->extensions.begin();
    std::vector<std::string>::const_iterator endIter = this->extensions.end();
    while(iter != endIter)
    {
        if(toLower(ext) == toLower(*iter))
            return true;
        else
            ++iter;
    }
    return false;
}



///////////////////////////////////////////////////////////////////////////////
// return array of OpenGL extension strings
///////////////////////////////////////////////////////////////////////////////
const std::vector<std::string>& glExtension::getExtensions()
{
    // re-try to get extensions if it is empty
    if(extensions.size() == 0)
        getExtensionStrings();

    return extensions;
}



///////////////////////////////////////////////////////////////////////////////
// get supported extensions
///////////////////////////////////////////////////////////////////////////////
void glExtension::getExtensionStrings()
{
    const char* cstr = (const char*)glGetString(GL_EXTENSIONS);
    if(!cstr) // check null ptr
        return;

    std::string str(cstr);
    std::string token;
    std::string::const_iterator cursor = str.begin();
    while(cursor != str.end())
    {
        if(*cursor != ' ')
        {
            token += *cursor;
        }
        else
        {
            extensions.push_back(token);
            token.clear();
        }
        ++cursor;
    }

#ifdef _WIN32 //===========================================
    // get WGL specific extensions for v3.0+
    // HDC must be passed to wglGetExtensionsStringARB() to get WGL extensions
    HDC hdc = wglGetCurrentDC();
    wglGetExtensionsStringARB = (PFNWGLGETEXTENSIONSSTRINGARBPROC)wglGetProcAddress("wglGetExtensionsStringARB");
    if(wglGetExtensionsStringARB && hdc)
    {
        str = (const char*)wglGetExtensionsStringARB(hdc);
        std::string token;
        std::string::const_iterator cursor = str.begin();
        while(cursor != str.end())
        {
            if(*cursor != ' ')
            {
                token += *cursor;
            }
            else
            {
                extensions.push_back(token);
                token.clear();
            }
            ++cursor;
        }
    }
#endif //==================================================

    // sort extension by alphabetical order
    std::sort(this->extensions.begin(), this->extensions.end());
}



///////////////////////////////////////////////////////////////////////////////
// string utility
///////////////////////////////////////////////////////////////////////////////
std::string glExtension::toLower(const std::string& str)
{
    std::string newStr = str;
    std::transform(newStr.begin(), newStr.end(), newStr.begin(), ::tolower);
    return newStr;
}


///////////////////////////////////////////////////////////////////////////////
// get function pointers from OpenGL ICD driver
///////////////////////////////////////////////////////////////////////////////
void glExtension::getFunctionPointers()
{
#ifdef _WIN32
    std::vector<std::string>::const_iterator iter = this->extensions.begin();
    std::vector<std::string>::const_iterator endIter = this->extensions.end();
    for(int i = 0; i < (int)extensions.size(); ++i)
    {
        if(extensions[i] == "GL_ARB_framebuffer_object")
        {
            glGenFramebuffers                     = (PFNGLGENFRAMEBUFFERSPROC)wglGetProcAddress("glGenFramebuffers");
            glDeleteFramebuffers                  = (PFNGLDELETEFRAMEBUFFERSPROC)wglGetProcAddress("glDeleteFramebuffers");
            glBindFramebuffer                     = (PFNGLBINDFRAMEBUFFERPROC)wglGetProcAddress("glBindFramebuffer");
            glCheckFramebufferStatus              = (PFNGLCHECKFRAMEBUFFERSTATUSPROC)wglGetProcAddress("glCheckFramebufferStatus");
            glGetFramebufferAttachmentParameteriv = (PFNGLGETFRAMEBUFFERATTACHMENTPARAMETERIVPROC)wglGetProcAddress("glGetFramebufferAttachmentParameteriv");
            glGenerateMipmap                      = (PFNGLGENERATEMIPMAPPROC)wglGetProcAddress("glGenerateMipmap");
            glFramebufferTexture1D                = (PFNGLFRAMEBUFFERTEXTURE1DPROC)wglGetProcAddress("glFramebufferTexture1D");
            glFramebufferTexture2D                = (PFNGLFRAMEBUFFERTEXTURE2DPROC)wglGetProcAddress("glFramebufferTexture2D");
            glFramebufferTexture3D                = (PFNGLFRAMEBUFFERTEXTURE3DPROC)wglGetProcAddress("glFramebufferTexture3D");
            glFramebufferTextureLayer             = (PFNGLFRAMEBUFFERTEXTURELAYERPROC)wglGetProcAddress("glFramebufferTextureLayer");
            glFramebufferRenderbuffer             = (PFNGLFRAMEBUFFERRENDERBUFFERPROC)wglGetProcAddress("glFramebufferRenderbuffer");
            glIsFramebuffer                       = (PFNGLISFRAMEBUFFERPROC)wglGetProcAddress("glIsFramebuffer");
            glBlitFramebuffer                     = (PFNGLBLITFRAMEBUFFERPROC)wglGetProcAddress("glBlitFramebuffer");
            glGenRenderbuffers                    = (PFNGLGENRENDERBUFFERSPROC)wglGetProcAddress("glGenRenderbuffers");
            glDeleteRenderbuffers                 = (PFNGLDELETERENDERBUFFERSPROC)wglGetProcAddress("glDeleteRenderbuffers");
            glBindRenderbuffer                    = (PFNGLBINDRENDERBUFFERPROC)wglGetProcAddress("glBindRenderbuffer");
            glRenderbufferStorage                 = (PFNGLRENDERBUFFERSTORAGEPROC)wglGetProcAddress("glRenderbufferStorage");
            glRenderbufferStorageMultisample      = (PFNGLRENDERBUFFERSTORAGEMULTISAMPLEPROC)wglGetProcAddress("glRenderbufferStorageMultisample");
            glGetRenderbufferParameteriv          = (PFNGLGETRENDERBUFFERPARAMETERIVPROC)wglGetProcAddress("glGetRenderbufferParameteriv");
            glIsRenderbuffer                      = (PFNGLISRENDERBUFFERPROC)wglGetProcAddress("glIsRenderbuffer");
        }
        else if(extensions[i] == "GL_ARB_multisample")
        {
            glSampleCoverageARB = (PFNGLSAMPLECOVERAGEARBPROC)wglGetProcAddress("glSampleCoverageARB");
        }
        else if(extensions[i] == "GL_ARB_multitexture")
        {
            glActiveTextureARB = (PFNGLACTIVETEXTUREARBPROC)wglGetProcAddress("glActiveTextureARB");
        }
        else if(extensions[i] == "GL_ARB_vertex_buffer_object") // same as PBO
        {
            glGenBuffersARB             = (PFNGLGENBUFFERSARBPROC)wglGetProcAddress("glGenBuffersARB");
            glBindBufferARB             = (PFNGLBINDBUFFERARBPROC)wglGetProcAddress("glBindBufferARB");
            glBufferDataARB             = (PFNGLBUFFERDATAARBPROC)wglGetProcAddress("glBufferDataARB");
            glBufferSubDataARB          = (PFNGLBUFFERSUBDATAARBPROC)wglGetProcAddress("glBufferSubDataARB");
            glDeleteBuffersARB          = (PFNGLDELETEBUFFERSARBPROC)wglGetProcAddress("glDeleteBuffersARB");
            glGetBufferParameterivARB   = (PFNGLGETBUFFERPARAMETERIVARBPROC)wglGetProcAddress("glGetBufferParameterivARB");
            glMapBufferARB              = (PFNGLMAPBUFFERARBPROC)wglGetProcAddress("glMapBufferARB");
            glUnmapBufferARB            = (PFNGLUNMAPBUFFERARBPROC)wglGetProcAddress("glUnmapBufferARB");
        }
        else if(extensions[i] == "GL_ARB_shader_objects")
        {
            glDeleteObjectARB           = (PFNGLDELETEOBJECTARBPROC)wglGetProcAddress("glDeleteObjectARB");
            glGetHandleARB              = (PFNGLGETHANDLEARBPROC)wglGetProcAddress("glGetHandleARB");
            glDetachObjectARB           = (PFNGLDETACHOBJECTARBPROC)wglGetProcAddress("glDetachObjectARB");
            glCreateShaderObjectARB     = (PFNGLCREATESHADEROBJECTARBPROC)wglGetProcAddress("glCreateShaderObjectARB");
            glShaderSourceARB           = (PFNGLSHADERSOURCEARBPROC)wglGetProcAddress("glShaderSourceARB");
            glCompileShaderARB          = (PFNGLCOMPILESHADERARBPROC)wglGetProcAddress("glCompileShaderARB");
            glCreateProgramObjectARB    = (PFNGLCREATEPROGRAMOBJECTARBPROC)wglGetProcAddress("glCreateProgramObjectARB");
            glAttachObjectARB           = (PFNGLATTACHOBJECTARBPROC)wglGetProcAddress("glAttachObjectARB");
            glLinkProgramARB            = (PFNGLLINKPROGRAMARBPROC)wglGetProcAddress("glLinkProgramARB");
            glUseProgramObjectARB       = (PFNGLUSEPROGRAMOBJECTARBPROC)wglGetProcAddress("glUseProgramObjectARB");
            glValidateProgramARB        = (PFNGLVALIDATEPROGRAMARBPROC)wglGetProcAddress("glValidateProgramARB");
            glUniform1fARB              = (PFNGLUNIFORM1FARBPROC)wglGetProcAddress("glUniform1fARB");
            glUniform2fARB              = (PFNGLUNIFORM2FARBPROC)wglGetProcAddress("glUniform2fARB");
            glUniform3fARB              = (PFNGLUNIFORM3FARBPROC)wglGetProcAddress("glUniform3fARB");
            glUniform4fARB              = (PFNGLUNIFORM4FARBPROC)wglGetProcAddress("glUniform4fARB");
            glUniform1iARB              = (PFNGLUNIFORM1IARBPROC)wglGetProcAddress("glUniform1iARB");
            glUniform2iARB              = (PFNGLUNIFORM2IARBPROC)wglGetProcAddress("glUniform2iARB");
            glUniform3iARB              = (PFNGLUNIFORM3IARBPROC)wglGetProcAddress("glUniform3iARB");
            glUniform4iARB              = (PFNGLUNIFORM4IARBPROC)wglGetProcAddress("glUniform4iARB");
            glUniform1fvARB             = (PFNGLUNIFORM1FVARBPROC)wglGetProcAddress("glUniform1fvARB");
            glUniform2fvARB             = (PFNGLUNIFORM2FVARBPROC)wglGetProcAddress("glUniform2fvARB");
            glUniform3fvARB             = (PFNGLUNIFORM3FVARBPROC)wglGetProcAddress("glUniform3fvARB");
            glUniform4fvARB             = (PFNGLUNIFORM4FVARBPROC)wglGetProcAddress("glUniform4fvARB");
            glUniform1ivARB             = (PFNGLUNIFORM1FVARBPROC)wglGetProcAddress("glUniform1ivARB");
            glUniform2ivARB             = (PFNGLUNIFORM2FVARBPROC)wglGetProcAddress("glUniform2ivARB");
            glUniform3ivARB             = (PFNGLUNIFORM3FVARBPROC)wglGetProcAddress("glUniform3ivARB");
            glUniform4ivARB             = (PFNGLUNIFORM4FVARBPROC)wglGetProcAddress("glUniform4ivARB");
            glUniformMatrix2fvARB       = (PFNGLUNIFORMMATRIX2FVARBPROC)wglGetProcAddress("glUniformMatrix2fvARB");
            glUniformMatrix3fvARB       = (PFNGLUNIFORMMATRIX3FVARBPROC)wglGetProcAddress("glUniformMatrix3fvARB");
            glUniformMatrix4fvARB       = (PFNGLUNIFORMMATRIX4FVARBPROC)wglGetProcAddress("glUniformMatrix4fvARB");
            glGetObjectParameterfvARB   = (PFNGLGETOBJECTPARAMETERFVARBPROC)wglGetProcAddress("glGetObjectParameterfvARB");
            glGetObjectParameterivARB   = (PFNGLGETOBJECTPARAMETERIVARBPROC)wglGetProcAddress("glGetObjectParameterivARB");
            glGetInfoLogARB             = (PFNGLGETINFOLOGARBPROC)wglGetProcAddress("glGetInfoLogARB");
            glGetAttachedObjectsARB     = (PFNGLGETATTACHEDOBJECTSARBPROC)wglGetProcAddress("glGetAttachedObjectsARB");
            glGetUniformLocationARB     = (PFNGLGETUNIFORMLOCATIONARBPROC)wglGetProcAddress("glGetUniformLocationARB");
            glGetActiveUniformARB       = (PFNGLGETACTIVEUNIFORMARBPROC)wglGetProcAddress("glGetActiveUniformARB");
            glGetUniformfvARB           = (PFNGLGETUNIFORMFVARBPROC)wglGetProcAddress("glGetUniformfvARB");
            glGetUniformivARB           = (PFNGLGETUNIFORMIVARBPROC)wglGetProcAddress("glGetUniformivARB");
            glGetShaderSourceARB        = (PFNGLGETSHADERSOURCEARBPROC)wglGetProcAddress("glGetShaderSourceARB");
            // core version
            glAttachShader              = (PFNGLATTACHSHADERPROC)wglGetProcAddress("glAttachShader");
            glCompileShader             = (PFNGLCOMPILESHADERPROC)wglGetProcAddress("glCompileShader");
            glCreateProgram             = (PFNGLCREATEPROGRAMPROC)wglGetProcAddress("glCreateProgram");
            glCreateShader              = (PFNGLCREATESHADERPROC)wglGetProcAddress("glCreateShader");
            glDeleteProgram             = (PFNGLDELETEPROGRAMPROC)wglGetProcAddress("glDeleteProgram");
            glDeleteShader              = (PFNGLDELETESHADERPROC)wglGetProcAddress("glDeleteShader");
            glDetachShader              = (PFNGLDETACHSHADERPROC)wglGetProcAddress("glDetachShader");
            glGetActiveUniform          = (PFNGLGETACTIVEUNIFORMPROC)wglGetProcAddress("glGetActiveUniform");
            glGetAttachedShaders        = (PFNGLGETATTACHEDSHADERSPROC)wglGetProcAddress("glGetAttachedShaders");
            glGetProgramiv              = (PFNGLGETPROGRAMIVPROC)wglGetProcAddress("glGetProgramiv");
            glGetProgramInfoLog         = (PFNGLGETPROGRAMINFOLOGPROC)wglGetProcAddress("glGetProgramInfoLog");
            glGetShaderiv               = (PFNGLGETSHADERIVPROC)wglGetProcAddress("glGetShaderiv");
            glGetShaderInfoLog          = (PFNGLGETSHADERINFOLOGPROC)wglGetProcAddress("glGetShaderInfoLog");
            glGetShaderSource           = (PFNGLGETSHADERSOURCEPROC)wglGetProcAddress("glGetShaderSource");
            glGetUniformLocation        = (PFNGLGETUNIFORMLOCATIONPROC)wglGetProcAddress("glGetUniformLocation");
            glGetUniformfv              = (PFNGLGETUNIFORMFVPROC)wglGetProcAddress("glGetUniformfv");
            glGetUniformiv              = (PFNGLGETUNIFORMIVPROC)wglGetProcAddress("glGetUniformiv");
            glLinkProgram               = (PFNGLLINKPROGRAMPROC)wglGetProcAddress("glLinkProgram");
            glShaderSource              = (PFNGLSHADERSOURCEPROC)wglGetProcAddress("glShaderSource");
            glUseProgram                = (PFNGLUSEPROGRAMPROC)wglGetProcAddress("glUseProgram");
            glUniform1f                 = (PFNGLUNIFORM1FPROC)wglGetProcAddress("glUniform1f");
            glUniform2f                 = (PFNGLUNIFORM2FPROC)wglGetProcAddress("glUniform2f");
            glUniform3f                 = (PFNGLUNIFORM3FPROC)wglGetProcAddress("glUniform3f");
            glUniform4f                 = (PFNGLUNIFORM4FPROC)wglGetProcAddress("glUniform4f");
            glUniform1i                 = (PFNGLUNIFORM1IPROC)wglGetProcAddress("glUniform1i");
            glUniform2i                 = (PFNGLUNIFORM2IPROC)wglGetProcAddress("glUniform2i");
            glUniform3i                 = (PFNGLUNIFORM3IPROC)wglGetProcAddress("glUniform3i");
            glUniform4i                 = (PFNGLUNIFORM4IPROC)wglGetProcAddress("glUniform4i");
            glUniform1fv                = (PFNGLUNIFORM1FVPROC)wglGetProcAddress("glUniform1fv");
            glUniform2fv                = (PFNGLUNIFORM2FVPROC)wglGetProcAddress("glUniform2fv");
            glUniform3fv                = (PFNGLUNIFORM3FVPROC)wglGetProcAddress("glUniform3fv");
            glUniform4fv                = (PFNGLUNIFORM4FVPROC)wglGetProcAddress("glUniform4fv");
            glUniform1iv                = (PFNGLUNIFORM1FVPROC)wglGetProcAddress("glUniform1iv");
            glUniform2iv                = (PFNGLUNIFORM2FVPROC)wglGetProcAddress("glUniform2iv");
            glUniform3iv                = (PFNGLUNIFORM3FVPROC)wglGetProcAddress("glUniform3iv");
            glUniform4iv                = (PFNGLUNIFORM4FVPROC)wglGetProcAddress("glUniform4iv");
            glUniformMatrix2fv          = (PFNGLUNIFORMMATRIX2FVPROC)wglGetProcAddress("glUniformMatrix2fv");
            glUniformMatrix3fv          = (PFNGLUNIFORMMATRIX3FVPROC)wglGetProcAddress("glUniformMatrix3fv");
            glUniformMatrix4fv          = (PFNGLUNIFORMMATRIX4FVPROC)wglGetProcAddress("glUniformMatrix4fv");
            glValidateProgram           = (PFNGLVALIDATEPROGRAMPROC)wglGetProcAddress("glValidateProgram");
        }
        else if(extensions[i] == "GL_ARB_sync")
        {
            glFenceSync         = (PFNGLFENCESYNCPROC)wglGetProcAddress("glFenceSync");
            glIsSync            = (PFNGLISSYNCPROC)wglGetProcAddress("glIsSync");
            glDeleteSync        = (PFNGLDELETESYNCPROC)wglGetProcAddress("glDeleteSync");
            glClientWaitSync    = (PFNGLCLIENTWAITSYNCPROC)wglGetProcAddress("glClientWaitSync");
            glWaitSync          = (PFNGLWAITSYNCPROC)wglGetProcAddress("glWaitSync");
            glGetInteger64v     = (PFNGLGETINTEGER64VPROC)wglGetProcAddress("glGetInteger64v");
            glGetSynciv         = (PFNGLGETSYNCIVPROC)wglGetProcAddress("glGetSynciv");
        }
        else if(extensions[i] == "GL_ARB_vertex_array_object")
        {
            glGenVertexArrays       = (PFNGLGENVERTEXARRAYSPROC)wglGetProcAddress("glGenVertexArrays");
            glDeleteVertexArrays    = (PFNGLDELETEVERTEXARRAYSPROC)wglGetProcAddress("glDeleteVertexArrays");
            glBindVertexArray       = (PFNGLBINDVERTEXARRAYPROC)wglGetProcAddress("glBindVertexArray");
            glIsVertexArray         = (PFNGLISVERTEXARRAYPROC)wglGetProcAddress("glIsVertexArray");
        }
        else if(extensions[i] == "GL_ARB_vertex_shader") // also GL_ARB_fragment_shader
        {
            glBindAttribLocationARB = (PFNGLBINDATTRIBLOCATIONARBPROC)wglGetProcAddress("glBindAttribLocationARB");
            glGetActiveAttribARB    = (PFNGLGETACTIVEATTRIBARBPROC)wglGetProcAddress("glGetActiveAttribARB");
            glGetAttribLocationARB  = (PFNGLGETATTRIBLOCATIONARBPROC)wglGetProcAddress("glGetAttribLocationARB");
            //@@ GLSL core version
            glBindAttribLocation    = (PFNGLBINDATTRIBLOCATIONPROC)wglGetProcAddress("glBindAttribLocation");
            glGetActiveAttrib       = (PFNGLGETACTIVEATTRIBPROC)wglGetProcAddress("glGetActiveAttrib");
            glGetAttribLocation     = (PFNGLGETATTRIBLOCATIONPROC)wglGetProcAddress("glGetAttribLocation");
        }
        else if(extensions[i] == "GL_ARB_vertex_program") // also GL_ARB_fragment_program
        {
            glVertexAttrib1dARB             = (PFNGLVERTEXATTRIB1DARBPROC)wglGetProcAddress("glVertexAttrib1dARB");
            glVertexAttrib1dvARB            = (PFNGLVERTEXATTRIB1DVARBPROC)wglGetProcAddress("glVertexAttrib1dvARB");
            glVertexAttrib1fARB             = (PFNGLVERTEXATTRIB1FARBPROC)wglGetProcAddress("glVertexAttrib1fARB");
            glVertexAttrib1fvARB            = (PFNGLVERTEXATTRIB1FVARBPROC)wglGetProcAddress("glVertexAttrib1fvARB");
            glVertexAttrib1sARB             = (PFNGLVERTEXATTRIB1SARBPROC)wglGetProcAddress("glVertexAttrib1sARB");
            glVertexAttrib1svARB            = (PFNGLVERTEXATTRIB1SVARBPROC)wglGetProcAddress("glVertexAttrib1svARB");
            glVertexAttrib2dARB             = (PFNGLVERTEXATTRIB2DARBPROC)wglGetProcAddress("glVertexAttrib2dARB");
            glVertexAttrib2dvARB            = (PFNGLVERTEXATTRIB2DVARBPROC)wglGetProcAddress("glVertexAttrib2dvARB");
            glVertexAttrib2fARB             = (PFNGLVERTEXATTRIB2FARBPROC)wglGetProcAddress("glVertexAttrib2fARB");
            glVertexAttrib2fvARB            = (PFNGLVERTEXATTRIB2FVARBPROC)wglGetProcAddress("glVertexAttrib2fvARB");
            glVertexAttrib2sARB             = (PFNGLVERTEXATTRIB2SARBPROC)wglGetProcAddress("glVertexAttrib2sARB");
            glVertexAttrib2svARB            = (PFNGLVERTEXATTRIB2SVARBPROC)wglGetProcAddress("glVertexAttrib2svARB");
            glVertexAttrib3dARB             = (PFNGLVERTEXATTRIB3DARBPROC)wglGetProcAddress("glVertexAttrib3dARB");
            glVertexAttrib3dvARB            = (PFNGLVERTEXATTRIB3DVARBPROC)wglGetProcAddress("glVertexAttrib3dvARB");
            glVertexAttrib3fARB             = (PFNGLVERTEXATTRIB3FARBPROC)wglGetProcAddress("glVertexAttrib3fARB");
            glVertexAttrib3fvARB            = (PFNGLVERTEXATTRIB3FVARBPROC)wglGetProcAddress("glVertexAttrib3fvARB");
            glVertexAttrib3sARB             = (PFNGLVERTEXATTRIB3SARBPROC)wglGetProcAddress("glVertexAttrib3sARB");
            glVertexAttrib3svARB            = (PFNGLVERTEXATTRIB3SVARBPROC)wglGetProcAddress("glVertexAttrib3svARB");
            glVertexAttrib4NbvARB           = (PFNGLVERTEXATTRIB4NBVARBPROC)wglGetProcAddress("glVertexAttrib4NbvARB");
            glVertexAttrib4NivARB           = (PFNGLVERTEXATTRIB4NIVARBPROC)wglGetProcAddress("glVertexAttrib4NivARB");
            glVertexAttrib4NsvARB           = (PFNGLVERTEXATTRIB4NSVARBPROC)wglGetProcAddress("glVertexAttrib4NsvARB");
            glVertexAttrib4NubARB           = (PFNGLVERTEXATTRIB4NUBARBPROC)wglGetProcAddress("glVertexAttrib4NubARB");
            glVertexAttrib4NubvARB          = (PFNGLVERTEXATTRIB4NUBVARBPROC)wglGetProcAddress("glVertexAttrib4NubvARB");
            glVertexAttrib4NuivARB          = (PFNGLVERTEXATTRIB4NUIVARBPROC)wglGetProcAddress("glVertexAttrib4NuivARB");
            glVertexAttrib4NusvARB          = (PFNGLVERTEXATTRIB4NUSVARBPROC)wglGetProcAddress("glVertexAttrib4NusvARB");
            glVertexAttrib4bvARB            = (PFNGLVERTEXATTRIB4BVARBPROC)wglGetProcAddress("glVertexAttrib4bvARB");
            glVertexAttrib4dARB             = (PFNGLVERTEXATTRIB4DARBPROC)wglGetProcAddress("glVertexAttrib4dARB");
            glVertexAttrib4dvARB            = (PFNGLVERTEXATTRIB4DVARBPROC)wglGetProcAddress("glVertexAttrib4dvARB");
            glVertexAttrib4fARB             = (PFNGLVERTEXATTRIB4FARBPROC)wglGetProcAddress("glVertexAttrib4fARB");
            glVertexAttrib4fvARB            = (PFNGLVERTEXATTRIB4FVARBPROC)wglGetProcAddress("glVertexAttrib4fvARB");
            glVertexAttrib4ivARB            = (PFNGLVERTEXATTRIB4IVARBPROC)wglGetProcAddress("glVertexAttrib4ivARB");
            glVertexAttrib4sARB             = (PFNGLVERTEXATTRIB4SARBPROC)wglGetProcAddress("glVertexAttrib4sARB");
            glVertexAttrib4svARB            = (PFNGLVERTEXATTRIB4SVARBPROC)wglGetProcAddress("glVertexAttrib4svARB");
            glVertexAttrib4ubvARB           = (PFNGLVERTEXATTRIB4UBVARBPROC)wglGetProcAddress("glVertexAttrib4ubvARB");
            glVertexAttrib4uivARB           = (PFNGLVERTEXATTRIB4UIVARBPROC)wglGetProcAddress("glVertexAttrib4uivARB");
            glVertexAttrib4usvARB           = (PFNGLVERTEXATTRIB4USVARBPROC)wglGetProcAddress("glVertexAttrib4usvARB");
            glVertexAttribPointerARB        = (PFNGLVERTEXATTRIBPOINTERARBPROC)wglGetProcAddress("glVertexAttribPointerARB");
            glEnableVertexAttribArrayARB    = (PFNGLENABLEVERTEXATTRIBARRAYARBPROC)wglGetProcAddress("glEnableVertexAttribArrayARB");
            glDisableVertexAttribArrayARB   = (PFNGLDISABLEVERTEXATTRIBARRAYARBPROC)wglGetProcAddress("glDisableVertexAttribArrayARB");
            glProgramStringARB              = (PFNGLPROGRAMSTRINGARBPROC)wglGetProcAddress("glProgramStringARB");
            glBindProgramARB                = (PFNGLBINDPROGRAMARBPROC)wglGetProcAddress("glBindProgramARB");
            glDeleteProgramsARB             = (PFNGLDELETEPROGRAMSARBPROC)wglGetProcAddress("glDeleteProgramsARB");
            glGenProgramsARB                = (PFNGLGENPROGRAMSARBPROC)wglGetProcAddress("glGenProgramsARB");
            glProgramEnvParameter4dARB      = (PFNGLPROGRAMENVPARAMETER4DARBPROC)wglGetProcAddress("glProgramEnvParameter4dARB");
            glProgramEnvParameter4dvARB     = (PFNGLPROGRAMENVPARAMETER4DVARBPROC)wglGetProcAddress("glProgramEnvParameter4dvARB");
            glProgramEnvParameter4fARB      = (PFNGLPROGRAMENVPARAMETER4FARBPROC)wglGetProcAddress("glProgramEnvParameter4fARB");
            glProgramEnvParameter4fvARB     = (PFNGLPROGRAMENVPARAMETER4FVARBPROC)wglGetProcAddress("glProgramEnvParameter4fvARB");
            glProgramLocalParameter4dARB    = (PFNGLPROGRAMLOCALPARAMETER4DARBPROC)wglGetProcAddress("glProgramLocalParameter4dARB");
            glProgramLocalParameter4dvARB   = (PFNGLPROGRAMLOCALPARAMETER4DVARBPROC)wglGetProcAddress("glProgramLocalParameter4dvARB");
            glProgramLocalParameter4fARB    = (PFNGLPROGRAMLOCALPARAMETER4FARBPROC)wglGetProcAddress("glProgramLocalParameter4fARB");
            glProgramLocalParameter4fvARB   = (PFNGLPROGRAMLOCALPARAMETER4FVARBPROC)wglGetProcAddress("glProgramLocalParameter4fvARB");
            glGetProgramEnvParameterdvARB   = (PFNGLGETPROGRAMENVPARAMETERDVARBPROC)wglGetProcAddress("glGetProgramEnvParameterdvARB");
            glGetProgramEnvParameterfvARB   = (PFNGLGETPROGRAMENVPARAMETERFVARBPROC)wglGetProcAddress("glGetProgramEnvParameterfvARB");
            glGetProgramLocalParameterdvARB = (PFNGLGETPROGRAMLOCALPARAMETERDVARBPROC)wglGetProcAddress("glGetProgramLocalParameterdvARB");
            glGetProgramLocalParameterfvARB = (PFNGLGETPROGRAMLOCALPARAMETERFVARBPROC)wglGetProcAddress("glGetProgramLocalParameterfvARB");
            glGetProgramivARB               = (PFNGLGETPROGRAMIVARBPROC)wglGetProcAddress("glGetProgramivARB");
            glGetProgramStringARB           = (PFNGLGETPROGRAMSTRINGARBPROC)wglGetProcAddress("glGetProgramStringARB");
            glGetVertexAttribdvARB          = (PFNGLGETVERTEXATTRIBDVARBPROC)wglGetProcAddress("glGetVertexAttribdvARB");
            glGetVertexAttribfvARB          = (PFNGLGETVERTEXATTRIBFVARBPROC)wglGetProcAddress("glGetVertexAttribfvARB");
            glGetVertexAttribivARB          = (PFNGLGETVERTEXATTRIBIVARBPROC)wglGetProcAddress("glGetVertexAttribivARB");
            glGetVertexAttribPointervARB    = (PFNGLGETVERTEXATTRIBPOINTERVARBPROC)wglGetProcAddress("glGetVertexAttribPointervARB");
            glIsProgramARB                  = (PFNGLISPROGRAMARBPROC)wglGetProcAddress("glIsProgramARB");
            //@@ v2.0 core version
            glDisableVertexAttribArray      = (PFNGLDISABLEVERTEXATTRIBARRAYPROC)wglGetProcAddress("glDisableVertexAttribArray");
            glEnableVertexAttribArray       = (PFNGLENABLEVERTEXATTRIBARRAYPROC)wglGetProcAddress("glEnableVertexAttribArray");
            glGetVertexAttribdv             = (PFNGLGETVERTEXATTRIBDVPROC)wglGetProcAddress("glGetVertexAttribdv");
            glGetVertexAttribfv             = (PFNGLGETVERTEXATTRIBFVPROC)wglGetProcAddress("glGetVertexAttribfv");
            glGetVertexAttribiv             = (PFNGLGETVERTEXATTRIBIVPROC)wglGetProcAddress("glGetVertexAttribiv");
            glGetVertexAttribPointerv       = (PFNGLGETVERTEXATTRIBPOINTERVPROC)wglGetProcAddress("glGetVertexAttribPointerv");
            glIsProgram                     = (PFNGLISPROGRAMPROC)wglGetProcAddress("glIsProgram");
            glIsShader                      = (PFNGLISSHADERPROC)wglGetProcAddress("glIsShader");
            glVertexAttrib1d                = (PFNGLVERTEXATTRIB1DPROC)wglGetProcAddress("glVertexAttrib1d");
            glVertexAttrib1dv               = (PFNGLVERTEXATTRIB1DVPROC)wglGetProcAddress("glVertexAttrib1dv");
            glVertexAttrib1f                = (PFNGLVERTEXATTRIB1FPROC)wglGetProcAddress("glVertexAttrib1f");
            glVertexAttrib1fv               = (PFNGLVERTEXATTRIB1FVPROC)wglGetProcAddress("glVertexAttrib1fv");
            glVertexAttrib1s                = (PFNGLVERTEXATTRIB1SPROC)wglGetProcAddress("glVertexAttrib1s");
            glVertexAttrib1sv               = (PFNGLVERTEXATTRIB1SVPROC)wglGetProcAddress("glVertexAttrib1sv");
            glVertexAttrib2d                = (PFNGLVERTEXATTRIB2DPROC)wglGetProcAddress("glVertexAttrib2d");
            glVertexAttrib2dv               = (PFNGLVERTEXATTRIB2DVPROC)wglGetProcAddress("glVertexAttrib2dv");
            glVertexAttrib2f                = (PFNGLVERTEXATTRIB2FPROC)wglGetProcAddress("glVertexAttrib2f");
            glVertexAttrib2fv               = (PFNGLVERTEXATTRIB2FVPROC)wglGetProcAddress("glVertexAttrib2fv");
            glVertexAttrib2s                = (PFNGLVERTEXATTRIB2SPROC)wglGetProcAddress("glVertexAttrib2s");
            glVertexAttrib2sv               = (PFNGLVERTEXATTRIB2SVPROC)wglGetProcAddress("glVertexAttrib2sv");
            glVertexAttrib3d                = (PFNGLVERTEXATTRIB3DPROC)wglGetProcAddress("glVertexAttrib3d");
            glVertexAttrib3dv               = (PFNGLVERTEXATTRIB3DVPROC)wglGetProcAddress("glVertexAttrib3dv");
            glVertexAttrib3f                = (PFNGLVERTEXATTRIB3FPROC)wglGetProcAddress("glVertexAttrib3f");
            glVertexAttrib3fv               = (PFNGLVERTEXATTRIB3FVPROC)wglGetProcAddress("glVertexAttrib3fv");
            glVertexAttrib3s                = (PFNGLVERTEXATTRIB3SPROC)wglGetProcAddress("glVertexAttrib3s");
            glVertexAttrib3sv               = (PFNGLVERTEXATTRIB3SVPROC)wglGetProcAddress("glVertexAttrib3sv");
            glVertexAttrib4Nbv              = (PFNGLVERTEXATTRIB4NBVPROC)wglGetProcAddress("glVertexAttrib4Nbv");
            glVertexAttrib4Niv              = (PFNGLVERTEXATTRIB4NIVPROC)wglGetProcAddress("glVertexAttrib4Niv");
            glVertexAttrib4Nsv              = (PFNGLVERTEXATTRIB4NSVPROC)wglGetProcAddress("glVertexAttrib4Nsv");
            glVertexAttrib4Nub              = (PFNGLVERTEXATTRIB4NUBPROC)wglGetProcAddress("glVertexAttrib4Nub");
            glVertexAttrib4Nubv             = (PFNGLVERTEXATTRIB4NUBVPROC)wglGetProcAddress("glVertexAttrib4Nubv");
            glVertexAttrib4Nuiv             = (PFNGLVERTEXATTRIB4NUIVPROC)wglGetProcAddress("glVertexAttrib4Nuiv");
            glVertexAttrib4Nusv             = (PFNGLVERTEXATTRIB4NUSVPROC)wglGetProcAddress("glVertexAttrib4Nusv");
            glVertexAttrib4bv               = (PFNGLVERTEXATTRIB4BVPROC)wglGetProcAddress("glVertexAttrib4bv");
            glVertexAttrib4d                = (PFNGLVERTEXATTRIB4DPROC)wglGetProcAddress("glVertexAttrib4d");
            glVertexAttrib4dv               = (PFNGLVERTEXATTRIB4DVPROC)wglGetProcAddress("glVertexAttrib4dv");
            glVertexAttrib4f                = (PFNGLVERTEXATTRIB4FPROC)wglGetProcAddress("glVertexAttrib4f");
            glVertexAttrib4fv               = (PFNGLVERTEXATTRIB4FVPROC)wglGetProcAddress("glVertexAttrib4fv");
            glVertexAttrib4iv               = (PFNGLVERTEXATTRIB4IVPROC)wglGetProcAddress("glVertexAttrib4iv");
            glVertexAttrib4s                = (PFNGLVERTEXATTRIB4SPROC)wglGetProcAddress("glVertexAttrib4s");
            glVertexAttrib4sv               = (PFNGLVERTEXATTRIB4SVPROC)wglGetProcAddress("glVertexAttrib4sv");
            glVertexAttrib4ubv              = (PFNGLVERTEXATTRIB4UBVPROC)wglGetProcAddress("glVertexAttrib4ubv");
            glVertexAttrib4uiv              = (PFNGLVERTEXATTRIB4UIVPROC)wglGetProcAddress("glVertexAttrib4uiv");
            glVertexAttrib4usv              = (PFNGLVERTEXATTRIB4USVPROC)wglGetProcAddress("glVertexAttrib4usv");
            glVertexAttribPointer           = (PFNGLVERTEXATTRIBPOINTERPROC)wglGetProcAddress("glVertexAttribPointer");
        }
        else if(extensions[i] == "GL_ARB_debug_output")
        {
            glDebugMessageControlARB  = (PFNGLDEBUGMESSAGECONTROLARBPROC)wglGetProcAddress("glDebugMessageControlARB");
            glDebugMessageInsertARB   = (PFNGLDEBUGMESSAGEINSERTARBPROC)wglGetProcAddress("glDebugMessageInsertARB");
            glDebugMessageCallbackARB = (PFNGLDEBUGMESSAGECALLBACKARBPROC)wglGetProcAddress("glDebugMessageCallbackARB");
            glGetDebugMessageLogARB   = (PFNGLGETDEBUGMESSAGELOGARBPROC)wglGetProcAddress("glGetDebugMessageLogARB");
        }
        else if(extensions[i] == "GL_ARB_direct_state_access")
        {
             // for transform feedback object
            glCreateTransformFeedbacks                 = (PFNGLCREATETRANSFORMFEEDBACKSPROC)wglGetProcAddress("glCreateTransformFeedbacks");
            glTransformFeedbackBufferBase              = (PFNGLTRANSFORMFEEDBACKBUFFERBASEPROC)wglGetProcAddress("glTransformFeedbackBufferBase");
            glTransformFeedbackBufferRange             = (PFNGLTRANSFORMFEEDBACKBUFFERRANGEPROC)wglGetProcAddress("glTransformFeedbackBufferRange");
            glGetTransformFeedbackiv                   = (PFNGLGETTRANSFORMFEEDBACKIVPROC)wglGetProcAddress("pglGetTransformFeedbackiv");
            glGetTransformFeedbacki_v                  = (PFNGLGETTRANSFORMFEEDBACKI_VPROC)wglGetProcAddress("pglGetTransformFeedbacki_v");
            glGetTransformFeedbacki64_v                = (PFNGLGETTRANSFORMFEEDBACKI64_VPROC)wglGetProcAddress("pglGetTransformFeedbacki64_v");
            // for buffer object
            glCreateBuffers                            = (PFNGLCREATEBUFFERSPROC)wglGetProcAddress("glCreateBuffers");
            glNamedBufferStorage                       = (PFNGLNAMEDBUFFERSTORAGEPROC)wglGetProcAddress("glNamedBufferStorage");
            glNamedBufferData                          = (PFNGLNAMEDBUFFERDATAPROC)wglGetProcAddress("glNamedBufferData");
            glNamedBufferSubData                       = (PFNGLNAMEDBUFFERSUBDATAPROC)wglGetProcAddress("glNamedBufferSubData");
            glCopyNamedBufferSubData                   = (PFNGLCOPYNAMEDBUFFERSUBDATAPROC)wglGetProcAddress("glCopyNamedBufferSubData");
            glClearNamedBufferData                     = (PFNGLCLEARNAMEDBUFFERDATAPROC)wglGetProcAddress("glClearNamedBufferData");
            glClearNamedBufferSubData                  = (PFNGLCLEARNAMEDBUFFERSUBDATAPROC)wglGetProcAddress("glClearNamedBufferSubData");
            glMapNamedBuffer                           = (PFNGLMAPNAMEDBUFFERPROC)wglGetProcAddress("glMapNamedBuffer");
            glMapNamedBufferRange                      = (PFNGLMAPNAMEDBUFFERRANGEPROC)wglGetProcAddress("glMapNamedBufferRange");
            glUnmapNamedBuffer                         = (PFNGLUNMAPNAMEDBUFFERPROC)wglGetProcAddress("glUnmapNamedBuffer");
            glFlushMappedNamedBufferRange              = (PFNGLFLUSHMAPPEDNAMEDBUFFERRANGEPROC)wglGetProcAddress("glFlushMappedNamedBufferRange");
            glGetNamedBufferParameteriv                = (PFNGLGETNAMEDBUFFERPARAMETERIVPROC)wglGetProcAddress("glGetNamedBufferParameteriv");
            glGetNamedBufferParameteri64v              = (PFNGLGETNAMEDBUFFERPARAMETERI64VPROC)wglGetProcAddress("glGetNamedBufferParameteri64v");
            glGetNamedBufferPointerv                   = (PFNGLGETNAMEDBUFFERPOINTERVPROC)wglGetProcAddress("glGetNamedBufferPointerv");
            glGetNamedBufferSubData                    = (PFNGLGETNAMEDBUFFERSUBDATAPROC)wglGetProcAddress("glGetNamedBufferSubData");
            // for framebuffer object
            glCreateFramebuffers                       = (PFNGLCREATEFRAMEBUFFERSPROC)wglGetProcAddress("glCreateFramebuffers");
            glNamedFramebufferRenderbuffer             = (PFNGLNAMEDFRAMEBUFFERRENDERBUFFERPROC)wglGetProcAddress("glNamedFramebufferRenderbuffer");
            glNamedFramebufferParameteri               = (PFNGLNAMEDFRAMEBUFFERPARAMETERIPROC)wglGetProcAddress("glNamedFramebufferParameteri");
            glNamedFramebufferTexture                  = (PFNGLNAMEDFRAMEBUFFERTEXTUREPROC)wglGetProcAddress("glNamedFramebufferTexture");
            glNamedFramebufferTextureLayer             = (PFNGLNAMEDFRAMEBUFFERTEXTURELAYERPROC)wglGetProcAddress("glNamedFramebufferTextureLayer");
            glNamedFramebufferDrawBuffer               = (PFNGLNAMEDFRAMEBUFFERDRAWBUFFERPROC)wglGetProcAddress("glNamedFramebufferDrawBuffer");
            glNamedFramebufferDrawBuffers              = (PFNGLNAMEDFRAMEBUFFERDRAWBUFFERSPROC)wglGetProcAddress("glNamedFramebufferDrawBuffers");
            glNamedFramebufferReadBuffer               = (PFNGLNAMEDFRAMEBUFFERREADBUFFERPROC)wglGetProcAddress("glNamedFramebufferReadBuffer");
            glInvalidateNamedFramebufferData           = (PFNGLINVALIDATENAMEDFRAMEBUFFERDATAPROC)wglGetProcAddress("glInvalidateNamedFramebufferData");
            glInvalidateNamedFramebufferSubData        = (PFNGLINVALIDATENAMEDFRAMEBUFFERSUBDATAPROC)wglGetProcAddress("glInvalidateNamedFramebufferSubData");
            glClearNamedFramebufferiv                  = (PFNGLCLEARNAMEDFRAMEBUFFERIVPROC)wglGetProcAddress("glClearNamedFramebufferiv");
            glClearNamedFramebufferuiv                 = (PFNGLCLEARNAMEDFRAMEBUFFERUIVPROC)wglGetProcAddress("glClearNamedFramebufferuiv");
            glClearNamedFramebufferfv                  = (PFNGLCLEARNAMEDFRAMEBUFFERFVPROC)wglGetProcAddress("glClearNamedFramebufferfv");
            glClearNamedFramebufferfi                  = (PFNGLCLEARNAMEDFRAMEBUFFERFIPROC)wglGetProcAddress("glClearNamedFramebufferfi");
            glBlitNamedFramebuffer                     = (PFNGLBLITNAMEDFRAMEBUFFERPROC)wglGetProcAddress("glBlitNamedFramebuffer");
            glCheckNamedFramebufferStatus              = (PFNGLCHECKNAMEDFRAMEBUFFERSTATUSPROC)wglGetProcAddress("glCheckNamedFramebufferStatus");
            glGetNamedFramebufferParameteriv           = (PFNGLGETNAMEDFRAMEBUFFERPARAMETERIVPROC)wglGetProcAddress("glGetNamedFramebufferParameteriv");
            glGetNamedFramebufferAttachmentParameteriv = (PFNGLGETNAMEDFRAMEBUFFERATTACHMENTPARAMETERIVPROC)wglGetProcAddress("glGetNamedFramebufferAttachmentParameteriv");
            // for renderbuffer object
            glCreateRenderbuffers                      = (PFNGLCREATERENDERBUFFERSPROC)wglGetProcAddress("glCreateRenderbuffers");
            glNamedRenderbufferStorage                 = (PFNGLNAMEDRENDERBUFFERSTORAGEPROC)wglGetProcAddress("glNamedRenderbufferStorage");
            glNamedRenderbufferStorageMultisample      = (PFNGLNAMEDRENDERBUFFERSTORAGEMULTISAMPLEPROC)wglGetProcAddress("glNamedRenderbufferStorageMultisample");
            glGetNamedRenderbufferParameteriv          = (PFNGLGETNAMEDRENDERBUFFERPARAMETERIVPROC)wglGetProcAddress("glGetNamedRenderbufferParameteriv");
            // for texture object
            glCreateTextures                           = (PFNGLCREATETEXTURESPROC)wglGetProcAddress("glCreateTextures");
            glTextureBuffer                            = (PFNGLTEXTUREBUFFERPROC)wglGetProcAddress("glTextureBuffer");
            glTextureBufferRange                       = (PFNGLTEXTUREBUFFERRANGEPROC)wglGetProcAddress("glTextureBufferRange");
            glTextureStorage1D                         = (PFNGLTEXTURESTORAGE1DPROC)wglGetProcAddress("glTextureStorage1D");
            glTextureStorage2D                         = (PFNGLTEXTURESTORAGE2DPROC)wglGetProcAddress("glTextureStorage2D");
            glTextureStorage3D                         = (PFNGLTEXTURESTORAGE3DPROC)wglGetProcAddress("glTextureStorage3D");
            glTextureStorage2DMultisample              = (PFNGLTEXTURESTORAGE2DMULTISAMPLEPROC)wglGetProcAddress("glTextureStorage2DMultisample");
            glTextureStorage3DMultisample              = (PFNGLTEXTURESTORAGE3DMULTISAMPLEPROC)wglGetProcAddress("glTextureStorage3DMultisample");
            glTextureSubImage1D                        = (PFNGLTEXTURESUBIMAGE1DPROC)wglGetProcAddress("glTextureSubImage1D");
            glTextureSubImage2D                        = (PFNGLTEXTURESUBIMAGE2DPROC)wglGetProcAddress("glTextureSubImage2D");
            glTextureSubImage3D                        = (PFNGLTEXTURESUBIMAGE3DPROC)wglGetProcAddress("glTextureSubImage3D");
            glCompressedTextureSubImage1D              = (PFNGLCOMPRESSEDTEXTURESUBIMAGE1DPROC)wglGetProcAddress("glCompressedTextureSubImage1D");
            glCompressedTextureSubImage2D              = (PFNGLCOMPRESSEDTEXTURESUBIMAGE2DPROC)wglGetProcAddress("glCompressedTextureSubImage2D");
            glCompressedTextureSubImage3D              = (PFNGLCOMPRESSEDTEXTURESUBIMAGE3DPROC)wglGetProcAddress("glCompressedTextureSubImage3D");
            glCopyTextureSubImage1D                    = (PFNGLCOPYTEXTURESUBIMAGE1DPROC)wglGetProcAddress("glCopyTextureSubImage1D");
            glCopyTextureSubImage2D                    = (PFNGLCOPYTEXTURESUBIMAGE2DPROC)wglGetProcAddress("glCopyTextureSubImage2D");
            glCopyTextureSubImage3D                    = (PFNGLCOPYTEXTURESUBIMAGE3DPROC)wglGetProcAddress("glCopyTextureSubImage3D");
            glTextureParameterf                        = (PFNGLTEXTUREPARAMETERFPROC)wglGetProcAddress("glTextureParameterf");
            glTextureParameterfv                       = (PFNGLTEXTUREPARAMETERFVPROC)wglGetProcAddress("glTextureParameterfv");
            glTextureParameteri                        = (PFNGLTEXTUREPARAMETERIPROC)wglGetProcAddress("glTextureParameteri");
            glTextureParameterIiv                      = (PFNGLTEXTUREPARAMETERIIVPROC)wglGetProcAddress("glTextureParameterIiv");
            glTextureParameterIuiv                     = (PFNGLTEXTUREPARAMETERIUIVPROC)wglGetProcAddress("glTextureParameterIuiv");
            glTextureParameteriv                       = (PFNGLTEXTUREPARAMETERIVPROC)wglGetProcAddress("glTextureParameteriv");
            glGenerateTextureMipmap                    = (PFNGLGENERATETEXTUREMIPMAPPROC)wglGetProcAddress("glGenerateTextureMipmap");
            glBindTextureUnit                          = (PFNGLBINDTEXTUREUNITPROC)wglGetProcAddress("glBindTextureUnit");
            glGetTextureImage                          = (PFNGLGETTEXTUREIMAGEPROC)wglGetProcAddress("glGetTextureImage");
            glGetCompressedTextureImage                = (PFNGLGETCOMPRESSEDTEXTUREIMAGEPROC)wglGetProcAddress("glGetCompressedTextureImage");
            glGetTextureLevelParameterfv               = (PFNGLGETTEXTURELEVELPARAMETERFVPROC)wglGetProcAddress("glGetTextureLevelParameterfv");
            glGetTextureLevelParameteriv               = (PFNGLGETTEXTURELEVELPARAMETERIVPROC)wglGetProcAddress("glGetTextureLevelParameteriv");
            glGetTextureParameterfv                    = (PFNGLGETTEXTUREPARAMETERFVPROC)wglGetProcAddress("glGetTextureParameterfv");
            glGetTextureParameterIiv                   = (PFNGLGETTEXTUREPARAMETERIIVPROC)wglGetProcAddress("glGetTextureParameterIiv");
            glGetTextureParameterIuiv                  = (PFNGLGETTEXTUREPARAMETERIUIVPROC)wglGetProcAddress("glGetTextureParameterIuiv");
            glGetTextureParameteriv                    = (PFNGLGETTEXTUREPARAMETERIVPROC)wglGetProcAddress("glGetTextureParameteriv");
            // for vertex array object
            glCreateVertexArrays                       = (PFNGLCREATEVERTEXARRAYSPROC)wglGetProcAddress("glCreateVertexArrays");
            glDisableVertexArrayAttrib                 = (PFNGLDISABLEVERTEXARRAYATTRIBPROC)wglGetProcAddress("glDisableVertexArrayAttrib");
            glEnableVertexArrayAttrib                  = (PFNGLENABLEVERTEXARRAYATTRIBPROC)wglGetProcAddress("glEnableVertexArrayAttrib");
            glVertexArrayElementBuffer                 = (PFNGLVERTEXARRAYELEMENTBUFFERPROC)wglGetProcAddress("glVertexArrayElementBuffer");
            glVertexArrayVertexBuffer                  = (PFNGLVERTEXARRAYVERTEXBUFFERPROC)wglGetProcAddress("glVertexArrayVertexBuffer");
            glVertexArrayVertexBuffers                 = (PFNGLVERTEXARRAYVERTEXBUFFERSPROC)wglGetProcAddress("glVertexArrayVertexBuffers");
            glVertexArrayAttribBinding                 = (PFNGLVERTEXARRAYATTRIBBINDINGPROC)wglGetProcAddress("glVertexArrayAttribBinding");
            glVertexArrayAttribFormat                  = (PFNGLVERTEXARRAYATTRIBFORMATPROC)wglGetProcAddress("glVertexArrayAttribFormat");
            glVertexArrayAttribIFormat                 = (PFNGLVERTEXARRAYATTRIBIFORMATPROC)wglGetProcAddress("glVertexArrayAttribIFormat");
            glVertexArrayAttribLFormat                 = (PFNGLVERTEXARRAYATTRIBLFORMATPROC)wglGetProcAddress("glVertexArrayAttribLFormat");
            glVertexArrayBindingDivisor                = (PFNGLVERTEXARRAYBINDINGDIVISORPROC)wglGetProcAddress("glVertexArrayBindingDivisor");
            glGetVertexArrayiv                         = (PFNGLGETVERTEXARRAYIVPROC)wglGetProcAddress("glGetVertexArrayiv");
            glGetVertexArrayIndexediv                  = (PFNGLGETVERTEXARRAYINDEXEDIVPROC)wglGetProcAddress("glGetVertexArrayIndexediv");
            glGetVertexArrayIndexed64iv                = (PFNGLGETVERTEXARRAYINDEXED64IVPROC)wglGetProcAddress("glGetVertexArrayIndexed64iv");
            // for sampler object
            glCreateSamplers                           = (PFNGLCREATESAMPLERSPROC)wglGetProcAddress("glCreateSamplers");
            // for program pipeline object
            glCreateProgramPipelines                   = (PFNGLCREATEPROGRAMPIPELINESPROC)wglGetProcAddress("glCreateProgramPipelines");
            // for query object
            glCreateQueries                            = (PFNGLCREATEQUERIESPROC)wglGetProcAddress("glCreateQueries");
            glGetQueryBufferObjectiv                   = (PFNGLGETQUERYBUFFEROBJECTIVPROC)wglGetProcAddress("glGetQueryBufferObjectiv");
            glGetQueryBufferObjectuiv                  = (PFNGLGETQUERYBUFFEROBJECTUIVPROC)wglGetProcAddress("glGetQueryBufferObjectuiv");
            glGetQueryBufferObjecti64v                 = (PFNGLGETQUERYBUFFEROBJECTI64VPROC)wglGetProcAddress("glGetQueryBufferObjecti64v");
            glGetQueryBufferObjectui64v                = (PFNGLGETQUERYBUFFEROBJECTUI64VPROC)wglGetProcAddress("glGetQueryBufferObjectui64v");
        }


        // WGL extensions =====================================================
        else if(extensions[i] == "WGL_ARB_pixel_format")
        {
            wglGetPixelFormatAttribivARB = (PFNWGLGETPIXELFORMATATTRIBIVARBPROC)wglGetProcAddress("wglGetPixelFormatAttribivARB");
            wglGetPixelFormatAttribfvARB = (PFNWGLGETPIXELFORMATATTRIBFVARBPROC)wglGetProcAddress("wglGetPixelFormatAttribfvARB");
            wglChoosePixelFormatARB      = (PFNWGLCHOOSEPIXELFORMATARBPROC)wglGetProcAddress("wglChoosePixelFormatARB");
        }
        else if(extensions[i] == "WGL_ARB_create_context")
        {
            wglCreateContextAttribsARB = (PFNWGLCREATECONTEXTATTRIBSARBPROC)wglGetProcAddress("wglCreateContextAttribsARB");
        }
        else if(extensions[i] == "WGL_EXT_swap_control")
        {
            wglSwapIntervalEXT = (PFNWGLSWAPINTERVALEXTPROC)wglGetProcAddress("wglSwapIntervalEXT");
            wglGetSwapIntervalEXT = (PFNWGLGETSWAPINTERVALEXTPROC)wglGetProcAddress("wglGetSwapIntervalEXT");
        }
    }
#endif
}

