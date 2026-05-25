#pragma once
#include "maillage.h"
#include <fstream>
#include <sstream>
#include <stdexcept>
#include <algorithm>

// ============================================================
//  Nombre de noeuds par type d'élément GMSH
// ============================================================
int nNoeudsParType(int type) {
    switch (type) {
        case 1:  return 2;   // ligne
        case 2:  return 3;   // T3
        case 3:  return 4;   // Q4
        case 9:  return 6;   // T6
        case 15: return 1;   // point
        default: return -1;  // inconnu
    }
}

// ============================================================
//  Trim d'une string (supprimer espaces/retours chariot)
// ============================================================
std::string trim(const std::string& s) {
    size_t debut = s.find_first_not_of(" \t\r\n");
    if (debut == std::string::npos) return "";
    size_t fin = s.find_last_not_of(" \t\r\n");
    return s.substr(debut, fin - debut + 1);
}

// ============================================================
//  Lecture du fichier .msh (format GMSH 2.2)
// ============================================================
Maillage lireMSH(const std::string& chemin) {
    Maillage m;

    std::ifstream fichier(chemin);
    if (!fichier.is_open()) {
        throw std::runtime_error("Impossible d'ouvrir : " + chemin);
    }

    // Table de correspondance id GMSH (1-based) → indice interne (0-based)
    std::map<int, int> idVersIndice;

    std::string ligne;
    while (std::getline(fichier, ligne)) {
        ligne = trim(ligne);

        // ── $PhysicalNames ────────────────────────────────────
        if (ligne == "$PhysicalNames") {
            std::getline(fichier, ligne);
            int nbGroupes = std::stoi(trim(ligne));

            for (int k = 0; k < nbGroupes; k++) {
                std::getline(fichier, ligne);
                std::istringstream ss(trim(ligne));

                GroupePhysique g;
                std::string nomAvecGuillemets;
                ss >> g.dimension >> g.id >> nomAvecGuillemets;

                // Supprimer les guillemets autour du nom
                g.nom = nomAvecGuillemets;
                g.nom.erase(remove(g.nom.begin(), g.nom.end(), '"'), g.nom.end());

                m.groupes.push_back(g);
                m.idVersNomGroupe[g.id] = g.nom;
            }
        }

        // ── $Nodes ────────────────────────────────────────────
        else if (ligne == "$Nodes") {
            std::getline(fichier, ligne);
            int nbNoeuds = std::stoi(trim(ligne));

            for (int k = 0; k < nbNoeuds; k++) {
                std::getline(fichier, ligne);
                std::istringstream ss(trim(ligne));

                Noeud n;
                int idGmsh;
                double z;
                ss >> idGmsh >> n.x >> n.y >> z;
                n.id = k;  // indice 0-based interne

                idVersIndice[idGmsh] = k;
                m.noeuds.push_back(n);
            }
        }

        // ── $Elements ─────────────────────────────────────────
        else if (ligne == "$Elements") {
            std::getline(fichier, ligne);
            int nbElements = std::stoi(trim(ligne));

            for (int k = 0; k < nbElements; k++) {
                std::getline(fichier, ligne);
                std::istringstream ss(trim(ligne));

                Element e;
                int idGmsh, nbTags;
                ss >> idGmsh >> e.type >> nbTags;

                // Lire les tags (le premier est le groupe physique)
                e.groupe = -1;
                for (int t = 0; t < nbTags; t++) {
                    int tag;
                    ss >> tag;
                    if (t == 0) e.groupe = tag;
                }

                // Lire les indices des noeuds
                int nn = nNoeudsParType(e.type);
                if (nn < 0) continue;  // type inconnu, ignorer

                for (int n = 0; n < nn; n++) {
                    int idNoeudGmsh;
                    ss >> idNoeudGmsh;
                    e.noeuds.push_back(idVersIndice[idNoeudGmsh]);
                }

                e.id = k;
                m.elements.push_back(e);

                // Stocker les triangles séparément
                if (e.type == GMSH_T3 || e.type == GMSH_T6) {
                    m.triangles.push_back(e);
                }
            }
        }
    }

    // Initialiser les conditions aux limites (toutes libres par défaut)
    m.conditions.resize(m.noeuds.size());

    return m;
}

// ============================================================
//  Appliquer les conditions aux limites depuis un fichier config
//
//  Format du fichier config (texte simple) :
//
//  # commentaire
//  ENCASTREMENT_XY   encastrement
//  ENCASTREMENT_X    appui_glissant
//  FORCE_X           force_droite   1000.0
//  FORCE_Y           force_haut     -500.0
//  PRESSION          bord_pression  200.0
// ============================================================
void appliquerConditions(Maillage& m, const std::string& cheminConfig) {
    std::ifstream fichier(cheminConfig);
    if (!fichier.is_open()) {
        throw std::runtime_error("Impossible d'ouvrir config : " + cheminConfig);
    }

    // Table : nom de groupe → liste de noeuds
    std::map<std::string, std::vector<int>> noeudsParGroupe;

    // Construire la table depuis les éléments de bord (lignes)
    for (auto& elem : m.elements) {
        if (elem.type != GMSH_LIGNE) continue;
        if (m.idVersNomGroupe.count(elem.groupe) == 0) continue;

        std::string nom = m.idVersNomGroupe[elem.groupe];
        for (int idx : elem.noeuds) {
            auto& liste = noeudsParGroupe[nom];
            if (std::find(liste.begin(), liste.end(), idx) == liste.end()) {
                liste.push_back(idx);
            }
        }
    }

    // Lire le fichier de config et appliquer
    std::string ligne;
    while (std::getline(fichier, ligne)) {
        ligne = trim(ligne);
        if (ligne.empty() || ligne[0] == '#') continue;

        std::istringstream ss(ligne);
        std::string type, nomGroupe;
        ss >> type >> nomGroupe;

        if (noeudsParGroupe.count(nomGroupe) == 0) {
            std::cerr << "Groupe introuvable : " << nomGroupe << std::endl;
            continue;
        }

        for (int idx : noeudsParGroupe[nomGroupe]) {
            ConditionNoeud& c = m.conditions[idx];

            if (type == "ENCASTREMENT_XY") {
                c.ux_bloque = true;
                c.uy_bloque = true;
            }
            else if (type == "ENCASTREMENT_X") {
                c.ux_bloque = true;
            }
            else if (type == "ENCASTREMENT_Y") {
                c.uy_bloque = true;
            }
            else if (type == "FORCE_X") {
                double val; ss >> val;
                // Répartir équitablement sur les noeuds du groupe
                int n = noeudsParGroupe[nomGroupe].size();
                c.force_x += val / n;
            }
            else if (type == "FORCE_Y") {
                double val; ss >> val;
                int n = noeudsParGroupe[nomGroupe].size();
                c.force_y += val / n;
            }
            else if (type == "PRESSION") {
                // TODO : calculer la pression normale arête par arête
                std::cerr << "PRESSION : non encore implémenté" << std::endl;
            }
        }
    }
//fgsdf
    std::cout << "\n=== CONDITIONS AUX LIMITES ===" << std::endl;
    int nbBloques = 0, nbForces = 0;
    for (auto& c : m.conditions) {
        if (c.ux_bloque || c.uy_bloque) nbBloques++;
        if (c.force_x != 0 || c.force_y != 0) nbForces++;
    }
    std::cout << "Noeuds bloques : " << nbBloques << std::endl;
    std::cout << "Noeuds charges : " << nbForces  << std::endl;
}