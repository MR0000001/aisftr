/**
 	* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date 18/03/2020
    * @description XC_LCC180_CreateCommercialVisit - Apex Cotroller for button to create Commercial Visit WO
 */

public without sharing class XC_LCC180_CreateCommercialVisit {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC180_CreateCommercialVisit');

    @AuraEnabled
    public static XC_UTIL_ResultWrapper manageCommercialVisit(String objectId) {
        // Retrieve data:
        XC_UTIL_ResultWrapper resWrapper = new XC_UTIL_ResultWrapper();
        String typeObject = XC_UTIL_Sobject.getObjectType(objectId);
        if(typeObject == Label.XC_CL_Lead){
            Lead ld = [SELECT Id, Status FROM Lead WHERE Id = :objectId LIMIT 1];
            if(ld.Status != Label.XC_CL_Lead_PendingScheduling){
                resWrapper.success = false;
                resWrapper.resultMessage = Label.XC_CL_CannotSkipStatus;
                return resWrapper;
            }
        }
        String selectFields = 'Id, XC_Country__c';
        if(typeObject == 'NE__Order__c'){
            selectFields = selectFields + ', NE__OptyId__c';
        }
        String query = 'SELECT '+ selectFields +' FROM ' + typeObject + ' WHERE Id = :objectId';
        
        Sobject mySobject = Database.query(String.escapeSingleQuotes(query));

        // Create WorkOrder:
        WorkOrder wo = new WorkOrder();
        Opportunity oppToUpd;
        wo.XC_WorkTypeCategory__c = Label.XC_CL_WorkType_CommercialVisit;
        wo.Status = Label.XC_CL_WorkOrder_Completed;
        wo.XC_forSATO__c = true;
        wo.XC_Country__c = String.valueOf(mySobject.get('XC_Country__c'));
        wo.XC_CreatedAutomaticallyBySystem__c = true;
        // Manage Source sObject:
        if(typeObject == Label.XC_CL_OpportunityLabel) {
            wo.XC_Opportunity__c = objectId;
            mySobject.put('XC_CommercialVisitDone__c', true);
            mySobject.put('XC_CommercialVisitStarted__c', true);
        } else if(typeObject == Label.XC_CL_Lead) {
            wo.XC_Lead__c = objectId;
            mySobject.put('Status', Label.XC_CL_Lead_AppointmentScheduling);
            mySobject.put('XC_CommercialVisitStarted__c', true);
        } else if(typeObject == 'NE__Order__c' && mySobject.get('NE__OptyId__c') != null){
            wo.XC_Opportunity__c = String.valueOf(mySobject.get('NE__OptyId__c'));
            oppToUpd = new Opportunity();
            oppToUpd.id = String.valueOf(mySobject.get('NE__OptyId__c'));
            oppToUpd.XC_CommercialVisitDone__c = true;
            oppToUpd.XC_CommercialVisitStarted__c = true;
        }

        // DML operations:
        XC_UTIL_Sobject.WrapperResult insertResult = XC_UTIL_Sobject.insertRecord(wo);
        if(!insertResult.success) {
            resWrapper.resultMessage = '[WorkOrder] ' + insertResult.errorMessage;
            return resWrapper;
        }
        if(oppToUpd == null){
            XC_UTIL_Sobject.WrapperResult updateResult = XC_UTIL_Sobject.updateRecord(mySobject);
            if(!updateResult.success) {
                resWrapper.resultMessage = '['+typeObject+'] ' + updateResult.errorMessage;
                return resWrapper;
            }
        } else {
            XC_UTIL_Sobject.WrapperResult updateResult = XC_UTIL_Sobject.updateRecord(oppToUpd);
            if(!updateResult.success) {
                resWrapper.resultMessage = '['+typeObject+'] ' + updateResult.errorMessage;
                return resWrapper;
            }
        }
        resWrapper.success = true;
        return resWrapper;
    }

}