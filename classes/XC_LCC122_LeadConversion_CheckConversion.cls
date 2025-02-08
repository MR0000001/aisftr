/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com & Valeria Martino - valeria.martino@nttdata.com
* @date Creation 27/06/2019
* @description XC_LCC122_LeadConversion_CheckConversion – Check methods for Lead Conversion 
*/ 

public without sharing class XC_LCC122_LeadConversion_CheckConversion {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC122_LeadConversion');

    /** @description ConversionWrapper */
    public class ConversionWrapper {
        public Boolean successConvert = false;
        public Contact contactConverted;
        public Account accountConverted;
        public Opportunity opportunityToInsert;
        public Database.LeadConvert leadConvertManager;
        public XC_LCC122_LeadConversion.ConversionResultWrapper resultWrapper = new XC_LCC122_LeadConversion.ConversionResultWrapper();
        public Savepoint savePoint;
        public Boolean createOpportunity = false;
    }

    /** @description OpportunityWrapper */
    public class OpportunityWrapper {
        public XC_LCC122_LeadConversion.ConversionResultWrapper resultWrapper = new XC_LCC122_LeadConversion.ConversionResultWrapper();
        public Boolean createOpportunity = false;
        public Lead ld;
        public Contact contactConverted;
        public Account accountConverted;
        public Database.LeadConvert leadConvertManager;
        public Savepoint savePoint;
        public Boolean successOpp = false;
    }

    /** @description AfterCheckConversionWrapper */
    public class AfterCheckConversionWrapper {
        public Lead ld;
        public Contact contactConverted;
        public XC_LCC122_LeadConversion.ConversionResultWrapper resultWrapper;
        public Boolean createOpportunity = false;
        public XC_LCC122_LeadConversion.CheckResultWrapper checkWrapper;
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com & Valeria Martino - valeria.martino@nttdata.com
    * @date Creation 27/06/2019
    * @description Create Opportunity for Lead Conversion
    * @param wrapper - OpportunityWrapper
    * @param opportunityToInsert - Opportunity
    */ 
    public static void createOpportunity(OpportunityWrapper wrapper, Opportunity opportunityToInsert) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'XC_LCC122_LeadConversion_CheckConversion - START createOpportunity');
        if(wrapper.createOpportunity && (
                                ((wrapper.ld.XC_LeadRecordType__c == Label.XC_CL_Lead_Soho && wrapper.contactConverted.XC_PrimaryContact__c) || wrapper.ld.XC_LeadRecordType__c == Label.XC_CL_Lead_Condominium) || 
                                (wrapper.ld.XC_LeadRecordType__c == Label.XC_CL_Lead_Residential) || 
                                (wrapper.ld.XC_LeadRecordType__c == Label.XC_CL_Lead_GLOB2B) || (wrapper.ld.XC_LeadRecordType__c == Label.XC_CL_Lead_GLOB2G) || 
                                wrapper.ld.XC_LeadRecordType__c.contains('SFM')
        )) {  
            XC_UTIL_Debug.debug(DEBUGACTIVE, '### wrapper ----> '+wrapper);                                      
            XC_UTIL_LeadConversion.populateSobjectDataByLeadData(wrapper.ld, 'Opportunity', opportunityToInsert);
            opportunityToInsert.XC_IsConverted__c = true;
            opportunityToInsert.XC_Contact__c = wrapper.contactConverted.Id;
            opportunityToInsert.AccountId = wrapper.accountConverted.Id;
            opportunityToInsert.StageName = Label.XC_CL_Opportunity_Draft;
            opportunityToInsert.Name = 'NoName';
            XC_UTIL_Debug.debug(DEBUGACTIVE, '### opportunityToInsert ----> '+opportunityToInsert);
            List<XC_CM_Opportunity_Default_Values__mdt> cmOpp = new List<XC_CM_Opportunity_Default_Values__mdt>();
            if(wrapper.ld.XC_LeadRecordType__c.contains('SFM')){
                cmOpp = new List<XC_CM_Opportunity_Default_Values__mdt>([
                SELECT XC_Default_Days_For_Close_Date_On_Insert__c 
                FROM XC_CM_Opportunity_Default_Values__mdt 
                WHERE XC_Country__c = :wrapper.ld.XC_Country__c]);
            }else{
             cmOpp = new List<XC_CM_Opportunity_Default_Values__mdt>([
                SELECT XC_Default_Days_For_Close_Date_On_Insert__c 
                FROM XC_CM_Opportunity_Default_Values__mdt 
                WHERE XC_Country__c = :wrapper.contactConverted.XC_CountryLegalEntity__c]);
            }
            XC_UTIL_Debug.debug(DEBUGACTIVE, '### cmOpp ----> '+cmOpp);    
            opportunityToInsert.CloseDate = Date.today().addDays(Integer.valueOf(cmOpp[0].XC_Default_Days_For_Close_Date_On_Insert__c));
            XC_UTIL_sObject.WrapperResult dmlOpportunityResult = XC_UTIL_sObject.insertRecord(opportunityToInsert);            
            XC_UTIL_Debug.debug(DEBUGACTIVE, '### dmlOpportunityResult ----> '+dmlOpportunityResult);  
            if(!dmlOpportunityResult.success){ 
                wrapper.resultWrapper.errorMessage = dmlOpportunityResult.errorMessage;                
                XC_UTIL_Debug.debug(DEBUGACTIVE, '### dmlOpportunityResult.errorMessage ----> '+dmlOpportunityResult.errorMessage);  
                Database.rollback(wrapper.savePoint);
                wrapper.successOpp = false;      
                return;
            }
            wrapper.leadConvertManager.setOpportunityId(opportunityToInsert.Id); 
        } else if(wrapper.createOpportunity) {
            wrapper.resultWrapper.errorMessage = Label.XC_CL_LeadConv_CannotCreateOpp;
            wrapper.successOpp = false;   
            return;
        } 
        wrapper.successOpp = true;
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com & Valeria Martino - valeria.martino@nttdata.com
    * @date Creation 27/06/2019
    * @description Check for post Lead Conversion
    * @param wrapper - AfterCheckConversionWrapper
    */ 
    public static void checkPostLeadConversion(AfterCheckConversionWrapper wrapper) {
        // For Address:
        XC_LCC122_LeadConversion_U.checkAddressForAccount(wrapper.ld, wrapper.contactConverted);

        // For WorkOrder:
        XC_LCC122_LeadConversion_U.populateWorkOrder(wrapper.resultWrapper, wrapper.createOpportunity, wrapper.checkWrapper.listWorkOrder);

        // For Current User:
        String idUser = UserInfo.getUserId();
        List<User> user = new List<User>([SELECT Account.isPartner FROM User WHERE Id = :idUser]);
        wrapper.resultWrapper.community = user[0].Account.isPartner;
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com 
    * @date Creation 17/07/2019
    * @description Conversion Lead
    * @param wrapper - ConversionWrapper
    */ 
    public static void checkPostLeadConversion(ConversionWrapper wrapper) {
        try{
            Database.LeadConvertResult leadConvertResult = Database.convertLead(wrapper.leadConvertManager);
            if(leadConvertResult.isSuccess()){
                wrapper.resultWrapper.success = true;
                wrapper.resultWrapper.contact = wrapper.contactConverted;
                wrapper.resultWrapper.account = wrapper.accountConverted;
                if(wrapper.createOpportunity) {
                    wrapper.resultWrapper.opportunity = wrapper.opportunityToInsert;
                }
                wrapper.successConvert = true;
            }               
        } catch(Exception e) {
            Database.rollback(wrapper.savePoint);
            wrapper.resultWrapper.errorMessage = e.getMessage();
            wrapper.successConvert = false;
        }
    }

}