
class MusicMaker
{
  MidiBus midiBus;
  ArrayList<NoteLinkedBlob> oldNLBs, newNLBs, toPlayNLBs;


  public MusicMaker()
  {
    midiBus = new MidiBus(this, -1, "Microsoft GS Wavetable Synth");
  }

  void updateNotes(ArrayList<Blob> blobs)
  {
    // clear previous NLB's in new and toPlay List
    this.newNLBs.clear();
    this.toPlayNLBs.clear();
    
    // translate blobs to newNLB's
     
     

    // for each old NLB
    Iterator<NoteLinkedBlob> oldNLBiter = oldNLBs.iterator();
    //for (NoteLinkedBlob oldNLB : oldNLBs)
    while(oldNLBiter.hasNext())
    {
      NoteLinkedBlob oldNLB = oldNLBiter.next();
      
      // check if same blob is in newNLBs:
      ArrayList<NoteLinkedBlob> sameBlobNewNLBs = oldNLB.removeNLBsWithSameBlobFrom(newNLBs);

      // if the blob was in the newNLB list
      if (!sameBlobNewNLBs.isEmpty())
      {
        if (sameBlobNewNLBs.size() > 1)
        {
          println("duplicate blobs in new NLB list, size: " + sameBlobNewNLBs.size());
        }

        // remove other newNLB's with the same note
        ArrayList<NoteLinkedBlob> sameNoteNLBs = oldNLB.removeNLBsWithSameNoteFrom(newNLBs);

        // TODO: change cc value based on sameBlobNLB
      }
      else
      {
        // TODO: stop the note
        
        // remove from oldNLB list
        oldNLBiter.remove();
      }
    }

    // for each remaining new NLB
    Iterator<NoteLinkedBlob> newNLBiter = newNLBs.iterator();
    while(newNLBiter.hasNext())
    {
      NoteLinkedBlob inspectedNewNLB = newNLBiter.next();
      
      // add to toPlay list unless note already there:
      // copy item to toPlay List
      toPlayNLBs.add(inspectedNewNLB);
      // remove NLBs with name note (including inspected) from newNLBs
      inspectedNewNLB.removeNLBsWithSameNoteFrom(this.newNLBs);
    }
    
    // TODO: play toPlay list

    // add toPlay NLBs to oldNLBs
    Iterator<NoteLinkedBlob> toPlayNLBiter = toPlayNLBs.iterator();
    while(toPlayNLBiter.hasNext())
    {
      NoteLinkedBlob inspectedToPlayNLB = toPlayNLBiter.next();
      
      oldNLBs.add(inspectedToPlayNLB);
      toPlayNLBiter.remove();
    }
  }


  Note determineNoteFromLocation(Blob blob)
  {
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
}