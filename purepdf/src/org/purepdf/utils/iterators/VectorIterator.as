/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: VectorIterator.as 238 2010-01-31 10:49:33Z alessandro.crugnola $
* $Author Alessandro Crugnola $
* $Rev: 238 $ $LastChangedDate: 2010-01-31 05:49:33 -0500 (Sun, 31 Jan 2010) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/utils/iterators/VectorIterator.as $
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
package org.purepdf.utils.iterators
{
	import it.sephiroth.utils.collections.iterators.Iterator;
	
	import org.purepdf.errors.IndexOutOfBoundsError;

	public class VectorIterator implements Iterator
	{
		protected var _data: Vector.<Object>;
		protected var pointer: int;
		
		public function VectorIterator( data: Vector.<Object> )
		{
			_data = data;
			pointer = 0;
		}
		
		/**
		 * Remove the last element returned by the next()
		 * method.
		 * This can be called only one
		 */
		public function remove(): void
		{
			if( _data.length > pointer )
			{
				_data.splice( pointer, 1 );
				pointer--;
			} else
			{
				throw new IndexOutOfBoundsError();
			}
		}
		
		public function get length(): int
		{
			return _data.length;
		}
		
		public function rewind(): void
		{
			pointer = 0;
		}
		
		public function hasNext(): Boolean
		{
			return _data.length > pointer;
		}
		
		public function next(): *
		{
			if( _data.length > pointer )
				return _data[pointer++];
			return null;
		}
		
		public function get index(): int
		{
			return pointer;
		}
	}
}