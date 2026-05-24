void calculSigma(Geometrie g){
  g.maillage.vmMax = 0;
  g.maillage.vmMin = Float.MAX_VALUE;
  for (int i = 0; i < g.maillage.sigma.length; i++) g.maillage.sigma[i] = 0;
  double[][] D = matriceComportement(g.E,g.nu,g.a);
  ArrayList<Noeud> s = g.maillage.sommets;
  int k = 0;
  for(int[] tri : g.maillage.triangles){
    double detJ = abs(s.get(tri[0]).pos.x*(s.get(tri[1]).pos.y-s.get(tri[2]).pos.y)
                    +s.get(tri[1]).pos.x*(s.get(tri[2]).pos.y-s.get(tri[0]).pos.y)
                    +s.get(tri[2]).pos.x*(s.get(tri[0]).pos.y-s.get(tri[1]).pos.y));
    double[][] B = matriceDif(s,tri, detJ);
    double[] epsilon = new double[3];
    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
            epsilon[i] += B[i][2*j] * g.maillage.sommets.get(tri[j]).du.x;
            epsilon[i] += B[i][2*j+1] * g.maillage.sommets.get(tri[j]).du.y;
        }
    }
    double[] sigma = new double[3];
    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
            sigma[i] += D[i][j] * epsilon[j];
        }
    }    
    float sxx = (float)sigma[0];
    float syy = (float)sigma[1];
    float sxy = (float)sigma[2];
    double vm = sqrt(sxx*sxx - sxx*syy + syy*syy + 3*sxy*sxy);
    g.maillage.sigma[k] = (float)vm;
    if(vm> g.maillage.vmMax) g.maillage.vmMax = (float)vm;
    if(vm< g.maillage.vmMin) g.maillage.vmMin = (float)vm;
    k++;
  }
}

color couleurContrainte(float t) {
    // t entre 0 (bleu) et 1 (rouge), vert au milieu
    if (t < 0.5) {
        float u = t * 2;
        return color(0, u*255, (1-u)*255);      // bleu → vert
    } else {
        float u = (t - 0.5) * 2;
        return color(u*255, (1-u)*255, 0);      // vert → rouge
    }
}

void afficherLegende(float vmin, float vmax) {
    int hLeg = 200, wLeg = 20;
    int xLeg = width - 60, yLeg = height/2 - hLeg/2;

    // Barre de couleur
    for (int i = 0; i < hLeg; i++) {
        float t = 1.0 - (float)i / hLeg;
        stroke(couleurContrainte(t));
        line(xLeg, yLeg + i, xLeg + wLeg, yLeg + i);
    }

    // Valeurs min/max
    fill(0); noStroke();
    textAlign(LEFT);
    textSize(11);
    text(nf(vmax, 1, 2), xLeg + wLeg + 4, yLeg + 5);
    text(nf(vmin, 1, 2), xLeg + wLeg + 4, yLeg + hLeg);
}
