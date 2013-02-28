/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: TrueTypeFontSubSet.as 238 2010-01-31 10:49:33Z alessandro.crugnola $
* $Author Alessandro Crugnola $
* $Rev: 238 $ $LastChangedDate: 2010-01-31 05:49:33 -0500 (Sun, 31 Jan 2010) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/pdf/fonts/TrueTypeFontSubSet.as $
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
package org.purepdf.pdf.fonts
{
	import flash.utils.ByteArray;
	
	import it.sephiroth.utils.HashMap;
	import it.sephiroth.utils.collections.iterators.Iterator;
	
	import org.purepdf.errors.DocumentError;
	import org.purepdf.pdf.ByteBuffer;
	import org.purepdf.pdf.PdfEncodings;
	import org.purepdf.utils.Bytes;

	[Abstract]
	public class TrueTypeFontSubSet
	{
		public static const tableNamesSimple: Vector.<String> = Vector.<String>( [ "cvt ", "fpgm", "glyf", "head", "hhea", "hmtx", "loca", "maxp", "prep" ] );
		public static const tableNamesCmap: Vector.<String> = Vector.<String>( [ "cmap", "cvt ", "fpgm", "glyf", "head", "hhea", "hmtx", "loca", "maxp", "prep" ] );
		public static const tableNamesExtra: Vector.<String> = Vector.<String>( [ "OS/2", "cmap", "cvt ", "fpgm", "glyf", "head", "hhea", "hmtx", "loca", "maxp", "name, prep" ] );
		public static const entrySelectors: Vector.<int> = Vector.<int>( [ 0, 0, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4 ] );
		public static const HEAD_LOCA_FORMAT_OFFSET: int = 51;
		public static const TABLE_CHECKSUM: int = 0;
		public static const TABLE_OFFSET: int = 1;
		public static const TABLE_LENGTH: int = 2;		
		public static const ARG_1_AND_2_ARE_WORDS: int = 1;
		public static const WE_HAVE_A_SCALE: int = 8;
		public static const MORE_COMPONENTS: int = 32;
		public static const WE_HAVE_AN_X_AND_Y_SCALE: int = 64;
		public static const WE_HAVE_A_TWO_BY_TWO: int = 128;
		
		protected var tableDirectory: HashMap;
		protected var rf: ByteArray;
		protected var fileName: String;
		protected var includeCmap: Boolean;
		protected var includeExtras: Boolean;
		protected var locaShortTable: Boolean;
		protected var locaTable: Vector.<int>;
		protected var glyphsUsed: HashMap;
		protected var glyphsInList: Vector.<int>;
		protected var tableGlyphOffset: int;
		protected var newLocaTable: Vector.<int>;
		protected var newLocaTableOut: Bytes;
		protected var newGlyfTable: Bytes;
		protected var glyfTableRealSize: int;
		protected var locaTableRealSize: int;
		protected var outFont: Bytes;
		protected var fontPtr: int;
		protected var directoryOffset: int;
		
		/** 
		 * Creates a new TrueTypeFontSubSet
		 */
		public function TrueTypeFontSubSet( $fileName: String, $rf: ByteArray, $glyphsUsed: HashMap, $directoryOffset: int, $includeCmap: Boolean, $includeExtras: Boolean )
		{
			fileName = $fileName;
			rf = $rf;
			glyphsUsed = $glyphsUsed;
			includeCmap = $includeCmap;
			includeExtras = $includeExtras;
			directoryOffset = $directoryOffset;
			glyphsInList = new Vector.<int>();
			
			for( var i: Iterator = $glyphsUsed.keySet().iterator(); i.hasNext(); )
				glyphsInList.push( i.next() );
		}
		
		/** Does the actual work of subsetting the font.
		 * @throws IOException on error
		 * @throws DocumentException on error
		 * @return the subset font
		 */    
		internal function process(): Bytes
		{
			try
			{
				rf.position = 0;
				createTableDirectory();
				readLoca();
				flatGlyphs();
				createNewGlyphTables();
				locaTobytes();
				assembleFont();
				return outFont;
			}
			finally {}
			return null;
		}
		
		/**
		 * 
		 * @throws EOFError
		 */
		protected function assembleFont(): void
		{
			var tableLocation: Vector.<int>;
			var fullFontSize: int = 0;
			var tableNames: Vector.<String>;
			var name: String;
			
			if (includeExtras)
				tableNames = tableNamesExtra;
			else {
				if (includeCmap)
					tableNames = tableNamesCmap;
				else
					tableNames = tableNamesSimple;
			}
			
			var tablesUsed: int = 2;
			var len: int = 0;
			var k: int;
			
			for (k = 0; k < tableNames.length; ++k) {
				name = tableNames[k];
				if (name == "glyf" || name == "loca" )
					continue;
				tableLocation = tableDirectory.getValue(name) as Vector.<int>;
				if (tableLocation == null)
					continue;
				++tablesUsed;
				fullFontSize += (tableLocation[TABLE_LENGTH] + 3) & (~3);
			}
			
			fullFontSize += newLocaTableOut.length;
			fullFontSize += newGlyfTable.length;
			var ref: int = 16 * tablesUsed + 12;
			fullFontSize += ref;
			outFont = new Bytes(fullFontSize);
			fontPtr = 0;
			writeFontInt(0x00010000);
			writeFontShort(tablesUsed);
			var selector: int = entrySelectors[tablesUsed];
			writeFontShort((1 << selector) * 16);
			writeFontShort(selector);
			writeFontShort((tablesUsed - (1 << selector)) * 16);
			for (k = 0; k < tableNames.length; ++k) {
				name = tableNames[k];
				tableLocation = tableDirectory.getValue(name) as Vector.<int>;
				if (tableLocation == null)
					continue;
				writeFontString(name);
				
				if (name == "glyf") {
					writeFontInt(calculateChecksum(newGlyfTable));
					len = glyfTableRealSize;
				}
				else if (name == "loca") {
					writeFontInt(calculateChecksum(newLocaTableOut));
					len = locaTableRealSize;
				}
				else {
					writeFontInt(tableLocation[TABLE_CHECKSUM]);
					len = tableLocation[TABLE_LENGTH];
				}
				writeFontInt(ref);
				writeFontInt(len);
				ref += (len + 3) & (~3);
			}
			for (k = 0; k < tableNames.length; ++k) {
				 name = tableNames[k];
				tableLocation = tableDirectory.getValue(name) as Vector.<int>;
				if (tableLocation == null)
					continue;
				if (name == "glyf" )
				{
					outFont.buffer.position = fontPtr;
					outFont.buffer.writeBytes( newGlyfTable.buffer, 0, newGlyfTable.length );
					outFont.buffer.position = 0;
					fontPtr += newGlyfTable.length;
					newGlyfTable = null;
				}
				else if (name == "loca" )
				{
					outFont.buffer.position = fontPtr;
					outFont.buffer.writeBytes( newLocaTableOut.buffer, 0, newLocaTableOut.length );
					outFont.buffer.position = 0;
					fontPtr += newLocaTableOut.length;
					newLocaTableOut = null;
				}
				else {
					rf.position = tableLocation[TABLE_OFFSET];
					rf.readBytes( outFont.buffer, fontPtr, tableLocation[TABLE_LENGTH] );
					fontPtr += (tableLocation[TABLE_LENGTH] + 3) & (~3);
				}
			}
		}
		
		protected function calculateChecksum( b: Bytes ): int
		{
			var len: int = b.length / 4;
			var v0: int = 0;
			var v1: int = 0;
			var v2: int = 0;
			var v3: int = 0;
			var ptr: int = 0;
			
			for( var k: int = 0; k < len; ++k )
			{
				v3 += b[ptr++] & 0xff;
				v2 += b[ptr++] & 0xff;
				v1 += b[ptr++] & 0xff;
				v0 += b[ptr++] & 0xff;
			}
			return v0 + (v1 << 8) + (v2 << 16) + (v3 << 24);
		}
		
		/**
		 * 
		 * @throws EOFError
		 */
		protected function createNewGlyphTables(): void
		{
			newLocaTable = new Vector.<int>(locaTable.length, true);
			var activeGlyphs: Vector.<int> = new Vector.<int>(glyphsInList.length, true);
			var k: int;
			for (k = 0; k < activeGlyphs.length; ++k)
				activeGlyphs[k] = glyphsInList[k];
			
			activeGlyphs.sort( defaultCompare );
			
			var glyfSize: int = 0;
			for ( k = 0; k < activeGlyphs.length; ++k) {
				var glyph: int = activeGlyphs[k];
				glyfSize += locaTable[glyph + 1] - locaTable[glyph];
			}
			
			glyfTableRealSize = glyfSize;
			glyfSize = (glyfSize + 3) & (~3);
			newGlyfTable = new Bytes( glyfSize );
			var glyfPtr: int = 0;
			var listGlyf: int = 0;
			for ( k = 0; k < newLocaTable.length; ++k) {
				newLocaTable[k] = glyfPtr;
				if (listGlyf < activeGlyphs.length && activeGlyphs[listGlyf] == k) {
					++listGlyf;
					newLocaTable[k] = glyfPtr;
					var start: int = locaTable[k];
					var len: int = locaTable[k + 1] - start;
					if (len > 0) {
						rf.position = (tableGlyphOffset + start);
						rf.readBytes( newGlyfTable.buffer, glyfPtr, len );
						glyfPtr += len;
					}
				}
			}
		}
		
		private function defaultCompare( x: int, y: int ): Number
		{
			return x - y;
		}

		protected function locaTobytes(): void
		{
			if ( locaShortTable )
				locaTableRealSize = newLocaTable.length * 2;
			else
				locaTableRealSize = newLocaTable.length * 4;
			newLocaTableOut = new Bytes( ( locaTableRealSize + 3 ) & ( ~3 ) );
			outFont = newLocaTableOut;
			fontPtr = 0;

			for ( var k: int = 0; k < newLocaTable.length; ++k )
			{
				if ( locaShortTable )
					writeFontShort( newLocaTable[ k ] / 2 );
				else
					writeFontInt( newLocaTable[ k ] );
			}
		}
		
		protected function writeFontShort( n: int ): void
		{
			outFont[fontPtr++] = (n >> 8);
			outFont[fontPtr++] = (n);
		}
		
		protected function writeFontInt( n: int ): void
		{
			outFont[fontPtr++] = (n >> 24);
			outFont[fontPtr++] = (n >> 16);
			outFont[fontPtr++] = (n >> 8);
			outFont[fontPtr++] = (n);
		}
		
		protected function writeFontString( s: String ): void
		{
			var b: Bytes = PdfEncodings.convertToBytes( s, BaseFont.WINANSI );
			outFont.buffer.position = fontPtr;
			outFont.buffer.writeBytes( b.buffer, 0, b.length );
			outFont.buffer.position = 0;
			fontPtr += b.length;
		}

		/**
		 *
		 * @throws DocumentError
		 * @throws EOFError
		 */
		protected function flatGlyphs(): void
		{
			var tableLocation: Vector.<int>;
			tableLocation = tableDirectory.getValue( "glyf" ) as Vector.<int>;

			if ( tableLocation == null )
				throw new DocumentError( "table glyf does not exist in " + fileName );
			var glyph0: int = 0;

			if ( !glyphsUsed.containsKey( glyph0 ) )
			{
				glyphsUsed.put( glyph0, null );
				glyphsInList.push( glyph0 );
			}
			tableGlyphOffset = tableLocation[ TABLE_OFFSET ];

			for ( var k: int = 0; k < glyphsInList.length; ++k )
			{
				var glyph: int = glyphsInList[ k ];
				checkGlyphComposite( glyph );
			}
		}
		
		/**
		 * 
		 * @throws EOFError
		 */
		protected function checkGlyphComposite( glyph: int): void
		{
			var start: int = locaTable[glyph];
			if (start == locaTable[glyph + 1]) // no contour
				return;
			rf.position = tableGlyphOffset + start;
			var numContours: int = rf.readShort();
			if (numContours >= 0)
				return;
			
			rf.position += 8;
			var flags: int;
			var cGlyph: int;
			var skip: int;
			
			for(;;) 
			{
				flags = rf.readUnsignedShort();
				cGlyph = rf.readUnsignedShort();
				if (!glyphsUsed.containsKey(cGlyph)) {
					glyphsUsed.put(cGlyph, null);
					glyphsInList.push(cGlyph);
				}
				if ((flags & MORE_COMPONENTS) == 0)
					return;
				
				skip = 0;
				
				if ((flags & ARG_1_AND_2_ARE_WORDS) != 0)
					skip = 4;
				else
					skip = 2;
				if ((flags & WE_HAVE_A_SCALE) != 0)
					skip += 2;
				else if ((flags & WE_HAVE_AN_X_AND_Y_SCALE) != 0)
					skip += 4;
				if ((flags & WE_HAVE_A_TWO_BY_TWO) != 0)
					skip += 8;
				rf.position += skip;
			}
		}

		/**
		 *
		 * @throws DocumentError
		 * @throws EOFError
		 */
		protected function readLoca(): void
		{
			var tableLocation: Vector.<int>;
			var k: int;
			var entries: int;

			tableLocation = tableDirectory.getValue( "head" ) as Vector.<int>;

			if ( tableLocation == null )
				throw new DocumentError( "table head does not exist in " + fileName );

			rf.position = ( tableLocation[ TABLE_OFFSET ] + HEAD_LOCA_FORMAT_OFFSET );
			locaShortTable = ( rf.readUnsignedShort() == 0 );
			tableLocation = tableDirectory.getValue( "loca" ) as Vector.<int>;

			if ( tableLocation == null )
				throw new DocumentError( "table loca does not exist in " + fileName );
			rf.position = ( tableLocation[ TABLE_OFFSET ] );

			if ( locaShortTable )
			{
				entries = tableLocation[ TABLE_LENGTH ] / 2;
				locaTable = new Vector.<int>( entries, true );

				for ( k = 0; k < entries; ++k )
					locaTable[ k ] = rf.readUnsignedShort() * 2;
			}
			else
			{
				entries = tableLocation[ TABLE_LENGTH ] / 4;
				locaTable = new Vector.<int>( entries, true );

				for ( k = 0; k < entries; ++k )
					locaTable[ k ] = rf.readInt();
			}
		}

		/**
		 * @throws DocumentError
		 * @throws EOFError
		 */
		protected function createTableDirectory(): void
		{
			tableDirectory = new HashMap();
			rf.position = directoryOffset;
			var id: int = rf.readInt();

			if ( id != 0x00010000 )
				throw new DocumentError( fileName + " is not a true type file" );
			var num_tables: int = rf.readUnsignedShort();
			rf.position += 6;

			for ( var k: int = 0; k < num_tables; ++k )
			{
				var tag: String = readStandardString( 4 );
				var tableLocation: Vector.<int> = new Vector.<int>( 3, true );
				tableLocation[ TABLE_CHECKSUM ] = rf.readInt();
				tableLocation[ TABLE_OFFSET ] = rf.readInt();
				tableLocation[ TABLE_LENGTH ] = rf.readInt();
				tableDirectory.put( tag, tableLocation );
			}
		}
		
		protected function readStandardString( length: int ): String
		{
			return rf.readMultiByte( length, "windows-1252" );
		}

	}
}