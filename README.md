# Not-the-Worlds-Worst-Demo
A Graphics Demo for The Worlds Worst Video card and companion 6502 Breadboard Computer kit written in Assembly.



WIP   
Progress on high speed 6502 bitmap graphics routines for the Worlds Worst Video Card.

Hardware in use for the Demo.
Stock Ben Eater 6502 kit:
6502 8 bit CPU. 
1 wire used to change CPU clock to 5Mhz from the VGA counters resulting in 1.4 Mhz worth of CPU cycles. The CPU is halted 72% of the time. 28% of 5Mhz is 1.4 Mhz.
1 wire used to connect the VGA Vertical Blank signal to the 6502 Non Mask able Interrupt pin.
16KB of RAM total, 8KB mapped by VGA.
32KB ROM


VGA in 800x600 60Hrz mode.
100 pixels wide by 64 pixels tall displayed. Mapped to $2000 as 128 bytes wide per row, IE 28 bytes at the end of each 100 byte line is off-screen.  6,400 bytes are ‘on-screen’, 8KB total with screen overdraw area.

Routines used:
‘Raster’ routines. Fully unrolled draw routines for Copper Bar style bars drawn vertical or horizontal. The vertical bar routine needed to be redone to follow the scanline or it would tear. 

‘Timing’ routines. Careful timing is required for the movement to to be smooth. A couple very simple adjustable time wasting loops and a decrementing counter on the Vsync NMI take care of that.
Another use for the timing routines is for ‘transparent’ rasters. The effect requires drawing one bar on 1 frame and the other bar on the next. If you can do it fast enough with exactly the correct timing the bar appears ‘transparent’ and blends with the bar below while still moving smoothly and without tears.

‘Text’


‘Shrink/Zoom’



  
