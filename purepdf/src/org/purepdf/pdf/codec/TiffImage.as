/*
*                             ______ _____  _______
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|
* |__|
* $Id: TiffImage.as 403 2011-02-10 13:00:57Z alessandro.crugnola@gmail.com $
* $Author Alessandro Crugnola $
* $Rev: 403 $ $LastChangedDate: 2011-02-10 08:00:57 -0500 (Thu, 10 Feb 2011) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/pdf/codec/TiffImage.as $
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
    import com.wizhelp.fzlib.ZStream;
    
    import flash.errors.IOError;
    import flash.utils.ByteArray;
    
    import org.purepdf.codecs.TIFFConstants;
    import org.purepdf.codecs.TIFFDirectory;
    import org.purepdf.codecs.TIFFField;
    import org.purepdf.elements.images.ImageElement;
    import org.purepdf.elements.images.Jpeg;
    import org.purepdf.errors.IllegalArgumentError;
    import org.purepdf.errors.NonImplementatioError;
    import org.purepdf.errors.RuntimeError;
    import org.purepdf.io.OutputStreamCounter;
    import org.purepdf.io.RandomAccessFileOrArray;
    import org.purepdf.io.zip.InflaterInputStream;
    import org.purepdf.pdf.ByteBuffer;
    import org.purepdf.pdf.PdfArray;
    import org.purepdf.pdf.PdfDictionary;
    import org.purepdf.pdf.PdfName;
    import org.purepdf.pdf.PdfNumber;
    import org.purepdf.pdf.PdfString;
    import org.purepdf.utils.ByteArrayUtils;
    import org.purepdf.utils.Bytes;

    public class TiffImage
    {
        public function TiffImage()
        {
        }

        /**
         * Gets the number of pages the TIFF document has.
         *
         * @param s the file source
         * @return the number of pages
         */
        public static function getNumberOfPages( s: RandomAccessFileOrArray ): int
        {
            return TIFFDirectory.getNumDirectories( s );
        }

        /**
         * Reads a page from a TIFF image
		 * 
         * @param s the file source
         * @param page the page to get. The first page is 1
         * @param direct for single strip, CCITT images, generate the image
         * by direct byte copying. It's faster but may not work
         * every time
         * @return the <CODE>ImageElement</CODE>
         */
        public static function getTiffImage( s: RandomAccessFileOrArray, page: int, direct: Boolean = false ): ImageElement
        {
			if( page < 1 )
				throw new IllegalArgumentError("the page number must be >= 1");
			
			try {
				var dir: TIFFDirectory = new TIFFDirectory( s, page - 1);
				
				if( dir.isTagPresent( TIFFConstants.TIFFTAG_TILEWIDTH ) )
					throw new IllegalArgumentError( "tiles are not supported" );
				
				const compression: int = dir.getFieldAsLong( TIFFConstants.TIFFTAG_COMPRESSION );
				
				switch( compression )
				{
					case TIFFConstants.COMPRESSION_CCITTRLEW:
					case TIFFConstants.COMPRESSION_CCITTRLE:
					case TIFFConstants.COMPRESSION_CCITTFAX3:
					case TIFFConstants.COMPRESSION_CCITTFAX4:
						break;
					default:
						return getTiffImageColor(dir, s);
				}
				
				var rotation: Number = 0;
				
				if( dir.isTagPresent( TIFFConstants.TIFFTAG_ORIENTATION ) )
				{
					const rot: int = dir.getFieldAsLong( TIFFConstants.TIFFTAG_ORIENTATION );
					if( rot == TIFFConstants.ORIENTATION_BOTRIGHT || rot == TIFFConstants.ORIENTATION_BOTLEFT )
						rotation = Math.PI;
					else if( rot == TIFFConstants.ORIENTATION_LEFTTOP || rot == TIFFConstants.ORIENTATION_LEFTBOT )
						rotation = Math.PI / 2.0;
					else if( rot == TIFFConstants.ORIENTATION_RIGHTTOP || rot == TIFFConstants.ORIENTATION_RIGHTBOT )
						rotation = -( Math.PI / 2.0 );
				}
				
				var img: ImageElement = null;
				var tiffT4Options: Number = 0;
				var tiffT6Options: Number = 0;
				var fillOrder: int = 1;
				var h: int = dir.getFieldAsLong( TIFFConstants.TIFFTAG_IMAGELENGTH );
				var w: int = dir.getFieldAsLong( TIFFConstants.TIFFTAG_IMAGEWIDTH );
				var dpiX: int = 0;
				var dpiY: int = 0;
				var XYRatio: Number = 0;
				var resolutionUnit: int = TIFFConstants.RESUNIT_INCH;
				
				if( dir.isTagPresent( TIFFConstants.TIFFTAG_RESOLUTIONUNIT ) )
					resolutionUnit = dir.getFieldAsLong( TIFFConstants.TIFFTAG_RESOLUTIONUNIT );
				
				dpiX = getDpi( dir.getField( TIFFConstants.TIFFTAG_XRESOLUTION), resolutionUnit );
				dpiY = getDpi( dir.getField( TIFFConstants.TIFFTAG_YRESOLUTION), resolutionUnit );
				
				if( resolutionUnit == TIFFConstants.RESUNIT_NONE )
				{
					if (dpiY != 0)
						XYRatio = Number(dpiX) / Number(dpiY);
					dpiX = 0;
					dpiY = 0;
				}
				
				var rowsStrip: int = h;
				if( dir.isTagPresent( TIFFConstants.TIFFTAG_ROWSPERSTRIP ) )
					rowsStrip = dir.getFieldAsLong( TIFFConstants.TIFFTAG_ROWSPERSTRIP );
				if( rowsStrip <= 0 || rowsStrip > h )
					rowsStrip = h;
				
				var offset: Vector.<Number> = getArrayLongShort( dir, TIFFConstants.TIFFTAG_STRIPOFFSETS );
				var size: Vector.<Number> = getArrayLongShort( dir, TIFFConstants.TIFFTAG_STRIPBYTECOUNTS );
				if( ( size == null || (size.length == 1 && (size[0] == 0 || size[0] + offset[0] > s.length))) && h == rowsStrip) { // some TIFF producers are really lousy, so...
					size = Vector.<Number>([ s.length - int( offset[0] ) ] );
				}
				
				var reverse: Boolean = false;
				var fillOrderField: TIFFField = dir.getField( TIFFConstants.TIFFTAG_FILLORDER );
				if( fillOrderField != null )
					fillOrder = fillOrderField.getAsInt( 0 );
				
				reverse = ( fillOrder == TIFFConstants.FILLORDER_LSB2MSB );
				var params: int = 0;
				
				if( dir.isTagPresent( TIFFConstants.TIFFTAG_PHOTOMETRIC ) )
				{
					var photo: Number = dir.getFieldAsLong( TIFFConstants.TIFFTAG_PHOTOMETRIC );
					if( photo == TIFFConstants.PHOTOMETRIC_MINISBLACK )
						params |= ImageElement.CCITT_BLACKIS1;
				}
				
				var imagecomp: int = 0;
				switch( compression )
				{
					case TIFFConstants.COMPRESSION_CCITTRLEW:
					case TIFFConstants.COMPRESSION_CCITTRLE:
						imagecomp = ImageElement.CCITTG3_1D;
						params |= ImageElement.CCITT_ENCODEDBYTEALIGN | ImageElement.CCITT_ENDOFBLOCK;
						break;
					
					case TIFFConstants.COMPRESSION_CCITTFAX3:
						imagecomp = ImageElement.CCITTG3_1D;
						params |= ImageElement.CCITT_ENDOFLINE | ImageElement.CCITT_ENDOFBLOCK;
						
						var t4OptionsField: TIFFField = dir.getField( TIFFConstants.TIFFTAG_GROUP3OPTIONS );
						if( t4OptionsField != null )
						{
							tiffT4Options = t4OptionsField.getAsLong( 0 );
							if( ( tiffT4Options & TIFFConstants.GROUP3OPT_2DENCODING) != 0 )
								imagecomp = ImageElement.CCITTG3_2D;
							if( ( tiffT4Options & TIFFConstants.GROUP3OPT_FILLBITS ) != 0 )
								params |= ImageElement.CCITT_ENCODEDBYTEALIGN;
						}
						break;
					
					case TIFFConstants.COMPRESSION_CCITTFAX4:
						imagecomp = ImageElement.CCITTG4;
						var t6OptionsField: TIFFField = dir.getField( TIFFConstants.TIFFTAG_GROUP4OPTIONS );
						if( t6OptionsField != null )
							tiffT6Options = t6OptionsField.getAsLong( 0 );
						break;
				}
				
				var im: Bytes;
				
				if (direct && rowsStrip == h) { //single strip, direct
					im = new Bytes( int( size[0] ) );
					s.seek( offset[0] );
					s.readFully( im, 0, im.length );
					img = ImageElement.getCCITTInstance( w, h, false, imagecomp, params, im );
					img.inverted = true;
				} else 
				{
					var rowsLeft: int = h;
					var g4: CCITTG4Encoder = new CCITTG4Encoder( w );
					
					for( var k: int = 0; k < offset.length; ++k )
					{
						im = new Bytes( int( size[k] ) );
						s.seek( offset[k] );
						s.readFully( im, 0, im.length );
						var height: int = Math.min( rowsStrip, rowsLeft );
						
						var decoder: TIFFFaxDecoder = new TIFFFaxDecoder( fillOrder, w, height );
						var outBuf: Bytes = new Bytes( (w + 7) / 8 * height );
						
						switch( compression )
						{
							case TIFFConstants.COMPRESSION_CCITTRLEW:
							case TIFFConstants.COMPRESSION_CCITTRLE:
								decoder.decode1D( outBuf, im, 0, height );
								g4.fax4Encode2( outBuf, height );
								break;
							
							case TIFFConstants.COMPRESSION_CCITTFAX3:
								try
								{
									throw new NonImplementatioError("TIFFFaxDecoder decode2D non yet implemented");
									//decoder.decode2D( outBuf, im, 0, height, tiffT4Options );
								}
								catch ( e: Error )
								{
									// let's flip the fill bits and try again...
									tiffT4Options ^= TIFFConstants.GROUP3OPT_FILLBITS;
									try 
									{
										throw new NonImplementatioError("TIFFFaxDecoder decode2D non yet implemented");
										//decoder.decode2D( outBuf, im, 0, height, tiffT4Options );
									}
									catch ( e2: Error ) {
										throw e;
									}
								}
								
								g4.fax4Encode2( outBuf, height );
								break;
							
							case TIFFConstants.COMPRESSION_CCITTFAX4:
								decoder.decodeT6( outBuf, im, 0, height, tiffT6Options );
								g4.fax4Encode2( outBuf, height );
								break;
						}
						rowsLeft -= rowsStrip;
					}
					
					var g4pic: Bytes = g4.close();
					img = ImageElement.getCCITTInstance( w, h, false, ImageElement.CCITTG4, params & ImageElement.CCITT_BLACKIS1, g4pic );
				}
				
				img.setDpi( dpiX, dpiY );
				img.xyRatio = XYRatio;
				
				if( dir.isTagPresent( TIFFConstants.TIFFTAG_ICCPROFILE ) ) 
				{
					try 
					{
						throw new NonImplementatioError();
						var fd: TIFFField = dir.getField( TIFFConstants.TIFFTAG_ICCPROFILE );
						//var icc_prof: ICC_Profile = ICC_Profile.getInstance( fd.getAsBytes() );
						//if( icc_prof.getNumComponents() == 1 )
						//	img.tagICC( icc_prof );
					}
					catch ( e: Error ) {
						//empty
					}
				}
				img.originalType = ImageElement.ORIGINAL_TIFF;
				
				if( rotation != 0 )
					img.initialRotation = rotation;
				
				return img;
			}
			catch( e: RuntimeError )
			{
				throw e;
			}
			
			return null;
        }

        internal static function getArrayLongShort( dir: TIFFDirectory, tag: int ): Vector.<Number>
        {
            var field: TIFFField = dir.getField( tag );

            if ( field == null )
                return null;
            var offset: Vector.<Number>;

            if ( field.getType() == TIFFField.TIFF_LONG )
                offset = field.getAsLongs();
            else
            { // must be short
                var temp: Vector.<uint> = field.getAsChars();
                offset = new Vector.<Number>( temp.length, true );

                for ( var k: int = 0; k < temp.length; ++k )
                    offset[k] = temp[k];
            }
            return offset;
        }

        internal static function getDpi( fd: TIFFField, resolutionUnit: int ): int
        {
            if ( fd == null )
                return 0;
            var res: Vector.<Number> = fd.getAsRational( 0 );
            var frac: Number = Number( res[0] ) / Number( res[1] );
            var dpi: int = 0;

            switch ( resolutionUnit )
            {
                case TIFFConstants.RESUNIT_INCH:
                case TIFFConstants.RESUNIT_NONE:
                    dpi = int( frac + 0.5 );
                    break;
                case TIFFConstants.RESUNIT_CENTIMETER:
                    dpi = int( frac * 2.54 + 0.5 );
                    break;
            }
            return dpi;
        }

        protected static function getTiffImageColor( dir: TIFFDirectory, s: RandomAccessFileOrArray ): ImageElement
        {
            const compression: int = dir.getFieldAsLong( TIFFConstants.TIFFTAG_COMPRESSION );
            var predictor: int = 1;
            var lzwDecoder: TIFFLZWDecoder = null;
			var k: int;

            switch ( compression )
            {
                case TIFFConstants.COMPRESSION_NONE:
                case TIFFConstants.COMPRESSION_LZW:
                case TIFFConstants.COMPRESSION_PACKBITS:
                case TIFFConstants.COMPRESSION_DEFLATE:
                case TIFFConstants.COMPRESSION_ADOBE_DEFLATE:
                case TIFFConstants.COMPRESSION_OJPEG:
                case TIFFConstants.COMPRESSION_JPEG:
                    break;
                default:
                    throw new IllegalArgumentError( "the compression " + compression + " is not supported" );
            }
            const photometric: int = dir.getFieldAsLong( TIFFConstants.TIFFTAG_PHOTOMETRIC );

            switch ( photometric )
            {
                case TIFFConstants.PHOTOMETRIC_MINISWHITE:
                case TIFFConstants.PHOTOMETRIC_MINISBLACK:
                case TIFFConstants.PHOTOMETRIC_RGB:
                case TIFFConstants.PHOTOMETRIC_SEPARATED:
                case TIFFConstants.PHOTOMETRIC_PALETTE:
                    break;
                default:
                    if ( compression != TIFFConstants.COMPRESSION_OJPEG && compression != TIFFConstants.COMPRESSION_JPEG )
                        throw new IllegalArgumentError( "the photometric " + photometric + " is not supported" );
            }
            var rotation: Number = 0;

            if ( dir.isTagPresent( TIFFConstants.TIFFTAG_ORIENTATION ) )
            {
                const rot: int = dir.getFieldAsLong( TIFFConstants.TIFFTAG_ORIENTATION );

                if ( rot == TIFFConstants.ORIENTATION_BOTRIGHT || rot == TIFFConstants.ORIENTATION_BOTLEFT )
                    rotation = Math.PI;
                else if ( rot == TIFFConstants.ORIENTATION_LEFTTOP || rot == TIFFConstants.ORIENTATION_LEFTBOT )
                    rotation = ( Math.PI / 2.0 );
                else if ( rot == TIFFConstants.ORIENTATION_RIGHTTOP || rot == TIFFConstants.ORIENTATION_RIGHTBOT )
                    rotation = -( Math.PI / 2.0 );
            }

            if ( dir.isTagPresent( TIFFConstants.TIFFTAG_PLANARCONFIG ) && dir.getFieldAsLong( TIFFConstants.TIFFTAG_PLANARCONFIG ) == TIFFConstants.PLANARCONFIG_SEPARATE )
                throw new IllegalArgumentError( "planar images are not supported" );

            if ( dir.isTagPresent( TIFFConstants.TIFFTAG_EXTRASAMPLES ) )
                throw new IllegalArgumentError( "extra samples are not supported" );
            var samplePerPixel: int = 1;

            if ( dir.isTagPresent( TIFFConstants.TIFFTAG_SAMPLESPERPIXEL ) ) // 1,3,4
                samplePerPixel = dir.getFieldAsLong( TIFFConstants.TIFFTAG_SAMPLESPERPIXEL );
            var bitsPerSample: int = 1;

            if ( dir.isTagPresent( TIFFConstants.TIFFTAG_BITSPERSAMPLE ) )
                bitsPerSample = dir.getFieldAsLong( TIFFConstants.TIFFTAG_BITSPERSAMPLE );

            switch ( bitsPerSample )
            {
                case 1:
                case 2:
                case 4:
                case 8:
                    break;
                default:
                    throw new IllegalArgumentError( "bits per sample " + bitsPerSample + " is not supported" );
            }
            var img: ImageElement = null;
            const h: int = dir.getFieldAsLong( TIFFConstants.TIFFTAG_IMAGELENGTH );
            const w: int = dir.getFieldAsLong( TIFFConstants.TIFFTAG_IMAGEWIDTH );
            var dpiX: int = 0;
            var dpiY: int = 0;
            var resolutionUnit: int = TIFFConstants.RESUNIT_INCH;

            if ( dir.isTagPresent( TIFFConstants.TIFFTAG_RESOLUTIONUNIT ) )
                resolutionUnit = dir.getFieldAsLong( TIFFConstants.TIFFTAG_RESOLUTIONUNIT );
            dpiX = getDpi( dir.getField( TIFFConstants.TIFFTAG_XRESOLUTION ), resolutionUnit );
            dpiY = getDpi( dir.getField( TIFFConstants.TIFFTAG_YRESOLUTION ), resolutionUnit );
            var fillOrder: int = 1;
            var reverse: Boolean = false;
            var fillOrderField: TIFFField = dir.getField( TIFFConstants.TIFFTAG_FILLORDER );

            if ( fillOrderField != null )
                fillOrder = fillOrderField.getAsInt( 0 );
            reverse = ( fillOrder == TIFFConstants.FILLORDER_LSB2MSB );
            var rowsStrip: int = h;

            if ( dir.isTagPresent( TIFFConstants.TIFFTAG_ROWSPERSTRIP ) ) //another hack for broken tiffs
                rowsStrip = dir.getFieldAsLong( TIFFConstants.TIFFTAG_ROWSPERSTRIP );

            if ( rowsStrip <= 0 || rowsStrip > h )
                rowsStrip = h;
            var offset: Vector.<Number> = getArrayLongShort( dir, TIFFConstants.TIFFTAG_STRIPOFFSETS );
            var size: Vector.<Number> = getArrayLongShort( dir, TIFFConstants.TIFFTAG_STRIPBYTECOUNTS );

            if ( ( size == null || ( size.length == 1 && ( size[0] == 0 || size[0] + offset[0] > s.length ) ) ) && h == rowsStrip )
            { // some TIFF producers are really lousy, so...
                size = Vector.<Number>( [ s.length - int( offset[0] ) ] );
            }

            if ( compression == TIFFConstants.COMPRESSION_LZW )
            {
                var predictorField: TIFFField = dir.getField( TIFFConstants.TIFFTAG_PREDICTOR );

                if ( predictorField != null )
                {
                    predictor = predictorField.getAsInt( 0 );

                    if ( predictor != 1 && predictor != 2 )
                    {
                        throw new RuntimeError( "illegal value for predictor in tiff file" );
                    }

                    if ( predictor == 2 && bitsPerSample != 8 )
                    {
                        throw new RuntimeError( bitsPerSample + " bit samples are not supported for horizontal differencing predictor" );
                    }
                }
                lzwDecoder = new TIFFLZWDecoder( w, predictor, samplePerPixel );
            }
            var rowsLeft: int = h;
            var zip: ByteArray = null;
            var g4: CCITTG4Encoder = null;

            if ( bitsPerSample == 1 && samplePerPixel == 1 )
            {
                g4 = new CCITTG4Encoder( w );
            } else
            {
                if ( compression != TIFFConstants.COMPRESSION_OJPEG && compression != TIFFConstants.COMPRESSION_JPEG )
                    zip = new ByteArray();
            }
			
			var jpeg: Bytes;
			var im: Bytes;

            if ( compression == TIFFConstants.COMPRESSION_OJPEG )
            {
                if ( ( !dir.isTagPresent( TIFFConstants.TIFFTAG_JPEGIFOFFSET ) ) )
                {
                    throw new IOError( "missing tag s for ojpeg compression" );
                }
                var jpegOffset: int = dir.getFieldAsLong( TIFFConstants.TIFFTAG_JPEGIFOFFSET );
                var jpegLength: int = s.length - jpegOffset;

                if ( dir.isTagPresent( TIFFConstants.TIFFTAG_JPEGIFBYTECOUNT ) )
                {
                    jpegLength = dir.getFieldAsLong( TIFFConstants.TIFFTAG_JPEGIFBYTECOUNT ) + int( size[0] );
                }
                jpeg = new Bytes( Math.min( jpegLength, s.length - jpegOffset ) );
                var posFilePointer: int = s.getFilePointer();
                posFilePointer += jpegOffset;
                s.seek( posFilePointer );
                s.readFully( jpeg, 0, jpeg.length );
                img = new Jpeg( jpeg.buffer );
            } else if ( compression == TIFFConstants.COMPRESSION_JPEG )
            {
                if ( size.length > 1 )
                    throw new IOError( "compression jpeg is only supported with a single strip this image has " + size.length + "strips" );
                jpeg = new Bytes( int( size[0] ) );
                s.seek( offset[0] );
                s.readFully( jpeg, 0, jpeg.length );
                img = new Jpeg( jpeg.buffer );
            } else
            {
                for ( k = 0; k < offset.length; ++k )
                {
                    im = new Bytes( int( size[k] ) );
                    s.seek( offset[k] );
                    s.readFully( im, 0, im.length );
                    var height: int = Math.min( rowsStrip, rowsLeft );
                    var outBuf: Bytes = null;

                    if ( compression != TIFFConstants.COMPRESSION_NONE )
                        outBuf = new Bytes( ( w * bitsPerSample * samplePerPixel + 7 ) / 8 * height );

                    if ( reverse )
                        TIFFFaxDecoder.reverseBits( im );

                    switch ( compression )
                    {
                        case TIFFConstants.COMPRESSION_DEFLATE:
                        case TIFFConstants.COMPRESSION_ADOBE_DEFLATE:
                            inflate( im, outBuf );
                            break;
                        case TIFFConstants.COMPRESSION_NONE:
                            outBuf = im;
                            break;
                        case TIFFConstants.COMPRESSION_PACKBITS:
                            decodePackbits( im, outBuf );
                            break;
                        case TIFFConstants.COMPRESSION_LZW:
                            lzwDecoder.decode( im, outBuf, height );
                            break;
                    }

                    if ( bitsPerSample == 1 && samplePerPixel == 1 )
                    {
                        g4.fax4Encode2( outBuf, height );
                    } else
                    {
                        //zip.write(outBuf);
                        zip.writeBytes( outBuf.buffer, 0, outBuf.length );
                    }
                    rowsLeft -= rowsStrip;
                }

                if ( bitsPerSample == 1 && samplePerPixel == 1 )
                {
                    img = ImageElement.getCCITTInstance( w, h, false, ImageElement.CCITTG4, photometric == TIFFConstants.PHOTOMETRIC_MINISBLACK ? ImageElement.
                            CCITT_BLACKIS1 : 0, g4.close() );
                } else
                {
                    zip.compress();
                    //zip.close();
					img = ImageElement.getRawInstance( w, h, samplePerPixel, bitsPerSample, zip, null );
                    img.deflated = true;
                }
            }
			
            img.setDpi( dpiX, dpiY );
			var fd: TIFFField;

            if ( compression != TIFFConstants.COMPRESSION_OJPEG && compression != TIFFConstants.COMPRESSION_JPEG )
            {
                if ( dir.isTagPresent( TIFFConstants.TIFFTAG_ICCPROFILE ) )
                {
                    try
                    {
                        fd = dir.getField( TIFFConstants.TIFFTAG_ICCPROFILE );
                            //ICC_Profile icc_prof = ICC_Profile.getInstance(fd.getAsBytes());
                            //if (samplePerPixel == icc_prof.getNumComponents())
                            //	img.tagICC(icc_prof);
                    } catch ( e: RuntimeError )
                    {
                        //empty
                    }
                }

                if ( dir.isTagPresent( TIFFConstants.TIFFTAG_COLORMAP ) )
                {
                    fd = dir.getField( TIFFConstants.TIFFTAG_COLORMAP );
                    var rgb: Vector.<uint> = fd.getAsChars();
                    var palette: Bytes = new Bytes( rgb.length );
                    var gColor: int = rgb.length / 3;
                    var bColor: int = gColor * 2;

                    for ( k = 0; k < gColor; ++k )
                    {
                        palette[k * 3] = ByteBuffer.intToByte( rgb[k] >>> 8 );
                        palette[k * 3 + 1] = ByteBuffer.intToByte( rgb[k + gColor] >>> 8 );
                        palette[k * 3 + 2] = ByteBuffer.intToByte( rgb[k + bColor] >>> 8 );
                    }
                    var indexed: PdfArray = new PdfArray();
                    indexed.add( PdfName.INDEXED );
                    indexed.add( PdfName.DEVICERGB );
                    indexed.add( new PdfNumber( gColor - 1 ) );
                    indexed.add( new PdfString( palette ) );
                    var additional: PdfDictionary = new PdfDictionary();
                    additional.put( PdfName.COLORSPACE, indexed );
                    img.additional = additional;
                }
                img.originalType = ImageElement.ORIGINAL_TIFF;
            }

            if ( photometric == TIFFConstants.PHOTOMETRIC_MINISWHITE )
                img.inverted = true;

            if ( rotation != 0 )
                img.initialRotation = rotation;
            return img;
        }

        public static function decodePackbits( data: Bytes, dst: Bytes ): void
        {
            var srcCount: int = 0;
            var dstCount: int = 0;
            var repeat: int;
            var b: int;
			var i: int;

            try
            {
                while ( dstCount < dst.length )
                {
                    b = data[srcCount++];

                    if ( b >= 0 && b <= 127 )
                    {
                        for ( i = 0; i < ( b + 1 ); i++ )
                        {
                            dst[dstCount++] = data[srcCount++];
                        }
                    } else if ( b <= -1 && b >= -127 )
                    {
                        repeat = data[srcCount++];

                        for ( i = 0; i < ( -b + 1 ); i++ )
                        {
                            dst[dstCount++] = repeat;
                        }
                    } else
                    {
                        srcCount++;
                    }
                }
            } catch ( e: Error )
            {
            }
        }
		
		public static function inflate( deflated: Bytes, inflated: Bytes ): void
		{
			var inflater: ZStream = new ZStream();
			inflater.next_in = deflated.buffer;
			inflater.next_out = inflated.buffer;
			inflater.inflate( deflated.length );
		}
    }
}