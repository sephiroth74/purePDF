/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: PdfBody.as 274 2010-02-06 17:36:29Z alessandro.crugnola $
* $Author Alessandro Crugnola $
* $Rev: 274 $ $LastChangedDate: 2010-02-06 12:36:29 -0500 (Sat, 06 Feb 2010) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/pdf/PdfBody.as $
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
	import it.sephiroth.utils.collections.iterators.Iterator;
	
	import org.purepdf.collections.PdfCrossReferenceCollection;
	import org.purepdf.io.OutputStreamCounter;

	/**
	 * This class generates the structure of a PDF document.
	 *
	 * @see		PdfWriter
	 * @see		PdfObject
	 * @see		PdfIndirectObject
	 */
	public class PdfBody extends ObjectHash
	{
		private static const OBJSINSTREAM: int = 200;
		private var currentObjNum: int;
		private var index: ByteBuffer;
		private var numObj: int = 0;
		private var position: int;
		private var _refnum: int;
		private var streamObjects: ByteBuffer;
		private var writer: PdfWriter;
		
		//private var xrefs: TreeSet;
		private var xrefs: PdfCrossReferenceCollection;

		public function PdfBody( $writer: PdfWriter )
		{
			writer = $writer;
			xrefs = new PdfCrossReferenceCollection();
			xrefs.add( new PdfCrossReference( 0, 0, 0, PdfWriter.GENERATION_MAX ) );
			position = writer.getOs().getCounter();
			_refnum = 1;
		}

		public function add( object: PdfObject, refNumber: int, inObjStm: Boolean=true ): PdfIndirectObject
		{
			var indirect: PdfIndirectObject;
			var pxref: PdfCrossReference;

			if ( inObjStm && object.canBeInObjStm() && writer.isFullCompression() )
			{
				pxref = addToObjStm( object, refNumber );
				indirect = new PdfIndirectObject( refNumber, 0, object, writer );

				if ( !xrefs.add( pxref ) )
				{
					xrefs.remove( pxref );
					xrefs.add( pxref );
				}
				return indirect;
			}
			else
			{
				indirect = new PdfIndirectObject( refNumber, 0, object, writer );
				pxref = new PdfCrossReference( 1, refNumber, position, 0 );

				if ( !xrefs.add( pxref ) )
				{
					xrefs.remove( pxref );
					xrefs.add( pxref );
				}
				indirect.writeTo( writer.getOs() );
				position = writer.getOs().getCounter();
				return indirect;
			}
		}

		public function add1( object: PdfObject ): PdfIndirectObject
		{
			return add( object, indirectReferenceNumber );
		}

		public function add2( object: PdfObject, inObjStm: Boolean ): PdfIndirectObject
		{
			return add( object, indirectReferenceNumber, inObjStm );
		}

		public function add3( object: PdfObject, ref: PdfIndirectReference ): PdfIndirectObject
		{
			return add4( object, ref.number );
		}

		public function add4( object: PdfObject, refNumber: int ): PdfIndirectObject
		{
			return add( object, refNumber, true ); // to false
		}

		public function add5( object: PdfObject, ref: PdfIndirectReference, inObjStm: Boolean ): PdfIndirectObject
		{
			return add( object, ref.number, inObjStm );
		}

		public function addToObjStm( obj: PdfObject, nObj: int ): PdfCrossReference
		{
			if ( numObj >= OBJSINSTREAM )
				flushObjStm();

			if ( index == null )
			{
				index = new ByteBuffer();
				streamObjects = new ByteBuffer();
				currentObjNum = indirectReferenceNumber;
				numObj = 0;
			}
			var p: int = streamObjects.size;
			var idx: int = numObj++;
			var enc: PdfEncryption = writer.getEncryption();
			writer.setEncryption( null );
			obj.toPdf( writer, streamObjects );
			writer.setEncryption( enc );
			streamObjects.append_char( ' ' );
			index.append( nObj ).append_char( ' ' ).append( p ).append_char( ' ' );
			return new PdfCrossReference( 2, nObj, currentObjNum, idx );
		}

		public function flushObjStm(): void
		{
			if ( numObj == 0 )
				return;
			var first: int = index.size;
			index.append_bytebuffer( streamObjects );
			var stream: PdfStream = new PdfStream( index.toByteArray() );
			stream.flateCompress( writer.compressionLevel );
			stream.put( PdfName.TYPE, PdfName.OBJSTM );
			stream.put( PdfName.N, new PdfNumber( numObj ) );
			stream.put( PdfName.FIRST, new PdfNumber( first ) );
			add( stream, currentObjNum );
			index = null;
			streamObjects = null;
			numObj = 0;
		}

		public function get indirectReferenceNumber(): int
		{
			var n: int = _refnum++;
			xrefs.add( new PdfCrossReference( 0, n, 0, PdfWriter.GENERATION_MAX ) );
			return n;
		}

		/**
		 * Gets a PdfIndirectReference for an object that will be created in the future.
		 */
		public function get pdfIndirectReference(): PdfIndirectReference
		{
			return new PdfIndirectReference( 0, indirectReferenceNumber, 0 );
		}

		public function get offset(): int
		{
			return position;
		}

		/**
		 * Returns the total number of objects contained in the CrossReferenceTable of this <CODE>Body</CODE>.
		 */
		public function get size(): int
		{
			return Math.max( xrefs.last.refnum + 1, _refnum );
		}

		public function writeCrossReferenceTable( os: OutputStreamCounter, root: PdfIndirectReference, info: PdfIndirectReference, encryption: PdfIndirectReference, fileID: PdfObject, prevxref: int ): void
		{
			var refNumber: int = 0;

			if ( writer.isFullCompression() )
			{
				flushObjStm();
				refNumber = indirectReferenceNumber;
				xrefs.add( new PdfCrossReference( 1, refNumber, position, 0 ) );
			}
			var i: Iterator;
			var entry: PdfCrossReference = xrefs.first;
			var first: int = entry.refnum;
			var len: int = 0;
			var sections: Vector.<int> = new Vector.<int>();
			i = xrefs.iterator();

			while ( i.hasNext() )
			{
				entry = PdfCrossReference( i.next() );

				if ( first + len == entry.refnum )
				{
					++len;
				}
				else
				{
					sections.push( first );
					sections.push( len );
					first = entry.refnum;
					len = 1;
				}
			}
			sections.push( first );
			sections.push( len );

			if ( writer.isFullCompression() )
			{
				var mid: int = 4;
				var mask: int = 0xff000000;
				for( ; mid > 1; --mid )
				{
					if(( mask & position ) != 0 )
						break;
					mask >>>= 8;
				}
				var buf: ByteBuffer = new ByteBuffer();
				
				for( i = xrefs.iterator(); i.hasNext(); )
				{
					entry = PdfCrossReference( i.next() );
					entry.midSizeToPdf( mid, buf );
				}
				
				var xr: PdfStream = new PdfStream( buf.toByteArray() );
				buf = null;
				xr.flateCompress( writer.compressionLevel );
				xr.put( PdfName.SIZE, new PdfNumber( size ) );
				xr.put( PdfName.ROOT, root );
				if( info != null )
					xr.put( PdfName.INFO, info );
				if( encryption != null )
					xr.put( PdfName.ENCRYPT, encryption );
				if( fileID != null )
					xr.put( PdfName.ID, fileID );
				xr.put( PdfName.W, new PdfArray( Vector.<int>([1, mid, 2]) ) );
				xr.put( PdfName.TYPE, PdfName.XREF );
				var idx: PdfArray = new PdfArray();
				for (k = 0; k < sections.length; ++k )
					idx.add( new PdfNumber( sections[k] ) );
				xr.put( PdfName.INDEX, idx );
				if( prevxref > 0 )
					xr.put( PdfName.PREV, new PdfNumber( prevxref ) );
				var enc: PdfEncryption = writer.crypto;
				writer.crypto = null;
				var indirect: PdfIndirectObject = new PdfIndirectObject( refNumber, 0, xr, writer );
				indirect.writeTo( writer.getOs() );
				writer.crypto = enc;
			}
			else
			{
				os.writeBytes( PdfWriter.getISOBytes( "xref\n" ) );
				i = xrefs.iterator();

				for ( var k: int = 0; k < sections.length; k += 2 )
				{
					first = sections[ k ];
					len = sections[ k + 1 ];
					os.writeBytes( PdfWriter.getISOBytes( first.toString() ) );
					os.writeBytes( PdfWriter.getISOBytes( " " ) );
					os.writeBytes( PdfWriter.getISOBytes( len.toString() ) );
					os.writeInt( '\n'.charCodeAt( 0 ) );

					while ( len-- > 0 )
					{
						entry = PdfCrossReference( i.next() );
						entry.toPdf( os );
					}
				}
			}
		}
	}
}