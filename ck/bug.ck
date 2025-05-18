// chuck ck/carillonSamplerMIDI.ck
// run vmpk -- check qjackctl, should see something like 130:VMPK:Output
// chuck this file -- should see something like 128:RtMidi:Input Client
// qjackctl ALSA patch something like 130:VMPK:Output to 128:RtMidi:Input Client

FileIO ls;
ls.open( "../satBells.txt", FileIO.READ );
0 => int nSndBufs;
while ( ls.more() ) {
  ls.readLine();
  nSndBufs++;
}
<<< nSndBufs >>>;

