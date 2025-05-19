# killall jackd
# killall chuck
sleep 1
/usr/bin/jackd -dalsa -dhw:A96 -r48000 -p1024 &
sleep 2
cd /home/cc/carillonSampler/ck
chuck -busize:32 carillonSamplerMIDI.ck &
sleep 2
aconnect 28:0 RtMidi\ Input\ Client:0

