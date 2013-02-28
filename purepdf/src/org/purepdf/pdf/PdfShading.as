/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: PdfShading.as 249 2010-02-02 06:59:26Z alessandro.crugnola $
* $Author Alessandro Crugnola $
* $Rev: 249 $ $LastChangedDate: 2010-02-02 01:59:26 -0500 (Tue, 02 Feb 2010) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/pdf/PdfShading.as $
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
	import flash.errors.IllegalOperationError;
	
	import it.sephiroth.utils.ObjectHash;
	
	import org.purepdf.colors.CMYKColor;
	import org.purepdf.colors.ExtendedColor;
	import org.purepdf.colors.GrayColor;
	import org.purepdf.colors.RGBColor;
	import org.purepdf.colors.SpotColor;
	import org.purepdf.utils.pdf_core;

	public class PdfShading extends ObjectHash
	{
		protected var _antiAlias: Boolean = false;

		protected var _bBox: Vector.<Number>;
		protected var _colorDetails: ColorDetails;
		protected var _shading: PdfDictionary;
		protected var _shadingName: PdfName;
		protected var _shadingReference: PdfIndirectReference;
		protected var _shadingType: int;
		protected var _writer: PdfWriter;

		private var _cspace: RGBColor;
		
		use namespace pdf_core;

		public function PdfShading( $writer: PdfWriter )
		{
			super();
			_writer = $writer;
		}

		public function addToBody(): void
		{
			if ( _bBox != null )
				_shading.put( PdfName.BBOX, new PdfArray( _bBox ) );

			if ( _antiAlias )
				_shading.put( PdfName.ANTIALIAS, PdfBoolean.PDF_TRUE );
			_writer.addToBody1( _shading, shadingReference );
		}

		public function get antiAlias(): Boolean
		{
			return _antiAlias;
		}

		public function set antiAlias( value: Boolean ): void
		{
			_antiAlias = value;
		}

		public function get bBox(): Vector.<Number>
		{
			return _bBox;
		}

		public function set bBox( value: Vector.<Number> ): void
		{
			if ( value.length != 4 )
				throw new ArgumentError( "value must have a length of 4" );
			_bBox = value;
		}

		public function get colorSpace(): RGBColor
		{
			return _cspace;
		}

		public function setName( number: int ): void
		{
			_shadingName = new PdfName( "Sh" + number );
		}

		public function get shadingName(): PdfName
		{
			return _shadingName;
		}

		public function get shadingReference(): PdfIndirectReference
		{
			if ( _shadingReference == null )
				_shadingReference = _writer.pdfIndirectReference;
			return _shadingReference;
		}

		internal function get colorDetails(): ColorDetails
		{
			return _colorDetails;
		}

		pdf_core function set colorSpace( color: RGBColor ): void
		{
			_cspace = color;
			var type: int = ExtendedColor.getType( color );
			var cs: PdfObject = null;

			switch ( type )
			{
				case ExtendedColor.TYPE_GRAY:
					cs = PdfName.DEVICEGRAY;
					break;

				case ExtendedColor.TYPE_CMYK:
					cs = PdfName.DEVICECMYK;
					break;

				case ExtendedColor.TYPE_SEPARATION:
					var spot: SpotColor = SpotColor( color );
					_colorDetails = writer.pdf_core::addSimple( spot.pdfSpotColor );
					cs = colorDetails.indirectReference;
					break;

				case ExtendedColor.TYPE_PATTERN:
				case ExtendedColor.TYPE_SHADING:
					throwColorSpaceErrror();

				default:
					cs = PdfName.DEVICERGB;
					break;
			}

			_shading.put( PdfName.COLORSPACE, cs );
		}

		internal function get writer(): PdfWriter
		{
			return _writer;
		}

		public static function checkCompatibleColors( c1: RGBColor, c2: RGBColor ): void
		{
			var type1: int = ExtendedColor.getType( c1 );
			var type2: int = ExtendedColor.getType( c2 );

			if ( type1 != type2 )
				throw new ArgumentError( "colors must be of the same type" );

			if ( type1 == ExtendedColor.TYPE_SEPARATION && SpotColor( c1 ).pdfSpotColor != SpotColor( c2 ).pdfSpotColor )
				throw new ArgumentError( "spot color must be the same. Only tint can vary" );

			if ( type1 == ExtendedColor.TYPE_PATTERN || type1 == ExtendedColor.TYPE_SHADING )
				throwColorSpaceErrror();
		}

		public static function getColorArray( color: RGBColor ): Vector.<Number>
		{
			var type: int = ExtendedColor.getType( color );

			switch ( type )
			{
				case ExtendedColor.TYPE_GRAY:
					return Vector.<Number>( [ GrayColor( color ).gray ] );

				case ExtendedColor.TYPE_CMYK:
					var cmyk: CMYKColor = CMYKColor( color );
					return Vector.<Number>( [ cmyk.cyan, cmyk.magenta, cmyk.yellow, cmyk.black ] );

				case ExtendedColor.TYPE_SEPARATION:
					return Vector.<Number>( [ SpotColor( color ).tint ] );

				case ExtendedColor.TYPE_RGB:
				{
					return Vector.<Number>( [ color.red / 255, color.green / 255, color.blue / 255 ] );
				}
			}
			throwColorSpaceErrror();
			return null;
		}

		/**
		 * Create a liear gradient shading with 2 colors
		 * <p>Example:
		 * <blockquote><pre>
		 * var cb: PdfContentByte = document.getDirectContent();
		 * var axial: PdfShading = PdfShading.simpleAxial(
		 * 					writer, 0, 0, 297, 420, 
		 * 					RGBColor.BLACK, RGBColor.BLUE
		 * 	);
		 * cb.paintShading( axial );
		 * </pre></blockquote>
		 * </p>
		 * 
		 * 
		 * @param x				left side of the color rect bound
		 * @param y				top side of the color rect bound
		 * @param x1			right side of the color rect bound
		 * @param y1			bottom side of the color rect bound
		 * @param startColor	gradient start color
		 * @param endColor		gradient end color  
		 * @param extendStart
		 * @param extendEnd	
		 * 
		 * @see org.purepdf.colors.RGBColor
		 */
		public static function simpleAxial( writer: PdfWriter, x0: Number, y0: Number, x1: Number, y1: Number, startColor: RGBColor, endColor: RGBColor
			, extendStart: Boolean=true, extendEnd: Boolean=true ): PdfShading
		{
			checkCompatibleColors( startColor, endColor );
			var fn: PdfFunction = PdfFunction.type2( writer, Vector.<Number>( [ 0, 1 ] ), null, getColorArray( startColor ), getColorArray( endColor )
				, 1 );

			return type2( writer, startColor, Vector.<Number>( [ x0, y0, x1, y1 ] ), null, fn, Vector.<Boolean>( [ extendStart, extendEnd ] ) );
		}

		public static function simpleRadial( writer: PdfWriter, x0: Number, y0: Number, r0: Number, x1: Number, y1: Number, r1: Number
			, startColor: RGBColor, endColor: RGBColor, extendStart: Boolean=true, extendEnd: Boolean=true ): PdfShading
		{
			checkCompatibleColors( startColor, endColor );
			var fn: PdfFunction = PdfFunction.type2( writer, Vector.<Number>( [ 0, 1 ] ), null, getColorArray( startColor ), getColorArray( endColor )
				, 1 );
			return type3( writer, startColor, Vector.<Number>( [ x0, y0, r0, x1, y1, r1 ] ), null, fn, Vector.<Boolean>( [ extendStart, extendEnd ] ) );
		}

		/**
		 * Create a linear gradient shading with multiple colors ( for 2 colors use simpleAxial )
		 * <p>Example:
		 * <blockquote><pre>
		 * var cb: PdfContentByte = document.getDirectContent();
		 * var axial: PdfShading = PdfShading.complexAxial(
		 * 					writer, 0, 0, 297, 420, 
		 * 					Vector.&lt;RGBColor&gt;([ RGBColor.BLACK, RGBColor.BLUE, RGBColor.CYAN ]),
		 * 					Vector.&lt;Number&gt;([ 0, 0.5, 1 ] )
		 * 	);
		 * cb.paintShading( axial );
		 * </pre></blockquote>
		 * </p>
		 * 
		 * 
		 * @param x				left side of the color rect bound
		 * @param y				top side of the color rect bound
		 * @param x1			right side of the color rect bound
		 * @param y1			bottom side of the color rect bound
		 * @param colors		Vector of RGBColor
		 * @param ratios		Vector of Number. This is the color spread ratios. 
		 * 						If null is passed a default ratio will be created  
		 * @param extendStart
		 * @param extendEnd	
		 * 
		 * @throws ArgumentError	if colors.length ne ratios.length
		 * @see org.purepdf.colors.RGBColor
		 */
		public static function complexAxial( writer: PdfWriter, x0: Number, y0: Number, x1: Number, y1: Number, colors: Vector.<RGBColor> , 
											 ratios: Vector.<Number>, extendStart: Boolean = true, extendEnd: Boolean = true ): PdfShading 
		{
			var ratio_null: Boolean = ratios == null;
			if( ratio_null )
				ratios = new Vector.<Number>( colors.length, true )
			
			if( colors.length != ratios.length )
			{
				throw new ArgumentError("colors length must equal ratios lenght");
			}
			
			var k: int;
			var factor: Number = 1/colors.length;
			var colorArrays: Vector.<Vector.<Number>> = new Vector.<Vector.<Number>>( colors.length, true );
			var functions: Vector.<PdfFunction> = new Vector.<PdfFunction>( ratios.length-1, true );
			var encode: Vector.<Number> = new Vector.<Number>( functions.length*2, true );
			var bounds: Vector.<Number> = new Vector.<Number>( functions.length-1, true );
			
			for( k = 0; k < colors.length; ++k)
			{
				if( ratio_null )
					ratios[k] = factor * k;
				else
					ExtendedColor.normalize( ratios[k] );
				
				if( k > 0 )
					checkCompatibleColors( colors[0], colors[k] );
				colorArrays[k] = getColorArray( colors[k] );
			}
			
			for( k = 0; k < functions.length; ++k )
			{
				functions[k] = PdfFunction.type2( writer,
						Vector.<Number>([0,1]),
						null,
						colorArrays[k],
						colorArrays[k+1],
						1);
				
				encode[2*k+0] = 0;
				encode[2*k+1] = 1;
				
				if( k < bounds.length )
					bounds[k] = ratios[k+1];
					
			}
			
			var fn: PdfFunction = PdfFunction.type3(writer, Vector.<Number>([0,1]), null, functions, bounds, encode);
			return type2(writer, colors[0], Vector.<Number>([x0, y0, x1, y1]), null, fn, Vector.<Boolean>([extendStart, extendEnd]) );
		}
		
		/**
		 * Create a radial gradient shading with multiple colors ( for 2 colors use simpleRadial )
		 * <p>Example:
		 * <blockquote><pre>
		 * var cb: PdfContentByte = document.getDirectContent();
		 * var axial: PdfShading = PdfShading.complexRadial(
		 * 					writer, 0, 0, 297, 420, 0, 100,
		 * 					Vector.&lt;RGBColor&gt;([ RGBColor.BLACK, RGBColor.BLUE, RGBColor.CYAN ]),
		 * 					Vector.&lt;Number&gt;([ 0, 0.5, 1 ] )
		 * 	);
		 * cb.paintShading( axial );
		 * </pre></blockquote>
		 * </p>
		 * 
		 * 
		 * @param x				left side of the color rect bound
		 * @param y				top side of the color rect bound
		 * @param x1			right side of the color rect bound
		 * @param y1			bottom side of the color rect bound
		 * @param r0			Inner radius
		 * @param r1			Outer radius
		 * @param colors		Vector of RGBColor
		 * @param ratios		Vector of Number. This is the color spread ratios. 
		 * 						If null is passed a default ratio will be created  
		 * @param extendStart
		 * @param extendEnd	
		 * 
		 * @throws ArgumentError	if colors.length ne ratios.length
		 * @see org.purepdf.colors.RGBColor
		 */
		public static function complexRadial( writer: PdfWriter, x0: Number, y0: Number, x1: Number, y1: Number, r0: Number, r1: Number, colors: Vector.<RGBColor> , 
											  ratios: Vector.<Number>, extendStart: Boolean = true, extendEnd: Boolean = true ): PdfShading 
		{
			var ratio_null: Boolean = ratios == null;
			if( ratio_null )
				ratios = new Vector.<Number>( colors.length, true )
			
			if( colors.length != ratios.length )
			{
				throw new ArgumentError("colors length must equal ratios lenght");
			}
			
			var k: int;
			var factor: Number = 1/colors.length;
			var colorArrays: Vector.<Vector.<Number>> = new Vector.<Vector.<Number>>( colors.length, true );
			var functions: Vector.<PdfFunction> = new Vector.<PdfFunction>( ratios.length-1, true );
			var encode: Vector.<Number> = new Vector.<Number>( functions.length*2, true );
			var bounds: Vector.<Number> = new Vector.<Number>( functions.length-1, true );
			
			for( k = 0; k < colors.length; ++k)
			{
				if( ratio_null )
					ratios[k] = factor * k;
				else
					ExtendedColor.normalize( ratios[k] );
				
				if( k > 0 )
					checkCompatibleColors( colors[0], colors[k] );
				colorArrays[k] = getColorArray( colors[k] );
			}
			
			for( k = 0; k < functions.length; ++k )
			{
				functions[k] = PdfFunction.type2( writer,
					Vector.<Number>([0,1]),
					null,
					colorArrays[k],
					colorArrays[k+1],
					1);
				
				encode[2*k+0] = 0;
				encode[2*k+1] = 1;
				
				if( k < bounds.length )
					bounds[k] = ratios[k+1];
				
			}
			
			var fn: PdfFunction = PdfFunction.type3(writer, Vector.<Number>([0,1]), null, functions, bounds, encode);
			return type3(writer, colors[0], Vector.<Number>([x0, y0, r0, x1, y1, r1]), null, fn, Vector.<Boolean>([extendStart, extendEnd]) );
		}
		

		public static function throwColorSpaceErrror(): void
		{
			throw new IllegalOperationError( "A tiling or shading pattern must be used as a color space in a shading pattern" );
		}

		public static function type1( writer: PdfWriter, cs: RGBColor, domain: Vector.<Number>, tMatrix: Vector.<Number>, fn: PdfFunction ): PdfShading
		{
			var sp: PdfShading = new PdfShading( writer );
			sp._shading = new PdfDictionary();
			sp._shadingType = 1;
			sp._shading.put( PdfName.SHADINGTYPE, new PdfNumber( sp._shadingType ) );
			sp.pdf_core::colorSpace = cs;

			if ( domain != null )
				sp._shading.put( PdfName.DOMAIN, new PdfArray( domain ) );

			if ( tMatrix != null )
				sp._shading.put( PdfName.MATRIX, new PdfArray( tMatrix ) );

			sp._shading.put( PdfName.FUNCTION, fn.reference );
			return sp;
		}

		public static function type2( writer: PdfWriter, cs: RGBColor, coords: Vector.<Number>, domain: Vector.<Number>, fn: PdfFunction
			, extend: Vector.<Boolean> ): PdfShading
		{
			var sp: PdfShading = new PdfShading( writer );
			sp._shading = new PdfDictionary();
			sp._shadingType = 2;
			sp._shading.put( PdfName.SHADINGTYPE, new PdfNumber( sp._shadingType ) );
			sp.pdf_core::colorSpace = cs;
			sp._shading.put( PdfName.COORDS, new PdfArray( coords ) );

			if ( domain != null )
				sp._shading.put( PdfName.DOMAIN, new PdfArray( domain ) );
			sp._shading.put( PdfName.FUNCTION, fn.reference );

			if ( extend != null && ( extend[ 0 ] || extend[ 1 ] ) )
			{
				var array: PdfArray = new PdfArray( extend[ 0 ] ? PdfBoolean.PDF_TRUE : PdfBoolean.PDF_FALSE );
				array.add( extend[ 1 ] ? PdfBoolean.PDF_TRUE : PdfBoolean.PDF_FALSE );
				sp._shading.put( PdfName.EXTEND, array );
			}
			return sp;
		}

		public static function type3( writer: PdfWriter, cs: RGBColor, coords: Vector.<Number>, domain: Vector.<Number>, fn: PdfFunction
			, extend: Vector.<Boolean> ): PdfShading
		{
			var sp: PdfShading = type2( writer, cs, coords, domain, fn, extend );
			sp._shadingType = 3;
			sp._shading.put( PdfName.SHADINGTYPE, new PdfNumber( sp._shadingType ) );
			return sp;
		}
	}
}