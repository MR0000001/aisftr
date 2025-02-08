/**
* @author Dario Tramontin - dtramontin@deloitte.it
* @date Creation 15/07/2019
* @description XC_TR_EmailMessage_U_ManageParentCase – Case Status update from Email to Case
*/
public without sharing class XC_TR_EmailMessage_U_ManageParentCase {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_EmailMessage_U_ManageParentCase');

    /*private static void email2caseConfigurator(List<EmailMessage> listNew) {

        Set<Id> caseIds = new Set<Id>();
        Set<String> emailToAddress = new Set<String>();
        getEmailInfos(caseIds, emailToAddress, listNew);
        createEmail2CaseMapConfiguration(emailToAddress);
    }*/

    /**
     * @author Marco Ottaviano - mottaviano@deloitte.it
     * @description Method to retrieve Email2Case Configuration Custom Metadata Type 
     * @param emailToAddress - Set of email addresses for email-2-case service 
     * @return  Map<String,XC_CM_Email2Case_ServConfig__mdt>
    */

    private static  Map<String,XC_CM_Email2Case_ServConfig__mdt> createEmail2CaseMapConfiguration (Set<String> emailAddress) {
        Map<String,XC_CM_Email2Case_ServConfig__mdt> mapEmailRecevierCaseConfig= new Map<String,XC_CM_Email2Case_ServConfig__mdt>();
        List<XC_CM_Email2Case_ServConfig__mdt> listEmail2CaseConfig=[SELECT Id, XC_ServiceEmail__c, XC_CaseReason__c, XC_SubCause__c,
                                                                            XC_SubType__c, XC_Channel_Attribute__c, XC_LegalEntity__c
                                                                     FROM XC_CM_Email2Case_ServConfig__mdt where XC_ServiceEmail__c IN : emailAddress];
        if(!listEmail2CaseConfig.isEmpty()) {
            for(XC_CM_Email2Case_ServConfig__mdt config: listEmail2CaseConfig) {
                mapEmailRecevierCaseConfig.put(config.XC_ServiceEmail__c,config);
            }
        }

        return mapEmailRecevierCaseConfig;
    }

    
    /**
     * @author Marco Ottaviano - mottaviano@deloitte.it
     * @description Update the Case field based on configuration on XC_CM_Email2Case_ServConfig__mdt record
     * @param CaseTupUpdate 
     * @param mapEmailRecevierCaseConfig - map of XC_CM_Email2Case_ServConfig__mdt
     * @param email - the EmailMessage sent for the creation of email-to-case
     * @return Case - Case to update
    */
        
    private static Case manageCasebyEmail2CaseMetadata(Case caseToUpdate, Map<String,XC_CM_Email2Case_ServConfig__mdt> mapEmailRecevierCaseConfig, EmailMessage email) {
        //EXSFDCSL-488 - 20220718 - Baba Goudiaby - baba.goudiaby@webresults.it - Manage CcAddress email - Start 
        List<String> emailList = new List<String>();
        List<String> emailToAddressList = String.isBlank(email.ToAddress) ? new List<String>() : email.ToAddress.split('\\;');
        List<String> emailCcAddressList = String.isBlank(email.CcAddress) ? new List<String>() : email.CcAddress.split('\\;');
        emailList.addAll(emailToAddressList);
        emailList.addAll(emailCcAddressList);
        
        for(String emailAdd : emailList) {
            //EXSFDCSL-488 - 20220718 - Baba Goudiaby - baba.goudiaby@webresults.it - Manage CcAddress email - End 
            if(mapEmailRecevierCaseConfig.containsKey(emailAdd) ) {
                XC_CM_Email2Case_ServConfig__mdt config = mapEmailRecevierCaseConfig.get(emailAdd);
                caseToUpdate.Reason = String.isNotBlank(config.XC_CaseReason__c) ? config.XC_CaseReason__c : caseToUpdate.Reason;
                caseToUpdate.SubCause__c = String.isNotBlank(config.XC_CaseReason__c) && String.isNotBlank(config.XC_SubCause__c) ? config.XC_SubCause__c : caseToUpdate.SubCause__c;
                caseToUpdate.XC_Subtype__c = String.isNotBlank(config.XC_CaseReason__c) && String.isNotBlank(config.XC_SubCause__c) ? config.XC_SubType__c : caseToUpdate.XC_Subtype__c;
                caseToUpdate.XC_Channel_Attribute__c =  String.isNotBlank(config.XC_Channel_Attribute__c) ? config.XC_Channel_Attribute__c : caseToUpdate.XC_Channel_Attribute__c;
                caseToUpdate.XC_LegalEntity__c =  String.isNotBlank(config.XC_LegalEntity__c) ? config.XC_LegalEntity__c : caseToUpdate.XC_LegalEntity__c;
        	}
        }
        return caseToUpdate;
    }

    /**
     * @author Rui Teixeira - rui.pedroteixeira@everis.nttdata.com
     * @description Method to Cases
     * @param ListNew - List of EmailMessage
     * @return  
    */
    public static void updateEmail2CaseField(List<EmailMessage> listNew){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'IN XC_TR_EmailMessage_U_ManageParentCase.manageParentCase');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '#listNew -> ' + listNew);

        Set<Id> caseIds = new Set<Id>();
        Set<String> emailToAddress = new Set<String>();
        getEmailInfos(caseIds, emailToAddress, listNew);
        System.debug('Email Addresses '+emailToAddress);
        Map<String,XC_CM_Email2Case_ServConfig__mdt> mapEmailRecevierCaseConfig = createEmail2CaseMapConfiguration(emailToAddress);

        Map<Id,Case> caseToUpdate; 
        Map<Id,XC_CM_CountryLegalEntityAssociation__mdt> associations; 
        Map<String,String> emailLegalEn = new Map<String,String>(); 


        if(!caseIds.isEmpty()){
            caseToUpdate = new Map<Id,Case> ([SELECT Status, Reason, SubCause__c, OwnerId,
                                                     XC_Subtype__c, XC_Channel_Attribute__c, 
                                                     RecordTypeId, Origin, XC_Segment__c, XC_LegalEntity__c 
                                            FROM Case WHERE Id IN: caseIds]);
            associations = new Map<Id,XC_CM_CountryLegalEntityAssociation__mdt> ([SELECT XC_LegalEntity__c, XC_EmailToAddress__c 
                                                                                  FROM XC_CM_CountryLegalEntityAssociation__mdt
                                                                                  WHERE XC_EmailToAddress__c IN: emailToAddress]);

            if(!associations.isEmpty() ){
                for(XC_CM_CountryLegalEntityAssociation__mdt association : associations.values()){
                    emailLegalEn.put(association.XC_EmailToAddress__c, association.XC_LegalEntity__c); 
                }
            }
        }


        List<Case> listCase= new List<Case>();
        for(EmailMessage email : listNew){
            if(email.ParentId != null && caseToUpdate.get(email.ParentId).XC_LegalEntity__c != null && caseToUpdate.get(email.ParentId).XC_LegalEntity__c !='EnelXMobilityHolding' && caseToUpdate.get(email.ParentId).XC_LegalEntity__c !='EnelXMSP'){
                //Changes added as part of INC000044841392 - 19thJan'20- Additional filter condition for status
                if(email.Incoming && (caseToUpdate.get(email.ParentId).Status!= XC_AT_Constants.TRIGGER_STATUS_ESTA007 || caseToUpdate.get(email.ParentId).Status!= XC_AT_Constants.TRIGGER_STATUS_ESTA008 )){
                    caseToUpdate.get(email.ParentId).Status = XC_AT_Constants.TRIGGER_STATUS_ESTA001;
                    if(email.ToAddress.contains(';')){
                        for(String emailAdd : email.ToAddress.split(';')){
                            if(emailLegalEn.get(emailAdd.trim())!= null){
                                caseToUpdate.get(email.ParentId).XC_LegalEntity__c = emailLegalEn.get(emailAdd.trim());
                            }
                        }
                    }else{
                        caseToUpdate.get(email.ParentId).XC_LegalEntity__c = ( emailLegalEn.get(email.ToAddress) != null ) ? emailLegalEn.get(email.ToAddress) : caseToUpdate.get(email.ParentId).XC_LegalEntity__c;
                    }
                    caseToUpdate.put(caseToUpdate.get(email.ParentId).Id,manageCasebyEmail2CaseMetadata(caseToUpdate.get(email.ParentId),mapEmailRecevierCaseConfig,email));
                }else if(!email.Incoming){
                    /*Case c = new Case();
                    c.id = email.ParentId;*/
                    caseToUpdate.get(email.ParentId).Status = XC_AT_Constants.TRIGGER_STATUS_ESTA004;
                    //listCase.add(c);
                }//End of changes - INC000044841392
            }
        }

        if(!caseIds.isEmpty()){
            //XC_TR_Case_U_DefaultSettings.setCaseRecordType(caseToUpdate.values());
            XC_TR_Case_U_CheckCase.fillRecordType(caseToUpdate.values()); //20200114 - fix email2case B2B, + fix set RT - [MC]
            listCase.addAll(excludeMobilityQueues(caseToUpdate.values()));
        }

        if(!listCase.isEmpty()){
            XC_UTIL_Sobject.updateListRecords(listCase);
            XC_UTIL_Sobject.runAssignmentRules(listCase, 'Case');
        }
    }


    /**
    * @author Luisana Rocco - lrocco@deloitte.it
    * @description Method to get infos from EmailMessage
    * @param caseIds - Set of case Id
    * @param emailToAddress - Set of emailToAddress
    * @param emailMessList - List of EmailMessage
    */
    public static void getEmailInfos(Set<Id> caseIds, Set<String> emailToAddress, List<EmailMessage> emailMessList){
        //EXSFDCSL-488 - 20220718 - Baba Goudiaby - baba.goudiaby@webresults.it - Manage CcAddress email - Start
        List<String> emailList = new List<String>();
        for(EmailMessage emailMess : emailMessList){
            System.debug('Email Message: ' + emailMess);
            if(emailMess.ParentId != null /*&& emailMess.Incoming*/){
                caseIds.add(emailMess.ParentId);
                List<String> emailToAddressList = String.isBlank(emailMess.ToAddress) ? new List<String>() : emailMess.ToAddress.split('\\;');
                List<String> emailCcAddressList = String.isBlank(emailMess.CcAddress) ? new List<String>() : emailMess.CcAddress.split('\\;');
                emailList.addAll(emailToAddressList);
                emailList.addAll(emailCcAddressList);
                emailToAddress.addAll(emailList);
            }
        }
        //EXSFDCSL-488 - 20220718- Baba Goudiaby - baba.goudiaby@webresults.it - Manage CcAddress email - End
    }

    /**
     * @author Rui Teixeira - rui.pedroteixeira@everis.nttdata.com
     * @description Method to Update GeolocalizationCountry field on Cases
     * @param ListNew - List of EmailMessage
     * @return  
    */
    public static void updateGeolocalizationCountryCaseField(List<EmailMessage> listNew){
        List<XC_CS017_Contact_Center__c> lstContactCenter = XC_CS017_Contact_Center__c.getall().values();
        Map<String, String> mapEmailCountrys = new Map<String, String>();
        for(XC_CS017_Contact_Center__c ContactCenter : lstContactCenter){
            mapEmailCountrys.put(ContactCenter.XC_Email__c,ContactCenter.XC_Country__c);
        }

        Set<Id> caseIds = new Set<Id>();
        Set<String> emailToAddress = new Set<String>();
        getEmailInfos(caseIds, emailToAddress, listNew);

        Map<Id, Case> caseToUpdate = new Map<Id, Case>(); 
        Map<Id,XC_CM_CountryLegalEntityAssociation__mdt> associations; 
        Map<String,String> emailLegalEn = new Map<String,String>(); 


        if(!caseIds.isEmpty()){
            caseToUpdate = new Map<Id,Case> ([SELECT Origin,XC_GeolocalizationCountry__c,XC_LegalEntity__c,Status,Reason,SubCause__c,XC_Subtype__c,XC_Channel_Attribute__c, RecordTypeId, XC_Segment__c FROM Case WHERE Id IN: caseIds]);
        }


        List<Case> listCase= new List<Case>();
        if(!caseToUpdate.isEmpty()){
            for(EmailMessage email : listNew){
                if(email.ParentId != null && email.ToAddress != null && (caseToUpdate.get(email.ParentId).Origin == 'Email' || caseToUpdate.get(email.ParentId).Origin == 'CAN004')){
                    for (String emailAddress : emailToAddress) {
                        if(mapEmailCountrys.containsKey(emailAddress)){
                            caseToUpdate.get(email.ParentId).XC_GeolocalizationCountry__c = mapEmailCountrys.get(emailAddress);
                            break;
                        }
                    }
                }
            }
            if(!caseIds.isEmpty()){
                XC_TR_Case_U_CheckCase.fillRecordType(caseToUpdate.values());
                listCase.addAll(caseToUpdate.values());
            }
    
            if(!listCase.isEmpty()){
                XC_UTIL_Sobject.updateListRecords(listCase);
            }
        }
    }

    public static List<Case> excludeMobilityQueues(List<Case> casesList) {
        List<Case> filteredCases = new List<Case>();
        List<Group> mobilityQueues = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName IN ('XC_MSP_PostSalesBOMobility', 'XC_DE_PostSalesBOEXW', 'XC_FR_PostSalesBOEXW', 'XC_EN_PostSalesBOEXW', 'XC_ESP_PostSalesBOEXW', 'XC_RO_PostSalesBOEXW')];
        Set<Id> mobilityQueueIds = XC_UTIL_Sobject.getSetIds(mobilityQueues);
        for(Case c : casesList) {
            if(!mobilityQueueIds.contains(c.OwnerId)) {
                filteredCases.add(c);
            } 
        }
        return filteredCases;
    }
}