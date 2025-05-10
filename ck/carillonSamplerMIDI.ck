// chuck ck/carillonSamplerMIDI.ck
// run vmpk -- check qjackctl, should see something like 130:VMPK:Output
// chuck this file -- should see something like 128:RtMidi:Input Client
// qjackctl ALSA patch something like 130:VMPK:Output to 128:RtMidi:Input Client

0 => int device;

MidiIn min;
MidiMsg msg;

if( !min.open( device ) ) me.exit();
<<< "MIDI device:", min.num(), " -> ", min.name() >>>;

FileIO ls;
ls.open( "../satBells.txt", FileIO.READ );
0 => int cntBell;
while ( ls.more() ) {
  ls.readLine();
  cntBell++;
}
<<< cntBell >>>;

string satFile[ cntBell ];
ls.open( "../satBells.txt", FileIO.READ );
0 => cntBell;
while ( ls.more() ) {
  ls.readLine() => satFile[ cntBell ];
  cntBell++;
}

200 => int nSndBufs;
SndBuf bellSamp[nSndBufs];
-1 => int bellCtr;

fun void satNote( int kn ) {
  bellCtr++;
  nSndBufs %=> bellCtr;
  bellCtr => int bc;
  kn%2 => int ch;
  <<< satFile[ kn ] >>>;
  bellSamp[ bc ].read( "../sather/" + satFile[ kn ]);
  bellSamp[ bc ].gain(0.2);
  bellSamp[ bc ] => dac.chan( ch );
  (4.0)::second => now;
  bellSamp[ bc ] =< dac.chan( ch );
}

class NoteEvent extends Event
{
    int note;
    int velocity;
}
NoteEvent on;
Event @ us[128];
Gain g => JCRev r => dac;
.1 => g.gain;
.2 => r.mix;

fun void handler()
{
    // don't connect to dac until we need it
    Mandolin m;
    Event off;
    int note;

    while( true )
    {
        on => now;
        on.note => note;
        // dynamically repatch
        m => g;
        Std.mtof( note ) => m.freq;
        Math.random2f( .6, .8 ) => m.pluckPos;
//        on.velocity / 128.0 => m.pluck;
        off @=> us[note];
spork ~satNote( note );

        off => now;
        null @=> us[note];
        m =< g;
    }
}
for( 0 => int i; i < 20; i++ ) spork ~ handler();
while( true )
{
    // wait on midi event
    min => now;

    // get the midimsg
    while( min.recv( msg ) )
    {
        // catch only noteon
        if( (msg.data1 & 0xf0) == 0x90 )
        {
            // check velocity
            if( msg.data3 > 0 )
            {
                // store midi note number
                msg.data2 => on.note;
                // store velocity
                msg.data3 => on.velocity;
                // signal the event
                on.signal();
                // yield without advancing time to allow shred to run
                me.yield();
            }
            else
            {
                if( us[msg.data2] != null ) us[msg.data2].signal();
            }
        }
        else if( (msg.data1 & 0xf0) == 0x80 )
        {
            us[msg.data2].signal();
        }
    }
}


