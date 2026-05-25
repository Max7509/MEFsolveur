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
 
    try {
        // 1. Lire le maillage
        std::cout << "Lecture de : " << cheminMSH << std::endl;
        Maillage m = lireMSH(cheminMSH);
        m.afficher();
 
        // 2. Appliquer les conditions aux limites
        std::cout << "\nLecture de : " << cheminConfig << std::endl;
        appliquerConditions(m, cheminConfig);
 
        // 3. Afficher un extrait des données MEF
        std::cout << "\n=== EXTRAIT NOEUDS ===" << std::endl;
        int afficher = std::min((int)m.noeuds.size(), 5);
        for (int i = 0; i < afficher; i++) {
            auto& n = m.noeuds[i];
            auto& c = m.conditions[i];
            std::cout << "Noeud " << i
                      << "  x=" << n.x << "  y=" << n.y
                      << "  ux_bloque=" << c.ux_bloque
                      << "  uy_bloque=" << c.uy_bloque
                      << "  fx=" << c.force_x
                      << "  fy=" << c.force_y
                      << std::endl;
        }
 
        std::cout << "\n=== EXTRAIT TRIANGLES ===" << std::endl;
        int afficherTri = std::min((int)m.triangles.size(), 5);
        for (int i = 0; i < afficherTri; i++) {
            auto& t = m.triangles[i];
            std::cout << "Triangle " << i
                      << "  noeuds=["
                      << t.noeuds[0] << ", "
                      << t.noeuds[1] << ", "
                      << t.noeuds[2] << "]"
                      << "  groupe=" << m.idVersNomGroupe[t.groupe]
                      << std::endl;
        }
 
    } catch (const std::exception& e) {
        std::cerr << "Erreur : " << e.what() << std::endl;
        return 1;
    }
 
    std::cout << "\nLecture terminee, pret pour la MEF." << std::endl;
    return 0;
}