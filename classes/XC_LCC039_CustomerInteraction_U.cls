/** 
 * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
 * @date Creation 06/05/2019
 * @description XC_LCC039_CustomerInteraction_U – Util class for XC_LCC039_CustomerInteraction
 */

public without sharing class XC_LCC039_CustomerInteraction_U {

    @TestVisible private static Boolean throwExceptionInTest = false;
    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC039_CustomerInteraction');

    /** @description CheckValuesWrapper */
    public class CheckValuesWrapper {
        public XC_Customer_Interaction__c customerInteraction;
        public Map<String,Object> values = new Map<String,Object>();
        public XC_UTIL_ResultWrapper rw;
        public Boolean isReturn = false;
    }

    /**
     * @description Method to check for Contacts
     * @param checkWrapper - CheckValuesWrapper
     */
    public static void checkForContacts(CheckValuesWrapper checkWrapper) {
        
        Boolean isSMS = checkIsSMS(checkWrapper.values);
        System.debug('In checkForContacts con isSMS = '+isSMS);
        populateCustomerInteractionContacts(checkWrapper.values, isSMS, checkWrapper.customerInteraction);
        if(checkContactsEmail(checkWrapper.customerInteraction)){
            checkWrapper.rw.success = false;
            checkWrapper.rw.resultMessage = Label.XC_CL_CustomerInteraction_EmptyEmail;
            //return rw;
            checkWrapper.isReturn = true;
        }
        if(checkContactsPhone(checkWrapper.customerInteraction)){
            checkWrapper.rw.success = false;
            checkWrapper.rw.resultMessage = Label.XC_CL_CustomerInt_MobilePhone;
            //return rw;
            checkWrapper.isReturn = true;
        }
    }

    /**
     * @description Method for WorkOrder
     * @param checkWrapper - CheckValuesWrapper
     * @return CheckValuesWrapper
     */
    public static CheckValuesWrapper checkForTypeObject(CheckValuesWrapper checkWrapper) {
        checkForOpportunity(checkWrapper);
        if(checkWrapper.isReturn) {
            return checkWrapper;
        }
        checkWrapper.isReturn = false;
        checkForOrder(checkWrapper);
        if(checkWrapper.isReturn) {
            return checkWrapper;
        }
        checkWrapper.isReturn = false;
        checkForWorkOrder(checkWrapper);
        if(checkWrapper.isReturn) {
            return checkWrapper;
        }
        return checkWrapper;
    }

    /**
     * @description Method for WorkOrder
     * @param checkWrapper - CheckValuesWrapper
     */
    public static void checkForWorkOrder(CheckValuesWrapper checkWrapper) {
        if(checkWrapper.values.get('workorderId') != null){
            String workorderId = (String)checkWrapper.values.get('workorderId');
            checkWrapper.customerInteraction.XC_WorkOrderId__c = workorderId;
            try{
                if(Test.isRunningTest() && throwExceptionInTest) {
                    throw new XC_Exception();
                }
                XC_UTIL_CustomerInteractionGeneration.populateFromWorkOrder(checkWrapper.customerInteraction);
            } catch (XC_Exception e) {
                checkWrapper.rw.success = false;
                checkWrapper.rw.resultMessage = e.getMessage();
                //return rw;
                checkWrapper.isReturn = true;
            }
        }
    }

    /**
     * @description Method for Opportunity
     * @param checkWrapper - CheckValuesWrapper
     */
    public static void checkForOpportunity(CheckValuesWrapper checkWrapper) {
        if(checkWrapper.values.get('opportunityId') != null){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'entered in Opportunity section with ' +checkWrapper.values.get('opportunityId'));
            String opportunityId = (String)checkWrapper.values.get('opportunityId');
            String accountId = (String)checkWrapper.values.get('accountId');
            checkWrapper.customerInteraction.XC_OpportunityId__c = opportunityId;
            Boolean isAccountRequired = checkAccountRequired(checkWrapper.values);
            try{
                if(Test.isRunningTest() && throwExceptionInTest) {
                    throw new XC_Exception();
                }
                XC_UTIL_CustomerInteractionGeneration.populateFromOpportunity(checkWrapper.customerInteraction);
                if(!isAccountRequired){
                    checkWrapper.customerInteraction.XC_AccountId__c = null;
                }
            } catch (XC_Exception e) {
                checkWrapper.rw.success = false;
                checkWrapper.rw.resultMessage = e.getMessage();
                //return checkWrapper.rw;
                checkWrapper.isReturn = true;
            }
        }   
    }

    /**
     * @description Method for Order
     * @param checkWrapper - CheckValuesWrapper
     */
    public static void checkForOrder(CheckValuesWrapper checkWrapper) {
        if(checkWrapper.values.get('orderId') != null){
            String orderId = (String)checkWrapper.values.get('orderId');
            checkWrapper.customerInteraction.XC_OrderId__c = orderId;
            try{
                if(Test.isRunningTest() && throwExceptionInTest) {
                    throw new XC_Exception();
                }
                XC_UTIL_CustomerInteractionGeneration.populateFromOrder(checkWrapper.customerInteraction);
            } catch (XC_Exception e) {
                checkWrapper.rw.success = false;
                checkWrapper.rw.resultMessage = e.getMessage();
                //return rw;
                checkWrapper.isReturn = true;
            }
        }
    }

    /**
     * @description Check for Channel and Email for CustomerInteraction
     * @param customerInteraction - XC_Customer_Interaction__c
     * @return Boolean
     */
    public static Boolean checkContactsEmail(XC_Customer_Interaction__c customerInteraction) {
        return (customerInteraction.XC_Channel__c == 'Email' && customerInteraction.XC_Email__c==null);
    }

    /**
     * @description Check for Channel and Phone for CustomerInteraction
     * @param customerInteraction - XC_Customer_Interaction__c
     * @return Boolean
     */
    public static Boolean checkContactsPhone(XC_Customer_Interaction__c customerInteraction) {
        return (customerInteraction.XC_Channel__c == 'SMS' && (customerInteraction.XC_Phone__c==null || !validateMobilePhone(customerInteraction.XC_Phone__c)));
    }

    /**
     * @description Populate Account for CustomerInteraction
     * @param values - Map<String, Object>
     * @param customerInteraction - XC_Customer_Interaction__c
     */
    public static void populateCustomerInteractionAccount(Map<String, Object> values, XC_Customer_Interaction__c customerInteraction) {
        String leadId = (String)values.get('leadId');
        if(leadId != null){
            XC_UTIL_CustomerInteractionGeneration.populateFromLead(customerInteraction, values);
            if(values.get('accountId') != null){
                String accountId = (String)values.get('accountId');
                customerInteraction.XC_AccountId__c = accountId;
            }
        }
    }

    /**
     * @description Check isSMS
     * @param values - Map<String, Object>
     * @return Boolean
     */
    public static Boolean checkIsSMS(Map<String, Object> values) {
        Boolean isSMS = false;
        if(values.get('isSMS')!=null){
            isSMS = (Boolean)values.get('isSMS');
        }
        return isSMS;
    }

    /**
     * @description Check AccountRequired 
     * @param values - Map<String, Object>
     * @return Boolean
     */
    public static Boolean checkAccountRequired(Map<String, Object> values) {
        Boolean isAccountRequired = false;
        if(values.get('isAccountRequired')!=null){
            isAccountRequired = (Boolean)values.get('isAccountRequired');
        }
        return isAccountRequired;
    }

    /**
     * @description Populate contacts for CustomerInteraction
     * @param values - Map<String, Object>
     * @param isSMS - Boolean
     * @param customerInteraction - XC_Customer_Interaction__c
     */
    public static void populateCustomerInteractionContacts(Map<String, Object> values, Boolean isSMS, XC_Customer_Interaction__c customerInteraction) {
        System.debug('In populateCustomerInteractionContacts');
        if(isSMS){
            customerInteraction.XC_Channel__c = 'SMS';
        }else{
            customerInteraction.XC_Channel__c = 'Email';
        }
        customerInteraction.XC_Source__c = 'CRM';
        customerInteraction.XC_Communication_Type__c = (String)values.get('customerType');
        if(values.get('newMobilePhone')!=null){
            customerInteraction.XC_Phone__c = (String)values.get('newMobilePhone');
        }
        if(values.get('newEmail')!=null){
            customerInteraction.XC_Email__c = (String)values.get('newEmail');
        }
    }

    /**
     * @description Populate WorkOrder for CustomerInteraction
     * @param sa - List<ServiceAppointment>
     * @param customerInteraction - XC_Customer_Interaction__c
     */
    public static void populateCustomerInteractionWorkOrder(List<ServiceAppointment> sa, XC_Customer_Interaction__c customerInteraction) {
        if(!sa.isEmpty() && sa[0].ParentRecordId!=null) {
                customerInteraction.XC_WorkOrderId__c = sa[0].ParentRecordId;
        }
    }

    /**
      * @description Validate mobile phone.
      *
      * @param phone the phone
      * @return the boolean
      */
      @TestVisible
    private static Boolean validateMobilePhone(String phone){
        
        Boolean result = false;
        String phoneRegex = '^(\\+34|0034|34)?[\\s|\\-|\\.]?[6|7][\\s|\\-|\\.]?([0-9][\\s|\\-|\\.]?){8}$' ; 
        Pattern myPattern = Pattern.compile(phoneRegex);
        Matcher myMatcher = myPattern.matcher(phone);
        result = myMatcher.matches();
        
        return result;
        
    }

}