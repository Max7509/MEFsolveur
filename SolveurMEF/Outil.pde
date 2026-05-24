// L'objet de type Outil sert à proposer des outils pour l'élaboration du treillis.
// Ces objets sont affichés en haut de la fenêtre dans le menu

class Outil { 
  // Position de l'outil
  PVector pos = new PVector(0,0);
  // Type de l'outil
  char type;
  
  Outil (char type_) {  
    // Le constructeur de l'outil lui assigne un type représenté par un simple charactère
    type = type_;
  }
  
  void afficher(PVector pos_) { 
    // Afficher un cercle avec le type de l'outil écrit au centre
    pos = pos_;
    float rayon = pos.y;
    circle(pos.x, pos.y, rayon);
    fill(0);
    textSize(20);
    textAlign(CENTER, CENTER);
    text(type, pos.x, pos.y);
    // Surligner l'outil sur laquelle se trouve la souris
    if(dist(mouseX, mouseY, pos.x, pos.y) < rayon/2){
      fill(100,100);
      circle(pos.x, pos.y, rayon);
    }
    fill(255);
  }  
}

void ajoutForceNodale(){
  if(construTemp){
    // Verifier que le curseur est sur un noeud
    for(Noeud n : geom.maillage.sommets){
      if(dist(mouseX, mouseY, n.pos.x, n.pos.y) < selectNoeud/2){
        // Créer une force sur ce noeud
        noeudTemp = n;
        construTemp = false;
      }
    }
  }else{
    noeudTemp.force = new PVector(mouseX - noeudTemp.pos.x, mouseY - noeudTemp.pos.y);
    construTemp = true;
  }
}void ajoutPressionNodale(){
  for(Noeud n : geom.maillage.sommets){
    if(dist(mouseX, mouseY, n.pos.x, n.pos.y) < selectNoeud){
      n.force = new PVector(20,5);
    }
  }
}

void supForceNodale(){
  // Verifier que le curseur est sur un noeud
  for(Noeud n : geom.maillage.sommets){
    if(dist(mouseX, mouseY, n.pos.x, n.pos.y) < selectNoeud){
      // Supprimer la force sur ce noeud
      n.force = new PVector(0, 0);
    }
  }
}

void changeAttache(){
  // Verifier que le curseur est sur un noeud
  for(Noeud n : geom.maillage.sommets){
    if(dist(mouseX, mouseY, n.pos.x, n.pos.y) < selectNoeud){
      // Changer le type d'attache
      if(!n.ux && !n.uy){
        n.ux = false;
        n.uy = true;
      } else if(!n.ux && n.uy){
        n.ux=true;
        n.uy=false;
      }else if(n.ux && !n.uy){
        n.ux=true;
        n.uy=true;
      }else if(n.ux && n.uy){
        n.ux=false;
        n.uy=false;
      }
    }
  }
}

void mousePressed(){
  if(mouseY < 2*outils.get(0).pos.y){
    // Si le curseur est préssé dans la zone menu:
    for(Outil o : outils){
      if(dist(mouseX, mouseY, o.pos.x, o.pos.y) < o.pos.y/2){
        typeOutil = o.type;
        switch(typeOutil){
          case 'N': // Cas neutre
            break;
          case 'a': // Cas suppression de sommets
            if(!(geom.maillage == null)){
              geom.maillage = null;
            }
            if(!(geom.contour == null) && geom.contour.size() >0){
              geom.contour.remove(geom.contour.size()-1);
            }
            break;
          case 'O': // Cas suppression du contour
            geom.contour= new ArrayList<PVector>();
            geom.maillage=null;
            break;
          case 'M': // Cas Maillage
            if(!(geom.contour == null) && geom.contour.size() >2){
              geom.maillage(nMaille);
              sig = false;
              reso=false;
            } else println("Rien à Mailler");
            break;
          case 'f': // Cas suppression force nodale
            if(!(geom.maillage == null)){
              supForceNodale();
            } else println("Pas de maillage");
            break;
          case 'S': // Cas calcul sigma
            if(sig){
              sig = false;
              break;
            }
            if(!(geom.maillage == null)){
              calculSigma(geom);
              sig = true;
            } else println("Pas de résolution");
            break;
          case 'E': // Cas fin de programme
            exit();
            break;
        }
      }
    }
  }
  else{
    // Sinon, selon le mode du curseur:
    switch(typeOutil){
      case 'N': // Cas neutre
        break;
      case 'A': // Cas ajout de sommets
        if(!(geom.maillage == null)){
          geom.maillage = null;
          reso = false;
          sig = false;
        }
        geom.contour.add(new PVector(mouseX, mouseY));
        break;
      case 'F': // Cas ajout force nodale
        if(!(geom.maillage == null)){
          ajoutForceNodale();
        } else println("Pas de maillage");
        break;
      case 'f': // Cas suppression force nodale
        if(!(geom.maillage == null)){
          supForceNodale();
        } else println("Pas de maillage");
        break;
      case 'C': // Cas condition limite
        if(!(geom.maillage == null)){
          changeAttache();
        } else println("Pas de maillage");
        break;
    }
  }
}
void mouseDragged(){
  if(mouseY > 2*outils.get(0).pos.y){
    switch(typeOutil){
      case 'P': // Cas ajout pression nodale
        if(!(geom.maillage == null)){
          ajoutPressionNodale();
        } else println("Pas de maillage");
        break;
      case 'f': // Cas suppression force nodale
        if(!(geom.maillage == null)){
          supForceNodale();
        } else println("Pas de maillage");
        break;
    }
  }
}

void keyPressed(){
  switch(keyCode){
    case ' ':
      if(!(geom.maillage == null) && geom.contour.size() >2){
        double[][] K = matriceRigi(geom);
        double[] F = forceConnues(geom);
        resolution(geom, K, F);
        sig = false;
        coefDefo = 1;
      } else println("Pas de maillage");
      break;
    case UP:
      coefDefo *=1.2;
      break;
    case DOWN:
      coefDefo /=1.2;
      break;
    case '0':
      coefDefo =1;
      break;
    case RIGHT:
      nMaille ++;
      break;
    case LEFT:
      nMaille --;
      break;
  }
}
