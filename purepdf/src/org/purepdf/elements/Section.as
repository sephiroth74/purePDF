/*
* $Author Alessandro Crugnola $
* $Rev: 242 $ $LastChangedDate: 2010-02-01 09:30:41 -0500 (Mon, 01 Feb 2010) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/elements/Section.as $
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
	import flash.utils.getQualifiedClassName;
	
	import it.sephiroth.utils.collections.iterators.Iterator;
	
	import org.purepdf.IIterable;
	import org.purepdf.errors.CastTypeError;
	import org.purepdf.errors.DocumentError;
	import org.purepdf.errors.IllegalStateError;
	import org.purepdf.utils.iterators.VectorIterator;

	public class Section implements ITextElementaryArray, ILargeElement, IIterable
	{
		/**
		 * hide default number in title
		 */
		public static const NUMBERSTYLE_NONE: int = -1;
		public static const NUMBERSTYLE_DOTTED: int = 0;
		public static const NUMBERSTYLE_DOTTED_WITHOUT_FINAL_DOT: int = 1;
		protected var _title: Paragraph;
		protected var _bookmarkTitle: String;
		protected var _numberDepth: int = 0;
		protected var _numberStyle: int = NUMBERSTYLE_DOTTED;
		protected var _indentationLeft: Number = 0;
		protected var _indentationRight: Number = 0;
		protected var _indentation: Number = 0;
		protected var _bookmarkOpen: Boolean = true;
		protected var _triggerNewPage: Boolean = false;
		protected var subsections: int = 0;
		protected var _numbers: Vector.<Number> = null;
		protected var _complete: Boolean = true;
		protected var _addedCompletely: Boolean = false;
		protected var _notAddedYet: Boolean = true;
		protected var _hideNumbers: Boolean;
		
		private var _arrayList: Vector.<IElement> = new Vector.<IElement>();
		
		public function Section( $title: Paragraph, $depth: int = 1 )
		{
			_title = $title ? $title : new Paragraph( null );
			_numberDepth = $depth;
		}
		
		public function get numberStyle():int
		{
			return _numberStyle;
		}
		
		/**
		 * 
		 * @see #NUMBERSTYLE_DOTTED_WITHOUT_FINAL_DOT
		 * @see #NUMBERSTYLE_DOTTED
		 * @see #NUMBERSTYLE_NONE
		 */
		public function set numberStyle( value: int ): void
		{
			_numberStyle = value;
		}

		public function get numbers():Vector.<Number>
		{
			return _numbers;
		}

		public function get triggerNewPage():Boolean
		{
			return _triggerNewPage;
		}

		public function set triggerNewPage(value:Boolean):void
		{
			_triggerNewPage = value;
		}

		public function get bookmarkOpen():Boolean
		{
			return _bookmarkOpen;
		}

		public function set bookmarkOpen(value:Boolean):void
		{
			_bookmarkOpen = value;
		}

		public function get indentation():Number
		{
			return _indentation;
		}

		public function set indentation(value:Number):void
		{
			_indentation = value;
		}

		public function get indentationRight():Number
		{
			return _indentationRight;
		}

		public function set indentationRight(value:Number):void
		{
			_indentationRight = value;
		}

		public function get indentationLeft():Number
		{
			return _indentationLeft;
		}

		public function set indentationLeft(value:Number):void
		{
			_indentationLeft = value;
		}

		public function get numberDepth():int
		{
			return _numberDepth;
		}

		public function set numberDepth(value:int):void
		{
			_numberDepth = value;
		}

		public function getBookmarkTitle(): Paragraph
		{
			if( _bookmarkTitle == null )
				return _title;
			else
				return new Paragraph( _bookmarkTitle );
		}

		public function set bookmarkTitle(value:String):void
		{
			_bookmarkTitle = value;
		}

		public function get title(): Paragraph
		{
			return constructTitle( _title, _numbers, _numberDepth, _numberStyle );
		}
		
		public function set title( value: Paragraph ): void
		{
			_title = value;
		}
		
		public static function constructTitle( title: Paragraph, numbers: Vector.<Number>, numberDepth: int, numberStyle: int ): Paragraph
		{
			if( title == null)
				return null;
			
			var depth: int = Math.min(numbers.length, numberDepth);
			if (depth < 1)
				return title;
			
			/*
			var buf: String = "";
			for( var i: int = 0; i < depth; i++)
			{
				buf = "." + buf;
				buf = numbers[i] + buf;
			}
			if( numberStyle == NUMBERSTYLE_DOTTED_WITHOUT_FINAL_DOT )
			buf = buf.substr( 0, buf.length - 3 ) + buf.substr( buf.length - 1 );
			*/
			
			var buf: String = numbers.slice(0, depth).reverse().join(".");
			if( numberStyle == NUMBERSTYLE_DOTTED ) buf += ".";
			
			
			var result: Paragraph = Paragraph.fromPhrase( title );
			result.insert( 0, new Chunk( buf, title.font ) );
			return result;
		}
		
		
		public function iterator(): Iterator
		{
			return new VectorIterator( Vector.<Object>(_arrayList) );
		}
		
		public function get size(): uint
		{
			return _arrayList.length;
		}
		
		public function flushContent(): void
		{
			notAddedYet = false;
			_title = null;
			var element: IElement;
			for( var i: VectorIterator = iterator() as VectorIterator; i.hasNext(); ) 
			{
				element = IElement(i.next());
				if (element is Section) 
				{
					var s: Section = Section(element);
					if( !s.complete && size == 1 )
					{
						s.flushContent();
						return;
					} else 
					{
						s.addedCompletely = true;
					}
				}
				i.remove();
			}
		}
		
		public function get isChapter(): Boolean
		{
			return type == Element.CHAPTER;
		}
		
		public function get isSection(): Boolean
		{
			return type == Element.SECTION;
		}
		
		public function set chapterNumber( value: uint ): void
		{
			_numbers[ _numbers.length - 1 ] = value;
			var s: Object;
			
			for( var i: Iterator = iterator(); i.hasNext(); ) 
			{
				s = i.next();
				if (s is Section) {
					Section(s).chapterNumber = value;
				}
			}
		}
		
		public function get depth(): uint
		{
			return _numbers.length;
		}
		
		public function get notAddedYet():Boolean
		{
			return _notAddedYet;
		}

		public function set notAddedYet(value:Boolean):void
		{
			_notAddedYet = value;
		}

		public function get addedCompletely():Boolean
		{
			return _addedCompletely;
		}

		public function set addedCompletely(value:Boolean):void
		{
			_addedCompletely = value;
		}

		public function add(o:Object):Boolean
		{
			if( addedCompletely )
				throw new IllegalStateError("element has already been added to the document");
			
			var section: Section;
			
			try 
			{
				var element: IElement = IElement(o);
				if (element.type == Element.SECTION) {
					section = Section(o);
					section.setNumbers(++subsections, _numbers);
					_arrayList.push( section );
					return true;
				} else if (o is MarkedSection && ( MarkedObject(o).element.type == Element.SECTION ))
				{
					var mo: MarkedSection = MarkedSection(o);
					section = Section(mo.element);
					section.setNumbers(++subsections, _numbers);
					_arrayList.push(mo);
					return true;
				} else if (element.isNestable )
				{
					_arrayList.push(o);
					return true;
				} else {
					throw new CastTypeError( "cannot add " + getQualifiedClassName(element) + " to this section" );
				}
			} catch( cce: CastTypeError ) {
				throw new CastTypeError( "insertion of illegal element " + cce.getStackTrace() );
			}
			return false;
		}
		
		public function addAll( collection: Vector.<IElement> ): Boolean
		{
			_arrayList = _arrayList.concat( collection );
			return true;
		}
		
		private function setNumbers( number: Number, array: Vector.<Number> ): void
		{
			_numbers = new Vector.<Number>();
			_numbers.push( number );
			_numbers = _numbers.concat( array );
		}
		
		public function process(listener:IElementListener):Boolean
		{
			try
			{
				var element: IElement;
				for ( var i: Iterator = iterator(); i.hasNext(); )
				{
					element = IElement(i.next());
					listener.addElement( element );
				}
				return true;
			}
			catch( de: DocumentError ) {
			}
			return false;
		}
		
		public function getChunks():Vector.<Object>
		{
			var tmp: Vector.<Object> = new Vector.<Object>();
			for( var i: Iterator = iterator(); i.hasNext(); )
			{
				var e: IElement = IElement( i.next() );
				tmp = tmp.concat( e.getChunks() );
			}
			return tmp;
		}
		
		public function insert( index: int, o: Object ): void
		{
			if ( addedCompletely )
				throw new IllegalStateError("element has already been added to the document");

			try
			{
				var element: IElement = IElement(o);
				if (element.isNestable)
					_arrayList.splice( index, 0, element );
				else
					throw new CastTypeError("you cant add this element to the section");
			}
			catch( cce: CastTypeError )
			{
				throw new CastTypeError("insertion of illegal element. " +  cce.message );
			}
		}
		
		public function get isNestable():Boolean
		{
			return false;
		}
		
		public function get isContent():Boolean
		{
			return false;
		}
		
		public function toString():String
		{
			return null;
		}
		
		public function get type():int
		{
			return Element.SECTION;
		}
		
		public function get complete():Boolean
		{
			return _complete;
		}
		
		public function set complete(value:Boolean):void
		{
			_complete = value;
		}
		
		public function newPage(): void
		{
			this.add( Chunk.NEXTPAGE );
		}
		
		public function addMarkedSection(): MarkedSection
		{
			var section: MarkedSection = new MarkedSection( new Section( null, numberDepth + 1 ) );
			add( section );
			return section;
		}
		
		public function addSection3( indentation: Number, title: Paragraph ): Section
		{
			return addSection2( indentation, title, numberDepth + 1 );
		}
		
		public function addSection4( title: Paragraph, numberDepth: int ): Section
		{
			return addSection2( 0, title, numberDepth );
		}
		
		public function addSection5( indentation: Number, title: String, numberDepth: int ): Section
		{
			return addSection2( indentation, new Paragraph( title ), numberDepth );
		}
		
		public function addSection6( title: String, numberDepth: int ): Section
		{
			return addSection4( new Paragraph( title ), numberDepth );
		}
		
		public function addSection7( indentation: Number, title: String ): Section
		{
			return addSection3( indentation, new Paragraph( title ) );
		}

		public function addSection( title: String ): Section
		{
			return addSection1( new Paragraph( title ) );
		}
		
		public function addSection1( title: Paragraph ): Section
		{
			return addSection2( 0, title, numberDepth + 1 );
		}
		
		public function addSection2( indentation: Number, title: Paragraph, numberDepth: int ): Section
		{
			if( addedCompletely )
				throw new IllegalStateError("element has already been added to the document");
			
			var section: Section = new Section( title, numberDepth );
			section.indentation = indentation;
			add( section );
			return section;
		}
		
	}
}