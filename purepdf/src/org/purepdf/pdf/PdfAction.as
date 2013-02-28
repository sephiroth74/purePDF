/*
 *                             ______ _____  _______
 * .-----..--.--..----..-----.|   __ \     \|    ___|
 * |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
 * |   __||_____||__|  |_____||___|  |_____/|___|
 * |__|
 * $Id: PdfAction.as 394 2011-01-14 18:48:14Z alessandro.crugnola@gmail.com $
 * $Author Alessandro Crugnola $
 * $Rev: 394 $ $LastChangedDate: 2011-01-14 13:48:14 -0500 (Fri, 14 Jan 2011) $
 * $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/pdf/PdfAction.as $
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
	import org.purepdf.errors.RuntimeError;
	import org.purepdf.utils.Bytes;
	import org.purepdf.utils.pdf_core;

	/**
	 * A PdfAction defines an action that can be triggered
	 */
	public class PdfAction extends PdfDictionary
	{

		use namespace pdf_core;

		public static const FIRSTPAGE: int = 1;
		public static const LASTPAGE: int = 4;
		public static const NEXTPAGE: int = 3;
		public static const PREVPAGE: int = 2;
		public static const PRINTDIALOG: int = 5;

		public function PdfAction()
		{
		}

		public static function fromDestination( destination: PdfIndirectReference ): PdfAction
		{
			var action: PdfAction = new PdfAction();
			action.put( PdfName.S, PdfName.GOTO );
			action.put( PdfName.D, destination );
			return action;
		}
		
		public static function fromFileDestination( filename: String, name: String ): PdfAction
		{
			var action: PdfAction = new PdfAction();
			action.put( PdfName.S, PdfName.GOTOR );
			action.put( PdfName.F, new PdfString( filename ) );
			action.put( PdfName.D, new PdfString( name ) );
			return action;
		}

		/**
		 * Creates a new PDfAction from a named action
		 *
		 * @see #FIRSTPAGE
		 * @see #PREVPAGE
		 * @see #NEXTPAGE
		 * @see #LASTPAGE
		 * @see #PRINTDIALOG
		 */
		public static function fromNamed( named: int ): PdfAction
		{
			var r: PdfAction = new PdfAction();
			r.put( PdfName.S, PdfName.NAMED );

			switch ( named )
			{
				case FIRSTPAGE:
					r.put( PdfName.N, PdfName.FIRSTPAGE );
					break;

				case PREVPAGE:
					r.put( PdfName.N, PdfName.PREVPAGE );
					break;

				case NEXTPAGE:
					r.put( PdfName.N, PdfName.NEXTPAGE );
					break;

				case LASTPAGE:
					r.put( PdfName.N, PdfName.LASTPAGE );
					break;

				case PRINTDIALOG:
					r.put( PdfName.S, PdfName.JAVASCRIPT );
					r.put( PdfName.JS, new PdfString( "this.print(true);\r" ) );
					break;

				default:
					throw new RuntimeError( "invalid named action" );
			}

			return r;
		}

		public static function fromURL( url: String, isMap: Boolean = false ): PdfAction
		{
			var action: PdfAction = new PdfAction();
			action.put( PdfName.S, PdfName.URI );
			action.put( PdfName.URI, new PdfString( url ) );

			if ( isMap )
				action.put( PdfName.ISMAP, PdfBoolean.PDF_TRUE );
			return action;
		}

		/**
		 * Create a JavaScript action. If the JavaScript is smaller than
		 * 50 characters it will be placed as a string, otherwise it will
		 * be placed as a compressed stream.
		 *
		 * @param code the JavaScript code
		 * @param writer the writer for this action
		 *
		 * @return the JavaScript action
		 */
		public static function javaScript( code: String, writer: PdfWriter, unicode: Boolean = false ): PdfAction
		{
			var js: PdfAction = new PdfAction();
			js.put( PdfName.S, PdfName.JAVASCRIPT );

			if ( unicode && code.length < 50 )
			{
				js.put( PdfName.JS, new PdfString( code, PdfObject.TEXT_UNICODE ) );
			} else if ( !unicode && code.length < 100 )
			{
				js.put( PdfName.JS, new PdfString( code ) );
			} else
			{
				try
				{
					var b: Bytes = PdfEncodings.convertToBytes( code, unicode ? PdfObject.TEXT_UNICODE : PdfObject.TEXT_PDFDOCENCODING );
					var stream: PdfStream = new PdfStream( b );
					stream.flateCompress( writer.compressionLevel );
					js.put( PdfName.JS, writer.addToBody( stream ).indirectReference );
				} catch ( e: Error )
				{
					js.put( PdfName.JS, new PdfString( code ) );
				}
			}
			return js;
		}

		/**
		 * Creates a Rendition action
		 * @param file
		 * @param fs
		 * @param mimeType
		 * @param ref
		 * @return a Media Clip action
		 * @throws IOError
		 */
		public static function rendition( file: String, fs: PdfFileSpecification, mimeType: String, ref: PdfIndirectReference ): PdfAction
		{
			var js: PdfAction = new PdfAction();
			js.put( PdfName.S, PdfName.RENDITION );
			js.put( PdfName.R, new PdfRendition( file, fs, mimeType ) );
			js.put( new PdfName( "OP" ), new PdfNumber( 0 ) );
			js.put( new PdfName( "AN" ), ref );
			return js;
		}
	}
}