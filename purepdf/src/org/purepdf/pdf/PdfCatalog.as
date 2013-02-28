/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: PdfCatalog.as 242 2010-02-01 14:30:41Z alessandro.crugnola $
* $Author Alessandro Crugnola $
* $Rev: 242 $ $LastChangedDate: 2010-02-01 09:30:41 -0500 (Mon, 01 Feb 2010) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/pdf/PdfCatalog.as $
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
	import it.sephiroth.utils.Entry;
	import it.sephiroth.utils.HashMap;
	import it.sephiroth.utils.collections.iterators.Iterator;
	
	import org.purepdf.errors.ConversionError;
	import org.purepdf.utils.pdf_core;

	public class PdfCatalog extends PdfDictionary
	{
		use namespace pdf_core;
		
		private var writer: PdfWriter;

		public function PdfCatalog( $pages: PdfIndirectReference, $writer: PdfWriter )
		{
			super( CATALOG );
			writer = $writer;
			put( PdfName.PAGES, $pages );
		}
		
		public function setAdditionalActions( actions: PdfDictionary ): void
		{
			try
			{
				put( PdfName.AA, writer.addToBody( actions ).indirectReference );
			} catch( e: Error )
			{
				throw new ConversionError(e);
			}
		}

		public function addNames( localDestinations: HashMap, documentLevelJS: HashMap, documentFileAttachment: HashMap,
						writer: PdfWriter ): void
		{
			if ( localDestinations.isEmpty() && documentLevelJS.isEmpty() && documentFileAttachment.isEmpty() )
				return;

			try
			{
				var names: PdfDictionary = new PdfDictionary();

				if ( !localDestinations.isEmpty() )
				{
					var ar: PdfArray = new PdfArray();

					for ( var i: Iterator = localDestinations.entrySet().iterator(); i.hasNext();  )
					{
						var entry: Entry = Entry( i.next() );
						var name: String = String( entry.getKey() );
						var obj: Vector.<Object> = entry.getValue() as Vector.<Object>;

						if ( obj[2] == null ) //no destination
							continue;
						var ref: PdfIndirectReference = PdfIndirectReference( obj[1] );
						ar.add( new PdfString( name, null ) );
						ar.add( ref );
					}

					if ( ar.size > 0 )
					{
						var dests: PdfDictionary = new PdfDictionary();
						dests.put( PdfName.NAMES, ar );
						names.put( PdfName.DESTS, writer.addToBody( dests ).indirectReference );
					}
				}

				if ( !documentLevelJS.isEmpty() )
				{
					var tree: PdfDictionary = PdfNameTree.writeTree( documentLevelJS, writer );
					names.put( PdfName.JAVASCRIPT, writer.addToBody( tree ).indirectReference );
				}

				if ( !documentFileAttachment.isEmpty() )
				{
					names.put( PdfName.EMBEDDEDFILES, writer.addToBody( PdfNameTree.writeTree( documentFileAttachment,
									writer ) ).indirectReference );
				}

				if ( names.size > 0 )
					put( PdfName.NAMES, writer.addToBody( names ).indirectReference );
			} catch ( e: Error )
			{
				trace( e.getStackTrace() );
				throw new ConversionError( e );
			}
		}
	}
}