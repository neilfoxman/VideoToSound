class BlobTracker
{
  private PApplet parent;
  private int idCounter;
  private ArrayList<Blob> oldBlobs, newBlobs;
  private OpenCV opencv;
  private int trackDistanceThreshold = 500;

  public BlobTracker(PApplet _parent)
  {
    this.parent = _parent;
    this.idCounter = 0;
    this.oldBlobs = new ArrayList<Blob>();
    this.newBlobs = new ArrayList<Blob>();
    this.opencv = new OpenCV(this.parent, FRAME_SINGLE_WIDTH, FRAME_SINGLE_HEIGHT);
  }

  public void setTrackDistanceThreshold(int threshold)
  {
    this.trackDistanceThreshold = threshold;
  }

  public void runTracker(PImage img)
  {
    // Find all contours in image
    this.opencv.loadImage(img);
    ArrayList<Contour> contours = opencv.findContours(true, true);

    // Convert each contour to a blob and add each blob to new blob list
    for (Contour contour : contours)
    {
      Blob newBlob = new Blob(this.parent, contour);
      newBlob.tempId = ++idCounter;
      this.newBlobs.add(newBlob);
    }

    // If no existing old blob list
    if (this.oldBlobs.isEmpty())
    {
      // Go thru each new blob
      for (Blob newBlob : newBlobs)
      {
        // assign the final id as the temp id
        newBlob.finalId = newBlob.tempId;

        // add the blob to the old blob list
        this.oldBlobs.add(newBlob);
      }
    } else // If we have old blobs
    {
      //println("size: " + oldBlobs.size() + "  counter: " + this.idCounter);

      //Determine closest new blob to each old blob
      for (Blob oldBlob : this.oldBlobs) //for each old blob
      {
        //  get closest newBlob distance
        oldBlob.calculateClosestBlob(this.newBlobs);

        //if (oldBlob.closestBlobDist == null && oldBlob.closestBlobDist > trackDistanceThreshold)//  if distance < threshold
        //{
        //  // get closest newblob tempId
          
        //}
      }

      //Determine closest old blob to each new blob
      for(Blob newBlob : this.newBlobs) //For each new blob
      {
        //  get closest oldBlob distance
        newBlob.calculateClosestBlob(this.oldBlobs);
        //  if distance < the=reshold
        //    get closest oldBlob final id
      }
      
      
      //determine matching blob - check that closest blob to new blob and closest blob to old blob match:
      for(Blob inspectedOldBlob : this.oldBlobs) // inspect each old blob
      {
        //  get closest newblob to inspected oldblob
        Blob closestNewBlob = inspectedOldBlob.closestBlob;
        
        //  get closest oldblob to closest newblob to inspected oldBlob
        Blob closestOldBlob_closestNewBlob = closestNewBlob.closestBlob;
        
        //  if inspected oldBlob is the closest oldBlob to its closest NewBlob
        if(inspectedOldBlob.finalId == closestOldBlob_closestNewBlob.finalId)
        {
          // Assign the newblob the same final id as the inspected and closest oldBlob
          closestNewBlob.finalId = inspectedOldBlob.finalId;
        }
      }
      
      
      
    }
  }

  public ArrayList<Blob> getBlobs()
  {
    return(newBlobs);
  }
  
  // looks up a newblob by temp id and assigns it a new final id
  //  returns true if set, returns false if not found
  private boolean setNewBlobFinalId(int _tempId, int _finalId)
  {
    boolean ret = false;
    for(Blob newBlob : newBlobs)
    {
      if(newBlob.tempId == _tempId)
      {
        newBlob.finalId = _finalId;
        ret = true;
      }
    }
    
    return(ret);
  }
}