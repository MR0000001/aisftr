/*******************************************************************************************************************************
* @author            : Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
* @date Creation     : 13/02/2019
* @date Modification : dd/mm/yyyy
* @description       : XC_TR_CompVerStatus_U_ParentToKO –-- Util to chamge the Compliance 1 Status of parent OrderItem in KO
*******************************************************************************************************************************/

public without sharing  class XC_TR_CompVerStatus_U_ParentToKO {
    
    private final static Boolean DEBUGACTIVE = true; //XC_UTIL_Debug.isActive('XC_TR_CompVerStatus_U_ParentToKO');

    /**
     *  @description Check status.
     * @param listNew the list new
     * @param mapOld the map old
     * @param mapNew the map new
     */
    public static void checkStatus(List<XC_ComplianceVerificationStatus__c> listNew, Map<Id, XC_ComplianceVerificationStatus__c> mapOld, Map<Id, XC_ComplianceVerificationStatus__c> mapNew) {
        List<String> fieldList = new List<String>{'XC_ComplianceStatus__c'};
        List<XC_ComplianceVerificationStatus__c> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
        if(!listChanged.isEmpty()) {
            updateConfItemforStatusChange(listChanged);
        }
    }

    /**
     * @description Update conf itemfor status change.
     *
     * @param listChanged the list changed
     */
    private static void updateConfItemforStatusChange(List<XC_ComplianceVerificationStatus__c> listChanged) {
        List<String> compliance1or5 = new List<String>{Label.XC_CL_Compliance_C1, Label.XC_CL_Compliance_C5};
        Map<String, String> getMapConfigurationItem = XC_TR_ComplVerifStatus_U_ParentToOk_D.getMapWithJunctionObjectByCVS(listChanged);
        List<NE__OrderItem__c> orderItemListToUpdate = new List<NE__OrderItem__c>();
        for(XC_ComplianceVerificationStatus__c cvs : listChanged) {
            if(getMapConfigurationItem.containsKey(cvs.Id)){
                NE__OrderItem__c confItemToUpdate = new NE__OrderItem__c(Id = getMapConfigurationItem.get(cvs.Id));
                if(checkStatusCompliance(cvs, Label.XC_CL_Compliance_C1)) { 
                    confItemToUpdate.XC_Compliance1_Status__c = Label.XC_CL_KO;
                    orderItemListToUpdate.add(confItemToUpdate);
                } else if(checkStatusCompliance(cvs, Label.XC_CL_Compliance_C2)){
                    confItemToUpdate.XC_Compliance2_Status__c = Label.XC_CL_KO;
                    orderItemListToUpdate.add(confItemToUpdate);               
                } else if(checkStatusCompliance(cvs, Label.XC_CL_Compliance_C3)){
                    confItemToUpdate.XC_Compliance3_Status__c = Label.XC_CL_KO;
                    orderItemListToUpdate.add(confItemToUpdate);               
                } else if(checkStatusCompliance(cvs, Label.XC_CL_Compliance_C4)){
                    confItemToUpdate.XC_Compliance4_Status__c = Label.XC_CL_KO;
                    orderItemListToUpdate.add(confItemToUpdate);          
                }
            }
        }
        XC_UTIL_Sobject.updateListRecords(orderItemListToUpdate);
    }

    private static Boolean checkStatusCompliance(XC_ComplianceVerificationStatus__c cvs, String complianceType){
        return cvs.XC_ComplianceType__c == complianceType && cvs.XC_ComplianceStatus__c == Label.XC_CL_ComplianceVerificationStatus_KoFinal;
    }
}