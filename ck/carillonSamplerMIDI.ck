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
float satDur [ cntBell ];
ls.open( "../satBells.txt", FileIO.READ );
0 => cntBell;
while ( ls.more() ) {
  ls.readLine() => satFile[ cntBell ];
  cntBell++;
}

ls.open( "../satBellsDurs.txt", FileIO.READ );
for( 0 => int i; i < cntBell; i++ ) 
  Std.atof( ls.readLine() ) => satDur[ i ];

200 => int nSndBufs;
SndBuf bellSamp[nSndBufs];
Pan2 pan[nSndBufs];
-1 => int bellCtr;

43 => int loBell; // g
103 => int hiBell; // g
if (false) // measure durations with RMS
for( 0 => int i; i < cntBell; i++ ) {
  SndBuf bell => FFT fft =^ RMS rms => blackhole;
  bell.read( "../sather/" + satFile[ i ]);
  //bell.gain(0.5);
  2048 => fft.size;
  Windowing.hann(fft.size()) => fft.window;
  now => time start;
  now + bell.length() => time quit;
  1000.0 => float rmsVal;
  now + 1::second => time slop;
  while( (now < quit) && ( (now < slop) || ( rmsVal > 5.0 ) ) ) {
    rms.upchuck() @=> UAnaBlob blob;
    Math.rmstodb( blob.fval(0) ) => rmsVal;
    fft.size()::samp => now;
  }
//  <<< i, satFile[ i ] >>>;
//  <<< bell.length()/second >>>; 
//  <<< rmsVal, now/second >>>;
<<< now/second-start/second,"" >>>;
}

fun void satNote( int kn, int v ) { // loBell to hiBell range
  bellCtr++;
  nSndBufs %=> bellCtr;
  bellCtr => int bc;
  kn%2 => int ch;
  kn - loBell => int fn; // satFile index
  <<< kn, satFile[ fn ], satDur[ fn ] >>>;
  bellSamp[ bc ].read( "../sather/" + satFile[ fn ]);
  bellSamp[ bc ].gain( 0.2 * v$float / 127.0);
  bellSamp[ bc ] => pan[ bc ] => dac;
  if (ch) 
    pan[ bc ].pan( Math.cos( 6.28 * v$float / 127.0) );
  else
    pan[ bc ].pan( -1.0 * Math.cos( 6.28 * v$float / 127.0) );
  0.5 * satDur[ fn ]::second => now;
  bellSamp[ bc ] =< pan[ bc ] =< dac;
}

class NoteEvent extends Event
{
    int note;
    int velocity;
}
NoteEvent on;
//Event @ us[128];

fun void handler()
{
    int note;
    int velocity;
    while( true )
    {
        on => now;
        on.note => note;
        12 +=> note; // shift the range left on the pn kbd
        on.velocity => velocity;
  if ( ( note  < loBell ) || ( note  > hiBell ) ) continue; 
        spork ~satNote( note, velocity ); 
//        null @=> us[note];
    }
}

for( 0 => int i; i < 10; i++ ) spork ~ handler();

while( true )
{
    min => now;
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
//                if( us[msg.data2] != null ) us[msg.data2].signal();
            }
        }
        else if( (msg.data1 & 0xf0) == 0x80 )
        {
//            us[msg.data2].signal();
        }
    }
}


