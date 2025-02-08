/**
 * The Class XC_TR_Case_U_AutomaticDeactivation.
 *
 * @author            : Nicola Mariniello nmariniello@delotte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation     : 01/07/2020
 * @date Modification : dd/mm/yyyy
 * @description       : Class to create order and start Provisioning
 **/ 
 

public without sharing class XC_TR_Case_U_AutomaticDeactivation {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_Case_U_AutomaticDeactivation');
 
    /**
     * onAfterInsert.
     * @param listNew the list new
     * @description create order
     */
    public static void onAfterInsert(List<Case> listNew) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'IN XC_TR_Case_U_AutomaticDeactivation.onAfterInsert');

        List<Case> casesToProcess = new List<Case>();
        Set<String> legalEntitySet = new Set<String>();
        Set<String> streamSet = new Set<String>();
        for(Case c : listNew) {
            if(c.XC_EnergyContractedPower__c != null && c.XC_EnergyVasContractNumberOfDays__c != null && (c.XC_LegalEntity__c == Label.XC_CL_EndesaX || c.XC_LegalEntity__c == Label.XC_CL_LegalEntity_EnelXMobilitySpain) &&
                c.XC_Segment__c == 'B2C' && String.isNotBlank(c.AssetId) && String.isBlank(c.XC_AutomaticDeactivationError__c)) {
                    casesToProcess.add(c);
                    legalEntitySet.add(c.XC_LegalEntity__c);
                    streamSet.add(c.XC_Segment__c);
            }
        }
        if(casesToProcess.isEmpty()) {
            return;
        }

        Map<Id, XC_CM_LegalEntity_Configuration__mdt> legalEntityInfoMap = new Map<Id, XC_CM_LegalEntity_Configuration__mdt>([SELECT Id, XC_MaxEnergyContractedPower__c, XC_MaxEnergyVasContractNumberOfDays__c, XC_LegalEntity__c, XC_Stream__c
                                                                                                                                FROM XC_CM_LegalEntity_Configuration__mdt
                                                                                                                                WHERE XC_LegalEntity__c IN: legalEntitySet
                                                                                                                                    AND XC_Stream__c IN: streamSet AND XC_OrgId__c =: UserInfo.getOrganizationId()]);
        Map<String, XC_CM_LegalEntity_Configuration__mdt> infosMap = new Map<String, XC_CM_LegalEntity_Configuration__mdt>();
        for(XC_CM_LegalEntity_Configuration__mdt cm : legalEntityInfoMap.values()) {
            infosMap.put(cm.XC_LegalEntity__c+cm.XC_Stream__c, cm);
        }
        
        List<Case> casesToUpdate = new List<Case>();
        for(Case c : casesToProcess) {
            XC_CM_LegalEntity_Configuration__mdt info = infosMap.get(c.XC_LegalEntity__c+c.XC_Segment__c);
            if(info != null && info.XC_MaxEnergyContractedPower__c != null && c.XC_EnergyContractedPower__c < info.XC_MaxEnergyContractedPower__c && 
                info.XC_MaxEnergyVasContractNumberOfDays__c != null && c.XC_EnergyVasContractNumberOfDays__c < info.XC_MaxEnergyVasContractNumberOfDays__c) {
                    createOrderAndStartProvisioning(JSON.serialize(c));
            } else {
                casesToUpdate.add(new Case(Id = c.Id, XC_AutomaticDeactivationError__c = 'Conditions for EnergyContractedPower and EnergyVasContractNumberOfDays not valid'));
            }
        }

        if(!casesToUpdate.isEmpty()) {
            XC_UTIL_SObject.updateListRecords(casesToUpdate);
        }
    }


    /**
     * createOrderAndStartProvisioning.
     * @param caseString the caseString 
     * @description create order and sart provisioning
     */
    @future
    public static void createOrderAndStartProvisioning(String caseString) {

        Case caseToProcess = (Case) JSON.deserialize(caseString, Case.class);

        Map<Id, XC_OrderSubtypeByCase__mdt> cmDataMap = new Map<Id,XC_OrderSubtypeByCase__mdt>([SELECT XC_Type__c, OrderSubtype__c, XC_Subtype__c, XC_SkipOrderCreation__c
                                                                                                FROM XC_OrderSubtypeByCase__mdt 
                                                                                                WHERE Reason__c =: caseToProcess.Reason
                                                                                                    AND SubCause__c =: caseToProcess.SubCause__c 
                                                                                                    AND XC_Type__c = 'Disconnect'   // Add on 18.11.2020 because there are different records with different type
                                                                                                ]);
        XC_OrderSubtypeByCase__mdt cmData = new XC_OrderSubtypeByCase__mdt();
        for(XC_OrderSubtypeByCase__mdt mdt : cmDataMap.values()) {
            if(String.isBlank(mdt.XC_Subtype__c)) {
                cmData = mdt;
            }else if(mdt.XC_Subtype__c == caseToProcess.XC_Subtype__c) {
                cmData = mdt;
                break;
            }
        }
        
        XC_UTIL_ResultWrapper resWr;
        if(cmData.XC_Type__c == 'Disconnect') {
            resWr = XC_LCC073_DisconnectAsset.disconnectAssetFromCase(caseToProcess.Id, cmData.OrderSubtype__c, cmData.XC_SkipOrderCreation__c);
        } else {
            //resWr = XC_LCC073_DisconnectAsset.changeOrderAssetFromCase(caseToProcess.Id, cmData.OrderSubtype__c, cmData.XC_SkipOrderCreation__c);
            return;
        }

        System.debug(LoggingLevel.FINEST, 'resWr: ' + resWr);
        if(resWr.success && String.isNotBlank(resWr.recordId)) {
            XC_LCC048_OrderInProvisioning.insertProvisioningSteps(resWr.recordId, 'XC_TR_Case_U_AutomaticDeactivation');
            System.enqueueJob(new XC_UTIL_NextStepOrderToProvisioning.ThirdNextStepQueue(resWr.recordId));
        } else {
            Case caseToUpdate = new Case();
            caseToUpdate.Id = caseToProcess.Id;
            caseToUpdate.XC_AutomaticDeactivationError__c = resWr.resultMessage;
            XC_UTIL_SObject.updateRecord(caseToUpdate);
        }
    }

}