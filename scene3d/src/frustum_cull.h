#include <dmsdk/sdk.h>

// Frustum Culling.
//
// Based on:
// - https://gist.github.com/podgorskiy/e698d18879588ada9014768e3e82a644
// - http://iquilezles.org/www/articles/frustumcorrect/frustumcorrect.htm

class Frustum
{
    public:
    Frustum() {}

    // m = ProjectionMatrix * ViewMatrix
    Frustum(dmVMath::Matrix4 m);

    bool IsBoxVisible(const dmVMath::Vector3& minp, const dmVMath::Vector3& maxp) const;

    private:
    enum Planes
    {
        Left = 0,
        Right,
        Bottom,
        Top,
        Near,
        Far,
        Count,
        Combinations = Count * (Count - 1) / 2
    };

    template <Planes i, Planes j>
    struct ij2k
    {
        enum
        {
            k = i * (9 - i) / 2 + j - 1
        };
    };

    template <Planes a, Planes b, Planes c>
    dmVMath::Vector3 intersection(const dmVMath::Vector3* crosses) const;

    dmVMath::Vector4 m_Planes[Count];
    dmVMath::Vector3 m_Points[8];
};

static inline dmVMath::Vector3 ToVector3(const dmVMath::Vector4& v)
{
    return dmVMath::Vector3(v.getX(), v.getY(), v.getZ());
}

inline Frustum::Frustum(dmVMath::Matrix4 m)
{
    using namespace dmVMath;

    m                = transpose(m);
    m_Planes[Left]   = m.getCol3() + m.getCol0();
    m_Planes[Right]  = m.getCol3() - m.getCol0();
    m_Planes[Bottom] = m.getCol3() + m.getCol1();
    m_Planes[Top]    = m.getCol3() - m.getCol1();
    m_Planes[Near]   = m.getCol3() + m.getCol2();
    m_Planes[Far]    = m.getCol3() - m.getCol2();

    Vector3 crosses[Combinations] = {
        cross(ToVector3(m_Planes[Left]), ToVector3(m_Planes[Right])),
        cross(ToVector3(m_Planes[Left]), ToVector3(m_Planes[Bottom])),
        cross(ToVector3(m_Planes[Left]), ToVector3(m_Planes[Top])),
        cross(ToVector3(m_Planes[Left]), ToVector3(m_Planes[Near])),
        cross(ToVector3(m_Planes[Left]), ToVector3(m_Planes[Far])),
        cross(ToVector3(m_Planes[Right]), ToVector3(m_Planes[Bottom])),
        cross(ToVector3(m_Planes[Right]), ToVector3(m_Planes[Top])),
        cross(ToVector3(m_Planes[Right]), ToVector3(m_Planes[Near])),
        cross(ToVector3(m_Planes[Right]), ToVector3(m_Planes[Far])),
        cross(ToVector3(m_Planes[Bottom]), ToVector3(m_Planes[Top])),
        cross(ToVector3(m_Planes[Bottom]), ToVector3(m_Planes[Near])),
        cross(ToVector3(m_Planes[Bottom]), ToVector3(m_Planes[Far])),
        cross(ToVector3(m_Planes[Top]), ToVector3(m_Planes[Near])),
        cross(ToVector3(m_Planes[Top]), ToVector3(m_Planes[Far])),
        cross(ToVector3(m_Planes[Near]), ToVector3(m_Planes[Far]))
    };

    m_Points[0] = intersection<Left, Bottom, Near>(crosses);
    m_Points[1] = intersection<Left, Top, Near>(crosses);
    m_Points[2] = intersection<Right, Bottom, Near>(crosses);
    m_Points[3] = intersection<Right, Top, Near>(crosses);
    m_Points[4] = intersection<Left, Bottom, Far>(crosses);
    m_Points[5] = intersection<Left, Top, Far>(crosses);
    m_Points[6] = intersection<Right, Bottom, Far>(crosses);
    m_Points[7] = intersection<Right, Top, Far>(crosses);
}

inline bool Frustum::IsBoxVisible(const dmVMath::Vector3& minp, const dmVMath::Vector3& maxp) const
{
    using namespace dmVMath;

    // check box outside/inside of frustum
    for (int i = 0; i < Count; i++)
    {
        if ((dot(m_Planes[i], Vector4(minp.getX(), minp.getY(), minp.getZ(), 1.0f)) < 0.0) &&
            (dot(m_Planes[i], Vector4(maxp.getX(), minp.getY(), minp.getZ(), 1.0f)) < 0.0) &&
            (dot(m_Planes[i], Vector4(minp.getX(), maxp.getY(), minp.getZ(), 1.0f)) < 0.0) &&
            (dot(m_Planes[i], Vector4(maxp.getX(), maxp.getY(), minp.getZ(), 1.0f)) < 0.0) &&
            (dot(m_Planes[i], Vector4(minp.getX(), minp.getY(), maxp.getZ(), 1.0f)) < 0.0) &&
            (dot(m_Planes[i], Vector4(maxp.getX(), minp.getY(), maxp.getZ(), 1.0f)) < 0.0) &&
            (dot(m_Planes[i], Vector4(minp.getX(), maxp.getY(), maxp.getZ(), 1.0f)) < 0.0) &&
            (dot(m_Planes[i], Vector4(maxp.getX(), maxp.getY(), maxp.getZ(), 1.0f)) < 0.0))
        {
            return false;
        }
    }

    // check frustum outside/inside box
    int out;
    out = 0;
    for (int i = 0; i < 8; i++)
        out += ((m_Points[i].getX() > maxp.getX()) ? 1 : 0);
    if (out == 8)
        return false;
    out = 0;
    for (int i = 0; i < 8; i++)
        out += ((m_Points[i].getX() < minp.getX()) ? 1 : 0);
    if (out == 8)
        return false;
    out = 0;
    for (int i = 0; i < 8; i++)
        out += ((m_Points[i].getY() > maxp.getY()) ? 1 : 0);
    if (out == 8)
        return false;
    out = 0;
    for (int i = 0; i < 8; i++)
        out += ((m_Points[i].getY() < minp.getY()) ? 1 : 0);
    if (out == 8)
        return false;
    out = 0;
    for (int i = 0; i < 8; i++)
        out += ((m_Points[i].getZ() > maxp.getZ()) ? 1 : 0);
    if (out == 8)
        return false;
    out = 0;
    for (int i = 0; i < 8; i++)
        out += ((m_Points[i].getZ() < minp.getZ()) ? 1 : 0);
    if (out == 8)
        return false;

    return true;
}

template <Frustum::Planes a, Frustum::Planes b, Frustum::Planes c>
inline dmVMath::Vector3 Frustum::intersection(const dmVMath::Vector3* crosses) const
{
    using namespace dmVMath;

    float D     = dot(ToVector3(m_Planes[a]), crosses[ij2k<b, c>::k]);
    Vector3 res = Matrix3(crosses[ij2k<b, c>::k], -crosses[ij2k<a, c>::k], crosses[ij2k<a, b>::k]) * Vector3(m_Planes[a].getW(), m_Planes[b].getW(), m_Planes[c].getW());
    return res * (-1.0f / D);
}
