/*
Projet Solveur MEF
Commencé le 22/04/2026
Ce programme calcul les déformations d'une surface élastique
*/

ArrayList<Outil> outils = new ArrayList<Outil>();
char typeOutil; // Permet de determiner le mode du curseur
boolean construTemp = true, reso = false, sig = false;
Noeud noeudTemp = new Noeud(0,0);;

int nMaille = 3;
double selectNoeud;
double E=100000, nu=0.5, a=0.99,e=1;
float coefDefo = 1;
Geometrie geom = new Geometrie(E,nu,e,a);

void setup() {
  //fullScreen();
  size(500,500);
  
  outils.add(new Outil('N')); // Neutre
  outils.add(new Outil('A')); // Ajout de sommets
  outils.add(new Outil('a')); // Suppression de sommets
  outils.add(new Outil('O')); // Suppression geometrie
  outils.add(new Outil('M')); // Maillage
  outils.add(new Outil('F')); // Ajout force nodale
  outils.add(new Outil('P')); // Ajout pression nodale
  outils.add(new Outil('f')); // Suppression force nodale
  outils.add(new Outil('C')); // Condition limite
  outils.add(new Outil('S')); // Calcul Sigma
  outils.add(new Outil('E')); // Fin programme
  typeOutil = outils.get(0).type;
}

void draw() {
  background(255);
  // Menu
  fill(200);
  noStroke();
  rect(0 ,0 ,width , 2*outils.get(0).pos.y);
  fill(255);
  stroke(0);
  for(int i = 0; i < outils.size(); i++){
    float xOutil = map(i, -1, outils.size(), 0, width);
    int yOutil = 30;
    outils.get(i).afficher(new PVector(xOutil, yOutil));
  }
  
  if(geom.maillage == null){
    geom.montrer(255);
    fill(0);
    textAlign(LEFT);
    text("Nombre de maille = "+nMaille, outils.get(0).pos.y, 3*outils.get(0).pos.y);
  }else{
    geom.maillage.montrer();
    geom.montrer(100);
  }
}
