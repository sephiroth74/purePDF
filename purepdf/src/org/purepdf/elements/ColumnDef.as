/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: ColumnDef.as 238 2010-01-31 10:49:33Z alessandro.crugnola $
* $Author Alessandro Crugnola $
* $Rev: 238 $ $LastChangedDate: 2010-01-31 05:49:33 -0500 (Sun, 31 Jan 2010) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/elements/ColumnDef.as $
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
	import org.purepdf.errors.RuntimeError;

	internal class ColumnDef
	{
		private var _left: Vector.<Number>;
		private var _right: Vector.<Number>;
		private var _ref: MultiColumnText;
		
		public function ColumnDef( ref: MultiColumnText )
		{
			_ref = ref;
		}
		
		public function create( newLeft: Vector.<Number>, newRight: Vector.<Number> ): void
		{
			_left = newLeft;
			_right = newRight;
		}
		
		public function createSimple( leftPosition: Number, rightPosition: Number ): void
		{
			_left = new Vector.<Number>(4, true);
			_left[0] = leftPosition; // x1
			_left[1] = _ref.top;          // y1
			_left[2] = leftPosition; // x2
			
			if( _ref._desiredHeight == MultiColumnText.AUTOMATIC || _ref.top == MultiColumnText.AUTOMATIC )
			{
				_left[3] = MultiColumnText.AUTOMATIC;
			} else {
				_left[3] = _ref.top - _ref._desiredHeight;
			}
			
			_right = new Vector.<Number>(4, true);
			_right[0] = rightPosition; // x1
			_right[1] = _ref.top;           // y1
			_right[2] = rightPosition; // x2
			if( _ref._desiredHeight == MultiColumnText.AUTOMATIC || _ref.top == MultiColumnText.AUTOMATIC) {
				_right[3] = MultiColumnText.AUTOMATIC;
			} else {
				_right[3] = _ref.top - _ref._desiredHeight;
			}
		}
		
		/**
		 * 
		 * @throws RuntimeError
		 */
		internal function resolvePositions( side: int ): Vector.<Number>
		{
			if( side == RectangleElement.LEFT )
				return _resolvePositions( _left );
			else 
				return _resolvePositions( _right );
		}
		
		private function _resolvePositions( positions: Vector.<Number> ): Vector.<Number>
		{
			if( !simple )
			{
				positions[1] = _ref.top;
				return positions;
			}
			
			if( _ref.top == MultiColumnText.AUTOMATIC )
				throw new RuntimeError( "resolvePositions called with top=AUTOMATIC (-1). Top position must be set befure lines can be resolved" );

			positions[1] = _ref.top;
			positions[3] = _ref.getColumnBottom();
			return positions;
		}
		
		internal function get simple(): Boolean
		{
			return (_left.length == 4 && _right.length == 4) && (_left[0] == _left[2] && _right[0] == _right[2]);
		}
	}
}