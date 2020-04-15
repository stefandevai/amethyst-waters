///////////////////////////////////////////////////////////////////////////////
// Icosahedron.cpp
// ===============
// Polyhedron with 12 vertices, 30 edges and 20 faces (triangles) for OpenGL
// If the radius is r, then the length of edge is (r / sin(2pi/5)).
//
// Vertices of icosahedron are constructed with spherical coords by aligning
// the north pole to (0,0,r) and the south pole to (0,0,-r). Other 10 vertices
// are computed by rotating 72 degree along y-axis at the elevation angle
// +/- 26.565 (=arctan(1/2)).
//
// The unwrapped (paper model) of icosahedron and texture map looks like;
// (S,0)  3S  5S  7S  9S
//    /\  /\  /\  /\  /\      : 1st row (5 triangles)       //
//   /__\/__\/__\/__\/__\                                   //
// T \  /\  /\  /\  /\  /\    : 2nd row (10 triangles)      //
//    \/__\/__\/__\/__\/__\                                 //
// 2T  \  /\  /\  /\  /\  /   : 3rd row (5 triangles)       //
//      \/  \/  \/  \/  \/                                  //
//      2S  4S  6S  8S  (10S,3T)
// where S = 186/2048 = 0.0908203
//       T = 322/1024 = 0.3144531
// If a texture size is 2048x1024, S=186, T=322
//
//  AUTHOR: Song Ho Ahn (song.ahn@gmail.com)
// CREATED: 2018-07-17
// UPDATED: 2018-07-31
///////////////////////////////////////////////////////////////////////////////

#ifdef _WIN32
#include <windows.h>    // include windows.h to avoid thousands of compile errors even though this class is not depending on Windows
#endif

#ifdef __APPLE__
#include <OpenGL/gl.h>
#else
#include <GL/gl.h>
#endif

#include <iostream>
#include <iomanip>
#include <cmath>
#include "Icosahedron.h"



// constants //////////////////////////////////////////////////////////////////




///////////////////////////////////////////////////////////////////////////////
// ctor
///////////////////////////////////////////////////////////////////////////////
Icosahedron::Icosahedron(float radius) : interleavedStride(32)
{
    setRadius(radius);
}



///////////////////////////////////////////////////////////////////////////////
// setters
///////////////////////////////////////////////////////////////////////////////
void Icosahedron::setRadius(float radius)
{
    this->radius = radius;
    this->edgeLength = radius / sinf(2 * 3.141592f / 5);
    if(vertices.size() <= 0)
        buildVertices();
    else
        updateRadius(); // update vertex positions only
}

void Icosahedron::setEdgeLength(float edge)
{
    this->edgeLength = edge;
    this->radius = edge * sinf(2 * 3.141592f / 5);
    updateRadius(); // update vertex positions only
}



///////////////////////////////////////////////////////////////////////////////
// print itself
///////////////////////////////////////////////////////////////////////////////
void Icosahedron::printSelf() const
{

    std::cout << "===== Icosahedron =====\n"
              << "        Radius: " << radius << "\n"
              << "   Edge Length: " << edgeLength << "\n"
              << "Triangle Count: " << getTriangleCount() << "\n"
              << "   Index Count: " << getIndexCount() << "\n"
              << "  Vertex Count: " << getVertexCount() << "\n"
              << "  Normal Count: " << getNormalCount() << "\n"
              << "TexCoord Count: " << getTexCoordCount() << std::endl;
}



///////////////////////////////////////////////////////////////////////////////
// draw a icosahedron in VertexArray mode
// OpenGL RC must be set before calling it
///////////////////////////////////////////////////////////////////////////////
void Icosahedron::draw() const
{
    // interleaved array
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_NORMAL_ARRAY);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    glVertexPointer(3, GL_FLOAT, interleavedStride, &interleavedVertices[0]);
    glNormalPointer(GL_FLOAT, interleavedStride, &interleavedVertices[3]);
    glTexCoordPointer(2, GL_FLOAT, interleavedStride, &interleavedVertices[6]);

    glDrawElements(GL_TRIANGLES, (unsigned int)indices.size(), GL_UNSIGNED_INT, indices.data());

    glDisableClientState(GL_VERTEX_ARRAY);
    glDisableClientState(GL_NORMAL_ARRAY);
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
}



///////////////////////////////////////////////////////////////////////////////
// draw lines only
// the caller must set the line width before call this
///////////////////////////////////////////////////////////////////////////////
void Icosahedron::drawLines(const float lineColor[4]) const
{
    // set line colour
    glColor4fv(lineColor);
    glMaterialfv(GL_FRONT, GL_DIFFUSE,   lineColor);

    // draw lines with VA
    glDisable(GL_LIGHTING);
    glDisable(GL_TEXTURE_2D);
    glEnableClientState(GL_VERTEX_ARRAY);
    glVertexPointer(3, GL_FLOAT, 0, vertices.data());

    glDrawElements(GL_LINES, (unsigned int)lineIndices.size(), GL_UNSIGNED_INT, lineIndices.data());

    glDisableClientState(GL_VERTEX_ARRAY);
    glEnable(GL_LIGHTING);
    glEnable(GL_TEXTURE_2D);
}



///////////////////////////////////////////////////////////////////////////////
// draw a icosahedron surfaces and lines on top of it
// the caller must set the line width before call this
///////////////////////////////////////////////////////////////////////////////
void Icosahedron::drawWithLines(const float lineColor[4]) const
{
    glEnable(GL_POLYGON_OFFSET_FILL);
    glPolygonOffset(1.0, 1.0f); // move polygon backward
    this->draw();
    glDisable(GL_POLYGON_OFFSET_FILL);

    // draw lines with VA
    drawLines(lineColor);
}



///////////////////////////////////////////////////////////////////////////////
// update vertex positions only
///////////////////////////////////////////////////////////////////////////////
void Icosahedron::updateRadius()
{
    float scale = sqrtf(radius * radius / (vertices[0] * vertices[0] + vertices[1] * vertices[1] + vertices[2] * vertices[2]));

    std::size_t i, j;
    std::size_t count = vertices.size();
    for(i = 0, j = 0; i < count; i += 3, j += 8)
    {
        vertices[i]   *= scale;
        vertices[i+1] *= scale;
        vertices[i+2] *= scale;

        // for interleaved array
        interleavedVertices[j]   *= scale;
        interleavedVertices[j+1] *= scale;
        interleavedVertices[j+2] *= scale;
    }
}



///////////////////////////////////////////////////////////////////////////////
// compute 12 vertices of icosahedron using spherical coordinates
// The north pole is at (0, 0, r) and the south pole is at (0,0,-r).
// 5 vertices are placed by rotating 72 deg at elevation 26.57 deg (=atan(1/2))
// 5 vertices are placed by rotating 72 deg at elevation -26.57 deg
///////////////////////////////////////////////////////////////////////////////
std::vector<float> Icosahedron::computeVertices()
{
    const float PI = 3.1415926f;
    const float H_ANGLE = PI / 180 * 72;    // 72 degree = 360 / 5
    const float V_ANGLE = atanf(1.0f / 2);  // elevation = 26.565 degree

    std::vector<float> vertices(12 * 3);    // 12 vertices
    int i1, i2;                             // indices
    float z, xy;                            // coords
    float hAngle1 = -PI / 2 - H_ANGLE / 2;  // start from -126 deg at 2nd row
    float hAngle2 = -PI / 2;                // start from -90 deg at 3rd row

    // the first top vertex (0, 0, r)
    vertices[0] = 0;
    vertices[1] = 0;
    vertices[2] = radius;

    // 10 vertices at 2nd and 3rd rows
    for(int i = 1; i <= 5; ++i)
    {
        i1 = i * 3;         // for 2nd row
        i2 = (i + 5) * 3;   // for 3rd row

        z = radius * sinf(V_ANGLE);             // elevaton
        xy = radius * cosf(V_ANGLE);

        vertices[i1] = xy * cosf(hAngle1);      // x
        vertices[i2] = xy * cosf(hAngle2);
        vertices[i1 + 1] = xy * sinf(hAngle1);  // y
        vertices[i2 + 1] = xy * sinf(hAngle2);
        vertices[i1 + 2] = z;                   // z
        vertices[i2 + 2] = -z;

        // next horizontal angles
        hAngle1 += H_ANGLE;
        hAngle2 += H_ANGLE;
    }

    // the last bottom vertex (0, 0, -r)
    i1 = 11 * 3;
    vertices[i1] = 0;
    vertices[i1 + 1] = 0;
    vertices[i1 + 2] = -radius;

    return vertices;
}



///////////////////////////////////////////////////////////////////////////////
// generate vertices with flat shading
// each triangle is independent (no shared vertices)
// NOTE: The texture coords are offset in order to align coords to image pixels
//    (S,0)  3S  5S  7S  (9S,0)
//       /\  /\  /\  /\  /\             //
//      /__\/__\/__\/__\/__\(10S,T)     //
// (0,T)\  /\  /\  /\  /\  /\           //
//       \/__\/__\/__\/__\/__\(11S,2T)  //
//  (S,2T)\  /\  /\  /\  /\  /          //
//         \/  \/  \/  \/  \/           //
//    (2S,3T)  4S  6S  8S  (10S,3T)
// where S = 186/2048 = 0.0908203
//       T = 322/1024 = 0.3144531, If texture size is 2048x1024, S=186, T=322
///////////////////////////////////////////////////////////////////////////////
void Icosahedron::buildVertices()
{
    //const float S_STEP = 1 / 11.0f;         // horizontal texture step
    //const float T_STEP = 1 / 3.0f;          // vertical texture step
    const float S_STEP = 186 / 2048.0f;     // horizontal texture step
    const float T_STEP = 322 / 1024.0f;     // vertical texture step

    // compute 12 vertices of icosahedron
    std::vector<float> tmpVertices = computeVertices();

    // clear memory of prev arrays
    std::vector<float>().swap(vertices);
    std::vector<float>().swap(normals);
    std::vector<float>().swap(texCoords);
    std::vector<unsigned int>().swap(indices);
    std::vector<unsigned int>().swap(lineIndices);

    float *v0, *v1, *v2, *v3, *v4, *v11;                // vertex positions
    float n[3];                                         // face normal
    float t0[2], t1[2], t2[2], t3[2], t4[2], t11[2];    // texCoords
    unsigned int index = 0;

    // compute and add 20 tiangles
    v0 = &tmpVertices[0];       // 1st vertex
    v11 = &tmpVertices[11 * 3]; // 12th vertex
    for(int i = 1; i <= 5; ++i)
    {
        // 4 vertices in the 2nd row
        v1 = &tmpVertices[i * 3];
        if(i < 5)
            v2 = &tmpVertices[(i + 1) * 3];
        else
            v2 = &tmpVertices[3];

        v3 = &tmpVertices[(i + 5) * 3];
        if((i + 5) < 10)
            v4 = &tmpVertices[(i + 6) * 3];
        else
            v4 = &tmpVertices[6 * 3];

        // texture coords
        t0[0] = (2 * i - 1) * S_STEP;   t0[1] = 0;
        t1[0] = (2 * i - 2) * S_STEP;   t1[1] = T_STEP;
        t2[0] = (2 * i - 0) * S_STEP;   t2[1] = T_STEP;
        t3[0] = (2 * i - 1) * S_STEP;   t3[1] = T_STEP * 2;
        t4[0] = (2 * i + 1) * S_STEP;   t4[1] = T_STEP * 2;
        t11[0]= 2 * i * S_STEP;         t11[1]= T_STEP * 3;

        // add a triangle in 1st row
        Icosahedron::computeFaceNormal(v0, v1, v2, n);
        addVertices(v0, v1, v2);
        addNormals(n, n, n);
        addTexCoords(t0, t1, t2);
        addIndices(index, index+1, index+2);

        // add 2 triangles in 2nd row
        Icosahedron::computeFaceNormal(v1, v3, v2, n);
        addVertices(v1, v3, v2);
        addNormals(n, n, n);
        addTexCoords(t1, t3, t2);
        addIndices(index+3, index+4, index+5);

        Icosahedron::computeFaceNormal(v2, v3, v4, n);
        addVertices(v2, v3, v4);
        addNormals(n, n, n);
        addTexCoords(t2, t3, t4);
        addIndices(index+6, index+7, index+8);

        // add a triangle in 3rd row
        Icosahedron::computeFaceNormal(v3, v11, v4, n);
        addVertices(v3, v11, v4);
        addNormals(n, n, n);
        addTexCoords(t3, t11, t4);
        addIndices(index+9, index+10, index+11);

        // add 6 edge lines per iteration
        addLineIndices(index);

        // next index
        index += 12;
    }

    // generate interleaved vertex array as well
    buildInterleavedVertices();
}



///////////////////////////////////////////////////////////////////////////////
// generate interleaved vertices: V/N/T
// stride must be 32 bytes
///////////////////////////////////////////////////////////////////////////////
void Icosahedron::buildInterleavedVertices()
{
    std::vector<float>().swap(interleavedVertices);

    std::size_t i, j;
    std::size_t count = vertices.size();
    for(i = 0, j = 0; i < count; i += 3, j += 2)
    {
        interleavedVertices.push_back(vertices[i]);
        interleavedVertices.push_back(vertices[i+1]);
        interleavedVertices.push_back(vertices[i+2]);

        interleavedVertices.push_back(normals[i]);
        interleavedVertices.push_back(normals[i+1]);
        interleavedVertices.push_back(normals[i+2]);

        interleavedVertices.push_back(texCoords[j]);
        interleavedVertices.push_back(texCoords[j+1]);
    }
}



///////////////////////////////////////////////////////////////////////////////
// add 3 vertices to array
///////////////////////////////////////////////////////////////////////////////
void Icosahedron::addVertices(float v1[3], float v2[3], float v3[3])
{
    vertices.push_back(v1[0]);  // x
    vertices.push_back(v1[1]);  // y
    vertices.push_back(v1[2]);  // z
    vertices.push_back(v2[0]);
    vertices.push_back(v2[1]);
    vertices.push_back(v2[2]);
    vertices.push_back(v3[0]);
    vertices.push_back(v3[1]);
    vertices.push_back(v3[2]);
}



///////////////////////////////////////////////////////////////////////////////
// add 3 normals to array
///////////////////////////////////////////////////////////////////////////////
void Icosahedron::addNormals(float n1[3], float n2[3], float n3[3])
{
    normals.push_back(n1[0]);  // nx
    normals.push_back(n1[1]);  // ny
    normals.push_back(n1[2]);  // nz
    normals.push_back(n2[0]);
    normals.push_back(n2[1]);
    normals.push_back(n2[2]);
    normals.push_back(n3[0]);
    normals.push_back(n3[1]);
    normals.push_back(n3[2]);
}



///////////////////////////////////////////////////////////////////////////////
// add 3 texture coords to array
///////////////////////////////////////////////////////////////////////////////
void Icosahedron::addTexCoords(float t1[2], float t2[2], float t3[2])
{
    texCoords.push_back(t1[0]); // s
    texCoords.push_back(t1[1]); // t
    texCoords.push_back(t2[0]);
    texCoords.push_back(t2[1]);
    texCoords.push_back(t3[0]);
    texCoords.push_back(t3[1]);
}



///////////////////////////////////////////////////////////////////////////////
// add 3 indices to array
///////////////////////////////////////////////////////////////////////////////
void Icosahedron::addIndices(unsigned int i1, unsigned int i2, unsigned int i3)
{
    indices.push_back(i1);
    indices.push_back(i2);
    indices.push_back(i3);
}



///////////////////////////////////////////////////////////////////////////////
// add 6 edge lines to array starting from param (i)
//  /   /   /   /   /       : (i, i+1)                          //
// /__ /__ /__ /__ /__                                          //
// \  /\  /\  /\  /\  /     : (i+3, i+4), (i+3, i+5), (i+4, i+5)//
//  \/__\/__\/__\/__\/__                                        //
//   \   \   \   \   \      : (i+9,i+10), (i+9, i+11)           //
//    \   \   \   \   \                                         //
///////////////////////////////////////////////////////////////////////////////
void Icosahedron::addLineIndices(unsigned int index)
{
    lineIndices.push_back(index);       // (i, i+1)
    lineIndices.push_back(index+1);
    lineIndices.push_back(index+3);     // (i+3, i+4)
    lineIndices.push_back(index+4);
    lineIndices.push_back(index+3);     // (i+3, i+5)
    lineIndices.push_back(index+5);
    lineIndices.push_back(index+4);     // (i+4, i+5)
    lineIndices.push_back(index+5);
    lineIndices.push_back(index+9);     // (i+9, i+10)
    lineIndices.push_back(index+10);
    lineIndices.push_back(index+9);     // (i+9, i+11)
    lineIndices.push_back(index+11);
}



// static functions ===========================================================
///////////////////////////////////////////////////////////////////////////////
// return face normal of a triangle v1-v2-v3
// if a triangle has no surface (normal length = 0), then return a zero vector
///////////////////////////////////////////////////////////////////////////////
void Icosahedron::computeFaceNormal(float v1[3], float v2[3], float v3[3], float n[3])
{
    const float EPSILON = 0.000001f;

    // default return value (0, 0, 0)
    n[0] = n[1] = n[2] = 0;

    // find 2 edge vectors: v1-v2, v1-v3
    float ex1 = v2[0] - v1[0];
    float ey1 = v2[1] - v1[1];
    float ez1 = v2[2] - v1[2];
    float ex2 = v3[0] - v1[0];
    float ey2 = v3[1] - v1[1];
    float ez2 = v3[2] - v1[2];

    // cross product: e1 x e2
    float nx, ny, nz;
    nx = ey1 * ez2 - ez1 * ey2;
    ny = ez1 * ex2 - ex1 * ez2;
    nz = ex1 * ey2 - ey1 * ex2;

    // normalize only if the length is > 0
    float length = sqrtf(nx * nx + ny * ny + nz * nz);
    if(length > EPSILON)
    {
        // normalize
        float lengthInv = 1.0f / length;
        n[0] = nx * lengthInv;
        n[1] = ny * lengthInv;
        n[2] = nz * lengthInv;
    }
}
