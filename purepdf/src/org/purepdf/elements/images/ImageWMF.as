/*
 *                             ______ _____  _______
 * .-----..--.--..----..-----.|   __ \     \|    ___|
 * |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
 * |   __||_____||__|  |_____||___|  |_____/|___|
 * |__|
 * $Id: ImageWMF.as 362 2010-05-05 16:53:53Z alessandro.crugnola $
 * $Author Alessandro Crugnola $
 * $Rev: 362 $ $LastChangedDate: 2010-05-05 12:53:53 -0400 (Wed, 05 May 2010) $
 * $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/elements/images/ImageWMF.as $
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
	import flash.utils.ByteArray;
	
	import org.purepdf.codecs.wmf.InputMeta;
	import org.purepdf.codecs.wmf.MetaDo;
	import org.purepdf.elements.Element;
	import org.purepdf.errors.BadElementError;
	import org.purepdf.io.ByteArrayInputStream;
	import org.purepdf.io.InputStream;
	import org.purepdf.pdf.PdfTemplate;

	public class ImageWMF extends ImageElement
	{
		public function ImageWMF( obj: Object ): void
		{
			super( obj is ByteArray ? null : ( obj is ImageElement ? obj : null ) );
			
			if( obj is ByteArray )
			{
				var buffer: ByteArray = ByteArray( obj );
				buffer.position = 0;
				_rawData = buffer;
				_originalData = buffer;
				processParameters();
				_rawData.position = 0;
			} else if( obj is ImageWMF )
			{
			} else {
				throw new ArgumentError("invalid parameter passed");
			}

		}

		/**
		 * @throws IOError
		 */
		private function processParameters(): void
		{
			_type = Element.IMGTEMPLATE;
			_originalType = ORIGINAL_WMF;

			try
			{
				var errorID: String;
				var ist: ByteArrayInputStream = new ByteArrayInputStream( rawData );
				var input: InputMeta = new InputMeta( ist );
				var t: int = input.readInt();

				if ( t != -1698247209 )
				{
					throw new BadElementError( errorID + " is not a valid placeable windows metafile" );
				}

				input.readWord();
				var left: int = input.readShort();
				var top: int = input.readShort();
				var right: int = input.readShort();
				var bottom: int = input.readShort();
				var inch: int = input.readWord();
				dpiX = 72;
				dpiY = 72;
				_scaledHeight = Number( bottom - top ) / inch * 72;
				setTop( scaledHeight );
				_scaledWidth = Number( right - left ) / inch * 72;
				setRight( scaledWidth );
			} catch ( e: Error )
			{
			} finally
			{
				plainWidth = width;
				plainHeight = height;
			}
		}
		
		/** 
		 * Reads the WMF into a template.
		 * @param template the template to read to
		 * @throws IOError on error
		 * @throws DocumentError on error
		 */    
		public function readWMF( template: PdfTemplate ): void
		{
			templateData = template;
			template.width = width;
			template.height = height;
			var ist: InputStream;
			try 
			{
				ist = new ByteArrayInputStream( rawData );
				var meta: MetaDo = new MetaDo( ist, template );
				meta.readAll();
			} catch( e: Error ){
				trace(e);
			}
		}
	}
}