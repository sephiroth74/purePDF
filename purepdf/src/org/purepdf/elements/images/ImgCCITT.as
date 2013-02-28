/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: ImgCCITT.as 238 2010-01-31 10:49:33Z alessandro.crugnola $
* $Author Alessandro Crugnola $
* $Rev: 238 $ $LastChangedDate: 2010-01-31 05:49:33 -0500 (Sun, 31 Jan 2010) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/elements/images/ImgCCITT.as $
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
	import org.purepdf.elements.Element;
	import org.purepdf.errors.BadElementError;
	import org.purepdf.pdf.codec.TIFFFaxDecoder;
	import org.purepdf.utils.Bytes;

	public class ImgCCITT extends ImageElement
	{
		/** 
		 * Creates an Image with CCITT compression.
		 *
		 * @param width the exact width of the image
		 * @param height the exact height of the image
		 * @param reverseBits reverses the bits
		 * @param typeCCITT the type of compression in data. It can be CCITTG4, CCITTG31D, CCITTG32D
		 * @param parameters parameters associated with this stream. Possible values are
		 * 						CCITT_BLACKIS1, CCITT_ENCODEDBYTEALIGN, CCITT_ENDOFLINE and CCITT_ENDOFBLOCK or a combination of them
		 * @param data the image data
		 * @throws BadElementError
		 */
		
		public function ImgCCITT( image: ImgCCITT, width: int, height: int, reverseBits: Boolean, typeCCITT: int, parameters: int, data: Bytes )
		{
			super( image == null ? null : image );
			_type = Element.IMGRAW;
			
			if( image == null )
			{
				if (typeCCITT != CCITTG4 && typeCCITT != CCITTG3_1D && typeCCITT != CCITTG3_2D )
					throw new BadElementError("the ccitt compression type must be ccittg4 ccittg3_1d or ccittg3_2d");
				if (reverseBits)
					TIFFFaxDecoder.reverseBits( data );
				_scaledHeight = height;
				setTop( scaledHeight );
				_scaledWidth = width;
				setRight( scaledWidth );
				_colorspace = parameters;
				_bpc = typeCCITT;
				_rawData = data.buffer;
				plainWidth = this.width;
				plainHeight = this.height;
			}
		}
	}
}