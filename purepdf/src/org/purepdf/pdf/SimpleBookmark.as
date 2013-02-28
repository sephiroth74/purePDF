/*
 *                             ______ _____  _______
 * .-----..--.--..----..-----.|   __ \     \|    ___|
 * |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
 * |   __||_____||__|  |_____||___|  |_____/|___|
 * |__|
 * $Id: SimpleBookmark.as 335 2010-02-14 23:08:03Z alessandro.crugnola $
 * $Author Alessandro Crugnola $
 * $Rev: 335 $ $LastChangedDate: 2010-02-14 18:08:03 -0500 (Sun, 14 Feb 2010) $
 * $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/pdf/SimpleBookmark.as $
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
	import it.sephiroth.utils.hashLib;
	
	import org.purepdf.utils.StringUtils;

	public class SimpleBookmark
	{
		public function SimpleBookmark()
		{
		}

		/**
		 * Gets a List with the bookmarks. It returns null if
		 * the document doesn't have any bookmarks.
		 * @param reader the document
		 * @return a List with the bookmarks or null if the
		 * document doesn't have any
		 */
		public static function getBookmark( reader: PdfReader ): Vector.<HashMap>
		{
			var catalog: PdfDictionary = reader.getCatalog();
			var obj: PdfObject = PdfReader.getPdfObjectRelease( catalog.getValue( PdfName.OUTLINES ) );
			if ( obj == null || !obj.isDictionary() )
				return null;
			var outlines: PdfDictionary = PdfDictionary( obj );
			var pages: HashMap = new HashMap();
			var numPages: int = reader.getNumberOfPages();
			for ( var k: int = 1; k <= numPages; ++k )
			{
				pages.put( reader.getPageOrigRef( k ).number, k );
				reader.releasePage( k );
			}
			return bookmarkDepth( reader, PdfDictionary( PdfReader.getPdfObjectRelease( outlines.getValue( PdfName.FIRST ) ) ), pages );
		}

		private static function bookmarkDepth( reader: PdfReader, outline: PdfDictionary, pages: HashMap ): Vector.<HashMap>
		{
			var list: Vector.<HashMap> = new Vector.<HashMap>();
			var s: String;
			var file: PdfObject;
			
			while ( outline != null )
			{
				var map: HashMap = new HashMap();
				var title: PdfString = PdfString( PdfReader.getPdfObjectRelease( outline.getValue( PdfName.TITLE ) ) );
				map.put( "Title", title.toUnicodeString() );
				var color: PdfArray = PdfArray( PdfReader.getPdfObjectRelease( outline.getValue( PdfName.C ) ) );
				if ( color != null && color.size == 3 )
				{
					var out: ByteBuffer = new ByteBuffer();
					out.append( color.getAsNumber( 0 ).floatValue() ).append_char( ' ' );
					out.append( color.getAsNumber( 1 ).floatValue() ).append_char( ' ' );
					out.append( color.getAsNumber( 2 ).floatValue() );
					map.put( "Color", PdfEncodings.convertToString( out.toByteArray(), null ) );
				}
				var style: PdfNumber = PdfNumber( PdfReader.getPdfObjectRelease( outline.getValue( PdfName.F ) ) );
				if ( style != null )
				{
					var f: int = style.intValue();
					s = "";
					if ( ( f & 1 ) != 0 )
						s += "italic ";
					if ( ( f & 2 ) != 0 )
						s += "bold ";
					s = StringUtils.trim( s );
					if ( s.length != 0 )
						map.put( "Style", s );
				}
				var count: PdfNumber = PdfNumber( PdfReader.getPdfObjectRelease( outline.getValue( PdfName.COUNT ) ) );
				if ( count != null && count.intValue() < 0 )
					map.put( "Open", "false" );
				try
				{
					var dest: PdfObject = PdfReader.getPdfObjectRelease( outline.getValue( PdfName.DEST ) );
					if ( dest != null )
					{
						mapGotoBookmark( map, dest, pages );
					} else
					{
						var action: PdfDictionary = PdfDictionary( PdfReader.getPdfObjectRelease( outline.getValue( PdfName.A ) ) );
						if ( action != null )
						{
							if ( PdfName.GOTO.equals( PdfReader.getPdfObjectRelease( action.getValue( PdfName.S ) ) ) )
							{
								dest = PdfReader.getPdfObjectRelease( action.getValue( PdfName.D ) );
								if ( dest != null )
								{
									mapGotoBookmark( map, dest, pages );
								}
							} else if ( PdfName.URI.equals( PdfReader.getPdfObjectRelease( action.getValue( PdfName.S ) ) ) )
							{
								map.put( "Action", "URI" );
								map.put( "URI", PdfString( PdfReader.getPdfObjectRelease( action.getValue( PdfName.URI ) ) ).toUnicodeString() );
							} else if ( PdfName.GOTOR.equals( PdfReader.getPdfObjectRelease( action.getValue( PdfName.S ) ) ) )
							{
								dest = PdfReader.getPdfObjectRelease( action.getValue( PdfName.D ) );
								if ( dest != null )
								{
									if ( dest.isString() )
										map.put( "Named", dest.toString() );
									else if ( dest.isName() )
										map.put( "NamedN", PdfName.decodeName( dest.toString() ) );
									else if ( dest.isArray() )
									{
										var arr: PdfArray = PdfArray( dest );
										s = "";
										s += arr.getPdfObject( 0 ).toString();
										s += ' ' + arr.getPdfObject( 1 ).toString();
										for ( var k: int = 2; k < arr.size; ++k )
											s += ' ' + arr.getPdfObject( k ).toString();
										map.put( "Page", s.toString() );
									}
								}
								map.put( "Action", "GoToR" );
								file = PdfReader.getPdfObjectRelease( action.getValue( PdfName.F ) );
								if ( file != null )
								{
									if ( file.isString() )
										map.put( "File", PdfString( file ).toUnicodeString() );
									else if ( file.isDictionary() )
									{
										file = PdfReader.getPdfObject( PdfDictionary( file ).getValue( PdfName.F ) );
										if ( file.isString() )
											map.put( "File", PdfString( file ).toUnicodeString() );
									}
								}
								var newWindow: PdfObject = PdfReader.getPdfObjectRelease( action.getValue( PdfName.NEWWINDOW ) );
								if ( newWindow != null )
									map.put( "NewWindow", newWindow.toString() );
							} else if ( PdfName.LAUNCH.equals( PdfReader.getPdfObjectRelease( action.getValue( PdfName.S ) ) ) )
							{
								map.put( "Action", "Launch" );
								file = PdfReader.getPdfObjectRelease( action.getValue( PdfName.F ) );
								if ( file == null )
									file = PdfReader.getPdfObjectRelease( action.getValue( PdfName.WIN ) );
								if ( file != null )
								{
									if ( file.isString() )
										map.put( "File", PdfString( file ).toUnicodeString() );
									else if ( file.isDictionary() )
									{
										file = PdfReader.getPdfObjectRelease( PdfDictionary( file ).getValue( PdfName.F ) );
										if ( file.isString() )
											map.put( "File", PdfString( file ).toUnicodeString() );
									}
								}
							}
						}
					}
				} catch ( e: Error )
				{
					//empty on purpose
				}
				var first: PdfDictionary = PdfDictionary( PdfReader.getPdfObjectRelease( outline.getValue( PdfName.FIRST ) ) );
				if ( first != null )
				{
					map.put( "Kids", bookmarkDepth( reader, first, pages ) );
				}
				list.push( map );
				outline = PdfDictionary( PdfReader.getPdfObjectRelease( outline.getValue( PdfName.NEXT ) ) );
			}
			return list;
		}

		/**
		 * Gets number of indirect. If type of directed indirect is PAGES, it refers PAGE object through KIDS.
		 * @param indirect
		 */
		private static function getNumber( indirect: PdfIndirectReference ): int
		{
			var pdfObj: PdfDictionary = PdfDictionary( PdfReader.getPdfObjectRelease( indirect ) );
			if ( pdfObj.contains( PdfName.TYPE ) && pdfObj.getValue( PdfName.TYPE ).equals( PdfName.PAGES ) && pdfObj.contains( PdfName.KIDS ) )
			{
				var kids: PdfArray = PdfArray( pdfObj.getValue( PdfName.KIDS ) );
				indirect = PdfIndirectReference( kids.getPdfObject( 0 ) );
			}
			return indirect.number;
		}

		private static function makeBookmarkParam( dest: PdfArray, pages: HashMap ): String
		{
			var s: String = "";
			var obj: PdfObject = dest.getPdfObject( 0 );
			if ( obj.isNumber() )
				s += PdfNumber( obj ).intValue() + 1;
			else
				s += pages.getValue( getNumber( PdfIndirectReference( obj ) ) );
			s += ' ' + ( dest.getPdfObject( 1 ).toString().substring( 1 ) );
			for ( var k: int = 2; k < dest.size; ++k )
				s += " " + ( dest.getPdfObject( k ).toString() );
			return s;
		}

		private static function mapGotoBookmark( map: HashMap, dest: PdfObject, pages: HashMap ): void
		{
			if ( dest.isString() )
				map.put( "Named", dest.toString() );
			else if ( dest.isName() )
				map.put( "Named", PdfName.decodeName( dest.toString() ) );
			else if ( dest.isArray() )
				map.put( "Page", makeBookmarkParam( PdfArray( dest ), pages ) );
			map.put( "Action", "GoTo" );
		}
	}
}