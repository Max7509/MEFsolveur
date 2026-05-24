// Contruction des matrices élémentaires
double[][] MatriceElem(double e, double[][] D, double[][] B, double detJ){
  double[][] DB   = matMul(D,B);
  double[][] Bt   = matTrans(B);
  double[][] BtDB = matMul(Bt,DB);
  double[][] Ke = matMulScal(BtDB, e*detJ/2);
  return Ke;
}

// Construction de D
double[][] matriceComportement(double E, double nu, double a){
  double[][] D = new double[3][3];
  D[0][0] = E*(1-a*nu)/((1+nu)*(1-nu-a*nu));
  D[1][1] = E*(1-a*nu)/((1+nu)*(1-nu-a*nu));
  D[0][2] = 0;
  D[1][2] = 0;
  D[2][0] = 0;
  D[2][1] = 0;
  D[0][1] = E*nu*(1-a*nu)/((1+nu)*(1-nu-a*nu)*(1-a*nu));
  D[1][0] = E*nu*(1-a*nu)/((1+nu)*(1-nu-a*nu)*(1-a*nu));
  D[2][2] = E/(2*(1+nu));
  return D;
}

// Construction de B
double[][] matriceDif(ArrayList<Noeud> s,int[] tri, double detJ){
  double [][] B = new double[tri.length][2*tri.length];
  for(int i=0; i<3;i++){
    B[1][2*i]=0;
    B[0][2*i+1]=0;
  }
  B[0][0]=(s.get(tri[1]).pos.y-s.get(tri[2]).pos.y)/detJ;
  B[1][1]=(s.get(tri[2]).pos.x-s.get(tri[1]).pos.x)/detJ;
  B[2][0]=B[1][1];
  B[2][1]=B[0][0];
  B[0][2]=(s.get(tri[2]).pos.y-s.get(tri[0]).pos.y)/detJ;
  B[1][3]=(s.get(tri[0]).pos.x-s.get(tri[2]).pos.x)/detJ;
  B[2][2]=B[1][3];
  B[2][3]=B[0][2];
  B[0][4]=(s.get(tri[0]).pos.y-s.get(tri[1]).pos.y)/detJ;
  B[1][5]=(s.get(tri[1]).pos.x-s.get(tri[0]).pos.x)/detJ;
  B[2][4]=B[1][5];
  B[2][5]=B[0][4];
  return B;
}


// Fonctions de calculs entre matrices
double[][] matMul(double[][] A, double[][] B){
  int p = A.length;
  int q = B[0].length;
  int n = A[0].length;
  if(n != B.length){
    println("Erreur de dimensionnement de matrice");
    exit();
  }
  double[][] AB = new double[p][q];
  for(int i = 0; i<p;i++){
    for(int j=0; j<q;j++){
      AB[i][j]=0;
      for(int k=0; k<n;k++){
        AB[i][j]+=A[i][k]*B[k][j];
      }
    }
  }
  return AB;
}

double[][] matMulScal(double[][] A, double k){
  int n = A.length;
  int m = A[0].length;
  double[][] kA = new double[n][m];
  for(int i = 0; i<n;i++){
    for(int j=0; j<m;j++){
      kA[i][j] =A[i][j]*k;
    }
  }
  return kA;
}

double[][] matTrans(double[][] A){
  int n = A.length;
  int m = A[0].length;
  double[][] At = new double[m][n];
  for(int i = 0; i<n;i++){
    for(int j=0; j<m;j++){
      At[j][i]=A[i][j];
    }
  }
  return At;
}
