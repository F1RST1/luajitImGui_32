#define CIMGUI_DEFINE_ENUMS_AND_STRUCTS
#include "cimplot.h"
#include "cimplot3d.h"

CIMGUI_API int ImPlot_PlotLine_FloatPtrFloatPtr_Ptr(
    const char* label_id,
    const float* xs,
    const float* ys,
    int count,
    const ImPlotSpec_c* spec)
{
    if (spec == nullptr)
        return -1;

    ImPlot_PlotLine_FloatPtrFloatPtr(label_id, xs, ys, count, *spec);
    return 0;
}

CIMGUI_API int ImPlot_PlotLineG_Ptr(
    const char* label_id,
    ImPlotPoint_getter getter,
    void* data,
    int count,
    const ImPlotSpec_c* spec)
{
    if (spec == nullptr)
        return -1;

    ImPlot_PlotLineG_LJ(label_id, getter, data, count, *spec);
    return 0;
}

CIMGUI_API int ImPlot3D_PlotLine_FloatPtr_Ptr(
    const char* label_id,
    const float* xs,
    const float* ys,
    const float* zs,
    int count,
    const ImPlot3DSpec_c* spec)
{
    if (spec == nullptr)
        return -1;

    ImPlot3D_PlotLine_FloatPtr(label_id, xs, ys, zs, count, *spec);
    return 0;
}
