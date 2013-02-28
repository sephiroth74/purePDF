/*
 *                             ______ _____  _______
 * .-----..--.--..----..-----.|   __ \     \|    ___|
 * |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
 * |   __||_____||__|  |_____||___|  |_____/|___|
 * |__|
 * $Id: PdfName.as 362 2010-05-05 16:53:53Z alessandro.crugnola $
 * $Author Alessandro Crugnola $
 * $Rev: 362 $ $LastChangedDate: 2010-05-05 12:53:53 -0400 (Wed, 05 May 2010) $
 * $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/pdf/PdfName.as $
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
package org.purepdf.pdf
{
	import it.sephiroth.utils.ObjectHash;
	
	import org.purepdf.IComparable;
	import org.purepdf.errors.IndexOutOfBoundsError;
	import org.purepdf.utils.Bytes;
	import org.purepdf.utils.assert_true;

	public class PdfName extends PdfObject implements IComparable
	{
		public static const A: PdfName = new PdfName( "A" );
		public static const AA: PdfName = new PdfName( "AA" );
		public static const ABSOLUTECOLORIMETRIC: PdfName = new PdfName( "AbsoluteColorimetric" );
		public static const AC: PdfName = new PdfName( "AC" );
		public static const ACROFORM: PdfName = new PdfName( "AcroForm" );
		public static const ACTION: PdfName = new PdfName( "Action" );
		public static const ACTIVATION: PdfName = new PdfName( "Activation" );
		public static const ACTUALTEXT: PdfName = new PdfName( "ActualText" );
		public static const ADBE: PdfName = new PdfName( "ADBE" );
		public static const ADBE_PKCS7_DETACHED: PdfName = new PdfName( "adbe.pkcs7.detached" );
		public static const ADBE_PKCS7_S4: PdfName = new PdfName( "adbe.pkcs7.s4" );
		public static const ADBE_PKCS7_S5: PdfName = new PdfName( "adbe.pkcs7.s5" );
		public static const ADBE_PKCS7_SHA1: PdfName = new PdfName( "adbe.pkcs7.sha1" );
		public static const ADBE_X509_RSA_SHA1: PdfName = new PdfName( "adbe.x509.rsa_sha1" );
		public static const ADOBE_PPKLITE: PdfName = new PdfName( "Adobe.PPKLite" );
		public static const ADOBE_PPKMS: PdfName = new PdfName( "Adobe.PPKMS" );
		public static const AESV2: PdfName = new PdfName( "AESV2" );
		public static const AIS: PdfName = new PdfName( "AIS" );
		public static const ALLPAGES: PdfName = new PdfName( "AllPages" );
		public static const ALT: PdfName = new PdfName( "Alt" );
		public static const ALTERNATE: PdfName = new PdfName( "Alternate" );
		public static const ANIMATION: PdfName = new PdfName( "Animation" );
		public static const ANNOT: PdfName = new PdfName( "Annot" );
		public static const ANNOTS: PdfName = new PdfName( "Annots" );
		public static const ANTIALIAS: PdfName = new PdfName( "AntiAlias" );
		public static const AP: PdfName = new PdfName( "AP" );
		public static const APPDEFAULT: PdfName = new PdfName( "AppDefault" );
		public static const ART: PdfName = new PdfName( "Art" );
		public static const ARTBOX: PdfName = new PdfName( "ArtBox" );
		public static const AS: PdfName = new PdfName( "AS" );
		public static const ASCENT: PdfName = new PdfName( "Ascent" );
		public static const ASCII85DECODE: PdfName = new PdfName( "ASCII85Decode" );
		public static const ASCIIHEXDECODE: PdfName = new PdfName( "ASCIIHexDecode" );
		public static const ASSET: PdfName = new PdfName( "Asset" );
		public static const ASSETS: PdfName = new PdfName( "Assets" );
		public static const AUTHEVENT: PdfName = new PdfName( "AuthEvent" );
		public static const AUTHOR: PdfName = new PdfName( "Author" );
		public static const B: PdfName = new PdfName( "B" );
		public static const BACKGROUND: PdfName = new PdfName( "Background" );
		public static const BASEENCODING: PdfName = new PdfName( "BaseEncoding" );
		public static const BASEFONT: PdfName = new PdfName( "BaseFont" );
		public static const BASEVERSION: PdfName = new PdfName( "BaseVersion" );
		public static const BBOX: PdfName = new PdfName( "BBox" );
		public static const BC: PdfName = new PdfName( "BC" );
		public static const BG: PdfName = new PdfName( "BG" );
		public static const BIBENTRY: PdfName = new PdfName( "BibEntry" );
		public static const BIGFIVE: PdfName = new PdfName( "BigFive" );
		public static const BINDING: PdfName = new PdfName( "Binding" );
		public static const BINDINGMATERIALNAME: PdfName = new PdfName( "BindingMaterialName" );
		public static const BITSPERCOMPONENT: PdfName = new PdfName( "BitsPerComponent" );
		public static const BITSPERSAMPLE: PdfName = new PdfName( "BitsPerSample" );
		public static const BL: PdfName = new PdfName( "Bl" );
		public static const BLACKIS1: PdfName = new PdfName( "BlackIs1" );
		public static const BLACKPOINT: PdfName = new PdfName( "BlackPoint" );
		public static const BLEEDBOX: PdfName = new PdfName( "BleedBox" );
		public static const BLINDS: PdfName = new PdfName( "Blinds" );
		public static const BLOCKQUOTE: PdfName = new PdfName( "BlockQuote" );
		public static const BM: PdfName = new PdfName( "BM" );
		public static const BORDER: PdfName = new PdfName( "Border" );
		public static const BOUNDS: PdfName = new PdfName( "Bounds" );
		public static const BOX: PdfName = new PdfName( "Box" );
		public static const BS: PdfName = new PdfName( "BS" );
		public static const BTN: PdfName = new PdfName( "Btn" );
		public static const BYTERANGE: PdfName = new PdfName( "ByteRange" );
		public static const C: PdfName = new PdfName( "C" );
		public static const C0: PdfName = new PdfName( "C0" );
		public static const C1: PdfName = new PdfName( "C1" );
		public static const CA: PdfName = new PdfName( "CA" );
		public static const CALGRAY: PdfName = new PdfName( "CalGray" );
		public static const CALRGB: PdfName = new PdfName( "CalRGB" );
		public static const CAPHEIGHT: PdfName = new PdfName( "CapHeight" );
		public static const CAPTION: PdfName = new PdfName( "Caption" );
		public static const CATALOG: PdfName = new PdfName( "Catalog" );
		public static const CATEGORY: PdfName = new PdfName( "Category" );
		public static const CCITTFAXDECODE: PdfName = new PdfName( "CCITTFaxDecode" );
		public static const CENTER: PdfName = new PdfName( "Center" );
		public static const CENTERWINDOW: PdfName = new PdfName( "CenterWindow" );
		public static const CERT: PdfName = new PdfName( "Cert" );
		public static const CF: PdfName = new PdfName( "CF" );
		public static const CFM: PdfName = new PdfName( "CFM" );
		public static const CH: PdfName = new PdfName( "Ch" );
		public static const CHARPROCS: PdfName = new PdfName( "CharProcs" );
		public static const CHECKSUM: PdfName = new PdfName( "CheckSum" );
		public static const CI: PdfName = new PdfName( "CI" );
		public static const CIDFONTTYPE0: PdfName = new PdfName( "CIDFontType0" );
		public static const CIDFONTTYPE2: PdfName = new PdfName( "CIDFontType2" );
		public static const CIDSET: PdfName = new PdfName( "CIDSet" );
		public static const CIDSYSTEMINFO: PdfName = new PdfName( "CIDSystemInfo" );
		public static const CIDTOGIDMAP: PdfName = new PdfName( "CIDToGIDMap" );
		public static const CIRCLE: PdfName = new PdfName( "Circle" );
		public static const CMD: PdfName = new PdfName( "CMD" );
		public static const CO: PdfName = new PdfName( "CO" );
		public static const CODE: PdfName = new PdfName( "Code" );
		public static const COLLECTION: PdfName = new PdfName( "Collection" );
		public static const COLLECTIONFIELD: PdfName = new PdfName( "CollectionField" );
		public static const COLLECTIONITEM: PdfName = new PdfName( "CollectionItem" );
		public static const COLLECTIONSCHEMA: PdfName = new PdfName( "CollectionSchema" );
		public static const COLLECTIONSORT: PdfName = new PdfName( "CollectionSort" );
		public static const COLLECTIONSUBITEM: PdfName = new PdfName( "CollectionSubitem" );
		public static const COLORS: PdfName = new PdfName( "Colors" );
		public static const COLORSPACE: PdfName = new PdfName( "ColorSpace" );
		public static const COLUMNS: PdfName = new PdfName( "Columns" );
		public static const CONDITION: PdfName = new PdfName( "Condition" );
		public static const CONFIGURATION: PdfName = new PdfName( "Configuration" );
		public static const CONFIGURATIONS: PdfName = new PdfName( "Configurations" );
		public static const CONTACTINFO: PdfName = new PdfName( "ContactInfo" );
		public static const CONTENT: PdfName = new PdfName( "Content" );
		public static const CONTENTS: PdfName = new PdfName( "Contents" );
		public static const COORDS: PdfName = new PdfName( "Coords" );
		public static const COUNT: PdfName = new PdfName( "Count" );
		public static const COURIER: PdfName = new PdfName( "Courier" );
		public static const COURIER_BOLD: PdfName = new PdfName( "Courier-Bold" );
		public static const COURIER_BOLDOBLIQUE: PdfName = new PdfName( "Courier-BoldOblique" );
		public static const COURIER_OBLIQUE: PdfName = new PdfName( "Courier-Oblique" );
		public static const CREATIONDATE: PdfName = new PdfName( "CreationDate" );
		public static const CREATOR: PdfName = new PdfName( "Creator" );
		public static const CREATORINFO: PdfName = new PdfName( "CreatorInfo" );
		public static const CROPBOX: PdfName = new PdfName( "CropBox" );
		public static const CRYPT: PdfName = new PdfName( "Crypt" );
		public static const CS: PdfName = new PdfName( "CS" );
		public static const CUEPOINT: PdfName = new PdfName( "CuePoint" );
		public static const CUEPOINTS: PdfName = new PdfName( "CuePoints" );
		public static const D: PdfName = new PdfName( "D" );
		public static const DA: PdfName = new PdfName( "DA" );
		public static const DATA: PdfName = new PdfName( "Data" );
		public static const DC: PdfName = new PdfName( "DC" );
		public static const DCTDECODE: PdfName = new PdfName( "DCTDecode" );
		public static const DEACTIVATION: PdfName = new PdfName( "Deactivation" );
		public static const DECODE: PdfName = new PdfName( "Decode" );
		public static const DECODEPARMS: PdfName = new PdfName( "DecodeParms" );
		public static const DEFAULT: PdfName = new PdfName( "Default" );
		public static const DEFAULTCMYK: PdfName = new PdfName( "DefaultCMYK" );
		public static const DEFAULTCRYPTFILTER: PdfName = new PdfName( "DefaultCryptFilter" );
		public static const DEFAULTGRAY: PdfName = new PdfName( "DefaultGray" );
		public static const DEFAULTRGB: PdfName = new PdfName( "DefaultRGB" );
		public static const DESC: PdfName = new PdfName( "Desc" );
		public static const DESCENDANTFONTS: PdfName = new PdfName( "DescendantFonts" );
		public static const DESCENT: PdfName = new PdfName( "Descent" );
		public static const DEST: PdfName = new PdfName( "Dest" );
		public static const DESTOUTPUTPROFILE: PdfName = new PdfName( "DestOutputProfile" );
		public static const DESTS: PdfName = new PdfName( "Dests" );
		public static const DEVICECMYK: PdfName = new PdfName( "DeviceCMYK" );
		public static const DEVICEGRAY: PdfName = new PdfName( "DeviceGray" );
		public static const DEVICEN: PdfName = new PdfName( "DeviceN" );
		public static const DEVICERGB: PdfName = new PdfName( "DeviceRGB" );
		public static const DI: PdfName = new PdfName( "Di" );
		public static const DIFFERENCES: PdfName = new PdfName( "Differences" );
		public static const DIRECTION: PdfName = new PdfName( "Direction" );
		public static const DISPLAYDOCTITLE: PdfName = new PdfName( "DisplayDocTitle" );
		public static const DISSOLVE: PdfName = new PdfName( "Dissolve" );
		public static const DIV: PdfName = new PdfName( "Div" );
		public static const DL: PdfName = new PdfName( "DL" );
		public static const DM: PdfName = new PdfName( "Dm" );
		public static const DOCMDP: PdfName = new PdfName( "DocMDP" );
		public static const DOCOPEN: PdfName = new PdfName( "DocOpen" );
		public static const DOCUMENT: PdfName = new PdfName( "Document" );
		public static const DOMAIN: PdfName = new PdfName( "Domain" );
		public static const DP: PdfName = new PdfName( "DP" );
		public static const DR: PdfName = new PdfName( "DR" );
		public static const DS: PdfName = new PdfName( "DS" );
		public static const DUPLEX: PdfName = new PdfName( "Duplex" );
		public static const DUPLEXFLIPLONGEDGE: PdfName = new PdfName( "DuplexFlipLongEdge" );
		public static const DUPLEXFLIPSHORTEDGE: PdfName = new PdfName( "DuplexFlipShortEdge" );
		public static const DUR: PdfName = new PdfName( "Dur" );
		public static const DV: PdfName = new PdfName( "DV" );
		public static const DW: PdfName = new PdfName( "DW" );
		public static const E: PdfName = new PdfName( "E" );
		public static const EARLYCHANGE: PdfName = new PdfName( "EarlyChange" );
		public static const EF: PdfName = new PdfName( "EF" );
		public static const EFF: PdfName = new PdfName( "EFF" );
		public static const EFOPEN: PdfName = new PdfName( "EFOpen" );
		public static const EMBEDDED: PdfName = new PdfName( "Embedded" );
		public static const EMBEDDEDFILE: PdfName = new PdfName( "EmbeddedFile" );
		public static const EMBEDDEDFILES: PdfName = new PdfName( "EmbeddedFiles" );
		public static const ENCODE: PdfName = new PdfName( "Encode" );
		public static const ENCODEDBYTEALIGN: PdfName = new PdfName( "EncodedByteAlign" );
		public static const ENCODING: PdfName = new PdfName( "Encoding" );
		public static const ENCRYPT: PdfName = new PdfName( "Encrypt" );
		public static const ENCRYPTMETADATA: PdfName = new PdfName( "EncryptMetadata" );
		public static const ENDOFBLOCK: PdfName = new PdfName( "EndOfBlock" );
		public static const ENDOFLINE: PdfName = new PdfName( "EndOfLine" );
		public static const EVENT: PdfName = new PdfName( "Event" );
		public static const EXPORT: PdfName = new PdfName( "Export" );
		public static const EXPORTSTATE: PdfName = new PdfName( "ExportState" );
		public static const EXTEND: PdfName = new PdfName( "Extend" );
		public static const EXTENSIONLEVEL: PdfName = new PdfName( "ExtensionLevel" );
		public static const EXTENSIONS: PdfName = new PdfName( "Extensions" );
		public static const EXTGSTATE: PdfName = new PdfName( "ExtGState" );
		public static const F: PdfName = new PdfName( "F" );
		public static const FAR: PdfName = new PdfName( "Far" );
		public static const FB: PdfName = new PdfName( "FB" );
		public static const FDECODEPARMS: PdfName = new PdfName( "FDecodeParms" );
		public static const FDF: PdfName = new PdfName( "FDF" );
		public static const FF: PdfName = new PdfName( "Ff" );
		public static const FFILTER: PdfName = new PdfName( "FFilter" );
		public static const FIELDS: PdfName = new PdfName( "Fields" );
		public static const FIGURE: PdfName = new PdfName( "Figure" );
		public static const FILEATTACHMENT: PdfName = new PdfName( "FileAttachment" );
		public static const FILESPEC: PdfName = new PdfName( "Filespec" );
		public static const FILTER: PdfName = new PdfName( "Filter" );
		public static const FIRST: PdfName = new PdfName( "First" );
		public static const FIRSTCHAR: PdfName = new PdfName( "FirstChar" );
		public static const FIRSTPAGE: PdfName = new PdfName( "FirstPage" );
		public static const FIT: PdfName = new PdfName( "Fit" );
		public static const FITB: PdfName = new PdfName( "FitB" );
		public static const FITBH: PdfName = new PdfName( "FitBH" );
		public static const FITBV: PdfName = new PdfName( "FitBV" );
		public static const FITH: PdfName = new PdfName( "FitH" );
		public static const FITR: PdfName = new PdfName( "FitR" );
		public static const FITV: PdfName = new PdfName( "FitV" );
		public static const FITWINDOW: PdfName = new PdfName( "FitWindow" );
		public static const FLAGS: PdfName = new PdfName( "Flags" );
		public static const FLASH: PdfName = new PdfName( "Flash" );
		public static const FLASHVARS: PdfName = new PdfName( "FlashVars" );
		public static const FLATEDECODE: PdfName = new PdfName( "FlateDecode" );
		public static const FO: PdfName = new PdfName( "Fo" );
		public static const FONT: PdfName = new PdfName( "Font" );
		public static const FONTBBOX: PdfName = new PdfName( "FontBBox" );
		public static const FONTDESCRIPTOR: PdfName = new PdfName( "FontDescriptor" );
		public static const FONTFILE: PdfName = new PdfName( "FontFile" );
		public static const FONTFILE2: PdfName = new PdfName( "FontFile2" );
		public static const FONTFILE3: PdfName = new PdfName( "FontFile3" );
		public static const FONTMATRIX: PdfName = new PdfName( "FontMatrix" );
		public static const FONTNAME: PdfName = new PdfName( "FontName" );
		public static const FOREGROUND: PdfName = new PdfName( "Foreground" );
		public static const FORM: PdfName = new PdfName( "Form" );
		public static const FORMTYPE: PdfName = new PdfName( "FormType" );
		public static const FORMULA: PdfName = new PdfName( "Formula" );
		public static const FREETEXT: PdfName = new PdfName( "FreeText" );
		public static const FRM: PdfName = new PdfName( "FRM" );
		public static const FS: PdfName = new PdfName( "FS" );
		public static const FT: PdfName = new PdfName( "FT" );
		public static const FULLSCREEN: PdfName = new PdfName( "FullScreen" );
		public static const FUNCTION: PdfName = new PdfName( "Function" );
		public static const FUNCTIONS: PdfName = new PdfName( "Functions" );
		public static const FUNCTIONTYPE: PdfName = new PdfName( "FunctionType" );
		public static const GAMMA: PdfName = new PdfName( "Gamma" );
		public static const GBK: PdfName = new PdfName( "GBK" );
		public static const GLITTER: PdfName = new PdfName( "Glitter" );
		public static const GOTO: PdfName = new PdfName( "GoTo" );
		public static const GOTOE: PdfName = new PdfName( "GoToE" );
		public static const GOTOR: PdfName = new PdfName( "GoToR" );
		public static const GROUP: PdfName = new PdfName( "Group" );
		public static const GTS_PDFA1: PdfName = new PdfName( "GTS_PDFA1" );
		public static const GTS_PDFX: PdfName = new PdfName( "GTS_PDFX" );
		public static const GTS_PDFXVERSION: PdfName = new PdfName( "GTS_PDFXVersion" );
		public static const H: PdfName = new PdfName( "H" );
		public static const H1: PdfName = new PdfName( "H1" );
		public static const H2: PdfName = new PdfName( "H2" );
		public static const H3: PdfName = new PdfName( "H3" );
		public static const H4: PdfName = new PdfName( "H4" );
		public static const H5: PdfName = new PdfName( "H5" );
		public static const H6: PdfName = new PdfName( "H6" );
		public static const HALIGN: PdfName = new PdfName( "HAlign" );
		public static const HEIGHT: PdfName = new PdfName( "Height" );
		public static const HELV: PdfName = new PdfName( "Helv" );
		public static const HELVETICA: PdfName = new PdfName( "Helvetica" );
		public static const HELVETICA_BOLD: PdfName = new PdfName( "Helvetica-Bold" );
		public static const HELVETICA_BOLDOBLIQUE: PdfName = new PdfName( "Helvetica-BoldOblique" );
		public static const HELVETICA_OBLIQUE: PdfName = new PdfName( "Helvetica-Oblique" );
		public static const HID: PdfName = new PdfName( "Hid" );
		public static const HIDE: PdfName = new PdfName( "Hide" );
		public static const HIDEMENUBAR: PdfName = new PdfName( "HideMenubar" );
		public static const HIDETOOLBAR: PdfName = new PdfName( "HideToolbar" );
		public static const HIDEWINDOWUI: PdfName = new PdfName( "HideWindowUI" );
		public static const HIGHLIGHT: PdfName = new PdfName( "Highlight" );
		public static const HOFFSET: PdfName = new PdfName( "HOffset" );
		public static const I: PdfName = new PdfName( "I" );
		public static const ICCBASED: PdfName = new PdfName( "ICCBased" );
		public static const ID: PdfName = new PdfName( "ID" );
		public static const IDENTITY: PdfName = new PdfName( "Identity" );
		public static const IF: PdfName = new PdfName( "IF" );
		public static const IMAGE: PdfName = new PdfName( "Image" );
		public static const IMAGEB: PdfName = new PdfName( "ImageB" );
		public static const IMAGEC: PdfName = new PdfName( "ImageC" );
		public static const IMAGEI: PdfName = new PdfName( "ImageI" );
		public static const IMAGEMASK: PdfName = new PdfName( "ImageMask" );
		public static const IMPORTDATA: PdfName = new PdfName( "ImportData" );
		public static const INDEX: PdfName = new PdfName( "Index" );
		public static const INDEXED: PdfName = new PdfName( "Indexed" );
		public static const INFO: PdfName = new PdfName( "Info" );
		public static const INK: PdfName = new PdfName( "Ink" );
		public static const INKLIST: PdfName = new PdfName( "InkList" );
		public static const INSTANCES: PdfName = new PdfName( "Instances" );
		public static const INTENT: PdfName = new PdfName( "Intent" );
		public static const INTERPOLATE: PdfName = new PdfName( "Interpolate" );
		public static const IRT: PdfName = new PdfName( "IRT" );
		public static const ISMAP: PdfName = new PdfName( "IsMap" );
		public static const ITALICANGLE: PdfName = new PdfName( "ItalicAngle" );
		public static const ITXT: PdfName = new PdfName( "ITXT" );
		public static const IX: PdfName = new PdfName( "IX" );
		public static const JAVASCRIPT: PdfName = new PdfName( "JavaScript" );
		public static const JBIG2DECODE: PdfName = new PdfName( "JBIG2Decode" );
		public static const JBIG2GLOBALS: PdfName = new PdfName( "JBIG2Globals" );
		public static const JPXDECODE: PdfName = new PdfName( "JPXDecode" );
		public static const JS: PdfName = new PdfName( "JS" );
		public static const K: PdfName = new PdfName( "K" );
		public static const KEYWORDS: PdfName = new PdfName( "Keywords" );
		public static const KIDS: PdfName = new PdfName( "Kids" );
		public static const L: PdfName = new PdfName( "L" );
		public static const L2R: PdfName = new PdfName( "L2R" );
		public static const LANG: PdfName = new PdfName( "Lang" );
		public static const LANGUAGE: PdfName = new PdfName( "Language" );
		public static const LAST: PdfName = new PdfName( "Last" );
		public static const LASTCHAR: PdfName = new PdfName( "LastChar" );
		public static const LASTPAGE: PdfName = new PdfName( "LastPage" );
		public static const LAUNCH: PdfName = new PdfName( "Launch" );
		public static const LBL: PdfName = new PdfName( "Lbl" );
		public static const LBODY: PdfName = new PdfName( "LBody" );
		public static const LENGTH: PdfName = new PdfName( "Length" );
		public static const LENGTH1: PdfName = new PdfName( "Length1" );
		public static const LI: PdfName = new PdfName( "LI" );
		public static const LIMITS: PdfName = new PdfName( "Limits" );
		public static const LINE: PdfName = new PdfName( "Line" );
		public static const LINEAR: PdfName = new PdfName( "Linear" );
		public static const LINK: PdfName = new PdfName( "Link" );
		public static const LISTMODE: PdfName = new PdfName( "ListMode" );
		public static const LOCATION: PdfName = new PdfName( "Location" );
		public static const LOCK: PdfName = new PdfName( "Lock" );
		public static const LOCKED: PdfName = new PdfName( "Locked" );
		public static const LZWDECODE: PdfName = new PdfName( "LZWDecode" );
		public static const M: PdfName = new PdfName( "M" );
		public static const MAC_EXPERT_ENCODING: PdfName = new PdfName( "MacExpertEncoding" );
		public static const MAC_ROMAN_ENCODING: PdfName = new PdfName( "MacRomanEncoding" );
		public static const MARKED: PdfName = new PdfName( "Marked" );
		public static const MARKINFO: PdfName = new PdfName( "MarkInfo" );
		public static const MASK: PdfName = new PdfName( "Mask" );
		public static const MATERIAL: PdfName = new PdfName( "Material" );
		public static const MATRIX: PdfName = new PdfName( "Matrix" );
		public static const MAXLEN: PdfName = new PdfName( "MaxLen" );
		public static const MAX_CAMEL_CASE: PdfName = new PdfName( "Max" );
		public static const MAX_LOWER_CASE: PdfName = new PdfName( "max" );
		public static const MCID: PdfName = new PdfName( "MCID" );
		public static const MCR: PdfName = new PdfName( "MCR" );
		public static const MEDIABOX: PdfName = new PdfName( "MediaBox" );
		public static const METADATA: PdfName = new PdfName( "Metadata" );
		public static const MIN_CAMEL_CASE: PdfName = new PdfName( "Min" );
		public static const MIN_LOWER_CASE: PdfName = new PdfName( "min" );
		public static const MK: PdfName = new PdfName( "MK" );
		public static const MMTYPE1: PdfName = new PdfName( "MMType1" );
		public static const MODDATE: PdfName = new PdfName( "ModDate" );
		public static const N: PdfName = new PdfName( "N" );
		public static const N0: PdfName = new PdfName( "n0" );
		public static const N1: PdfName = new PdfName( "n1" );
		public static const N2: PdfName = new PdfName( "n2" );
		public static const N3: PdfName = new PdfName( "n3" );
		public static const N4: PdfName = new PdfName( "n4" );
		public static const NAME: PdfName = new PdfName( "Name" );
		public static const NAMED: PdfName = new PdfName( "Named" );
		public static const NAMES: PdfName = new PdfName( "Names" );
		public static const NAVIGATION: PdfName = new PdfName( "Navigation" );
		public static const NAVIGATIONPANE: PdfName = new PdfName( "NavigationPane" );
		public static const NEAR: PdfName = new PdfName( "Near" );
		public static const NEEDAPPEARANCES: PdfName = new PdfName( "NeedAppearances" );
		public static const NEWWINDOW: PdfName = new PdfName( "NewWindow" );
		public static const NEXT: PdfName = new PdfName( "Next" );
		public static const NEXTPAGE: PdfName = new PdfName( "NextPage" );
		public static const NM: PdfName = new PdfName( "NM" );
		public static const NONE: PdfName = new PdfName( "None" );
		public static const NONFULLSCREENPAGEMODE: PdfName = new PdfName( "NonFullScreenPageMode" );
		public static const NONSTRUCT: PdfName = new PdfName( "NonStruct" );
		public static const NOTE: PdfName = new PdfName( "Note" );
		public static const NUMCOPIES: PdfName = new PdfName( "NumCopies" );
		public static const NUMS: PdfName = new PdfName( "Nums" );
		public static const O: PdfName = new PdfName( "O" );
		public static const OBJ: PdfName = new PdfName( "Obj" );
		public static const OBJR: PdfName = new PdfName( "OBJR" );
		public static const OBJSTM: PdfName = new PdfName( "ObjStm" );
		public static const OC: PdfName = new PdfName( "OC" );
		public static const OCG: PdfName = new PdfName( "OCG" );
		public static const OCGS: PdfName = new PdfName( "OCGs" );
		public static const OCMD: PdfName = new PdfName( "OCMD" );
		public static const OCPROPERTIES: PdfName = new PdfName( "OCProperties" );
		public static const OFF: PdfName = new PdfName( "OFF" );
		public static const ON: PdfName = new PdfName( "ON" );
		public static const ONECOLUMN: PdfName = new PdfName( "OneColumn" );
		public static const OP: PdfName = new PdfName( "OP" );
		public static const OPEN: PdfName = new PdfName( "Open" );
		public static const OPENACTION: PdfName = new PdfName( "OpenAction" );
		public static const OPM: PdfName = new PdfName( "OPM" );
		public static const OPT: PdfName = new PdfName( "Opt" );
		public static const ORDER: PdfName = new PdfName( "Order" );
		public static const ORDERING: PdfName = new PdfName( "Ordering" );
		public static const OSCILLATING: PdfName = new PdfName( "Oscillating" );
		public static const OUTLINES: PdfName = new PdfName( "Outlines" );
		public static const OUTPUTCONDITION: PdfName = new PdfName( "OutputCondition" );
		public static const OUTPUTCONDITIONIDENTIFIER: PdfName = new PdfName( "OutputConditionIdentifier" );
		public static const OUTPUTINTENT: PdfName = new PdfName( "OutputIntent" );
		public static const OUTPUTINTENTS: PdfName = new PdfName( "OutputIntents" );
		public static const Off: PdfName = new PdfName( "Off" );
		public static const P: PdfName = new PdfName( "P" );
		public static const PAGE: PdfName = new PdfName( "Page" );
		public static const PAGELABELS: PdfName = new PdfName( "PageLabels" );
		public static const PAGELAYOUT: PdfName = new PdfName( "PageLayout" );
		public static const PAGEMODE: PdfName = new PdfName( "PageMode" );
		public static const PAGES: PdfName = new PdfName( "Pages" );
		public static const PAINTTYPE: PdfName = new PdfName( "PaintType" );
		public static const PANOSE: PdfName = new PdfName( "Panose" );
		public static const PARAMS: PdfName = new PdfName( "Params" );
		public static const PARENT: PdfName = new PdfName( "Parent" );
		public static const PARENTTREE: PdfName = new PdfName( "ParentTree" );
		public static const PARENTTREENEXTKEY: PdfName = new PdfName( "ParentTreeNextKey" );
		public static const PART: PdfName = new PdfName( "Part" );
		public static const PASSCONTEXTCLICK: PdfName = new PdfName( "PassContextClick" );
		public static const PATTERN: PdfName = new PdfName( "Pattern" );
		public static const PATTERNTYPE: PdfName = new PdfName( "PatternType" );
		public static const PC: PdfName = new PdfName( "PC" );
		public static const PDF: PdfName = new PdfName( "PDF" );
		public static const PDFDOCENCODING: PdfName = new PdfName( "PDFDocEncoding" );
		public static const PERCEPTUAL: PdfName = new PdfName( "Perceptual" );
		public static const PERMS: PdfName = new PdfName( "Perms" );
		public static const PG: PdfName = new PdfName( "Pg" );
		public static const PI: PdfName = new PdfName( "PI" );
		public static const PICKTRAYBYPDFSIZE: PdfName = new PdfName( "PickTrayByPDFSize" );
		public static const PLAYCOUNT: PdfName = new PdfName( "PlayCount" );
		public static const PO: PdfName = new PdfName( "PO" );
		public static const POPUP: PdfName = new PdfName( "Popup" );
		public static const POSITION: PdfName = new PdfName( "Position" );
		public static const PREDICTOR: PdfName = new PdfName( "Predictor" );
		public static const PREFERRED: PdfName = new PdfName( "Preferred" );
		public static const PRESENTATION: PdfName = new PdfName( "Presentation" );
		public static const PRESERVERB: PdfName = new PdfName( "PreserveRB" );
		public static const PREV: PdfName = new PdfName( "Prev" );
		public static const PREVPAGE: PdfName = new PdfName( "PrevPage" );
		public static const PRINT: PdfName = new PdfName( "Print" );
		public static const PRINTAREA: PdfName = new PdfName( "PrintArea" );
		public static const PRINTCLIP: PdfName = new PdfName( "PrintClip" );
		public static const PRINTPAGERANGE: PdfName = new PdfName( "PrintPageRange" );
		public static const PRINTSCALING: PdfName = new PdfName( "PrintScaling" );
		public static const PRINTSTATE: PdfName = new PdfName( "PrintState" );
		public static const PRIVATE: PdfName = new PdfName( "Private" );
		public static const PROCSET: PdfName = new PdfName( "ProcSet" );
		public static const PRODUCER: PdfName = new PdfName( "Producer" );
		public static const PROPERTIES: PdfName = new PdfName( "Properties" );
		public static const PS: PdfName = new PdfName( "PS" );
		public static const PUBSEC: PdfName = new PdfName( "Adobe.PubSec" );
		public static const PUREPDF: PdfName = new PdfName( "PUREPDF" );
		public static const PV: PdfName = new PdfName( "PV" );
		public static const Q: PdfName = new PdfName( "Q" );
		public static const QUADPOINTS: PdfName = new PdfName( "QuadPoints" );
		public static const QUOTE: PdfName = new PdfName( "Quote" );
		public static const R: PdfName = new PdfName( "R" );
		public static const R2L: PdfName = new PdfName( "R2L" );
		public static const RANGE: PdfName = new PdfName( "Range" );
		public static const RBGROUPS: PdfName = new PdfName( "RBGroups" );
		public static const RC: PdfName = new PdfName( "RC" );
		public static const REASON: PdfName = new PdfName( "Reason" );
		public static const RECIPIENTS: PdfName = new PdfName( "Recipients" );
		public static const RECT: PdfName = new PdfName( "Rect" );
		public static const REFERENCE: PdfName = new PdfName( "Reference" );
		public static const REGISTRY: PdfName = new PdfName( "Registry" );
		public static const REGISTRYNAME: PdfName = new PdfName( "RegistryName" );
		public static const RELATIVECOLORIMETRIC: PdfName = new PdfName( "RelativeColorimetric" );
		public static const RENDITION: PdfName = new PdfName( "Rendition" );
		public static const RESETFORM: PdfName = new PdfName( "ResetForm" );
		public static const RESOURCES: PdfName = new PdfName( "Resources" );
		public static const RI: PdfName = new PdfName( "RI" );
		public static const RICHMEDIA: PdfName = new PdfName( "RichMedia" );
		public static const RICHMEDIAACTIVATION: PdfName = new PdfName( "RichMediaActivation" );
		public static const RICHMEDIAANIMATION: PdfName = new PdfName( "RichMediaAnimation" );
		public static const RICHMEDIACOMMAND: PdfName = new PdfName( "RichMediaCommand" );
		public static const RICHMEDIACONFIGURATION: PdfName = new PdfName( "RichMediaConfiguration" );
		public static const RICHMEDIACONTENT: PdfName = new PdfName( "RichMediaContent" );
		public static const RICHMEDIADEACTIVATION: PdfName = new PdfName( "RichMediaDeactivation" );
		public static const RICHMEDIAEXECUTE: PdfName = new PdfName( "RichMediaExecute" );
		public static const RICHMEDIAINSTANCE: PdfName = new PdfName( "RichMediaInstance" );
		public static const RICHMEDIAPARAMS: PdfName = new PdfName( "RichMediaParams" );
		public static const RICHMEDIAPOSITION: PdfName = new PdfName( "RichMediaPosition" );
		public static const RICHMEDIAPRESENTATION: PdfName = new PdfName( "RichMediaPresentation" );
		public static const RICHMEDIASETTINGS: PdfName = new PdfName( "RichMediaSettings" );
		public static const RICHMEDIAWINDOW: PdfName = new PdfName( "RichMediaWindow" );
		public static const ROLEMAP: PdfName = new PdfName( "RoleMap" );
		public static const ROOT: PdfName = new PdfName( "Root" );
		public static const ROTATE: PdfName = new PdfName( "Rotate" );
		public static const ROWS: PdfName = new PdfName( "Rows" );
		public static const RUBY: PdfName = new PdfName( "Ruby" );
		public static const RUNLENGTHDECODE: PdfName = new PdfName( "RunLengthDecode" );
		public static const RV: PdfName = new PdfName( "RV" );
		public static const S: PdfName = new PdfName( "S" );
		public static const SATURATION: PdfName = new PdfName( "Saturation" );
		public static const SCHEMA: PdfName = new PdfName( "Schema" );
		public static const SCREEN: PdfName = new PdfName( "Screen" );
		public static const SCRIPTS: PdfName = new PdfName( "Scripts" );
		public static const SECT: PdfName = new PdfName( "Sect" );
		public static const SEPARATION: PdfName = new PdfName( "Separation" );
		public static const SETOCGSTATE: PdfName = new PdfName( "SetOCGState" );
		public static const SETTINGS: PdfName = new PdfName( "Settings" );
		public static const SHADING: PdfName = new PdfName( "Shading" );
		public static const SHADINGTYPE: PdfName = new PdfName( "ShadingType" );
		public static const SHIFT_JIS: PdfName = new PdfName( "Shift-JIS" );
		public static const SIG: PdfName = new PdfName( "Sig" );
		public static const SIGFLAGS: PdfName = new PdfName( "SigFlags" );
		public static const SIGREF: PdfName = new PdfName( "SigRef" );
		public static const SIMPLEX: PdfName = new PdfName( "Simplex" );
		public static const SINGLEPAGE: PdfName = new PdfName( "SinglePage" );
		public static const SIZE: PdfName = new PdfName( "Size" );
		public static const SMASK: PdfName = new PdfName( "SMask" );
		public static const SORT: PdfName = new PdfName( "Sort" );
		public static const SOUND: PdfName = new PdfName( "Sound" );
		public static const SPAN: PdfName = new PdfName( "Span" );
		public static const SPEED: PdfName = new PdfName( "Speed" );
		public static const SPLIT: PdfName = new PdfName( "Split" );
		public static const SQUARE: PdfName = new PdfName( "Square" );
		public static const SQUIGGLY: PdfName = new PdfName( "Squiggly" );
		public static const ST: PdfName = new PdfName( "St" );
		public static const STAMP: PdfName = new PdfName( "Stamp" );
		public static const STANDARD: PdfName = new PdfName( "Standard" );
		public static const STATE: PdfName = new PdfName( "State" );
		public static const STDCF: PdfName = new PdfName( "StdCF" );
		public static const STEMV: PdfName = new PdfName( "StemV" );
		public static const STMF: PdfName = new PdfName( "StmF" );
		public static const STRF: PdfName = new PdfName( "StrF" );
		public static const STRIKEOUT: PdfName = new PdfName( "StrikeOut" );
		public static const STRUCTPARENT: PdfName = new PdfName( "StructParent" );
		public static const STRUCTPARENTS: PdfName = new PdfName( "StructParents" );
		public static const STRUCTTREEROOT: PdfName = new PdfName( "StructTreeRoot" );
		public static const STYLE: PdfName = new PdfName( "Style" );
		public static const SUBFILTER: PdfName = new PdfName( "SubFilter" );
		public static const SUBJECT: PdfName = new PdfName( "Subject" );
		public static const SUBMITFORM: PdfName = new PdfName( "SubmitForm" );
		public static const SUBTYPE: PdfName = new PdfName( "Subtype" );
		public static const SUPPLEMENT: PdfName = new PdfName( "Supplement" );
		public static const SV: PdfName = new PdfName( "SV" );
		public static const SW: PdfName = new PdfName( "SW" );
		public static const SYMBOL: PdfName = new PdfName( "Symbol" );
		public static const T: PdfName = new PdfName( "T" );
		public static const TA: PdfName = new PdfName( "TA" );
		public static const TABLE: PdfName = new PdfName( "Table" );
		public static const TABLEROW: PdfName = new PdfName( "TR" );
		public static const TABS: PdfName = new PdfName( "Tabs" );
		public static const TBODY: PdfName = new PdfName( "TBody" );
		public static const TD: PdfName = new PdfName( "TD" );
		public static const TEXT: PdfName = new PdfName( "Text" );
		public static const TFOOT: PdfName = new PdfName( "TFoot" );
		public static const TH: PdfName = new PdfName( "TH" );
		public static const THEAD: PdfName = new PdfName( "THead" );
		public static const THREADS: PdfName = new PdfName( "Threads" );
		public static const THUMB: PdfName = new PdfName( "Thumb" );
		public static const TI: PdfName = new PdfName( "TI" );
		public static const TILINGTYPE: PdfName = new PdfName( "TilingType" );
		public static const TIME: PdfName = new PdfName( "Time" );
		public static const TIMES_BOLD: PdfName = new PdfName( "Times-Bold" );
		public static const TIMES_BOLDITALIC: PdfName = new PdfName( "Times-BoldItalic" );
		public static const TIMES_ITALIC: PdfName = new PdfName( "Times-Italic" );
		public static const TIMES_ROMAN: PdfName = new PdfName( "Times-Roman" );
		public static const TITLE: PdfName = new PdfName( "Title" );
		public static const TK: PdfName = new PdfName( "TK" );
		public static const TM: PdfName = new PdfName( "TM" );
		public static const TOC: PdfName = new PdfName( "TOC" );
		public static const TOCI: PdfName = new PdfName( "TOCI" );
		public static const TOGGLE: PdfName = new PdfName( "Toggle" );
		public static const TOOLBAR: PdfName = new PdfName( "Toolbar" );
		public static const TOUNICODE: PdfName = new PdfName( "ToUnicode" );
		public static const TP: PdfName = new PdfName( "TP" );
		public static const TRANS: PdfName = new PdfName( "Trans" );
		public static const TRANSFORMMETHOD: PdfName = new PdfName( "TransformMethod" );
		public static const TRANSFORMPARAMS: PdfName = new PdfName( "TransformParams" );
		public static const TRANSPARENCY: PdfName = new PdfName( "Transparency" );
		public static const TRANSPARENT: PdfName = new PdfName( "Transparent" );
		public static const TRAPPED: PdfName = new PdfName( "Trapped" );
		public static const TRIMBOX: PdfName = new PdfName( "TrimBox" );
		public static const TRUETYPE: PdfName = new PdfName( "TrueType" );
		public static const TU: PdfName = new PdfName( "TU" );
		public static const TWOCOLUMNLEFT: PdfName = new PdfName( "TwoColumnLeft" );
		public static const TWOCOLUMNRIGHT: PdfName = new PdfName( "TwoColumnRight" );
		public static const TWOPAGELEFT: PdfName = new PdfName( "TwoPageLeft" );
		public static const TWOPAGERIGHT: PdfName = new PdfName( "TwoPageRight" );
		public static const TX: PdfName = new PdfName( "Tx" );
		public static const TYPE: PdfName = new PdfName( "Type" );
		public static const TYPE0: PdfName = new PdfName( "Type0" );
		public static const TYPE1: PdfName = new PdfName( "Type1" );
		public static const TYPE3: PdfName = new PdfName( "Type3" );
		public static const U: PdfName = new PdfName( "U" );
		public static const UF: PdfName = new PdfName( "UF" );
		public static const UHC: PdfName = new PdfName( "UHC" );
		public static const UNDERLINE: PdfName = new PdfName( "Underline" );
		public static const UR: PdfName = new PdfName( "UR" );
		public static const UR3: PdfName = new PdfName( "UR3" );
		public static const URI: PdfName = new PdfName( "URI" );
		public static const URL: PdfName = new PdfName( "URL" );
		public static const USAGE: PdfName = new PdfName( "Usage" );
		public static const USEATTACHMENTS: PdfName = new PdfName( "UseAttachments" );
		public static const USENONE: PdfName = new PdfName( "UseNone" );
		public static const USEOC: PdfName = new PdfName( "UseOC" );
		public static const USEOUTLINES: PdfName = new PdfName( "UseOutlines" );
		public static const USER: PdfName = new PdfName( "User" );
		public static const USERPROPERTIES: PdfName = new PdfName( "UserProperties" );
		public static const USERUNIT: PdfName = new PdfName( "UserUnit" );
		public static const USETHUMBS: PdfName = new PdfName( "UseThumbs" );
		public static const V: PdfName = new PdfName( "V" );
		public static const V2: PdfName = new PdfName( "V2" );
		public static const VALIGN: PdfName = new PdfName( "VAlign" );
		public static const VERISIGN_PPKVS: PdfName = new PdfName( "VeriSign.PPKVS" );
		public static const VERSION: PdfName = new PdfName( "Version" );
		public static const VIDEO: PdfName = new PdfName( "Video" );
		public static const VIEW: PdfName = new PdfName( "View" );
		public static const VIEWAREA: PdfName = new PdfName( "ViewArea" );
		public static const VIEWCLIP: PdfName = new PdfName( "ViewClip" );
		public static const VIEWERPREFERENCES: PdfName = new PdfName( "ViewerPreferences" );
		public static const VIEWS: PdfName = new PdfName( "Views" );
		public static const VIEWSTATE: PdfName = new PdfName( "ViewState" );
		public static const VISIBLEPAGES: PdfName = new PdfName( "VisiblePages" );
		public static const VOFFSET: PdfName = new PdfName( "VOffset" );
		public static const W: PdfName = new PdfName( "W" );
		public static const W2: PdfName = new PdfName( "W2" );
		public static const WARICHU: PdfName = new PdfName( "Warichu" );
		public static const WC: PdfName = new PdfName( "WC" );
		public static const WHITEPOINT: PdfName = new PdfName( "WhitePoint" );
		public static const WIDGET: PdfName = new PdfName( "Widget" );
		public static const WIDTH: PdfName = new PdfName( "Width" );
		public static const WIDTHS: PdfName = new PdfName( "Widths" );
		public static const WIN: PdfName = new PdfName( "Win" );
		public static const WINDOW: PdfName = new PdfName( "Window" );
		public static const WINDOWED: PdfName = new PdfName( "Windowed" );
		public static const WIN_ANSI_ENCODING: PdfName = new PdfName( "WinAnsiEncoding" );
		public static const WIPE: PdfName = new PdfName( "Wipe" );
		public static const WP: PdfName = new PdfName( "WP" );
		public static const WS: PdfName = new PdfName( "WS" );
		public static const X: PdfName = new PdfName( "X" );
		public static const XA: PdfName = new PdfName( "XA" );
		public static const XD: PdfName = new PdfName( "XD" );
		public static const XFA: PdfName = new PdfName( "XFA" );
		public static const XML: PdfName = new PdfName( "XML" );
		public static const XOBJECT: PdfName = new PdfName( "XObject" );
		public static const XREF: PdfName = new PdfName( "XRef" );
		public static const XREFSTM: PdfName = new PdfName( "XRefStm" );
		public static const XSTEP: PdfName = new PdfName( "XStep" );
		public static const XYZ: PdfName = new PdfName( "XYZ" );
		public static const YSTEP: PdfName = new PdfName( "YStep" );
		public static const ZADB: PdfName = new PdfName( "ZaDb" );
		public static const ZAPFDINGBATS: PdfName = new PdfName( "ZapfDingbats" );
		public static const ZOOM: PdfName = new PdfName( "Zoom" );
		public static const _3D: PdfName = new PdfName( "3D" );
		public static const ca: PdfName = new PdfName( "ca" );
		public static const op: PdfName = new PdfName( "op" );

		public var originalName: String;
		private var hash: int = 0;

		public function PdfName( name: String, lengthCheck: Boolean = true )
		{
			super( PdfObject.NAME );

			if ( lengthCheck && name.length > 127 )
				throw new ArgumentError( "The name " + name + " is too long" );
			bytes = encodeName( name );
			originalName = name;
		}

		public function compareTo( o: Object ): int
		{
			var name: PdfName = PdfName( o );
			var myBytes: Bytes = bytes;
			var objBytes: Bytes = name.getBytes();
			var len: int = Math.min( myBytes.length, objBytes.length );

			for ( var i: int = 0; i < len; i++ )
			{
				if ( myBytes[i] > objBytes[i] )
					return 1;

				if ( myBytes[i] < objBytes[i] )
					return -1;
			}

			if ( myBytes.length < objBytes.length )
				return -1;

			if ( myBytes.length > objBytes.length )
				return 1;
			return 0;
		}

		/**
		 * Indicates whether some other object is "equal to" this one.
		 *
		 * @param   obj   the reference object with which to compare.
		 * @return  <code>true</code> if this object is the same as the obj
		 * argument; <code>false</code> otherwise.
		 */
		override public function equals( obj: Object ): Boolean
		{
			if ( this == obj )
				return true;

			if ( obj is PdfName )
				return compareTo( obj ) == 0;
			return false;
		}

		override public function hashCode(): int
		{
			var h: int = hash;

			if ( h == 0 )
			{
				var ptr: int = 0;
				var len: int = bytes.length;

				for ( var i: int = 0; i < len; i++ )
					h = 31 * h + ( bytes[ptr++] & 0xff );
				hash = h;
			}
			return h;
		}

		override public function toString(): String
		{
			return "/" + originalName;
		}

		public static function encodeName( name: String ): Bytes
		{
			var lenght: int = name.length;
			var buf: ByteBuffer = new ByteBuffer();
			buf.append_char( '/' );
			var c: String;
			var code: Number;

			for ( var k: int = 0; k < lenght; k++ )
			{
				c = name.charAt( k );
				code = name.charCodeAt( k );

				switch ( c )
				{
					case ' ':
					case '%':
					case '(':
					case ')':
					case '<':
					case '>':
					case '[':
					case ']':
					case '{':
					case '}':
					case '/':
					case '#':
						buf.append_char( '#' );
						buf.append_string( code.toString( 16 ) );
						break;
					default:
						if ( code >= 32 && code <= 126 )
						{
							buf.append_char( c );
						} else
						{
							buf.append_char( '#' );

							if ( code < 16 )
								buf.append_char( '0' );
							buf.append_string( code.toString( 16 ) );
						}
						break;
				}
			}
			return buf.toByteArray();
		}

		public static function fromBytes( bytes: Bytes ): PdfName
		{
			var res: PdfName = new PdfName("");
			res.bytes = bytes;
			return res;
		}
		
		/**
		 * Decodes an escaped name given in the form "/AB#20CD" into "AB CD".
		 *
		 * @param name the name to decode
		 * @return the decoded name
		 */
		public static function decodeName( name: String ): String
		{
			var buf: String = "";
			try {
				var len: int = name.length;
				for (var k: int  = 1; k < len; ++k )
				{
					var c: int = name.charCodeAt(k);
					if (c == 35 ) {
						var c1: int = name.charCodeAt(k + 1);
						var c2: int = name.charCodeAt(k + 2);
						c = ((PRTokeniser.getHex(c1) << 4) + PRTokeniser.getHex(c2));
						k += 2;
					}
					buf += String.fromCharCode(c);
				}
			}
			catch (e: IndexOutOfBoundsError ) {
			}
			return buf;
		}
	}
}