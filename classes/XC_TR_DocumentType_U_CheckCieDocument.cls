/**
* @author massimiliano avallone massimiliano.avallone@nttdata.com - salvatore scarpato salvatore.scarpato@nttdata.com
* @date Creation 03/10/2019
* @date Modification 
* @description XC_TR_DocumentType_Handler – Handler for XC_TR_DocumentType Trigger
*/ 
public without sharing class XC_TR_DocumentType_U_CheckCieDocument{
    
    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_DocumentType_U_CheckCieDocument');

    /** 
    * @description UtilWrapper util wrapper for the class. 
    */
    public class UtilWrapper{
        public String country;
        public String accountId;
        public String contactId;
        public String email;
        public String configurationItemId;
        public String contactName;
        public String accountPhone;
        public String legalEntity;
        public String preferredlanguage;
        public String workOrderId;
        public String caseId;
        public String doxeeUrl;
        public String provisioningStepId;
    }

    /**
    * @description onUpdate
    * @param mapOld - Map<Id, SObject> 
    * @param mapNew - Map<Id, SObject>
    **/
    public static void onUpdate(Map<Id, SObject> mapOld, Map<Id, SObject> mapNew) {
        system.debug('@@@onUpdate cie');
        List<XC_DocumentType__c> listDocumentTypeChanged = XC_UTIL_SObject.getListChanged(new List<String>{'Category__c','XC_ConfigurationItem__c','XC_DoxeeUrl__c'}, mapOld, mapNew);
        system.debug('<---- @107 ENTER IN PopolateField - list DocumentType changed--> ' + listDocumentTypeChanged);
        if(listDocumentTypeChanged.isEmpty()){
            system.debug('@@@doc type cie return');
            return;
        }
        checkCieDocument(listDocumentTypeChanged);
    }

    /**
    * @description onInsert
    * @param listNew - List<XC_DocumentType__c>
    **/
    public static void onInsert(List<XC_DocumentType__c> listNew) {
        checkCieDocument(listNew);
    } 

    /**
    * @author Massimiliano Avallone - massimiliano.avallone@nttdata.com
    * @param listDocumentType - List<XC_DocumentType__c>
    * @description check CIE Document
    */     
    public static void checkCieDocument(List<XC_DocumentType__c> listDocumentType){
		system.debug('@@@in checkCieDocument');
        List<String> doxeeUrlList = new List<String>();
        
        XC_DocumentType__c docType = listDocumentType[0];
        String configurationItemId = '';
        String doxeeUrl = '';
        
        if(docType.Category__c == Label.XC_CL_Document_CIE && !String.isBlank(docType.XC_DoxeeUrl__c)){
            system.debug('@@@if 1');
            configurationItemId = docType.XC_ConfigurationItem__c;
            doxeeUrl = docType.XC_DoxeeUrl__c;
        } else {
            return;
        }
        UtilWrapper utilWr = getParentsInfo(configurationItemId, doxeeUrl);
        if(!String.isBlank(utilWr.configurationItemId)){
            system.debug('@@@if 2');
            List<XC_UTIL_Sobject.WrapperResult> wrResultList = createCustomerInteraction(utilWr);
            if(wrResultList[0].success){
                completeStep(utilWr.provisioningStepId);
            }
        }
    }

    private static void completeStep(String provisioningStepId){
        
        /*List<XC_Provisioning_Step__c> listProvStep = new List<XC_Provisioning_Step__c>([
        SELECT Id
        FROM XC_Provisioning_Step__c
        WHERE XC_Configuration_Item__c =: configurationItemId and XC_Flow_API_Name__c =: Label.XC_CL_ProvisioningDocSending_Flow and XC_Status__c =: Label.XC_CL_Provisioning_Step_InProgress
        ]);*/
        List<XC_Provisioning_Step__c> listPStep = new List<XC_Provisioning_Step__c> ();
        if(!String.isBlank(provisioningStepId)){
            XC_Provisioning_Step__c ps = new XC_Provisioning_Step__c(Id= provisioningStepId);
            ps.XC_Status__c = Label.XC_CL_Completed_Ok; 
            XC_UTIL_Sobject.updateRecord(ps);
        }
    }

    
    /**
    * @description Gets the info from step.
    * @param inputWrapperList the input wrapper list
    * @return 
    **/
    private static UtilWrapper getParentsInfo(String configuratioItemId, String doxeeUrl){
        System.debug('@@@@Entrato in getParentsInfo');
        UtilWrapper wrapper = new UtilWrapper();
    
        List<NE__OrderItem__c> configurationItemList = new List<NE__OrderItem__c>([
            SELECT id, XC_CountryFormula__c, NE__OrderId__c, NE__ProdId__c, NE__OrderId__r.NE__OptyId__r.XC_Contact__c, NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c,
            NE__OrderId__r.NE__AccountId__r.name, NE__OrderId__r.NE__AccountId__r.PrimaryEmail__c, NE__OrderId__r.NE__AccountId__c,
            (SELECT id, AccountId, Contact.Name, Account.MainPhone__c, ContactId, Contact.Email, Contact.XC_Preferredlanguageofcontact__c from Assets__r),
            (SELECT Id FROM Work_Orders__r WHERE XC_WorkTypeCategory__c =: Label.XC_CL_WorkType_SiteInspection),
            (SELECT Id FROM Cases__r WHERE Origin =: Label.XC_CL_CaseOriginCAN002 AND Reason =: Label.XC_CL_CaseReason_XCMOT007 AND SubCause__c =: 'ATCL023'),
            (SELECT Id FROM Provisioning_Steps__r WHERE XC_Flow_API_Name__c =: Label.XC_CL_ProvisioningDocSending_Flow and XC_Status__c =: Label.XC_CL_Provisioning_Step_InProgress)
            FROM NE__OrderItem__c 
            WHERE Id =: configuratioItemId
        ]);             
        
        if(!configurationItemList.isEmpty()){
            wrapper.doxeeUrl = doxeeUrl;
            wrapper.country = configurationItemList[0].XC_CountryFormula__c;
            wrapper.configurationItemId = configurationItemList[0].NE__OrderId__c;
            wrapper.contactId = configurationItemList[0].NE__OrderId__r.NE__OptyId__r.XC_Contact__c;
            wrapper.legalEntity = configurationItemList[0].NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c;
            wrapper.accountId = configurationItemList[0].NE__OrderId__r.NE__AccountId__c;
            wrapper.contactName = configurationItemList[0].NE__OrderId__r.NE__AccountId__r.name;
            wrapper.email = configurationItemList[0].NE__OrderId__r.NE__AccountId__r.PrimaryEmail__c;
            if(!configurationItemList[0].Assets__r.isEmpty()){
                //If the asset is created, the value contact name and email are ovrewritten here
                wrapper.contactName = configurationItemList[0].Assets__r[0].Contact.Name;
                wrapper.email = configurationItemList[0].Assets__r[0].Contact.Email;
                wrapper.preferredlanguage = getPreferredLanguage(configurationItemList[0].Assets__r[0].Contact.XC_Preferredlanguageofcontact__c);
            }
            if(!configurationItemList[0].Work_Orders__r.isEmpty()){
                wrapper.workOrderId = configurationItemList[0].Work_Orders__r[0].Id;
            }
            if(!configurationItemList[0].Cases__r.isEmpty()){
                wrapper.caseId = configurationItemList[0].Cases__r[0].Id;
            }
            if(!configurationItemList[0].Provisioning_Steps__r.isEmpty()){
                wrapper.provisioningStepId = configurationItemList[0].Provisioning_Steps__r[0].Id;
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

    private static List<XC_UTIL_Sobject.WrapperResult> createCustomerInteraction(UtilWrapper wrapper) { 
        System.debug('@@@@Entrato in createCustomerInteraction');
        List<Map<String,Object>> interactions = new List<Map<String,Object>>();
        String accountId = wrapper.accountId; 
        String contactId = wrapper.contactId;
        String orderId = wrapper.configurationItemId;
        String contactName = wrapper.contactName;
        String accountPhone = wrapper.accountPhone;
        String legalEntity = wrapper.legalEntity;
        String workOrderId = wrapper.workOrderId;
        String caseId = wrapper.caseId;
        String docUrl = wrapper.doxeeUrl;
        String email = wrapper.email;
        String preferredlanguage = wrapper.preferredlanguage;
        Map<String,Object> data = new Map<String,Object>();
        data.put('customerType', Label.XC_CL_CustomerInter_ComType_SendCIEDoc);
        data.put('skipComunication', false);
        data.put('accountId', accountId);
        data.put('contactId', contactId);
        data.put('workorderId', workorderId);
        data.put('legalEntity', legalEntity);
        data.put('caseId', caseId);
        data.put('preferredlanguage', preferredlanguage); /*ESCEP-1826 MCutillo 10/05/2019*/
        data.put('orderId', orderId);
        data.put('fullName', contactName);
        data.put('docURL', docUrl);
        data.put('email', email);
        data.put('sent', false);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@SS@ data Map -->' + data);
        interactions.add(data);
        return XC_UTIL_CustomerInteractionGeneration.newEmailForCustomerFromWorkOrder(interactions);
    } 
	

}