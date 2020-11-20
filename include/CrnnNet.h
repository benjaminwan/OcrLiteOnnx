#ifndef __OCR_CRNNNET_H__
#define __OCR_CRNNNET_H__

#include "OcrStruct.h"
#include "onnx/onnxruntime_cxx_api.h"
#include <opencv/cv.hpp>

class CrnnNet {
public:

    ~CrnnNet();

    bool initModel(std::string &pathStr, Ort::Env &env, Ort::SessionOptions &sessionOptions);

    std::vector<TextLine> getTextLines(std::vector<cv::Mat> &partImg, const char *path, const char *imgName);

private:
    bool isOutputDebugImg = false;
    std::unique_ptr<Ort::Session> session;
    std::vector<const char *> inputNames;
    std::vector<const char *> outputNames;

    const float meanValues[3] = {127.5, 127.5, 127.5};
    const float normValues[3] = {1.0 / 127.5, 1.0 / 127.5, 1.0 / 127.5};
    const int dstHeight = 32;
    const int crnnCols = 5531;

    std::vector<std::string> keys;

    TextLine scoreToTextLine(const float *srcData, int h, int w);

    TextLine getTextLine(cv::Mat &src);
};


#endif //__OCR_CRNNNET_H__
