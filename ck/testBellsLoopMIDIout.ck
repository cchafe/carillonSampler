// chuck testBellsLoopMIDIout.ck

//-----------------------------------------------------------------------------
// name: midiout.ck
// desc: example of sending MIDI messages
// note: for a good explanation of how MIDI messages work, see after the code
//       also see midiout2.ck for sending by common channel voice message
//-----------------------------------------------------------------------------

MidiOut mout;
MidiMsg msg;
if( !mout.open(0) ) me.exit();

<<< "MIDI output device opened...", "" >>>;
43 => int loBell; // g
103 => int hiBell; // g
(hiBell - loBell) + 1 => int nBells;
loBell => int kn;
while( true )
{
    for ( 117 => int v; v <= 127; 10 +=> v) {
      0x90 => msg.data1;
      kn - 12 => msg.data2;
      v => msg.data3;
    <<< "sending NOTE ON message...", kn, v >>>;
      mout.send( msg );

      400::ms => now;

//      0x80 => msg.data1;
//      0 => msg.data3;
//      <<< "sending NOTE OFF message...", "" >>>;
//      mout.send( msg );
    }
//      .1::second => now;
    if (kn == hiBell) loBell => kn; else kn++;
}


