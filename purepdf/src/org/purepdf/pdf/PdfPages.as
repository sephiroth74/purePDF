/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: PdfPages.as 251 2010-02-02 19:31:26Z alessandro.crugnola $
* $Author Alessandro Crugnola $
* $Rev: 251 $ $LastChangedDate: 2010-02-02 14:31:26 -0500 (Tue, 02 Feb 2010) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/pdf/PdfPages.as $
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
	
	import org.purepdf.utils.pdf_core;
	

	public class PdfPages extends ObjectHash
	{
		private var writer: PdfWriter;
		private var pages: Vector.<PdfIndirectReference> = new Vector.<PdfIndirectReference>();
		private var parents: Vector.<PdfIndirectReference> = new Vector.<PdfIndirectReference>();
		private var leafSize: int = 10;
		private var topParent: PdfIndirectReference;
		
		use namespace pdf_core;
		
		public function PdfPages( $writer: PdfWriter )
		{
			writer = $writer;
		}
		
		public function getTopParent(): PdfIndirectReference
		{
			return topParent;
		}
		
		public function addPage( page: PdfDictionary ): void
		{
			if(( pages.length % leafSize ) == 0 )
				parents.push( writer.pdfIndirectReference );
			
			var parent: PdfIndirectReference = parents[ parents.length - 1] as PdfIndirectReference;
			page.put( PdfName.PARENT, parent );
			var current: PdfIndirectReference = writer.getCurrentPage();
			writer.addToBody1( page, current );
			pages.push( current );
		}
		
		public function addPageRef( pageRef: PdfIndirectReference ): PdfIndirectReference
		{
			if( ( pages.length % leafSize ) == 0 )
				parents.push( writer.pdfIndirectReference );
			pages.push( pageRef );
			return parents[ (parents.length - 1) ];
		}
		
		public function writePageTree(): PdfIndirectReference
		{
			if( pages.length == 0 )
				throw new Error("The document has no pages");
			
			var leaf: int = 1;
			var tParents: Vector.<PdfIndirectReference> = parents;
			var tPages: Vector.<PdfIndirectReference> = pages;
			var nextParents: Vector.<PdfIndirectReference> = new Vector.<PdfIndirectReference>();
			
			while( true )
			{
				leaf *= leafSize;
				var stdCount: int = leafSize;
				var rightCount: int = tPages.length % leafSize;
				if( rightCount == 0 )
					rightCount = leafSize;
				
				for( var p: int = 0; p < tParents.length; ++p )
				{
					var count: int;
					var thisLeaf: int = leaf;
					if( p == ( tParents.length - 1 ) )
					{
						count = rightCount;
						thisLeaf = pages.length % leaf;
						if( thisLeaf == 0 )
							thisLeaf = leaf;
					} else {
						count = stdCount;
					}
					
					var top: PdfDictionary = new PdfDictionary( PdfName.PAGES );
					top.put( PdfName.COUNT, new PdfNumber( thisLeaf ) );
					var kids: PdfArray = new PdfArray();
					var internalArray: Vector.<PdfObject> = kids.getArrayList();
					var tmp: Vector.<PdfIndirectReference> = tPages.slice( p * stdCount, p * stdCount + count );
					
					for( var a: int = 0; a < tmp.length; a++ )
						internalArray.push( tmp[a] );
					
					top.put( PdfName.KIDS, kids );
					//top.put( PdfName.ROTATE, new PdfNumber(180) );
					if( tParents.length > 1 )
					{
						if( (p % leafSize) == 0 )
							nextParents.push( writer.pdfIndirectReference );
						top.put( PdfName.PARENT, nextParents[ int(p / leafSize) ] );
					} else {
						top.put( PdfName.PUREPDF, new PdfString( PdfWriter.RELEASE ) );
					}
					
					writer.addToBody1( top, tParents[p] );
				}
				
				if( tParents.length == 1 ){
					topParent = tParents[0];
					return topParent;
				}
				
				tPages = tParents;
				tParents = nextParents;
				nextParents = new Vector.<PdfIndirectReference>();
			}
			
			return null;
		}
	}
}