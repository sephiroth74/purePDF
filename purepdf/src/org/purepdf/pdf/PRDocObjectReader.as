/*
*                             ______ _____  _______
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|
* |__|
* $Id: PRDocObjectReader.as 351 2010-02-27 07:30:47Z alessandro.crugnola $
* $Author Alessandro Crugnola $
* $Rev: 351 $ $LastChangedDate: 2010-02-27 02:30:47 -0500 (Sat, 27 Feb 2010) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/pdf/PRDocObjectReader.as $
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
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.ProgressEvent;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;

	[Event( name="complete", type="flash.events.Event" )]
	[Event( name="error", type="flash.events.errors.ErrorEvent" )]
	[Event( name="progress", type="flash.events.ProgressEvent" )]
	public class PRDocObjectReader extends EventDispatcher
	{
		public var streams: Vector.<PdfObject>;
		
		private var tokens: PRTokeniser;
		private var xref: Vector.<int>;
		private var xrefObj: Vector.<PdfObject>;
		private var reader: PdfReader;
		private var k: int;
		private var progress_event: ProgressEvent;

		public function PRDocObjectReader( pdf: PdfReader )
		{
			super( null );
			reader = pdf;
		}

		public function run(): void
		{
			streams = new Vector.<PdfObject>();
			xrefObj = reader.getxrefobj();
			xref = reader.getxref();
			tokens = reader.getTokens();
			k = 2;
			progress_event = new ProgressEvent( ProgressEvent.PROGRESS, false, false, 0, xref.length );
			setTimeout( step, 5 );
		}

		public function dispose(): void
		{
			xref = null;
			reader = null;
			xrefObj = null;
		}

		private function step(): void
		{
			try
			{
				var timer: Number = getTimer();
				while ( getTimer() - timer < PdfReader.TIMER_STEP )
				{
					if( k < xref.length )
					{
						var pos: int = xref[k];
						if ( pos <= 0 || xref[k + 1] > 0 )
						{
							k += 2;
							continue;
						}
						tokens.seek( pos );
						tokens.nextValidToken();
						if ( tokens.getTokenType() != PRTokeniser.TK_NUMBER )
							tokens.throwError( "invalid object number" );
						reader.setObjNum( tokens.intValue() );
						tokens.nextValidToken();
						if ( tokens.getTokenType() != PRTokeniser.TK_NUMBER )
							tokens.throwError( "invalid generation number" );
						reader.setObjGen( tokens.intValue() );
						tokens.nextValidToken();
						if ( tokens.stringValue != "obj" )
							tokens.throwError( "token obj expected" );
						var obj: PdfObject;
						try
						{
							obj = reader.readPRObject();
							if ( obj.isStream() )
							{
								streams.push( obj );
							}
						} catch ( e: Error )
						{
							obj = null;
						}
						xrefObj[k / 2] = obj;
						
						progress_event.bytesLoaded = k;
						dispatchEvent( progress_event ); 
						
						k += 2;
					} else
					{
						dispatchEvent( new Event( Event.COMPLETE ) );
						return;
					}
				}
				setTimeout( step, 5 );
			} catch( e: Error )
			{
				dispatchEvent( new ErrorEvent( ErrorEvent.ERROR, false, false, e.message ) );
			}
		}
	}
}