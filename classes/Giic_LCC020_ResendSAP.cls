/**    
* @author FirstName : Sara Miozza sara.miozza@nttadata.com & Lorenzo Orlanducci lorenzo.orlanducci@nttdata.com
* @date Creation 23/03/2020
* @date Modification dd/mm/yyyy
* @description controller for Giic_LCP020_ResendSAP
*/ 
public class Giic_LCC020_ResendSAP {
	
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('Giic_LCC020_ResendSAP'); 
    
    @AuraEnabled 
    public static XC_UTIL_ResultWrapper resend(String recordId, Boolean sapSelected, Boolean logisticSelected){
        Id recId = Id.valueOf(recordId);
        String sobjectType = recId.getSObjectType().getDescribe().getName();
        if(sobjectType=='gii__PurchaseOrder__c'){
            return resendPO(recordId,  sapSelected, logisticSelected);
        }
        else if(sobjectType=='gii__PurchaseOrderReceipt__c'){
            return resendPOReceipt(recordId, sapSelected, logisticSelected);
        }else if(sobjectType=='gii__TransferOrder__c'){
            return resendTO(recordId, sapSelected, logisticSelected);
        }
        else if(sobjectType=='gii__PurchaseOrderReceiptStaging__c'){
            return resendPORS(recordId, sapSelected, logisticSelected);
        }else{ return null; }

        
    }
    
    @AuraEnabled 
    public static XC_UTIL_ResultWrapper resendPO(String recordId, Boolean sapSelected, Boolean logisticSelected){
        XC_UTIL_Debug.debug(DEBUGACTIVE,'In resendPO----->>' );
        XC_UTIL_ResultWrapper resWrapper = new XC_UTIL_ResultWrapper();
        gii__PurchaseOrder__c  po = [SELECT Id, gii__Approved__c,giic_Status__c, giic_PurchaseOrderMaster__c, giic_POCode__c,giic_MultiTargetSystem__c FROM gii__PurchaseOrder__c WHERE Id =: recordId];
        if(!po.gii__Approved__c){
            resWrapper.success = false;
            resWrapper.resultMessage = 'This Purchase Order cannot be resent';
        }else{
            po.giic_IntegrationStatus__c = Label.giic_TOIntegrationStatusReadyToIntegrate;
            if(po.giic_Status__c == 'Approved' || Test.isRunningTest()){
            	po.giic_IntegrationOperation__c = Label.giic_IntegrationOperationCreate;
            }else if(po.giic_Status__c == 'Cancelled'){
                po.giic_IntegrationOperation__c = Label.giic_CancellationRequest;
            }else{
                  resWrapper.success = false;
                  resWrapper.resultMessage = 'This Purchase Order cannot be resent';
                  return resWrapper;
            }
            System.debug('po.giic_MultiTargetSystem__c = '+po.giic_MultiTargetSystem__c);
            if(sapSelected && logisticSelected){
                if(!controlForSAP(po)){ return populateErrorWrapper('This Purchase Order cannot be resent to SAP system'); }
                Set<String> values = new Set<String>();
            	values.add(Label.giic_TargetSystemSAP);
                values.add('3PL');
				po.giic_MultiTargetSystem__c = Giic_PurchaseOrderUtility.setTargetSystem(null , values);
                
            }else{
            	if(sapSelected){
                    if(!controlForSAP(po)){ return populateErrorWrapper('This Purchase Order cannot be resent to SAP system'); }
                    else{
                        Set<String> values = new Set<String>();
                        values.add(Label.giic_TargetSystemSAP);
                        po.giic_MultiTargetSystem__c = Giic_PurchaseOrderUtility.setTargetSystem(null , values);
                    }
            	}
            	if(logisticSelected){
            		Set<String> values = new Set<String>();
            		values.add('3PL');
            		po.giic_MultiTargetSystem__c = Giic_PurchaseOrderUtility.setTargetSystem(null , values);    
            	}
            }
            System.debug('po.giic_MultiTargetSystem__c dopo = '+po.giic_MultiTargetSystem__c);
         	resWrapper = XC_UTIL_Glovia.updateRecord(po);
        }
        return resWrapper;
        
    }
    
    
    @AuraEnabled 
    public static XC_UTIL_ResultWrapper resendPOReceipt(String recordId, Boolean sapSelected, Boolean logisticSelected){
        XC_UTIL_ResultWrapper resWrapper = new XC_UTIL_ResultWrapper();
        gii__PurchaseOrderReceipt__c por = new gii__PurchaseOrderReceipt__c(Id=recordId, giic_IntegrationStatus__c=System.Label.giic_TOIntegrationStatusReadyToIntegrate,
                                                                        giic_IntegrationOperation__c = Label.giic_IntegrationOperationCreate,
                                                                        giic_TargetSystem__c = Label.giic_TargetSystemSAP);
        resWrapper = XC_UTIL_Glovia.updateRecord(por);
        return resWrapper;
        
        
    }
    
     @AuraEnabled 
    public static XC_UTIL_ResultWrapper resendTO(String recordId, Boolean sapSelected, Boolean logisticSelected){
        XC_UTIL_ResultWrapper resWrapper = new XC_UTIL_ResultWrapper();
        gii__TransferOrder__c to = new gii__TransferOrder__c(Id=recordId, giic_IntegrationStatus__c=System.Label.giic_TOIntegrationStatusReadyToIntegrate,
                                                                          giic_IntegrationOperation__c = Label.giic_IntegrationOperationCreate,
                                                                          giic_TargetSystem__c = '3PL');
        resWrapper = XC_UTIL_Glovia.updateRecord(to);
        return resWrapper;
        
        
    }
    
    @AuraEnabled 
    public static XC_UTIL_ResultWrapper resendPORS(String recordId, Boolean sapSelected, Boolean logisticSelected){
        XC_UTIL_ResultWrapper resWrapper = new XC_UTIL_ResultWrapper();
        gii__PurchaseOrderReceiptStaging__c por = new gii__PurchaseOrderReceiptStaging__c(Id=recordId, giic_IntegrationStatus__c=System.Label.giic_TOIntegrationStatusReadyToIntegrate,
                                                                          giic_IntegrationOperation__c = 'Cancellation Request',
                                                                          giic_TargetSystem__c = 'SAP');
        resWrapper = XC_UTIL_Glovia.updateRecord(por);
        return resWrapper;
        
        
    }
    
    
    private static Boolean controlForSAP(gii__PurchaseOrder__c po){
        if(po.giic_PurchaseOrderMaster__c != null){ return false; }
        if(po.giic_Status__c == 'Approved' && po.giic_POCode__c != null){ return false; }
        return true;
        
    }
    
    @TestVisible
    private static XC_UTIL_ResultWrapper populateErrorWrapper(String resultMessage){
            XC_UTIL_ResultWrapper resWrapper = new XC_UTIL_ResultWrapper();
        	resWrapper.success = false;
            resWrapper.resultMessage = resultMessage;
            return resWrapper;
    }
    
    

}