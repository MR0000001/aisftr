/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com 
* @date Creation 09/04/2019
* @date Modification dd/mm/yyyy
* @description XC_TR_ConfigurationItem_U_CheckQuantity – Util Class for check quantity of Configuration Item
*/ 

public class XC_TR_ConfigurationItem_U_CheckQuantity {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_ConfigurationItem_U_CheckQuantity');

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Method to split Configuration Item if Quantity > 1
     * @param confItem - Object NE__OrderItem__c to check
    */
    public void splitConfigurationItem(NE__OrderItem__c confItem) {
        splitListConfigurationItem(new List<NE__OrderItem__c>{confItem});
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Method to split Configuration Item if Quantity > 1
     * @param listConfItem - List of Object NE__OrderItem__c to check
    */
    public void splitListConfigurationItem(List<NE__OrderItem__c> listConfItem) {
        for(NE__OrderItem__c confItem : listConfItem) {
            if(confItem.NE__Qty__c > 1) {
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'Split quantity of Configuration Item ' + confItem.Id + ' (NE__Qty__c = ' + confItem.NE__Qty__c + ')');
                Decimal splitNumber = confItem.NE__Qty__c - 1.0;
                NE.Bit2win_Lightning_Summary_Controller.splitItem(confItem.Id, null, splitNumber);
            }
        }
    }
}