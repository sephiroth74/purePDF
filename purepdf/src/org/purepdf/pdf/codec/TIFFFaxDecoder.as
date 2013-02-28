/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: TIFFFaxDecoder.as 403 2011-02-10 13:00:57Z alessandro.crugnola@gmail.com $
* $Author Alessandro Crugnola $
* $Rev: 403 $ $LastChangedDate: 2011-02-10 08:00:57 -0500 (Thu, 10 Feb 2011) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/pdf/codec/TIFFFaxDecoder.as $
*
* The contents of this file are subject to  LGPL license 
* (the "GNU LIBRARY GENERAL PUBLIC LICENSE"), in which case the
* provisions of LGPL are applicable instead of those above.  If you wish to
* allow use of your version of this file only under the terms of the LGPL
* License and not to allow others to use your version of this file under
* the MPL, indicate your decision by deleting the provisions above and
* replace them with the notice and other provisions required by the LGPL.
* If you do not delete the provisions above, a recipient may use your version
* of this file under either the MPL or the GNU LIBRARY GENERAL PUBLIC LICENSE
*
* Software distributed under the License is distributed on an "AS IS" basis,
* WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
* for the specific language governing rights and limitations under the License.
*
* The Original Code is 'iText, a free JAVA-PDF library' ( version 4.2 ) by Bruno Lowagie.
* All the Actionscript ported code and all the modifications to the
* original java library are written by Alessandro Crugnola (alessandro@sephiroth.it)
*
* This library is free software; you can redistribute it and/or modify it
* under the terms of the MPL as stated above or under the terms of the GNU
* Library General Public License as published by the Free Software Foundation;
* either version 2 of the License, or any later version.
*
* This library is distributed in the hope that it will be useful, but WITHOUT
* ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
* FOR A PARTICULAR PURPOSE. See the GNU LIBRARY GENERAL PUBLIC LICENSE for more
* details
*
* If you didn't download this code from the following link, you should check if
* you aren't using an obsolete version:
* http://code.google.com/p/purepdf
*
*/
package org.purepdf.pdf.codec
{
	import org.purepdf.errors.RuntimeError;
	import org.purepdf.pdf.ByteBuffer;
	import org.purepdf.utils.Bytes;

	public class TIFFFaxDecoder
	{
		private var bitPointer: int;
		private var bytePointer: int;
		private var data: Bytes;
		private var w: int;
		private var h: int;
		private var fillOrder: int;
		private var changingElemSize: int = 0;
		private var prevChangingElems: Vector.<int>;
		private var currChangingElems: Vector.<int>;
		private var lastChangingElement: int = 0;
		private var compression: int = 2;
		private var uncompressedMode: int = 0;
		private var fillBits: int = 0;
		private var oneD: int;

		private static const flipTable: Vector.<int> = Vector.<int>( [ 0, -128, 64, -64, 32, -96, 96, -32, 16, -112, 80, -48, 48, -80, 112, -16, 8, -120, 72, -56, 40, -88, 104, -24, 24, -104, 88, -40,
				56, -72, 120, -8, 4, -124, 68, -60, 36, -92, 100, -28, 20, -108, 84, -44, 52, -76, 116, -12, 12, -116, 76, -52, 44, -84, 108, -20, 28, -100, 92, -36, 60, -68, 124, -4, 2, -126, 66, -62,
				34, -94, 98, -30, 18, -110, 82, -46, 50, -78, 114, -14, 10, -118, 74, -54, 42, -86, 106, -22, 26, -102, 90, -38, 58, -70, 122, -6, 6, -122, 70, -58, 38, -90, 102, -26, 22, -106, 86, -42,
				54, -74, 118, -10, 14, -114, 78, -50, 46, -82, 110, -18, 30, -98, 94, -34, 62, -66, 126, -2, 1, -127, 65, -63, 33, -95, 97, -31, 17, -111, 81, -47, 49, -79, 113, -15, 9, -119, 73, -55,
				41, -87, 105, -23, 25, -103, 89, -39, 57, -71, 121, -7, 5, -123, 69, -59, 37, -91, 101, -27, 21, -107, 85, -43, 53, -75, 117, -11, 13, -115, 77, -51, 45, -83, 109, -19, 29, -99, 93, -35,
				61, -67, 125, -3, 3, -125, 67, -61, 35, -93, 99, -29, 19, -109, 83, -45, 51, -77, 115, -13, 11, -117, 75, -53, 43, -85, 107, -21, 27, -101, 91, -37, 59, -69, 123, -5, 7, -121, 71, -57,
				39, -89, 103, -25, 23, -105, 87, -41, 55, -73, 119, -9, 15, -113, 79, -49, 47, -81, 111, -17, 31, -97, 95, -33, 63, -65, 127, -1, ] );

        private static const white: Vector.<int> = Vector.<int>( [  // 0 - 7
                6430, 6400, 6400, 6400, 3225, 3225, 3225, 3225,  // 8 - 15
                944, 944, 944, 944, 976, 976, 976, 976,  // 16 - 23
                1456, 1456, 1456, 1456, 1488, 1488, 1488, 1488,  // 24 - 31
                718, 718, 718, 718, 718, 718, 718, 718,  // 32 - 39
                750, 750, 750, 750, 750, 750, 750, 750,  // 40 - 47
                1520, 1520, 1520, 1520, 1552, 1552, 1552, 1552,  // 48 - 55
                428, 428, 428, 428, 428, 428, 428, 428,  // 56 - 63
                428, 428, 428, 428, 428, 428, 428, 428,  // 64 - 71
                654, 654, 654, 654, 654, 654, 654, 654,  // 72 - 79
                1072, 1072, 1072, 1072, 1104, 1104, 1104, 1104,  // 80 - 87
                1136, 1136, 1136, 1136, 1168, 1168, 1168, 1168,  // 88 - 95
                1200, 1200, 1200, 1200, 1232, 1232, 1232, 1232,  // 96 - 103
                622, 622, 622, 622, 622, 622, 622, 622,  // 104 - 111
                1008, 1008, 1008, 1008, 1040, 1040, 1040, 1040,  // 112 - 119
                44, 44, 44, 44, 44, 44, 44, 44,  // 120 - 127
                44, 44, 44, 44, 44, 44, 44, 44,  // 128 - 135
                396, 396, 396, 396, 396, 396, 396, 396,  // 136 - 143
                396, 396, 396, 396, 396, 396, 396, 396,  // 144 - 151
                1712, 1712, 1712, 1712, 1744, 1744, 1744, 1744,  // 152 - 159
                846, 846, 846, 846, 846, 846, 846, 846,  // 160 - 167
                1264, 1264, 1264, 1264, 1296, 1296, 1296, 1296,  // 168 - 175
                1328, 1328, 1328, 1328, 1360, 1360, 1360, 1360,  // 176 - 183
                1392, 1392, 1392, 1392, 1424, 1424, 1424, 1424,  // 184 - 191
                686, 686, 686, 686, 686, 686, 686, 686,  // 192 - 199
                910, 910, 910, 910, 910, 910, 910, 910,  // 200 - 207
                1968, 1968, 1968, 1968, 2000, 2000, 2000, 2000,  // 208 - 215
                2032, 2032, 2032, 2032, 16, 16, 16, 16,  // 216 - 223
                10257, 10257, 10257, 10257, 12305, 12305, 12305, 12305,  // 224 - 231
                330, 330, 330, 330, 330, 330, 330, 330,  // 232 - 239
                330, 330, 330, 330, 330, 330, 330, 330,  // 240 - 247
                330, 330, 330, 330, 330, 330, 330, 330,  // 248 - 255
                330, 330, 330, 330, 330, 330, 330, 330,  // 256 - 263
                362, 362, 362, 362, 362, 362, 362, 362,  // 264 - 271
                362, 362, 362, 362, 362, 362, 362, 362,  // 272 - 279
                362, 362, 362, 362, 362, 362, 362, 362,  // 280 - 287
                362, 362, 362, 362, 362, 362, 362, 362,  // 288 - 295
                878, 878, 878, 878, 878, 878, 878, 878,  // 296 - 303
                1904, 1904, 1904, 1904, 1936, 1936, 1936, 1936,  // 304 - 311
                -18413, -18413, -16365, -16365, -14317, -14317, -10221, -10221,  // 312 - 319
                590, 590, 590, 590, 590, 590, 590, 590,  // 320 - 327
                782, 782, 782, 782, 782, 782, 782, 782,  // 328 - 335
                1584, 1584, 1584, 1584, 1616, 1616, 1616, 1616,  // 336 - 343
                1648, 1648, 1648, 1648, 1680, 1680, 1680, 1680,  // 344 - 351
                814, 814, 814, 814, 814, 814, 814, 814,  // 352 - 359
                1776, 1776, 1776, 1776, 1808, 1808, 1808, 1808,  // 360 - 367
                1840, 1840, 1840, 1840, 1872, 1872, 1872, 1872,  // 368 - 375
                6157, 6157, 6157, 6157, 6157, 6157, 6157, 6157,  // 376 - 383
                6157, 6157, 6157, 6157, 6157, 6157, 6157, 6157,  // 384 - 391
                -12275, -12275, -12275, -12275, -12275, -12275, -12275, -12275,  // 392 - 399
                -12275, -12275, -12275, -12275, -12275, -12275, -12275, -12275,  // 400 - 407
                14353, 14353, 14353, 14353, 16401, 16401, 16401, 16401,  // 408 - 415
                22547, 22547, 24595, 24595, 20497, 20497, 20497, 20497,  // 416 - 423
                18449, 18449, 18449, 18449, 26643, 26643, 28691, 28691,  // 424 - 431
                30739, 30739, -32749, -32749, -30701, -30701, -28653, -28653,  // 432 - 439
                -26605, -26605, -24557, -24557, -22509, -22509, -20461, -20461,  // 440 - 447
                8207, 8207, 8207, 8207, 8207, 8207, 8207, 8207,  // 448 - 455
                72, 72, 72, 72, 72, 72, 72, 72,  // 456 - 463
                72, 72, 72, 72, 72, 72, 72, 72,  // 464 - 471
                72, 72, 72, 72, 72, 72, 72, 72,  // 472 - 479
                72, 72, 72, 72, 72, 72, 72, 72,  // 480 - 487
                72, 72, 72, 72, 72, 72, 72, 72,  // 488 - 495
                72, 72, 72, 72, 72, 72, 72, 72,  // 496 - 503
                72, 72, 72, 72, 72, 72, 72, 72,  // 504 - 511
                72, 72, 72, 72, 72, 72, 72, 72,  // 512 - 519
                104, 104, 104, 104, 104, 104, 104, 104,  // 520 - 527
                104, 104, 104, 104, 104, 104, 104, 104,  // 528 - 535
                104, 104, 104, 104, 104, 104, 104, 104,  // 536 - 543
                104, 104, 104, 104, 104, 104, 104, 104,  // 544 - 551
                104, 104, 104, 104, 104, 104, 104, 104,  // 552 - 559
                104, 104, 104, 104, 104, 104, 104, 104,  // 560 - 567
                104, 104, 104, 104, 104, 104, 104, 104,  // 568 - 575
                104, 104, 104, 104, 104, 104, 104, 104,  // 576 - 583
                4107, 4107, 4107, 4107, 4107, 4107, 4107, 4107,  // 584 - 591
                4107, 4107, 4107, 4107, 4107, 4107, 4107, 4107,  // 592 - 599
                4107, 4107, 4107, 4107, 4107, 4107, 4107, 4107,  // 600 - 607
                4107, 4107, 4107, 4107, 4107, 4107, 4107, 4107,  // 608 - 615
                266, 266, 266, 266, 266, 266, 266, 266,  // 616 - 623
                266, 266, 266, 266, 266, 266, 266, 266,  // 624 - 631
                266, 266, 266, 266, 266, 266, 266, 266,  // 632 - 639
                266, 266, 266, 266, 266, 266, 266, 266,  // 640 - 647
                298, 298, 298, 298, 298, 298, 298, 298,  // 648 - 655
                298, 298, 298, 298, 298, 298, 298, 298,  // 656 - 663
                298, 298, 298, 298, 298, 298, 298, 298,  // 664 - 671
                298, 298, 298, 298, 298, 298, 298, 298,  // 672 - 679
                524, 524, 524, 524, 524, 524, 524, 524,  // 680 - 687
                524, 524, 524, 524, 524, 524, 524, 524,  // 688 - 695
                556, 556, 556, 556, 556, 556, 556, 556,  // 696 - 703
                556, 556, 556, 556, 556, 556, 556, 556,  // 704 - 711
                136, 136, 136, 136, 136, 136, 136, 136,  // 712 - 719
                136, 136, 136, 136, 136, 136, 136, 136,  // 720 - 727
                136, 136, 136, 136, 136, 136, 136, 136,  // 728 - 735
                136, 136, 136, 136, 136, 136, 136, 136,  // 736 - 743
                136, 136, 136, 136, 136, 136, 136, 136,  // 744 - 751
                136, 136, 136, 136, 136, 136, 136, 136,  // 752 - 759
                136, 136, 136, 136, 136, 136, 136, 136,  // 760 - 767
                136, 136, 136, 136, 136, 136, 136, 136,  // 768 - 775
                168, 168, 168, 168, 168, 168, 168, 168,  // 776 - 783
                168, 168, 168, 168, 168, 168, 168, 168,  // 784 - 791
                168, 168, 168, 168, 168, 168, 168, 168,  // 792 - 799
                168, 168, 168, 168, 168, 168, 168, 168,  // 800 - 807
                168, 168, 168, 168, 168, 168, 168, 168,  // 808 - 815
                168, 168, 168, 168, 168, 168, 168, 168,  // 816 - 823
                168, 168, 168, 168, 168, 168, 168, 168,  // 824 - 831
                168, 168, 168, 168, 168, 168, 168, 168,  // 832 - 839
                460, 460, 460, 460, 460, 460, 460, 460,  // 840 - 847
                460, 460, 460, 460, 460, 460, 460, 460,  // 848 - 855
                492, 492, 492, 492, 492, 492, 492, 492,  // 856 - 863
                492, 492, 492, 492, 492, 492, 492, 492,  // 864 - 871
                2059, 2059, 2059, 2059, 2059, 2059, 2059, 2059,  // 872 - 879
                2059, 2059, 2059, 2059, 2059, 2059, 2059, 2059,  // 880 - 887
                2059, 2059, 2059, 2059, 2059, 2059, 2059, 2059,  // 888 - 895
                2059, 2059, 2059, 2059, 2059, 2059, 2059, 2059,  // 896 - 903
                200, 200, 200, 200, 200, 200, 200, 200,  // 904 - 911
                200, 200, 200, 200, 200, 200, 200, 200,  // 912 - 919
                200, 200, 200, 200, 200, 200, 200, 200,  // 920 - 927
                200, 200, 200, 200, 200, 200, 200, 200,  // 928 - 935
                200, 200, 200, 200, 200, 200, 200, 200,  // 936 - 943
                200, 200, 200, 200, 200, 200, 200, 200,  // 944 - 951
                200, 200, 200, 200, 200, 200, 200, 200,  // 952 - 959
                200, 200, 200, 200, 200, 200, 200, 200,  // 960 - 967
                232, 232, 232, 232, 232, 232, 232, 232,  // 968 - 975
                232, 232, 232, 232, 232, 232, 232, 232,  // 976 - 983
                232, 232, 232, 232, 232, 232, 232, 232,  // 984 - 991
                232, 232, 232, 232, 232, 232, 232, 232,  // 992 - 999
                232, 232, 232, 232, 232, 232, 232, 232,  // 1000 - 1007
                232, 232, 232, 232, 232, 232, 232, 232,  // 1008 - 1015
                232, 232, 232, 232, 232, 232, 232, 232,  // 1016 - 1023
                232, 232, 232, 232, 232, 232, 232, 232, ] );

        private static const additionalMakeup: Vector.<int> = Vector.<int>( [ 28679, 28679, 31752, -32759, -31735, -30711, -29687, -28663, 29703, 29703,
                30727, 30727, -27639, -26615, -25591, -24567 ] );

        private static const initBlack: Vector.<int> = Vector.<int>( [ 3226, 6412, 200, 168, 38, 38, 134, 134, 100, 100, 100, 100, 68, 68, 68, 68 ] );

        private static const twoBitBlack: Vector.<int> = Vector.<int>( [ 292, 260, 226, 226 ] );

        private static const black: Vector.<int> = Vector.<int>( [  // 0 - 7
                62, 62, 30, 30, 0, 0, 0, 0,  // 8 - 15
                0, 0, 0, 0, 0, 0, 0, 0,  // 16 - 23
                0, 0, 0, 0, 0, 0, 0, 0,  // 24 - 31
                0, 0, 0, 0, 0, 0, 0, 0,  // 32 - 39
                3225, 3225, 3225, 3225, 3225, 3225, 3225, 3225,  // 40 - 47
                3225, 3225, 3225, 3225, 3225, 3225, 3225, 3225,  // 48 - 55
                3225, 3225, 3225, 3225, 3225, 3225, 3225, 3225,  // 56 - 63
                3225, 3225, 3225, 3225, 3225, 3225, 3225, 3225,  // 64 - 71
                588, 588, 588, 588, 588, 588, 588, 588,  // 72 - 79
                1680, 1680, 20499, 22547, 24595, 26643, 1776, 1776,  // 80 - 87
                1808, 1808, -24557, -22509, -20461, -18413, 1904, 1904,  // 88 - 95
                1936, 1936, -16365, -14317, 782, 782, 782, 782,  // 96 - 103
                814, 814, 814, 814, -12269, -10221, 10257, 10257,  // 104 - 111
                12305, 12305, 14353, 14353, 16403, 18451, 1712, 1712,  // 112 - 119
                1744, 1744, 28691, 30739, -32749, -30701, -28653, -26605,  // 120 - 127
                2061, 2061, 2061, 2061, 2061, 2061, 2061, 2061,  // 128 - 135
                424, 424, 424, 424, 424, 424, 424, 424,  // 136 - 143
                424, 424, 424, 424, 424, 424, 424, 424,  // 144 - 151
                424, 424, 424, 424, 424, 424, 424, 424,  // 152 - 159
                424, 424, 424, 424, 424, 424, 424, 424,  // 160 - 167
                750, 750, 750, 750, 1616, 1616, 1648, 1648,  // 168 - 175
                1424, 1424, 1456, 1456, 1488, 1488, 1520, 1520,  // 176 - 183
                1840, 1840, 1872, 1872, 1968, 1968, 8209, 8209,  // 184 - 191
                524, 524, 524, 524, 524, 524, 524, 524,  // 192 - 199
                556, 556, 556, 556, 556, 556, 556, 556,  // 200 - 207
                1552, 1552, 1584, 1584, 2000, 2000, 2032, 2032,  // 208 - 215
                976, 976, 1008, 1008, 1040, 1040, 1072, 1072,  // 216 - 223
                1296, 1296, 1328, 1328, 718, 718, 718, 718,  // 224 - 231
                456, 456, 456, 456, 456, 456, 456, 456,  // 232 - 239
                456, 456, 456, 456, 456, 456, 456, 456,  // 240 - 247
                456, 456, 456, 456, 456, 456, 456, 456,  // 248 - 255
                456, 456, 456, 456, 456, 456, 456, 456,  // 256 - 263
                326, 326, 326, 326, 326, 326, 326, 326,  // 264 - 271
                326, 326, 326, 326, 326, 326, 326, 326,  // 272 - 279
                326, 326, 326, 326, 326, 326, 326, 326,  // 280 - 287
                326, 326, 326, 326, 326, 326, 326, 326,  // 288 - 295
                326, 326, 326, 326, 326, 326, 326, 326,  // 296 - 303
                326, 326, 326, 326, 326, 326, 326, 326,  // 304 - 311
                326, 326, 326, 326, 326, 326, 326, 326,  // 312 - 319
                326, 326, 326, 326, 326, 326, 326, 326,  // 320 - 327
                358, 358, 358, 358, 358, 358, 358, 358,  // 328 - 335
                358, 358, 358, 358, 358, 358, 358, 358,  // 336 - 343
                358, 358, 358, 358, 358, 358, 358, 358,  // 344 - 351
                358, 358, 358, 358, 358, 358, 358, 358,  // 352 - 359
                358, 358, 358, 358, 358, 358, 358, 358,  // 360 - 367
                358, 358, 358, 358, 358, 358, 358, 358,  // 368 - 375
                358, 358, 358, 358, 358, 358, 358, 358,  // 376 - 383
                358, 358, 358, 358, 358, 358, 358, 358,  // 384 - 391
                490, 490, 490, 490, 490, 490, 490, 490,  // 392 - 399
                490, 490, 490, 490, 490, 490, 490, 490,  // 400 - 407
                4113, 4113, 6161, 6161, 848, 848, 880, 880,  // 408 - 415
                912, 912, 944, 944, 622, 622, 622, 622,  // 416 - 423
                654, 654, 654, 654, 1104, 1104, 1136, 1136,  // 424 - 431
                1168, 1168, 1200, 1200, 1232, 1232, 1264, 1264,  // 432 - 439
                686, 686, 686, 686, 1360, 1360, 1392, 1392,  // 440 - 447
                12, 12, 12, 12, 12, 12, 12, 12,  // 448 - 455
                390, 390, 390, 390, 390, 390, 390, 390,  // 456 - 463
                390, 390, 390, 390, 390, 390, 390, 390,  // 464 - 471
                390, 390, 390, 390, 390, 390, 390, 390,  // 472 - 479
                390, 390, 390, 390, 390, 390, 390, 390,  // 480 - 487
                390, 390, 390, 390, 390, 390, 390, 390,  // 488 - 495
                390, 390, 390, 390, 390, 390, 390, 390,  // 496 - 503
                390, 390, 390, 390, 390, 390, 390, 390,  // 504 - 511
                390, 390, 390, 390, 390, 390, 390, 390, ] );
		
		internal static const table1: Vector.<int> = Vector.<int>([
			0x00, // 0 bits are left in first byte - SHOULD NOT HAPPEN
			0x01, // 1 bits are left in first byte
			0x03, // 2 bits are left in first byte
			0x07, // 3 bits are left in first byte
			0x0f, // 4 bits are left in first byte
			0x1f, // 5 bits are left in first byte
			0x3f, // 6 bits are left in first byte
			0x7f, // 7 bits are left in first byte
			0xff  // 8 bits are left in first byte
		]);
		
		internal static const table2: Vector.<int> = Vector.<int>([
			0x00, // 0
			0x80, // 1
			0xc0, // 2
			0xe0, // 3
			0xf0, // 4
			0xf8, // 5
			0xfc, // 6
			0xfe, // 7
			0xff  // 8
		]);

        internal static const twoDCodes: Vector.<int> = Vector.<int>( [  // 0 - 7
                80, 88, 23, 71, 30, 30, 62, 62,  // 8 - 15
                4, 4, 4, 4, 4, 4, 4, 4,  // 16 - 23
                11, 11, 11, 11, 11, 11, 11, 11,  // 24 - 31
                11, 11, 11, 11, 11, 11, 11, 11,  // 32 - 39
                35, 35, 35, 35, 35, 35, 35, 35,  // 40 - 47
                35, 35, 35, 35, 35, 35, 35, 35,  // 48 - 55
                51, 51, 51, 51, 51, 51, 51, 51,  // 56 - 63
                51, 51, 51, 51, 51, 51, 51, 51,  // 64 - 71
                41, 41, 41, 41, 41, 41, 41, 41,  // 72 - 79
                41, 41, 41, 41, 41, 41, 41, 41,  // 80 - 87
                41, 41, 41, 41, 41, 41, 41, 41,  // 88 - 95
                41, 41, 41, 41, 41, 41, 41, 41,  // 96 - 103
                41, 41, 41, 41, 41, 41, 41, 41,  // 104 - 111
                41, 41, 41, 41, 41, 41, 41, 41,  // 112 - 119
                41, 41, 41, 41, 41, 41, 41, 41,  // 120 - 127
                41, 41, 41, 41, 41, 41, 41, 41, ] );
		
		public static function reverseBits( b: Bytes ): void
		{
			for ( var k: int = 0; k < b.length; ++k )
				b[k] = flipTable[b[k] & 0xff];
		}

        /**
         * @param fillOrder   The fill order of the compressed data bytes.
         * @param w
         * @param h
         */
        public function TIFFFaxDecoder( fillOrder: int, w: int, h: int )
        {
            this.fillOrder = fillOrder;
            this.w = w;
            this.h = h;
            this.bitPointer = 0;
            this.bytePointer = 0;
            this.prevChangingElems = new Vector.<int>(w, true);
            this.currChangingElems = new Vector.<int>(w, true);
        }

        public function decode1D( buffer: Bytes, compData: Bytes, startX: int, height: int ): void
        {
			trace("TIFFFaxDecoder::decode1D");
            this.data = compData;
            var lineOffset: int = 0;
            var scanlineStride: int = ( w + 7 ) / 8;
            bitPointer = 0;
            bytePointer = 0;

            for ( var i: int = 0; i < height; i++ )
            {
                decodeNextScanline( buffer, lineOffset, startX );
                lineOffset += scanlineStride;
            }
        }

        public function decodeT6( buffer: Bytes, compData: Bytes, startX: int, height: int, tiffT6Options: Number ): void
        {
            this.data = compData;
            compression = 4;
            bitPointer = 0;
            bytePointer = 0;
            var scanlineStride: int = ( w + 7 ) / 8;
            var a0: int, a1: int, b1: int, b2: int;
            var entry: int, code: int, bits: int;
            var isWhite: Boolean;
            var currIndex: int;
            var temp: Vector.<int>;
            var b: Vector.<int> = new Vector.<int>( 2, true );
            uncompressedMode = ( ( tiffT6Options & 0x02 ) >> 1 );
            var cce: Vector.<int> = currChangingElems;
            changingElemSize = 0;
            cce[changingElemSize++] = w;
            cce[changingElemSize++] = w;
            var lineOffset: int = 0;
            var bitOffset: int;

            for ( var lines: int = 0; lines < height; lines++ )
            {
                a0 = -1;
                isWhite = true;
                temp = prevChangingElems;
                prevChangingElems = currChangingElems;
                cce = currChangingElems = temp;
                currIndex = 0;
                bitOffset = startX;
                lastChangingElement = 0;

                while ( bitOffset < w )
                {
                    getNextChangingElement( a0, isWhite, b );
                    b1 = b[0];
                    b2 = b[1];
                    entry = nextLesserThan8Bits( 7 );
                    entry = twoDCodes[entry] & 0xff;
                    code = ( entry & 0x78 ) >>> 3;
                    bits = entry & 0x07;

                    if ( code == 0 )
                    { // Pass
                        if ( !isWhite )
                        {
                            setToBlack( buffer, lineOffset, bitOffset, b2 - bitOffset );
                        }
                        bitOffset = a0 = b2;
                        updatePointer( 7 - bits );
                    } else if ( code == 1 )
                    { // Horizontal
                        updatePointer( 7 - bits );
                        var number: int;

                        if ( isWhite )
                        {
                            number = decodeWhiteCodeWord();
                            bitOffset += number;
                            cce[currIndex++] = bitOffset;
                            number = decodeBlackCodeWord();
                            setToBlack( buffer, lineOffset, bitOffset, number );
                            bitOffset += number;
                            cce[currIndex++] = bitOffset;
                        } else
                        {
                            number = decodeBlackCodeWord();
                            setToBlack( buffer, lineOffset, bitOffset, number );
                            bitOffset += number;
                            cce[currIndex++] = bitOffset;
                            number = decodeWhiteCodeWord();
                            bitOffset += number;
                            cce[currIndex++] = bitOffset;
                        }
                        a0 = bitOffset;
                    } else if ( code <= 8 )
                    { // Vertical
                        a1 = b1 + ( code - 5 );
                        cce[currIndex++] = a1;

                        if ( !isWhite )
                        {
                            setToBlack( buffer, lineOffset, bitOffset, a1 - bitOffset );
                        }
                        bitOffset = a0 = a1;
                        isWhite = !isWhite;
                        updatePointer( 7 - bits );
                    } else if ( code == 11 )
                    {
                        if ( nextLesserThan8Bits( 3 ) != 7 )
                        {
                            throw new RuntimeError( "invalid code encountered while decoding 2d group 4 compressed data" );
                        }
                        var zeros: int = 0;
                        var exit: Boolean = false;

                        while ( !exit )
                        {
                            while ( nextLesserThan8Bits( 1 ) != 1 )
                            {
                                zeros++;
                            }

                            if ( zeros > 5 )
                            {
                                zeros = zeros - 6;

                                if ( !isWhite && ( zeros > 0 ) )
                                {
                                    cce[currIndex++] = bitOffset;
                                }
                                bitOffset += zeros;

                                if ( zeros > 0 )
                                {
                                    isWhite = true;
                                }

                                if ( nextLesserThan8Bits( 1 ) == 0 )
                                {
                                    if ( !isWhite )
                                    {
                                        cce[currIndex++] = bitOffset;
                                    }
                                    isWhite = true;
                                } else
                                {
                                    if ( isWhite )
                                    {
                                        cce[currIndex++] = bitOffset;
                                    }
                                    isWhite = false;
                                }
                                exit = true;
                            }

                            if ( zeros == 5 )
                            {
                                if ( !isWhite )
                                {
                                    cce[currIndex++] = bitOffset;
                                }
                                bitOffset += zeros;
                                isWhite = true;
                            } else
                            {
                                bitOffset += zeros;
                                cce[currIndex++] = bitOffset;
                                setToBlack( buffer, lineOffset, bitOffset, 1 );
                                ++bitOffset;
                                isWhite = false;
                            }
                        }
                    } else
                    {
                        bitOffset = w;
                        updatePointer( 7 - bits );
                    }
                }

                if ( currIndex < cce.length )
                    cce[currIndex++] = bitOffset;
                changingElemSize = currIndex;
                lineOffset += scanlineStride;
            }
        }

        public function decodeNextScanline( buffer: Bytes, lineOffset: int, bitOffset: int ): void
        {
            var bits: int = 0, code: int = 0, isT: int = 0;
            var current: int, entry: int, twoBits: int;
            var isWhite: Boolean = true;
            changingElemSize = 0;

            while ( bitOffset < w )
            {
                while ( isWhite )
                {
                    // White run
                    current = nextNBits( 10 );
                    entry = white[current];
                    // Get the 3 fields from the entry
                    isT = entry & 0x0001;
                    bits = ( entry >>> 1 ) & 0x0f;

                    if ( bits == 12 )
                    { // Additional Make up code
                        // Get the next 2 bits
                        twoBits = nextLesserThan8Bits( 2 );
                        // Consolidate the 2 new bits and last 2 bits into 4 bits
                        current = ( ( current << 2 ) & 0x000c ) | twoBits;
                        entry = additionalMakeup[current];
                        bits = ( entry >>> 1 ) & 0x07; // 3 bits 0000 0111
                        code = ( entry >>> 4 ) & 0x0fff; // 12 bits
                        bitOffset += code; // Skip white run
                        updatePointer( 4 - bits );
                    } else if ( bits == 0 )
                    { // ERROR
                        throw new RuntimeError( "invalid code encountered" );
                    } else if ( bits == 15 )
                    { // EOL
                        throw new RuntimeError( "EOL code word encountered in white run" );
                    } else
                    {
                        // 11 bits - 0000 0111 1111 1111 = 0x07ff
                        code = ( entry >>> 5 ) & 0x07ff;
                        bitOffset += code;
                        updatePointer( 10 - bits );

                        if ( isT == 0 )
                        {
                            isWhite = false;
                            currChangingElems[changingElemSize++] = bitOffset;
                        }
                    }
                }

                // Check whether this run completed one width, if so
                // advance to next byte boundary for compression = 2.
                if ( bitOffset == w )
                {
                    if ( compression == 2 )
                    {
                        advancePointer();
                    }
                    break;
                }

                while ( !isWhite )
                {
                    // Black run
                    current = nextLesserThan8Bits( 4 );
                    entry = initBlack[current];
                    // Get the 3 fields from the entry
                    isT = entry & 0x0001;
                    bits = ( entry >>> 1 ) & 0x000f;
                    code = ( entry >>> 5 ) & 0x07ff;

                    if ( code == 100 )
                    {
                        current = nextNBits( 9 );
                        entry = black[current];
                        // Get the 3 fields from the entry
                        isT = entry & 0x0001;
                        bits = ( entry >>> 1 ) & 0x000f;
                        code = ( entry >>> 5 ) & 0x07ff;

                        if ( bits == 12 )
                        {
                            // Additional makeup codes
                            updatePointer( 5 );
                            current = nextLesserThan8Bits( 4 );
                            entry = additionalMakeup[current];
                            bits = ( entry >>> 1 ) & 0x07; // 3 bits 0000 0111
                            code = ( entry >>> 4 ) & 0x0fff; // 12 bits
                            setToBlack( buffer, lineOffset, bitOffset, code );
                            bitOffset += code;
                            updatePointer( 4 - bits );
                        } else if ( bits == 15 )
                        {
                            // EOL code
                            throw new RuntimeError( "EOL code word encountered in black run" );
                        } else
                        {
                            setToBlack( buffer, lineOffset, bitOffset, code );
                            bitOffset += code;
                            updatePointer( 9 - bits );

                            if ( isT == 0 )
                            {
                                isWhite = true;
                                currChangingElems[changingElemSize++] = bitOffset;
                            }
                        }
                    } else if ( code == 200 )
                    {
                        // Is a Terminating code
                        current = nextLesserThan8Bits( 2 );
                        entry = twoBitBlack[current];
                        code = ( entry >>> 5 ) & 0x07ff;
                        bits = ( entry >>> 1 ) & 0x0f;
                        setToBlack( buffer, lineOffset, bitOffset, code );
                        bitOffset += code;
                        updatePointer( 2 - bits );
                        isWhite = true;
                        currChangingElems[changingElemSize++] = bitOffset;
                    } else
                    {
                        // Is a Terminating code
                        setToBlack( buffer, lineOffset, bitOffset, code );
                        bitOffset += code;
                        updatePointer( 4 - bits );
                        isWhite = true;
                        currChangingElems[changingElemSize++] = bitOffset;
                    }
                }

                // Check whether this run completed one width
                if ( bitOffset == w )
                {
                    if ( compression == 2 )
                    {
                        advancePointer();
                    }
                    break;
                }
            }
            currChangingElems[changingElemSize++] = bitOffset;
        }

        private function nextNBits( bitsToGet: int ): int
        {
            var b: int, next: int, next2next: int;
            var l: int = data.length - 1;
            var bp: int = this.bytePointer;

            if ( fillOrder == 1 )
            {
                b = data[bp];

                if ( bp == l )
                {
                    next = 0x00;
                    next2next = 0x00;
                } else if ( ( bp + 1 ) == l )
                {
                    next = data[bp + 1];
                    next2next = 0x00;
                } else
                {
                    next = data[bp + 1];
                    next2next = data[bp + 2];
                }
            } else if ( fillOrder == 2 )
            {
                b = flipTable[data[bp] & 0xff];

                if ( bp == l )
                {
                    next = 0x00;
                    next2next = 0x00;
                } else if ( ( bp + 1 ) == l )
                {
                    next = flipTable[data[bp + 1] & 0xff];
                    next2next = 0x00;
                } else
                {
                    next = flipTable[data[bp + 1] & 0xff];
                    next2next = flipTable[data[bp + 2] & 0xff];
                }
            } else
            {
                throw new RuntimeError( "tiff fill order tag must be either 1 or 2" );
            }
            var bitsLeft: int = 8 - bitPointer;
            var bitsFromNextByte: int = bitsToGet - bitsLeft;
            var bitsFromNext2NextByte: int = 0;

            if ( bitsFromNextByte > 8 )
            {
                bitsFromNext2NextByte = bitsFromNextByte - 8;
                bitsFromNextByte = 8;
            }
            bytePointer++;
            var i1: int = ( b & table1[bitsLeft] ) << ( bitsToGet - bitsLeft );
            var i2: int = ( next & table2[bitsFromNextByte] ) >>> ( 8 - bitsFromNextByte );
            var i3: int = 0;

            if ( bitsFromNext2NextByte != 0 )
            {
                i2 <<= bitsFromNext2NextByte;
                i3 = ( next2next & table2[bitsFromNext2NextByte] ) >>> ( 8 - bitsFromNext2NextByte );
                i2 |= i3;
                bytePointer++;
                bitPointer = bitsFromNext2NextByte;
            } else
            {
                if ( bitsFromNextByte == 8 )
                {
                    bitPointer = 0;
                    bytePointer++;
                } else
                {
                    bitPointer = bitsFromNextByte;
                }
            }
            var i: int = i1 | i2;
            return i;
        }

        private function nextLesserThan8Bits( bitsToGet: int ): int
        {
            var b: int, next: int;
            var l: int = data.length - 1;
            var bp: int = this.bytePointer;

            if ( fillOrder == 1 )
            {
                b = data[bp];

                if ( bp == l )
                {
                    next = 0x00;
                } else
                {
                    next = data[bp + 1];
                }
            } else if ( fillOrder == 2 )
            {
                b = flipTable[data[bp] & 0xff];

                if ( bp == l )
                {
                    next = 0x00;
                } else
                {
                    next = flipTable[data[bp + 1] & 0xff];
                }
            } else
            {
                throw new RuntimeError( "tiff fill order tag must be either 1 or 2" );
            }
            var bitsLeft: int = 8 - bitPointer;
            var bitsFromNextByte: int = bitsToGet - bitsLeft;
            var shift: int = bitsLeft - bitsToGet;
            var i1: int, i2: int;

            if ( shift >= 0 )
            {
                i1 = ( b & table1[bitsLeft] ) >>> shift;
                bitPointer += bitsToGet;

                if ( bitPointer == 8 )
                {
                    bitPointer = 0;
                    bytePointer++;
                }
            } else
            {
                i1 = ( b & table1[bitsLeft] ) << ( -shift );
                i2 = ( next & table2[bitsFromNextByte] ) >>> ( 8 - bitsFromNextByte );
                i1 |= i2;
                bytePointer++;
                bitPointer = bitsFromNextByte;
            }
            return i1;
        }

        private function updatePointer( bitsToMoveBack: int ): void
        {
            const i: int = bitPointer - bitsToMoveBack;

            if ( i < 0 )
            {
                bytePointer--;
                bitPointer = 8 + i;
            } else
            {
                bitPointer = i;
            }
        }

        private function advancePointer(): Boolean
        {
            if ( bitPointer != 0 )
            {
                bytePointer++;
                bitPointer = 0;
            }
            return true;
        }

        private function setToBlack( buffer: Bytes, lineOffset: int, bitOffset: int, numBits: int ): void
        {
            var bitNum: int = 8 * lineOffset + bitOffset;
            var lastBit: int = bitNum + numBits;
            var byteNum: int = bitNum >> 3;
            var shift: int = bitNum & 0x7;

            if ( shift > 0 )
            {
                var maskVal: int = 1 << ( 7 - shift );
                var val: int = buffer[byteNum];

                while ( maskVal > 0 && bitNum < lastBit )
                {
                    val |= maskVal;
                    maskVal >>= 1;
                    ++bitNum;
                }
                buffer[byteNum] = val;
            }
            byteNum = bitNum >> 3;

            while ( bitNum < lastBit - 7 )
            {
                buffer[byteNum++] = ByteBuffer.intToByte( 255 );
                bitNum += 8;
            }

            while ( bitNum < lastBit )
            {
                byteNum = bitNum >> 3;
                buffer[byteNum] |= 1 << ( 7 - ( bitNum & 0x7 ) );
                ++bitNum;
            }
        }

        private function getNextChangingElement( a0: int, isWhite: Boolean, ret: Vector.<int> ): void
        {
            var pce: Vector.<int> = this.prevChangingElems;
            var ces: int = this.changingElemSize;
            var start: int = lastChangingElement > 0 ? lastChangingElement - 1 : 0;

            if ( isWhite )
            {
                start &= ~0x1; // Search even numbered elements
            } else
            {
                start |= 0x1; // Search odd numbered elements
            }
            var i: int = start;

            for ( ; i < ces; i += 2 )
            {
                var temp: int = pce[i];

                if ( temp > a0 )
                {
                    lastChangingElement = i;
                    ret[0] = temp;
                    break;
                }
            }

            if ( i + 1 < ces )
            {
                ret[1] = pce[i + 1];
            }
        }

        private function decodeWhiteCodeWord(): int
        {
            var current: int, entry: int, bits: int, isT: int, twoBits: int;
            var code: int = -1;
            var runLength: int = 0;
            var isWhite: Boolean = true;

            while ( isWhite )
            {
                current = nextNBits( 10 );
                entry = white[current];
                isT = entry & 0x0001;
                bits = ( entry >>> 1 ) & 0x0f;

                if ( bits == 12 )
                { // Additional Make up code
                    twoBits = nextLesserThan8Bits( 2 );
                    current = ( ( current << 2 ) & 0x000c ) | twoBits;
                    entry = additionalMakeup[current];
                    bits = ( entry >>> 1 ) & 0x07; // 3 bits 0000 0111
                    code = ( entry >>> 4 ) & 0x0fff; // 12 bits
                    runLength += code;
                    updatePointer( 4 - bits );
                } else if ( bits == 0 )
                { // ERROR
                    throw new RuntimeError( "invalid code encountered" );
                } else if ( bits == 15 )
                { // EOL
                    throw new RuntimeError( "EOL code word encountered in white run" );
                } else
                {
                    code = ( entry >>> 5 ) & 0x07ff;
                    runLength += code;
                    updatePointer( 10 - bits );

                    if ( isT == 0 )
                    {
                        isWhite = false;
                    }
                }
            }
            return runLength;
        }

        private function decodeBlackCodeWord(): int
        {
            var current: int, entry: int, bits: int, isT: int;
            var code: int = -1;
            var runLength: int = 0;
            var isWhite: Boolean = false;

            while ( !isWhite )
            {
                current = nextLesserThan8Bits( 4 );
                entry = initBlack[current];
                isT = entry & 0x0001;
                bits = ( entry >>> 1 ) & 0x000f;
                code = ( entry >>> 5 ) & 0x07ff;

                if ( code == 100 )
                {
                    current = nextNBits( 9 );
                    entry = black[current];
                    isT = entry & 0x0001;
                    bits = ( entry >>> 1 ) & 0x000f;
                    code = ( entry >>> 5 ) & 0x07ff;

                    if ( bits == 12 )
                    {
                        updatePointer( 5 );
                        current = nextLesserThan8Bits( 4 );
                        entry = additionalMakeup[current];
                        bits = ( entry >>> 1 ) & 0x07; // 3 bits 0000 0111
                        code = ( entry >>> 4 ) & 0x0fff; // 12 bits
                        runLength += code;
                        updatePointer( 4 - bits );
                    } else if ( bits == 15 )
                    {
                        // EOL code
                        throw new RuntimeError( "EOL code word encountered in black run" );
                    } else
                    {
                        runLength += code;
                        updatePointer( 9 - bits );

                        if ( isT == 0 )
                        {
                            isWhite = true;
                        }
                    }
                } else if ( code == 200 )
                {
                    current = nextLesserThan8Bits( 2 );
                    entry = twoBitBlack[current];
                    code = ( entry >>> 5 ) & 0x07ff;
                    runLength += code;
                    bits = ( entry >>> 1 ) & 0x0f;
                    updatePointer( 2 - bits );
                    isWhite = true;
                } else
                {
                    // Is a Terminating code
                    runLength += code;
                    updatePointer( 4 - bits );
                    isWhite = true;
                }
            }
            return runLength;
        }
	}
}