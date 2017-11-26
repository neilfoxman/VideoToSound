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
    // Load Image into Tracker
    this.img = _img;
    
    // Find all contours in image
    this.opencv.loadImage(img);
    ArrayList<Contour> contours = opencv.findContours(true, true);

    // Convert each contour to a blob and add each blob to new blob list
    this.newBlobs.clear();
    for (Contour contour : contours)
    {
      Blob newBlob = new Blob(this.parent, contour);
      newBlob.tempId = ++idCounter;
      this.newBlobs.add(newBlob);
    }



    // If we have tracked old blobs
    if (!this.oldBlobs.isEmpty())
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
      for (Blob newBlob : this.newBlobs) //For each new blob
      {
        //  get closest oldBlob distance
        newBlob.calculateClosestBlob(this.oldBlobs);
        //  if distance < the=reshold
        //    get closest oldBlob final id
      }


      //determine matching blob - check that closest blob to new blob and closest blob to old blob match:
      for (Blob inspectedOldBlob : this.oldBlobs) // inspect each old blob
      {
        //  get closest newblob to inspected oldblob
        Blob closestNewBlob = inspectedOldBlob.closestBlob;

        //  get closest oldblob to closest newblob to inspected oldBlob
        Blob closestOldBlob_closestNewBlob = closestNewBlob.closestBlob;

        //  if inspected oldBlob is the closest oldBlob to its closest newBlob
        if (inspectedOldBlob.finalId == closestOldBlob_closestNewBlob.finalId)
        {
          // if distance is less than threshold
          if (inspectedOldBlob.closestBlobDist < trackDistanceThreshold)
          {
            // Assign the newblob the same final id as the inspected and closest oldBlob
            closestNewBlob.finalId = inspectedOldBlob.finalId;
          }
        }
      }
    }

    // clear oldBlob List as tracking operations are complete
    this.oldBlobs.clear();

    // Assign a final id to all remaining newBlobs and copy them to the oldBlob List:
    for(Blob newBlob : this.newBlobs)// for each newBlob
    {
      if(newBlob.finalId < 0)// if the newBlob does not have a finalId
      {
        newBlob.finalId = newBlob.tempId;// copy its tempId to its finalId
      }
      this.oldBlobs.add(newBlob);// add each newBlob to the List of OldBlobs
    }
    
  }

  public ArrayList<Blob> getBlobs()
  {
    println(newBlobs.size());
    return(newBlobs);
  }
  
}