# carillon sampler
uses bell samples from UC Berkeley Sather Tower

[Recorded by David Wessel, Ed Campion, and Jeff Davis ](https://cearto.github.io/hack-the-bells/open.html)

for indoor performances (MIDI keyboard) of 
[To The Sun](https://www.suncarillon.org/)

----
chuck project started from 
[chuck MIDI example](https://chuck.stanford.edu/doc/examples/midi/polyfony.ck)

intended for standalone Raspberry Pi4b+, headless, booting into live application
1. Raspberry Pi Imager on fedora 41 laptop to burn SDcard with latest Raspbian -- Debian 12 Bookworm
2. install in rpi, configure with defaults and upgrade
3. sudo apt install chuck
4. git clone this repository code
5. cd carillonSampler
6. autostart/updateAutostartService.sh
  * assumes Presonus A96 audio interface (adjust as needed for Jack and for MIDI input)
7. reboot
8. (optional for development)
  * sudo apt install vmpk qjackctl
  * start qjackctl, choose your audio device, 48k, 1024
  * start vmpk, edit MIDI connections -> ALSA
  * sudo systemctl enable ssh.service
9. (optional for debugging)
  * cd ck
  * chuck -busize:32 carillonSamplerMIDI.ck
  * qjackctl ALSA patch something like 130:VMPK:Output to 128:RtMidi:Input Client
10. (optional for stress testing)
 * generate test loop from another chuck host
    * connect with MIDI cable
    * cd ck
    * chuck testBellsLoopMIDIout.ck
----

tested audio
1. vanilla internal headphone out, limited to 22kHz -- not useable quality
2. external USB audio interface, 48kHz, limited to 1024 FPP -- ok
3. HifiBerry, also needs 1024 -- ok

tested MIDI cable
1. Presonus A96 MIDI in to 128:RtMidi:Input Client
2. Emu Xmidi1x1 tab from RtMidi:Output Client

tested external loop via MIDI cable
1. testBellsLoopMIDIout.ck
