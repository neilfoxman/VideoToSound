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
    
    // Clear out old blobs that have died
    // For each old Blob
    Iterator<Blob> oldBlobIter = this.oldBlobs.iterator();
    while(oldBlobIter.hasNext())
    {
      Blob oldBlob = oldBlobIter.next();
      
      if(oldBlob.deathCounter < 0) // if the oldBlob has died
      {
        oldBlobIter.remove(); // remove it from the list
      }
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
      
      // determine if oldBlob has a matching newBlob
      for (Blob inspectedOldBlob : this.oldBlobs) // inspect each old blob
      {
        
        //  get closest newblob to inspected oldblob
        Blob closestNewBlob = inspectedOldBlob.closestBlob;

        //  get closest oldblob to closest newblob to inspected oldBlob
        Blob closestOldBlob_closestNewBlob = closestNewBlob.closestBlob;
        
        //print("inspectedOldBlob: " + inspectedOldBlob.finalId + " (" + inspectedOldBlob.tempId + ") closestBlobDist: " + String.format("%.2g",inspectedOldBlob.closestBlobDist));
        //print("\t| closestNewBlob: " + closestNewBlob.finalId + " (" + closestNewBlob.tempId + ")");
        //println("\t| closestOldBlob_closestNewBlob: " + closestOldBlob_closestNewBlob.finalId + " (" + closestOldBlob_closestNewBlob.tempId + ")");
        
        boolean matchFound = false; // Assert that a matching newBlob has not been found yet
        
        //  if inspected oldBlob is the closest oldBlob to its closest newBlob
        if (inspectedOldBlob.finalId == closestOldBlob_closestNewBlob.finalId)
        {
          // if distance is less than threshold
          if (inspectedOldBlob.closestBlobDist < trackDistanceThreshold)
          {
            //// Assign the newblob the same final id as the inspected and closest oldBlob
            //closestNewBlob.finalId = inspectedOldBlob.finalId;
            ////println("closestNewBlob "+closestNewBlob.finalId+"  inspectedOldBlob:"+inspectedOldBlob.finalId);
            
            inspectedOldBlob.update(closestNewBlob); // update the oldBlob with the closest newBlob info
            
            matchFound = true; // assert that a matching blob has been found
          }
        }
        
        if(!matchFound) // if a matching newBlob has not been found
        {
          inspectedOldBlob.deathCounter--; // decrement the death counter
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
      
      this.oldBlobs.add(newBlob); // add to the oldBlobs List
    }
    
    //println(); //<>//
    
  }
  
  public ArrayList<Blob> getBlobs()
  {
    return(this.oldBlobs);
  }
  
  public ArrayList<Blob> getNewBlobsOnly()
  {
    return(this.newBlobs);
  }
  
}