///////////////////////////////////////////////////////////////////////////////
// Icosahedron.h
// =============
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
// UPDATED: 2019-12-29
///////////////////////////////////////////////////////////////////////////////

#ifndef GEOMETRY_ICOSAHEDRON_H
#define GEOMETRY_ICOSAHEDRON_H

#include <vector>

class Icosahedron
{
public:
    // ctor/dtor
    Icosahedron(float radius=1.0f);
    ~Icosahedron() {}

    // getters/setters
    float getRadius() const                 { return radius; }
    void setRadius(float radius);
    float getEdgeLength() const             { return edgeLength; }
    void setEdgeLength(float edge);

    // for vertex data
    unsigned int getVertexCount() const     { return (unsigned int)vertices.size() / 3; }
    unsigned int getNormalCount() const     { return (unsigned int)normals.size() / 3; }
    unsigned int getTexCoordCount() const   { return (unsigned int)texCoords.size() / 2; }
    unsigned int getIndexCount() const      { return (unsigned int)indices.size(); }
    unsigned int getLineIndexCount() const  { return (unsigned int)lineIndices.size(); }
    unsigned int getTriangleCount() const   { return getIndexCount() / 3; }

    unsigned int getVertexSize() const      { return (unsigned int)vertices.size() * sizeof(float); }   // # of bytes
    unsigned int getNormalSize() const      { return (unsigned int)normals.size() * sizeof(float); }
    unsigned int getTexCoordSize() const    { return (unsigned int)texCoords.size() * sizeof(float); }
    unsigned int getIndexSize() const       { return (unsigned int)indices.size() * sizeof(unsigned int); }
    unsigned int getLineIndexSize() const   { return (unsigned int)lineIndices.size() * sizeof(unsigned int); }

    const float* getVertices() const        { return vertices.data(); }
    const float* getNormals() const         { return normals.data(); }
    const float* getTexCoords() const       { return texCoords.data(); }
    const unsigned int* getIndices() const  { return indices.data(); }
    const unsigned int* getLineIndices() const  { return lineIndices.data(); }

    // for interleaved vertices: V/N/T
    unsigned int getInterleavedVertexCount() const  { return getVertexCount(); }    // # of vertices
    unsigned int getInterleavedVertexSize() const   { return (unsigned int)interleavedVertices.size() * sizeof(float); }    // # of bytes
    int getInterleavedStride() const                { return interleavedStride; }   // should be 32 bytes
    const float* getInterleavedVertices() const     { return interleavedVertices.data(); }

    // draw in VertexArray mode
    void draw() const;
    void drawLines(const float lineColor[4]) const;
    void drawWithLines(const float lineColor[4]) const;

    // debug
    void printSelf() const;

protected:

private:
    // static functions
    static void computeFaceNormal(float v1[3], float v2[3], float v3[3], float n[3]);

    // member functions
    void updateRadius();
    std::vector<float> computeVertices();
    void buildVertices();
    void buildInterleavedVertices();
    void addVertices(float v1[3], float v2[3], float v3[3]);
    void addNormals(float n1[3], float n2[3], float n3[3]);
    void addTexCoords(float t1[2], float t2[2], float t3[2]);
    void addIndices(unsigned int i1, unsigned int i2, unsigned int i3);
    void addLineIndices(unsigned int indexFrom);

    // memeber vars
    float radius;                           // circumscribed radius
    float edgeLength;
    std::vector<float> vertices;
    std::vector<float> normals;
    std::vector<float> texCoords;
    std::vector<unsigned int> indices;
    std::vector<unsigned int> lineIndices;

    // interleaved
    std::vector<float> interleavedVertices;
    int interleavedStride;                  // # of bytes to hop to the next vertex (should be 32 bytes)

};

#endif
