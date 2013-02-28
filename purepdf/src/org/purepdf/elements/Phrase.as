/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: Phrase.as 321 2010-02-10 11:36:49Z alessandro.crugnola $
* $Author Alessandro Crugnola $
* $Rev: 321 $ $LastChangedDate: 2010-02-10 06:36:49 -0500 (Wed, 10 Feb 2010) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/elements/Phrase.as $
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
package org.purepdf.elements
{
	import it.sephiroth.utils.collections.iterators.Iterator;
	
	import org.purepdf.Font;
	import org.purepdf.IIterable;
	import org.purepdf.errors.CastTypeError;
	import org.purepdf.errors.DocumentError;
	import org.purepdf.utils.StringUtils;
	import org.purepdf.utils.iterators.VectorIterator;
	import org.purepdf.utils.pdf_core;

	/**
	 * A Phrase contains a series of Chunks.
	 * A Phrase has a main Font, but some chunks
	 * within the phrase can have different Font than the main phrase font.
	 * All the Chunks in a Phrase have the same leading.<br />
	 * Example:
	 * <pre>
	 * // When no parameters are passed, the default leading = 16
	 * var phrase1: Phrase = new Phrase("this is a phrase");
	 * var phrase2: Phrase = new Phrase("this is a phrase", new Font( Font.HELVETICA, 12, Font.BOLD ), 20 );
	 * </pre>
	 *
	 * @see		Element
	 * @see		Chunk
	 * @see		Paragraph
	 * @see		Anchor
	 */
	public class Phrase implements ITextElementaryArray, IIterable
	{
		public static const DEFAULT_LEADING: int = 16;
		
		protected var _array: Vector.<Object> = new Vector.<Object>();
		protected var _font: Font;
		protected var _leading: Number = Number.NaN;

		public function Phrase( $text: String, $font: Font, $leading: Number = Number.NaN )
		{
			if( ( $text == null || $text.length == 0 ) && $font == null && isNaN( $leading ) )
			{
				_leading = DEFAULT_LEADING;
				_font = new Font();
			} else 
			{
				_leading = $leading;
				_font = $font == null ? new Font() : $font;
				if( $text != null && $text.length > 0 )
					_array.push( new Chunk( $text, $font ) );
			}
		}
		
		public function initFromPhrase( phrase: Phrase ): void
		{
			if ( phrase != null )
			{
				addAll( phrase );
				_leading = phrase.leading;
				_font = phrase.font;
			} else {
				_leading = DEFAULT_LEADING;
			}
		}
		
		public function initFromChunk( chunk: Chunk ): void
		{
			this.leading = leading;
			if( chunk )
			{
				this.push( chunk );
				this.font = chunk.font;
			} else {
				this.font = new Font();
			}
		}
		
		internal function push( o: Object ): Boolean
		{
			_array.push( o );
			return true;
		}
		
		public function getValue( index: int ): Object
		{
			return _array[index];
		}

		/**
		 * Adds a Chunk, Ancor or another Phrase
		 * @throws	CastTypeError	allowed elements are: Chunk, Anchor and Phrase
		 */
		public function add( o: Object ): Boolean
		{
			if ( o == null )
				return false;

			if ( o is String )
			{
				_array.push( new Chunk( String( o ), font ) );
				return true;
			}

			try
			{
				var element: IElement = IElement( o );

				switch ( element.type )
				{
					case Element.CHUNK:
						return addChunk( Chunk( o ) );

					case Element.PHRASE:
					case Element.PARAGRAPH:
						var phrase: Phrase = Phrase( o );
						var success: int = 1;
						var e: IElement;
						for ( var i: Iterator = phrase.iterator(); i.hasNext();  )
						{
							e = IElement( i.next() );

							if ( e is Chunk )
							{
								success &= addChunk( Chunk( e ) ) ? 1 : 0;
							}
							else
							{
								success &= add( e ) ? 1 : 0;
							}
						}
						return success == 1;

					case Element.MARKED:
					case Element.ANCHOR:
					case Element.ANNOTATION:
					case Element.TABLE:
					case Element.PTABLE:
					case Element.LIST:
					case Element.YMARK:
						_array.push( o );
						return true;

					default:
						throw new CastTypeError( element.type.toString() );
				}
			}
			catch ( cce: CastTypeError )
			{
				throw new CastTypeError( "illegal element. " + cce.message );
			}
			return false;
		}

		public function addAll( collection: IIterable ): Boolean
		{
			for ( var i: Iterator = collection.iterator(); i.hasNext();  )
			{
				add( i.next() );
			}
			return true;
		}

		public function get font(): Font
		{
			return _font;
		}
		
		public function set font( value: Font ): void
		{
			_font = value;
		}

		public function getChunks(): Vector.<Object>
		{
			var tmp: Vector.<Object> = new Vector.<Object>();

			for ( var i: Iterator = new VectorIterator( _array ); i.hasNext();  )
			{
				var chunks: Vector.<Object> = IElement( i.next() ).getChunks();
				for ( var k: int = 0; k < chunks.length; ++k )
					tmp.push( chunks[ k ] );

			}
			return tmp;
		}

		/**
		 * Checks you if the leading of this phrase is defined.
		 *
		 * @return	true if the leading is defined
		 */
		public function get hasLeading(): Boolean
		{
			if ( isNaN( _leading ) )
			{
				return false;
			}
			return true;
		}

		public function insert( index: int, o: Object ): void
		{
			if ( o == null )
				return;

			try
			{
				var element: IElement = IElement( o );

				if ( element.type == Element.CHUNK )
				{
					var chunk: Chunk = Chunk( element );

					if ( !font.isStandardFont )
					{
						chunk.font = font.difference( chunk.font );
					}

					_array.splice( index, 0, chunk );
				}
				else if ( element.type == Element.PHRASE || element.type == Element.ANCHOR || element.type == Element.ANNOTATION || element
					.type == Element.TABLE || element.type == Element.YMARK || element.type == Element.MARKED )
				{
					_array.splice( index, 0, element );
				}
				else
				{
					throw new CastTypeError();
				}
			}
			catch ( cce: CastTypeError )
			{
				throw new CastTypeError( "insertion of illegal element" );
			}
		}

		public function get isContent(): Boolean
		{
			return true;
		}

		public function get isEmpty(): Boolean
		{
			switch ( _array.length )
			{
				case 0:
					return true;

				case 1:
					var element: IElement = IElement( _array[ 0 ] );
					if ( element.type == Element.CHUNK && Chunk( element ).isEmpty )
						return true;
					return false;

				default:
					return false;
			}
		}

		public function get isNestable(): Boolean
		{
			return true;
		}

		public function iterator(): Iterator
		{
			return new VectorIterator( _array );
		}

		public function get leading(): Number
		{
			if ( isNaN( _leading ) && _font != null )
				return _font.getCalculatedLeading( 1.5 );

			return _leading;
		}
		
		public function set leading( value: Number ): void
		{
			_leading = value;
		}

		public function process( listener: IElementListener ): Boolean
		{
			try
			{
				for ( var i: Iterator = iterator(); i.hasNext();  )
				{
					listener.addElement( IElement( i.next() ) );
				}
				return true;
			}
			catch ( de: DocumentError )
			{
				return false;
			}
			return false;
		}

		public function get size(): uint
		{
			return _array.length;
		}

		public function toString(): String
		{
			return "[Phrase]";
		}

		public function get type(): int
		{
			return Element.PHRASE;
		}

		/**
		 * Adds a Chunk.
		 * <p>
		 * This method is a hack to solve a problem I had with phrases that were split between chunks
		 * in the wrong place.
		 * </p>
		 * @param chunk a Chunk to add to the Phrase
		 * @return true if adding the Chunk succeeded
		 */
		protected function addChunk( chunk: Chunk ): Boolean
		{
			var f: Font = chunk.font;
			var c: String = chunk.content;

			if ( font != null && !font.isStandardFont )
				f = font.difference( chunk.font );

			if ( size > 0 && !chunk.hasAttributes )
			{
				try
				{
					var previous: Chunk = Chunk(_array[ size - 1 ]);

					if ( !previous.hasAttributes && ( f == null || f.compareTo( previous.font ) == 0 ) && !( "" == StringUtils.trim( previous
						.content ) ) && !( "" == StringUtils.trim( c ) ) )
					{
						previous.append( c );
						return true;
					}
				}
				catch ( cce: TypeError )
				{
					/* empty statement */
				}
			}

			var newChunk: Chunk = new Chunk( c, f );
			newChunk.attributes = chunk.attributes;

			_array.push( newChunk );
			return true;
		}

		pdf_core function addSpecial( o: Object ): void
		{
			_array.push( o );
		}
		
		public static function fromChunk( chunk: Chunk ): Phrase
		{
			var result: Phrase = new Phrase( null, null );
			result._array.push( chunk );
			result._font = chunk.font;
			return result;
		}
	}
}