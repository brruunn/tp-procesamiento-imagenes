cmake_minimum_required(VERSION 3.28)
project(ImageProcessor LANGUAGES C CXX ASM_NASM)

# configuración para NASM
enable_language(ASM_NASM)
set(CMAKE_ASM_NASM_FLAGS "-g -F dwarf")

# fuentes
set(SOURCES
    src/display_image.cpp
    src/procesarImagen.asm
    src/valorRGBLineal.asm
    src/valorYComprimido.asm
)

# buscar OpenCV
find_package(OpenCV REQUIRED)
include_directories(
    include
    ${OpenCV_INCLUDE_DIRS}
)

# ejecutable principal
add_executable(ImageProcessor ${SOURCES})

# enlazar librerías
target_link_libraries(ImageProcessor
    PRIVATE
    ${OpenCV_LIBS}
    m  # para math.h (pow)
)
