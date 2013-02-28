/*
*                             ______ _____  _______
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|
* |__|
* $Id: ImageElement.as 386 2011-01-12 14:05:20Z alessandro.crugnola@gmail.com $
* $Author Alessandro Crugnola $
* $Rev: 386 $ $LastChangedDate: 2011-01-12 15:05:20 +0100 (Wed, 12 Jan 2011) $
* $URL: https://purepdf.googlecode.com/svn/trunk/src/org/purepdf/elements/images/ImageElement.as $
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
    import org.purepdf.errors.CastTypeError;
    import org.purepdf.errors.IllegalArgumentError;
    import org.purepdf.utils.Bytes;

    /**
     * A class representing a field in a TIFF 6.0 Image File Directory.
     * A field is defined as a sequence of values of identical data type
     *
     * @see TIFFDirectory
     */
    public class TIFFField
    {
        /** Flag for null-terminated ASCII strings. */
        public static const TIFF_ASCII: int = 2;

        /** Flag for 8 bit unsigned integers. */
        public static const TIFF_BYTE: int = 1;

        /** Flag for 64 bit IEEE doubles. */
        public static const TIFF_DOUBLE: int = 12;

        /** Flag for 32 bit IEEE floats. */
        public static const TIFF_FLOAT: int = 11;

        /** Flag for 32 bit unsigned integers. */
        public static const TIFF_LONG: int = 4;

        /** Flag for pairs of 32 bit unsigned integers. */
        public static const TIFF_RATIONAL: int = 5;

        /** Flag for 8 bit signed integers. */
        public static const TIFF_SBYTE: int = 6;

        /** Flag for 16 bit unsigned integers. */
        public static const TIFF_SHORT: int = 3;

        /** Flag for 32 bit signed integers. */
        public static const TIFF_SLONG: int = 9;

        /** Flag for pairs of 32 bit signed integers. */
        public static const TIFF_SRATIONAL: int = 10;

        /** Flag for 16 bit signed integers. */
        public static const TIFF_SSHORT: int = 8;

        /** Flag for 8 bit uninterpreted bytes. */
        public static const TIFF_UNDEFINED: int = 7;

        /** The number of data items present in the field. */
        protected var count: int;

        /** The field data. */
        protected var data: Object;

        /** The tag number. */
        protected var tag: int;

        /** The tag type. */
        protected var type: int;

        /**
         * Constructs a TIFFField with arbitrary data
         *
         */
        public function TIFFField( tag: int, type: int, count: int, data: Object )
        {
            this.tag = tag;
            this.type = type;
            this.count = count;
            this.data = data;
        }

        public function compareTo( o: Object ): int
        {
            if ( o == null )
            {
                throw new IllegalArgumentError();
            }
            var oTag: int = TIFFField( o ).getTag();

            if ( tag < oTag )
            {
                return -1;
            } else if ( tag > oTag )
            {
                return 1;
            } else
            {
                return 0;
            }
        }

        public function getAsBytes(): Vector.<int>
        {
			return Bytes( data ).toVector();
        }

        public function getAsChars(): Vector.<uint>
        {
            return Vector.<uint>( data );
        }

        /**
         * Returns data in any numerical format as a float
         *
         */
        public function getAsDouble( index: int ): Number
        {
            switch ( type )
            {
                case TIFF_BYTE:
                    return Bytes( data )[index] & 0xff;
					
                case TIFF_SBYTE:
                    return Bytes( data )[index];
					
                case TIFF_SHORT:
                    return Vector.<int>( data )[index] & 0xffff;
					
                case TIFF_SSHORT:
                    return Vector.<int>( data )[index];
					
                case TIFF_SLONG:
                    return Vector.<int>( data )[index];
					
                case TIFF_LONG:
                    return Vector.<Number>( data )[index];
					
                case TIFF_FLOAT:
                    return Vector.<Number>( data )[index];
					
                case TIFF_DOUBLE:
                    return Vector.<Number>( data )[index];
					
                case TIFF_SRATIONAL:
                    var ivalue: Vector.<int> = getAsSRational( index );
                    return ivalue[0] / ivalue[1];
					
                case TIFF_RATIONAL:
                    var lvalue: Vector.<Number> = getAsRational( index );
                    return Number( lvalue[0] ) / lvalue[1];
                default:
                    throw new CastTypeError();
            }
        }
		
        public function getAsDoubles(): Vector.<Number>
        {
            return Vector.<Number>( data );
        }

        /**
         * Returns data in any numerical format as a float
         *
         */
        public function getAsFloat( index: int ): Number
        {
            switch ( type )
            {
                case TIFF_BYTE:
                    return Bytes( data )[index] & 0xff;
					
                case TIFF_SBYTE:
                    return Bytes( data )[index];
					
                case TIFF_SHORT:
                    return Vector.<int>( data )[index] & 0xffff;
					
                case TIFF_SSHORT:
                    return Vector.<int>( data )[index];
					
                case TIFF_SLONG:
                    return Vector.<int>( data )[index];
					
                case TIFF_LONG:
                    return Vector.<Number>( data )[index];
					
                case TIFF_FLOAT:
                    return Vector.<Number>( data )[index];
					
                case TIFF_DOUBLE:
                    return Vector.<Number>( data )[index];
					
                case TIFF_SRATIONAL:
                    var ivalue: Vector.<int> = getAsSRational( index );
                    return Number( Number( ivalue[0] ) / ivalue[1] );
					
                case TIFF_RATIONAL:
                    var lvalue: Vector.<Number> = getAsRational( index );
                    return Number( Number( lvalue[0] ) / lvalue[1] );
                default:
                    throw new CastTypeError();
            }
        }

        public function getAsFloats(): Vector.<Number>
        {
            return Vector.<Number>( data );
        }

        /**
         * Returns data in TIFF_BYTE, TIFF_SBYTE, TIFF_UNDEFINED, TIFF_SHORT,
         * TIFF_SSHORT, or TIFF_SLONG format as an int.
         *
         */
        public function getAsInt( index: int ): int
        {
            switch ( type )
            {
                case TIFF_BYTE:
                case TIFF_UNDEFINED:
                    return Bytes( data )[index] & 0xff;
					
                case TIFF_SBYTE:
                    return Bytes( data )[index];
					
                case TIFF_SHORT:
                    return Vector.<int>( data )[index] & 0xffff;
					
                case TIFF_SSHORT:
                    return Vector.<int>( data )[index];
					
                case TIFF_SLONG:
                    return Vector.<Number>( data )[index];
					
                default:
                    throw new CastTypeError();
            }
        }

        public function getAsInts(): Vector.<int>
        {
            return Vector.<int>( data );
        }

        /**
         * Returns data in TIFF_BYTE, TIFF_SBYTE, TIFF_UNDEFINED, TIFF_SHORT,
         * TIFF_SSHORT, TIFF_SLONG, or TIFF_LONG format as a long.
         *
         */
        public function getAsLong( index: int ): uint
        {
            switch ( type )
            {
                case TIFF_BYTE:
                case TIFF_UNDEFINED:
                    return Bytes( data )[index] & 0xff;
					
                case TIFF_SBYTE:
                    return Bytes( data )[index];
					
                case TIFF_SHORT:
                    return Vector.<int>( data )[index] & 0xffff;
					
                case TIFF_SSHORT:
                    return Vector.<int>( data )[index];
					
                case TIFF_SLONG:
                    return Vector.<int>( data )[index];
					
                case TIFF_LONG:
                    return Vector.<Number>( data )[index];
					
                default:
                    throw new CastTypeError();
            }
        }

        public function getAsLongs(): Vector.<Number>
        {
            return Vector.<Number>( data );
        }

        /**
         * Returns a TIFF_RATIONAL data item as a two-element array
         * of ints.
         */
        public function getAsRational( index: int ): Vector.<Number>
        {
            if ( type == TIFF_LONG )
                return getAsLongs();
            return Vector.<Vector.<Number>>( data )[index];
        }

        public function getAsRationals(): Vector.<Vector.<Number>>
        {
            return Vector.<Vector.<Number>>( data );
        }

        /**
         * Returns a TIFF_SRATIONAL data item as a two-element array
         * of ints.
         */
        public function getAsSRational( index: int ): Vector.<int>
        {
            return Vector.<Vector.<int>>( data )[index];
        }

        public function getAsSRationals(): Vector.<Vector.<int>>
        {
            return Vector.<Vector.<int>>( data );
        }

        public function getAsShorts(): Vector.<int>
        {
            return Vector.<int>( data );
        }

        /**
         * Returns a TIFF_ASCII data item as a String.
         */
        public function getAsString( index: int ): String
        {
            return Vector.<String>( data )[index];
        }

        /**
         * Returns the number of elements in the IFD.
         */
        public function getCount(): int
        {
            return count;
        }

        /**
         * Returns the tag number, between 0 and 65535.
         */
        public function getTag(): int
        {
            return tag;
        }

        /**
         * Returns the type of the data stored in the IFD.
         * For a TIFF6.0 file, the value will equal one of the
         * TIFF_ constants defined in this class.  For future
         * revisions of TIFF, higher values are possible.
         *
         */
        public function getType(): int
        {
            return type;
        }
    }
}