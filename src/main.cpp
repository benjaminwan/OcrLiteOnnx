#include "OcrLite.h"
#include "main.h"

#ifdef __JNI__

#include <jni.h>
#include "OcrResultUtils.h"

#endif

#define VERSION "1.3.2.20201030"

void printHelp(FILE *out, const char *argv0) {
    fprintf(out, " ------- Usage -------\n");
    fprintf(out, "%s %s", argv0, usageMsg);
    fprintf(out, " ------- Required Parameters -------\n");
    fprintf(out, "%s", requiredMsg);
    fprintf(out, " ------- Optional Parameters -------\n");
    fprintf(out, "%s", optionalMsg);
    fprintf(out, " ------- Other Parameters -------\n");
    fprintf(out, "%s", otherMsg);
    fprintf(out, " ------- Examples -------\n");
    fprintf(out, example1Msg, argv0);
    fprintf(out, example2Msg, argv0);
}

int main(int argc, char **argv) {
    if (argc <= 1) {
        printHelp(stderr, argv[0]);
        return -1;
    }

    std::string modelsDir, argImgPath, imgPath, imgName;
    modelsDir = "../models";
    argImgPath = "../../test_imgs/1.jpg";
    int numThread = 4;
    int padding = 50;
    int imgResize = 0;
    float boxScoreThresh = 0.6f;
    float boxThresh = 0.3f;
    float minArea = 3.f;
    float unClipRatio = 2.0f;
    bool doAngle = true;
    int flagDoAngle = 1;
    bool mostAngle = true;
    int flagMostAngle = 1;

    int opt;
    int optionIndex = 0;
    while ((opt = getopt_long(argc, argv, "i:d:t:p:s:b:o:m:u:a:A:v?", long_options, &optionIndex)) != -1) {
        //printf("option(-%c)=%s\n", opt, optarg);
        switch (opt) {
            case 'd':
                modelsDir = optarg;
                printf("modelsPath=%s\n", modelsDir.c_str());
                break;
            case 'i':
                argImgPath = std::string(optarg);
                imgPath = argImgPath.substr(0, argImgPath.find_last_of('/') + 1);
                imgName = argImgPath.substr(argImgPath.find_last_of('/') + 1);
                printf("imgPath=%s, imgName=%s\n", imgPath.c_str(), imgName.c_str());
                break;
            case 't':
                numThread = (int) strtol(optarg, NULL, 10);
                printf("numThread=%d\n", numThread);
                break;
            case 'p':
                padding = (int) strtol(optarg, NULL, 10);
                printf("padding=%d\n", padding);
                break;
            case 's':
                imgResize = (int) strtol(optarg, NULL, 10);
                printf("imgResize=%d\n", imgResize);
                break;
            case 'b':
                boxScoreThresh = strtof(optarg, NULL);
                printf("boxScoreThresh=%f\n", boxScoreThresh);
                break;
            case 'o':
                boxThresh = strtof(optarg, NULL);
                printf("boxThresh=%f\n", boxThresh);
                break;
            case 'm':
                minArea = strtof(optarg, NULL);
                printf("minArea=%f\n", minArea);
                break;
            case 'u':
                unClipRatio = strtof(optarg, NULL);
                printf("unClipRatio=%f\n", unClipRatio);
                break;
            case 'a':
                flagDoAngle = (int) strtol(optarg, NULL, 10);
                if (flagDoAngle == 0) {
                    doAngle = false;
                } else {
                    doAngle = true;
                }
                printf("doAngle=%d\n", doAngle);
                break;
            case 'A':
                flagMostAngle = (int) strtol(optarg, NULL, 10);
                if (flagMostAngle == 0) {
                    mostAngle = false;
                } else {
                    mostAngle = true;
                }
                printf("mostAngle=%d\n", mostAngle);
                break;
            case 'v':
                printf("%s\n", VERSION);
                return 0;
            case '?':
                printHelp(stdout, argv[0]);
                return 0;
            default:
                printf("other option %c :%s\n", opt, optarg);
        }
    }

    OcrLite ocrLite(numThread);
    ocrLite.initLogger(
            true,//isOutputConsole
            false,//isOutputPartImg
            false,//isOutputAngleImg
            false,//isOutputDebugImg
            true);//isOutputResultImg

    ocrLite.initResultTxtPath(imgPath.c_str(), imgName.c_str());

    bool ret = ocrLite.initModels(modelsDir.c_str());
    if (!ret) return -1;

    OcrResult result = ocrLite.detect(imgPath.c_str(), imgName.c_str(),
                                      padding, imgResize,
                                      boxScoreThresh, boxThresh, minArea,
                                      unClipRatio, doAngle, mostAngle);
    ocrLite.Logger("%s\n", result.strRes.c_str());

    return 0;
}

#ifdef __JNI__
static OcrLite *ocrLite;

const char *jstringToChar(JNIEnv *env, jstring input) {
    const char *str;
    jboolean isCopy = false;
    str = env->GetStringUTFChars(input, &isCopy);
    if (str == NULL) {
        return NULL;
    }
    env->ReleaseStringUTFChars(input, str);
    return str;
}

extern "C" JNIEXPORT jstring JNICALL
Java_com_benjaminwan_ocrlibrary_OcrEngine_getVersion(JNIEnv *env, jobject thiz) {
    jstring ver = env->NewStringUTF(VERSION);
    return ver;
}

extern "C" JNIEXPORT jboolean JNICALL
Java_com_benjaminwan_ocrlibrary_OcrEngine_init(JNIEnv *env, jobject thiz, jint numThread) {
    ocrLite = new OcrLite(numThread);
    printf("numThread=%d\n", numThread);
    return JNI_TRUE;
}

extern "C" JNIEXPORT void JNICALL
Java_com_benjaminwan_ocrlibrary_OcrEngine_initLogger(JNIEnv *env, jobject thiz, jboolean isConsole,
                                                     jboolean isPartImg, jboolean isAngleImg, jboolean isDebugImg,
                                                     jboolean isResultImg) {
    ocrLite->initLogger(isConsole,//isOutputConsole
                        isPartImg,//isOutputPartImg
                        isAngleImg,//isOutputAngleImg
                        isDebugImg,//isOutputDebugImg
                        isResultImg);//isOutputResultImg
}

extern "C" JNIEXPORT jboolean JNICALL
Java_com_benjaminwan_ocrlibrary_OcrEngine_initModels(JNIEnv *env, jobject thiz, jstring path) {
    const char *models = jstringToChar(env, path);
    printf("models dir=%s\n", models);
    bool ret = ocrLite->initModels(models);
    return ret;
}

extern "C" JNIEXPORT jobject JNICALL
Java_com_benjaminwan_ocrlibrary_OcrEngine_detect(JNIEnv *env, jobject thiz, jstring input,
                                                 jint padding, jint reSize,
                                                 jfloat boxScoreThresh, jfloat boxThresh,
                                                 jfloat minArea, jfloat unClipRatio,
                                                 jboolean doAngle, jboolean mostAngle
) {
    std::string argImgPath, imgPath, imgName;
    const char *inputStr = jstringToChar(env, input);
    argImgPath = std::string(inputStr);
    imgPath = argImgPath.substr(0, argImgPath.find_last_of('/') + 1);
    imgName = argImgPath.substr(argImgPath.find_last_of('/') + 1);
    printf("imgPath=%s, imgName=%s\n", imgPath.c_str(), imgName.c_str());
    ocrLite->initResultTxtPath(imgPath.c_str(), imgName.c_str());
    OcrResult result = ocrLite->detect(imgPath.c_str(), imgName.c_str(),
                                       padding, reSize,
                                       boxScoreThresh, boxThresh, minArea,
                                       unClipRatio, doAngle, mostAngle);

    return OcrResultUtils(env, result).getJObject();
}
#endif

