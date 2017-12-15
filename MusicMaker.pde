
class MusicMaker
{
  MidiBus midiBus;
  ArrayList<NoteLinkedBlob> oldNLBs, newNLBs, toPlayNLBs, toStopNLBs;



  public final ArrayList<Integer> SCALE_MAJOR = new ArrayList(Arrays.asList(0, 2, 4, 5, 7, 9, 11));
  public final ArrayList<Integer> SCALE_MINOR = new ArrayList(Arrays.asList(0, 2, 3, 5, 7, 8, 10));
  public final ArrayList<Integer> SCALE_SIMPLE = new ArrayList(Arrays.asList(0, 2, 5, 7));
  private ArrayList<XRange> xRanges = new ArrayList<XRange>(); // collection of x values.   
  public ArrayList<Integer> scale;
  public int channel = 0;
  public int velocity = 127;
  public int rootNote = 60;


  public MusicMaker()
  {
    midiBus = new MidiBus(this, -1, "Microsoft GS Wavetable Synth");
    setNoteMapLinear(10);
    this.scale = SCALE_SIMPLE;
  }
  
  
  
  
  
  
  
  // gets notes for each new blob, handles blob translation into NoteLinkedBlob, NLB birth, NLB movement, and NLB death
  void update(ArrayList<Blob> blobs)
  {
    // clear previous NLB lists
    this.newNLBs.clear();
    this.toPlayNLBs.clear();
    this.toStopNLBs.clear();

    // translate blobs to newNLB's
    for (Blob blob : blobs)
    {
      Note note = determineNoteFromLocation(blob);
      this.newNLBs.add(new NoteLinkedBlob(note, blob));
    }

    // for each old NLB
    Iterator<NoteLinkedBlob> oldNLBiter = this.oldNLBs.iterator();
    while (oldNLBiter.hasNext())
    {
      NoteLinkedBlob oldNLB = oldNLBiter.next();

      // check if same blob is in newNLBs:
      ArrayList<NoteLinkedBlob> sameBlobNewNLBs = oldNLB.removeNLBsWithSameBlobFrom(this.newNLBs);

      // if the blob was in the newNLB list
      if (!sameBlobNewNLBs.isEmpty())
      {
        if (sameBlobNewNLBs.size() > 1)
        {
          println("duplicate blobs in new NLB list, size: " + sameBlobNewNLBs.size());
        }

        // remove other newNLB's with the same note
        ArrayList<NoteLinkedBlob> sameNoteNLBs = oldNLB.removeNLBsWithSameNoteFrom(this.newNLBs);

        // TODO: change cc value based on sameBlobNLB
      } else // if blob is not in newNLB list andhas disappeared
      {
        // add toStop list
        this.toStopNLBs.add(oldNLB);

        // remove from oldNLB list
        oldNLBiter.remove();
      }
    }

    // for each remaining new NLB
    Iterator<NoteLinkedBlob> newNLBiter = this.newNLBs.iterator();
    while (newNLBiter.hasNext())
    {
      NoteLinkedBlob inspectedNewNLB = newNLBiter.next();

      // add to toPlay list unless note already there:
      // copy item to toPlay List
      toPlayNLBs.add(inspectedNewNLB);
      // remove NLBs with name note (including inspected) from newNLBs
      inspectedNewNLB.removeNLBsWithSameNoteFrom(this.newNLBs);
    }

    // add toPlay NLBs to oldNLBs
    Iterator<NoteLinkedBlob> toPlayNLBiter = this.toPlayNLBs.iterator();
    while (toPlayNLBiter.hasNext())
    {
      NoteLinkedBlob inspectedToPlayNLB = toPlayNLBiter.next();

      oldNLBs.add(inspectedToPlayNLB);
      toPlayNLBiter.remove();
    }
  }
  
  
  
  
  
  
  
  // looks at NLB's stored on list and plays, stops, or changes Notes
  void play()
  {
    // TODO: change cc
    
    // stop notes on toStop list
    for(NoteLinkedBlob nlb : this.toStopNLBs)
    {
      midiBus.sendNoteOff(nlb.note);
    }
    
    // play notes on toPlay list
    for(NoteLinkedBlob nlb : this.toPlayNLBs)
    {
      midiBus.sendNoteOn(nlb.note);
    }
  }








  void setNoteMapLinear(int numNotes)
  {

    this.xRanges.clear();// clear previous map of note ranges
    int xRangeInterval = FRAME_SINGLE_WIDTH / numNotes; // choose interval between X to make note cutoff
    if(xRangeInterval == 0)
    {
      println("improper number of notes");
      return;
    }
    
    int xRangeMax = 0; // start at x = 0

    for (int xRangeIdx = 0; xRangeIdx < numNotes; xRangeIdx++) // for each xRange
    {
      int xMin = xRangeIdx * xRangeInterval;
      int xMax = xRangeIdx+1 * xRangeInterval;
      this.xRanges.add(new XRange(xMin, xMax)); // add that value to the noteMap
    }
  }



  Note determineNoteFromLocation(Blob blob)
  {
    Note retNote = null;
    for (int xRangeIdx = 0; xRangeIdx < xRanges.size(); xRangeIdx++) // for each xRange by index
    {
      XRange xRange = xRanges.get(xRangeIdx); // get the current xRange
      if (xRange.contains(blob.x)) // if the blob is in this xRange
      {
        int octave = xRangeIdx / this.scale.size(); // determine octave above rootNote
        int pitchIdx = xRangeIdx % this.scale.size(); // determine pitch index in scale
        int pitch = this.rootNote + octave * 12 + this.scale.get(pitchIdx); // determine note pitch
        retNote = new Note(channel, pitch, velocity);
      }
    }
    return(retNote);
  }



























  public class NoteLinkedBlob
  {
    public Note note;
    public Blob blob;

    public NoteLinkedBlob(Note _note, Blob _blob)
    {
      this.note = _note;
      this.blob = _blob;
    }

    boolean isSameNote(NoteLinkedBlob compareNLB)
    {
      boolean ret = false;
      if (compareNLB.note.pitch == this.note.pitch)
      {
        ret = true;
      }
      return(ret);
    }

    boolean isSameBlob(NoteLinkedBlob compareNLB)
    {
      boolean ret = false;
      if (compareNLB.blob.finalId == this.blob.finalId)
      {
        ret = true;
      }
      return(ret);
    }

    // Iterating removal https://stackoverflow.com/questions/223918/iterating-through-a-collection-avoiding-concurrentmodificationexception-when-re

    // Iterate through list and remove any elements that match the note pitch
    // returns removed items
    ArrayList<NoteLinkedBlob> removeNLBsWithSameNoteFrom(ArrayList<NoteLinkedBlob> listNLB)
    {
      ArrayList<NoteLinkedBlob> retList = new ArrayList<NoteLinkedBlob>();

      Iterator<NoteLinkedBlob> listNLBiter = listNLB.iterator();
      while (listNLBiter.hasNext())
      {
        NoteLinkedBlob nextNLB = listNLBiter.next();
        if (this.isSameNote(nextNLB))
        {
          retList.add(nextNLB);
          listNLBiter.remove();
        }
      }
      return(retList);
    }

    ArrayList<NoteLinkedBlob> removeNLBsWithSameBlobFrom(ArrayList<NoteLinkedBlob> listNLB)
    {
      ArrayList<NoteLinkedBlob> retList = new ArrayList<NoteLinkedBlob>();

      Iterator<NoteLinkedBlob> listNLBiter = listNLB.iterator();
      while (listNLBiter.hasNext())
      {
        NoteLinkedBlob nextNLB = listNLBiter.next();
        if (this.isSameBlob(nextNLB))
        {
          retList.add(nextNLB);
          listNLBiter.remove();
          //break;
        }
      }
      return(retList);
    }
  }





















  public class XRange
  {
    /*
      Scales and xRanges
     Each portion of the window is divided into XRanges horizontally
     each xRange is assigned a minimum and a maximum x value
     When iterating through xRanges, if a blob's x value is less than a given value, but above all the previous values,
     then it resides in 
     */
     public int xMin, xMax;

    public XRange(int _xMin, int _xMax)
    {
      this.xMin = _xMin;
      this.xMax = _xMax;
    }
    
    // Check if value is in xRange (left inclusive)
    public boolean contains(int xVal)
    {
      boolean retBool = false;
      if(xVal < this.xMax)
      {
        if(xVal >= this.xMin)
        {
          retBool = true;
        }
      }
      return(retBool);
    }
    
  }
}