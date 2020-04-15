///////////////////////////////////////////////////////////////////////////////
// glExtension.h
// =============
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

#ifndef GL_EXTENSION_H
#define GL_EXTENSION_H

// in order to get function prototypes from glext.h, define GL_GLEXT_PROTOTYPES before including glext.h
#define GL_GLEXT_PROTOTYPES

#ifdef _WIN32
#ifndef WIN32_LEAN_AND_MEAN
#define WIN32_LEAN_AND_MEAN 1
#endif
#include <windows.h>
#endif

#ifdef __APPLE__
#include <OpenGL/gl.h>
#else
#include <GL/gl.h>
#endif

#include <string>
#include <vector>
#include "glext.h"

class glExtension
{
public:
    ~glExtension();
    static glExtension& getInstance();                  // must be called after RC is open

    bool isSupported(const std::string& extStr);        // check if a extension is available
    const std::vector<std::string>& getExtensions();

private:
    glExtension();                                      // prevent calling ctor
    glExtension(const glExtension& rhs);                // no implementation
    void getExtensionStrings();
    void getFunctionPointers();
    std::string toLower(const std::string& str);

    std::vector <std::string> extensions;
};



#ifdef _WIN32 //===============================================================
// GL_ARB_framebuffer_object
extern PFNGLGENFRAMEBUFFERSPROC                     pglGenFramebuffers;                     // FBO name generation procedure
extern PFNGLDELETEFRAMEBUFFERSPROC                  pglDeleteFramebuffers;                  // FBO deletion procedure
extern PFNGLBINDFRAMEBUFFERPROC                     pglBindFramebuffer;                     // FBO bind procedure
extern PFNGLCHECKFRAMEBUFFERSTATUSPROC              pglCheckFramebufferStatus;              // FBO completeness test procedure
extern PFNGLGETFRAMEBUFFERATTACHMENTPARAMETERIVPROC pglGetFramebufferAttachmentParameteriv; // return various FBO parameters
extern PFNGLGENERATEMIPMAPPROC                      pglGenerateMipmap;                      // FBO automatic mipmap generation procedure
extern PFNGLFRAMEBUFFERTEXTURE1DPROC                pglFramebufferTexture1D;                // FBO texture attachement procedure
extern PFNGLFRAMEBUFFERTEXTURE2DPROC                pglFramebufferTexture2D;                // FBO texture attachement procedure
extern PFNGLFRAMEBUFFERTEXTURE3DPROC                pglFramebufferTexture3D;                // FBO texture attachement procedure
extern PFNGLFRAMEBUFFERTEXTURELAYERPROC             pglFramebufferTextureLayer;             // FBO texture layer procedure
extern PFNGLFRAMEBUFFERRENDERBUFFERPROC             pglFramebufferRenderbuffer;             // FBO renderbuffer attachement procedure
extern PFNGLISFRAMEBUFFERPROC                       pglIsFramebuffer;                       // FBO state = true/false
extern PFNGLBLITFRAMEBUFFERPROC                     pglBlitFramebuffer;                     // FBO copy
extern PFNGLGENRENDERBUFFERSPROC                    pglGenRenderbuffers;                    // renderbuffer generation procedure
extern PFNGLDELETERENDERBUFFERSPROC                 pglDeleteRenderbuffers;                 // renderbuffer deletion procedure
extern PFNGLBINDRENDERBUFFERPROC                    pglBindRenderbuffer;                    // renderbuffer bind procedure
extern PFNGLRENDERBUFFERSTORAGEPROC                 pglRenderbufferStorage;                 // renderbuffer memory allocation procedure
extern PFNGLRENDERBUFFERSTORAGEMULTISAMPLEPROC      pglRenderbufferStorageMultisample;      // renderbuffer memory allocation with multisample
extern PFNGLGETRENDERBUFFERPARAMETERIVPROC          pglGetRenderbufferParameteriv;          // return various renderbuffer parameters
extern PFNGLISRENDERBUFFERPROC                      pglIsRenderbuffer;                      // determine renderbuffer object type
#define glGenFramebuffers                           pglGenFramebuffers
#define glDeleteFramebuffers                        pglDeleteFramebuffers
#define glBindFramebuffer                           pglBindFramebuffer
#define glCheckFramebufferStatus                    pglCheckFramebufferStatus
#define glGetFramebufferAttachmentParameteriv       pglGetFramebufferAttachmentParameteriv
#define glGenerateMipmap                            pglGenerateMipmap
#define glFramebufferTexture1D                      pglFramebufferTexture1D
#define glFramebufferTexture2D                      pglFramebufferTexture2D
#define glFramebufferTexture3D                      pglFramebufferTexture3D
#define glFramebufferTextureLayer                   pglFramebufferTextureLayer
#define glFramebufferRenderbuffer                   pglFramebufferRenderbuffer
#define glIsFramebuffer                             pglIsFramebuffer
#define glBlitFramebuffer                           pglBlitFramebuffer
#define glGenRenderbuffers                          pglGenRenderbuffers
#define glDeleteRenderbuffers                       pglDeleteRenderbuffers
#define glBindRenderbuffer                          pglBindRenderbuffer
#define glRenderbufferStorage                       pglRenderbufferStorage
#define glRenderbufferStorageMultisample            pglRenderbufferStorageMultisample
#define glGetRenderbufferParameteriv                pglGetRenderbufferParameteriv
#define glIsRenderbuffer                            pglIsRenderbuffer

// GL_ARB_multisample
extern PFNGLSAMPLECOVERAGEARBPROC   pglSampleCoverageARB;
#define glSampleCoverageARB         pglSampleCoverageARB

// GL_ARB_multitexture
extern PFNGLACTIVETEXTUREARBPROC    pglActiveTextureARB;
#define glActiveTextureARB          pglActiveTextureARB

// GL_ARB_pixel_buffer_objects & GL_ARB_vertex_buffer_object
extern PFNGLGENBUFFERSARBPROC           pglGenBuffersARB;           // VBO Name Generation Procedure
extern PFNGLBINDBUFFERARBPROC           pglBindBufferARB;           // VBO Bind Procedure
extern PFNGLBUFFERDATAARBPROC           pglBufferDataARB;           // VBO Data Loading Procedure
extern PFNGLBUFFERSUBDATAARBPROC        pglBufferSubDataARB;        // VBO Sub Data Loading Procedure
extern PFNGLDELETEBUFFERSARBPROC        pglDeleteBuffersARB;        // VBO Deletion Procedure
extern PFNGLGETBUFFERPARAMETERIVARBPROC pglGetBufferParameterivARB; // return various parameters of VBO
extern PFNGLMAPBUFFERARBPROC            pglMapBufferARB;            // map VBO procedure
extern PFNGLUNMAPBUFFERARBPROC          pglUnmapBufferARB;          // unmap VBO procedure
#define glGenBuffersARB                 pglGenBuffersARB
#define glBindBufferARB                 pglBindBufferARB
#define glBufferDataARB                 pglBufferDataARB
#define glBufferSubDataARB              pglBufferSubDataARB
#define glDeleteBuffersARB              pglDeleteBuffersARB
#define glGetBufferParameterivARB       pglGetBufferParameterivARB
#define glMapBufferARB                  pglMapBufferARB
#define glUnmapBufferARB                pglUnmapBufferARB

// GL_ARB_shader_objects
extern PFNGLDELETEOBJECTARBPROC         pglDeleteObjectARB;         // delete shader object
extern PFNGLGETHANDLEARBPROC            pglGetHandleARB;            // return handle of program
extern PFNGLDETACHOBJECTARBPROC         pglDetachObjectARB;         // detatch a shader from a program
extern PFNGLCREATESHADEROBJECTARBPROC   pglCreateShaderObjectARB;   // create a shader
extern PFNGLSHADERSOURCEARBPROC         pglShaderSourceARB;         // set a shader source(codes)
extern PFNGLCOMPILESHADERARBPROC        pglCompileShaderARB;        // compile shader source
extern PFNGLCREATEPROGRAMOBJECTARBPROC  pglCreateProgramObjectARB;  // create a program
extern PFNGLATTACHOBJECTARBPROC         pglAttachObjectARB;         // attach a shader to a program
extern PFNGLLINKPROGRAMARBPROC          pglLinkProgramARB;          // link a program
extern PFNGLUSEPROGRAMOBJECTARBPROC     pglUseProgramObjectARB;     // use a program
extern PFNGLVALIDATEPROGRAMARBPROC      pglValidateProgramARB;      // validate a program
extern PFNGLUNIFORM1FARBPROC            pglUniform1fARB;            //
extern PFNGLUNIFORM2FARBPROC            pglUniform2fARB;            //
extern PFNGLUNIFORM3FARBPROC            pglUniform3fARB;            //
extern PFNGLUNIFORM4FARBPROC            pglUniform4fARB;            //
extern PFNGLUNIFORM1IARBPROC            pglUniform1iARB;            //
extern PFNGLUNIFORM2IARBPROC            pglUniform2iARB;            //
extern PFNGLUNIFORM3IARBPROC            pglUniform3iARB;            //
extern PFNGLUNIFORM4IARBPROC            pglUniform4iARB;            //
extern PFNGLUNIFORM1FVARBPROC           pglUniform1fvARB;           //
extern PFNGLUNIFORM2FVARBPROC           pglUniform2fvARB;           //
extern PFNGLUNIFORM3FVARBPROC           pglUniform3fvARB;           //
extern PFNGLUNIFORM4FVARBPROC           pglUniform4fvARB;           //
extern PFNGLUNIFORM1FVARBPROC           pglUniform1ivARB;           //
extern PFNGLUNIFORM2FVARBPROC           pglUniform2ivARB;           //
extern PFNGLUNIFORM3FVARBPROC           pglUniform3ivARB;           //
extern PFNGLUNIFORM4FVARBPROC           pglUniform4ivARB;           //
extern PFNGLUNIFORMMATRIX2FVARBPROC     pglUniformMatrix2fvARB;     //
extern PFNGLUNIFORMMATRIX3FVARBPROC     pglUniformMatrix3fvARB;     //
extern PFNGLUNIFORMMATRIX4FVARBPROC     pglUniformMatrix4fvARB;     //
extern PFNGLGETOBJECTPARAMETERFVARBPROC pglGetObjectParameterfvARB; // get shader/program param
extern PFNGLGETOBJECTPARAMETERIVARBPROC pglGetObjectParameterivARB; //
extern PFNGLGETINFOLOGARBPROC           pglGetInfoLogARB;           // get log
extern PFNGLGETATTACHEDOBJECTSARBPROC   pglGetAttachedObjectsARB;   // get attached shader to a program
extern PFNGLGETUNIFORMLOCATIONARBPROC   pglGetUniformLocationARB;   // get index of uniform var
extern PFNGLGETACTIVEUNIFORMARBPROC     pglGetActiveUniformARB;     // get info of uniform var
extern PFNGLGETUNIFORMFVARBPROC         pglGetUniformfvARB;         // get value of uniform var
extern PFNGLGETUNIFORMIVARBPROC         pglGetUniformivARB;         //
extern PFNGLGETSHADERSOURCEARBPROC      pglGetShaderSourceARB;      // get shader source codes
#define glDeleteObjectARB               pglDeleteObjectARB
#define glGetHandleARB                  pglGetHandleARB
#define glDetachObjectARB               pglDetachObjectARB
#define glCreateShaderObjectARB         pglCreateShaderObjectARB
#define glShaderSourceARB               pglShaderSourceARB
#define glCompileShaderARB              pglCompileShaderARB
#define glCreateProgramObjectARB        pglCreateProgramObjectARB
#define glAttachObjectARB               pglAttachObjectARB
#define glLinkProgramARB                pglLinkProgramARB
#define glUseProgramObjectARB           pglUseProgramObjectARB
#define glValidateProgramARB            pglValidateProgramARB
#define glUniform1fARB                  pglUniform1fARB
#define glUniform2fARB                  pglUniform2fARB
#define glUniform3fARB                  pglUniform3fARB
#define glUniform4fARB                  pglUniform4fARB
#define glUniform1iARB                  pglUniform1iARB
#define glUniform2iARB                  pglUniform2iARB
#define glUniform3iARB                  pglUniform3iARB
#define glUniform4iARB                  pglUniform4iARB
#define glUniform1fvARB                 pglUniform1fvARB
#define glUniform2fvARB                 pglUniform2fvARB
#define glUniform3fvARB                 pglUniform3fvARB
#define glUniform4fvARB                 pglUniform4fvARB
#define glUniform1ivARB                 pglUniform1ivARB
#define glUniform2ivARB                 pglUniform2ivARB
#define glUniform3ivARB                 pglUniform3ivARB
#define glUniform4ivARB                 pglUniform4ivARB
#define glUniformMatrix2fvARB           pglUniformMatrix2fvARB
#define glUniformMatrix3fvARB           pglUniformMatrix3fvARB
#define glUniformMatrix4fvARB           pglUniformMatrix4fvARB
#define glGetObjectParameterfvARB       pglGetObjectParameterfvARB
#define glGetObjectParameterivARB       pglGetObjectParameterivARB
#define glGetInfoLogARB                 pglGetInfoLogARB
#define glGetAttachedObjectsARB         pglGetAttachedObjectsARB
#define glGetUniformLocationARB         pglGetUniformLocationARB
#define glGetActiveUniformARB           pglGetActiveUniformARB
#define glGetUniformfvARB               pglGetUniformfvARB
#define glGetUniformivARB               pglGetUniformivARB
#define glGetShaderSourceARB            pglGetShaderSourceARB
//@@ v2.0 core version:
// while GLSL is promoted to OpenGL 2.0 core, shader APIs was slightly changed.
// ARB suffix was removed and GLhandleARB type was changed to GLuint,
// for example glCreateShaderObjectARB() is changed to glCreateShader().
// You can use either ARB or core version, but do not mix both together.
extern PFNGLATTACHSHADERPROC            pglAttachShader;            // attach a shader to a program
extern PFNGLCOMPILESHADERPROC           pglCompileShader;           // compile shader source
extern PFNGLCREATEPROGRAMPROC           pglCreateProgram;           // create a program object
extern PFNGLCREATESHADERPROC            pglCreateShader;            // create a shader object
extern PFNGLDELETEPROGRAMPROC           pglDeleteProgram;           // delete shader program
extern PFNGLDELETESHADERPROC            pglDeleteShader;            // delete shader object
extern PFNGLDETACHSHADERPROC            pglDetachShader;            // detatch a shader object from a program
extern PFNGLGETACTIVEUNIFORMPROC        pglGetActiveUniform;        // get info of uniform var
extern PFNGLGETATTACHEDSHADERSPROC      pglGetAttachedShaders;      // get attached shaders to a program
extern PFNGLGETPROGRAMIVPROC            pglGetProgramiv;            // return param of program object
extern PFNGLGETPROGRAMINFOLOGPROC       pglGetProgramInfoLog;       // return info log of program
extern PFNGLGETSHADERIVPROC             pglGetShaderiv;             // return param of shader object
extern PFNGLGETSHADERINFOLOGPROC        pglGetShaderInfoLog;        // return info log of shader
extern PFNGLGETSHADERSOURCEPROC         pglGetShaderSource;         // get shader source codes
extern PFNGLGETUNIFORMLOCATIONPROC      pglGetUniformLocation;      // get index of uniform var
extern PFNGLGETUNIFORMFVPROC            pglGetUniformfv;            // get value of uniform var
extern PFNGLGETUNIFORMIVPROC            pglGetUniformiv;            //
extern PFNGLLINKPROGRAMPROC             pglLinkProgram;             // link a program
extern PFNGLSHADERSOURCEPROC            pglShaderSource;            // set a shader source(codes)
extern PFNGLUSEPROGRAMPROC              pglUseProgram;              // use a program
extern PFNGLUNIFORM1FPROC               pglUniform1f;               //
extern PFNGLUNIFORM2FPROC               pglUniform2f;               //
extern PFNGLUNIFORM3FPROC               pglUniform3f;               //
extern PFNGLUNIFORM4FPROC               pglUniform4f;               //
extern PFNGLUNIFORM1IPROC               pglUniform1i;               //
extern PFNGLUNIFORM2IPROC               pglUniform2i;               //
extern PFNGLUNIFORM3IPROC               pglUniform3i;               //
extern PFNGLUNIFORM4IPROC               pglUniform4i;               //
extern PFNGLUNIFORM1FVPROC              pglUniform1fv;              //
extern PFNGLUNIFORM2FVPROC              pglUniform2fv;              //
extern PFNGLUNIFORM3FVPROC              pglUniform3fv;              //
extern PFNGLUNIFORM4FVPROC              pglUniform4fv;              //
extern PFNGLUNIFORM1FVPROC              pglUniform1iv;              //
extern PFNGLUNIFORM2FVPROC              pglUniform2iv;              //
extern PFNGLUNIFORM3FVPROC              pglUniform3iv;              //
extern PFNGLUNIFORM4FVPROC              pglUniform4iv;              //
extern PFNGLUNIFORMMATRIX2FVPROC        pglUniformMatrix2fv;        //
extern PFNGLUNIFORMMATRIX3FVPROC        pglUniformMatrix3fv;        //
extern PFNGLUNIFORMMATRIX4FVPROC        pglUniformMatrix4fv;        //
extern PFNGLVALIDATEPROGRAMPROC         pglValidateProgram;         // validate a program
#define glAttachShader                  pglAttachShader
#define glCompileShader                 pglCompileShader
#define glCreateProgram                 pglCreateProgram
#define glCreateShader                  pglCreateShader
#define glDeleteProgram                 pglDeleteProgram
#define glDeleteShader                  pglDeleteShader
#define glDetachShader                  pglDetachShader
#define glGetActiveUniform              pglGetActiveUniform
#define glGetAttachedShaders            pglGetAttachedShaders
#define glGetProgramiv                  pglGetProgramiv
#define glGetProgramInfoLog             pglGetProgramInfoLog
#define glGetShaderiv                   pglGetShaderiv
#define glGetShaderInfoLog              pglGetShaderInfoLog
#define glGetShaderSource               pglGetShaderSource
#define glGetUniformLocation            pglGetUniformLocation
#define glGetUniformfv                  pglGetUniformfv
#define glGetUniformiv                  pglGetUniformiv
#define glLinkProgram                   pglLinkProgram
#define glShaderSource                  pglShaderSource
#define glUseProgram                    pglUseProgram
#define glUniform1f                     pglUniform1f
#define glUniform2f                     pglUniform2f
#define glUniform3f                     pglUniform3f
#define glUniform4f                     pglUniform4f
#define glUniform1i                     pglUniform1i
#define glUniform2i                     pglUniform2i
#define glUniform3i                     pglUniform3i
#define glUniform4i                     pglUniform4i
#define glUniform1fv                    pglUniform1fv
#define glUniform2fv                    pglUniform2fv
#define glUniform3fv                    pglUniform3fv
#define glUniform4fv                    pglUniform4fv
#define glUniform1iv                    pglUniform1iv
#define glUniform2iv                    pglUniform2iv
#define glUniform3iv                    pglUniform3iv
#define glUniform4iv                    pglUniform4iv
#define glUniformMatrix2fv              pglUniformMatrix2fv
#define glUniformMatrix3fv              pglUniformMatrix3fv
#define glUniformMatrix4fv              pglUniformMatrix4fv
#define glValidateProgram               pglValidateProgram

// GL_ARB_sync extension
extern PFNGLFENCESYNCPROC       pglFenceSync;
extern PFNGLISSYNCPROC          pglIsSync;
extern PFNGLDELETESYNCPROC      pglDeleteSync;
extern PFNGLCLIENTWAITSYNCPROC  pglClientWaitSync;
extern PFNGLWAITSYNCPROC        pglWaitSync;
extern PFNGLGETINTEGER64VPROC   pglGetInteger64v;
extern PFNGLGETSYNCIVPROC       pglGetSynciv;
#define glFenceSync             pglFenceSync
#define glIsSync                pglIsSync
#define glDeleteSync            pglDeleteSync
#define glClientWaitSync        pglClientWaitSync
#define glWaitSync              pglWaitSync
#define glGetInteger64v         pglGetInteger64v
#define glGetSynciv             pglGetSynciv

// GL_ARB_vertex_array_object
extern PFNGLGENVERTEXARRAYSPROC     pglGenVertexArrays;     // VAO name generation procedure
extern PFNGLDELETEVERTEXARRAYSPROC  pglDeleteVertexArrays;  // VAO deletion procedure
extern PFNGLBINDVERTEXARRAYPROC     pglBindVertexArray;     // VAO bind procedure
extern PFNGLISVERTEXARRAYPROC       pglIsVertexArray;       // VBO query procedure
#define glGenVertexArrays           pglGenVertexArrays
#define glDeleteVertexArrays        pglDeleteVertexArrays
#define glBindVertexArray           pglBindVertexArray
#define glIsVertexArray             pglIsVertexArray

// GL_ARB_vertex_shader and GL_ARB_fragment_shader extensions
extern PFNGLBINDATTRIBLOCATIONARBPROC   pglBindAttribLocationARB;   // bind vertex attrib var with index
extern PFNGLGETACTIVEATTRIBARBPROC      pglGetActiveAttribARB;      // get attrib value
extern PFNGLGETATTRIBLOCATIONARBPROC    pglGetAttribLocationARB;    // get lndex of attrib var
#define glBindAttribLocationARB         pglBindAttribLocationARB
#define glGetActiveAttribARB            pglGetActiveAttribARB
#define glGetAttribLocationARB          pglGetAttribLocationARB
//@@ v2.0 core version
extern PFNGLBINDATTRIBLOCATIONPROC      pglBindAttribLocation;      // bind vertex attrib var with index
extern PFNGLGETACTIVEATTRIBPROC         pglGetActiveAttrib;         // get attrib value
extern PFNGLGETATTRIBLOCATIONPROC       pglGetAttribLocation;       // get lndex of attrib var
#define glBindAttribLocation            pglBindAttribLocation
#define glGetActiveAttrib               pglGetActiveAttrib
#define glGetAttribLocation             pglGetAttribLocation

// GL_ARB_vertex_program and GL_ARB_fragment_program
extern PFNGLVERTEXATTRIB1DARBPROC               pglVertexAttrib1dARB;
extern PFNGLVERTEXATTRIB1DVARBPROC              pglVertexAttrib1dvARB;
extern PFNGLVERTEXATTRIB1FARBPROC               pglVertexAttrib1fARB;
extern PFNGLVERTEXATTRIB1FVARBPROC              pglVertexAttrib1fvARB;
extern PFNGLVERTEXATTRIB1SARBPROC               pglVertexAttrib1sARB;
extern PFNGLVERTEXATTRIB1SVARBPROC              pglVertexAttrib1svARB;
extern PFNGLVERTEXATTRIB2DARBPROC               pglVertexAttrib2dARB;
extern PFNGLVERTEXATTRIB2DVARBPROC              pglVertexAttrib2dvARB;
extern PFNGLVERTEXATTRIB2FARBPROC               pglVertexAttrib2fARB;
extern PFNGLVERTEXATTRIB2FVARBPROC              pglVertexAttrib2fvARB;
extern PFNGLVERTEXATTRIB2SARBPROC               pglVertexAttrib2sARB;
extern PFNGLVERTEXATTRIB2SVARBPROC              pglVertexAttrib2svARB;
extern PFNGLVERTEXATTRIB3DARBPROC               pglVertexAttrib3dARB;
extern PFNGLVERTEXATTRIB3DVARBPROC              pglVertexAttrib3dvARB;
extern PFNGLVERTEXATTRIB3FARBPROC               pglVertexAttrib3fARB;
extern PFNGLVERTEXATTRIB3FVARBPROC              pglVertexAttrib3fvARB;
extern PFNGLVERTEXATTRIB3SARBPROC               pglVertexAttrib3sARB;
extern PFNGLVERTEXATTRIB3SVARBPROC              pglVertexAttrib3svARB;
extern PFNGLVERTEXATTRIB4NBVARBPROC             pglVertexAttrib4NbvARB;
extern PFNGLVERTEXATTRIB4NIVARBPROC             pglVertexAttrib4NivARB;
extern PFNGLVERTEXATTRIB4NSVARBPROC             pglVertexAttrib4NsvARB;
extern PFNGLVERTEXATTRIB4NUBARBPROC             pglVertexAttrib4NubARB;
extern PFNGLVERTEXATTRIB4NUBVARBPROC            pglVertexAttrib4NubvARB;
extern PFNGLVERTEXATTRIB4NUIVARBPROC            pglVertexAttrib4NuivARB;
extern PFNGLVERTEXATTRIB4NUSVARBPROC            pglVertexAttrib4NusvARB;
extern PFNGLVERTEXATTRIB4BVARBPROC              pglVertexAttrib4bvARB;
extern PFNGLVERTEXATTRIB4DARBPROC               pglVertexAttrib4dARB;
extern PFNGLVERTEXATTRIB4DVARBPROC              pglVertexAttrib4dvARB;
extern PFNGLVERTEXATTRIB4FARBPROC               pglVertexAttrib4fARB;
extern PFNGLVERTEXATTRIB4FVARBPROC              pglVertexAttrib4fvARB;
extern PFNGLVERTEXATTRIB4IVARBPROC              pglVertexAttrib4ivARB;
extern PFNGLVERTEXATTRIB4SARBPROC               pglVertexAttrib4sARB;
extern PFNGLVERTEXATTRIB4SVARBPROC              pglVertexAttrib4svARB;
extern PFNGLVERTEXATTRIB4UBVARBPROC             pglVertexAttrib4ubvARB;
extern PFNGLVERTEXATTRIB4UIVARBPROC             pglVertexAttrib4uivARB;
extern PFNGLVERTEXATTRIB4USVARBPROC             pglVertexAttrib4usvARB;
extern PFNGLVERTEXATTRIBPOINTERARBPROC          pglVertexAttribPointerARB;
extern PFNGLENABLEVERTEXATTRIBARRAYARBPROC      pglEnableVertexAttribArrayARB;
extern PFNGLDISABLEVERTEXATTRIBARRAYARBPROC     pglDisableVertexAttribArrayARB;
extern PFNGLPROGRAMSTRINGARBPROC                pglProgramStringARB;
extern PFNGLBINDPROGRAMARBPROC                  pglBindProgramARB;
extern PFNGLDELETEPROGRAMSARBPROC               pglDeleteProgramsARB;
extern PFNGLGENPROGRAMSARBPROC                  pglGenProgramsARB;
extern PFNGLPROGRAMENVPARAMETER4DARBPROC        pglProgramEnvParameter4dARB;
extern PFNGLPROGRAMENVPARAMETER4DVARBPROC       pglProgramEnvParameter4dvARB;
extern PFNGLPROGRAMENVPARAMETER4FARBPROC        pglProgramEnvParameter4fARB;
extern PFNGLPROGRAMENVPARAMETER4FVARBPROC       pglProgramEnvParameter4fvARB;
extern PFNGLPROGRAMLOCALPARAMETER4DARBPROC      pglProgramLocalParameter4dARB;
extern PFNGLPROGRAMLOCALPARAMETER4DVARBPROC     pglProgramLocalParameter4dvARB;
extern PFNGLPROGRAMLOCALPARAMETER4FARBPROC      pglProgramLocalParameter4fARB;
extern PFNGLPROGRAMLOCALPARAMETER4FVARBPROC     pglProgramLocalParameter4fvARB;
extern PFNGLGETPROGRAMENVPARAMETERDVARBPROC     pglGetProgramEnvParameterdvARB;
extern PFNGLGETPROGRAMENVPARAMETERFVARBPROC     pglGetProgramEnvParameterfvARB;
extern PFNGLGETPROGRAMLOCALPARAMETERDVARBPROC   pglGetProgramLocalParameterdvARB;
extern PFNGLGETPROGRAMLOCALPARAMETERFVARBPROC   pglGetProgramLocalParameterfvARB;
extern PFNGLGETPROGRAMIVARBPROC                 pglGetProgramivARB;
extern PFNGLGETPROGRAMSTRINGARBPROC             pglGetProgramStringARB;
extern PFNGLGETVERTEXATTRIBDVARBPROC            pglGetVertexAttribdvARB;
extern PFNGLGETVERTEXATTRIBFVARBPROC            pglGetVertexAttribfvARB;
extern PFNGLGETVERTEXATTRIBIVARBPROC            pglGetVertexAttribivARB;
extern PFNGLGETVERTEXATTRIBPOINTERVARBPROC      pglGetVertexAttribPointervARB;
extern PFNGLISPROGRAMARBPROC                    pglIsProgramARB;
#define glVertexAttrib1dARB                     pglVertexAttrib1dARB
#define glVertexAttrib1dvARB                    pglVertexAttrib1dvARB
#define glVertexAttrib1fARB                     pglVertexAttrib1fARB
#define glVertexAttrib1fvARB                    pglVertexAttrib1fvARB
#define glVertexAttrib1sARB                     pglVertexAttrib1sARB
#define glVertexAttrib1svARB                    pglVertexAttrib1svARB
#define glVertexAttrib2dARB                     pglVertexAttrib2dARB
#define glVertexAttrib2dvARB                    pglVertexAttrib2dvARB
#define glVertexAttrib2fARB                     pglVertexAttrib2fARB
#define glVertexAttrib2fvARB                    pglVertexAttrib2fvARB
#define glVertexAttrib2sARB                     pglVertexAttrib2sARB
#define glVertexAttrib2svARB                    pglVertexAttrib2svARB
#define glVertexAttrib3dARB                     pglVertexAttrib3dARB
#define glVertexAttrib3dvARB                    pglVertexAttrib3dvARB
#define glVertexAttrib3fARB                     pglVertexAttrib3fARB
#define glVertexAttrib3fvARB                    pglVertexAttrib3fvARB
#define glVertexAttrib3sARB                     pglVertexAttrib3sARB
#define glVertexAttrib3svARB                    pglVertexAttrib3svARB
#define glVertexAttrib4NbvARB                   pglVertexAttrib4NbvARB
#define glVertexAttrib4NivARB                   pglVertexAttrib4NivARB
#define glVertexAttrib4NsvARB                   pglVertexAttrib4NsvARB
#define glVertexAttrib4NubARB                   pglVertexAttrib4NubARB
#define glVertexAttrib4NubvARB                  pglVertexAttrib4NubvARB
#define glVertexAttrib4NuivARB                  pglVertexAttrib4NuivARB
#define glVertexAttrib4NusvARB                  pglVertexAttrib4NusvARB
#define glVertexAttrib4bvARB                    pglVertexAttrib4bvARB
#define glVertexAttrib4dARB                     pglVertexAttrib4dARB
#define glVertexAttrib4dvARB                    pglVertexAttrib4dvARB
#define glVertexAttrib4fARB                     pglVertexAttrib4fARB
#define glVertexAttrib4fvARB                    pglVertexAttrib4fvARB
#define glVertexAttrib4ivARB                    pglVertexAttrib4ivARB
#define glVertexAttrib4sARB                     pglVertexAttrib4sARB
#define glVertexAttrib4svARB                    pglVertexAttrib4svARB
#define glVertexAttrib4ubvARB                   pglVertexAttrib4ubvARB
#define glVertexAttrib4uivARB                   pglVertexAttrib4uivARB
#define glVertexAttrib4usvARB                   pglVertexAttrib4usvARB
#define glVertexAttribPointerARB                pglVertexAttribPointerARB
#define glEnableVertexAttribArrayARB            pglEnableVertexAttribArrayARB
#define glDisableVertexAttribArrayARB           pglDisableVertexAttribArrayARB
#define glProgramStringARB                      pglProgramStringARB
#define glBindProgramARB                        pglBindProgramARB
#define glDeleteProgramsARB                     pglDeleteProgramsARB
#define glGenProgramsARB                        pglGenProgramsARB
#define glProgramEnvParameter4dARB              pglProgramEnvParameter4dARB
#define glProgramEnvParameter4dvARB             pglProgramEnvParameter4dvARB
#define glProgramEnvParameter4fARB              pglProgramEnvParameter4fARB
#define glProgramEnvParameter4fvARB             pglProgramEnvParameter4fvARB
#define glProgramLocalParameter4dARB            pglProgramLocalParameter4dARB
#define glProgramLocalParameter4dvARB           pglProgramLocalParameter4dvARB
#define glProgramLocalParameter4fARB            pglProgramLocalParameter4fARB
#define glProgramLocalParameter4fvARB           pglProgramLocalParameter4fvARB
#define glGetProgramEnvParameterdvARB           pglGetProgramEnvParameterdvARB
#define glGetProgramEnvParameterfvARB           pglGetProgramEnvParameterfvARB
#define glGetProgramLocalParameterdvARB         pglGetProgramLocalParameterdvARB
#define glGetProgramLocalParameterfvARB         pglGetProgramLocalParameterfvARB
#define glGetProgramivARB                       pglGetProgramivARB
#define glGetProgramStringARB                   pglGetProgramStringARB
#define glGetVertexAttribdvARB                  pglGetVertexAttribdvARB
#define glGetVertexAttribfvARB                  pglGetVertexAttribfvARB
#define glGetVertexAttribivARB                  pglGetVertexAttribivARB
#define glGetVertexAttribPointervARB            pglGetVertexAttribPointervARB
#define glIsProgramARB                          pglIsProgramARB
//@@ v2.0 core version
extern PFNGLDISABLEVERTEXATTRIBARRAYPROC        pglDisableVertexAttribArray;
extern PFNGLENABLEVERTEXATTRIBARRAYPROC         pglEnableVertexAttribArray;
extern PFNGLGETVERTEXATTRIBDVPROC               pglGetVertexAttribdv;
extern PFNGLGETVERTEXATTRIBFVPROC               pglGetVertexAttribfv;
extern PFNGLGETVERTEXATTRIBIVPROC               pglGetVertexAttribiv;
extern PFNGLGETVERTEXATTRIBPOINTERVPROC         pglGetVertexAttribPointerv;
extern PFNGLISPROGRAMPROC                       pglIsProgram;
extern PFNGLISSHADERPROC                        pglIsShader;
extern PFNGLVERTEXATTRIB1DPROC                  pglVertexAttrib1d;
extern PFNGLVERTEXATTRIB1DVPROC                 pglVertexAttrib1dv;
extern PFNGLVERTEXATTRIB1FPROC                  pglVertexAttrib1f;
extern PFNGLVERTEXATTRIB1FVPROC                 pglVertexAttrib1fv;
extern PFNGLVERTEXATTRIB1SPROC                  pglVertexAttrib1s;
extern PFNGLVERTEXATTRIB1SVPROC                 pglVertexAttrib1sv;
extern PFNGLVERTEXATTRIB2DPROC                  pglVertexAttrib2d;
extern PFNGLVERTEXATTRIB2DVPROC                 pglVertexAttrib2dv;
extern PFNGLVERTEXATTRIB2FPROC                  pglVertexAttrib2f;
extern PFNGLVERTEXATTRIB2FVPROC                 pglVertexAttrib2fv;
extern PFNGLVERTEXATTRIB2SPROC                  pglVertexAttrib2s;
extern PFNGLVERTEXATTRIB2SVPROC                 pglVertexAttrib2sv;
extern PFNGLVERTEXATTRIB3DPROC                  pglVertexAttrib3d;
extern PFNGLVERTEXATTRIB3DVPROC                 pglVertexAttrib3dv;
extern PFNGLVERTEXATTRIB3FPROC                  pglVertexAttrib3f;
extern PFNGLVERTEXATTRIB3FVPROC                 pglVertexAttrib3fv;
extern PFNGLVERTEXATTRIB3SPROC                  pglVertexAttrib3s;
extern PFNGLVERTEXATTRIB3SVPROC                 pglVertexAttrib3sv;
extern PFNGLVERTEXATTRIB4NBVPROC                pglVertexAttrib4Nbv;
extern PFNGLVERTEXATTRIB4NIVPROC                pglVertexAttrib4Niv;
extern PFNGLVERTEXATTRIB4NSVPROC                pglVertexAttrib4Nsv;
extern PFNGLVERTEXATTRIB4NUBPROC                pglVertexAttrib4Nub;
extern PFNGLVERTEXATTRIB4NUBVPROC               pglVertexAttrib4Nubv;
extern PFNGLVERTEXATTRIB4NUIVPROC               pglVertexAttrib4Nuiv;
extern PFNGLVERTEXATTRIB4NUSVPROC               pglVertexAttrib4Nusv;
extern PFNGLVERTEXATTRIB4BVPROC                 pglVertexAttrib4bv;
extern PFNGLVERTEXATTRIB4DPROC                  pglVertexAttrib4d;
extern PFNGLVERTEXATTRIB4DVPROC                 pglVertexAttrib4dv;
extern PFNGLVERTEXATTRIB4FPROC                  pglVertexAttrib4f;
extern PFNGLVERTEXATTRIB4FVPROC                 pglVertexAttrib4fv;
extern PFNGLVERTEXATTRIB4IVPROC                 pglVertexAttrib4iv;
extern PFNGLVERTEXATTRIB4SPROC                  pglVertexAttrib4s;
extern PFNGLVERTEXATTRIB4SVPROC                 pglVertexAttrib4sv;
extern PFNGLVERTEXATTRIB4UBVPROC                pglVertexAttrib4ubv;
extern PFNGLVERTEXATTRIB4UIVPROC                pglVertexAttrib4uiv;
extern PFNGLVERTEXATTRIB4USVPROC                pglVertexAttrib4usv;
extern PFNGLVERTEXATTRIBPOINTERPROC             pglVertexAttribPointer;
#define glDisableVertexAttribArray              pglDisableVertexAttribArray
#define glEnableVertexAttribArray               pglEnableVertexAttribArray
#define glGetVertexAttribdv                     pglGetVertexAttribdv
#define glGetVertexAttribfv                     pglGetVertexAttribfv
#define glGetVertexAttribiv                     pglGetVertexAttribiv
#define glGetVertexAttribPointerv               pglGetVertexAttribPointerv
#define glIsProgram                             pglIsProgram
#define glIsShader                              pglIsShader
#define glVertexAttrib1d                        pglVertexAttrib1d
#define glVertexAttrib1dv                       pglVertexAttrib1dv
#define glVertexAttrib1f                        pglVertexAttrib1f
#define glVertexAttrib1fv                       pglVertexAttrib1fv
#define glVertexAttrib1s                        pglVertexAttrib1s
#define glVertexAttrib1sv                       pglVertexAttrib1sv
#define glVertexAttrib2d                        pglVertexAttrib2d
#define glVertexAttrib2dv                       pglVertexAttrib2dv
#define glVertexAttrib2f                        pglVertexAttrib2f
#define glVertexAttrib2fv                       pglVertexAttrib2fv
#define glVertexAttrib2s                        pglVertexAttrib2s
#define glVertexAttrib2sv                       pglVertexAttrib2sv
#define glVertexAttrib3d                        pglVertexAttrib3d
#define glVertexAttrib3dv                       pglVertexAttrib3dv
#define glVertexAttrib3f                        pglVertexAttrib3f
#define glVertexAttrib3fv                       pglVertexAttrib3fv
#define glVertexAttrib3s                        pglVertexAttrib3s
#define glVertexAttrib3sv                       pglVertexAttrib3sv
#define glVertexAttrib4Nbv                      pglVertexAttrib4Nbv
#define glVertexAttrib4Niv                      pglVertexAttrib4Niv
#define glVertexAttrib4Nsv                      pglVertexAttrib4Nsv
#define glVertexAttrib4Nub                      pglVertexAttrib4Nub
#define glVertexAttrib4Nubv                     pglVertexAttrib4Nubv
#define glVertexAttrib4Nuiv                     pglVertexAttrib4Nuiv
#define glVertexAttrib4Nusv                     pglVertexAttrib4Nusv
#define glVertexAttrib4bv                       pglVertexAttrib4bv
#define glVertexAttrib4d                        pglVertexAttrib4d
#define glVertexAttrib4dv                       pglVertexAttrib4dv
#define glVertexAttrib4f                        pglVertexAttrib4f
#define glVertexAttrib4fv                       pglVertexAttrib4fv
#define glVertexAttrib4iv                       pglVertexAttrib4iv
#define glVertexAttrib4s                        pglVertexAttrib4s
#define glVertexAttrib4sv                       pglVertexAttrib4sv
#define glVertexAttrib4ubv                      pglVertexAttrib4ubv
#define glVertexAttrib4uiv                      pglVertexAttrib4uiv
#define glVertexAttrib4usv                      pglVertexAttrib4usv
#define glVertexAttribPointer                   pglVertexAttribPointer

// GL_ARB_debug_output
extern PFNGLDEBUGMESSAGECONTROLARBPROC  pglDebugMessageControlARB;
extern PFNGLDEBUGMESSAGEINSERTARBPROC   pglDebugMessageInsertARB;
extern PFNGLDEBUGMESSAGECALLBACKARBPROC pglDebugMessageCallbackARB;
extern PFNGLGETDEBUGMESSAGELOGARBPROC   pglGetDebugMessageLogARB;
#define glDebugMessageControlARB        pglDebugMessageControlARB
#define glDebugMessageInsertARB         pglDebugMessageInsertARB
#define glDebugMessageCallbackARB       pglDebugMessageCallbackARB
#define glGetDebugMessageLogARB         pglGetDebugMessageLogARB

// GL_ARB_direct_state_access
extern PFNGLCREATETRANSFORMFEEDBACKSPROC                 pglCreateTransformFeedbacks; // for transform feedback object
extern PFNGLTRANSFORMFEEDBACKBUFFERBASEPROC              pglTransformFeedbackBufferBase;
extern PFNGLTRANSFORMFEEDBACKBUFFERRANGEPROC             pglTransformFeedbackBufferRange;
extern PFNGLGETTRANSFORMFEEDBACKIVPROC                   pglGetTransformFeedbackiv;
extern PFNGLGETTRANSFORMFEEDBACKI_VPROC                  pglGetTransformFeedbacki_v;
extern PFNGLGETTRANSFORMFEEDBACKI64_VPROC                pglGetTransformFeedbacki64_v;
extern PFNGLCREATEBUFFERSPROC                            pglCreateBuffers;          // for buffer object
extern PFNGLNAMEDBUFFERSTORAGEPROC                       pglNamedBufferStorage;
extern PFNGLNAMEDBUFFERDATAPROC                          pglNamedBufferData;
extern PFNGLNAMEDBUFFERSUBDATAPROC                       pglNamedBufferSubData;
extern PFNGLCOPYNAMEDBUFFERSUBDATAPROC                   pglCopyNamedBufferSubData;
extern PFNGLCLEARNAMEDBUFFERDATAPROC                     pglClearNamedBufferData;
extern PFNGLCLEARNAMEDBUFFERSUBDATAPROC                  pglClearNamedBufferSubData;
extern PFNGLMAPNAMEDBUFFERPROC                           pglMapNamedBuffer;
extern PFNGLMAPNAMEDBUFFERRANGEPROC                      pglMapNamedBufferRange;
extern PFNGLUNMAPNAMEDBUFFERPROC                         pglUnmapNamedBuffer;
extern PFNGLFLUSHMAPPEDNAMEDBUFFERRANGEPROC              pglFlushMappedNamedBufferRange;
extern PFNGLGETNAMEDBUFFERPARAMETERIVPROC                pglGetNamedBufferParameteriv;
extern PFNGLGETNAMEDBUFFERPARAMETERI64VPROC              pglGetNamedBufferParameteri64v;
extern PFNGLGETNAMEDBUFFERPOINTERVPROC                   pglGetNamedBufferPointerv;
extern PFNGLGETNAMEDBUFFERSUBDATAPROC                    pglGetNamedBufferSubData;
extern PFNGLCREATEFRAMEBUFFERSPROC                       pglCreateFramebuffers;     // for framebuffer object
extern PFNGLNAMEDFRAMEBUFFERRENDERBUFFERPROC             pglNamedFramebufferRenderbuffer;
extern PFNGLNAMEDFRAMEBUFFERPARAMETERIPROC               pglNamedFramebufferParameteri;
extern PFNGLNAMEDFRAMEBUFFERTEXTUREPROC                  pglNamedFramebufferTexture;
extern PFNGLNAMEDFRAMEBUFFERTEXTURELAYERPROC             pglNamedFramebufferTextureLayer;
extern PFNGLNAMEDFRAMEBUFFERDRAWBUFFERPROC               pglNamedFramebufferDrawBuffer;
extern PFNGLNAMEDFRAMEBUFFERDRAWBUFFERSPROC              pglNamedFramebufferDrawBuffers;
extern PFNGLNAMEDFRAMEBUFFERREADBUFFERPROC               pglNamedFramebufferReadBuffer;
extern PFNGLINVALIDATENAMEDFRAMEBUFFERDATAPROC           pglInvalidateNamedFramebufferData;
extern PFNGLINVALIDATENAMEDFRAMEBUFFERSUBDATAPROC        pglInvalidateNamedFramebufferSubData;
extern PFNGLCLEARNAMEDFRAMEBUFFERIVPROC                  pglClearNamedFramebufferiv;
extern PFNGLCLEARNAMEDFRAMEBUFFERUIVPROC                 pglClearNamedFramebufferuiv;
extern PFNGLCLEARNAMEDFRAMEBUFFERFVPROC                  pglClearNamedFramebufferfv;
extern PFNGLCLEARNAMEDFRAMEBUFFERFIPROC                  pglClearNamedFramebufferfi;
extern PFNGLBLITNAMEDFRAMEBUFFERPROC                     pglBlitNamedFramebuffer;
extern PFNGLCHECKNAMEDFRAMEBUFFERSTATUSPROC              pglCheckNamedFramebufferStatus;
extern PFNGLGETNAMEDFRAMEBUFFERPARAMETERIVPROC           pglGetNamedFramebufferParameteriv;
extern PFNGLGETNAMEDFRAMEBUFFERATTACHMENTPARAMETERIVPROC pglGetNamedFramebufferAttachmentParameteriv;
extern PFNGLCREATERENDERBUFFERSPROC                      pglCreateRenderbuffers;    // for renderbuffer object
extern PFNGLNAMEDRENDERBUFFERSTORAGEPROC                 pglNamedRenderbufferStorage;
extern PFNGLNAMEDRENDERBUFFERSTORAGEMULTISAMPLEPROC      pglNamedRenderbufferStorageMultisample;
extern PFNGLGETNAMEDRENDERBUFFERPARAMETERIVPROC          pglGetNamedRenderbufferParameteriv;
extern PFNGLCREATETEXTURESPROC                           pglCreateTextures;         // for texture object
extern PFNGLTEXTUREBUFFERPROC                            pglTextureBuffer;
extern PFNGLTEXTUREBUFFERRANGEPROC                       pglTextureBufferRange;
extern PFNGLTEXTURESTORAGE1DPROC                         pglTextureStorage1D;
extern PFNGLTEXTURESTORAGE2DPROC                         pglTextureStorage2D;
extern PFNGLTEXTURESTORAGE3DPROC                         pglTextureStorage3D;
extern PFNGLTEXTURESTORAGE2DMULTISAMPLEPROC              pglTextureStorage2DMultisample;
extern PFNGLTEXTURESTORAGE3DMULTISAMPLEPROC              pglTextureStorage3DMultisample;
extern PFNGLTEXTURESUBIMAGE1DPROC                        pglTextureSubImage1D;
extern PFNGLTEXTURESUBIMAGE2DPROC                        pglTextureSubImage2D;
extern PFNGLTEXTURESUBIMAGE3DPROC                        pglTextureSubImage3D;
extern PFNGLCOMPRESSEDTEXTURESUBIMAGE1DPROC              pglCompressedTextureSubImage1D;
extern PFNGLCOMPRESSEDTEXTURESUBIMAGE2DPROC              pglCompressedTextureSubImage2D;
extern PFNGLCOMPRESSEDTEXTURESUBIMAGE3DPROC              pglCompressedTextureSubImage3D;
extern PFNGLCOPYTEXTURESUBIMAGE1DPROC                    pglCopyTextureSubImage1D;
extern PFNGLCOPYTEXTURESUBIMAGE2DPROC                    pglCopyTextureSubImage2D;
extern PFNGLCOPYTEXTURESUBIMAGE3DPROC                    pglCopyTextureSubImage3D;
extern PFNGLTEXTUREPARAMETERFPROC                        pglTextureParameterf;
extern PFNGLTEXTUREPARAMETERFVPROC                       pglTextureParameterfv;
extern PFNGLTEXTUREPARAMETERIPROC                        pglTextureParameteri;
extern PFNGLTEXTUREPARAMETERIIVPROC                      pglTextureParameterIiv;
extern PFNGLTEXTUREPARAMETERIUIVPROC                     pglTextureParameterIuiv;
extern PFNGLTEXTUREPARAMETERIVPROC                       pglTextureParameteriv;
extern PFNGLGENERATETEXTUREMIPMAPPROC                    pglGenerateTextureMipmap;
extern PFNGLBINDTEXTUREUNITPROC                          pglBindTextureUnit;
extern PFNGLGETTEXTUREIMAGEPROC                          pglGetTextureImage;
extern PFNGLGETCOMPRESSEDTEXTUREIMAGEPROC                pglGetCompressedTextureImage;
extern PFNGLGETTEXTURELEVELPARAMETERFVPROC               pglGetTextureLevelParameterfv;
extern PFNGLGETTEXTURELEVELPARAMETERIVPROC               pglGetTextureLevelParameteriv;
extern PFNGLGETTEXTUREPARAMETERFVPROC                    pglGetTextureParameterfv;
extern PFNGLGETTEXTUREPARAMETERIIVPROC                   pglGetTextureParameterIiv;
extern PFNGLGETTEXTUREPARAMETERIUIVPROC                  pglGetTextureParameterIuiv;
extern PFNGLGETTEXTUREPARAMETERIVPROC                    pglGetTextureParameteriv;
extern PFNGLCREATEVERTEXARRAYSPROC                       pglCreateVertexArrays;     // for vertex array object
extern PFNGLDISABLEVERTEXARRAYATTRIBPROC                 pglDisableVertexArrayAttrib;
extern PFNGLENABLEVERTEXARRAYATTRIBPROC                  pglEnableVertexArrayAttrib;
extern PFNGLVERTEXARRAYELEMENTBUFFERPROC                 pglVertexArrayElementBuffer;
extern PFNGLVERTEXARRAYVERTEXBUFFERPROC                  pglVertexArrayVertexBuffer;
extern PFNGLVERTEXARRAYVERTEXBUFFERSPROC                 pglVertexArrayVertexBuffers;
extern PFNGLVERTEXARRAYATTRIBBINDINGPROC                 pglVertexArrayAttribBinding;
extern PFNGLVERTEXARRAYATTRIBFORMATPROC                  pglVertexArrayAttribFormat;
extern PFNGLVERTEXARRAYATTRIBIFORMATPROC                 pglVertexArrayAttribIFormat;
extern PFNGLVERTEXARRAYATTRIBLFORMATPROC                 pglVertexArrayAttribLFormat;
extern PFNGLVERTEXARRAYBINDINGDIVISORPROC                pglVertexArrayBindingDivisor;
extern PFNGLGETVERTEXARRAYIVPROC                         pglGetVertexArrayiv;
extern PFNGLGETVERTEXARRAYINDEXEDIVPROC                  pglGetVertexArrayIndexediv;
extern PFNGLGETVERTEXARRAYINDEXED64IVPROC                pglGetVertexArrayIndexed64iv;
extern PFNGLCREATESAMPLERSPROC                           pglCreateSamplers;         // for sampler object
extern PFNGLCREATEPROGRAMPIPELINESPROC                   pglCreateProgramPipelines; // for program pipeline object
extern PFNGLCREATEQUERIESPROC                            pglCreateQueries;          // for query object
extern PFNGLGETQUERYBUFFEROBJECTIVPROC                   pglGetQueryBufferObjectiv;
extern PFNGLGETQUERYBUFFEROBJECTUIVPROC                  pglGetQueryBufferObjectuiv;
extern PFNGLGETQUERYBUFFEROBJECTI64VPROC                 pglGetQueryBufferObjecti64v;
extern PFNGLGETQUERYBUFFEROBJECTUI64VPROC                pglGetQueryBufferObjectui64v;
#define glCreateTransformFeedbacks                       pglCreateTransformFeedbacks
#define glTransformFeedbackBufferBase                    pglTransformFeedbackBufferBase
#define glTransformFeedbackBufferRange                   pglTransformFeedbackBufferRange
#define glGetTransformFeedbackiv                         pglGetTransformFeedbackiv
#define glGetTransformFeedbacki_v                        pglGetTransformFeedbacki_v
#define glGetTransformFeedbacki64_v                      pglGetTransformFeedbacki64_v
#define glCreateBuffers                                  pglCreateBuffers
#define glNamedBufferStorage                             pglNamedBufferStorage
#define glNamedBufferData                                pglNamedBufferData
#define glNamedBufferSubData                             pglNamedBufferSubData
#define glCopyNamedBufferSubData                         pglCopyNamedBufferSubData
#define glClearNamedBufferData                           pglClearNamedBufferData
#define glClearNamedBufferSubData                        pglClearNamedBufferSubData
#define glMapNamedBuffer                                 pglMapNamedBuffer
#define glMapNamedBufferRange                            pglMapNamedBufferRange
#define glUnmapNamedBuffer                               pglUnmapNamedBuffer
#define glFlushMappedNamedBufferRange                    pglFlushMappedNamedBufferRange
#define glGetNamedBufferParameteriv                      pglGetNamedBufferParameteriv
#define glGetNamedBufferParameteri64v                    pglGetNamedBufferParameteri64v
#define glGetNamedBufferPointerv                         pglGetNamedBufferPointerv
#define glGetNamedBufferSubData                          pglGetNamedBufferSubData
#define glCreateFramebuffers                             pglCreateFramebuffers
#define glNamedFramebufferRenderbuffer                   pglNamedFramebufferRenderbuffer
#define glNamedFramebufferParameteri                     pglNamedFramebufferParameteri
#define glNamedFramebufferTexture                        pglNamedFramebufferTexture
#define glNamedFramebufferTextureLayer                   pglNamedFramebufferTextureLayer
#define glNamedFramebufferDrawBuffer                     pglNamedFramebufferDrawBuffer
#define glNamedFramebufferDrawBuffers                    pglNamedFramebufferDrawBuffers
#define glNamedFramebufferReadBuffer                     pglNamedFramebufferReadBuffer
#define glInvalidateNamedFramebufferData                 pglInvalidateNamedFramebufferData
#define glInvalidateNamedFramebufferSubData              pglInvalidateNamedFramebufferSubData
#define glClearNamedFramebufferiv                        pglClearNamedFramebufferiv
#define glClearNamedFramebufferuiv                       pglClearNamedFramebufferuiv
#define glClearNamedFramebufferfv                        pglClearNamedFramebufferfv
#define glClearNamedFramebufferfi                        pglClearNamedFramebufferfi
#define glBlitNamedFramebuffer                           pglBlitNamedFramebuffer
#define glCheckNamedFramebufferStatus                    pglCheckNamedFramebufferStatus
#define glGetNamedFramebufferParameteriv                 pglGetNamedFramebufferParameteriv
#define glGetNamedFramebufferAttachmentParameteriv       pglGetNamedFramebufferAttachmentParameteriv
#define glCreateRenderbuffers                            pglCreateRenderbuffers
#define glNamedRenderbufferStorage                       pglNamedRenderbufferStorage
#define glNamedRenderbufferStorageMultisample            pglNamedRenderbufferStorageMultisample
#define glGetNamedRenderbufferParameteriv                pglGetNamedRenderbufferParameteriv
#define glCreateTextures                                 pglCreateTextures
#define glTextureBuffer                                  pglTextureBuffer
#define glTextureBufferRange                             pglTextureBufferRange
#define glTextureStorage1D                               pglTextureStorage1D
#define glTextureStorage2D                               pglTextureStorage2D
#define glTextureStorage3D                               pglTextureStorage3D
#define glTextureStorage2DMultisample                    pglTextureStorage2DMultisample
#define glTextureStorage3DMultisample                    pglTextureStorage3DMultisample
#define glTextureSubImage1D                              pglTextureSubImage1D
#define glTextureSubImage2D                              pglTextureSubImage2D
#define glTextureSubImage3D                              pglTextureSubImage3D
#define glCompressedTextureSubImage1D                    pglCompressedTextureSubImage1D
#define glCompressedTextureSubImage2D                    pglCompressedTextureSubImage2D
#define glCompressedTextureSubImage3D                    pglCompressedTextureSubImage3D
#define glCopyTextureSubImage1D                          pglCopyTextureSubImage1D
#define glCopyTextureSubImage2D                          pglCopyTextureSubImage2D
#define glCopyTextureSubImage3D                          pglCopyTextureSubImage3D
#define glTextureParameterf                              pglTextureParameterf
#define glTextureParameterfv                             pglTextureParameterfv
#define glTextureParameteri                              pglTextureParameteri
#define glTextureParameterIiv                            pglTextureParameterIiv
#define glTextureParameterIuiv                           pglTextureParameterIuiv
#define glTextureParameteriv                             pglTextureParameteriv
#define glGenerateTextureMipmap                          pglGenerateTextureMipmap
#define glBindTextureUnit                                pglBindTextureUnit
#define glGetTextureImage                                pglGetTextureImage
#define glGetCompressedTextureImage                      pglGetCompressedTextureImage
#define glGetTextureLevelParameterfv                     pglGetTextureLevelParameterfv
#define glGetTextureLevelParameteriv                     pglGetTextureLevelParameteriv
#define glGetTextureParameterfv                          pglGetTextureParameterfv
#define glGetTextureParameterIiv                         pglGetTextureParameterIiv
#define glGetTextureParameterIuiv                        pglGetTextureParameterIuiv
#define glGetTextureParameteriv                          pglGetTextureParameteriv
#define glCreateVertexArrays                             pglCreateVertexArrays
#define glDisableVertexArrayAttrib                       pglDisableVertexArrayAttrib
#define glEnableVertexArrayAttrib                        pglEnableVertexArrayAttrib
#define glVertexArrayElementBuffer                       pglVertexArrayElementBuffer
#define glVertexArrayVertexBuffer                        pglVertexArrayVertexBuffer
#define glVertexArrayVertexBuffers                       pglVertexArrayVertexBuffers
#define glVertexArrayAttribBinding                       pglVertexArrayAttribBinding
#define glVertexArrayAttribFormat                        pglVertexArrayAttribFormat
#define glVertexArrayAttribIFormat                       pglVertexArrayAttribIFormat
#define glVertexArrayAttribLFormat                       pglVertexArrayAttribLFormat
#define glVertexArrayBindingDivisor                      pglVertexArrayBindingDivisor
#define glGetVertexArrayiv                               pglGetVertexArrayiv
#define glGetVertexArrayIndexediv                        pglGetVertexArrayIndexediv
#define glGetVertexArrayIndexed64iv                      pglGetVertexArrayIndexed64iv
#define glCreateSamplers                                 pglCreateSamplers
#define glCreateProgramPipelines                         pglCreateProgramPipelines
#define glCreateQueries                                  pglCreateQueries
#define glGetQueryBufferObjectiv                         pglGetQueryBufferObjectiv
#define glGetQueryBufferObjectuiv                        pglGetQueryBufferObjectuiv
#define glGetQueryBufferObjecti64v                       pglGetQueryBufferObjecti64v
#define glGetQueryBufferObjectui64v                      pglGetQueryBufferObjectui64v



// WGL_ARB_extensions_string
typedef const char* (WINAPI * PFNWGLGETEXTENSIONSSTRINGARBPROC)(HDC hdc);
extern PFNWGLGETEXTENSIONSSTRINGARBPROC pwglGetExtensionsStringARB;
#define wglGetExtensionsStringARB       pwglGetExtensionsStringARB

// WGL_ARB_pixel_format
typedef BOOL (WINAPI * PFNWGLGETPIXELFORMATATTRIBIVARBPROC) (HDC hdc, int iPixelFormat, int iLayerPlane, UINT nAttributes, const int *piAttributes, int *piValues);
typedef BOOL (WINAPI * PFNWGLGETPIXELFORMATATTRIBFVARBPROC) (HDC hdc, int iPixelFormat, int iLayerPlane, UINT nAttributes, const int *piAttributes, FLOAT *pfValues);
typedef BOOL (WINAPI * PFNWGLCHOOSEPIXELFORMATARBPROC) (HDC hdc, const int *piAttribIList, const FLOAT *pfAttribFList, UINT nMaxFormats, int *piFormats, UINT *nNumFormats);
extern PFNWGLGETPIXELFORMATATTRIBIVARBPROC  pwglGetPixelFormatAttribivARB;
extern PFNWGLGETPIXELFORMATATTRIBFVARBPROC  pwglGetPixelFormatAttribfvARB;
extern PFNWGLCHOOSEPIXELFORMATARBPROC       pwglChoosePixelFormatARB;
#define wglGetPixelFormatAttribivARB        pwglGetPixelFormatAttribivARB
#define wglGetPixelFormatAttribfvARB        pwglGetPixelFormatAttribfvARB
#define wglChoosePixelFormatARB             pwglChoosePixelFormatARB

// WGL_ARB_create_context
typedef HGLRC (WINAPI * PFNWGLCREATECONTEXTATTRIBSARBPROC) (HDC hDC, HGLRC hShareContext, const int *attribList);
extern PFNWGLCREATECONTEXTATTRIBSARBPROC    pwglCreateContextAttribsARB;
#define wglCreateContextAttribsARB          pwglCreateContextAttribsARB

// WGL_EXT_swap_control
typedef BOOL (WINAPI * PFNWGLSWAPINTERVALEXTPROC) (int interval);
typedef int (WINAPI * PFNWGLGETSWAPINTERVALEXTPROC) (void);
extern PFNWGLSWAPINTERVALEXTPROC    pwglSwapIntervalEXT;
extern PFNWGLGETSWAPINTERVALEXTPROC pwglGetSwapIntervalEXT;
#define wglSwapIntervalEXT          pwglSwapIntervalEXT
#define wglGetSwapIntervalEXT       pwglGetSwapIntervalEXT

#endif //======================================================================

#endif // end of #ifndef
