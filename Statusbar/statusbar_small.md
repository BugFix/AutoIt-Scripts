### About
I have created a minimal status bar function here. 
It consists of a collection of labels. This also makes it possible to evaluate clicks on the parts.<br />
Font and style can be set for the entire status bar. The height of the resulting control is determined from this when it is created.<br />
The existing UDF is a bit too cluttered for me on the one hand and too uncomfortable on the other.<br />
Although I have modelled myself somewhat on the existing status bar UDF, there are some striking differences:
- The status bar is at the bottom by default, but can also be positioned at the top.
- The width of the parts is indicated (not the right position).
- The width must be specified for all parts.
- The width can be set to "-1". For this part(s), the remaining space is divided equally with other parts set to "-1".
- (Rounding) differences arising during width determination are applied to the last part marked with "-1" for correction, alternatively to the last part.
- There is an additional parameter when creating and a separate function for aligning the parts.
- All parameters (part width, part index, texts, alignment) can optionally be passed as a separated string (Opt("GuiDataSeparatorChar")) or array.
- The text and/or background colour of individual/several/all parts can be set by function.

### Current
v 0.3

### Functions

<table style='font-family:"Courier New"'>
<tr><td>_StatusbarCreate</td>
<td>Creates a simple status bar, position default on bottom border, can also be on top border</td></tr>
<tr><td>_StatusbarSetText</td>
<td>Sets values for one / more parts based on the 0-based index</td></tr>
<tr><td>_StatusbarSetAlign</td>
<td>Sets the alignment of one or more parts</td></tr>
<tr><td>_StatusbarSetColors</td>
<td>Sets text and / or background color for one / several parts</td></tr>
<tr><td>_StatusbarSetOnEvent</td>
<td>Sets OnEvent function for parts by passed indexes (default: all)</td></tr>
</table>

### Gallery
![bottom](pic/01_bottom.png)<br /><br />
![top](pic/02_top.png)<br /><br />
![alignment](pic/03_alignment.png)<br /><br />
![colored](pic/04_colored.png)<br />
