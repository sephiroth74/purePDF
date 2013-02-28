/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: PdfImage.as 401 2011-02-07 11:05:24Z alessandro.crugnola@gmail.com $
* $Author Alessandro Crugnola $
* $Rev: 401 $ $LastChangedDate: 2011-02-07 06:05:24 -0500 (Mon, 07 Feb 2011) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/pdf/PdfImage.as $
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
	import flash.utils.ByteArray;
	
	import org.purepdf.elements.Element;
	import org.purepdf.elements.images.ImageElement;
	import org.purepdf.errors.NonImplementatioError;
	import org.purepdf.utils.Bytes;

	public class PdfImage extends PdfStream
	{
		public static const TRANSFERSIZE: int = 4096;
		protected var _name: PdfName = null;

		public function PdfImage( image: ImageElement, $name: String, maskRef: PdfIndirectReference )
		{
			super();
			_name = new PdfName( $name );
			init( image, maskRef );
		}

		public function get name(): PdfName
		{
			return _name;
		}

		private function init( image: ImageElement, maskRef: PdfIndirectReference ): void
		{
			put( PdfName.TYPE, PdfName.XOBJECT );
			put( PdfName.SUBTYPE, PdfName.IMAGE );
			put( PdfName.WIDTH, new PdfNumber( image.width));
			put( PdfName.HEIGHT, new PdfNumber( image.height));

			if ( image.layer != null )
			{
				throw new NonImplementatioError();
					//put(PdfName.OC, image.getLayer().getRef());
			}

			if ( image.isMask && ( image.bpc == 1 || image.bpc > 0xFF ))
				put( PdfName.IMAGEMASK, PdfBoolean.PDF_TRUE );

			if ( maskRef != null )
			{
				if ( image.isSmask )
					put( PdfName.SMASK, maskRef );
				else
					put( PdfName.MASK, maskRef );
			}

			if ( image.isMask && image.inverted )
				put( PdfName.DECODE, new PdfLiteral( "[1 0]" ));

			if ( image.isInterpolated )
				put( PdfName.INTERPOLATE, PdfBoolean.PDF_TRUE );
			var ins: ByteArray;

			// Raw Image data
			if ( image.isImgRaw )
			{
				var k: int;
				var colorspace: int = image.colorspace;
				var transparency: Vector.<int> = image.transparency;

				if ( transparency != null && !image.isMask && maskRef == null )
				{
					var s: String = "[";

					for ( k = 0; k < transparency.length; ++k )
						s += transparency[ k ] + " ";
					s += "]";
					put( PdfName.MASK, new PdfLiteral( s ));
				}
				
				bytes = new Bytes();
				bytes.buffer = image.rawData;
				put( PdfName.LENGTH, new PdfNumber( bytes.length ));
				var bpc: int = image.bpc;

				if ( bpc > 0xff )
				{
					if ( !image.isMask )
						put( PdfName.COLORSPACE, PdfName.DEVICEGRAY );
					put( PdfName.BITSPERCOMPONENT, new PdfNumber( 1 ));
					put( PdfName.FILTER, PdfName.CCITTFAXDECODE );
					k = bpc - Element.CCITTG3_1D;
					var decodeparms: PdfDictionary = new PdfDictionary();

					if ( k != 0 )
						decodeparms.put( PdfName.K, new PdfNumber( k ));

					if (( colorspace & Element.CCITT_BLACKIS1 ) != 0 )
						decodeparms.put( PdfName.BLACKIS1, PdfBoolean.PDF_TRUE );

					if (( colorspace & Element.CCITT_ENCODEDBYTEALIGN ) != 0 )
						decodeparms.put( PdfName.ENCODEDBYTEALIGN, PdfBoolean.PDF_TRUE );

					if (( colorspace & Element.CCITT_ENDOFLINE ) != 0 )
						decodeparms.put( PdfName.ENDOFLINE, PdfBoolean.PDF_TRUE );

					if (( colorspace & Element.CCITT_ENDOFBLOCK ) != 0 )
						decodeparms.put( PdfName.ENDOFBLOCK, PdfBoolean.PDF_FALSE );
					decodeparms.put( PdfName.COLUMNS, new PdfNumber( image.width));
					decodeparms.put( PdfName.ROWS, new PdfNumber( image.height));
					put( PdfName.DECODEPARMS, decodeparms );
				} else
				{
					switch ( colorspace )
					{
						case 1:
							put( PdfName.COLORSPACE, PdfName.DEVICEGRAY );
							if ( image.inverted )
								put( PdfName.DECODE, new PdfLiteral( "[1 0]" ));
							break;
						
						case 3:
							put( PdfName.COLORSPACE, PdfName.DEVICERGB );
							if ( image.inverted )
								put( PdfName.DECODE, new PdfLiteral( "[1 0 1 0 1 0]" ));
							break;
						
						case 4:
						default:
							put( PdfName.COLORSPACE, PdfName.DEVICECMYK );
							if ( image.inverted )
								put( PdfName.DECODE, new PdfLiteral( "[1 0 1 0 1 0 1 0]" ));
					}
					var additional: PdfDictionary = image.additional;

					if ( additional != null )
						putAll( additional );

					if ( image.isMask && ( image.bpc == 1 || image.bpc > 8 ))
						remove( PdfName.COLORSPACE );
					put( PdfName.BITSPERCOMPONENT, new PdfNumber( image.bpc ));

					if ( image.deflated )
						put( PdfName.FILTER, PdfName.FLATEDECODE );
					else
					{
						flateCompress( image.compressionLevel );
					}
				}
				return;
			}
			// GIF, JPEG or PNG
			var errorID: String;

			if ( image.rawData == null )
			{
				throw new NonImplementatioError();
					//ins = image.getUrl().openStream();
					//errorID = image.getUrl().toString();
			} else
			{
				ins = new ByteArray();
				ins.writeBytes( image.rawData, 0, image.rawData.length );
				ins.position = 0;
				errorID = "Byte array";
			}

			switch ( image.type )
			{
				case Element.JPEG:
					put( PdfName.FILTER, PdfName.DCTDECODE );
					switch ( image.colorspace )
				{
					case 1:
						put( PdfName.COLORSPACE, PdfName.DEVICEGRAY );
						break;
					case 3:
						put( PdfName.COLORSPACE, PdfName.DEVICERGB );
						break;
					default:
						put( PdfName.COLORSPACE, PdfName.DEVICECMYK );
						if ( image.inverted )
						{
							put( PdfName.DECODE, new PdfLiteral( "[1 0 1 0 1 0 1 0]" ));
						}
				}
					put( PdfName.BITSPERCOMPONENT, new PdfNumber( 8 ));
					if ( image.rawData != null )
					{
						bytes = new Bytes();
						bytes.buffer = image.rawData;
						put( PdfName.LENGTH, new PdfNumber( bytes.length ));
						return;
					}
					streamBytes = new ByteArray();
					transferBytes( ins, streamBytes, -1 );
					break;
				case Element.JPEG2000:
					put( PdfName.FILTER, PdfName.JPXDECODE );
					if ( image.colorspace > 0 )
					{
						switch ( image.colorspace )
						{
							case 1:
								put( PdfName.COLORSPACE, PdfName.DEVICEGRAY );
								break;
							case 3:
								put( PdfName.COLORSPACE, PdfName.DEVICERGB );
								break;
							default:
								put( PdfName.COLORSPACE, PdfName.DEVICECMYK );
						}
						put( PdfName.BITSPERCOMPONENT, new PdfNumber( image.bpc ));
					}
					if ( image.rawData != null )
					{
						bytes = new Bytes();
						bytes.buffer = image.rawData;
						put( PdfName.LENGTH, new PdfNumber( bytes.length ));
						return;
					}
					streamBytes = new ByteArray();
					transferBytes( ins, streamBytes, -1 );
					break;
				case Element.JBIG2:
					put( PdfName.FILTER, PdfName.JBIG2DECODE );
					put( PdfName.COLORSPACE, PdfName.DEVICEGRAY );
					put( PdfName.BITSPERCOMPONENT, new PdfNumber( 1 ));
					if ( image.rawData != null )
					{
						bytes = new Bytes();
						bytes.buffer = image.rawData;
						put( PdfName.LENGTH, new PdfNumber( bytes.length ));
						return;
					}
					streamBytes = new ByteArray();
					transferBytes( ins, streamBytes, -1 );
					break;
				default:
					throw new Error( "unknown image format: " + errorID );
			}
			put( PdfName.LENGTH, new PdfNumber( streamBytes.length ));
		}

		public static function transferBytes( ins: ByteArray, out: ByteArray, len: int ): void
		{
			var buffer: ByteArray = new ByteArray();

			if ( len < 0 )
				len = 0x7fff0000;
			var size: int;

			while ( len != 0 )
			{
				var osize: int = buffer.length;
				ins.readBytes( buffer, 0, Math.min( len, TRANSFERSIZE ));
				size = buffer.length - osize;

				if ( size < 0 )
					return;
				out.writeBytes( buffer, 0, size );
				len -= size;
			}
		}
	}
}