/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 13/03/2019
* @description XC_UTIL_Debug – Util class for Debug code
*/ 

public without sharing class XC_UTIL_Debug {
    
    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 13/03/2019
    * @description Check if Class has debug in Status Active
    * @param name - String
    * @return Boolean
    */ 
    /*public static Boolean isActive(String name) {
        List<XC_CS003_ApexDebugActive__c> apexDebugs = XC_CS003_ApexDebugActive__c.getAll().values();

        for(XC_CS003_ApexDebugActive__c apexDebug : apexDebugs) {
            if(apexDebug.XC_ClassName__c.equals(name)) {
                return apexDebug.XC_LogActive__c;
            }
        }

        return false;
    }*/

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 13/03/2019
    * @description Check if Class has debug in Status Active
    * @param name - String
    * @return Boolean
    */ 
    public static Boolean isActive(String name) {
        if(name.length() <= 38) {
            XC_CS003_ApexDebugActive__c apexDebug = XC_CS003_ApexDebugActive__c.getInstance(name);
            if(apexDebug != null && apexDebug.XC_LogActive__c) {
                return true;
            }
        }
        return false;
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 13/03/2019
    * @description Print debug message without LogLevel
    * @param isActive - Boolean
    * @param message - Object
    */ 
    public static void debug(Boolean isActive, Object message) {
        if(isActive) {
            System.Debug(message);
        }
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 13/03/2019
    * @description Print debug message with LogLevel
    * @param isActive - Boolean
    * @param logLevel - System.LoggingLevel
    * @param message - Object
    */ 
    public static void debug(Boolean isActive, System.LoggingLevel logLevel, Object message) {
        if(isActive) {
            System.Debug(logLevel, message);
        }
    }
}