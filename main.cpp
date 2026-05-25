#include <iostream>
#include "maillage.h"
#include "lecteurMSH.h"
 
int main(int argc, char* argv[]) {
    if (argc < 3) {
        std::cout << "Attendu : programme <fichier.msh> <conditions.txt>" << std::endl;
        return 1;
    }
    std::string cheminMSH    = argv[1];
    std::string cheminConfig = argv[2];
 
    Maillage m = lectureInput(cheminMSH, cheminConfig);
    
 
    std::cout << "\nLecture terminee, pret pour la MEF." << std::endl;
    return 0;
}