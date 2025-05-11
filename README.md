# carillon sampler
uses bell samples from UC Berkeley Sather Tower

[Recorded by David Wessel, Ed Campion, and Jeff Davis ](https://cearto.github.io/hack-the-bells/open.html)

for indoor performances (MIDI keyboard) of 
[To The Sun](https://www.suncarillon.org/)

----
chuck project started from 
[chuck MIDI example](https://chuck.stanford.edu/doc/examples/midi/polyfony.ck)

standalone Raspberry Pi4b+, headless, boots into live application
1. Raspberry Pi Imager on fedora 41 laptop to burn SDcard with latest Raspbian -- Debian 12 Bookworm
2. install in rpi, configure with defaults and upgrade
3. `sudo apt install chuck`
4. `git clone` this repository code
5. `cd carillonSampler; autostart/updateAutostartService.sh`
  * assumes Presonus A96 audio interface (adjust as needed for Jack and for MIDI input)
6. `reboot`
7. connect a MIDI keyboard to the A96 with a MIDI cable and play some bells
----
1. (optional for development)
  * `sudo systemctl enable ssh.service`
  * `sudo apt install qjackctl vmpk`
  * start qjackctl, choose your audio device, 48k, 1024
  * start vmpk, edit MIDI connections -> ALSA
  * `cd ck; chuck -busize:32 carillonSamplerMIDI.ck`
  * qjackctl ALSA patch something like 130:VMPK:Output to 128:RtMidi:Input Client
2. (optional for stress testing)
 * generate test loop from another chuck host connected with a MIDI cable
    * `cd ck; chuck testBellsLoopMIDIout.ck`
----

tested audio
1. vanilla internal headphone out, limited to 22kHz -- not useable quality
2. external USB audio interface, 48kHz, limited to 1024 FPP -- ok
3. HifiBerry, also needs 1024 -- ok

tested MIDI
1. MIDI input of Presonus A96 patched to chuck 128:RtMidi:Input Client (for live performance)
2. chuck RtMidi:Output Client patched to Emu Xmidi1x1 tab (for stress testing using second chuck host)
