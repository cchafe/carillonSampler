# carillon sampler
uses bell samples from UC Berkeley Sather Tower

[Recorded by David Wessel, Ed Campion, and Jeff Davis ](https://cearto.github.io/hack-the-bells/open.html)

started from 
[chuck MIDI example](https://chuck.stanford.edu/doc/examples/midi/polyfony.ck)

intended for standalone Raspberry Pi4b+, headless, booting into live application
1. Raspberry Pi Imager on fedora 41 laptop to burn SDcard with latest Raspbian -- Debian 12 Bookworm
2. install in rpi, configure with defaults and upgrade
3. sudo apt install chuck vmpk
4. qjackctl, choose audio device, 48k, 1024
5. start vmpk, edit MIDI connections -- ALSA
6. git clone this repository code
7. cd carillonSampler
8. chuck carillonSamplerMIDI.ck
9. qjackctl ALSA patch something like 130:VMPK:Output to 128:RtMidi:Input Client

tested
1. vanilla internal headphone out, limited to 22kHz -- not useable quality
2. external USB audio interface, 48kHz, limited to 1024 FPP -- ok
3. HifiBerry, also needs 1024 -- ok
