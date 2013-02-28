/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: Meta.as 238 2010-01-31 10:49:33Z alessandro.crugnola $
* $Author Alessandro Crugnola $
* $Rev: 238 $ $LastChangedDate: 2010-01-31 05:49:33 -0500 (Sun, 31 Jan 2010) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/elements/Meta.as $
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
	import org.purepdf.errors.DocumentError;

	public class Meta implements IElement
	{
		private var _content: String;
		private var _type: int;

		public function Meta( $type: int, $content: String )
		{
			super();
			_type = $type;
			_content = $content;
		}
		
		public function toString(): String
		{
			return "[Meta: " + _content + "]";
		}
		
		public function process( element: IElementListener ): Boolean
		{
			try
			{
				return element.addElement( this );
			} catch( e: DocumentError )
			{
				return false;
			}
			return false;
		}

		public function append( value: String ): String
		{
			_content += value;
			return _content;
		}

		public function getChunks(): Vector.<Object>
		{
			return new Vector.<Object>();
		}

		public function getContent(): String
		{
			return _content;
		}

		public function getName(): String
		{
			switch ( _type )
			{
				case Element.SUBJECT:
					return ElementTags.SUBJECT;
				case Element.KEYWORDS:
					return ElementTags.KEYWORDS;
				case Element.AUTHOR:
					return ElementTags.AUTHOR;
				case Element.TITLE:
					return ElementTags.TITLE;
				case Element.PRODUCER:
					return ElementTags.PRODUCER;
				case Element.CREATIONDATE:
					return ElementTags.CREATIONDATE;
				default:
					return ElementTags.UNKNOWN;
			}
		}

		public function get isNestable(): Boolean
		{
			return false;
		}

		public function get isContent(): Boolean
		{
			return false;
		}

		public function get type(): int
		{
			return _type;
		}

		/**
		 * Returns the name of the meta information.
		 *
		 * @return	the Element value corresponding with the given tag
		 */
		public static function getType( tag: String ): int
		{
			if ( ElementTags.SUBJECT == tag )
				return Element.SUBJECT;

			if ( ElementTags.KEYWORDS == tag )
				return Element.KEYWORDS;

			if ( ElementTags.AUTHOR == tag )
				return Element.AUTHOR;

			if ( ElementTags.TITLE == tag )
				return Element.TITLE;

			if ( ElementTags.PRODUCER == tag )
				return Element.PRODUCER;

			if ( ElementTags.CREATIONDATE == tag )
				return Element.CREATIONDATE;
			return Element.HEADER;
		}
	}
}