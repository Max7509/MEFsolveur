double[][] matriceRigi(Geometrie g){
  double[][] D = matriceComportement(g.E,g.nu,g.a);
  
  ArrayList<Noeud> s = g.maillage.sommets;
  double[][] K = new double[2*s.size()][2*s.size()];
  for(int[] tri : g.maillage.triangles){
    double detJ = abs(s.get(tri[0]).pos.x*(s.get(tri[1]).pos.y-s.get(tri[2]).pos.y)
                    +s.get(tri[1]).pos.x*(s.get(tri[2]).pos.y-s.get(tri[0]).pos.y)
                    +s.get(tri[2]).pos.x*(s.get(tri[0]).pos.y-s.get(tri[1]).pos.y));
    double[][] B = matriceDif(s,tri, detJ);
    double[][] Ke = MatriceElem(g.e, D, B, detJ);
    for(int i=0;i<tri.length;i++){
      for(int j=0;j<tri.length;j++){
        K[2*tri[i]  ][2*tri[j]  ] += Ke[2*i  ][2*j  ];
        K[2*tri[i]+1][2*tri[j]  ] += Ke[2*i+1][2*j  ];
        K[2*tri[i]  ][2*tri[j]+1] += Ke[2*i  ][2*j+1];
        K[2*tri[i]+1][2*tri[j]+1] += Ke[2*i+1][2*j+1];
      }
    }
  }
  return K;
}

double[] forceConnues(Geometrie g){
  ArrayList<Noeud> s = g.maillage.sommets;
  double[] Fc = new double[2*s.size()];
  for(int i=0;i<s.size();i++){
    Fc[2*i]+=s.get(i).force.x;
    Fc[2*i+1]+=s.get(i).force.y;
  }
  return Fc;
}

void resolution(Geometrie g, double[][] K, double[] F){
  for (Noeud n : g.maillage.sommets) {
    n.du.x = 0;
    n.du.y = 0;
  }
  ArrayList<Integer> libre  = new ArrayList<>();
  ArrayList<Integer> fixe   = new ArrayList<>();
  for (int i = 0; i < F.length/2; i++) {
    if (g.maillage.sommets.get(i).ux) fixe.add(2*i);
    else                              libre.add(2*i);
    if (g.maillage.sommets.get(i).uy) fixe.add(2*i+1);
    else                              libre.add(2*i+1);
  }
  
  int nl = libre.size();
  double[][] Kll = new double[nl][nl];
  double[]   Fl  = new double[nl];
  for (int i = 0; i < nl; i++) {
    Fl[i] = F[libre.get(i)];
    for (int j = 0; j < nl; j++) {
        Kll[i][j] = K[libre.get(i)][libre.get(j)];
    }
  }
  
  double[] Ul = resoudre(Kll, Fl);
  
  if(Ul == null){
    println("Système irrésoluble, peut être pas statique ?");
    reso= false;
    sig = false;
    return;
  }
  int p = 0;
  for (int i = 0; i < F.length/2; i++) {
    if (!g.maillage.sommets.get(i).ux){
      g.maillage.sommets.get(i).du.x = (float)Ul[p];
      p++;
    }
    if (!g.maillage.sommets.get(i).uy){
      g.maillage.sommets.get(i).du.y = (float)Ul[p];
      p++;
    }
  }
  
  int nf = fixe.size();
  double[] reactions = new double[nf];
  for (int i = 0; i < nf; i++) {
    double r = 0;
    for (int j = 0; j < nl; j++) {
        r += K[fixe.get(i)][libre.get(j)] * Ul[j];
    }
    reactions[i] = r - F[fixe.get(i)];
  }
  println("Calcul fini");
  reso = true;
}

double[] resoudre(double[][] K, double[] F){
  double[] U = new double[F.length];
  double[][] K_inv = inverseMatrice(K);
  if(K_inv == null){
    println("Matrice non réversible.");
    return null;
  }else{
    for (int i = 0; i < F.length; i++) {
      U[i] = 0;
      for (int j = 0; j < F.length; j++) {
          U[i] += K_inv[i][j] * F[j];
      }
    }
  }
 return U;
}

double[][] inverseMatrice(double[][] A) {
  int n = A.length;
  // Matrice matriceAugmentée [A | I]
  double[][] matriceAug = new double[n][2*n];
  double maxA = 0;
  for(int i = 0; i < n; i++){
    for(int j = 0; j < n; j++){
      matriceAug[i][j] = A[i][j];
      if(abs((float)A[i][j]) > maxA) maxA = abs((float)A[i][j]);
    }
    for(int j = 0; j < n; j++) matriceAug[i][n + j] = (i == j) ? 1.0 : 0.0;
  }

  double seuil = 1e-12 * maxA;

  for(int col = 0; col < n; col++){
    // 1) Chercher le pivot
    int colPivot = col;
    double max = abs((float)matriceAug[col][col]);
    for(int row = col + 1; row < n; row++){
      double v = abs((float)matriceAug[row][col]);
      if(v > max){
        max = v;
        colPivot = row;
      }
    }
    // 2) Vérifier si il y a des singularités
    if (max < seuil) {
      println("Matrice singulière (pivot ~ 0) à col = " + col);
      return null;
    }
    // 3) Echanger colPivot et col
    if(colPivot != col){
      double[] temp = matriceAug[colPivot];
      matriceAug[colPivot] = matriceAug[col];
      matriceAug[col] = temp;
    }
    // 4) Normaliser la ligne pivot
    double pivot = matriceAug[col][col];
    for(int j = 0; j < 2*n; j++) matriceAug[col][j] /= pivot;
    // 5) Éliminer les autres lignes
    for(int row = 0; row < n; row++){
      if(row == col) continue;
      double facteur = matriceAug[row][col];
      if(abs((float)facteur) < seuil) continue;
      for(int j = 0; j < 2*n; j++){
        matriceAug[row][j] -= facteur * matriceAug[col][j];
      }
    }
  }
  // On retourne l'inverse
  double[][] inv = new double[n][n];
  for (int i = 0; i < n; i++) {
    for (int j = 0; j < n; j++) inv[i][j] = matriceAug[i][n + j];
  }
  return inv;
}
