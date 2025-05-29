#include <stdio.h>
#include <opencv2/opencv.hpp>
using namespace cv;

#define FLOAT_TO_INT(x) ((x)>=0?(int)((x)+0.5):(int)((x)-0.5))

int procesarImagen(uchar* p, int nRows, int nCols, int channels);
double valorRGBlineal (double RGBcomprimido);
double valorYcomprimido (double valorYlineal);


int main (int argc, char** argv) {
	int resultado;
	uchar* p;
	int channels;
	int nRows;
	int nCols;

	if (argc != 2) {
		printf ("Uso:  testopencv <imagen>\n");
		return (-1);
	}
	Mat image;
	image = imread (argv[1], IMREAD_COLOR);
	if (!image.data) {
		printf ("Sin datos de imagen... \n");
		return (-1);
	}
	namedWindow ("Original", WINDOW_AUTOSIZE);
	imshow ("Original", image);

	channels = image.channels();
	nRows = image.rows;
	nCols = image.cols;
	p = image.data;

	printf ("CTRL+C para finalizar\n\n");
	printf ("Filas: %d\n", nRows);
	printf ("Columnas: %d\n", nCols);
	printf ("Canales: %d\n", channels);
	CV_Assert(image.depth() == CV_8U);

	// Procesamiento
	resultado = procesarImagen (p, nRows, nCols, channels);

	namedWindow ("Grayscale", WINDOW_AUTOSIZE);
	imshow ("Grayscale", image);

	waitKey(0);
	return (0);
}
