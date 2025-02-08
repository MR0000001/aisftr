/**
 * @author Federico Amici - federico.amici@nttdata.com
 * @date Creation 15/04/2019
 * @date Modification dd/mm/yyyy
 * @description XC_UTIL_String – Util class for String methods
 */

public without sharing class XC_UTIL_String {

	/** 
  * @author Federico Amici - federico.amici@nttdata.com
  * @date 15/04/2019
  * @date Modification dd/mm/yyyy
  * @description stringsAreEqual
  * @return Boolean
  * @param s1
  * @param s2
  */
	public static Boolean stringsAreEqual(String s1, String s2) {

		if (String.isBlank(s1) && String.isBlank(s2)) {
			return true;
		} else if (String.isNotBlank(s1) && String.isNotBlank(s2)) {
			if (s1.equals(s2)) {
				return true;
			}
		}

		return false;
	}


    /**
    *@author Francesco Imperioli - fimperioli@deloitte.it
    *@description: remove accents from string
    *@createdDate 2020-03-11
    */
	public static String removeDiacritics(String str) {
		if (str == null) {
			return null;
		}
		List < Integer > result = new List < Integer > ();
		for (Integer chr: str.getChars()) {
			if (XC_UTIL_String_U.DIACRITIC_MAP.containsKey(chr)) {
				result.addAll(XC_UTIL_String_U.DIACRITIC_MAP.get(chr));
			} else {
				result.add(chr);
			}
		}
		return String.fromCharArray(result);
	}
    
    
    /**
    *@author Damiano Palamides - dpalamides@deloitte.it
    *@description: remove characters not valid to SEPA charset
    *@createdDate 2021-02-25
    */
	public static String removeDiacriticsSIA(String str) {
		if (str == null) {
			return null;
		}
		List < Integer > result = new List < Integer > ();
		for (Integer chr: str.getChars()) {
			if (XC_UTIL_String_U.DIACRITIC_MAP.containsKey(chr)) {
				result.addAll(XC_UTIL_String_U.DIACRITIC_MAP.get(chr));
			} else {
				result.add(chr);
			}
		}
        List < Integer > result2 = new List < Integer > ();
        String str2 = String.fromCharArray(result);
        System.debug(XC_UTIL_String_U.NO_SEPA_MAP);
		for (Integer chr: str2.getChars()) {
            String x = String.valueOf(XC_UTIL_String_U.NO_SEPA_MAP.get(chr));
			if (XC_UTIL_String_U.NO_SEPA_MAP.containsKey(chr)) {
				result2.addAll(XC_UTIL_String_U.NO_SEPA_MAP.get(chr));
			} else {
				result2.add(chr);
			}
		}
		return String.fromCharArray(result2);
	}

}