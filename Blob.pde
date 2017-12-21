class Blob
{
  private PApplet parent;
  public Contour contour;
  public int x, y;
  public int deathCounter = 50; // number of frames after which the blob will be removed if not found, removes flicker

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
    closestBlob = null; // clear previous close blobs
    closestBlobDist = null; // clear previous distances

    distMap = new HashMap<Blob, Float>(2 * blobs.size());  // Oversize to avoid re-hashing
    for (Blob blob : blobs)
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
      if (closestBlobDist == null || inspectedDist < closestBlobDist)
      {
        closestBlobDist = inspectedDist;
        closestBlob = inspectedBlob;
      }
      it.remove(); // avoids a ConcurrentModificationException
    }
  }


  // Compares position of other blob to see if matching position
  public boolean hasSamePosAs(Blob otherBlob)
  {
    boolean retBool = false; // begin asserting that position is not the same

    if (otherBlob.x == this.x) // if x's match
    {
      if (otherBlob.y == this.y) // and y's match
      {
        retBool = true; // assert that they do have the same position
      }
    }
    return(retBool);
  }

  public Blob getMatchingBlobFrom(ArrayList<Blob> blobList)
  {
    
    // Try to find an blob with the same positionin a list
    // begin asserting there is no matching blob then break and return match when match is found
    // returns null if no match found
    
    Blob retBlob = null;
    
    for (Blob inspectedBlob : blobList) // inspect each blob on the list
    {
      if (this.hasSamePosAs(inspectedBlob)) // If blobs have same position
      {
        retBlob = inspectedBlob; // return matching blob
        break; // break out of blob list inspection, we already found a match
      }
    }
    
    return(retBlob);
  }
}