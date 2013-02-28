/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: PdfDictionary.as 332 2010-02-14 19:57:16Z alessandro.crugnola $
* $Author Alessandro Crugnola $
* $Rev: 332 $ $LastChangedDate: 2010-02-14 14:57:16 -0500 (Sun, 14 Feb 2010) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/pdf/PdfDictionary.as $
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
	import it.sephiroth.utils.HashMap;
	import it.sephiroth.utils.IObject;
	import it.sephiroth.utils.KeySet;
	import it.sephiroth.utils.ObjectHash;
	import it.sephiroth.utils.collections.iterators.Iterator;
	
	import org.purepdf.pdf.interfaces.IOutputStream;

	public class PdfDictionary extends PdfObject implements IObject
	{
		public static const PAGE: PdfName = PdfName.PAGE;
		public static const CATALOG: PdfName = PdfName.CATALOG;
		public static const OUTLINES: PdfName = PdfName.OUTLINES;
		
		protected var hashMap: HashMap;
		protected var dictionaryType: PdfName;
		
		public function PdfDictionary( $type: PdfName = null )
		{
			super( DICTIONARY );
			hashMap = new HashMap();
			
			if( $type != null )
			{
				dictionaryType = $type;
				put( PdfName.TYPE, dictionaryType );
			}
		}
		
		public function put( key: PdfName, object: PdfObject ): void
		{
			if( object == null || object.isNull() )
			{
				hashMap.remove( key );
			} else {
				hashMap.put( key, object );
			}
		}
		
		/**
		 * Associates the specified PdfObject as value to the
		 * specified PdfName as key in this map.
		 * 
		 * If the value is a PdfNull, it is treated just as
		 * any other PdfObject. If the value is
		 * null however nothing is done.  
		 *
		 * @param key a PdfName
		 * @param value the PdfObject to be associated to the key
		 */
		public function putEx( key: PdfName, value: PdfObject ): void
		{
			if( value == null )
				return;
			put( key, value );
		}
		
		public function remove( key: PdfName ): void
		{
			hashMap.remove( key );
		}
		
		public function getKeys(): KeySet
		{
			return hashMap.keySet();
		}
		
		public function getValue( key: PdfName ): PdfObject
		{
			return hashMap.getValue( key ) as PdfObject;
		}
		
		public function get size(): int
		{
			return hashMap.size();
		}
		
		public function mergeDifferent( other: PdfDictionary ): void
		{
			var i: Iterator = other.hashMap.keySet().iterator();
			for( i; i.hasNext(); )
			{
				var key: ObjectHash = i.next();
				if( !hashMap.containsKey( key ) )
					hashMap.put( key, other.hashMap.getValue( key ) );
			}
		}
		
		override public function toString(): String
		{
			if( getValue( PdfName.TYPE ) == null )
				return "Dictionary";
			return "Dictionary of type: " + getValue( PdfName.TYPE );
		}
		
		public function merge( other: PdfDictionary ): void
		{
			hashMap.putAll( other.hashMap );
		}
		
		public function putAll( other: PdfDictionary ): void
		{
			hashMap.putAll( other.hashMap );
		}
		
		public function contains( key: PdfName ): Boolean
		{
			return hashMap.containsKey(key);
		}
		
		public function getAsDict( key: PdfName ): PdfDictionary
		{
			var dict: PdfDictionary = null;
			var orig: PdfObject = getDirectObject( key );
			if( orig != null && orig.isDictionary() )
				dict = orig as PdfDictionary;
			return dict;
		}
		
		/**
		 * Returns a PdfObject as a PdfNumber,
		 * resolving indirect references.
		 * 
		 * The object associated with the PdfName given is retrieved
		 * and resolved to a direct object.
		 * If it is a PdfNumber, it is cast down and returned as such.
		 * Otherwise null is returned.
		 *     
		 * @param key a PdfName
		 * @return the associated PdfNumber object, or null
		 */
		public function getAsNumber( key: PdfName ): PdfNumber
		{
			var number: PdfNumber = null;
			var orig: PdfObject = getDirectObject( key );
			if (orig != null && orig.isNumber())
				number = PdfNumber(orig);
			return number;
		}

		/**
		 * Returns a <code>PdfObject</code> as a <code>PdfArray</code>,
		 * resolving indirect references.
		 *
		 * The object associated with the <code>PdfName</code> given is retrieved
		 * and resolved to a direct object.
		 * If it is a <code>PdfArray</code>, it is cast down and returned as such.
		 * Otherwise <code>null</code> is returned.
		 *
		 * @param key A <code>PdfName</code>
		 * @return the associated <code>PdfArray</code> object,
		 *   or <code>null</code>
		 */
		public function getAsArray( key: PdfName ): PdfArray
		{
			var array: PdfArray = null;
			var orig: PdfObject = getDirectObject( key );
			if ( orig != null && orig.isArray() )
				array = PdfArray( orig );
			return array;
		}
		
		/**
		 * Returns the <CODE>PdfObject</CODE> associated to the specified
		 * <VAR>key</VAR>, resolving a possible indirect reference to a direct
		 * object.
		 * 
		 * This method will never return a <CODE>PdfIndirectReference</CODE>
		 * object.  
		 * 
		 */
		public function getDirectObject( key: PdfName ): PdfObject
		{
			return PdfReader.getPdfObject( getValue( key ) );
		}
		
		override public function toPdf( writer: PdfWriter, os: IOutputStream ) : void
		{			
			os.writeInt( 60 /* '<' */ );
			os.writeInt( 60 /* '<' */ );
			
			var value: PdfObject;
			var type: int = 0;
			
			var key: PdfName;
			var i: Iterator = hashMap.keySet().iterator();
			
			for( i; i.hasNext(); )
			{
				key = PdfName( i.next() );
				value = PdfObject( hashMap.getValue( key ) );
				
				key.toPdf( writer, os );
				type = value.getType();

				
				if( type != PdfObject.ARRAY && type != PdfObject.DICTIONARY && type != PdfObject.NAME && type != PdfObject.STRING )
					os.writeInt( 32 /* ' ' */ );
				value.toPdf( writer, os );
			}
			
			os.writeInt( 62 /* '>' */ );
			os.writeInt( 62 /* '>' */ );
		}
	}
}