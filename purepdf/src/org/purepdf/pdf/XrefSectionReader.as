/*
*                             ______ _____  _______
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|
* |__|
* $Id: XrefSectionReader.as 401 2011-02-07 11:05:24Z alessandro.crugnola@gmail.com $
* $Author Alessandro Crugnola $
* $Rev: 401 $ $LastChangedDate: 2011-02-07 06:05:24 -0500 (Mon, 07 Feb 2011) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/pdf/XrefSectionReader.as $
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
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	
	import org.purepdf.pdf.interfaces.IDisposable;

	[Event(name="complete", type="flash.events.Event")]
	[Event(name="error", type="flash.events.ErrorEvent")]
	public class XrefSectionReader extends EventDispatcher implements IDisposable
	{
		private var end: int = 0;
		private var gen: int = 0;
		private var pos: int = 0;
		private var reader: PdfReader;
		private var start: int = 0;
		public var trailer: PdfDictionary;

		public function XrefSectionReader( reader: PdfReader )
		{
			super( null );
			this.reader = reader;
		}

		public function dispose(): void
		{
			reader = null;
			trailer = null;
		}

		public function run(): void
		{
			start = 0;
			end = 0;
			gen = 0;
			pos = 0;
			reader.tokens.nextValidToken();
			if ( !reader.tokens.stringValue == "xref" )
			{
				dispatchEvent( new ErrorEvent( ErrorEvent.ERROR, false, false, "xref subsection not found" ) );
				return;
			}
			execute_while();
		}

		private function execute_while(): void
		{
			reader.tokens.nextValidToken();
			if ( reader.tokens.stringValue == "trailer" )
			{
				complete();
				return;
			}
			
			if ( reader.tokens.getTokenType() != PRTokeniser.TK_NUMBER )
			{
				dispatchEvent( new ErrorEvent( ErrorEvent.ERROR, false, false, "object number of the first object in this xref subsection not found" ) );
				return;
			}

			start = reader.tokens.intValue();
			reader.tokens.nextValidToken();
			if ( reader.tokens.getTokenType() != PRTokeniser.TK_NUMBER )
			{
				dispatchEvent( new ErrorEvent( ErrorEvent.ERROR, false, false, "number of entries in this xref subsection not found" ) );
				return;
			}

			end = reader.tokens.intValue() + start;
			if ( start == 1 )
			{
				var back: int = reader.tokens.getFilePointer();
				reader.tokens.nextValidToken();
				pos = reader.tokens.intValue();
				reader.tokens.nextValidToken();
				gen = reader.tokens.intValue();
				if ( pos == 0 && gen == PdfWriter.GENERATION_MAX )
				{
					--start;
					--end;
				}
				reader.tokens.seek( back );
			}
			reader.ensureXrefSize( end * 2 );
			
			execute_for( start );
		}
		
		protected function execute_for( k: int ): void
		{
			var t: Number = getTimer();
			for ( k; k < end; ++k )
			{
				reader.tokens.nextValidToken();
				pos = reader.tokens.intValue();
				reader.tokens.nextValidToken();
				gen = reader.tokens.intValue();
				reader.tokens.nextValidToken();
				var p: int = k * 2;
				if ( reader.tokens.stringValue == "n" )
				{
					if ( reader.xref[p] == 0 && reader.xref[p + 1] == 0 )
					{
						reader.xref[p] = pos;
					}
				} else if ( reader.tokens.stringValue == "f" )
				{
					if ( reader.xref[p] == 0 && reader.xref[p + 1] == 0 )
						reader.xref[p] = -1;
				} else
				{
					dispatchEvent( new ErrorEvent( ErrorEvent.ERROR, false, false, "invalid cross reference entry in this xref subsection" ) );
					return;
				}
				
				if( ( getTimer() - t ) > PdfReader.TIMER_STEP && k < end )
				{
					setTimeout( execute_for, 10, ++k );
					return;
				}
			}
			execute_while();
		}
		
		protected function complete(): void
		{
			trailer = PdfDictionary( reader.readPRObject() );
			var xrefSize: PdfNumber = PdfNumber( trailer.getValue( PdfName.SIZE ) );
			reader.ensureXrefSize( xrefSize.intValue() * 2 );
			var xrs: PdfObject = trailer.getValue( PdfName.XREFSTM );
			if ( xrs != null && xrs.isNumber() )
			{
				var loc: int = PdfNumber( xrs ).intValue();
				try
				{
					reader.readXRefStream( loc );
					reader.newXrefType = true;
					reader.hybridXref = true;
				} catch ( e: EOFError )
				{
					reader.xref = null;
					dispatchEvent( new ErrorEvent( ErrorEvent.ERROR, false, false, e.getStackTrace() ) );
					return;
				}
			}
			dispatchEvent( new Event( Event.COMPLETE ) );
		}
	}
}