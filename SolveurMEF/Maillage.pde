class Maillage {
  ArrayList<Noeud> sommets;
  int[][]   aretes;
  int[][]   triangles;
  float[]   sigma;
  float vmMax = 0, vmMin = Float.MAX_VALUE;

  Maillage(ArrayList<Noeud> s, int[][] a, int[][] t) {
    sommets   = s;
    aretes    = a;
    triangles = t;
    sigma = new float[triangles.length];
  }
  
  void montrer(){
    fill(0);
    textAlign(LEFT);
    text("Coefficient de déformation = "+coefDefo, outils.get(0).pos.y, 3*outils.get(0).pos.y);
    for (Noeud s : sommets) s.montrer();
    for (int[] a : aretes) {
      Noeud p1 = sommets.get(a[0]);
      Noeud p2 = sommets.get(a[1]);
      line(p1.pos.x+coefDefo*p1.du.x, p1.pos.y+coefDefo*p1.du.y, p2.pos.x+coefDefo*p2.du.x, p2.pos.y+coefDefo*p2.du.y);
    }
    if(sig){
      for (int t = 0; t < triangles.length; t++) {
          int[] tri = triangles[t];
  
          float ratio = (vmMax > vmMin) ? 
                        (sigma[t] - vmMin) / (vmMax - vmMin) : 0;
          fill(couleurContrainte(ratio));
          noStroke();
          PVector p0 = sommets.get(tri[0]).pos;
          PVector p1 = sommets.get(tri[1]).pos;
          PVector p2 = sommets.get(tri[2]).pos;
          triangle(p0.x, p0.y, p1.x, p1.y, p2.x, p2.y);
      }
      afficherLegende(vmMin, vmMax);
    }
  }
}
class Noeud {
  PVector pos;
  PVector force;
  boolean ux,uy;
  PVector du;

  Noeud(float x, float y) {
    pos = new PVector(x,y);
    force = new PVector(0,0);
    du = new PVector(0,0);
    ux=false;
    uy=false;
  }
  void montrer(){
    fill(0);
    pushMatrix();
    translate(coefDefo*du.x,coefDefo*du.y);
    if(ux) triangle(pos.x,pos.y,pos.x-5,pos.y+3,pos.x-5,pos.y-3);
    if(uy) triangle(pos.x,pos.y,pos.x+3,pos.y+5,pos.x-3,pos.y+5);
    stroke(255,0,0);
    line(pos.x,pos.y,pos.x+force.x,pos.y+force.y);
    stroke(0,0,0);
    point(pos.x,pos.y);
    noFill();
    popMatrix();
  }
}


Maillage triangulationContour(ArrayList<PVector> contour,int nx) {
  // Bornes du domaine
  float minX = contour.get(0).x, maxX = contour.get(0).x;
  float minY = contour.get(0).y, maxY = contour.get(0).y;
  for (PVector p : contour) {
    if (p.x < minX) minX = p.x;
    if (p.x > maxX) maxX = p.x;
    if (p.y < minY) minY = p.y;
    if (p.y > maxY) maxY = p.y;
  }
  
  // Maillage en grille
  ArrayList<Noeud> sommets = new ArrayList<Noeud>();
  float h = (maxX - minX)/float(nx);
  selectNoeud=h/2;
  int ny = int((maxY - minY)/h);
  int[][] indices = new int[nx+1][ny+1];
  for (int[] row : indices) java.util.Arrays.fill(row, -1);
  for (int i = 0; i <= nx; i++) {
    for (int j = 0; j <= ny; j++) {
      float x = minX + i * h;
      float y = minY + j * h;
      if (pointDansContour(x, y, contour)) {
        indices[i][j] = sommets.size();
        sommets.add(new Noeud(x, y));
      }
    }
  }
  
  // Triangles
  ArrayList<int[]> triangles = new ArrayList<int[]>();
  for (int i = 0; i < nx; i++) {
    for (int j = 0; j < ny; j++) {
      int A = indices[i  ][j  ];
      int B = indices[i+1][j  ];
      int C = indices[i+1][j+1];
      int D = indices[i  ][j+1];
      if (A != -1 && B != -1 && C != -1 && D != -1) {
        triangles.add(new int[]{ A, B, D });
        triangles.add(new int[]{ B, C, D });
      }
      else if (A != -1 && B != -1 && D != -1) triangles.add(new int[]{ A, B, D });
      else if (B != -1 && C != -1 && D != -1) triangles.add(new int[]{ B, C, D });
      else if (A != -1 && B != -1 && C != -1) triangles.add(new int[]{ A, B, C });
      else if (A != -1 && C != -1 && D != -1) triangles.add(new int[]{ A, C, D });
    }
  }

  // Arêtes
  ArrayList<int[]> aretes = new ArrayList<int[]>();
  ArrayList<PVector> vus = new ArrayList<PVector>();
  for (int[] tri : triangles) {
    int[][] paires = { {tri[0],tri[1]}, {tri[1],tri[2]}, {tri[2],tri[0]} };
    for (int[] ar : paires) {
      int a0 = min(ar[0], ar[1]);
      int a1 = max(ar[0], ar[1]);
      long cle = (long)a0 * 1000000 + a1;
      PVector cles = new PVector(cle,0);
      if (vus.add(cles)) aretes.add(new int[]{ a0, a1 });
    }
  }

  return new Maillage(
    sommets,
    aretes.toArray(new int[0][]),
    triangles.toArray(new int[0][])
  );
}

boolean pointDansContour(float px, float py, ArrayList<PVector> contour) {
  int n = contour.size();
  boolean dedans = false;
  int j = n - 1;
  for (int i = 0; i < n; i++) {
    float xi = contour.get(i).x, yi = contour.get(i).y;
    float xj = contour.get(j).x, yj = contour.get(j).y;
    if ((yi > py) != (yj > py)) {
      float xInter = (xj - xi) * (py - yi) / (yj - yi) + xi;
      if (px < xInter) dedans = !dedans;
    }
    j = i;
  }
  return dedans;
}
