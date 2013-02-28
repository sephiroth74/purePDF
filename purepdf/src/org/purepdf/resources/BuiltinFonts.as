/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: BuiltinFonts.as 238 2010-01-31 10:49:33Z alessandro.crugnola $
* $Author Alessandro Crugnola $
* $Rev: 238 $ $LastChangedDate: 2010-01-31 05:49:33 -0500 (Sun, 31 Jan 2010) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/resources/BuiltinFonts.as $
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
package org.purepdf.resources
{
	/**
	 * This class contains all the pdf builtin fonts you can use for writing text.
	 * Use the FontsResourceFactory to register a new font.
	 * 
	 * @see FontsResourceFactory#registerFont()
	 */
	public final class BuiltinFonts
	{
		[Embed( source="afm/Courier.afm", mimeType="application/octet-stream" )]
		public static const COURIER: Class;
		
		[Embed( source="afm/Courier-Bold.afm", mimeType="application/octet-stream" )]
		public static const COURIER_BOLD: Class;
		
		[Embed( source="afm/Courier-BoldOblique.afm", mimeType="application/octet-stream" )]
		public static const COURIER_BOLDOBLIQUE: Class;
		
		[Embed( source="afm/Courier-Oblique.afm", mimeType="application/octet-stream" )]
		public static const COURIER_OBLIQUE: Class;
		
		[Embed( source="afm/Helvetica.afm", mimeType="application/octet-stream" )]
		public static const HELVETICA: Class;
		
		[Embed( source="afm/Helvetica-Bold.afm", mimeType="application/octet-stream" )]
		public static const HELVETICA_BOLD: Class;
		
		[Embed( source="afm/Helvetica-BoldOblique.afm", mimeType="application/octet-stream" )]
		public static const HELVETICA_BOLDOBLIQUE: Class;
		
		[Embed( source="afm/Helvetica-Oblique.afm", mimeType="application/octet-stream" )]
		public static const HELVETICA_OBLIQUE: Class;

		[Embed( source="afm/Symbol.afm", mimeType="application/octet-stream" )]
		public static const SYMBOL: Class;

		[Embed( source="afm/Times-Roman.afm", mimeType="application/octet-stream" )]
		public static const TIMES_ROMAN: Class;
		
		[Embed( source="afm/Times-Bold.afm", mimeType="application/octet-stream" )]
		public static const TIMES_BOLD: Class;
		
		[Embed( source="afm/Times-BoldItalic.afm", mimeType="application/octet-stream" )]
		public static const TIMES_BOLDITALIC: Class;
		
		[Embed( source="afm/Times-Italic.afm", mimeType="application/octet-stream" )]
		public static const TIMES_ITALIC: Class;
		
		[Embed( source="afm/ZapfDingbats.afm", mimeType="application/octet-stream" )]
		public static const ZAPFDINGBATS: Class;

	}
}