# Paterson Listings
Tim Paterson's DOS listings, containing source code of 86-DOS 1.00 kernel,
various PC-DOS 1.00 pre-release kernels and utilities, and the Microsoft
BASIC-86 Compiler runtime library.

<p align="center">
<img
src="https://archive.org/download/paterson_listings/images/paterson_photo.jpg"
width="50%" align="center">
</p>

The DOS-related portions have been transcribed and turned into compilable
source code.

## Downloads and Layout
- [`1_transcription`](./1_transcription/) ([download](https://github.com/DOS-History/Paterson-Listings/releases/latest/download/paterson_listings_transcription.zip)) -
transcription of the listings, essentially the raw printer output
- [`2_printed_files`](./2_printed_files/) ([download](https://github.com/DOS-History/Paterson-Listings/releases/latest/download/paterson_listings_printed_files.zip)) -
the original files that were printed, extracted from the raw printer output
above
- [`3_source_code`](./3_source_code/) ([download](https://github.com/DOS-History/Paterson-Listings/releases/latest/download/paterson_listings_source_code.zip)) -
compilable source code extracted from the printed files above

If you just want to browse the source code or compile/assemble it, choose
[`3_source_code`](./3_source_code/). The original scans, in PDF and PNG
formats, are available at https://archive.org/details/paterson_listings.

Further details about these listings, including technical writeups, can be
found at:
- https://thebrokenpipe.com/dos/paterson_listings
- http://cini.classiccmp.org/recoveryblog.htm
- https://jscarsbrook.me/doshistory
- https://opensource.microsoft.com/blog/2026/04/28/continuing-the-story-of-early-dos-development

## Listing Content
Paterson's stack of DOS listings contains 10 bundles of continuous-feed paper,
from top to bottom:

- [Bundle 01](https://archive.org/download/paterson_listings/bundle01.pdf)
(86 pages):
    - [`MSDOS.LST`](./2_printed_files/bundle_01/MSDOS.LST)
- [Bundle 02](https://archive.org/download/paterson_listings/bundle02.pdf)
(62 pages):
    - [`86DOS.A86`](./2_printed_files/bundle_02/86DOS.A86)
    (created: 1981/07/07 17:06:59, printed: 1981/07/08 13:49:52)
- [Bundle 03](https://archive.org/download/paterson_listings/bundle03.pdf)
(18 pages):
    - [`EDLIN.DIF`](./2_printed_files/bundle_03/EDLIN.DIF)
    (created: 1981/07/28 14:21:18, printed: 1981/07/28 14:40:48)
    - [`CHKDSK.A86`](./2_printed_files/bundle_03/CHKDSK.A86)
    (created: 1981/07/15 12:19:22, printed: 1981/07/28 14:41:25)
- [Bundle 04](https://archive.org/download/paterson_listings/bundle04.pdf)
(58 pages):
    - [`86DOS.ASM`](./2_printed_files/bundle_04/86DOS.ASM)
    (created: 1981/06/15 03:18:51, printed: 1981/06/16 15:17:17)
- [Bundle 05](https://archive.org/download/paterson_listings/bundle05.pdf)
(57 pages):
    - [`ASM.PRN`](./2_printed_files/bundle_05/ASM.PRN)
- [Bundle 06](https://archive.org/download/paterson_listings/bundle06.pdf)
(71 pages):
    - [`ASM.PRN`](./2_printed_files/bundle_06/ASM.PRN)
- [Bundle 07](https://archive.org/download/paterson_listings/bundle07.pdf)
(10 pages):
    - [`CHKDSK.A86`](./2_printed_files/bundle_07/CHKDSK.A86)
    (created: 1981/06/15 04:10:28, printed: 1981/06/16 15:32:54)
- [Bundle 08](https://archive.org/download/paterson_listings/bundle08.pdf)
(32 pages):
    - [`86DOS.DIF`](./2_printed_files/bundle_08/86DOS.DIF)
    (created: 1981/06/16 15:11:47, printed: 1981/06/16 15:13:47)
- [Bundle 09](https://archive.org/download/paterson_listings/bundle09.pdf)
(459 pages):
    - `LIBLST.LOG`
    (created: 1981/11/13 01:10:16, printed: 1981/11/13 01:17:42)
    - `BASLIB.PRT`
    (created: 1981/11/13 01:09:35, printed: 1981/11/13 01:19:29)
- [Bundle 10](https://archive.org/download/paterson_listings/bundle10.pdf)
(20 pages):
    - `PAINT.ASM`
    (created: 1982/01/06 22:20:26, printed: 1982/02/06 20:58:03)
    - `CIRCLE.ASM`
    (created: 1982/02/04 11:51:32, printed: 1982/02/06 20:58:44)

Bundles 9 and 10 have not yet been transcribed. If you wish to help transcribe
them, please submit a
[pull request](https://github.com/DOS-History/Paterson-Listings/pulls). Only
contributions that provide direct transcriptions of the listings or correct
typos in existing transcriptions will be merged.

## Compiling/Assembling
Most of the sources here target Seattle Computer Products' ASM assembler, so
you will need a copy. It can be obtained from any release of 86-DOS or MS-DOS
by Seattle Computer Products. You will also need the `HEX2BIN` utility from
Seattle Computer Products to convert Intel HEX objects produced by the
assembler into binaries.

The simplest way to assemble a source file is to run
`ASM <FILENAME-NO-EXTENSION>`, followed by `HEX2BIN <FILENAME-NO-EXTENSION>`.
For example, to assemble `86DOS.ASM` into the binary `86DOS.COM`, run:
```
A:ASM 86DOS

Seattle Computer Products 8086 Assembler Version 2.24
Copyright 1979,80,81 by Seattle Computer Products, Inc.



Error Count =    0

A:HEX2BIN 86DOS

A:
```

## Special Thanks
* [@TimPaterson](https://github.com/TimPaterson) - for providing the listings
* [@shanselman](https://github.com/shanselman) and the Microsoft folks - for making this happen
* [@the-grue](https://github.com/the-grue) - for transcribing bundle 10
