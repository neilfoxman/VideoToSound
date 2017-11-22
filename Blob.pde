class Blob
{
  private PApplet parent;
  public Contour contour;
  public int x, y;
  
  // Blob Tracking
  public int tempId, finalId;
  public Blob closestBlob = null;
  public Float closestBlobDist = null;
  Map<Blob, Float> distMap = null; // map of distances to other blobs


  public Blob (PApplet _parent, Contour _contour)
  {
    this.parent = _parent;
    this.tempId = -1;
    this.finalId = -1;
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
  
  public void calculateClosestBlob(ArrayList<Blob> blobs)
  {
    distMap = new HashMap<Blob, Float>(2 * blobs.size());  // Oversize to avoid re-hashing
    for(Blob blob : blobs)
    {
      float dist = this.getDist(blob);
      distMap.put(blob, dist);
    }
    
    // Iterate through hashmap to determine min distance
    // https://stackoverflow.com/questions/1066589/iterate-through-a-hashmap
    Iterator it = distMap.entrySet().iterator();
    while (it.hasNext()) {
        Map.Entry pair = (Map.Entry)it.next();
        Blob inspectedBlob = (Blob)pair.getKey();
        Float inspectedDist = (Float)pair.getValue();
        if(closestBlobDist == null || inspectedDist < closestBlobDist)
        {
          closestBlobDist = inspectedDist;
          closestBlob = inspectedBlob;
        }
        it.remove(); // avoids a ConcurrentModificationException
    }
  }
}