#include "CrnnNet.h"
#include "OcrUtils.h"
#include <fstream>
#include <numeric>

CrnnNet::CrnnNet() {}

CrnnNet::~CrnnNet() {
    delete session;
    free(inputName);
    free(outputName);
}

void CrnnNet::setNumThread(int numOfThread) {
    numThread = numOfThread;
    //===session options===
    // Sets the number of threads used to parallelize the execution within nodes
    // A value of 0 means ORT will pick a default
    //sessionOptions.SetIntraOpNumThreads(numThread);
    //set OMP_NUM_THREADS=16

    // Sets the number of threads used to parallelize the execution of the graph (across nodes)
    // If sequential execution is enabled this value is ignored
    // A value of 0 means ORT will pick a default
    sessionOptions.SetInterOpNumThreads(numThread);

    // Sets graph optimization level
    // ORT_DISABLE_ALL -> To disable all optimizations
    // ORT_ENABLE_BASIC -> To enable basic optimizations (Such as redundant node removals)
    // ORT_ENABLE_EXTENDED -> To enable extended optimizations (Includes level 1 + more complex optimizations like node fusions)
    // ORT_ENABLE_ALL -> To Enable All possible opitmizations
    sessionOptions.SetGraphOptimizationLevel(GraphOptimizationLevel::ORT_ENABLE_EXTENDED);
}

void CrnnNet::initModel(const std::string &pathStr, const std::string &keysPath) {
#ifdef _WIN32
    std::wstring crnnPath = strToWstr(pathStr);
    session = new Ort::Session(env, crnnPath.c_str(), sessionOptions);
#else
    session = new Ort::Session(env, pathStr.c_str(), sessionOptions);
#endif
    getInputName(session, inputName);
    getOutputName(session, outputName);

    //load keys
    std::ifstream in(keysPath.c_str());
    std::string line;
    if (in) {
        while (getline(in, line)) {// line中不包括每行的换行符
            keys.push_back(line);
        }
    } else {
        printf("The keys.txt file was not found\n");
        return;
    }
    if (keys.size() != 5531) {
        fprintf(stderr, "missing keys\n");
    }
    printf("total keys size(%lu)\n", keys.size());

}

template<class ForwardIterator>
inline static size_t argmax(ForwardIterator first, ForwardIterator last) {
    return std::distance(first, std::max_element(first, last));
}

TextLine CrnnNet::scoreToTextLine(const std::vector<float> &outputData, int h, int w) {
    int keySize = keys.size();
    std::string strRes;
    std::vector<float> scores;
    int lastIndex = 0;
    int maxIndex;
    float maxValue;

    for (int i = 0; i < h; i++) {
        maxIndex = 0;
        maxValue = -1000.f;
        //do softmax
        std::vector<float> exps(w);
        for (int j = 0; j < w; j++) {
            float expSingle = exp(outputData[i * w + j]);
            exps.at(j) = expSingle;
        }
        float partition = accumulate(exps.begin(), exps.end(), 0.0);//row sum
        maxIndex = int(argmax(exps.begin(), exps.end()));
        maxValue = float(*std::max_element(exps.begin(), exps.end())) / partition;
        if (maxIndex > 0 && maxIndex < keySize && (!(i > 0 && maxIndex == lastIndex))) {
            scores.emplace_back(maxValue);
            strRes.append(keys[maxIndex - 1]);
        }
        lastIndex = maxIndex;
    }
    return {strRes, scores};
}

TextLine CrnnNet::getTextLine(const cv::Mat &src) {
    float scale = (float) dstHeight / (float) src.rows;
    int dstWidth = int((float) src.cols * scale);

    cv::Mat srcResize;
    resize(src, srcResize, cv::Size(dstWidth, dstHeight));

    std::vector<float> inputTensorValues = substractMeanNormalize(srcResize, meanValues, normValues);

    std::array<int64_t, 4> inputShape{1, srcResize.channels(), srcResize.rows, srcResize.cols};

    auto memoryInfo = Ort::MemoryInfo::CreateCpu(OrtDeviceAllocator, OrtMemTypeCPU);

    Ort::Value inputTensor = Ort::Value::CreateTensor<float>(memoryInfo, inputTensorValues.data(),
                                                             inputTensorValues.size(), inputShape.data(),
                                                             inputShape.size());
    assert(inputTensor.IsTensor());

    auto outputTensor = session->Run(Ort::RunOptions{nullptr}, &inputName, &inputTensor, 1, &outputName, 1);

    assert(outputTensor.size() == 1 && outputTensor.front().IsTensor());

    std::vector<int64_t> outputShape = outputTensor[0].GetTensorTypeAndShapeInfo().GetShape();

    int64_t outputCount = std::accumulate(outputShape.begin(), outputShape.end(), 1,
                                          std::multiplies<int64_t>());

    float *floatArray = outputTensor.front().GetTensorMutableData<float>();
    std::vector<float> outputData(floatArray, floatArray + outputCount);
    return scoreToTextLine(outputData, outputShape[0], outputShape[2]);
}

std::vector<TextLine> CrnnNet::getTextLines(std::vector<cv::Mat> &partImg, const char *path, const char *imgName) {
    int size = partImg.size();
    std::vector<TextLine> textLines(size);
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
        textLines[i] = textLine;
    }
    return textLines;
}