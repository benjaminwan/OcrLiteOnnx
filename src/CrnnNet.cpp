#include "CrnnNet.h"
#include "OcrUtils.h"
#include <fstream>
#include <numeric>

CrnnNet::~CrnnNet() {
    session.release();
}

bool CrnnNet::initModel(std::string &pathStr, Ort::Env &env, Ort::SessionOptions &sessionOptions) {
#ifdef _WIN32
    std::wstring crnnPath = strToWstr(pathStr + "/crnn_lite_lstm.onnx");
    session = makeUnique<Ort::Session>(env, crnnPath.c_str(), sessionOptions);
#else
    session = makeUnique<Ort::Session>(env, (pathStr + "/crnn_lite_lstm.onnx").c_str(), sessionOptions);
#endif
    inputNames = getInputNames(session);
    outputNames = getOutputNames(session);

    //load keys
    std::ifstream in((pathStr + "/keys.txt").c_str());
    std::string line;
    int keysSize = 0;
    if (in) {
        while (getline(in, line)) {// line中不包括每行的换行符
            keys.push_back(line);
        }
        keysSize = keys.size();
    } else {
        printf("The keys.txt file was not found\n");
        return false;
    }

    printf("keys size(%d)\n", keysSize);
    if (keysSize != 5531) return false;

    return true;
}

TextLine CrnnNet::scoreToTextLine(const float *srcData, int h, int w) {
    std::string strRes;
    int lastIndex = 0;
    int keySize = keys.size();
    std::vector<float> scores;
    for (int i = 0; i < h; i++) {
        int maxIndex = 0;
        float maxValue = -1000.f;
        //do softmax
        std::vector<float> exps(w);
        for (int j = 0; j < w; j++) {
            float expSingle = exp(srcData[i * w + j]);
            exps.at(j) = expSingle;
        }
        float partition = accumulate(exps.begin(), exps.end(), 0.0);//row sum
        for (int j = 0; j < w; j++) {
            float softmax = exps[j] / partition;
            if (softmax > maxValue) {
                maxValue = softmax;
                maxIndex = j;
            }
        }

        //no softmax
        /*for (int j = 0; j < w; j++) {
            if (srcData[i * w + j] > maxValue) {
                maxValue = srcData[i * w + j];
                maxIndex = j;
            }
        }*/
        if (maxIndex > 0 && maxIndex < keySize && (!(i > 0 && maxIndex == lastIndex))) {
            scores.emplace_back(maxValue);
            strRes.append(keys[maxIndex - 1]);
        }
        lastIndex = maxIndex;
    }
    return {strRes, scores};
}

TextLine CrnnNet::getTextLine(cv::Mat &src) {
    float scale = (float) dstHeight / (float) src.rows;
    int dstWidth = int((float) src.cols * scale);

    cv::Mat srcResize;
    resize(src, srcResize, cv::Size(dstWidth, dstHeight));

    std::vector<float> inputTensorValues = substractMeanNormalize(srcResize, meanValues, normValues);

    std::array<int64_t, 4> inputShape{1, srcResize.channels(), srcResize.rows, srcResize.cols};

    auto memoryInfo = Ort::MemoryInfo::CreateCpu(OrtArenaAllocator, OrtMemTypeDefault);


    Ort::Value inputTensor = Ort::Value::CreateTensor<float>(memoryInfo, inputTensorValues.data(),
                                                   inputTensorValues.size(), inputShape.data(),
                                                   inputShape.size());
    assert(inputTensor.IsTensor());

    auto outputTensor = session->Run(Ort::RunOptions{nullptr}, inputNames.data(), &inputTensor,
                                     inputNames.size(),
                                     outputNames.data(), outputNames.size());

    assert(outputTensor.size() == 1 && outputTensor.front().IsTensor());

    size_t count = outputTensor.front().GetTensorTypeAndShapeInfo().GetElementCount();
    size_t rows = count / crnnCols;
    float *floatArray = outputTensor.front().GetTensorMutableData<float>();

    cv::Mat score(rows, crnnCols, CV_32FC1);
    memcpy(score.data, floatArray, rows * crnnCols * sizeof(float));

    return scoreToTextLine((float *) score.data, rows, crnnCols);
}

std::vector<TextLine> CrnnNet::getTextLines(std::vector<cv::Mat> &partImg, const char *path, const char *imgName) {
    int size = partImg.size();
    std::vector<TextLine> textLines(size);
#ifdef __OPENMP__
#pragma omp parallel for
#endif
    for (int i = 0; i < size; ++i) {
        //OutPut DebugImg
        if (isOutputDebugImg) {
            std::string debugImgFile = getDebugImgFilePath(path, imgName, i, "-debug-");
            saveImg(partImg[i], debugImgFile.c_str());
        }

        //getTextLine
        double startCrnnTime = getCurrentTime();
        TextLine textLine = getTextLine(partImg[i]);
        double endCrnnTime = getCurrentTime();
        textLine.time = endCrnnTime - startCrnnTime;

        //Log textLine
        //Logger("textLine[%d](%s)", i, textLine.text.c_str());
        textLines[i] = textLine;

        /*std::ostringstream txtScores;
        for (int s = 0; s < textLine.charScores.size(); ++s) {
            if (s == 0) {
                txtScores << textLine.charScores[s];
            } else {
                txtScores << " ," << textLine.charScores[s];
            }
        }*/
        //Logger("textScores[%d]{%s}\n", i, string(txtScores.str()).c_str());
        //Logger("crnnTime[%d](%fms)\n", i, textLine.time);
    }
    return textLines;
}