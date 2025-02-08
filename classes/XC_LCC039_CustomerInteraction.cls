/** 
 * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com & Monica Cutillo - monica.cutillo@nttdata.com
 * @date Creation 22/11/2018
 * @date Modification dd/mm/yyyy
 * @description XC_LCC039_CustomerInteraction – Class to manage inserts for CustomerInteraction object.
 */

public without sharing class XC_LCC039_CustomerInteraction {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC039_CustomerInteraction'); 

    /**
     * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com & Monica Cutillo - monica.cutillo@nttdata.com
     * @description Check lead product category.
     * @param recordId the record id
     * @return the x C UTI L result wrapper
     */

    @AuraEnabled
    public static XC_UTIL_ResultWrapper checkLeadProductCategory(String recordId){
        XC_UTIL_ResultWrapper rw = new XC_UTIL_ResultWrapper();
        rw.success = true;
        if(XC_UTIL_CustomerInteractionGeneration.isLeadProductCategoryBlank(recordId)){
            rw.resultMessage = Label.XC_CL_CustomerInteraction_EmptyProductCategory;
            rw.success = false;
        }
        return rw; 
    }// MCutillo & LOrlanducci - 03/12/2018 - ESCEP-96 ____FINE
 
    /** 
     * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com & Monica Cutillo - monica.cutillo@nttdata.com
     * @description New email for customer.
     *
     * @param interactionValues the interaction values
     * @return the x C UTI L result wrapper   
     */
    // MCutillo & LOrlanducci - 04/01/2019 - ESCEP-96 ____INIZIO
    @AuraEnabled
    public static XC_UTIL_ResultWrapper newEmailForCustomer(String interactionValues){
        XC_UTIL_ResultWrapper rw = new XC_UTIL_ResultWrapper();
        rw.success = true;
        rw.resultMessage = Label.XC_CL_CustomerInteraction_EmailProcessed;
        XC_Customer_Interaction__c customerInteraction = new XC_Customer_Interaction__c();
        Map<String,Object> values = (Map<String,Object>) JSON.deserializeUntyped(interactionValues);

        if(values.get('serviceAppointmentId') != null){
            String serviceAppointmentId = (String)values.get('serviceAppointmentId');
            customerInteraction.XC_ServiceAppointmentId__c = serviceAppointmentId;
            if(!Schema.SObjectType.ServiceAppointment.isAccessible()) {
                return new XC_UTIL_ResultWrapper();
            }

            Map<Id,ServiceAppointment> saMap = new Map<Id,ServiceAppointment>([SELECT Id, ParentRecordId FROM ServiceAppointment where id=: serviceAppointmentId]);
            List<ServiceAppointment> sa = new List<ServiceAppointment>();
            sa = saMap.values(); 
            XC_LCC039_CustomerInteraction_U.populateCustomerInteractionWorkOrder(sa, customerInteraction);

            try{
                XC_UTIL_CustomerInteractionGeneration.populateFromServiceAppointment(customerInteraction);
                
            } catch (XC_Exception e) {
                rw.success = false;
                rw.resultMessage = e.getMessage();
                return rw;
            }
        }
        if(customerInteraction.XC_Channel__c=='SMS'){
                values.put('isSMS' , true);
        }
        if (values.get('customerType') == 'Opportunity_Product_Category_Email' && values.get('opportunityId') != null) {
            String opid = values.get('opportunityId')+'';
            Map<Id, Opportunity> opmap = new Map<Id, Opportunity>([SELECT Id, XC_LegalEntity__c, AccountId FROM Opportunity WHERE Id =:opid]);
            if (!opmap.values().isEmpty()){
                System.debug('*hello');
                String legE = opmap.values()[0].XC_LegalEntity__c;
                String acid = opmap.values()[0].AccountId;
                System.debug(acid);
                customerInteraction.XC_LegalEntity__c = legE;
                customerInteraction.XC_AccountId__c = acid;
                System.debug(customerInteraction.XC_AccountId__c);
            }
        }

        if (values.get('customerType') == 'Opportunity_QuoteCreated' && values.get('opportunityId') != null) {
            customerInteraction.XC_LegalEntity__c = (values.get('legalEntity') != null) ? (String) values.get('legalEntity') : null;
            customerInteraction.XC_AccountId__c = (values.get('accountId') != null) ? (String) values.get('accountId') : null;
            customerInteraction.XC_SkipCommunication__c =  (values.get('skipComunication') != null) ? (Boolean) values.get('skipComunication') : null;
        }

        XC_LCC039_CustomerInteraction_U.populateCustomerInteractionAccount(values, customerInteraction);
        
        // For cyclomatic complexity:
        XC_LCC039_CustomerInteraction_U.CheckValuesWrapper checkWrapper = new XC_LCC039_CustomerInteraction_U.CheckValuesWrapper();
        checkWrapper.customerInteraction = customerInteraction;
        checkWrapper.values = values;
        checkWrapper.rw = rw;
        XC_LCC039_CustomerInteraction_U.CheckValuesWrapper checkWrapperOutput = XC_LCC039_CustomerInteraction_U.checkForTypeObject(checkWrapper);
        if(checkWrapperOutput.isReturn) {
            return checkWrapperOutput.rw;
        }
        customerInteraction = checkWrapperOutput.customerInteraction;
        rw = checkWrapperOutput.rw;

        customerInteraction.XC_SkipCommunication__c = (Boolean)values.get('skipComunication');

        // For cyclomatic complexity:
        XC_LCC039_CustomerInteraction_U.CheckValuesWrapper checkWrapperForContacts = new XC_LCC039_CustomerInteraction_U.CheckValuesWrapper();
        checkWrapperForContacts.customerInteraction = customerInteraction;
        checkWrapperForContacts.values = values;
        checkWrapperForContacts.rw = rw;
        XC_LCC039_CustomerInteraction_U.checkForContacts(checkWrapperForContacts);
        if(checkWrapperForContacts.isReturn) {
            return checkWrapperForContacts.rw;
        }
        customerInteraction = checkWrapperForContacts.customerInteraction;
        rw = checkWrapperForContacts.rw;
        System.debug('Sto per inserire questa: '+customerInteraction);
        XC_UTIL_Sobject.WrapperResult utilResut = XC_UTIL_CustomerInteractionGeneration.insertCustomerInteraction(customerInteraction);
        
        if(!utilResut.success){
            rw.success = false;
            rw.resultMessage = Label.XC_CL_CustomerInteraction_NewEmailError;
            return rw;
        }

        return rw;
    }

    /**
     * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com & Monica Cutillo - monica.cutillo@nttdata.com
     * @description Check possibility to re schedule.
     *
     * @param recordId the record id
     * @return the x C UTI L result wrapper
     */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper checkPossibilityToReSchedule(String recordId){
        XC_UTIL_ResultWrapper rw = new XC_UTIL_ResultWrapper(); 
        rw.success=true;
        if(!Schema.SObjectType.ServiceAppointment.isAccessible()) {
            return new XC_UTIL_ResultWrapper();
        }
        Map<Id,ServiceAppointment> saMap = new Map<Id,ServiceAppointment>([
            SELECT id, ParentRecord.Id, Status , ContactId
            FROM ServiceAppointment where id =: recordId limit 1]);
        List<ServiceAppointment> sa = new List<ServiceAppointment>();
        sa =  saMap.values(); 
        if(sa.isEmpty() || sa[0].ParentRecord.Id==null){
            rw.success=false;
            rw.resultMessage = Label.XC_CL_ServiceAppointment_ParentNeedForReSchedule;
            return rw;
        }
        if(sa[0].Status != Label.XC_CL_ServiceAppointment_OnHold &&
           sa[0].Status != Label.XC_CL_ServiceAppointment_None &&
           sa[0].Status != Label.XC_CL_ServiceAppointment_Scheduled ){
            rw.success=false;
            rw.resultMessage = Label.XC_CL_ServiceAppointment_NotInCannotCompleteStatus;
            return rw;  
        }
        if(!Schema.SObjectType.WorkOrder.isAccessible()) {
            return new XC_UTIL_ResultWrapper();
        } 
        if(sa.isEmpty() || sa[0].ContactId == null){
            rw.success=false;
            rw.resultMessage = Label.XC_CL_ServiceAppointment_ContactNeedForReSchedule;
            return rw;
        } 
        return rw;    
    }   
    
     /**
     * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com & Monica Cutillo - monica.cutillo@nttdata.com
     * @description CheckContactEmailAndNotification
     *
     * @param opportunityId the record id
     * @param interactionValues the fields
     * @return the x C UTI L result wrapper
     */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper checkContactEmailAndNotification(String opportunityId, String interactionValues){
        XC_UTIL_ResultWrapper resWrapper = new XC_UTIL_ResultWrapper();
        List<Opportunity> oppList = new List<Opportunity>([SELECT Id,XC_Contact__c, XC_Contact__r.Email FROM Opportunity WHERE Id =: opportunityId LIMIT 1 ]);
        if(!oppList.isEmpty() && oppList[0].XC_Contact__r.Email!=null){
            return newEmailForCustomer(interactionValues);
        }else{
            resWrapper.success = false;
            resWrapper.resultMessage = Label.XC_CL_Opportunity_NoEmailOnContact;
            return resWrapper;
        }
        
    }

}