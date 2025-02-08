/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 02/05/2019
* @date Modification 30/03/2020 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @description XC_UTIL_WBE – Util class for WBE
*/ 

public without sharing class XC_UTIL_WBE {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_UTIL_WBE'); 
    public static Integer numberDigit = 24;

    /** @description WBEWrapper */ 
    public class WBEWrapper {
        public String companyCode = '';
        public String productLine = '';
        public String digitFree = '';
        public String capOpEx = '';
        public String projectScope = '';
        public String productServiceType = '';
        public String businessModel = '';
        public String ctaCts = '';
        public String channel = '';
        public String suffixAll = '';
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com 
    * @date Creation 02/05/2019
    * @description Method to create a WBE
    * @param wrapper - WBEWrapper
    * @return String
    */
    public static String createWBE(WBEWrapper wrapper) {
        String wbe = getWBE(wrapper);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ wbe -> ' + wbe);
        if(wbe.length() > numberDigit) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ ERROR: WBE is too long!');
            return null;
        }
        return wbe;
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 02/05/2019
    * @description Method to create a WBE 
    * @param wrapper - WBEWrapper
    * @return wbe - String
    */
    public static String getWBE(XC_UTIL_WBE.WBEWrapper wrapper) {
        String wbe = wrapper.companyCode + wrapper.productLine + wrapper.digitFree + wrapper.capOpEx + wrapper.projectScope + 
                     wrapper.productServiceType + wrapper.businessModel + wrapper.ctaCts + wrapper.channel;
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ WBE created ---> ' + wbe);
        return wbe;
    }

    /** 
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com 
    * @date Creation 02/05/2019
    * @description Method for Digit FREE for WBE
    * @return String 
    */
    public static String getDigitFree() {
        return '00';
    }

    /** 
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com 
    * @date Creation 02/05/2019
    * @description Method for CTA/CTS for WBE
    * @param isFromConfItem - Boolean
    * @param isPenalty - Boolean
    * @return List<String>
    */
    public static List<String> getCtaCts(Boolean isFromConfItem, Boolean isPenalty) {
        if(isPenalty) {
            return new List<String>{'A'};
        }
        else if(isFromConfItem) {
            return new List<String>{'0'};
        } 
        else {
            return new List<String>{'0','1','2','3','4','5','6','7','8','9','A','B'};
        }        
    }

    /** 
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com 
    * @date Creation 02/05/2019
    * @description Method for  Project Scope for WBE
    * @return String
    */
    public static String getProjectScope() {
        //If null, it returns 'C'
        String projectScopte = 'C';
        return projectScopte;
    }

    /** 
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com 
    * @date Creation 02/05/2019
    * @description Method for CAPEx/OpEx for WBE
    * @return String
    */
    public static String getCAPExOpEx() {
        //If null, it returns 'Y'
        String capExOpEx = 'Y';
        return capExOpEx;
    }

}