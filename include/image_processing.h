#ifndef IMAGE_PROCESSING_H
#define IMAGE_PROCESSING_H

#ifdef __cplusplus
extern "C" {
#endif

void procesarImagen(unsigned char* p, int nRows, int nCols, int channels);
double valorRGBlineal(double RGBcomprimido);
double valorYcomprimido(double valorYlineal);

#ifdef __cplusplus
}
#endif

#endif