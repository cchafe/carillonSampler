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
0 => int nSndBufs;
while ( ls.more() ) {
  ls.readLine();
  nSndBufs++;
}
<<< nSndBufs >>>;

string satFile[ nSndBufs ];
float satDur [ nSndBufs ];
int poly [ nSndBufs ];
ls.open( "../satBells.txt", FileIO.READ );
0 => nSndBufs;
while ( ls.more() ) {
  ls.readLine() => satFile[ nSndBufs ];
  nSndBufs++;
}

ls.open( "../satBellsDurs.txt", FileIO.READ );
for( 0 => int i; i < nSndBufs; i++ ) 
  Std.atof( ls.readLine() ) => satDur[ i ];

2 => int nVoices; // rpi 4 // 12 len5

SndBuf bellSamp[nSndBufs][nVoices];
Pan2 pan[nSndBufs][nVoices];
for( 0 => int i; i < nSndBufs; i++ ) {
  0 => poly[ i ];
  for( 0 => int j; j < nVoices; j++ ) {
    bellSamp[ i ][ j ].read( "../sather/" + satFile[ i ]);
    bellSamp[ i ][ j ] => pan[ i ][ j ];
  }
}

43 => int loBell; // g
103 => int hiBell; // g
if (false) // measure durations with RMS
for( 0 => int i; i < nSndBufs; i++ ) {
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
  kn - loBell => int fn; // satFile index
  fn%2 => int ch;
  poly[ fn ] => int vn;
  nVoices %=> vn;
  vn + 1 => poly[ fn ];
//  <<< kn, satFile[ fn ], satDur[ fn ], vn >>>;
  bellSamp[ fn ][ vn ].pos( 0 );
  pan[ fn ][ vn ].gain( 0.2 * v$float / 127.0);
  pan[ fn ][ vn ] => dac;
//  bellSamp[ fn ] => pan[ fn ] => dac;
  if (ch) 
    pan[ fn ][ vn ].pan( Math.cos( 6.28 * v$float / 127.0) );
  else
    pan[ fn ][ vn ].pan( -1.0 * Math.cos( 6.28 * v$float / 127.0) );
  satDur[ fn ]::second => now;
  pan[ fn ][ vn ] =< dac;
//  bellSamp[ fn ] =< pan[ fn ] =< dac;
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


