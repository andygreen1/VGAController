# VGAController
Disclaimer: This has not been verified on an actual FPGA (yet), use at your own risk.

A state machine approach to generating VGA signals. Work in progress.

I'm relatively new to VHDL, but I've not seen any examples of driving VGA signals via state machines in any of the online material I've found.

I compared this against EEWiki's example (link: https://eewiki.net/pages/viewpage.action?pageId=15925278) by synthesizing in Xilinx ISE WebPack 14.7, the results are below.

(NB: Seeing as I'm missing some data, I can't claim that I've followed the scientific process to any degree of rigour beyond 'ehh, it gives me a rough idea anyway'. I recommend you check for yourself if you care enough.)

| 640x480 @60Hz | Best case time (ns) | Flip-flops | LUTs | Slices |
| --- | --- | --- | --- | --- |
| This Version | 3.331 | 29 | 50 | 17 |
| EEWiki Version | 3.682 | 23 | 28 | ? |


| 1280x800 @60Hz | Best case time (ns) | Flip-flops | LUTs | Slices |
| --- | --- | --- | --- | --- |
| This Version | 3.783 | 31 | 57| 22 |
| EEWiki Version | ? | ? | ? | ? |


| 1920x1200 @60Hz | Best case time (ns) | Flip-flops | LUTs | Slices |
| --- | --- | --- | --- | --- |
| This Version | 3.717 | 32 | 59 | 20 |
| EEWiki Version | 4.518 | 26 | 51 | 14 |


| 1920x1200 @60Hz | Best case time (ns) | Flip-flops | LUTs | Slices |
| --- | --- | --- | --- | --- |
| This Version | 3.708 | 32 | 58 | 20 |
| EEWiki Version | 4.587 | 26 | 45 | 15 |


So on the face of it, this seems to be doing a better job of best case throughput, at the cost of extra gates. 
I have no idea if this is a good or bad thing. I had fun anyway.