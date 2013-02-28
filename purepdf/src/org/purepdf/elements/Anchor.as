/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: Anchor.as 238 2010-01-31 10:49:33Z alessandro.crugnola $
* $Author Alessandro Crugnola $
* $Rev: 238 $ $LastChangedDate: 2010-01-31 05:49:33 -0500 (Sun, 31 Jan 2010) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/elements/Anchor.as $
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
	import flash.net.URLRequest;
	
	import it.sephiroth.utils.collections.iterators.Iterator;
	
	import org.purepdf.Font;
	import org.purepdf.errors.DocumentError;
	import org.purepdf.utils.StringUtils;
	import org.purepdf.utils.iterators.VectorIterator;

	/**
	 * An Anchor can be a reference or a destination of a reference.<br />
	 * Example:<br />
	 * <pre>
	 * var anchor: Anchor = new Anchor("this is a link");
	 * anchor.name = "LINK";
	 * anchor.reference = "http://code.google.com/p/purepdf";
	 * </pre>
	 *
	 * @see		IElement
	 * @see		Phrase
	 */
	public class Anchor extends Phrase
	{
		protected var _name: String = null;
		protected var _reference: String = null;

		public function Anchor( $text: String, $font: Font = null )
		{
			super( $text, $font, $text == null ? Phrase.DEFAULT_LEADING : Number.NaN );
		}
		
		/**
		 * Create a new Anchor from a starting Phrase or Anchor
		 * 
		 * @param phrase	the starting Phrase or Anchor
		 * @return Anchor
		 * 
		 * @see Phrase
		 */
		public static function fromPhrase( phrase: Phrase = null ): Anchor
		{
			var result: Anchor = new Anchor( null );
			result.initFromPhrase( phrase );
			if (phrase is Anchor)
			{
				var a: Anchor = Anchor( phrase );
				result._name = a.name;
				result._reference = a.reference;
			}
			return result;
		}
		
		public static function fromChunk( chunk: Chunk ): Anchor
		{
			var result: Anchor = new Anchor( null );
			result.add( chunk );
			result._font = chunk.font;
			return result;
		}
		
		override public function process( listener: IElementListener ): Boolean
		{
			try 
			{
				var chunk: Chunk;
				var i: Iterator = new VectorIterator( getChunks() );
				var localDestination: Boolean = ( _reference != null && StringUtils.startsWith( _reference, "#"));
				var notGotoOK: Boolean = true;
				while (i.hasNext() )
				{
					chunk = Chunk( i.next() );
					if( _name != null && notGotoOK && !chunk.isEmpty )
					{
						chunk.setLocalDestination( _name );
						notGotoOK = false;
					}
					if( localDestination )
						chunk.setLocalGoto( _reference.substring(1) );
					
					listener.addElement( chunk );
				}
				return true;
			}
			catch( de: DocumentError )
			{}
			return false;
		}
		
		override public function getChunks(): Vector.<Object>
		{
			var tmp: Vector.<Object> = new Vector.<Object>();
			var chunk: Chunk;
			var i: Iterator = iterator();
			var localDestination: Boolean = ( _reference != null && StringUtils.startsWith( _reference, "#"));
			var notGotoOK: Boolean = true;
			while (i.hasNext()) 
			{
				chunk = Chunk( i.next() );
				if (_name != null && notGotoOK && !chunk.isEmpty)
				{
					chunk.setLocalDestination( _name );
					notGotoOK = false;
				}
				if( localDestination )
				{
					chunk.setLocalGoto( _reference.substring(1) );
				} else if ( _reference != null )
					chunk.setAnchor( _reference );
				tmp.push( chunk );
			}
			return tmp;
		}
		
		override public function get type(): int
		{
			return Element.ANCHOR;
		}
		
		public function set name( value: String ): void
		{
			_name = value;
		}
		
		public function set reference( value: String ): void
		{
			_reference = value;
		}
		   
		public function get name(): String
		{
			return _name;
		}
		
		public function get reference(): String
		{
			return _reference;
		}
		
		public function get url(): URLRequest
		{
			try 
			{
				return new URLRequest( _reference );
			}
			catch( mue: Error )
			{}
			return null;
		}
	}
}