/*
 *                             ______ _____  _______
 * .-----..--.--..----..-----.|   __ \     \|    ___|
 * |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
 * |   __||_____||__|  |_____||___|  |_____/|___|
 * |__|
 * $Id: PdfReader.as 370 2010-05-27 06:48:13Z alessandro.crugnola $
 * $Author Alessandro Crugnola $
 * $Rev: 370 $ $LastChangedDate: 2010-05-27 02:48:13 -0400 (Thu, 27 May 2010) $
 * $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/pdf/PdfReader.as $
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
	import flash.errors.EOFError;
	import flash.errors.IOError;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	
	import it.sephiroth.utils.Entry;
	import it.sephiroth.utils.HashMap;
	import it.sephiroth.utils.ObjectHash;
	import it.sephiroth.utils.collections.iterators.Iterator;
	
	import org.purepdf.elements.RectangleElement;
	import org.purepdf.errors.ConversionError;
	import org.purepdf.errors.InvalidPdfError;
	import org.purepdf.errors.NonImplementatioError;
	import org.purepdf.errors.RuntimeError;
	import org.purepdf.errors.UnsupportedPdfError;
	import org.purepdf.io.ByteArrayInputStream;
	import org.purepdf.io.DataInputStream;
	import org.purepdf.io.RandomAccessFileOrArray;
	import org.purepdf.io.zip.InflaterInputStream;
	import org.purepdf.utils.Bytes;
	import org.purepdf.utils.StringUtils;

	public class PdfReader extends EventDispatcher
	{

		internal static const pageInhCandidates: Vector.<PdfName> = Vector.<PdfName>( [ PdfName.MEDIABOX, PdfName.ROTATE, PdfName.RESOURCES, PdfName.CROPBOX ] );
		private static const endobj: Bytes = PdfEncodings.convertToBytes( "endobj", null );
		private static const endstream: Bytes = PdfEncodings.convertToBytes( "endstream", null );
		public static const TIMER_STEP: int = 300;
		
		public var currentStep: int = 0;

		public var totalSteps: int = 3;

		protected var _decrypt: PdfEncryption;
		protected var _pdfVersion: int;
		protected var encrypted: Boolean = false;
		protected var eofPos: int;
		protected var lastXref: int;
		protected var objStmMark: HashMap;
		protected var objStmToOffset: HashMap;
		protected var pValue: int;
		protected var pageRefs: PageRefs;
		protected var rValue: int;
		protected var rebuilt: Boolean;
		protected var sharedStreams: Boolean = true;
		protected var strings: Vector.<PdfString> = new Vector.<PdfString>();
		protected var trailer: PdfDictionary;
		internal var catalog: PdfDictionary;
		internal var hybridXref: Boolean;
		internal var lastXrefPartial: int = -1;
		internal var newXrefType: Boolean;
		internal var partial: Boolean;
		internal var rootPages: PdfDictionary;
		internal var tokens: PRTokeniser;
		internal var xref: Vector.<int>;
		private var _appendable: Boolean;
		private var encryptionError: Boolean;
		private var fileLength: int;
		private var objGen: int;
		private var objNum: int;
		private var progressEvent: ProgressEvent = new ProgressEvent( ProgressEvent.PROGRESS, false, false, 0, 0 );
		private var readDepth: int = 0;
		private var removeUnused: Boolean;
		private var xrefObj: Vector.<PdfObject>;

		public function PdfReader( input: ByteArray )
		{
			super( null );
			tokens = new PRTokeniser( input );
		}

		public function get appendable(): Boolean
		{
			return _appendable;
		}

		public function get decrypt(): PdfEncryption
		{
			return _decrypt;
		}

		public function getCatalog(): PdfDictionary
		{
			return catalog;
		}

		/**
		 * Getter for property fileLength.
		 * @return Value of property fileLength.
		 */
		public function getFileLength(): int
		{
			return fileLength;
		}


		/**
		 * Gets the number of pages in the document.
		 * @return the number of pages in the document
		 */
		public function getNumberOfPages(): int
		{
			return pageRefs.size;
		}

		/**
		 * Gets the dictionary that represents a page.
		 * @param pageNum the page number. 1 is the first
		 * @return the page dictionary
		 */
		public function getPageN( pageNum: int ): PdfDictionary
		{
			var dic: PdfDictionary = pageRefs.getPageN( pageNum );
			if ( dic == null )
				return null;
			if ( appendable )
				dic.setIndRef( pageRefs.getPageOrigRef( pageNum ) );
			return dic;
		}

		/**
		 * Gets the page reference to this page.
		 * @param pageNum the page number. 1 is the first
		 * @return the page reference
		 */
		public function getPageOrigRef( pageNum: int ): PRIndirectReference
		{
			return pageRefs.getPageOrigRef( pageNum );
		}

		/**
		 * Gets the page rotation. This value can be 0, 90, 180 or 270.
		 * @param index the page number. The first page is 1
		 * @return the page rotation
		 */
		public function getPageRotation( index: int ): int
		{
			return _getPageRotation( pageRefs.getPageNRelease( index ) );
		}

		/**
		 * Gets the page size without taking rotation into account. This
		 * is the value of the /MediaBox key.
		 * @param index the page number. The first page is 1
		 * @return the page size
		 */
		public function getPageSize( index: int ): RectangleElement
		{
			return _getPageSize( pageRefs.getPageNRelease( index ) );
		}

		/**
		 * Gets the page size, taking rotation into account. This
		 * is a RectangleElement with the value of the /MediaBox and the /Rotate key.
		 * @param index the page number. The first page is 1
		 * @return a RectangleElement
		 */
		public function getPageSizeWithRotation( index: int ): RectangleElement
		{
			return _getPageSizeWithRotation( pageRefs.getPageNRelease( index ) );
		}

		public function getPdfObject( idx: int ): PdfObject
		{
			try
			{
				lastXrefPartial = -1;
				if ( idx < 0 || idx >= xrefObj.length )
					return null;
				var obj: PdfObject = xrefObj[idx] as PdfObject;
				if ( !partial || obj != null )
					return obj;
				if ( idx * 2 >= xref.length )
					return null;
				obj = readSingleObject( idx );
				lastXrefPartial = -1;
				if ( obj != null )
					lastXrefPartial = idx;
				return obj;
			} catch ( e: Error )
			{
				throw new ConversionError( e );
			}
			return null;
		}

		public function getPdfObjectRelease( idx: int ): PdfObject
		{
			var obj: PdfObject = getPdfObject( idx );
			releaseLastXrefPartial();
			return obj;
		}

		/**
		 * Gets a new file instance of the original PDF
		 * document.
		 * @return a new file instance of the original PDF document
		 */
		public function getSafeFile(): RandomAccessFileOrArray
		{
			return tokens.getSafeFile();
		}

		/**
		 * Gets the number of xref objects.
		 * @return the number of xref objects
		 */
		public function getXrefSize(): int
		{
			return xrefObj.length;
		}

		/**
		 * Returns true if the PDF is encrypted.
		 * @return true if the PDF is encrypted
		 */
		public function isEncrypted(): Boolean
		{
			return encrypted;
		}

		/**
		 * Checks if the document had errors and was rebuilt.
		 * @return true if rebuilt.
		 */
		public function isRebuilt(): Boolean
		{
			return rebuilt;
		}

		/**
		 * Gets the number of pages in the document.
		 * @return the number of pages in the document
		 */
		public function get numberOfPages(): int
		{
			return 0;
		}

		public function get pdfVersion(): int
		{
			return _pdfVersion;
		}

		/**
		 * Start parsing the current pdf document.
		 * If the parameter <code>removeUnused</code> is set to
		 * true then all the unused nodes will be removed one the
		 * parsing process has ended.
		 */
		public function readPdf( removeUnused: Boolean = false ): void
		{
			this.removeUnused = removeUnused;
			fileLength = tokens.getFile().length;
			_pdfVersion = tokens.checkPdfHeader();
			step1();
		}

		public function releaseLastXrefPartial(): void
		{
			if ( partial && lastXrefPartial != -1 )
			{
				xrefObj[lastXrefPartial] = null;
				lastXrefPartial = -1;
			}
		}

		public function releasePage( pageNum: int ): void
		{
			pageRefs.releasePage( pageNum );
		}


		/**
		 * Removes all the unreachable objects.
		 * @return the number of indirect objects removed
		 */
		public function removeUnusedObjects(): int
		{
			var hits: Vector.<Boolean> = new Vector.<Boolean>( xrefObj.length, true );
			removeUnusedNode( trailer, hits );
			var total: int = 0;
			var k: int;
			if ( partial )
			{
				for ( k = 1; k < hits.length; ++k )
				{
					if ( !hits[k] )
					{
						xref[k * 2] = -1;
						xref[k * 2 + 1] = 0;
						xrefObj[k] = null;
						++total;
					}
				}
			} else
			{
				for ( k = 1; k < hits.length; ++k )
				{
					if ( !hits[k] )
					{
						xrefObj[k] = null;
						++total;
					}
				}
			}
			return total;
		}

		public function resetLastXrefPartial(): void
		{
			lastXrefPartial = -1;
		}
		
		/** 
		 * Returns the content of the document information dictionary as a HashMap
		 * of String.
		 * @return content of the document information dictionary
		 */
		public function getInfo(): HashMap
		{
			var map: HashMap = new HashMap();
			var info: PdfDictionary = trailer.getAsDict( PdfName.INFO );
			if (info == null)
				return map;
			
			var iterator: Iterator = info.getKeys().iterator();
			while( iterator.hasNext() )
			{
				var key: PdfName = PdfName( iterator.next() );
				var obj: PdfObject = PdfReader.getPdfObject( info.getValue( key ) );
				if (obj == null)
					continue;
				
				var value: String = obj.toString();
				switch( obj.getType() )
				{
					case PdfObject.STRING:
						value = PdfString(obj).toUnicodeString();
						break;
					
					case PdfObject.NAME:
						value = PdfName.decodeName( value );
						break;
				}
				map.put( PdfName.decodeName( key.toString() ), value );
			}
			return map;
		}

		/**
		 * Eliminates shared streams if they exist.
		 */
		protected function eliminateSharedStreams(): void
		{
			var t: Number = new Date().getTime();
			if ( !sharedStreams )
				return;
			sharedStreams = false;
			if ( pageRefs.size == 1 )
				return;
			var newRefs: Vector.<PRIndirectReference> = new Vector.<PRIndirectReference>();
			var newStreams: Vector.<PRStream> = new Vector.<PRStream>();
			var visited: HashMap = new HashMap();
			var ref: PRIndirectReference;
			var k: int;

			for ( k = 1; k <= pageRefs.size; ++k )
			{
				var page: PdfDictionary = pageRefs.getPageN( k );
				if ( page == null )
					continue;
				var contents: PdfObject = PdfReader.getPdfObject( page.getValue( PdfName.CONTENTS ) );
				if ( contents == null )
					continue;
				if ( contents.isStream() )
				{
					ref = PRIndirectReference( page.getValue( PdfName.CONTENTS ) );
					if ( visited.containsKey( ref.number ) )
					{
						newRefs.push( ref );
						newStreams.push( PRStream.fromPRStream( PRStream( contents ), null ) );
					} else
						visited.put( ref.number, 1 );
				} else if ( contents.isArray() )
				{
					var array: PdfArray = PdfArray( contents );
					for ( var j: int = 0; j < array.size; ++j )
					{
						ref = PRIndirectReference( array.getPdfObject( j ) );
						if ( visited.containsKey( ref.number ) )
						{
							// need to duplicate
							newRefs.push( ref );
							newStreams.push( PRStream.fromPRStream( PRStream( PdfReader.getPdfObject( ref ) ), null ) );
						} else
							visited.put( ref.number, 1 );
					}
				}
			}

			if ( newStreams.length == 0 )
				return;

			for ( k = 0; k < newStreams.length; ++k )
			{
				xrefObj.push( newStreams[k] );
				ref = PRIndirectReference( newRefs[k] );
				ref.setNumber( xrefObj.length - 1, 0 );
			}
			trace( 'eliminateSharedStreams: ' + ( new Date().getTime() - t ) );
		}

		protected function readArray(): PdfArray
		{
			var array: PdfArray = new PdfArray();
			var obj: PdfObject;
			var type: int;
			while ( true )
			{
				obj = readPRObject();
				type = obj.getType();
				if ( -type == PRTokeniser.TK_END_ARRAY )
					break;
				if ( -type == PRTokeniser.TK_END_DIC )
					tokens.throwError( "unexpected >>" );
				array.add( obj );
			}
			return array;
		}

		protected function readDictionary(): PdfDictionary
		{
			var dic: PdfDictionary = new PdfDictionary();
			while ( true )
			{
				tokens.nextValidToken();
				if ( tokens.getTokenType() == PRTokeniser.TK_END_DIC )
					break;
				if ( tokens.getTokenType() != PRTokeniser.TK_NAME )
					tokens.throwError( "dictionary key is not a name" );
				var name: PdfName = new PdfName( tokens.getStringValue(), false );
				var obj: PdfObject = readPRObject();
				var type: int = obj.getType();
				if ( -type == PRTokeniser.TK_END_DIC )
					tokens.throwError( "unexpected >>" );
				if ( -type == PRTokeniser.TK_END_ARRAY )
					tokens.throwError( "unexpected close bracket" );
				dic.put( name, obj );
			}
			return dic;
		}

		protected function readDocObj(): void
		{
			currentStep++;
			dispatchEvent( new ProgressEvent( ProgressEvent.PROGRESS ) );
			xrefObj = new Vector.<PdfObject>( xref.length / 2, true );
			var copies: Vector.<PdfObject> = new Vector.<PdfObject>( xref.length / 2 );
			xrefObj = xrefObj.concat( copies );

			var docReader: PRDocObjectReader = new PRDocObjectReader( this );
			docReader.addEventListener( Event.COMPLETE, onDocObjComplete, false, 0, true );
			docReader.addEventListener( ErrorEvent.ERROR, onDocObjError, false, 0, true );
			docReader.addEventListener( ProgressEvent.PROGRESS, onDocObjProgress, false, 0, true );
			docReader.run();
		}

		protected function readObjStm( stream: PRStream, map: HashMap ): void
		{
			var first: int = stream.getAsNumber( PdfName.FIRST ).intValue();
			var n: int = stream.getAsNumber( PdfName.N ).intValue();
			var b: Bytes = getStreamBytes( stream, tokens.getFile() );
			var saveTokens: PRTokeniser = tokens;
			tokens = new PRTokeniser( b.buffer );
			try
			{
				var address: Vector.<int> = new Vector.<int>( n, true );
				var objNumber: Vector.<int> = new Vector.<int>( n, true );
				var ok: Boolean = true;
				var k: int;
				for ( k = 0; k < n; ++k )
				{
					ok = tokens.nextToken();
					if ( !ok )
						break;
					if ( tokens.getTokenType() != PRTokeniser.TK_NUMBER )
					{
						ok = false;
						break;
					}
					objNumber[k] = tokens.intValue();
					ok = tokens.nextToken();
					if ( !ok )
						break;
					if ( tokens.getTokenType() != PRTokeniser.TK_NUMBER )
					{
						ok = false;
						break;
					}
					address[k] = tokens.intValue() + first;
				}
				if ( !ok )
					throw new InvalidPdfError( "error reading objstm" );
				for ( k = 0; k < n; ++k )
				{
					if ( map.containsKey( k ) )
					{
						tokens.seek( address[k] );
						var obj: PdfObject = readPRObject();
						xrefObj[objNumber[k]] = obj;
					}
				}
			} finally
			{
				tokens = saveTokens;
			}
		}

		protected function readOneObjStm( stream: PRStream, idx: int ): PdfObject
		{
			var t: Number = getTimer();
			var first: int = stream.getAsNumber( PdfName.FIRST ).intValue();
			var b: Bytes = getStreamBytes( stream, tokens.getFile() );
			var saveTokens: PRTokeniser = tokens;
			tokens = new PRTokeniser( b.buffer );
			try
			{
				var address: int = 0;
				var ok: Boolean = true;
				++idx;
				for ( var k: int = 0; k < idx; ++k )
				{
					ok = tokens.nextToken();
					if ( !ok )
						break;
					if ( tokens.getTokenType() != PRTokeniser.TK_NUMBER )
					{
						ok = false;
						break;
					}
					ok = tokens.nextToken();
					if ( !ok )
						break;
					if ( tokens.getTokenType() != PRTokeniser.TK_NUMBER )
					{
						ok = false;
						break;
					}
					address = tokens.intValue() + first;
				}
				if ( !ok )
					throw new InvalidPdfError( "error reading objstm" );
				tokens.seek( address );
				return readPRObject();
			} finally
			{
				tokens = saveTokens;
			}
			trace( 'readOneObjstm: ' + ( getTimer() - t ) );
			return null;
		}

		protected function readPages(): void
		{
			catalog = trailer.getAsDict( PdfName.ROOT );
			rootPages = catalog.getAsDict( PdfName.PAGES );
			pageRefs = new PageRefs( this );
		}

		protected function readSingleObject( k: int ): PdfObject
		{
			strings.splice( 0, strings.length );
			var k2: int = k * 2;
			var pos: int = xref[k2];
			if ( pos < 0 )
				return null;
			if ( xref[k2 + 1] > 0 )
				pos = objStmToOffset.getValue( xref[k2 + 1] ) as int;
			if ( pos == 0 )
				return null;
			tokens.seek( pos );
			tokens.nextValidToken();
			if ( tokens.getTokenType() != PRTokeniser.TK_NUMBER )
				tokens.throwError( "invalid object number" );
			objNum = tokens.intValue();
			tokens.nextValidToken();
			if ( tokens.getTokenType() != PRTokeniser.TK_NUMBER )
				tokens.throwError( "invalid generation number" );
			objGen = tokens.intValue();
			tokens.nextValidToken();
			if ( !tokens.getStringValue() == "obj" )
				tokens.throwError( "token obj expected" );
			var obj: PdfObject;
			try
			{
				obj = readPRObject();
				for ( var j: int = 0; j < strings.length; ++j )
				{
					var str: PdfString = strings[j];
					str.decrypt( this );
				}
				if ( obj.isStream() )
				{
					checkPRStreamLength( PRStream( obj ) );
				}
			} catch ( e: Error )
			{
				obj = null;
			}
			if ( xref[k2 + 1] > 0 )
			{
				obj = readOneObjStm( PRStream( obj ), xref[k2] );
			}
			xrefObj[k] = obj;
			return obj;
		}


		protected function readXref(): void
		{
			hybridXref = false;
			newXrefType = false;
			tokens.seek( tokens.getStartxref() );
			tokens.nextToken();
			if ( !tokens.getStringValue() == "startxref" )
			{
				dispatchEvent( new ErrorEvent( ErrorEvent.ERROR, false, false, "startxref not found" ) );
				return;
			}
			tokens.nextToken();
			if ( tokens.getTokenType() != PRTokeniser.TK_NUMBER )
			{
				dispatchEvent( new ErrorEvent( ErrorEvent.ERROR, false, false, "startxref is not followed by a number" ) );
				return;
			}
			
			var startxref: int = tokens.intValue();
			lastXref = startxref;
			eofPos = tokens.getFilePointer();
			try
			{
				if ( readXRefStream( startxref ) )
				{
					newXrefType = true;
					return;
				}
			} catch ( e: Error )
			{
				trace( e );
			}
			xref = null;
			tokens.seek( startxref );
			
			var xf: XrefSectionReader = new XrefSectionReader( this );
			xf.addEventListener( Event.COMPLETE, onReadSectionComplete, false, 0, true );
			xf.addEventListener( ErrorEvent.ERROR, onReadSectionError, false, 0, true );
			xf.run();

		}
		
		private function onReadSectionComplete( event: Event ): void
		{
			var xf: XrefSectionReader = XrefSectionReader( event.target );
			trailer = xf.trailer;
			xf.dispose();
			
			var trailer2: PdfDictionary = trailer;
			onReadSectionStep( trailer2 );
		}
		
		private function onReadSectionComplete2( event: Event ): void
		{
			var xf: XrefSectionReader = XrefSectionReader( event.target );
			var t: PdfDictionary = xf.trailer;
			xf.dispose();
			
			onReadSectionStep( t );
		}
		
		private function onReadSectionStep( t: PdfDictionary ): void
		{
			var prev: PdfNumber = t.getValue( PdfName.PREV ) as PdfNumber;
			if( prev == null )
			{
				step1_complete();
				return;
			}
			tokens.seek( prev.intValue() );

			var xf: XrefSectionReader = new XrefSectionReader( this );
			xf.addEventListener( Event.COMPLETE, onReadSectionComplete2, false, 0, true );
			xf.addEventListener( ErrorEvent.ERROR, onReadSectionError, false, 0, true );
			xf.run();
		}
		
		private function onReadSectionError( event: ErrorEvent ): void
		{
			var xf: XrefSectionReader = XrefSectionReader( event.target );
			xf.dispose();
			dispatchEvent( event.clone() );
		}

		protected function rebuildXref(): void
		{
			throw new NonImplementatioError();
		}

		protected function removeUnusedNode( obj: PdfObject, hits: Vector.<Boolean> ): void
		{
			var state: Vector.<Object> = new Vector.<Object>();
			state.push( obj );
			while ( state.length > 0 )
			{
				var current: Object = state.shift();
				if ( current == null )
					continue;

				var ar: Vector.<PdfObject> = null;
				var dic: PdfDictionary = null;
				var keys: Vector.<Object> = null;
				var objs: Vector.<Object> = null;
				var idx: int = 0;
				var k: int;
				var num: int;
				var v: PdfObject;
				var ref: PRIndirectReference;

				if ( current is PdfObject )
				{
					obj = PdfObject( current );
					switch ( obj.getType() )
					{
						case PdfObject.DICTIONARY:
						case PdfObject.STREAM:
							dic = PdfDictionary( obj );
							keys = new Vector.<Object>( dic.size, true );
							dic.getKeys().toArray( Vector.<Object>( keys ) );
							break;
						case PdfObject.ARRAY:
							ar = PdfArray( obj ).getArrayList();
							break;
						case PdfObject.INDIRECT:
							ref = PRIndirectReference( obj );
							num = ref.number;
							if ( !hits[num] )
							{
								hits[num] = true;
								state.push( PdfReader.getPdfObjectRelease( ref ) );
							}
							continue;
						default:
							continue;
					}
				} else
				{
					objs = Vector.<Object>( current );
					if ( objs[0] is Vector.<PdfObject> && !( objs[1] is PdfDictionary ) )
					{
						ar = objs[0] as Vector.<PdfObject>;
						idx = objs[1] as int;
					} else
					{
						keys = Vector.<Object>( objs[0] );
						dic = PdfDictionary( objs[1] );
						idx = objs[2] as int;
					}
				}
				if ( ar != null )
				{
					for ( k = idx; k < ar.length; ++k )
					{
						v = PdfObject( ar[k] );
						if ( v.isIndirect() )
						{
							num = PRIndirectReference( v ).number;
							if ( num >= xrefObj.length || ( !partial && xrefObj[num] == null ) )
							{
								ar[k] = PdfNull.PDFNULL;
								continue;
							}
						}
						if ( objs == null )
							state.push( Vector.<Object>( [ ar, ( k + 1 ) ] ) );
						else
						{
							objs[1] = k + 1;
							state.push( objs );
						}
						state.push( v );
						break;
					}
				} else
				{
					for ( k = idx; k < keys.length; ++k )
					{
						var key: PdfName = keys[k] as PdfName;
						v = dic.getValue( key );
						if ( v.isIndirect() )
						{
							num = PRIndirectReference( v ).number;
							if ( num >= xrefObj.length || ( !partial && xrefObj[num] == null ) )
							{
								dic.put( key, PdfNull.PDFNULL );
								continue;
							}
						}
						if ( objs == null )
							state.push( Vector.<Object>( [ keys, dic, ( k + 1 ) ] ) );
						else
						{
							objs[2] = ( k + 1 );
							state.push( objs );
						}
						state.push( v );
						break;
					}
				}
			}
		}

		internal function _getPageRotation( page: PdfDictionary ): int
		{
			var rotate: PdfNumber = page.getAsNumber( PdfName.ROTATE );
			if ( rotate == null )
			{
				return 0;
			} else
			{
				var n: int = rotate.intValue();
				n %= 360;
				return n < 0 ? n + 360 : n;
			}
		}

		/**
		 * Gets the page from a page dictionary
		 * @param page the page dictionary
		 * @return the page
		 */
		internal function _getPageSize( page: PdfDictionary ): RectangleElement
		{
			var mediaBox: PdfArray = page.getAsArray( PdfName.MEDIABOX );
			return getNormalizedRectangle( mediaBox );
		}

		/**
		 * Gets the rotated page from a page dictionary.
		 * @param page the page dictionary
		 * @return the rotated page
		 */
		internal function _getPageSizeWithRotation( page: PdfDictionary ): RectangleElement
		{
			var rect: RectangleElement = _getPageSize( page );
			var rotation: int = _getPageRotation( page );
			while ( rotation > 0 )
			{
				rect = rect.rotate();
				rotation -= 90;
			}
			return rect;
		}

		internal function ensureXrefSize( size: int ): void
		{
			if ( size == 0 )
				return;
			if ( xref == null )
				xref = new Vector.<int>( size, true );
			else
			{
				var xref2: Vector.<int>;
				if ( xref.length < size )
				{
					xref2 = new Vector.<int>( size, true );
					xref2 = xref.slice( 0, xref.length );
					xref = xref2;
				}
			}
		}

		internal function getTokens(): PRTokeniser
		{
			return tokens;
		}

		internal function getxref(): Vector.<int>
		{
			return xref;
		}

		internal function getxrefobj(): Vector.<PdfObject>
		{
			return xrefObj;
		}

		internal function readPRObject(): PdfObject
		{
			tokens.nextValidToken();
			var type: int = tokens.getTokenType();
			switch ( type )
			{
				case PRTokeniser.TK_START_DIC:
					++readDepth;
					var dic: PdfDictionary = readDictionary();
					--readDepth;
					var pos: int = tokens.getFilePointer();
					var hasNext: Boolean;
					do
					{
						hasNext = tokens.nextToken();
					} while ( hasNext && tokens.getTokenType() == PRTokeniser.TK_COMMENT );

					if ( hasNext && tokens.getStringValue() == "stream" )
					{
						var ch: int;
						do
						{
							ch = tokens.readInt();
						} while ( ch == 32 || ch == 9 || ch == 0 || ch == 12 );
						if ( ch != 10 )
							ch = tokens.readInt();
						if ( ch != 10 )
							tokens.backOnePosition( ch );
						var stream: PRStream = PRStream.fromReader( this, tokens.getFilePointer() );
						stream.putAll( dic );
						stream.setObjNum( objNum, objGen );
						return stream;
					} else
					{
						tokens.seek( pos );
						return dic;
					}

				case PRTokeniser.TK_START_ARRAY:
					++readDepth;
					var arr: PdfArray = readArray();
					--readDepth;
					return arr;

				case PRTokeniser.TK_NUMBER:
					return new PdfNumber( tokens.getStringValue() );

				case PRTokeniser.TK_STRING:
					var str: PdfString = new PdfString( tokens.getStringValue(), null ).setHexWriting( tokens.isHexString() );
					str.setObjNum( objNum, objGen );
					if ( strings != null )
						strings.push( str );
					return str;

				case PRTokeniser.TK_NAME:
					var cachedName: PdfName = PdfName( PdfName[tokens.getStringValue()] );
					if ( readDepth > 0 && cachedName != null )
					{
						return cachedName;
					} else
					{
						return new PdfName( tokens.getStringValue(), false );
					}

				case PRTokeniser.TK_REF:
					var num: int = tokens.getReference();
					var ref: PRIndirectReference = new PRIndirectReference( PdfObject.INDIRECT, num, tokens.getGeneration() );
					ref.reader = this;
					return ref;

				case PRTokeniser.TK_ENDOFFILE:
					throw new EOFError( "unexpected end of file" );

				default:
					var sv: String = tokens.getStringValue();
					if ( "null" == sv )
					{
						if ( readDepth == 0 )
						{
							return new PdfNull();
						} //else
						return PdfNull.PDFNULL;
					} else if ( "true" == sv )
					{
						if ( readDepth == 0 )
						{
							return new PdfBoolean( true );
						} //else
						return PdfBoolean.PDF_TRUE;
					} else if ( "false" == sv )
					{
						if ( readDepth == 0 )
						{
							return new PdfBoolean( false );
						} //else
						return PdfBoolean.PDF_FALSE;
					}
					return new PdfLiteral( tokens.getStringValue(), -type );
			}
		}

		internal function readXRefStream( ptr: int ): Boolean
		{
			var t: Number = getTimer();
			tokens.seek( ptr );
			var thisStream: int = 0;
			if ( !tokens.nextToken() )
				return false;
			if ( tokens.getTokenType() != PRTokeniser.TK_NUMBER )
				return false;
			thisStream = tokens.intValue();
			if ( !tokens.nextToken() || tokens.getTokenType() != PRTokeniser.TK_NUMBER )
				return false;
			if ( !tokens.nextToken() || !tokens.getStringValue() == "obj" )
				return false;
			var object: PdfObject = readPRObject();
			var stm: PRStream = null;
			if ( object.isStream() )
			{
				stm = PRStream( object );
				if ( !PdfName.XREF.equals( stm.getValue( PdfName.TYPE ) ) )
					return false;
			} else
				return false;
			if ( trailer == null )
			{
				trailer = new PdfDictionary();
				trailer.putAll( stm );
			}
			stm.length = PdfNumber( stm.getValue( PdfName.LENGTH ) ).intValue();
			var size: int = PdfNumber( stm.getValue( PdfName.SIZE ) ).intValue();
			var index: PdfArray;
			var obj: PdfObject = stm.getValue( PdfName.INDEX );
			if ( obj == null )
			{
				index = new PdfArray();
				index.add( Vector.<int>( [ 0, size ] ) );
			} else
			{
				index = PdfArray( obj );
			}
			var w: PdfArray = PdfArray( stm.getValue( PdfName.W ) );
			var prev: int = -1;
			obj = stm.getValue( PdfName.PREV );
			if ( obj != null )
				prev = PdfNumber( obj ).intValue();
			// Each xref pair is a position
			// type 0 -> -1, 0
			// type 1 -> offset, 0
			// type 2 -> index, obj num
			ensureXrefSize( size * 2 );
			if ( objStmMark == null && !partial )
				objStmMark = new HashMap();
			if ( objStmToOffset == null && partial )
				objStmToOffset = new HashMap();
			var b: Bytes = getStreamBytes( stm, tokens.getFile() );
			var bptr: int = 0;
			var wc: Vector.<int> = new Vector.<int>( 3, true );
			var k: int;
			for ( k = 0; k < 3; ++k )
				wc[k] = w.getAsNumber( k ).intValue();
			for ( var idx: int = 0; idx < index.size; idx += 2 )
			{
				var start: int = index.getAsNumber( idx ).intValue();
				var length: int = index.getAsNumber( idx + 1 ).intValue();
				ensureXrefSize( ( start + length ) * 2 );
				while ( length-- > 0 )
				{
					var type: int = 1;
					if ( wc[0] > 0 )
					{
						type = 0;
						for ( k = 0; k < wc[0]; ++k )
							type = ( type << 8 ) + ( b[bptr++] & 0xff );
					}
					var field2: int = 0;
					for ( k = 0; k < wc[1]; ++k )
						field2 = ( field2 << 8 ) + ( b[bptr++] & 0xff );
					var field3: int = 0;
					for ( k = 0; k < wc[2]; ++k )
						field3 = ( field3 << 8 ) + ( b[bptr++] & 0xff );
					var base: int = start * 2;
					if ( xref[base] == 0 && xref[base + 1] == 0 )
					{
						switch ( type )
						{
							case 0:
								xref[base] = -1;
								break;
							case 1:
								xref[base] = field2;
								break;
							case 2:
								xref[base] = field3;
								xref[base + 1] = field2;
								if ( partial )
								{
									objStmToOffset.put( field2, 0 );
								} else
								{
									var on: int = field2;
									var seq: HashMap = objStmMark.getValue( on ) as HashMap;
									if ( seq == null )
									{
										seq = new HashMap();
										seq.put( field3, 1 );
										objStmMark.put( on, seq );
									} else
										seq.put( field3, 1 );
								}
								break;
						}
					}
					++start;
				}
			}
			thisStream *= 2;
			if ( thisStream < xref.length )
				xref[thisStream] = -1;

			trace( 'readXRefStream: ' + ( getTimer() - t ) );

			if ( prev == -1 )
				return true;
			return readXRefStream( prev );
		}

		internal function setObjGen( value: int ): void
		{
			objGen = value;
		}

		internal function setObjNum( value: int ): void
		{
			objNum = value;
		}

		private function checkPRStreamLength( stream: PRStream ): void
		{
			var fileLength: int = tokens.length;
			var start: int = stream.offset;
			var calc: Boolean = false;
			var streamLength: int = 0;

			var obj: PdfObject = PdfReader.getPdfObjectRelease( stream.getValue( PdfName.LENGTH ) );

			if ( obj != null && obj.getType() == PdfObject.NUMBER )
			{
				streamLength = PdfNumber( obj ).intValue();
				if ( streamLength + start > fileLength - 20 )
				{
					calc = true;
				} else
				{
					tokens.seek( start + streamLength );
					var line: String = tokens.readString( 20 );
					if ( !StringUtils.startsWith( line, "\nendstream" ) && !StringUtils.startsWith( line, "\r\nendstream" ) && !StringUtils.startsWith( line,
							"\rendstream" ) && !StringUtils.startsWith( line, "endstream" ) )
						calc = true;
				}
			} else
				calc = true;
			if ( calc )
			{
				var tline: Bytes = new Bytes( 16 );
				tokens.seek( start );
				while ( true )
				{
					var pos: int = tokens.getFilePointer();
					if ( !tokens.readLineSegment( tline ) )
						break;
					if ( equalsn( tline, endstream ) )
					{
						streamLength = pos - start;
						break;
					}
					if ( equalsn( tline, endobj ) )
					{
						tokens.seek( pos - 16 );
						var s: String = tokens.readString( 16 );
						var index: int = s.indexOf( "endstream" );
						if ( index >= 0 )
							pos = pos - 16 + index;
						streamLength = pos - start;
						break;
					}
				}
			}
			stream.length = streamLength;
		}

		private function onDocObjComplete( event: Event ): void
		{
			var doc: PRDocObjectReader = PRDocObjectReader( event.target );
			var streams: Vector.<PdfObject> = doc.streams;
			var k: int;

			for ( k = 0; k < streams.length; ++k )
			{
				checkPRStreamLength( PRStream( streams[k] ) );
			}
			step3();
		}

		private function onDocObjError( event: ErrorEvent ): void
		{
			if ( rebuilt || encryptionError )
				throw new InvalidPdfError( event.text );
			rebuilt = true;
			encrypted = false;
			rebuildXref();
			lastXref = -1;

			totalSteps++;
			readDocObj();
		}

		private function onDocObjProgress( event: ProgressEvent ): void
		{
			dispatchEvent( event.clone() );
		}

		private function readDecryptedDocObj(): void
		{
			if ( encrypted )
				return;

			var encDic: PdfObject = trailer.getValue( PdfName.ENCRYPT );
			if ( encDic == null || encDic.toString() == "null" )
				return;

			encryptionError = true;
			throw new NonImplementatioError( "encryption not supported" );

		/*
		   encryptionError = true;
		   var encryptionKey: Bytes = null;
		   encrypted = true;
		   var enc: PdfDictionary = PdfDictionary( getPdfObject( encDic ) );

		   var s: String;
		   var o: PdfObject;
		   var documentIDs: PdfArray = trailer.getAsArray( PdfName.ID );
		   var documentID: Bytes = null;

		   if (documentIDs != null) {
		   o = documentIDs.getPdfObject( 0 );
		   strings.splice( strings.indexOf( o ), 1 );
		   s = o.toString();
		   documentID = com.lowagie.text.DocWriter.getISOBytes(s);
		   if (documentIDs.size > 1)
		   strings.splice( strings.indexOf( documentIDs.getPdfObject(1) ), 1 );
		   }
		   // just in case we have a broken producer
		   if (documentID == null)
		   documentID = new Bytes();
		   var uValue: Bytes = null;
		   var oValue: Bytes = null;
		   var cryptoMode: int = PdfWriter.STANDARD_ENCRYPTION_40;
		   var lengthValue: int = 0;

		   var filter: PdfObject = getPdfObjectRelease( enc.getValue(PdfName.FILTER));

		   if (filter.equals(PdfName.STANDARD)) {
		   s = enc.getValue(PdfName.U).toString();
		   strings.splice( strings.indexOf( enc.getValue(PdfName.U)), 1);
		   uValue = PdfWriter.getISOBytes(s);
		   s = enc.getValue(PdfName.O).toString();
		   strings.splice( strings.indexOf( enc.getValue(PdfName.O)), 1);
		   oValue = PdfWriter.getISOBytes(s);

		   o = enc.getValue(PdfName.P);
		   if (!o.isNumber())
		   throw new InvalidPdfError("illegal 'P' value");
		   pValue = PdfNumber(o).intValue();

		   o = enc.getValue(PdfName.R);
		   if (!o.isNumber())
		   throw new InvalidPdfError("illegal 'R' value");
		   rValue = PdfNumber(o).intValue();

		   switch (rValue) {
		   case 2:
		   cryptoMode = PdfWriter.STANDARD_ENCRYPTION_40;
		   break;
		   case 3:
		   o = enc.getValue(PdfName.LENGTH);
		   if (!o.isNumber())
		   throw new InvalidPdfError("illegal 'length' value");
		   lengthValue = PdfNumber(o).intValue();
		   if (lengthValue > 128 || lengthValue < 40 || lengthValue % 8 != 0)
		   throw new InvalidPdfError("illegal 'length' value");
		   cryptoMode = PdfWriter.STANDARD_ENCRYPTION_128;
		   break;
		   case 4:
		   var dic: PdfDictionary = enc.getValue(PdfName.CF) as PdfDictionary;
		   if (dic == null)
		   throw new InvalidPdfError("cf not found encryption");
		   dic = dic.getValue(PdfName.STDCF) as PdfDictionary;
		   if (dic == null)
		   throw new InvalidPdfError("stdcf not found encryption");
		   if (PdfName.V2.equals(dic.getValue(PdfName.CFM)))
		   cryptoMode = PdfWriter.STANDARD_ENCRYPTION_128;
		   else if (PdfName.AESV2.equals(dic.getValue(PdfName.CFM)))
		   cryptoMode = PdfWriter.ENCRYPTION_AES_128;
		   else
		   throw new UnsupportedPdfError("no compatible encryption.found");
		   var em: PdfObject = enc.getValue(PdfName.ENCRYPTMETADATA);
		   if (em != null && em.toString() == "false")
		   cryptoMode |= PdfWriter.DO_NOT_ENCRYPT_METADATA;
		   break;
		   default:
		   throw new UnsupportedPdfError("unknown encryption type 'R' = " + rValue);
		   }
		   }
		   else if (filter.equals(PdfName.PUBSEC)) {
		   var foundRecipient: Boolean = false;
		   var envelopedData: Bytes = null;
		   var recipients: PdfArray = null;

		   o = enc.getValue(PdfName.V);
		   if (!o.isNumber())
		   throw new InvalidPdfError("illegal 'V' value");
		   var vValue: int = PdfNumber(o).intValue();
		   switch(vValue) {
		   case 1:
		   cryptoMode = PdfWriter.STANDARD_ENCRYPTION_40;
		   lengthValue = 40;
		   recipients = PdfArray(enc.getValue(PdfName.RECIPIENTS));
		   break;
		   case 2:
		   o = enc.getValue(PdfName.LENGTH);
		   if (!o.isNumber())
		   throw new InvalidPdfError("illegal 'length' value");
		   lengthValue = PdfNumber(o).intValue();
		   if (lengthValue > 128 || lengthValue < 40 || lengthValue % 8 != 0)
		   throw new InvalidPdfError("illegal 'length' value");
		   cryptoMode = PdfWriter.STANDARD_ENCRYPTION_128;
		   recipients = PdfArray(enc.getValue(PdfName.RECIPIENTS));
		   break;
		   case 4:
		   var dic: PdfDictionary = enc.getValue(PdfName.CF) as PdfDictionary;
		   if (dic == null)
		   throw new InvalidPdfError("cf not found encryption");
		   dic = dic.getValue(PdfName.DEFAULTCRYPTFILTER) as PdfDictionary;
		   if (dic == null)
		   throw new InvalidPdfError("defaultcryptfilter not found encryption");
		   if (PdfName.V2.equals(dic.getValue(PdfName.CFM))) {
		   cryptoMode = PdfWriter.STANDARD_ENCRYPTION_128;
		   lengthValue = 128;
		   }
		   else if (PdfName.AESV2.equals(dic.getValue(PdfName.CFM))) {
		   cryptoMode = PdfWriter.ENCRYPTION_AES_128;
		   lengthValue = 128;
		   }
		   else
		   throw new UnsupportedPdfError("no compatible encryption found");
		   var em: PdfObject = dic.getValue(PdfName.ENCRYPTMETADATA);
		   if (em != null && em.toString() == "false")
		   cryptoMode |= PdfWriter.DO_NOT_ENCRYPT_METADATA;

		   recipients = PdfArray(dic.getValue(PdfName.RECIPIENTS));
		   break;
		   default:
		   throw new UnsupportedPdfError("unknown encryption type 'V' = " + rValue);
		   }
		   for ( var i: int = 0; i<recipients.size; i++)
		   {
		   var recipient: PdfObject = recipients.getPdfObject(i);
		   strings.splice( strings.indexOf(recipient), 1);

		   CMSEnvelopedData data = null;
		   try {
		   data = new CMSEnvelopedData(recipient.getBytes());

		   Iterator recipientCertificatesIt = data.getRecipientInfos().getRecipients().iterator();

		   while (recipientCertificatesIt.hasNext()) {
		   RecipientInformation recipientInfo = (RecipientInformation)recipientCertificatesIt.next();

		   if (recipientInfo.getRID().match(certificate) && !foundRecipient) {
		   envelopedData = recipientInfo.getContent(certificateKey, certificateKeyProvider);
		   foundRecipient = true;
		   }
		   }
		   }
		   catch (Exception f) {
		   throw new ExceptionConverter(f);
		   }
		   }

		   if(!foundRecipient || envelopedData == null) {
		   throw new UnsupportedPdfException(MessageLocalization.getComposedMessage("bad.certificate.and.key"));
		   }

		   MessageDigest md = null;

		   try {
		   md = MessageDigest.getInstance("SHA-1");
		   md.update(envelopedData, 0, 20);
		   for (int i = 0; i<recipients.size(); i++) {
		   byte[] encodedRecipient = recipients.getPdfObject(i).getBytes();
		   md.update(encodedRecipient);
		   }
		   if ((cryptoMode & PdfWriter.DO_NOT_ENCRYPT_METADATA) != 0)
		   md.update(new byte[]{(byte)255, (byte)255, (byte)255, (byte)255});
		   encryptionKey = md.digest();
		   }
		   catch (Exception f) {
		   throw new ExceptionConverter(f);
		   }
		   }


		   decrypt = new PdfEncryption();
		   decrypt.setCryptoMode(cryptoMode, lengthValue);

		   if (filter.equals(PdfName.STANDARD)) {
		   //check by owner password
		   decrypt.setupByOwnerPassword(documentID, password, uValue, oValue, pValue);
		   if (!equalsArray(uValue, decrypt.userKey, (rValue == 3 || rValue == 4) ? 16 : 32)) {
		   //check by user password
		   decrypt.setupByUserPassword(documentID, password, oValue, pValue);
		   if (!equalsArray(uValue, decrypt.userKey, (rValue == 3 || rValue == 4) ? 16 : 32)) {
		   throw new BadPasswordException(MessageLocalization.getComposedMessage("bad.user.password"));
		   }
		   }
		   else
		   ownerPasswordUsed = true;
		   }
		   else if (filter.equals(PdfName.PUBSEC)) {
		   decrypt.setupByEncryptionKey(encryptionKey, lengthValue);
		   ownerPasswordUsed = true;
		   }

		   for (int k = 0; k < strings.size(); ++k) {
		   PdfString str = (PdfString)strings.get(k);
		   str.decrypt(this);
		   }

		   if (encDic.isIndirect()) {
		   cryptoRef = (PRIndirectReference)encDic;
		   xrefObj.set(cryptoRef.getNumber(), null);
		   }
		   encryptionError = false;
		 */
		}

		private function step1(): void
		{
			currentStep = 1;
			step1_init();
		}

		private function step1_init(): void
		{
			dispatchEvent( new ProgressEvent( ProgressEvent.PROGRESS ) );
			readXref();
		}
		
		private function step1_complete(): void
		{
			step2();
		}

		private function step2(): void
		{
			readDocObj();
		}

		private function step3(): void
		{
			readDecryptedDocObj();
			step3_init();
		}

		private function step3_complete(): void
		{
			objStmMark = null;
			xref = null;

			strings.splice( 0, strings.length );
			readPages();
			eliminateSharedStreams();

			if ( removeUnused )
				removeUnusedObjects();
			
			// all completed
			trace('READ COMPLETED');
			dispatchEvent( new Event( Event.COMPLETE ) );
		}

		private function step3_init(): void
		{
			currentStep++;
			dispatchEvent( new ProgressEvent( ProgressEvent.PROGRESS ) );
			
			if ( objStmMark != null )
			{
				var i: Iterator = objStmMark.entrySet().iterator();
				progressEvent.bytesTotal = objStmMark.size();
				progressEvent.bytesLoaded = 0;
				setTimeout( step3_tick, 3, i );
			} else
			{
				step3_complete();
			}
		}

		private function step3_tick( i: Iterator ): void
		{
			trace( 'step3_timer' );
			var t: Number = getTimer();
			while ( getTimer() - t < TIMER_STEP )
			{
				if ( i.hasNext() )
				{
					var entry: Entry = i.next();
					var n: * = entry.key;
					var h: * = entry.value;
					readObjStm( PRStream( xrefObj[n] ), h );
					PRStream( xrefObj[n] ).dispose();
					xrefObj[n] = null;

					progressEvent.bytesLoaded++;
					dispatchEvent( progressEvent );
				} else
				{
					step3_complete();
					return;
				}
			}
			setTimeout( step3_tick, 3, i );
		}

		/**
		 * Decodes a stream that has the ASCII85Decode filter.
		 * @param in the input data
		 * @return the decoded data
		 * @throws RuntimeError
		 */
		public static function ASCII85Decode( input: Bytes ): Bytes
		{
			var out: ByteArray = new ByteArray();
			var state: int = 0;
			var chn: Vector.<int> = new Vector.<int>( 5, true );
			var k: int;
			var ch: int;
			var j: int;
			var r: int;
			for ( k = 0; k < input.length; ++k )
			{
				ch = input[k] & 0xff;
				if ( ch == 126 )
					break;
				if ( PRTokeniser.isWhitespace( ch ) )
					continue;
				if ( ch == 122 && state == 0 )
				{
					out.writeByte( 0 );
					out.writeByte( 0 );
					out.writeByte( 0 );
					out.writeByte( 0 );
					continue;
				}
				if ( ch < 33 || ch > 117 )
					throw new RuntimeError( "illegal character in ascii85decode" );
				chn[state] = ch - 33;
				++state;
				if ( state == 5 )
				{
					state = 0;
					r = 0;
					for ( j = 0; j < 5; ++j )
						r = r * 85 + chn[j];
					out.writeByte( ( r >> 24 ) );
					out.writeByte( ( r >> 16 ) );
					out.writeByte( ( r >> 8 ) );
					out.writeByte( r );
				}
			}

			r = 0;
			if ( state == 2 )
			{
				r = chn[0] * 85 * 85 * 85 * 85 + chn[1] * 85 * 85 * 85 + 85 * 85 * 85 + 85 * 85 + 85;
				out.writeByte( ( r >> 24 ) );
			} else if ( state == 3 )
			{
				r = chn[0] * 85 * 85 * 85 * 85 + chn[1] * 85 * 85 * 85 + chn[2] * 85 * 85 + 85 * 85 + 85;
				out.writeByte( ( r >> 24 ) );
				out.writeByte( ( r >> 16 ) );
			} else if ( state == 4 )
			{
				r = chn[0] * 85 * 85 * 85 * 85 + chn[1] * 85 * 85 * 85 + chn[2] * 85 * 85 + chn[3] * 85 + 85;
				out.writeByte( ( r >> 24 ) );
				out.writeByte( ( r >> 16 ) );
				out.writeByte( ( r >> 8 ) );
			}
			return new Bytes( out );
		}

		/**
		 * Decodes a stream that has the ASCIIHexDecode filter.
		 * @param in the input data
		 * @return the decoded data
		 * @throws RuntimeError
		 */
		public static function ASCIIHexDecode( input: Bytes ): Bytes
		{
			var out: ByteArray = new ByteArray();
			var first: Boolean = true;
			var n1: int = 0;
			var k: int;
			var ch: int;
			var n: int;
			for ( k = 0; k < input.length; ++k )
			{
				ch = input[k] & 0xff;
				if ( ch == 62 )
					break;
				if ( PRTokeniser.isWhitespace( ch ) )
					continue;
				n = PRTokeniser.getHex( ch );
				if ( n == -1 )
					throw new RuntimeError( "illegal character in asciihexdecode" );
				if ( first )
					n1 = n;
				else
					out.writeByte( ( ( n1 << 4 ) + n ) );
				first = !first;
			}
			if ( !first )
				out.writeByte( ( n1 << 4 ) );
			return new Bytes( out );
		}

		/**
		 * Decodes a stream that has the FlateDecode filter.
		 * @param in the input data
		 * @return the decoded data
		 */
		public static function FlateDecode( input: Bytes ): Bytes
		{
			// TODO: maybe it's better to use Inflater class than the
			// native uncompress method?
			var b: Bytes = new Bytes();
			b.writeBytes( input, 0, input.length );
			b.buffer.uncompress();
			return b;

		/*
		   var b: Bytes = _FlateDecode( input, true );
		   if ( b == null )
		   return _FlateDecode( input, false );
		   return b;
		 */
		}

		/**
		 * A helper to FlateDecode.
		 * @param in the input data
		 * @param strict true to read a correct stream.
		 * false to try to read a corrupted stream
		 * @return the decoded data
		 */
		public static function _FlateDecode( input: Bytes, strict: Boolean ): Bytes
		{
			var stream: ByteArrayInputStream = new ByteArrayInputStream( input.buffer );
			var zip: InflaterInputStream = new InflaterInputStream( stream );
			var out: ByteArray = new ByteArray();
			var b: Bytes = new Bytes( strict ? 4092 : 1 );
			try
			{
				var n: int;
				while ( ( n = zip.readBytes( b.buffer, 0, b.length ) ) >= 0 )
				{
					out.writeBytes( b.buffer, 0, n );
				}
				return new Bytes( out );
			} catch ( e: Error )
			{
				if ( strict )
					return null;
				return new Bytes( out );
			}
			return null;
		}


		public static function decodePredictor( input: Bytes, dicPar: PdfObject ): Bytes
		{
			if ( dicPar == null || !dicPar.isDictionary() )
				return input;
			var dic: PdfDictionary = PdfDictionary( dicPar );
			var obj: PdfObject = getPdfObject( dic.getValue( PdfName.PREDICTOR ) );
			if ( obj == null || !obj.isNumber() )
				return input;
			var predictor: int = PdfNumber( obj ).intValue();
			if ( predictor < 10 )
				return input;
			var width: int = 1;
			obj = getPdfObject( dic.getValue( PdfName.COLUMNS ) );
			if ( obj != null && obj.isNumber() )
				width = PdfNumber( obj ).intValue();
			var colors: int = 1;
			obj = getPdfObject( dic.getValue( PdfName.COLORS ) );
			if ( obj != null && obj.isNumber() )
				colors = PdfNumber( obj ).intValue();
			var bpc: int = 8;
			obj = getPdfObject( dic.getValue( PdfName.BITSPERCOMPONENT ) );
			if ( obj != null && obj.isNumber() )
				bpc = PdfNumber( obj ).intValue();

			var dataStream: DataInputStream = new DataInputStream( new ByteArrayInputStream( input.buffer ) );
			var fout: ByteArray = new ByteArray();
			fout.length = input.length;

			var bytesPerPixel: int = colors * bpc / 8;
			var bytesPerRow: int = ( colors * width * bpc + 7 ) / 8;
			var curr: Bytes = new Bytes( bytesPerRow );
			var prior: Bytes = new Bytes( bytesPerRow );

			// Decode the (sub)image row-by-row
			var filter: int;
			var i: int;
			while ( true )
			{
				filter = 0;
				try
				{
					filter = dataStream.readUnsignedByte();
					if ( filter < 0 )
					{
						return new Bytes( fout );
					}
					dataStream.readFully( curr.buffer, 0, bytesPerRow );
				} catch ( e: Error )
				{
					return new Bytes( fout );
				}

				switch ( filter )
				{
					case 0: //PNG_FILTER_NONE
						break;

					case 1: //PNG_FILTER_SUB
						for ( i = bytesPerPixel; i < bytesPerRow; i++ )
						{
							curr[i] += curr[i - bytesPerPixel];
						}
						break;

					case 2: //PNG_FILTER_UP
						for ( i = 0; i < bytesPerRow; i++ )
						{
							curr[i] += prior[i];
						}
						break;

					case 3: //PNG_FILTER_AVERAGE
						for ( i = 0; i < bytesPerPixel; i++ )
						{
							curr[i] += prior[i] / 2;
						}
						for ( i = bytesPerPixel; i < bytesPerRow; i++ )
						{
							curr[i] += ( ( curr[i - bytesPerPixel] & 0xff ) + ( prior[i] & 0xff ) ) / 2;
						}
						break;

					case 4: //PNG_FILTER_PAETH
						for ( i = 0; i < bytesPerPixel; i++ )
						{
							curr[i] += prior[i];
						}

						var a: int, b: int, c: int, p: int, pa: int, pb: int, pc: int, ret: int;
						for ( i = bytesPerPixel; i < bytesPerRow; i++ )
						{
							a = curr[i - bytesPerPixel] & 0xff;
							b = prior[i] & 0xff;
							c = prior[i - bytesPerPixel] & 0xff;
							p = a + b - c;
							pa = Math.abs( p - a );
							pb = Math.abs( p - b );
							pc = Math.abs( p - c );

							if ( ( pa <= pb ) && ( pa <= pc ) )
							{
								ret = a;
							} else if ( pb <= pc )
							{
								ret = b;
							} else
							{
								ret = c;
							}
							curr[i] += ret;
						}
						break;

					default:
						throw new RuntimeError( "png filter unknown" );
				}

				try
				{
					fout.writeBytes( curr.buffer );
				} catch ( ioe: EOFError )
				{
					// Never happens
				}

				// Swap curr and prior
				var tmp: Bytes = prior;
				prior = curr;
				curr = tmp;
			}
			return null;
		}

		/**
		 * Normalizes a RectangleElement so that llx and lly are smaller than urx and ury.
		 * @param box the original rectangle
		 * @return a normalized RectangleElement
		 */
		public static function getNormalizedRectangle( box: PdfArray ): RectangleElement
		{
			var llx: Number = PdfNumber( getPdfObjectRelease( box.getPdfObject( 0 ) ) ).floatValue();
			var lly: Number = PdfNumber( getPdfObjectRelease( box.getPdfObject( 1 ) ) ).floatValue();
			var urx: Number = PdfNumber( getPdfObjectRelease( box.getPdfObject( 2 ) ) ).floatValue();
			var ury: Number = PdfNumber( getPdfObjectRelease( box.getPdfObject( 3 ) ) ).floatValue();
			return new RectangleElement( Math.min( llx, urx ), Math.min( lly, ury ), Math.max( llx, urx ), Math.max( lly, ury ) );
		}

		public static function getPdfObject( obj: PdfObject ): PdfObject
		{
			if ( obj == null )
				return null;
			if ( !obj.isIndirect() )
				return obj;

			try
			{
				var ref: PRIndirectReference = PRIndirectReference( obj );
				var idx: int = ref.number;
				var appendable: Boolean = ref.reader.appendable;
				obj = ref.reader.getPdfObject( idx );
				if ( obj == null )
				{
					return null;
				} else
				{
					if ( appendable )
					{
						switch ( obj.getType() )
						{
							case PdfObject.NULL:
								obj = new PdfNull();
								break;
							case PdfObject.BOOLEAN:
								obj = new PdfBoolean( PdfBoolean( obj ).booleanValue );
								break;
							case PdfObject.NAME:
								obj = PdfName.fromBytes( obj.getBytes() );
								break;
						}
						obj.setIndRef( ref );
					}
					return obj;
				}
			} catch ( e: Error )
			{
				throw new ConversionError( e );
			}
			return null;
		}

		public static function getPdfObjectRelease( obj: PdfObject ): PdfObject
		{
			var obj2: PdfObject = getPdfObject( obj );
			releaseLastXrefPartial( obj );
			return obj2;
		}

		public static function getPdfObjects( obj: PdfObject, parent: PdfObject ): PdfObject
		{
			if ( obj == null )
				return null;

			if ( !obj.isIndirect() )
			{
				var ref: PRIndirectReference;

				if ( parent != null && ( ref = parent.getIndRef() ) != null && ref.reader.appendable )
				{
					switch ( obj.getType() )
					{
						case PdfObject.NULL:
							obj = new PdfNull();
							break;
						case PdfObject.BOOLEAN:
							obj = new PdfBoolean( PdfBoolean( obj ).booleanValue );
							break;
						case PdfObject.NAME:
							obj = PdfName.fromBytes( obj.getBytes() );
							break;
					}
					obj.setIndRef( ref );
				}
				return obj;
			}
			return getPdfObject( obj );
		}

		/**
		 * Get the content from a stream applying the required filters.
		 *
		 * @param stream the stream
		 * @param file the location where the stream is
		 * @return the stream content
		 */
		public static function getStreamBytes( stream: PRStream, file: RandomAccessFileOrArray ): Bytes
		{
			var filter: PdfObject = getPdfObjectRelease( stream.getValue( PdfName.FILTER ) );
			var b: Bytes = getStreamBytesRaw( stream, file );
			var filters: Vector.<PdfObject> = new Vector.<PdfObject>();
			if ( filter != null )
			{
				if ( filter.isName() )
					filters.push( filter );
				else if ( filter.isArray() )
					filters = PdfArray( filter ).getArrayList();
			}

			var dp: Vector.<PdfObject> = new Vector.<PdfObject>();
			var dpo: PdfObject = getPdfObjectRelease( stream.getValue( PdfName.DECODEPARMS ) );
			if ( dpo == null || ( !dpo.isDictionary() && !dpo.isArray() ) )
				dpo = getPdfObjectRelease( stream.getValue( PdfName.DP ) );
			if ( dpo != null )
			{
				if ( dpo.isDictionary() )
					dp.push( dpo );
				else if ( dpo.isArray() )
					dp = PdfArray( dpo ).getArrayList();
			}

			var name: String;
			var j: int;
			for ( j = 0; j < filters.length; ++j )
			{
				name = PdfName( getPdfObjectRelease( filters[j] ) ).toString();
				if ( name == "/FlateDecode" || name == "/Fl" )
				{
					b = FlateDecode( b );
					var dicParam: PdfObject = null;
					if ( j < dp.length )
					{
						dicParam = PdfObject( dp[j] );
						b = decodePredictor( b, dicParam );
					}
				} else if ( name == "/ASCIIHexDecode" || name == "/AHx" )
					b = ASCIIHexDecode( b );
				else if ( name == "/ASCII85Decode" || name == "/A85" )
					b = ASCII85Decode( b );
				else if ( name == "/LZWDecode" )
				{
					throw new NonImplementatioError( "LZW not yet supported" );
					/*
					   b = LZWDecode( b );
					   var dicParam: PdfObject = null;
					   if ( j < dp.length )
					   {
					   dicParam = dp[j];
					   b = decodePredictor( b, dicParam );
					   }
					 */
				} else if ( name == "/Crypt" )
				{
				} else
					throw new UnsupportedPdfError( "the filter " + name + " is not supported" );
			}
			return b;
		}

		/**
		 * Get the content from a stream applying the required filters.
		 * @param stream the stream
		 * @return the stream content
		 */
		public static function getStreamBytes2( stream: PRStream ): Bytes
		{
			var rf: RandomAccessFileOrArray = stream.reader.getSafeFile();
			rf.reOpen();
			return getStreamBytes( stream, rf );
		}

		/**
		 * Get the content from a stream as it is without applying any filter.
		 * @param stream the stream
		 * @param file the location where the stream is
		 * @return the stream content
		 */
		public static function getStreamBytesRaw( stream: PRStream, file: RandomAccessFileOrArray ): Bytes
		{
			var reader: PdfReader = stream.reader;
			var b: Bytes;
			if ( stream.offset < 0 )
			{
				b = stream.getBytes();
			} else
			{
				b = new Bytes( stream.length );
				file.seek( stream.offset );
				file.readFully( b, 0, b.length );
				var decrypt: PdfEncryption = reader.decrypt;
				if ( decrypt != null )
				{
					var filter: PdfObject = getPdfObjectRelease( stream.getValue( PdfName.FILTER ) );
					var filters: Vector.<PdfObject> = new Vector.<PdfObject>();
					if ( filter != null )
					{
						if ( filter.isName() )
							filters.push( filter );
						else if ( filter.isArray() )
							filters = PdfArray( filter ).getArrayList();
					}
					var skip: Boolean = false;
					for ( var k: int = 0; k < filters.length; ++k )
					{
						var obj: PdfObject = getPdfObjectRelease( filters[k] );
						if ( obj != null && obj.toString() == "/Crypt" )
						{
							skip = true;
							break;
						}
					}
					if ( !skip )
					{
						throw new NonImplementatioError();
							//decrypt.setHashKey(stream.getObjNum(), stream.getObjGen());
							//b = decrypt.decryptByteArray(b);
					}
				}
			}
			return b;
		}

		/**
		 * Get the content from a stream as it is without applying any filter.
		 * @param stream the stream
		 * @return the stream content
		 */
		public static function getStreamBytesRaw2( stream: PRStream ): Bytes
		{
			var rf: RandomAccessFileOrArray = stream.reader.getSafeFile();
			rf.reOpen();
			return getStreamBytesRaw( stream, rf );
		}

		public static function releaseLastXrefPartial( obj: PdfObject ): void
		{
			if ( obj == null )
				return;
			if ( !obj.isIndirect() )
				return;
			if ( !( obj is PRIndirectReference ) )
				return;

			var ref: PRIndirectReference = PRIndirectReference( obj );
			var reader: PdfReader = ref.reader;
			if ( reader.partial && reader.lastXrefPartial != -1 && reader.lastXrefPartial == ref.number )
			{
				reader.xrefObj[reader.lastXrefPartial] = null;
			}
			reader.lastXrefPartial = -1;
		}

		private static function equalsn( a1: Bytes, a2: Bytes ): Boolean
		{
			var length: int = a2.length;
			for ( var k: int = 0; k < length; ++k )
			{
				if ( a1[k] != a2[k] )
					return false;
			}
			return true;
		}
	}
}