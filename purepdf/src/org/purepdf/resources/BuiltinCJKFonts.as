/*
*                             ______ _____  _______ 
* .-----..--.--..----..-----.|   __ \     \|    ___|
* |  _  ||  |  ||   _||  -__||    __/  --  |    ___|
* |   __||_____||__|  |_____||___|  |_____/|___|    
* |__|
* $Id: BuiltinCJKFonts.as 238 2010-01-31 10:49:33Z alessandro.crugnola $
* $Author Alessandro Crugnola $
* $Rev: 238 $ $LastChangedDate: 2010-01-31 05:49:33 -0500 (Sun, 31 Jan 2010) $
* $URL: http://purepdf.googlecode.com/svn/trunk/src/org/purepdf/resources/BuiltinCJKFonts.as $
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
	public class BuiltinCJKFonts
	{
			[Embed(source="properties/STSong-Light.properties", mimeType="application/octet-stream")]  
			public static var STSong_Light: Class;
			
			[Embed(source="properties/STSongStd-Light.properties", mimeType="application/octet-stream")]  
			public static var STSongStd_Light: Class;
			
			[Embed(source="properties/HeiseiKakuGo-W5.properties", mimeType="application/octet-stream")]  
			public static var HeiseiKakuGo_W5: Class;
			[Embed(source="properties/HeiseiMin-W3.properties", mimeType="application/octet-stream")]  
			public static var HeiseiMin_W3: Class;
			
			[Embed(source="properties/HYGoThic-Medium.properties", mimeType="application/octet-stream")]  
			public static var HYGoThic_Medium: Class;
			
			[Embed(source="properties/HYSMyeongJo-Medium.properties", mimeType="application/octet-stream")]  
			public static var HYSMyeongJo_Medium: Class;
			
			[Embed(source="properties/HYSMyeongJoStd-Medium.properties", mimeType="application/octet-stream")]  
			public static var HYSMyeongJoStd_Medium: Class;
			
			[Embed(source="properties/KozMinPro-Regular.properties", mimeType="application/octet-stream")]  
			public static var KozMinPro_Regular: Class;
			
			[Embed(source="properties/MHei-Medium.properties", mimeType="application/octet-stream")]  
			public static var MHei_Medium: Class;
			
			[Embed(source="properties/MSung-Light.properties", mimeType="application/octet-stream")]  
			public static var MSung_Light: Class;
			
			[Embed(source="properties/MSungStd-Light.properties", mimeType="application/octet-stream")]  
			public static var MSungStd_Light: Class;
			
			public static function getFontName( cls: Class ): String
			{
				if( cls == STSong_Light ) 		return "STSong-Light";
				if( cls == STSongStd_Light ) 	return "STSongStd-Light";
				if( cls == HeiseiKakuGo_W5 ) 	return "HeiseiKakuGo-W5";
				if( cls == HeiseiMin_W3 ) 		return "HeiseiMin-W3";
				if( cls == HYGoThic_Medium ) 	return "HYGoThic-Medium";
				if( cls == HYSMyeongJo_Medium ) return "HYSMyeongJo-Medium";
				if( cls == HYSMyeongJoStd_Medium ) return "HYSMyeongJoStd-Medium";
				if( cls == KozMinPro_Regular ) 	return "KozMinPro-Regular";
				if( cls == MHei_Medium ) 		return "MHei-Medium";
				if( cls == MSung_Light ) 		return "MSung-Light";
				if( cls == MSungStd_Light ) 	return "MSungStd-Light";
				return null;
			}
	}
}