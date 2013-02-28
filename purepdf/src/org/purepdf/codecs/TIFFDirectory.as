/*
*                             ______ _____  _______
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|
* |__|
* $Id: TIFFEncoder.as 251 2010-02-02 19:31:26Z alessandro.crugnola $
* $Author Alessandro Crugnola $
* $Rev: 251 $ $LastChangedDate: 2010-02-02 20:31:26 +0100 (Tue, 02 Feb 2010) $
* $URL: https://purepdf.googlecode.com/svn/trunk/src/org/purepdf/codecs/TIFFEncoder.as $
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
package org.purepdf.codecs
{
    import flash.errors.EOFError;
    
    import it.sephiroth.utils.HashMap;
    
    import org.purepdf.errors.IllegalArgumentError;
    import org.purepdf.errors.IndexOutOfBoundsError;
    import org.purepdf.io.RandomAccessFileOrArray;
    import org.purepdf.utils.Bytes;

    public class TIFFDirectory
    {
        private var isBigEndian: Boolean;
		private var IFDOffset: Number = 8;
		private var nextIFDOffset: Number = 0;
		private var numEntries: int;
		private var fields: Vector.<TIFFField>;
		private var fieldIndex: HashMap = new HashMap();
		
		private static const sizeOfType: Vector.<int> = Vector.<int>( [
			0, //  0 = n/a
			1, //  1 = byte
			1, //  2 = ascii
			2, //  3 = short
			4, //  4 = long
			8, //  5 = rational
			1, //  6 = sbyte
			1, //  7 = undefined
			2, //  8 = sshort
			4, //  9 = slong
			8, // 10 = srational
			4, // 11 = float
			8  // 12 = double
		] );
		

        /**
         * Constructs a TIFFDirectory from a stream.
         * The directory parameter specifies which directory to read from
         * the linked list present in the stream; directory 0 is normally
         * read but it is possible to store multiple images in a single
         * TIFF file by maintaining multiple directories.
         *
         * @param stream
         * @param directory the index of the directory to read.
         */
        public function TIFFDirectory( stream: RandomAccessFileOrArray, directory: int )
        {
            const global_save_offset: uint = stream.getFilePointer();
            var ifd_offset: uint;
            stream.seek( 0 );
            var endian: uint = stream.readUnsignedShort();

            if ( !isValidEndianTag( endian ) )
            {
                throw new IllegalArgumentError( "bad endianness tag" );
            }
            isBigEndian = ( endian == 0x4d4d );
            var magic: uint = this.readUnsignedShort( stream );

            if ( magic != 42 )
            {
                throw new IllegalArgumentError( "bad magic number" );
            }
            ifd_offset = this.readUnsignedInt( stream );

            for ( var i: int = 0; i < directory; i++ )
            {
                if ( ifd_offset == 0 )
                {
                    throw new IllegalArgumentError( "directory number too large" );
                }
                stream.seek( ifd_offset );
                var entries: uint = readUnsignedShort( stream );
                stream.skip( 12 * entries );
                ifd_offset = this.readUnsignedInt( stream );
            }
            stream.seek( ifd_offset );
            initialize( stream );
            stream.seek( global_save_offset );
        }
		
		/**
		 * Returns true if a tag appears in the directory
		 * 
		 */
		public function isTagPresent( tag: int ): Boolean 
		{
			return fieldIndex.containsKey( tag );
		}
		
		/**
		 * Returns the value of index 0 of a given tag as a
		 * long.  The caller is responsible for ensuring that the tag is
		 * present and has type TIFF_BYTE, TIFF_SBYTE, TIFF_UNDEFINED,
		 * TIFF_SHORT, TIFF_SSHORT, TIFF_SLONG or TIFF_LONG.
		 */
		public function getFieldAsLong( tag: int, index: int = 0 ): Number
		{
			const i: int = int( fieldIndex.getValue( tag ) );
			return fields[ i ].getAsLong( index );
		}

        /**
         * Returns the value of a given tag as a TIFFField,
         * or null if the tag is not present.
         *
         */
        public function getField( tag: int ): TIFFField
        {
			const value: Object = fieldIndex.getValue( tag );

            if( value == null || isNaN( int( value ) ) )
            {
                return null;
            } else
            {
	            const i: int = value as int;
                return fields[i];
            }
        }

        private function initialize( stream: RandomAccessFileOrArray ): void
        {
            var nextTagOffset: uint = 0;
            var maxOffset: uint = stream.length;
            var i: int;
            var j: int;
            IFDOffset = stream.getFilePointer();
            numEntries = readUnsignedShort( stream );
            fields = new Vector.<TIFFField>( numEntries, true );

            for ( i = 0; ( i < numEntries ) && ( nextTagOffset < maxOffset ); i++ )
            {
                var tag: uint = readUnsignedShort( stream );
                var type: uint = readUnsignedShort( stream );
                var count: uint = readUnsignedInt( stream );
                var processTag: Boolean = true;
                nextTagOffset = stream.getFilePointer() + 4;

                try
                {
                    if ( count * sizeOfType[type] > 4 )
                    {
                        var valueOffset: uint = readUnsignedInt( stream );

                        if ( valueOffset < maxOffset )
                        {
                            stream.seek( valueOffset );
                        } else
                        {
                            processTag = false;
                        }
                    }
                } catch ( ae: IndexOutOfBoundsError )
                {
                    processTag = false;
                }

                if ( processTag )
                {
                    fieldIndex.put( tag, i );
                    var obj: Object = null;

                    switch ( type )
                    {
                        case TIFFField.TIFF_BYTE:
                        case TIFFField.TIFF_SBYTE:
                        case TIFFField.TIFF_UNDEFINED:
                        case TIFFField.TIFF_ASCII:
                            var bvalues: Bytes = new Bytes( count );
                            stream.readFully( bvalues, 0, count );
                            if ( type == TIFFField.TIFF_ASCII )
                            {
                                var index: int = 0;
                                var prevIndex: int = 0;
                                var v: Array = new Array();
                                trace( "bvalues" + bvalues.toVector() );

                                while ( index < count )
                                {
                                    while ( ( index < count ) && ( bvalues[index++] != 0 ) )
                                    {
                                    }
                                    trace( "prevIndex=" + prevIndex + ", len=" + ( index - prevIndex ) );
                                    v.push( bvalues.readAsString( prevIndex, ( index - prevIndex ) ) );
                                    prevIndex = index;
                                }
                                count = v.length;
                                var strings: Vector.<String> = new Vector.<String>( count, true );

                                for ( var c: int = 0; c < count; c++ )
                                {
                                    strings[c] = String( v[c] );
                                }
                                obj = strings;
                            } else
                            {
                                obj = bvalues;
                            }
                            break;
                        case TIFFField.TIFF_SHORT:
                            var cvalues: Vector.<int> = new Vector.<int>( count, true );
                            for ( j = 0; j < count; j++ )
                            {
                                cvalues[j] = TIFFDirectory.readUnsignedShort( stream, isBigEndian );
                            }
                            obj = cvalues;
                            break;
                        case TIFFField.TIFF_LONG:
                            var lvalues: Vector.<Number> = new Vector.<Number>( count, true );
                            for ( j = 0; j < count; j++ )
                            {
                                lvalues[j] = TIFFDirectory.readUnsignedInt( stream, isBigEndian );
                            }
                            obj = lvalues;
                            break;
                        case TIFFField.TIFF_RATIONAL:
                            var llvalues: Vector.<Vector.<Number>> = new Vector.<Vector.<Number>>( count, true );
                            for ( j = 0; j < count; j++ )
                            {
                                llvalues[j] = new Vector.<Number>( 2, true );
                                llvalues[j][0] = readUnsignedInt( stream );
                                llvalues[j][1] = readUnsignedInt( stream );
                            }
                            obj = llvalues;
                            break;
                        case TIFFField.TIFF_SSHORT:
                            var svalues: Vector.<int> = new Vector.<int>( count, true );
                            for ( j = 0; j < count; j++ )
                            {
                                svalues[j] = readShort( stream );
                            }
                            obj = svalues;
                            break;
                        case TIFFField.TIFF_SLONG:
                            var ivalues: Vector.<int> = new Vector.<int>( count, true );
                            for ( j = 0; j < count; j++ )
                            {
                                ivalues[j] = readInt( stream );
                            }
                            obj = ivalues;
                            break;
                        case TIFFField.TIFF_SRATIONAL:
                            var iivalues: Vector.<Vector.<int>> = new Vector.<Vector.<int>>( count, true );
                            for ( j = 0; j < count; j++ )
                            {
                                iivalues[j] = new Vector.<int>( 2, true );
                                iivalues[j][0] = readInt( stream );
                                iivalues[j][1] = readInt( stream );
                            }
                            obj = iivalues;
                            break;
                        case TIFFField.TIFF_FLOAT:
                            var fvalues: Vector.<Number> = new Vector.<Number>( count, true );
                            for ( j = 0; j < count; j++ )
                            {
                                fvalues[j] = readFloat( stream );
                            }
                            obj = fvalues;
                            break;
                        case TIFFField.TIFF_DOUBLE:
                            var dvalues: Vector.<Number> = new Vector.<Number>( count, true );
                            for ( j = 0; j < count; j++ )
                            {
                                dvalues[j] = readDouble( stream );
                            }
                            obj = dvalues;
                            break;
                        default:
                            break;
                    }
                    fields[i] = new TIFFField( tag, type, count, obj );
                }
                stream.seek( nextTagOffset );
            }

            // Read the offset of the next IFD.
            try
            {
                nextIFDOffset = this.readUnsignedInt( stream );
            } catch ( e: Error )
            {
                // broken tiffs may not have this pointer
                nextIFDOffset = 0;
            }
        }

        /**
         * Returns the number of image directories (subimages) stored in a
         * given TIFF file, represented by a <code>SeekableStream</code>.
         *
         * @since 78.0
         * @throws IOException
         */
        public static function getNumDirectories( stream: RandomAccessFileOrArray ): int
        {
            const pointer: uint = stream.getFilePointer();
            stream.seek( 0 );
            const endian: int = stream.readUnsignedShort();

            if ( !isValidEndianTag( endian ) )
            {
                throw new IllegalArgumentError( "bad endianness tag" );
            }
            const isBigEndian: Boolean = ( endian == 0x4d4d );
            const magic: int = readUnsignedShort( stream, isBigEndian );

            if ( magic != 42 )
            {
                throw new IllegalArgumentError( "bad magic number. should be 42" );
            }
            stream.seek( 4 );
            var offset: uint = readUnsignedInt( stream, isBigEndian );
            var numDirectories: int = 0;

            while ( offset != 0 )
            {
                ++numDirectories;

                try
                {
                    stream.seek( offset );
                    var entries: int = readUnsignedShort( stream, isBigEndian );
                    stream.skip( 12 * entries );
                    offset = readUnsignedInt( stream, isBigEndian );
                } catch ( eof: EOFError )
                {
                    //numDirectories--;
                    break;
                }
            }
            stream.seek( pointer ); // Reset stream pointer
            return numDirectories;
        }

        private static function isValidEndianTag( endian: int ): Boolean
        {
            return ( ( endian == 0x4949 ) || ( endian == 0x4d4d ) );
        }
		
		private function readFloat( stream : RandomAccessFileOrArray ): Number
		{
			if( isBigEndian )
				return stream.readFloat();
			else
				return stream.readFloatLE();
		}
		
		private function readShort( stream: RandomAccessFileOrArray ): int
		{
			if( isBigEndian )
				return stream.readShort();
			else
				return stream.readShortLE();
		}
		
		private function readInt( stream: RandomAccessFileOrArray ): int
		{
			if( isBigEndian )
				return stream.readInt();
			else
				return  stream.readIntLE();
		}
		
		private function readDouble( stream: RandomAccessFileOrArray ): Number
		{
			if( isBigEndian )
				return stream.readDouble();
			else
				return stream.readDoubleLE();
		}
		
		private function readUnsignedInt( stream: RandomAccessFileOrArray ): uint
		{
			return TIFFDirectory.readUnsignedInt( stream, isBigEndian );
		}

        private static function readUnsignedInt( stream: RandomAccessFileOrArray, isBigEndian: Boolean ): uint
        {
            if ( isBigEndian )
            {
                return stream.readUnsignedInt();
            } else
            {
                return stream.readUnsignedIntLE();
            }
        }
		
		private function readUnsignedShort( stream: RandomAccessFileOrArray ): int
		{
			return TIFFDirectory.readUnsignedShort( stream, isBigEndian );
		}

        private static function readUnsignedShort( stream: RandomAccessFileOrArray, isBigEndian: Boolean ): int
        {
            if ( isBigEndian )
            {
                return stream.readUnsignedShort();
            } else
            {
                return stream.readUnsignedShortLE();
            }
        }
    }
}