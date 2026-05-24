class Geometrie{
  ArrayList<PVector> contour = new ArrayList<PVector>();
  Maillage maillage;
  double E, nu, e, a;
  Geometrie (double E_, double nu_, double e_, double a_) {
    E=E_;
    nu=nu_;
    e=e_;
    a=a_;
  } 
  
  
  void montrer(int c) {
    stroke(0,c);
    noFill();
    beginShape();
    for(int i = 0; i < contour.size(); i++)  {
      PVector p = contour.get(i);
      vertex(p.x,p.y);
    }
    endShape(CLOSE);
  }
  
  void maillage(int nMaille){
    maillage = triangulationContour(contour, nMaille);
    println();
    println("Triangles : " + maillage.triangles.length);
    println("Arêtes    : " + maillage.aretes.length);
    println("Sommets   : " + maillage.sommets.size());
  }
}
