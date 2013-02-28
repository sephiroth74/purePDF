/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: CCITTG4Encoder.as 238 2010-01-31 10:49:33Z alessandro.crugnola $
* $Author Alessandro Crugnola $
* $Rev: 238 $ $LastChangedDate: 2010-01-31 11:49:33 +0100 (Sun, 31 Jan 2010) $
* $URL: https://purepdf.googlecode.com/svn/trunk/src/org/purepdf/pdf/codec/CCITTG4Encoder.as $
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
package org.purepdf.codecs
{
    public class TIFFConstants
    {
        public static const CLEANFAXDATA_CLEAN: int = 0; /* no errors detected */
        public static const CLEANFAXDATA_REGENERATED: int = 1; /* receiver regenerated lines */
        public static const CLEANFAXDATA_UNCLEAN: int = 2; /* uncorrected errors exist */
        public static const COLORRESPONSEUNIT_100000S: int = 5; /* hundred-thousandths */
        public static const COLORRESPONSEUNIT_10000S: int = 4; /* ten-thousandths of a unit */
        public static const COLORRESPONSEUNIT_1000S: int = 3; /* thousandths of a unit */
        public static const COLORRESPONSEUNIT_100S: int = 2; /* hundredths of a unit */
        public static const COLORRESPONSEUNIT_10S: int = 1; /* tenths of a unit */
        public static const COMPRESSION_ADOBE_DEFLATE: int = 8; /* Deflate compression, as recognized by Adobe */
        public static const COMPRESSION_CCITTFAX3: int = 3; /* CCITT Group 3 fax encoding */
        public static const COMPRESSION_CCITTFAX4: int = 4; /* CCITT Group 4 fax encoding */
        public static const COMPRESSION_CCITTRLE: int = 2; /* CCITT modified Huffman RLE */
        public static const COMPRESSION_CCITTRLEW: int = 32771; /* #1 w/ word alignment */
        /* compression code 32947 is reserved for Oceana Matrix <dev@oceana.com> */
        public static const COMPRESSION_DCS: int = 32947; /* Kodak DCS encoding */
        public static const COMPRESSION_DEFLATE: int = 32946; /* Deflate compression */
        public static const COMPRESSION_IT8BL: int = 32898; /* IT8 Binary line art */
        /* codes 32895-32898 are reserved for ANSI IT8 TIFF/IT <dkelly@etsinc.com) */
        public static const COMPRESSION_IT8CTPAD: int = 32895; /* IT8 CT w/padding */
        public static const COMPRESSION_IT8LW: int = 32896; /* IT8 Linework RLE */
        public static const COMPRESSION_IT8MP: int = 32897; /* IT8 Monochrome picture */
        public static const COMPRESSION_JBIG: int = 34661; /* ISO JBIG */
        public static const COMPRESSION_JPEG: int = 7; /* %JPEG DCT compression */
        public static const COMPRESSION_LZW: int = 5; /* Lempel-Ziv  & Welch */
        public static const COMPRESSION_NEXT: int = 32766; /* NeXT 2-bit RLE */
        public static const COMPRESSION_NONE: int = 1; /* dump mode */
        public static const COMPRESSION_OJPEG: int = 6; /* !6.0 JPEG */
        public static const COMPRESSION_PACKBITS: int = 32773; /* Macintosh RLE */
        /* compression codes 32908-32911 are reserved for Pixar */
        public static const COMPRESSION_PIXARFILM: int = 32908; /* Pixar companded 10bit LZW */
        public static const COMPRESSION_PIXARLOG: int = 32909; /* Pixar companded 11bit ZIP */
        public static const COMPRESSION_SGILOG: int = 34676; /* SGI Log Luminance RLE */
        public static const COMPRESSION_SGILOG24: int = 34677; /* SGI Log 24-bit packed */
        public static const COMPRESSION_THUNDERSCAN: int = 32809; /* ThunderScan RLE */
        public static const EXTRASAMPLE_ASSOCALPHA: int = 1; /* !associated alpha data */
        public static const EXTRASAMPLE_UNASSALPHA: int = 2; /* !unassociated alpha data */
        public static const EXTRASAMPLE_UNSPECIFIED: int = 0; /* !unspecified data */
        public static const FILETYPE_MASK: int = 0x4; /* transparency mask */
        public static const FILETYPE_PAGE: int = 0x2; /* one page of many */
        public static const FILETYPE_REDUCEDIMAGE: int = 0x1; /* reduced resolution version */
        public static const FILLORDER_LSB2MSB: int = 2; /* least significant -> most */
        public static const FILLORDER_MSB2LSB: int = 1; /* most significant -> least */
        public static const GRAYRESPONSEUNIT_100000S: int = 5; /* hundred-thousandths */
        public static const GRAYRESPONSEUNIT_10000S: int = 4; /* ten-thousandths of a unit */
        public static const GRAYRESPONSEUNIT_1000S: int = 3; /* thousandths of a unit */
        public static const GRAYRESPONSEUNIT_100S: int = 2; /* hundredths of a unit */
        public static const GRAYRESPONSEUNIT_10S: int = 1; /* tenths of a unit */
        public static const GROUP3OPT_2DENCODING: int = 0x1; /* 2-dimensional coding */
        public static const GROUP3OPT_FILLBITS: int = 0x4; /* fill to byte boundary */
        public static const GROUP3OPT_UNCOMPRESSED: int = 0x2; /* data not compressed */
        public static const GROUP4OPT_UNCOMPRESSED: int = 0x2; /* data not compressed */
        public static const INKSET_CMYK: int = 1; /* !cyan-magenta-yellow-black */
        public static const JPEGPROC_BASELINE: int = 1; /* !baseline sequential */
        public static const JPEGPROC_LOSSLESS: int = 14; /* !Huffman coded lossless */
        public static const OFILETYPE_IMAGE: int = 1; /* full resolution image data */
        public static const OFILETYPE_PAGE: int = 3; /* one page of many */
        public static const OFILETYPE_REDUCEDIMAGE: int = 2; /* reduced size image data */
        public static const ORIENTATION_BOTLEFT: int = 4; /* row 0 bottom, col 0 lhs */
        public static const ORIENTATION_BOTRIGHT: int = 3; /* row 0 bottom, col 0 rhs */
        public static const ORIENTATION_LEFTBOT: int = 8; /* row 0 lhs, col 0 bottom */
        public static const ORIENTATION_LEFTTOP: int = 5; /* row 0 lhs, col 0 top */
        public static const ORIENTATION_RIGHTBOT: int = 7; /* row 0 rhs, col 0 bottom */
        public static const ORIENTATION_RIGHTTOP: int = 6; /* row 0 rhs, col 0 top */
        public static const ORIENTATION_TOPLEFT: int = 1; /* row 0 top, col 0 lhs */
        public static const ORIENTATION_TOPRIGHT: int = 2; /* row 0 top, col 0 rhs */
        public static const PHOTOMETRIC_CIELAB: int = 8; /* !1976 CIE L*a*b* */
        public static const PHOTOMETRIC_LOGL: int = 32844; /* CIE Log2(L) */
        public static const PHOTOMETRIC_LOGLUV: int = 32845; /* CIE Log2(L) (u',v') */
        public static const PHOTOMETRIC_MASK: int = 4; /* $holdout mask */
        public static const PHOTOMETRIC_MINISBLACK: int = 1; /* min value is black */
        public static const PHOTOMETRIC_MINISWHITE: int = 0; /* min value is white */
        public static const PHOTOMETRIC_PALETTE: int = 3; /* color map indexed */
        public static const PHOTOMETRIC_RGB: int = 2; /* RGB color model */
        public static const PHOTOMETRIC_SEPARATED: int = 5; /* !color separations */
        public static const PHOTOMETRIC_YCBCR: int = 6; /* !CCIR 601 */
        public static const PLANARCONFIG_CONTIG: int = 1; /* single image plane */
        public static const PLANARCONFIG_SEPARATE: int = 2; /* separate planes of data */
        public static const RESUNIT_CENTIMETER: int = 3; /* metric */
        public static const RESUNIT_INCH: int = 2; /* english */
        public static const RESUNIT_NONE: int = 1; /* no meaningful units */
        public static const SAMPLEFORMAT_COMPLEXIEEEFP: int = 6; /* !complex ieee floating */
        public static const SAMPLEFORMAT_COMPLEXINT: int = 5; /* !complex signed int */
        public static const SAMPLEFORMAT_IEEEFP: int = 3; /* !IEEE floating point data */
        public static const SAMPLEFORMAT_INT: int = 2; /* !signed integer data */
        public static const SAMPLEFORMAT_UINT: int = 1; /* !unsigned integer data */
        public static const SAMPLEFORMAT_VOID: int = 4; /* !untyped data */
        public static const THRESHHOLD_BILEVEL: int = 1; /* b&w art scan */
        public static const THRESHHOLD_ERRORDIFFUSE: int = 3; /* usually floyd-steinberg */
        public static const THRESHHOLD_HALFTONE: int = 2; /* or dithered scan */
        public static const TIFFTAG_ARTIST: int = 315; /* creator of image */
        public static const TIFFTAG_BADFAXLINES: int = 326; /* lines w/ wrong pixel count */
        public static const TIFFTAG_BITSPERSAMPLE: int = 258; /* bits per channel (sample) */
        public static const TIFFTAG_CELLLENGTH: int = 265; /* +dithering matrix height */
        public static const TIFFTAG_CELLWIDTH: int = 264; /* +dithering matrix width */
        public static const TIFFTAG_CLEANFAXDATA: int = 327; /* regenerated line info */
        public static const TIFFTAG_COLORMAP: int = 320; /* RGB map for pallette image */
        public static const TIFFTAG_COLORRESPONSEUNIT: int = 300; /* $color curve accuracy */
        public static const TIFFTAG_COMPRESSION: int = 259; /* data compression technique */
        public static const TIFFTAG_CONSECUTIVEBADFAXLINES: int = 328; /* max consecutive bad lines */
        /* tag 33432 is listed in the 6.0 spec w/ unknown ownership */
        public static const TIFFTAG_COPYRIGHT: int = 33432; /* copyright string */
        public static const TIFFTAG_DATATYPE: int = 32996; /* $use SampleFormat */
        public static const TIFFTAG_DATETIME: int = 306; /* creation date and time */
        /* tag 65535 is an undefined tag used by Eastman Kodak */
        public static const TIFFTAG_DCSHUESHIFTVALUES: int = 65535; /* hue shift correction data */
        public static const TIFFTAG_DOCUMENTNAME: int = 269; /* name of doc. image is from */
        public static const TIFFTAG_DOTRANGE: int = 336; /* !0% and 100% dot codes */
        public static const TIFFTAG_EXTRASAMPLES: int = 338; /* !info about extra samples */
        /* tags 34908-34914 are private tags registered to SGI */
        public static const TIFFTAG_FAXRECVPARAMS: int = 34908; /* encoded Class 2 ses. parms */
        public static const TIFFTAG_FAXRECVTIME: int = 34910; /* receive time (secs) */
        public static const TIFFTAG_FAXSUBADDRESS: int = 34909; /* received SubAddr string */
        /* tag 34929 is a private tag registered to FedEx */
        public static const TIFFTAG_FEDEX_EDR: int = 34929; /* unknown use */
        public static const TIFFTAG_FILLORDER: int = 266; /* data order within a byte */
        /* tags 34232-34236 are private tags registered to Texas Instruments */
        public static const TIFFTAG_FRAMECOUNT: int = 34232; /* Sequence Frame Count */
        public static const TIFFTAG_FREEBYTECOUNTS: int = 289; /* +sizes of free blocks */
        public static const TIFFTAG_FREEOFFSETS: int = 288; /* +byte offset to free block */
        public static const TIFFTAG_GRAYRESPONSECURVE: int = 291; /* $gray scale response curve */
        public static const TIFFTAG_GRAYRESPONSEUNIT: int = 290; /* $gray scale curve accuracy */
        public static const TIFFTAG_GROUP3OPTIONS: int = 292; /* 32 flag bits */
        public static const TIFFTAG_GROUP4OPTIONS: int = 293; /* 32 flag bits */
        public static const TIFFTAG_HALFTONEHINTS: int = 321; /* !highlight+shadow info */
        public static const TIFFTAG_HOSTCOMPUTER: int = 316; /* machine where created */
        /* tag 34750 is a private tag registered to Adobe? */
        public static const TIFFTAG_ICCPROFILE: int = 34675; /* ICC profile data */
        public static const TIFFTAG_IMAGEDEPTH: int = 32997; /* z depth of image */
        public static const TIFFTAG_IMAGEDESCRIPTION: int = 270; /* info about image */
        public static const TIFFTAG_IMAGELENGTH: int = 257; /* image height in pixels */
        public static const TIFFTAG_IMAGEWIDTH: int = 256; /* image width in pixels */
        public static const TIFFTAG_INKNAMES: int = 333; /* !ascii names of inks */
        public static const TIFFTAG_INKSET: int = 332; /* !inks in separated image */
        public static const TIFFTAG_IT8BITSPEREXTENDEDRUNLENGTH: int = 34021; /* # of bits in long run */
        public static const TIFFTAG_IT8BITSPERRUNLENGTH: int = 34020; /* # of bits in short run */
        public static const TIFFTAG_IT8BKGCOLORINDICATOR: int = 34024; /* BP/BL bg color switch */
        public static const TIFFTAG_IT8BKGCOLORVALUE: int = 34026; /* BP/BL bg color value */
        public static const TIFFTAG_IT8COLORCHARACTERIZATION: int = 34029; /* color character. table */
        public static const TIFFTAG_IT8COLORSEQUENCE: int = 34017; /* color seq. [RGB,CMYK,etc] */
        public static const TIFFTAG_IT8COLORTABLE: int = 34022; /* LW colortable */
        public static const TIFFTAG_IT8HEADER: int = 34018; /* DDES Header */
        public static const TIFFTAG_IT8IMAGECOLORINDICATOR: int = 34023; /* BP/BL image color switch */
        public static const TIFFTAG_IT8IMAGECOLORVALUE: int = 34025; /* BP/BL image color value */
        public static const TIFFTAG_IT8PIXELINTENSITYRANGE: int = 34027; /* MP pixel intensity value */
        public static const TIFFTAG_IT8RASTERPADDING: int = 34019; /* raster scanline padding */
        /* 34016-34029 are reserved for ANSI IT8 TIFF/IT <dkelly@etsinc.com) */
        public static const TIFFTAG_IT8SITE: int = 34016; /* site name */
        public static const TIFFTAG_IT8TRANSPARENCYINDICATOR: int = 34028; /* HC transparency switch */
        /* tag 34750 is a private tag registered to Pixel Magic */
        public static const TIFFTAG_JBIGOPTIONS: int = 34750; /* JBIG options */
        public static const TIFFTAG_JPEGACTABLES: int = 521; /* !AC coefficient offsets */
        public static const TIFFTAG_JPEGDCTABLES: int = 520; /* !DCT table offsets */
        public static const TIFFTAG_JPEGIFBYTECOUNT: int = 514; /* !JFIF stream length */
        public static const TIFFTAG_JPEGIFOFFSET: int = 513; /* !pointer to SOI marker */
        public static const TIFFTAG_JPEGLOSSLESSPREDICTORS: int = 517; /* !lossless proc predictor */
        public static const TIFFTAG_JPEGPOINTTRANSFORM: int = 518; /* !lossless point transform */
        /*
        * Tags 512-521 are obsoleted by Technical Note #2
        * which specifies a revised JPEG-in-TIFF scheme.
        */
        public static const TIFFTAG_JPEGPROC: int = 512; /* !JPEG processing algorithm */
        public static const TIFFTAG_JPEGQTABLES: int = 519; /* !Q matrice offsets */
        public static const TIFFTAG_JPEGRESTARTINTERVAL: int = 515; /* !restart interval length */
        public static const TIFFTAG_JPEGTABLES: int = 347; /* %JPEG table stream */
        public static const TIFFTAG_MAKE: int = 271; /* scanner manufacturer name */
        /* tags 32995-32999 are private tags registered to SGI */
        public static const TIFFTAG_MATTEING: int = 32995; /* $use ExtraSamples */
        public static const TIFFTAG_MAXSAMPLEVALUE: int = 281; /* +maximum sample value */
        public static const TIFFTAG_MINSAMPLEVALUE: int = 280; /* +minimum sample value */
        public static const TIFFTAG_MODEL: int = 272; /* scanner model name/number */
        public static const TIFFTAG_NUMBEROFINKS: int = 334; /* !number of inks */
        public static const TIFFTAG_ORIENTATION: int = 274; /* +image orientation */
        public static const TIFFTAG_OSUBFILETYPE: int = 255; /* +kind of data in subfile */
        public static const TIFFTAG_PAGENAME: int = 285; /* page name image is from */
        public static const TIFFTAG_PAGENUMBER: int = 297; /* page numbers of multi-page */
        public static const TIFFTAG_PHOTOMETRIC: int = 262; /* photometric interpretation */
        /* tag 34377 is private tag registered to Adobe for PhotoShop */
        public static const TIFFTAG_PHOTOSHOP: int = 34377;
        public static const TIFFTAG_PIXAR_FOVCOT: int = 33304; /* cotan(fov) for env. maps */
        public static const TIFFTAG_PIXAR_IMAGEFULLLENGTH: int = 33301; /* full image size in y */
        /* tags 33300-33309 are private tags registered to Pixar */
        /*
        * TIFFTAG_PIXAR_IMAGEFULLWIDTH and TIFFTAG_PIXAR_IMAGEFULLLENGTH
        * are set when an image has been cropped out of a larger image.
        * They reflect the size of the original uncropped image.
        * The TIFFTAG_XPOSITION and TIFFTAG_YPOSITION can be used
        * to determine the position of the smaller image in the larger one.
        */
        public static const TIFFTAG_PIXAR_IMAGEFULLWIDTH: int = 33300; /* full image size in x */
        public static const TIFFTAG_PIXAR_MATRIX_WORLDTOCAMERA: int = 33306;
        public static const TIFFTAG_PIXAR_MATRIX_WORLDTOSCREEN: int = 33305;
        /* Tags 33302-33306 are used to identify special image modes and data
        * used by Pixar's texture formats.
        */
        public static const TIFFTAG_PIXAR_TEXTUREFORMAT: int = 33302; /* texture map format */
        public static const TIFFTAG_PIXAR_WRAPMODES: int = 33303; /* s & t wrap modes */
        public static const TIFFTAG_PLANARCONFIG: int = 284; /* storage organization */
        public static const TIFFTAG_PREDICTOR: int = 317; /* prediction scheme w/ LZW */
        public static const TIFFTAG_PRIMARYCHROMATICITIES: int = 319; /* !primary chromaticities */
        public static const TIFFTAG_REFERENCEBLACKWHITE: int = 532; /* !colorimetry info */
        /* tags 32952-32956 are private tags registered to Island Graphics */
        public static const TIFFTAG_REFPTS: int = 32953; /* image reference points */
        public static const TIFFTAG_REGIONAFFINE: int = 32956; /* affine transformation mat */
        public static const TIFFTAG_REGIONTACKPOINT: int = 32954; /* region-xform tack point */
        public static const TIFFTAG_REGIONWARPCORNERS: int = 32955; /* warp quadrilateral */
        public static const TIFFTAG_RESOLUTIONUNIT: int = 296; /* units of resolutions */
        /* IPTC TAG from RichTIFF specifications */
        public static const TIFFTAG_RICHTIFFIPTC: int = 33723;
        public static const TIFFTAG_ROWSPERSTRIP: int = 278; /* rows per strip of data */
        public static const TIFFTAG_SAMPLEFORMAT: int = 339; /* !data sample format */
        public static const TIFFTAG_SAMPLESPERPIXEL: int = 277; /* samples per pixel */
        public static const TIFFTAG_SMAXSAMPLEVALUE: int = 341; /* !variable MaxSampleValue */
        public static const TIFFTAG_SMINSAMPLEVALUE: int = 340; /* !variable MinSampleValue */
        public static const TIFFTAG_SOFTWARE: int = 305; /* name & release */
        /* tags 37439-37443 are registered to SGI <gregl@sgi.com> */
        public static const TIFFTAG_STONITS: int = 37439; /* Sample value to Nits */
        public static const TIFFTAG_STRIPBYTECOUNTS: int = 279; /* bytes counts for strips */
        public static const TIFFTAG_STRIPOFFSETS: int = 273; /* offsets to data strips */
        public static const TIFFTAG_SUBFILETYPE: int = 254; /* subfile data descriptor */
        public static const TIFFTAG_SUBIFD: int = 330; /* subimage descriptors */
        public static const TIFFTAG_TARGETPRINTER: int = 337; /* !separation target */
        public static const TIFFTAG_THRESHHOLDING: int = 263; /* +thresholding used on data */
        public static const TIFFTAG_TILEBYTECOUNTS: int = 325; /* !byte counts for tiles */
        public static const TIFFTAG_TILEDEPTH: int = 32998; /* z depth/data tile */
        public static const TIFFTAG_TILELENGTH: int = 323; /* !cols/data tile */
        public static const TIFFTAG_TILEOFFSETS: int = 324; /* !offsets to data tiles */
        public static const TIFFTAG_TILEWIDTH: int = 322; /* !rows/data tile */
        public static const TIFFTAG_TRANSFERFUNCTION: int = 301; /* !colorimetry info */
        public static const TIFFTAG_WHITEPOINT: int = 318; /* image white point */
        /* tag 33405 is a private tag registered to Eastman Kodak */
        public static const TIFFTAG_WRITERSERIALNUMBER: int = 33405; /* device serial number */
        public static const TIFFTAG_XPOSITION: int = 286; /* x page offset of image lhs */
        public static const TIFFTAG_XRESOLUTION: int = 282; /* pixels/resolution in x */
        public static const TIFFTAG_YCBCRCOEFFICIENTS: int = 529; /* !RGB -> YCbCr transform */
        public static const TIFFTAG_YCBCRPOSITIONING: int = 531; /* !subsample positioning */
        public static const TIFFTAG_YCBCRSUBSAMPLING: int = 530; /* !YCbCr subsampling factors */
        public static const TIFFTAG_YPOSITION: int = 287; /* y page offset of image lhs */
        public static const TIFFTAG_YRESOLUTION: int = 283; /* pixels/resolution in y */
        public static const YCBCRPOSITION_CENTERED: int = 1; /* !as in PostScript Level 2 */
        public static const YCBCRPOSITION_COSITED: int = 2; /* !as in CCIR 601-1 */
    }
}