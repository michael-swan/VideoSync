VideoSync
=========
Simple module that generates video sync signals that can be passed directly to RGB, VGA, and SCART connectors unchanged. These signals could also be passed to a DAC for video signal generation. 

Motivation
==========
I needed composite sync for RGB video output from an FPGA and the available implementations were heavily coupled with other modules and features that I never intend to use. If you are looking for a convenient way to generate video synchronization signals in a Verilog project, look no further.
