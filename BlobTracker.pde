class BlobTracker
{
  private PApplet parent;
  private int idCounter;
  private ArrayList<Blob> oldBlobs, newBlobs;
  private PImage img;
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

  public void runTracker(PImage _img)
  {
    
    //println("***********************************");
    
    // Clear out old blobs
    this.oldBlobs.clear();
    
    // Copy any previous newBlobs to oldBlob list, they are now used as the oldBlobs for tracking
    for(Blob newBlob : this.newBlobs)// for each newBlob
    {
      this.oldBlobs.add(newBlob);// add each newBlob to the List of OldBlobs
    }
    
    // clear out newBlobs list.  When we scan the image, we will put the blobs in the newBlob list
    this.newBlobs.clear();
    
    // Load Image into Tracker
    this.img = _img;
    
    // Find all contours in image
    this.opencv.loadImage(this.img);
    ArrayList<Contour> contours = opencv.findContours(true, true);

    // Convert each contour to a blob and add each blob to new blob list
    for (Contour contour : contours)
    {
      Blob newBlob = new Blob(this.parent, contour);
      newBlob.tempId = ++idCounter;
      this.newBlobs.add(newBlob);
    }

    // If we have old blobs that we have previously tracked
    if (!this.oldBlobs.isEmpty())
    {
      //Determine closest new blob to each old blob
      for (Blob oldBlob : this.oldBlobs) //for each old blob
      {
        //  get closest newBlob distance
        oldBlob.calculateClosestBlob(this.newBlobs);
      }

      //Determine closest old blob to each new blob
      for (Blob newBlob : this.newBlobs) //For each new blob
      {
        //  get closest oldBlob distance
        newBlob.calculateClosestBlob(this.oldBlobs);
      }      
      
      
      for (Blob inspectedOldBlob : this.oldBlobs) // inspect each old blob
      {
        //  get closest newblob to inspected oldblob
        Blob closestNewBlob = inspectedOldBlob.closestBlob;

        //  get closest oldblob to closest newblob to inspected oldBlob
        Blob closestOldBlob_closestNewBlob = closestNewBlob.closestBlob;
        
        //print("inspectedOldBlob: " + inspectedOldBlob.finalId + " (" + inspectedOldBlob.tempId + ") closestBlobDist: " + String.format("%.2g",inspectedOldBlob.closestBlobDist));
        //print("\t| closestNewBlob: " + closestNewBlob.finalId + " (" + closestNewBlob.tempId + ")");
        //println("\t| closestOldBlob_closestNewBlob: " + closestOldBlob_closestNewBlob.finalId + " (" + closestOldBlob_closestNewBlob.tempId + ")");

        //  if inspected oldBlob is the closest oldBlob to its closest newBlob
        if (inspectedOldBlob.finalId == closestOldBlob_closestNewBlob.finalId)
        {
          // if distance is less than threshold
          if (inspectedOldBlob.closestBlobDist < trackDistanceThreshold)
          {
            // Assign the newblob the same final id as the inspected and closest oldBlob
            closestNewBlob.finalId = inspectedOldBlob.finalId;
            //println("closestNewBlob "+closestNewBlob.finalId+"  inspectedOldBlob:"+inspectedOldBlob.finalId);
          }
        }
      }
    }

    // Assign a final id to all remaining newBlobs and copy them to the oldBlob List:
    for(Blob newBlob : this.newBlobs)// for each newBlob
    {
      if(newBlob.finalId < 0)// if the newBlob does not have a finalId
      {
        newBlob.finalId = newBlob.tempId;// copy its tempId to its finalId
      }
    }
    
    //println(); //<>//
    
  }

  public ArrayList<Blob> getNewBlobs()
  {
    return(this.newBlobs);
  }
  
  public ArrayList<Blob> getOldBlobs()
  {
    return(this.oldBlobs);
  }
  
}