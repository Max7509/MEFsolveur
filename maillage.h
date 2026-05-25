#pragma once
#include <vector>
#include <string>
#include <map>
#include <iostream>

// ============================================================
//  Structures de données pour la MEF
// ============================================================

struct Noeud {
    int    id;        // indice global (0-based)
    double x, y;     // coordonnées 2D (z ignoré)
};

struct Element {
    int              id;       // indice global (0-based)
    int              type;     // type GMSH (1=ligne, 2=T3, 3=Q4...)
    int              groupe;   // indice du groupe physique
    std::vector<int> noeuds;   // indices 0-based des noeuds
};

struct GroupePhysique {
    int         id;
    int         dimension;   // 1=courbe, 2=surface
    std::string nom;
};

// Conditions aux limites sur un noeud
struct ConditionNoeud {
    bool  ux_bloque = false;
    bool  uy_bloque = false;
    double force_x  = 0.0;
    double force_y  = 0.0;
};

struct Maillage {
    std::vector<Noeud>          noeuds;
    std::vector<Element>        elements;     // tous les éléments (lignes + surfaces)
    std::vector<GroupePhysique> groupes;
    std::map<int, std::string>  idVersNomGroupe;

    // Conditions aux limites par noeud (remplies par appliquerConditions)
    std::vector<ConditionNoeud> conditions;

    // Afficher un résumé
    void afficher() const {
        std::cout << "===== MAILLAGE =====" << std::endl;
        std::cout << "Noeuds            : "       << noeuds.size()    << std::endl;
        std::cout << "Type d'elements   : " << typeElem(elements[elements.size()-1].type) << std::endl;
        std::cout << "Elements          : "       << elements.size()  << std::endl;
        std::cout << "Groupes physiques :" << std::endl;
        for (auto& g : groupes) {
            std::cout << "    [" << g.id << "] dim = " << g.dimension
                      << " nom : \"" << g.nom << "\"" << std::endl;
        }
    }

    std::string typeElem(int type) const {
        switch (type) {
            case 1:  return "ligne";   // ligne
            case 2:  return "T3";      // T3
            case 3:  return "Q4";      // Q4
            case 9:  return "T6";      // T6
            case 15: return "point";   // point
            default: return "inconnu";  // inconnu
        }
    }
};

// Types d'éléments GMSH
constexpr int GMSH_LIGNE = 1;   // 2 noeuds
constexpr int GMSH_T3    = 2;   // triangle 3 noeuds
constexpr int GMSH_Q4    = 3;   // quadrangle 4 noeuds
constexpr int GMSH_T6    = 9;   // triangle 6 noeuds