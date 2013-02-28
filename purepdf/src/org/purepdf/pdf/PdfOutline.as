/*
 *                             ______ _____  _______
 * .-----..--.--..----..-----.|   __ \     \|    ___|
 * |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
 * |   __||_____||__|  |_____||___|  |_____/|___|
 * |__|
 * $Id: PdfOutline.as 242 2010-02-01 14:30:41Z alessandro.crugnola $
 * $Author Alessandro Crugnola $
 * $Rev: 242 $ $LastChangedDate: 2010-02-01 09:30:41 -0500 (Mon, 01 Feb 2010) $
 * $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/pdf/PdfOutline.as $
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
	import org.purepdf.Font;
	import org.purepdf.colors.RGBColor;
	import org.purepdf.elements.Chunk;
	import org.purepdf.elements.Paragraph;
	import org.purepdf.pdf.interfaces.IOutputStream;

	public class PdfOutline extends PdfDictionary
	{
		protected var _action: PdfAction;
		protected var _destination: PdfDestination;
		protected var _writer: PdfWriter;
		private var _color: RGBColor;
		private var _count: int = 0;
		private var _kids: Vector.<PdfOutline> = new Vector.<PdfOutline>();
		private var _open: Boolean;
		private var _parent: PdfOutline;
		private var _reference: PdfIndirectReference;
		private var _style: int = 0;
		private var _tag: String;

		public function PdfOutline( $writer: PdfWriter )
		{
			super( $writer == null ? null : OUTLINES );

			if ( $writer != null )
			{
				_open = true;
				_parent = null;
				_writer = $writer;
			}
		}

		public function addKid( outline: PdfOutline ): void
		{
			_kids.push( outline );
		}

		public function get color(): RGBColor
		{
			return _color;
		}

		public function set color( value: RGBColor ): void
		{
			_color = value;
		}

		public function get count(): int
		{
			return _count;
		}

		public function set count( value: int ): void
		{
			_count = value;
		}

		public function get indirectReference(): PdfIndirectReference
		{
			return _reference;
		}

		public function set indirectReference( value: PdfIndirectReference ): void
		{
			_reference = value;
		}

		public function get kids(): Vector.<PdfOutline>
		{
			return _kids;
		}

		public function set kids( value: Vector.<PdfOutline> ): void
		{
			_kids = value;
		}

		public function get level(): int
		{
			if ( parent == null )
				return 0;
			return parent.level + 1;
		}

		public function set open( value: Boolean ): void
		{
			_open = value;
		}

		public function get opened(): Boolean
		{
			return _open;
		}

		public function get parent(): PdfOutline
		{
			return _parent;
		}

		public function setDestinationPage( pageReference: PdfIndirectReference ): Boolean
		{
			if ( _destination == null )
				return false;
			return _destination.addPage( pageReference );
		}

		public function get style(): int
		{
			return _style;
		}

		public function set style( value: int ): void
		{
			_style = value;
		}

		public function get tag(): String
		{
			return _tag;
		}

		public function set tag( value: String ): void
		{
			_tag = value;
		}

		public function get title(): String
		{
			var title: PdfString = PdfString( getValue( PdfName.TITLE ) );
			return title.toString();
		}

		public function set title( value: String ): void
		{
			put( PdfName.TITLE, new PdfString( title, PdfObject.TEXT_UNICODE ) );
		}

		override public function toPdf( writer: PdfWriter, os: IOutputStream ): void
		{
			if ( _color != null && !_color.equals( RGBColor.BLACK ) )
				put( PdfName.C, new PdfArray( Vector.<Number>( [ color.red / 255, color.green / 255, color.blue / 255 ] ) ) );

			var flag: int = 0;
			if ( ( _style & Font.BOLD ) != 0 )
				flag |= 2;

			if ( ( _style & Font.ITALIC ) != 0 )
				flag |= 1;

			if ( flag != 0 )
				put( PdfName.F, new PdfNumber( flag ) );

			if ( _parent != null )
				put( PdfName.PARENT, _parent.indirectReference );

			if ( _destination != null && _destination.hasPage )
				put( PdfName.DEST, _destination );

			if ( _action != null )
				put( PdfName.A, _action );

			if ( _count != 0 )
			{
				put( PdfName.COUNT, new PdfNumber( _count ) );
			}
			super.toPdf( writer, os );
		}

		/**
		 * Constructs a PdfOutline
		 */

		public function get writer(): PdfWriter
		{
			return _writer;
		}

		public function set writer( value: PdfWriter ): void
		{
			_writer = value;
		}

		internal function initOutline( parent: PdfOutline, title: String, open: Boolean ): void
		{
			_open = open;
			_parent = parent;
			_writer = parent.writer;
			put( PdfName.TITLE, new PdfString( title, PdfObject.TEXT_UNICODE ) );
			parent.addKid( this );
			if ( _destination != null && !_destination.hasPage )
				setDestinationPage( writer.getCurrentPage() );
		}

		public static function create( parent: PdfOutline, destination: PdfDestination, title: Paragraph, open: Boolean ): PdfOutline
		{
			var p: PdfOutline = new PdfOutline( null );

			var buf: String = "";
			var chunks: Vector.<Object> = title.getChunks();

			for ( var i: int = 0; i < chunks.length; ++i )
			{
				var chunk: Chunk = Chunk( chunks[i] );
				buf += chunk.content;
			}

			p._destination = destination;
			p.initOutline( parent, buf, open );
			return p;
		}
	}
}