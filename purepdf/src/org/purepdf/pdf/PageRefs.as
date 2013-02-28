/*
*                             ______ _____  _______
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|
* |__|
* $Id: PageRefs.as 350 2010-02-24 23:57:29Z alessandro.crugnola $
* $Author Alessandro Crugnola $
* $Rev: 350 $ $LastChangedDate: 2010-02-24 18:57:29 -0500 (Wed, 24 Feb 2010) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/pdf/PageRefs.as $
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

	public class PageRefs
	{
		private var _keepPages: Boolean;
		private var _reader: PdfReader;
		private var lastPageRead: int = -1;
		private var pageInh: Vector.<PdfDictionary>;
		private var refsn: Vector.<PRIndirectReference>;
		private var refsp: HashMap;
		private var sizep: int;

		public function PageRefs( reader: PdfReader )
		{
			this._reader = reader;
			if ( reader.partial )
			{
				refsp = new HashMap();
				var npages: PdfNumber = PdfNumber( PdfReader.getPdfObjectRelease( reader.rootPages.getValue( PdfName.COUNT ) ) );
				sizep = npages.intValue();
			} else
			{
				readPages();
			}
		}

		/**
		   /**
		 * Gets the dictionary that represents a page.
		 * @param pageNum the page number. 1 is the first
		 * @return the page dictionary
		 */
		public function getPageN( pageNum: int ): PdfDictionary
		{
			var ref: PRIndirectReference = getPageOrigRef( pageNum );
			return PdfDictionary( PdfReader.getPdfObject( ref ) );
		}

		/**
		 * @param pageNum
		 * @return a dictionary object
		 */
		public function getPageNRelease( pageNum: int ): PdfDictionary
		{
			var page: PdfDictionary = getPageN( pageNum );
			releasePage( pageNum );
			return page;
		}

		/**
		 * Gets the page reference to this page.
		 * @param pageNum the page number. 1 is the first
		 * @return the page reference
		 */
		public function getPageOrigRef( pageNum: int ): PRIndirectReference
		{
			try
			{
				--pageNum;
				if ( pageNum < 0 || pageNum >= size )
					return null;
				if ( refsn != null )
					return refsn[pageNum];
				else
				{
					var n: int = refsp.getValue( pageNum ) as int;
					if ( n == 0 )
					{
						var ref: PRIndirectReference = getSinglePage( pageNum );
						if ( reader.lastXrefPartial == -1 )
							lastPageRead = -1;
						else
							lastPageRead = pageNum;
						reader.lastXrefPartial = -1;
						refsp.put( pageNum, ref.number );
						if ( _keepPages )
							lastPageRead = -1;
						return ref;
					} else
					{
						if ( lastPageRead != pageNum )
							lastPageRead = -1;
						if ( _keepPages )
							lastPageRead = -1;
						
						var res: PRIndirectReference = new PRIndirectReference( PdfObject.INDIRECT, n );
						res.reader = reader;
						return res;
					}
				}
			} catch ( e: Error )
			{
				throw new ConversionError( e );
			}
			return null;
		}

		/**
		 * @param pageNum
		 * @return an indirect reference
		 */
		public function getPageOrigRefRelease( pageNum: int ): PRIndirectReference
		{
			var ref: PRIndirectReference = getPageOrigRef( pageNum );
			releasePage( pageNum );
			return ref;
		}

		public function get reader(): PdfReader
		{
			return _reader;
		}

		/**
		 * @param pageNum
		 */
		public function releasePage( pageNum: int ): void
		{
			if ( refsp == null )
				return;
			--pageNum;
			if ( pageNum < 0 || pageNum >= size )
				return;
			if ( pageNum != lastPageRead )
				return;
			lastPageRead = -1;
			_reader.lastXrefPartial = refsp.getValue( pageNum ) as int;
			_reader.releaseLastXrefPartial();
			refsp.remove( pageNum );
		}

		public function resetReleasePage(): void
		{
			if ( refsp == null )
				return;
			lastPageRead = -1;
		}

		protected function getSinglePage( n: int ): PRIndirectReference
		{
			var acc: PdfDictionary = new PdfDictionary();
			var top: PdfDictionary = _reader.rootPages;
			var base: int = 0;
			while ( true )
			{
				for ( var k: int = 0; k < PdfReader.pageInhCandidates.length; ++k )
				{
					var obj: PdfObject = top.getValue( PdfReader.pageInhCandidates[k] );
					if ( obj != null )
						acc.put( PdfReader.pageInhCandidates[k], obj );
				}
				var kids: PdfArray = PdfReader.getPdfObjectRelease( top.getValue( PdfName.KIDS ) ) as PdfArray;
				for ( var it: Iterator = kids.listIterator(); it.hasNext();  )
				{
					var ref: PRIndirectReference = PRIndirectReference( it.next() );
					var dic: PdfDictionary = PdfDictionary( PdfReader.getPdfObject( ref ) );
					var last: int = _reader.lastXrefPartial;
					var count: PdfObject = PdfReader.getPdfObjectRelease( dic.getValue( PdfName.COUNT ) );
					_reader.lastXrefPartial = last;
					var acn: int = 1;
					if ( count != null && count.getType() == PdfObject.NUMBER )
						acn = PdfNumber( count ).intValue();
					if ( n < base + acn )
					{
						if ( count == null )
						{
							dic.mergeDifferent( acc );
							return ref;
						}
						_reader.releaseLastXrefPartial();
						top = dic;
						break;
					}
					_reader.releaseLastXrefPartial();
					base += acn;
				}
			}
			return null;
		}

		internal function insertPage( pageNum: int, ref: PRIndirectReference ): void
		{
			--pageNum;
			if ( refsn != null )
			{
				if ( pageNum >= refsn.length )
					refsn.push( ref );
				else
					refsn[pageNum] = ref;
			} else
			{
				++sizep;
				lastPageRead = -1;
				if ( pageNum >= size )
				{
					refsp.put( size, ref.number );
				} else
				{
					var refs2: HashMap = new HashMap( ( refsp.size + 1 ) * 2 );
					for ( var it: Iterator = refsp.entrySet().iterator(); it.hasNext();  )
					{
						var entry: Entry = Entry( it.next() );
						var p: int = entry.key as int;
						refs2.put( p >= pageNum ? p + 1 : p, entry.value );
					}
					refs2.put( pageNum, ref.number );
					refsp = refs2;
				}
			}
		}

		internal function keepPages(): void
		{
			if ( refsp == null || _keepPages )
				return;
			_keepPages = true;
			refsp.clear();
		}

		internal function reReadPages(): void
		{
			refsn = null;
			readPages();
		}

		internal function readPages(): void
		{
			if ( refsn != null )
				return;
			refsp = null;
			refsn = new Vector.<PRIndirectReference>();
			pageInh = new Vector.<PdfDictionary>();
			iteratePages( _reader.catalog.getValue( PdfName.PAGES ) as PRIndirectReference );
			pageInh = null;
			_reader.rootPages.put( PdfName.COUNT, new PdfNumber( refsn.length ) );
		}

		internal function get size(): int
		{
			if ( refsn != null )
				return refsn.length;
			else
				return sizep;
		}


		private function iteratePages( rpage: PRIndirectReference ): void
		{
			var page: PdfDictionary = PdfDictionary( PdfReader.getPdfObject( rpage ) );
			var kidsPR: PdfArray = page.getAsArray( PdfName.KIDS );

			if ( kidsPR == null )
			{
				page.put( PdfName.TYPE, PdfName.PAGE );
				var dic: PdfDictionary = pageInh[pageInh.length - 1];
				var key: PdfName;
				for ( var i: Iterator = dic.getKeys().iterator(); i.hasNext();  )
				{
					key = i.next() as PdfName;
					if ( page.getValue( key ) == null )
						page.put( key, dic.getValue( key ) );
				}
				if ( page.getValue( PdfName.MEDIABOX ) == null )
				{
					var arr: PdfArray = new PdfArray( Vector.<Number>( [ 0, 0, PageSize.LETTER.getRight(), PageSize.LETTER.getTop() ] ) );
					page.put( PdfName.MEDIABOX, arr );
				}
				refsn.push( rpage );
			}
			// reference to a branch
			else
			{
				page.put( PdfName.TYPE, PdfName.PAGES );
				pushPageAttributes( page );
				for ( var k: int = 0; k < kidsPR.size; ++k )
				{
					var obj: PdfObject = kidsPR.getPdfObject( k );
					if ( !obj.isIndirect() )
					{
						while ( k < kidsPR.size )
							kidsPR.remove( k );
						break;
					}
					iteratePages( PRIndirectReference( obj ) );
				}
				popPageAttributes();
			}
		}

		/**
		 * Removes the last PdfDictionary that was pushed to the pageInh stack.
		 */
		private function popPageAttributes(): void
		{
			pageInh.splice( pageInh.indexOf( pageInh.length - 1 ), 1 );
		}

		/**
		 * Adds a PdfDictionary to the pageInh stack to keep track of the page attributes.
		 * @param nodePages	a Pages dictionary
		 */
		private function pushPageAttributes( nodePages: PdfDictionary ): void
		{
			var dic: PdfDictionary = new PdfDictionary();
			if ( pageInh.length > 0 )
			{
				dic.putAll( pageInh[pageInh.length - 1] );
			}
			for ( var k: int = 0; k < PdfReader.pageInhCandidates.length; ++k )
			{
				var obj: PdfObject = nodePages.getValue( PdfReader.pageInhCandidates[k] );
				if ( obj != null )
					dic.put( PdfReader.pageInhCandidates[k], obj );
			}
			pageInh.push( dic );
		}
	}
}