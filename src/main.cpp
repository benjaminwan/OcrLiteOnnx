#include "OcrLite.h"

int main(int argc, char **argv) {
    if (argc <= 1) {
        fprintf(stderr,
                "Usage: %s image/path models/dir numThread(option) padding(option) imgResize(option) boxScoreThresh(option) boxThresh(option) minArea(option) unClipRatio(option)\n",
                argv[0]);
        fprintf(stderr, "Example: %s ../test/1.jpg ../models\n", argv[0]);
        fprintf(stderr, "Example: %s ../test/1.jpg ../models 4 50 0 0.6 0.3 3 2.0\n", argv[0]);
    } else {
        std::string argImgPath, imgPath, imgName, modelsDir;
        argImgPath = "../test/1.jpg";
        modelsDir = "../models";
        int numThread = 4;
        int padding = 50;
        int imgResize = 0;
        float boxScoreThresh = 0.6f;
        float boxThresh = 0.3f;
        float minArea = 3.f;
        float unClipRatio = 2.0f;

        for (int i = 1; i < argc; ++i) {
            printf("argv[%d]=%s, ", i, argv[i]);
            switch (i) {
                case 1:
                    argImgPath = std::string(argv[i]);
                    imgPath = argImgPath.substr(0, argImgPath.find_last_of('/') + 1);
                    imgName = argImgPath.substr(argImgPath.find_last_of('/') + 1);
                    printf("imgPath=%s, imgName=%s\n", imgPath.c_str(), imgName.c_str());
                    break;
                case 2:
                    modelsDir = argv[i];
                    printf("modelsPath=%s\n", modelsDir.c_str());
                    break;
                case 3:
                    numThread = (int) strtol(argv[i], NULL, 10);
                    printf("numThread=%d\n", numThread);
                    break;
                case 4:
                    padding = (int) strtol(argv[i], NULL, 10);
                    printf("padding=%d\n", padding);
                    break;
                case 5:
                    imgResize = (int) strtol(argv[i], NULL, 10);
                    printf("imgResize=%d\n", imgResize);
                    break;
                case 6:
                    boxScoreThresh = strtof(argv[i], NULL);
                    printf("boxScoreThresh=%f\n", boxScoreThresh);
                    break;
                case 7:
                    boxThresh = strtof(argv[i], NULL);
                    printf("boxThresh=%f\n", boxThresh);
                    break;
                case 8:
                    minArea = strtof(argv[i], NULL);
                    printf("minArea=%f\n", minArea);
                    break;
                case 9:
                    unClipRatio = strtof(argv[i], NULL);
                    printf("scaleWidth=%f\n", unClipRatio);
                    break;
            }
        }

        OcrLite ocrLite(numThread);
        ocrLite.initLogger(imgPath.c_str(), imgName.c_str(),
                           true,//isOutputConsole
                           false,//isOutputPartImg
                           false,//isOutputAngleImg
                           false,//isOutputDebugImg
                           true,//isOutputResultTxt
                           true);//isOutputResultImg
        bool ret = ocrLite.initModels(modelsDir.c_str());
        if (!ret) return -1;

        OcrResult result = ocrLite.detect(imgPath.c_str(), imgName.c_str(),
                                          padding, imgResize,
                                          boxScoreThresh, boxThresh, minArea,
                                          unClipRatio);
        ocrLite.Logger("%s\n", result.strRes.c_str());
    }

    return 0;
}
