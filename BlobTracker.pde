class BlobTracker
{
  private PApplet parent;
  private int idCounter;
  private ArrayList<Blob> oldBlobs, newBlobs;
  private OpenCV opencv;
  
  public BlobTracker(PApplet _parent)
  {
    this.parent = _parent;
    this.idCounter = 0;
    this.oldBlobs = new ArrayList<Blob>();
    this.newBlobs = new ArrayList<Blob>();
    this.opencv = new OpenCV(this.parent, FRAME_SINGLE_WIDTH, FRAME_SINGLE_HEIGHT);
  }
  
  public void runTracker(PImage img)
  {
    // Find all contours in image
    this.opencv.loadImage(img);
    ArrayList<Contour> contours = opencv.findContours(true, true);
    
    // Convert each contour to a blob and add each blob to new blob list
    for(Contour contour : contours)
    {
      Blob newBlob = new Blob(this.parent, contour);
      newBlob.tempId = ++idCounter;
      this.newBlobs.add(newBlob);
    }
    
    // If no existing old blob list
    if(this.oldBlobs.isEmpty())
    {
      // Go thru each new blob
      for(Blob newBlob : newBlobs)
      {
        // assign the final id as the temp id
        newBlob.finalId = newBlob.tempId;
        
        // add the blob to the old blob list
        this.oldBlobs.add(newBlob);
      }
    }
    else // If we have old blobs
    {
      //println("size: " + oldBlobs.size() + "  counter: " + this.idCounter);
      
      //Determine closest new blob to each old blob
       //for each old blob
       //  get closest newBlob distance
       //  if distance < threshold
       //    get closest newblob tempId
          
       //Determine closest old blob to each new blob
       //For each new blob
       //  get closest oldBlob distance
       //  if distance < the=reshold
       //    get closest oldBlob final id
        
       //determine matching blob - check that closest blob to new blob and closest blob to old blob match:
       //for each old blob
       //  get oldblob_finalId
       //  get closest_newblob_tempId
       //  get closest_oldblob_to_closest_newblob_final_id
       //  if oldblob_final_id == closest_oldblob_to_closest_newblob_final_id
       //    closest_newblob_final_id = oldblob_final_id
      
    }
  }
  
  public ArrayList<Blob> getBlobs()
  {
    return(newBlobs);
  }
  
  
  
}