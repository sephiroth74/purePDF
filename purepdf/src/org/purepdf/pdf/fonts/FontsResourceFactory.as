/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: FontsResourceFactory.as 238 2010-01-31 10:49:33Z alessandro.crugnola $
* $Author Alessandro Crugnola $
* $Rev: 238 $ $LastChangedDate: 2010-01-31 05:49:33 -0500 (Sun, 31 Jan 2010) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/pdf/fonts/FontsResourceFactory.as $
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
	import flash.utils.Dictionary;
	import flash.utils.IDataOutput;
	
	import org.purepdf.utils.StringUtils;

	/**
	 * Use this class if you want to register more fonts to 
	 * be used with the document
	 */
	public class FontsResourceFactory
	{

		private static var instance: FontsResourceFactory;
		private var fontsMap: Dictionary;

		/**
		 * Do not use constructor to initialize this class but <code>getInstance</code>
		 * should be used
		 * 
		 * @see FontsResourceFactory#getInstance()
		 */
		public function FontsResourceFactory( lock: Lock )
		{
			if ( lock == null )
				throw new Error( "Cannot instantiate a new FontsResourceFactory. Use getInstance instead" );

			fontsMap = new Dictionary();
		}

		/**
		 * Return true if a font is already registered
		 * @param name the font name. eg. "Helvetica"
		 * @see #registerFont()
		 */
		public function fontIsRegistered( name: String ): Boolean
		{
			if ( StringUtils.endsWith( name, ".afm" ) )
				return fontsMap[name] != null;
			return fontsMap[ name + ".afm" ] != null;
		}

		public function getFontFile( filename: String ): ByteArray
		{
			if ( fontsMap[filename] )
				return fontsMap[filename];
			return null;
		}

		/**
		 * <p>You can register a new font passing the bytearray class
		 * of an embedded resource</p>
		 * <p>Example
		 * <pre>
		 * [Embed(source="assets/fonts/Helvetica-Bold.afm", mimeType="application/octet-stream")]
		 * private var helveticaB: Class;
		 * public function main()
		 * {
		 *	// this will register a custom, user defined font
		 *	FontsResourceFactory.getInstance().registerFont( BaseFont.HELVETICA_BOLD, new helveticaB() );
		 *	// register a new font, using one of the builtin fonts
		 *	FontsResourceFactory.getInstance().registerFont( BaseFont.HELVETICA, new BuiltinFonts.HELVETICA() );
		 *	var font: Font = new Font( Font.HELVETICA, 18, Font.BOLD );
		 *	document.addElement( new Paragraph("Hello world", font) );
		 * }
		 * </pre>
		 * </p>
		 * 
		 * <p>You can use the built-in fonts embedded into the separate BuiltinFonts class</p>
		 * 
		 * @param name	The font name (eg. "Helvetica")
		 * @see BuiltinFonts
		 */
		public function registerFont( name: String, file: ByteArray ): void
		{
			fontsMap[ name ] = file;
		}

		/**
		 * Return the singleton of FontsResourceFactory
		 * 
		 * @see #registerFont()
		 * @see #fontIsRegistered()
		 * @see #getFontFile()
		 */
		public static function getInstance(): FontsResourceFactory
		{
			if ( instance == null )
				instance = new FontsResourceFactory( new Lock() );
			return instance;
		}
	}
}

class Lock
{
}