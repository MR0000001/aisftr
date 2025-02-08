/**
* @author Massimiliano Avallone  massimiliano.avallone@nttdata.com
* @date Creation 02/10/2019
* @date Modification dd/mm/yyyy
* @description  – public class with invocable method. It is invoked by a Flow to create a specific case connected with the step "Send to Assista" in the eMobility templates
*/ 
public without sharing class XC_IN033_SendToAssista { 
    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_IN033_SendToAssista');
    /** 
    * @description InputWrapper the input wrapper.
    */
    public class InputWrapper{ 
        @Invocablevariable
        public String stepId;        
    } 
    /** 
    * @description UtilWrapper util wrapper for the class. 
    */
    public class UtilWrapper{ 
        public String country;
        public String accountId;
        public String contactId;
        public String assetId;
        public String configurationId;
        public String accountName;
        public String accountPhone;
        public String legalEntity;
        public String preferredlanguage;
        public String productId;
        public String workOrderId;
        public String configurationItemId;
        public XC_Provisioning_Step__c step;
    }
    
    /** 
     * @description create a Send to Assista Case.
     * @param inputWrapperList from the flow
     */
    @InvocableMethod
    public static void createSendToAssistaCase(List<InputWrapper> inputWrapperList) { 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Entering In XC_IN033_SendToAssista');
        List<String> caseSettingNames = new List<String>{Label.XC_CL_SendToAssistaCase};
        Map<String, XC_CM_Case_Type_Setting__mdt> caseSettingsMap = XC_UTIL_Case.retriveCaseTypeSettings(caseSettingNames);
        XC_CM_Case_Type_Setting__mdt caseSettings = caseSettingsMap.get(Label.XC_CL_SendToAssistaCase);
        UtilWrapper utilWr = getParentsInfo(inputWrapperList);
        //ACTIONS
        createCaseAndUpdateStep(caseSettings, utilWr);
    }

    /** 
     * @description create Case and populate Provisioning Step.
     * @param caseSettings - XC_CM_Case_Type_Setting__mdt
     * @param utilWr - UtilWrapper 
     */
    private static void createCaseAndUpdateStep(XC_CM_Case_Type_Setting__mdt caseSettings, UtilWrapper utilWr){
        XC_Provisioning_Step__c step = utilWr.step;
        if (createCase(caseSettings, utilWr)){   
            step.XC_Status__c = Label.XC_CL_Completed_Ok;
        } else{
            step.XC_Status__c = Label.XC_CL_Step_CompletedKO;
        }
        XC_UTIL_Sobject.updateRecord(step);   
    }
        /**
    * @description Gets the info from step.
    * @param inputWrapperList the input wrapper list
    * @return 
    **/
    private static UtilWrapper getParentsInfo(List<InputWrapper> inputWrapperList){
        
        UtilWrapper wrapper = new UtilWrapper();
        NE__OrderItem__c orderItemFather = new NE__OrderItem__c();
        List<String> configurationItemIds = new List<String>(); 
        List<String> listStepIds = new List<String>(); 
        for(InputWrapper inputWr : inputWrapperList){                
            listStepIds.add(inputWr.stepId);
        }
        
        
        List<XC_Provisioning_Step__c> listSteps =  new list<XC_Provisioning_Step__c> ([
             SELECT XC_Configuration_Item__c, XC_ConfigurationId__c
            FROM XC_Provisioning_Step__c 
            WHERE Id IN: listStepIds
        ]);
        XC_Provisioning_Step__c step = listSteps[0];
        for(XC_Provisioning_Step__c provisioningStep : listSteps){
            if(!String.isBlank(provisioningStep.XC_Configuration_Item__c)){
                configurationItemIds.add(provisioningStep.XC_Configuration_Item__c);
            }
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'listStepIds -->' + listStepIds);
    
    
        List<NE__OrderItem__c> configurationItemList = new List<NE__OrderItem__c>([
            SELECT Id, XC_CountryFormula__c, NE__OrderId__c, NE__ProdId__c, NE__OrderId__r.NE__OptyId__r.XC_Contact__c, NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c, 
            //(SELECT Id, AccountId, Account.Name, Account.MainPhone__c, ContactId, Contact.Email, Contact.XC_Preferredlanguageofcontact__c FROM Assets__r),
            (SELECT Id,AssetId, AccountId, Account.Name, Account.MainPhone__c, ContactId, Contact.Email, Contact.XC_Preferredlanguageofcontact__c  FROM Work_Orders__r WHERE XC_WorkTypeCategory__c =: Label.XC_CL_WorkType_SiteInspection)
            FROM NE__OrderItem__c 
            WHERE Id IN: configurationItemIds 
            ]);             
        
        if(!configurationItemList.isEmpty()){
            wrapper.country = configurationItemList[0].XC_CountryFormula__c;
            wrapper.step = step;
            wrapper.configurationId = configurationItemList[0].NE__OrderId__c;
            wrapper.configurationItemId = configurationItemList[0].Id;
            wrapper.contactId = configurationItemList[0].NE__OrderId__r.NE__OptyId__r.XC_Contact__c;
            wrapper.legalEntity = configurationItemList[0].NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c;
            wrapper.productId = configurationItemList[0].NE__ProdId__c;
            if(!configurationItemList[0].Work_Orders__r.isEmpty()){
                wrapper.accountId = configurationItemList[0].Work_Orders__r[0].AccountId;
                wrapper.assetId = configurationItemList[0].Work_Orders__r[0].AssetId;
                wrapper.accountName = configurationItemList[0].Work_Orders__r[0].Account.Name;
                wrapper.accountPhone = configurationItemList[0].Work_Orders__r[0].Account.MainPhone__c;
                wrapper.preferredlanguage = getPreferredLanguage(configurationItemList[0].Work_Orders__r[0].Contact.XC_Preferredlanguageofcontact__c);
                wrapper.workOrderId = configurationItemList[0].Work_Orders__r[0].Id;
            }
        }
        return wrapper; 
    }
    
    private static String getPreferredLanguage(String preferedLanguageOnContact){
        Schema.DescribeFieldResult fieldResult = XC_Customer_Interaction__c.XC_Preferredlanguageofcontact__c.getDescribe();
        List<String> acceptedLanguages= new List<String>();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry pickListVal : ple){
            acceptedLanguages.add(pickListVal.getLabel());
        }  
        
        String preferredlanguage = '';
        if(acceptedLanguages.contains(preferedLanguageOnContact)){
            preferredlanguage = preferedLanguageOnContact;  /*ESCEP-1826 MCutillo 10/05/2019*/
        } else {
            preferredlanguage = Label.XC_CL_EnglishPrefLanguage;
        }
        return preferredlanguage;
    }    
    /**
    * @description Method that create the case
    * @param caseSettings - XC_CM_Case_Type_Setting__mdt
    * @param utilWr  - UtilWrapper 
    * @return Boolean
    **/ 
    private static Boolean createCase(XC_CM_Case_Type_Setting__mdt caseSettings, UtilWrapper utilWr){  
        List<Case> caseToInsertList = new List<Case>();
        List<String> countryList = new List<String>{utilWr.country};
        //Map<String, Id> recordTypeMap = XC_UTIL_Case_U_Check.getRecordTypeByCountry(countryList);
        
        AssignmentRule AR = new AssignmentRule();
        AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.assignmentRuleId = AR.id;
        
        Case cs = XC_UTIL_Case.initCaseFromCaseSettings(caseSettings);
        //cs.RecordTypeId = recordTypeMap.get(utilWr.country.toUpperCase());    RecordType set by trigger
        /*cs.Reason = caseSettings.XC_Case_Reason__c; 
        cs.SubCause__c = caseSettings.XC_Sub_Cause__c;
        cs.XC_Subtype__c = caseSettings.XC_Sub_Type__c;
        cs.Status = caseSettings.XC_Status__c;
        cs.Priority = caseSettings.XC_Priority__c;
        cs.Origin = caseSettings.XC_Origin__c; */
        cs.AccountId = utilWr.accountId;
        cs.ContactId = utilWr.contactId;
        cs.AssetId = utilWr.assetId;
        cs.XC_Order__c = utilWr.configurationId;
        cs.XC_OriginChannel__c = Label.XC_EMobility;
        cs.XC_WorkOrder__c = utilWr.workOrderId;
        cs.XC_OrderItem__c = utilWr.configurationItemId;
        cs.XC_LegalEntity__c = utilWr.legalentity;
        cs.setOptions(dmlOpts);
        caseToInsertList.add(cs);        
        List <XC_UTIL_Sobject.WrapperResult> listWr = XC_UTIL_Sobject.insertListRecords(caseToInsertList);
        return XC_UTIL_Sobject.checkDMLResults(listWr);
    }
}