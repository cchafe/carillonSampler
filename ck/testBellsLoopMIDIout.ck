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
0 => int kn;
while( true )
{
    0x90 => msg.data1;
    // pitch
    kn => msg.data2;
    kn++;
    68 %=> kn;
    // velocity
    127 => msg.data3;
    // print
    <<< "sending NOTE ON message...", "" >>>;
    // send MIDI message
    mout.send( msg );

    // let time pass
    .1::second => now;
    
    // MIDI note off message
    // 0x80 + channel (0 in this case)
    0x80 => msg.data1;
    // pitch
    kn => msg.data2;
    // velocity
    0 => msg.data3;
    // print
    <<< "sending NOTE OFF message...", "" >>>;
    // send MIDI message
    mout.send( msg );

    // let time pass
    .1::second => now;
}


