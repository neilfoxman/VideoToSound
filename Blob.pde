class Blob
{
  private PApplet parent;
  public Contour contour;
  public int id;
  public int x, y;
  
  public Blob(PApplet _parent, int _id, Contour _contour)
  {
    this.parent = _parent;
    this.id = _id;
    this.contour = new Contour(parent, _contour.pointMat);
    
    // get location of blob
    Rectangle r = contour.getBoundingBox();
    this.x = r.x + r.width/2;
    this.y = r.y + r.height/2;    
  }
  
  // Get distance between this blob and another
  public float getDist(Blob otherBlob)
  {
    float dist = dist(this.x, this.y, otherBlob.x, otherBlob.y);
    return(dist);
  }
}