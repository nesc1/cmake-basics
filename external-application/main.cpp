#include <iostream>
#include <string>

#include "mylibA/mylibA_header.h"

int main(int argc, char const *argv[]) {
    std::cout << "Make some math from external application: 1+1=" << doTheMath(1, 1) << "... tada\n";
    std::cout << "\ndone.\n";
    return 0;
}
