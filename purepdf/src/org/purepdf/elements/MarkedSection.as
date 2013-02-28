/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: MarkedSection.as 238 2010-01-31 10:49:33Z alessandro.crugnola $
* $Author Alessandro Crugnola $
* $Rev: 238 $ $LastChangedDate: 2010-01-31 05:49:33 -0500 (Sun, 31 Jan 2010) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/elements/MarkedSection.as $
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
	
	import org.purepdf.errors.DocumentError;

	public class MarkedSection extends MarkedObject implements IElement
	{
		protected var _title: MarkedObject = null;

		public function MarkedSection( section: Section )
		{
			super();
			
			if( section.title != null )
			{
				title = new MarkedObject( section.title );
				section.title = null;
			}
			_element = section;
		}
		
		/**
		 * Adds a Paragraph, List, Table or Section to this Section.
		 */ 
		public function add( o: Object ): Boolean
		{
			return Section(element).add(o);
		}
		
		public function insert( index: int, o: Object ): void
		{
			Section(element).insert( index, o );
		}
		
		override public function process( listener: IElementListener ): Boolean
		{
			try 
			{
				var element: IElement;
				for ( var i: Iterator = Section(_element).iterator(); i.hasNext(); )
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
		
		
		public function addAll( collection: Vector.<IElement> ): Boolean
		{
			return Section( element ).addAll( collection );
		}
		
		public function addSection3( indentation: Number, numberDepth: int ): MarkedSection
		{
			var section: MarkedSection = Section( element ).addMarkedSection();
			section.indentation = indentation;
			section.numberDepth = numberDepth;
			return section;
		}
		
		public function addSection2( indentation: Number ): MarkedSection
		{
			var section: MarkedSection = Section(element).addMarkedSection();
			section.indentation = indentation;
			return section;
		}
		
		public  function addSection1( numberDepth: Number ): MarkedSection
		{
			var section: MarkedSection = Section(element).addMarkedSection();
			section.numberDepth = numberDepth;
			return section;
		}
		
		public function addSection(): MarkedSection
		{
			return Section(element).addMarkedSection();
		}
		
		public function set title( title: MarkedObject ): void
		{
			if( title.element is Paragraph )
				_title = title;
		}
		
		public function get title(): MarkedObject
		{
			var result: Paragraph = Section.constructTitle( 
										Paragraph(title.element), 
										Section(element).numbers, 
										Section(element).numberDepth, 
										Section(element).numberStyle );
			
			var mo: MarkedObject = new MarkedObject( result );
			mo.markupAttributes = title.markupAttributes;
			return mo;
		}
		
		public function set numberDepth( value: int ): void
		{
			Section(element).numberDepth = value;
		}
		
		public function set indentationLeft( value: Number ): void
		{
			Section(element).indentationLeft = value;
		}
		   
		public function set indentationRight( value: Number ): void
		{
			Section(element).indentationRight = value;
		}
		
		public function set indentation( value: Number ): void
		{
			Section(element).indentation = value;
		}
		
		public function set bookmarkOpen( value: Boolean ): void
		{
			Section(element).bookmarkOpen = value;
		}
		
		public function set triggerNewPage( value: Boolean ): void
		{
			Section(element).triggerNewPage = value;
		}
		    
		public function set bookmarkTitle( value: String ): void
		{
			Section(element).bookmarkTitle = value;
		}
		
		public function newPage(): void
		{
			Section(element).newPage();
		}
	}
}