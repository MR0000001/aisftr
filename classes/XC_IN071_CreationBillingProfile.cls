/**
 * @author Salvatore Barbera
 * @email sbarbera@deloitte.it
 * @create date 23-03-2021
 * @modify date 23-03-2021
 * @desc class called from XC_FL_eMobility_CreateBillingProfile
 */


public without sharing class XC_IN071_CreationBillingProfile {
    
    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_IN071_CreationBillingProfile');

    /** 
     * @description InputWrapper the input wrapper. TEST
     */
    public class InputWrapper{ 

        @Invocablevariable
        public String stepId;   

        public InputWrapper(){
        }

        public InputWrapper(String stepId){
            this.stepId = stepId;
        }
            
    }

    @InvocableMethod 
    public static void createBillingProfile(List<InputWrapper> inputWrapperList) {
        
        /**
         * Create list of stepId 
         */
        List<String> listStepIds = new List<String>(); 
        for(InputWrapper inputWr : inputWrapperList){                
            listStepIds.add(inputWr.stepId);
        }

        XC_UTIL_Debug.debug(DEBUGACTIVE, 'listStepIds: ' + listStepIds);

        /**
         * Get provisioning stepId Map
         */
        Map<Id, XC_Provisioning_Step__c> mapSteps = new Map<ID,XC_Provisioning_Step__c>([SELECT Id, XC_Configuration_Item__c, XC_Configuration_Item__r.XC_BillingProfileLineItem__c, XC_Configuration_Item__r.XC_Segment__c,
                                                                                            XC_Configuration_Item__r.NE__OrderId__r.NE__OptyId__c, XC_Configuration_Item__r.NE__OrderId__r.XC_POD__c
                                                                                        FROM XC_Provisioning_Step__c
                                                                                        WHERE ID IN :listStepIds]);
        XC_UTIL_Debug.debug(DEBUGACTIVE,'mapSteps: ' + mapSteps);

        /**
         * Get list XC_Provisioning_Step__c from Map
         */                                              
        XC_Provisioning_Step__c step = mapSteps.values()[0];
        ID opportunityId = step.XC_Configuration_Item__r.NE__OrderId__r.NE__OptyId__c;
        Opportunity opportunity = [SELECT Id, AccountId, XC_Address__c, XC_LegalEntity__c, XC_Contact__c, XC_Contact__r.Email, XC_Contact__r.XC_Preferredlanguageofcontact__c,
                                        XC_Contact__r.AccountId, XC_Contact__r.Account.XC_DocumentCountry__c, XC_Contact__r.Account.IdentityNumber__c, XC_Contact__r.Account.IdentityType__c
                                    FROM Opportunity 
                                    WHERE ID = :opportunityId];

        /**
         * Create BillingProfile for each opportunity (should be one)
         */
        NE__Billing_Profile__c billingProfile = new NE__Billing_Profile__c();
        billingProfile.Name = Label.XC_CL_Commodity_Bill;
        billingProfile.NE__Payment__c = Label.XC_CL_Commodity_Bill;
        billingProfile.XC_InvoiceDeliveryPref__c = String.isNotBlank(opportunity.XC_Contact__r.Email) ? 'Email' : 'Print';
        billingProfile.XC_InvoicePreferredLanguage__c = opportunity.XC_Contact__r.XC_Preferredlanguageofcontact__c;
        billingProfile.XC_Status__c = Label.XC_CL_BillingProfileWaiting;
        billingProfile.XC_SkipBatch__c = true;
        billingProfile.NE__Account__c = opportunity.AccountId;
        billingProfile.XC_CommodityCupsID__c = step.XC_Configuration_Item__r.NE__OrderId__r.XC_POD__c;
        billingProfile.XC_OPDocumentType__c = opportunity.XC_Contact__r.Account.IdentityType__c;
        billingProfile.XC_OPDocumentNumber__c = opportunity.XC_Contact__r.Account.IdentityNumber__c;
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'billingProfile: ' + billingProfile);

        /**
         * Insert billingProfile to get ID
         */
        XC_UTIL_SObject.WrapperResult resultBillingProfileInsert = XC_UTIL_SObject.insertRecord(billingProfile);
        XC_UTIL_Debug.debug(DEBUGACTIVE,'resultBillingProfileInsert: ' + resultBillingProfileInsert);
        if(resultBillingProfileInsert.success != true) {
            step.XC_Status__c = Label.XC_CL_Step_CompletedKO;
            step.XC_ErrorMessage__c = 'Error creating Billing Profile: ' + resultBillingProfileInsert.errorMessage;
            XC_UTIL_SObject.updateRecord(step);
            return;
        }

        /**
         * Create BillingProfileLineItem
         * and relate it to billing profile created above
         */
        XC_BillingProfileLineItem__c billingProfileLineItem = new XC_BillingProfileLineItem__c();
        billingProfileLineItem.XC_BillingProfile__c = billingProfile.ID;
        billingProfileLineItem.XC_BillToContactId__c = opportunity.XC_Contact__c;
        billingProfileLineItem.XC_SoldToContactId__c = opportunity.XC_Contact__c;
        billingProfileLineItem.XC_BillToAddress__c = opportunity.XC_Address__c;
        billingProfileLineItem.XC_SoldToAddress__c = opportunity.XC_Address__c;
        billingProfileLineItem.XC_Status__c = Label.XC_CL_BillingProfileWaiting;
        billingProfileLineItem.XC_LegalEntity__c = 'EnelXMSP';
        billingProfileLineItem.XC_Account__c = opportunity.XC_Contact__r.AccountId;
        billingProfileLineItem.XC_DocumentCountry__c = opportunity.XC_Contact__r.Account.XC_DocumentCountry__c;
        billingProfileLineItem.XC_DocumentType__c = opportunity.XC_Contact__r.Account.IdentityType__c;
        billingProfileLineItem.XC_DocumentNumber__c = opportunity.XC_Contact__r.Account.IdentityNumber__c;
        billingProfileLineItem.XC_InvoiceDeliveryPreference__c = String.isNotBlank(opportunity.XC_Contact__r.Email) ? 'Email' : 'Print';
        billingProfileLineItem.XC_InvoicePreferredLanguage__c = opportunity.XC_Contact__r.XC_Preferredlanguageofcontact__c;
        billingProfileLineItem.XC_RecipientCodeB2B__c = (step.XC_Configuration_Item__r.XC_Segment__c != 'B2C') ? '0000000' : null;
        XC_UTIL_Debug.debug(DEBUGACTIVE,'billingProfileLineItem: ' + billingProfileLineItem);

        /**
         * insert billing profile line item
         */
        XC_UTIL_SObject.WrapperResult resultBillingProfileLineItemInsert = XC_UTIL_SObject.insertRecord(billingProfileLineItem);
        XC_UTIL_Debug.debug(DEBUGACTIVE,'resultBillingProfileLineItemInsert: ' + resultBillingProfileLineItemInsert);
        if(resultBillingProfileLineItemInsert.success != true) {
            step.XC_Status__c = Label.XC_CL_Step_CompletedKO;
            step.XC_ErrorMessage__c = 'Error creating Billing Profile line item: ' + resultBillingProfileLineItemInsert.errorMessage;
            XC_UTIL_SObject.updateRecord(step);
            XC_UTIL_SObject.deleteRecord(billingProfile);
            return;
        }

        /**
         * set profile on opportunity
         */
        XC_UTIL_Debug.debug(DEBUGACTIVE,'Update opportunity.XC_CommodityBillBPLI__c with: ' + resultBillingProfileLineItemInsert);
        opportunity.XC_CommodityBillBPLI__c = billingProfileLineItem.ID;

        /**
         * Update opportunity
         */
        XC_UTIL_SObject.WrapperResult resultOpportunityUpdate = XC_UTIL_SObject.updateRecord(opportunity);
        XC_UTIL_Debug.debug(DEBUGACTIVE,'opportunity after update: ' + opportunity);
        if(resultOpportunityUpdate.success != true) {
            step.XC_Status__c = Label.XC_CL_Step_CompletedKO;
            step.XC_ErrorMessage__c = 'Error updating opportunity: ' + resultOpportunityUpdate.errorMessage;
        } else if (step.XC_Configuration_Item__r.XC_Segment__c == 'B2C') {
            step.XC_Status__c = Label.XC_CL_Completed_OK;
        } else {
            NE__OrderItem__c confItem = new NE__OrderItem__c(Id = step.XC_Configuration_Item__c, XC_BillingProfileLineItem__c = billingProfileLineItem.Id);
            XC_UTIL_SObject.WrapperResult resultConfItemUpdate = XC_UTIL_SObject.updateRecord(confItem);
            XC_UTIL_Debug.debug(DEBUGACTIVE,'conf item after update: ' + confItem);
            if(resultConfItemUpdate.success != true) {
                step.XC_Status__c = Label.XC_CL_Step_CompletedKO;
                step.XC_ErrorMessage__c = 'Error updating conf item: ' + resultConfItemUpdate.errorMessage;
            } else {
                step.XC_Status__c = Label.XC_CL_Completed_OK;
            }
        }

        XC_UTIL_SObject.WrapperResult resultStepUpdate = XC_UTIL_SObject.updateRecord(step);
        XC_UTIL_Debug.debug(DEBUGACTIVE,'resultStepUpdate: ' + resultStepUpdate);

        if(resultStepUpdate.success != true){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Error updating Provisioning Step: ' + step);
        }
    }
}