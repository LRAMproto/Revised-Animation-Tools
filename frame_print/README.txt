animation (c) Ross Hatton, 2014, modified with permission by David Rebhuhn.

plot2svg written by Juerg Schwizer, 23 Oct 2005, modified by David Rebhuhn in accordance to its license.

SVGRenderer, divvy(), frame_print, frame_print_setup, render_batch_svg (c) David Rebhuhn 2014.

frame_print is a frame rendering tool which is 100% compatible with Ross Hatton's animation() framework. It allows for quick, easy, and accurate exporting of SVG, JPEG, PNG, and TIFF images in specific sizes.

Note: for best performance, it is probably easiest to render SVG frames first and then rasterize them using the render_batch_svg() function. render_batch_svg is a matlab function which uses a Java SVG rendering tool which is capable of multithreading for better performance. It works the same way as one-off rendering of frames, except works on a batch of frames with multiple processes.

This version is distributed as is. License pending.
