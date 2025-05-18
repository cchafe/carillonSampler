// chuck bug.ck
// test number of lines read while more() is true
// different results on Fedora 41 and Debian 12

FileIO out;
out.open( "lines.txt", FileIO.WRITE );
repeat (10) out <= "\n";
out.close();

FileIO in;
in.open( "lines.txt", FileIO.READ );
0 => int linesRead;
while ( in.more() ) {
  in.readLine();
  linesRead++;
}
<<< "read", linesRead, "lines"  >>>;

