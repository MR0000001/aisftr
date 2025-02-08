/**
* @author Simone Trenta strenta@deloitte.it Luca Tedeschi - ltedeschi@deloitte.it
* @date Creation 11/01/2019
* @description XC_TR_ComplVerifStatus_U_ParentToOk_D DAO for the
*/
public without sharing class XC_TR_ComplVerifStatus_U_ParentToOk_D {
    
    private final static Boolean DEBUGACTIVE = true; //XC_UTIL_Debug.isActive('XC_TR_CompVerStatus_U_ParentToKO');
   
    /**
    * @description 
    * @param listOfOrderId 
    * @return List<XC_OrderItemCompliance__c> 
    **/
    public static List<XC_OrderItemCompliance__c> getComplianceVerificationStatus(List<String> listOfOrderId) {         
        List<XC_OrderItemCompliance__c> ordItemList = new List<XC_OrderItemCompliance__c>([SELECT Id, XC_OrderItem__c, XC_ComplianceVerificationStatus__r.Id, 
            XC_ComplianceVerificationStatus__r.XC_ComplianceStatus__c, 
            XC_ComplianceVerificationStatus__r.XC_ComplianceType__c
                FROM XC_OrderItemCompliance__c 
                WHERE XC_ComplianceVerificationStatus__r.XC_Order__c IN :listOfOrderId]);
        return ordItemList;
    }


    /**
     * Gets the map with junction object by CVS.
     *
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @param listCVS the list CVS
     * @return the map with junction object by CVS
     * @date Creation 03/04/2019
     * @description getMapWithJunctionObjectByCVS() - Get Map with key=idCVS and value=idParentConfItem from Junction Object
    */
    public static Map<String, String> getMapWithJunctionObjectByCVS(List<XC_ComplianceVerificationStatus__c> listCVS) {
        List<String> listIdCVS = new List<String>();
        for(XC_ComplianceVerificationStatus__c cvs : listCVS) {
            listIdCVS.add(cvs.Id);
        }
        Map<Id,XC_OrderItemCompliance__c> listJunctionObjectMap = new Map<Id,XC_OrderItemCompliance__c>([SELECT XC_OrderItem__c, XC_ComplianceVerificationStatus__c 
            FROM XC_OrderItemCompliance__c WHERE XC_ComplianceVerificationStatus__c IN :listIdCVS]);
        List<XC_OrderItemCompliance__c> listJunctionObject = listJunctionObjectMap.values();

        Map<String, String> mapCVSjunctionObject = new Map<String, String>();
        for(XC_OrderItemCompliance__c junctionObject : listJunctionObject) {
            mapCVSjunctionObject.put(junctionObject.XC_ComplianceVerificationStatus__c, junctionObject.XC_OrderItem__c);
        }

        return mapCVSjunctionObject;
    }



    public static Map<String, List<Id>> getMapWithJunctionObjectByCVSWithAllOrderItem(List<XC_ComplianceVerificationStatus__c> listCVS) {
        List<String> listIdCVS = new List<String>();
        for(XC_ComplianceVerificationStatus__c cvs : listCVS) {
            listIdCVS.add(cvs.Id);
        }
        Map<Id,XC_OrderItemCompliance__c> listJunctionObjectMap = new Map<Id,XC_OrderItemCompliance__c>([SELECT XC_OrderItem__c, XC_ComplianceVerificationStatus__c 
            FROM XC_OrderItemCompliance__c WHERE XC_ComplianceVerificationStatus__c IN :listIdCVS]);
        List<XC_OrderItemCompliance__c> listJunctionObject = listJunctionObjectMap.values();

        Map<String, List<String>> mapCVSjunctionObject = new Map<String, List<Id>>();
        for(XC_OrderItemCompliance__c junctionObject : listJunctionObject) {
            if(!mapCVSjunctionObject.containsKey(junctionObject.XC_ComplianceVerificationStatus__c)){
                mapCVSjunctionObject.put(junctionObject.XC_ComplianceVerificationStatus__c, new List<Id>());
            }
            mapCVSjunctionObject.get(junctionObject.XC_ComplianceVerificationStatus__c).add(junctionObject.XC_OrderItem__c);
        }
        return mapCVSjunctionObject;
    }
    
    /**
     * @description Gets the configuration item by id.
     * @param ids the ids
     * @return the configuration item by id
     */
    public static List<NE__OrderItem__c> getConfigurationItemById(Set<Id> ids){

        Map<Id,NE__OrderItem__c> ordItmMap = new Map<Id,NE__OrderItem__c>([SELECT Id, XC_Compliance1_Status__c FROM NE__OrderItem__c WHERE Id IN: ids]);
        List<NE__OrderItem__c> ordItm = ordItmMap.values();

        return ordItm;
    }
}