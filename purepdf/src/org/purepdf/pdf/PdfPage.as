/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: PdfPage.as 238 2010-01-31 10:49:33Z alessandro.crugnola $
* $Author Alessandro Crugnola $
* $Rev: 238 $ $LastChangedDate: 2010-01-31 05:49:33 -0500 (Sun, 31 Jan 2010) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/pdf/PdfPage.as $
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
	import it.sephiroth.utils.HashMap;

	public class PdfPage extends PdfDictionary
	{
		private static const boxStrings: Vector.<String> = Vector.<String>(["crop", "trim", "art", "bleed"]);
		private static const boxNames: Vector.<PdfName> = Vector.<PdfName>([ PdfName.CROPBOX, PdfName.TRIMBOX, PdfName.ARTBOX, PdfName.BLEEDBOX ]);
		
		public static const PORTRAIT: PdfNumber = new PdfNumber( 0 );
		public static const LANDSCAPE: PdfNumber = new PdfNumber( 90 );
		public static const INVERTEDPORTRAIT: PdfNumber = new PdfNumber( 180 );
		public static const SEASCAPE: PdfNumber = new PdfNumber( 270 );
		
		protected var mediaBox: PdfRectangle;
		
		public function PdfPage( $mediaBox: PdfRectangle, boxSize: HashMap, resources: PdfDictionary, rotate: int )
		{
			super( PAGE );
			mediaBox = $mediaBox;
			put( PdfName.MEDIABOX, mediaBox );
			put( PdfName.RESOURCES, resources );
			
			if( rotate != 0 )
			{
				put( PdfName.ROTATE, new PdfNumber( rotate ) );
			}
			
			for( var k: int = 0; k < boxStrings.length; ++k )
			{
				var rect: PdfObject;
				if( boxSize.hasOwnProperty( boxStrings[k] ) )
					put( boxNames[k], boxSize[ boxStrings[k] ] );
			}
		}
		
		public function isParent(): Boolean
		{
			return false;
		}
		
		/**
		 * Adds an indirect reference pointing to a <CODE>PdfContents</CODE>-object.
		 *
		 * @param	contents		an indirect reference to a <CODE>PdfContents</CODE>-object
		 */
		
		public function add( contents: PdfIndirectReference ): void
		{
			put( PdfName.CONTENTS, contents );
		}
		
		/**
		 * Rotates the mediabox, but not the text in it.
		 *
		 * @return		a <CODE>PdfRectangle</CODE>
		 */
		public function rotateMediaBox(): PdfRectangle
		{
			this.mediaBox = mediaBox.rotate();
			put( PdfName.MEDIABOX, this.mediaBox );
			return this.mediaBox;
		}
		
		public function getMediaBox(): PdfRectangle
		{
			return mediaBox;
		}
	}
}