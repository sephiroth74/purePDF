/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: ImageElement.as 401 2011-02-07 11:05:24Z alessandro.crugnola@gmail.com $
* $Author Alessandro Crugnola $
* $Rev: 401 $ $LastChangedDate: 2011-02-07 06:05:24 -0500 (Mon, 07 Feb 2011) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/elements/images/ImageElement.as $
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
package org.purepdf.elements.images
{
	import com.adobe.images.PNGEncoder;
	
	import flash.display.BitmapData;
	import flash.utils.ByteArray;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import org.purepdf.codecs.TIFFEncoder;
	import org.purepdf.elements.Annotation;
	import org.purepdf.elements.Element;
	import org.purepdf.elements.IElement;
	import org.purepdf.elements.RectangleElement;
	import org.purepdf.errors.BadElementError;
	import org.purepdf.errors.NonImplementatioError;
	import org.purepdf.io.RandomAccessFileOrArray;
	import org.purepdf.pdf.PdfDictionary;
	import org.purepdf.pdf.PdfIndirectReference;
	import org.purepdf.pdf.PdfStream;
	import org.purepdf.pdf.PdfTemplate;
	import org.purepdf.pdf.codec.BmpImage;
	import org.purepdf.pdf.codec.GifImage;
	import org.purepdf.pdf.codec.PngImage;
	import org.purepdf.pdf.codec.TiffImage;
	import org.purepdf.pdf.interfaces.IPdfOCG;
	import org.purepdf.utils.Bytes;

	public class ImageElement extends RectangleElement implements IElement
	{
		public static const AX: int = 0;
		public static const AY: int = 1;
		public static const BX: int = 2;
		public static const BY: int = 3;
		public static const CX: int = 4;
		public static const CY: int = 5;
		public static const DEFAULT: int = 0;
		public static const DX: int = 6;
		public static const DY: int = 7;
		public static const LEFT: int = 0;
		public static const MIDDLE: int = 1;
		public static const ORIGINAL_BMP: int = 4;
		public static const ORIGINAL_GIF: int = 3;
		public static const ORIGINAL_JBIG2: int = 9;
		public static const ORIGINAL_JPEG: int = 1;
		public static const ORIGINAL_JPEG2000: int = 8;
		public static const ORIGINAL_NONE: int = 0;
		public static const ORIGINAL_PNG: int = 2;
		public static const ORIGINAL_PS: int = 7;
		public static const ORIGINAL_TIFF: int = 5;
		public static const ORIGINAL_WMF: int = 6;
		public static const RIGHT: int = 2;
		public static const TEXTWRAP: int = 4;
		public static const UNDERLYING: int = 8;
		public static const CCITTG4: int = 0x100;
		public static const CCITTG3_1D: int = 0x101;
		public static const CCITTG3_2D: int = 0x102;
		public static const CCITT_BLACKIS1: int = 1;
		public static const CCITT_ENCODEDBYTEALIGN: int = 2;
		public static const CCITT_ENDOFLINE: int = 4;
		public static const CCITT_ENDOFBLOCK: int = 8;
		
		protected static var serialId: Number = 0;
		protected var _XYRatio: Number = 0;
		protected var _absoluteX: Number = Number.NaN;
		protected var _absoluteY: Number = Number.NaN;
		protected var _additional: PdfDictionary;
		protected var _alignment: int;
		protected var _annotation: Annotation = null;
		protected var _bpc: int = 1;
		protected var _colorspace: int = -1;
		protected var _compressionLevel: int = PdfStream.BEST_COMPRESSION;
		protected var _deflated: Boolean = false;
		protected var _imageMask: ImageElement;
		protected var _indentationLeft: Number = 0;
		protected var _indentationRight: Number = 0;
		protected var _interpolation: Boolean;
		protected var _invert: Boolean = false;
		protected var _layer: IPdfOCG;
		protected var _mask: Boolean = false;
		protected var _mySerialId: Number = getSerialId();
		protected var _originalData: ByteArray;
		protected var _originalType: int = ORIGINAL_NONE;
		protected var _rawData: ByteArray;
		protected var _scaledHeight: Number;
		protected var _scaledWidth: Number;
		protected var _smask: Boolean;
		protected var _transparency: Vector.<int>;
		protected var _type: int;
		protected var _url: String;
		protected var alt: String;
		protected var dpiX: int = 0;
		protected var dpiY: int = 0;
		protected var _initialRotation: Number = 0;
		protected var plainHeight: Number;
		protected var plainWidth: Number;
		protected var rotationRadians: Number;
		protected var _spacingAfter: Number = 0;
		protected var _spacingBefore: Number = 0;
		protected var template: Vector.<PdfTemplate> = new Vector.<PdfTemplate>( 1 );
		private var _directReference: PdfIndirectReference;
		private var _widthPercentage: Number = 100;
		
		public function initFromImageElement( other: ImageElement ): void
		{
			//var buffer: ByteArray = new ByteArray();
			//buffer.writeBytes( other._rawData );
			//buffer.position = 0;
			
			_backgroundColor = other._backgroundColor;
			_border = other._border;
			_borderColor = other._borderColor;
			_borderColorBottom = other._borderColorBottom;
			_borderColorLeft = other._borderColorLeft;
			_borderColorRight = other._borderColorRight;
			_borderColorTop = other._borderColorTop;
			_borderWidth = other._borderWidth;
			_borderWidthBottom = other._borderWidthBottom;
			_borderWidthLeft = other._borderWidthLeft;
			_borderWidthRight = other._borderWidthRight;
			_borderWidthTop = other._borderWidthTop;
			llx = other.llx;
			lly = other.lly;
			_rotation = other._rotation;
			urx = other.urx;
			ury = other.ury;
			_useVariableBorders = other._useVariableBorders;
			_XYRatio = other._XYRatio;
			_absoluteX = other._absoluteX;
			_absoluteY = other._absoluteY;
			_additional = other._additional;
			_alignment = other._alignment;
			_annotation = other._annotation;
			_bpc = other._bpc;
			_colorspace = other._colorspace;
			_compressionLevel = other._compressionLevel;
			_deflated = other._deflated;
			// TODO: should we clone also the mask?
			_imageMask = other._imageMask;
			_indentationLeft = other._indentationLeft;
			_indentationRight = other._indentationRight;
			_interpolation = other._interpolation;
			_invert = other._invert;
			_layer = other._layer;
			_mask = other._mask;
			_originalData = other._originalData;
			_originalType = other._originalType;
			_rawData = other._rawData;
			_scaledHeight = other._scaledHeight;
			_scaledWidth = other._scaledWidth;
			_smask = other._smask;
			_transparency = other._transparency ? other._transparency.concat() : null;
			_type = other._type;
			alt = other.alt;
			dpiX = other.dpiX;
			dpiY = other.dpiY;
			_initialRotation = other._initialRotation;
			plainHeight = other.plainHeight;
			plainWidth = other.plainWidth;
			rotationRadians = other.rotationRadians;
			_spacingAfter = other._spacingAfter;
			_spacingBefore = other._spacingBefore;
			
			for( var k: int = 0; k < other.template.length; ++k )
				template[k] = other.template[k] ? ( other.template[k].duplicate() as PdfTemplate ) : null;
			_directReference = other._directReference;
			_widthPercentage = other._widthPercentage;
		}

		public function ImageElement( obj: Object )
		{
			super( 0, 0, 0, 0 );
			
			if( obj is String || obj == null )
			{
				_url = String( obj );
				_alignment = DEFAULT;
				rotationRadians = 0;
			} else {
				initFromImageElement( ImageElement( obj ) );
			}
		}
		
		public function set initialRotation( value: Number ): void
		{
			var old_rot: Number = rotationRadians - this._initialRotation;
			this._initialRotation = value;
			setRotation( old_rot );
		}
		
		public function get initialRotation(): Number
		{
			return this._initialRotation;
		}

		public function get spacingBefore():Number
		{
			return _spacingBefore;
		}

		public function set spacingBefore(value:Number):void
		{
			_spacingBefore = value;
		}

		public function get spacingAfter():Number
		{
			return _spacingAfter;
		}

		public function set spacingAfter(value:Number):void
		{
			_spacingAfter = value;
		}

		public function get absoluteX(): Number
		{
			return _absoluteX;
		}

		public function get absoluteY(): Number
		{
			return _absoluteY;
		}

		public function get additional(): PdfDictionary
		{
			return _additional;
		}

		public function set additional( value: PdfDictionary ): void
		{
			_additional = value;
		}

		public function get alignment(): int
		{
			return _alignment;
		}

		public function set alignment( value: int ): void
		{
			_alignment = value;
		}

		public function get annotation(): Annotation
		{
			return _annotation;
		}

		public function set annotation( value: Annotation ): void
		{
			_annotation = value;
		}

		public function get bpc(): int
		{
			return _bpc;
		}

		public function get colorspace(): int
		{
			return _colorspace;
		}

		public function get compressionLevel(): int
		{
			return _compressionLevel;
		}

		public function set compressionLevel( value: int ): void
		{
			if ( value < PdfStream.NO_COMPRESSION || value > PdfStream.BEST_COMPRESSION )
				_compressionLevel = PdfStream.NO_COMPRESSION;
			else
				_compressionLevel = value;
		}

		public function get deflated(): Boolean
		{
			return _deflated;
		}

		public function set deflated( value: Boolean ): void
		{
			_deflated = value;
		}

		public function get directReference(): PdfIndirectReference
		{
			return _directReference;
		}

		public function get hasAbsoluteX(): Boolean
		{
			return !isNaN( _absoluteX );
		}

		public function get hasAbsoluteY(): Boolean
		{
			return !isNaN( _absoluteY );
		}

		public function get imageMask(): ImageElement
		{
			return _imageMask;
		}

		public function set imageMask( value: ImageElement ): void
		{
			if ( _mask )
				throw new Error( "an image mask cannot contain another image mask" );

			if ( !value.isMask )
				throw new Error( "the image mask is not a valid mask" );
			_imageMask = value;
			_smask = ( value.bpc > 1 && value.bpc <= 8 );
		}

		/**
		 * Get the current Image rotation in radians
		 *
		 * @return rotation in radians
		 */
		public function get imageRotation(): Number
		{
			var d: Number = Math.PI * 2;
			var rot: Number = ( rotationRadians - _initialRotation ) % d;

			if ( rot < 0 )
				rot += d;
			return rot;
		}

		public function get indentationLeft(): Number
		{
			return _indentationLeft;
		}

		public function get indentationRight(): Number
		{
			return _indentationRight;
		}

		public function get isImgRaw(): Boolean
		{
			return _type == Element.IMGRAW;
		}

		public function get isImgTemplate(): Boolean
		{
			return _type == Element.IMGTEMPLATE;
		}

		public function get isInterpolated(): Boolean
		{
			return _interpolation;
		}

		public function get inverted(): Boolean
		{
			return _invert;
		}

		public function set inverted( value: Boolean ): void
		{
			_invert = value;
		}


		public function get isMask(): Boolean
		{
			return _mask;
		}

		public function get isSmask(): Boolean
		{
			return _smask;
		}

		public function get layer(): IPdfOCG
		{
			return _layer;
		}

		public function makeMask(): void
		{
			if ( !isMaskCandidate )
				throw new Error( "this image cannot be an image mask" );
			_mask = true;
		}

		public function get matrix(): Vector.<Number>
		{
			var mt: Vector.<Number> = new Vector.<Number>( 8, true );
			var cosX: Number = Math.cos( rotationRadians );
			var sinX: Number = Math.sin( rotationRadians );
			mt[ AX ] = plainWidth * cosX;
			mt[ AY ] = plainWidth * sinX;
			mt[ BX ] = ( -plainHeight ) * sinX;
			mt[ BY ] = plainHeight * cosX;

			if ( rotationRadians < Math.PI / 2 )
			{
				mt[ CX ] = mt[ BX ];
				mt[ CY ] = 0;
				mt[ DX ] = mt[ AX ];
				mt[ DY ] = mt[ AY ] + mt[ BY ];
			}
			else if ( rotationRadians < Math.PI )
			{
				mt[ CX ] = mt[ AX ] + mt[ BX ];
				mt[ CY ] = mt[ BY ];
				mt[ DX ] = 0;
				mt[ DY ] = mt[ AY ];
			}
			else if ( rotationRadians < Math.PI * 1.5 )
			{
				mt[ CX ] = mt[ AX ];
				mt[ CY ] = mt[ AY ] + mt[ BY ];
				mt[ DX ] = mt[ BX ];
				mt[ DY ] = 0;
			}
			else
			{
				mt[ CX ] = 0;
				mt[ CY ] = mt[ AY ];
				mt[ DX ] = mt[ AX ] + mt[ BX ];
				mt[ DY ] = mt[ BY ];
			}
			return mt;
		}

		public function get mySerialId(): Number
		{
			return _mySerialId;
		}

		public function get originalData(): ByteArray
		{
			return _originalData;
		}

		public function set originalData( value: ByteArray ): void
		{
			_originalData = value;
		}

		public function get originalType(): int
		{
			return _originalType;
		}

		public function set originalType( value: int ): void
		{
			_originalType = value;
		}

		public function get rawData(): ByteArray
		{
			return _rawData;
		}

		/**
		 * Scale the Image to an absolute width and height
		 *
		 * @param newWidth
		 * 					the new image width
		 * @param newHeight
		 * 					the new image height
		 */
		public function scaleAbsolute( newWidth: Number, newHeight: Number ): void
		{
			plainWidth = newWidth;
			plainHeight = newHeight;
			var m: Vector.<Number> = matrix;
			_scaledWidth = m[ DX ] - m[ CX ];
			_scaledHeight = m[ DY ] - m[ CY ];
			setWidthPercentage( 0 );
		}

		/**
		 * Scale the image to an absolute height
		 *
		 * @param newHeight
		 */
		public function scaleAbsoluteHeight( newHeight: Number ): void
		{
			plainHeight = newHeight;
			var m: Vector.<Number> = matrix;
			_scaledWidth = m[ DX ] - m[ CX ];
			_scaledHeight = m[ DY ] - m[ CY ];
			setWidthPercentage( 0 );
		}

		/**
		 * Scale the image to an absolute width
		 *
		 * @param newWidth
		 */
		public function scaleAbsoluteWidth( newWidth: Number ): void
		{
			plainWidth = newWidth;
			var m: Vector.<Number> = matrix;
			_scaledWidth = m[ DX ] - m[ CX ];
			_scaledHeight = m[ DY ] - m[ CY ];
			setWidthPercentage( 0 );
		}

		/**
		 * Scale the width and the height of the Image to an absolute percentage
		 *
		 * @param percentX
		 * @param percentY
		 */
		public function scalePercent( percentX: Number, percentY: Number ): void
		{
			plainWidth = ( width * percentX ) / 100;
			plainHeight = ( height * percentY ) / 100;
			var m: Vector.<Number> = matrix;
			_scaledWidth = m[ DX ] - m[ CX ];
			_scaledHeight = m[ DY ] - m[ CY ];
			setWidthPercentage( 0 );
		}

		/**
		 * Scales the Image to fit an absolute width and height.
		 *
		 * @param fitWidth
		 * @param fitHeight
		 */
		public function scaleToFit( fitWidth: Number, fitHeight: Number ): void
		{
			scalePercent( 100, 100 );
			var percentX: Number = ( fitWidth * 100 ) / scaledWidth;
			var percentY: Number = ( fitHeight * 100 ) / scaledHeight;
			scalePercent( percentX < percentY ? percentX : percentY, percentX < percentY ? percentX : percentY );
			setWidthPercentage( 0 );
		}

		public function get scaledHeight(): Number
		{
			return _scaledHeight;
		}

		public function get scaledWidth(): Number
		{
			return _scaledWidth;
		}

		/**
		 * Set the absolute position of the Image
		 *
		 * @param absX
		 * @param absY
		 */
		public function setAbsolutePosition( absX: Number, absY: Number ): void
		{
			_absoluteX = absX;
			_absoluteY = absY;
		}

		public function setDpi( x: int, y: int ): void
		{
			dpiX = x;
			dpiY = y;
		}

		/**
		 * Set the rotation of the Image in radians
		 *
		 * @param r
		 * 			rotation in radians
		 */
		public function setRotation( r: Number ): void
		{
			var d: Number = 2 * Math.PI;
			rotationRadians = ( r + _initialRotation ) % d;

			if ( rotationRadians < 0 )
				rotationRadians += d;
			var m: Vector.<Number> = matrix;
			_scaledWidth = m[ DX ] - m[ CX ];
			_scaledHeight = m[ DY ] - m[ CY ];
		}

		/**
		 * Set the rotation of the Image in degrees
		 *
		 * @param deg
		 * 				rotation in degrees
		 */
		public function setRotationDegrees( deg: Number ): void
		{
			setRotation( deg / 180 * Math.PI );
		}

		public function setWidthPercentage( value: Number ): void
		{
			_widthPercentage = value;
		}

		public function get templateData(): PdfTemplate
		{
			return template[ 0 ];
		}
		
		public function set templateData( value: PdfTemplate ): void
		{
			template[0] = value;
		}

		public function get transparency(): Vector.<int>
		{
			return _transparency;
		}

		public function set transparency( value: Vector.<int> ): void
		{
			_transparency = value;
		}

		override public function get type(): int
		{
			return _type;
		}

		public function get url(): String
		{
			return _url;
		}

		public function set url( value: String ): void
		{
			_url = value;
		}

		public function get widthPercentage(): Number
		{
			return _widthPercentage;
		}

		public function get xyRatio(): Number
		{
			return _XYRatio;
		}

		public function set xyRatio( value: Number ): void
		{
			_XYRatio = value;
		}

		private function get isMaskCandidate(): Boolean
		{
			if ( _type == Element.IMGRAW )
			{
				if ( _bpc > 0xFF )
				{
					return true;
				}
			}
			return _colorspace == 1;
		}

		/**
		 * Create an ImageElement instance from a BitmapData.
		 * The image will be encoded using a TIFF encoder and compressed
		 * into a raw bytearray
		 */
		public static function getBitmapDataInstance( data: BitmapData, has_alpha: Boolean = true ): ImageElement
		{
			var bytes: ByteArray;
			var img: ImageElement;
			
			if( has_alpha ){
				bytes = PNGEncoder.encode( data );
				
				bytes.position = 0;
				
				img = ImageElement.getInstance( bytes );
				
			} else {
				var tiff: ByteArray = TIFFEncoder.encode( data );
				bytes = new ByteArray();
				bytes.writeBytes( tiff, TIFFEncoder.DATA_OFFSET, tiff.length - TIFFEncoder.DATA_OFFSET );
				bytes.compress();
				
				img = ImageElement.getRawInstance( data.width, data.height, 3, 8, bytes );
				img.deflated = true;
			}
			
			return img;
		}
		
		public static function getTemplateInstance( template: PdfTemplate ): ImageElement
		{
			return new ImageTemplate( template );
		}
		
		public static function getImageInstance( image: ImageElement ): ImageElement
		{
			if( image )
			{
				var def: Object = getDefinitionByName( getQualifiedClassName( image ) );
				return new def( image );
			}
			return null;
		}
		
		
		/**
		 * Creates an Image with CCITT G3 or G4 compression. It assumes that the
		 * data bytes are already compressed.
		 * 
		 * @param width
		 *            the exact width of the image
		 * @param height
		 *            the exact height of the image
		 * @param reverseBits
		 *            reverses the bits in <code>data</code>. Bit 0 is swapped
		 *            with bit 7 and so on
		 * @param typeCCITT
		 *            the type of compression in <code>data</code>. It can be
		 *            CCITTG4, CCITTG31D, CCITTG32D
		 * @param parameters
		 *            parameters associated with this stream. Possible values are
		 *            CCITT_BLACKIS1, CCITT_ENCODEDBYTEALIGN, CCITT_ENDOFLINE and
		 *            CCITT_ENDOFBLOCK or a combination of them
		 * @param data
		 * @param transparency
		 * @throws BadElementError
		 */
		public static function getCCITTInstance( width: int, height: int, reverseBits: Boolean,	typeCCITT: int, parameters: int, data: Bytes, transparency: Vector.<int> = null ): ImageElement
		{
			if( transparency != null && transparency.length != 2 )
				throw new BadElementError("transparency length must be = 2 with");
			
			var img: ImageElement = new ImgCCITT( null, width, height, reverseBits, typeCCITT, parameters, data );
			img.transparency = transparency;
			return img;
		}

		/**
		 * Create a new ImageElement instance from the passed image data
		 * Currently allowed image types are: jpeg, png, gif (and animated gif), tiff
		 *
		 */
		public static function getInstance( buffer: ByteArray ): ImageElement
		{
			buffer.position = 0;
			var c1: uint = buffer.readUnsignedByte();
			var c2: uint = buffer.readUnsignedByte();
			var c3: uint = buffer.readUnsignedByte();
			var c4: uint = buffer.readUnsignedByte();

			// GIF
			if ( c1 == "G".charCodeAt( 0 ) && c2 == "I".charCodeAt( 0 ) && c3 == "F".charCodeAt( 0 ) )
			{
				var gif: GifImage = new GifImage( buffer );
				return gif.getImage();
			}

			// JPEG
			if ( c1 == 0xFF && c2 == 0xD8 )
			{
				return new Jpeg( buffer );
			}

			// PNG
			if ( c1 == PngImage.PNGID[ 0 ] && c2 == PngImage.PNGID[ 1 ] && c3 == PngImage.PNGID[ 2 ] && c4 == PngImage.PNGID[ 3 ] )
			{
				return PngImage.getImage( buffer );
			}

			// TIFF
			if ( ( c1 == 'M'.charCodeAt( 0 ) && c2 == 'M'.charCodeAt( 0 ) && c3 == 0 && c4 == 42 ) || ( c1 == 'I'.charCodeAt( 0 ) && c2 == 'I'.charCodeAt( 0 ) && c3 == 42 && c4 == 0 ) )
			{
				var ra: RandomAccessFileOrArray = null;
				try
				{
					ra = new RandomAccessFileOrArray( buffer );
					var img: ImageElement = TiffImage.getTiffImage( ra, 1 );
					if( img.originalData == null )
						img.originalData = buffer;
					return img;
				} finally {
					if( ra != null )
						ra.close();
				}
			}
			
			// WMF
			if ( c1 == 0xD7 && c2 == 0xCD ) {
				return new ImageWMF( buffer );
			}
			
			if( c1 == 'B'.charCodeAt(0) && c2 == 'M'.charCodeAt(0) )
			{
				return BmpImage.getImage( buffer );
			}

			throw new Error( "byte array is not a recognized image format" );
			return null;
		}

		public static function getRawInstance( width: int, height: int, components: int, bpc: int, data: ByteArray, transparency: Vector
			.<int>=null ): ImageElement
		{
			if ( transparency != null && transparency.length != components * 2 )
				throw new BadElementError( "transparency length must be equal to components*2" );

			if ( components == 1 && bpc == 1 )
			{
				throw new NonImplementatioError();
			}
			var img: ImageElement = new ImageRaw( null, width, height, components, bpc, data );
			img.transparency = transparency;
			return img;
		}

		/** Creates a new serial id. */
		protected static function getSerialId(): Number
		{
			++serialId;
			return serialId;
		}
	}
}