public class XC_TR_Account_UpdateZuoraAccount {
    
    public static void updateBillingAccount(Map<Id, Account> mapOld, Map<Id, Account> mapNew) {
        List<String> fieldList = new List<String>{'XC_DocumentCountry__c', 'IdentityNumber__c','IdentityType__c', 'XC_BillingAgency__c','XC_PlafondTechnical__c'};
        List<Account> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
		Date today = System.today();
        for(Account acc : listChanged) {
            if(acc.XC_Segment__c == 'B2B' || acc.XC_Segment__c == 'B2G') {
                callZuoraFromAccount(JSON.serialize(New List<Account>{acc}));
            }
            if(!Test.isRunningTest()){
                if(acc.XC_Segment__c == 'B2B' && acc.XC_Country__c == 'Italy' && acc.XC_AccountTaxType__c =='Esportatore Abituale' && 1 == today.day() && 1 == today.month() && null != mapOld.get(acc.Id).XC_Plafond__c && 0.0 != mapOld.get(acc.Id).XC_Plafond__c && 0.0 == mapNew.get(acc.Id).XC_Plafond__c ){
                    createSendInvoiceToCommodityLog(JSON.serialize(New List<Account>{acc}));
                }
            }
            
		}
    }
    
    
    public static void updateBillingAccount(Map<Id, XC_BillingProfileLineItem__c> mapOld, Map<Id, XC_BillingProfileLineItem__c> mapNew) {
        List<String> fieldList = new List<String>{'XC_OfficeCode__c', 'XC_RecipientCodeB2B__c','XC_PEC__c'};
        List<XC_BillingProfileLineItem__c> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
        if(listChanged.isEmpty()) {
            return;
        }   
        
        Map<Id, XC_BillingProfileLineItem__c> bpliMap =
            new Map<Id, XC_BillingProfileLineItem__c>([SELECT Id, XC_ZuoraId__c, XC_BillToContactId__c, XC_SoldToContactId__c, XC_BillToAddress__c, XC_BillingProfile__r.XC_Segment__c,
                                                        XC_SoldToAddress__c, XC_LegalEntity__c, XC_BillingProfile__r.NE__Account__c, XC_BillingProfile__r.NE__Account__r.Name,
                                                        XC_BillingProfile__r.NE__Account__r.RecordType.Name, XC_BillingProfile__r.NE__Account__r.XC_DocumentCountry__c,
                                                        XC_BillingProfile__r.NE__Account__r.IdentityNumber__c, XC_BillingProfile__r.NE__Account__r.IdentityType__c,XC_BillingProfile__r.NE__Account__r.XC_BillingAgency__r.Name,
                                                        XC_BillingProfile__r.NE__Account__r.XC_NIE_expiration_date__c, XC_BillingProfile__r.NE__Account__r.XC_NIE_expedition_date__c,
                                                        XC_BillingProfile__r.NE__Account__r.XC_BillingAgency__c,XC_Account__c,XC_PEC__c, XC_OfficeCode__c, XC_RecipientCodeB2B__c
                                                        FROM XC_BillingProfileLineItem__c
                                                        WHERE (XC_ZuoraId__c != null AND id in :XC_UTIL_SObject.getIds(listChanged))]);
        if(bpliMap.values().isEmpty()) {
            return;
        }       
		for(XC_BillingProfileLineItem__c bpli : bpliMap.values()) {
            if(bpli.XC_BillingProfile__r.XC_Segment__c == 'B2B' || bpli.XC_BillingProfile__r.XC_Segment__c == 'B2G') {
                callZuoraFromBPLI(JSON.serialize(New List<XC_BillingProfileLineItem__c>{bpli}));
            } 
		}
    }
 	
    @future(callout=true)
    public static void callZuoraFromAccount(String accounts) {
		List<Account> accList = (List<Account>) JSON.deserialize(accounts, List<Account>.class);
        Map<Id,Account> accMap = new Map<Id,Account>(accList);
		List<String> accountIdList = XC_UTIL_SObject.getIds(accList);        
        Map<Id, XC_BillingProfileLineItem__c> bpliMap =
            new Map<Id, XC_BillingProfileLineItem__c>([SELECT Id, XC_ZuoraId__c, XC_BillToContactId__c, XC_SoldToContactId__c, XC_BillToAddress__c, XC_BillingProfile__r.XC_Segment__c,
                                                        XC_SoldToAddress__c, XC_LegalEntity__c, XC_BillingProfile__r.NE__Account__c, XC_BillingProfile__r.NE__Account__r.Name,
                                                        XC_BillingProfile__r.NE__Account__r.RecordType.Name, XC_BillingProfile__r.NE__Account__r.XC_DocumentCountry__c,
                                                        XC_BillingProfile__r.NE__Account__r.IdentityNumber__c, XC_BillingProfile__r.NE__Account__r.IdentityType__c,
                                                        XC_BillingProfile__r.NE__Account__r.XC_NIE_expiration_date__c, XC_BillingProfile__r.NE__Account__r.XC_NIE_expedition_date__c,
                                                        XC_BillingProfile__r.NE__Account__r.XC_BillingAgency__c,XC_PEC__c, XC_OfficeCode__c, XC_RecipientCodeB2B__c,
                                                        XC_BillingProfile__r.NE__Account__r.XC_BillingAgency__r.Name
                                                        FROM XC_BillingProfileLineItem__c
                                                        WHERE (XC_ZuoraId__c != null AND XC_BillingProfile__r.NE__Account__c in :accountIdList)]);
        if(bpliMap.values().isEmpty()) {
            return;
        }

        String newAccountIdentityType = '';
        String newAccountIdentityNumber = '';
        String newAccountDocumentCountry = '';
        String newAccountDocumentReleaseDate = '';
        String newAccountDocumentExpirationDate = '';
              
        String orgId = UserInfo.getOrganizationId();
        Map<Id, XC_CM_LegalEntity_Configuration__mdt> legalInfoMap = new Map<Id, XC_CM_LegalEntity_Configuration__mdt>([SELECT Id, XC_LegalEntity__c, XC_Stream__c, XC_Country__c, XC_ValidDocuments__c FROM XC_CM_LegalEntity_Configuration__mdt WHERE XC_OrgId__c =: orgId]);
        Map<String, String> legalEntityDocuments = new Map<String, String>();
        for(XC_CM_LegalEntity_Configuration__mdt mdt : legalInfoMap.values()) {
            legalEntityDocuments.put(mdt.XC_LegalEntity__c+mdt.XC_Stream__c, mdt.XC_Country__c + '-' + mdt.XC_ValidDocuments__c);
        }

        Boolean check = true;
        List<XC_Integration_Log__c> integrationLogsToInsert = new List<XC_Integration_Log__c>();
        for(XC_BillingProfileLineItem__c bpli : bpliMap.values()) {
            Account acc = accMap.get(bpli.XC_BillingProfile__r.NE__Account__c);
            newAccountIdentityType = acc.IdentityType__c;
            newAccountIdentityNumber = acc.IdentityNumber__c;
            newAccountDocumentCountry = acc.XC_DocumentCountry__c;
            newAccountDocumentReleaseDate = String.valueOf(acc.XC_NIE_expedition_date__c);
            newAccountDocumentExpirationDate = String.valueOf(acc.XC_NIE_expiration_date__c);
        
            
            String country = '';
            List<String> validDocuments = new List<String>();
            if(String.isNotBlank(legalEntityDocuments.get(bpli.XC_LegalEntity__c+bpli.XC_BillingProfile__r.XC_Segment__c))) {
                country = legalEntityDocuments.get(bpli.XC_LegalEntity__c+bpli.XC_BillingProfile__r.XC_Segment__c).split('-')[0];
                validDocuments.addAll((legalEntityDocuments.get(bpli.XC_LegalEntity__c+bpli.XC_BillingProfile__r.XC_Segment__c).split('-')[1]).split(';'));
            }
            
           
            Map<String, String> parametersMap = new Map<String, String>{'zuoraAccountId' => bpli.XC_ZuoraId__c,
                                                                        'billToId' => bpli.XC_BillToContactId__c,
                                                                        'soldToId' => bpli.XC_SoldToContactId__c,
                                                                        'billAddrId' => bpli.XC_BillToAddress__c,
                                                                        'soldAddrId' => bpli.XC_SoldToAddress__c,
                                                                        'newAccountName' => bpli.XC_BillingProfile__r.NE__Account__r.Name,
                                                                        'legalEntity' => bpli.XC_LegalEntity__c,
                                                                        'newAccountIdentityType' => (country == newAccountDocumentCountry && validDocuments.contains(newAccountIdentityType) || true) ? newAccountIdentityType : '',
                                                                        'newAccountIdentityNumber' => (country == newAccountDocumentCountry && validDocuments.contains(newAccountIdentityType) || true) ? newAccountIdentityNumber : '',
                                                                        'newAccountDocumentCountry' => (country == newAccountDocumentCountry && validDocuments.contains(newAccountIdentityType) || true) ? newAccountDocumentCountry : '',
                                                                        'newAccountDocumentReleaseDate' => (country == newAccountDocumentCountry && validDocuments.contains(newAccountIdentityType) || true) ? newAccountDocumentReleaseDate : '',
                                                                        'newAccountDocumentExpirationDate' => (country == newAccountDocumentCountry && validDocuments.contains(newAccountIdentityType) || true) ? newAccountDocumentExpirationDate : '',
                                                                        'newRecipientCodeB2B' => bpli.XC_RecipientCodeB2B__c,
                                                                        'newOfficeCode' => bpli.XC_OfficeCode__c,
                                                                        'newBillingAgency' => bpli.XC_BillingProfile__r.NE__Account__r.XC_BillingAgency__r.Name,
                                                                        'newIsWhitelisted' => String.valueOf(bpli.XC_BillingProfile__r.NE__Account__r.XC_BillingAgency__r.Name != null),       
                                                                        'segment' => bpli.XC_BillingProfile__r.XC_Segment__c,
                                                                        'newPEC' => bpli.XC_PEC__c};

            //ZuoraWebService zws = new ZuoraWebService(XC_UTIL_Integration_U.getEntityName(bpli.XC_LegalEntity__c));
            ZuoraWebService zws = new ZuoraWebService(XC_UTIL_Integration_U.getEntityNameWithStream(bpli.XC_LegalEntity__c, bpli.XC_BillingProfile__r.XC_Segment__c));
            ZuoraWebService.CreateZuoraAccountResponse responseUpdateAccount = zws.updateZuoraAccount(parametersMap);
            if(responseUpdateAccount.success == 'false') {
                check = false;
            }

            if(responseUpdateAccount.integrationLog != null) {
                responseUpdateAccount.integrationLog.XC_BillingProfileLineItem__c = bpli.Id;
                responseUpdateAccount.integrationLog.XC_Log_AccountID__c = bpli.XC_BillingProfile__r.NE__Account__c;
                responseUpdateAccount.integrationLog.XC_Log_ClientSystem__c = 'XCustomer';
                responseUpdateAccount.integrationLog.XC_Log_ServerSystem__c = 'Zuora';
                integrationLogsToInsert.add(responseUpdateAccount.integrationLog);
            }
            
            bpli.XC_DocumentType__c = newAccountIdentityType;
            bpli.XC_DocumentNumber__c = newAccountIdentityNumber; 
            bpli.XC_DocumentCountry__c = newAccountDocumentCountry;
        }
        
		if(!integrationLogsToInsert.isEmpty()) {
			XC_UTIL_Sobject.insertListRecords(integrationLogsToInsert);
		}
       
        if(!bpliMap.values().isEmpty()) {
			XC_UTIL_Sobject.updateListRecords(bpliMap.values());
		}
       
    }
    
    
    @future(callout=true)
    public static void callZuoraFromBPLI(String bplis) {
        System.debug(bplis);
		List<XC_BillingProfileLineItem__c> bpliList = (List<XC_BillingProfileLineItem__c>) JSON.deserialize(bplis, List<XC_BillingProfileLineItem__c>.class);
             
        Map<Id, XC_BillingProfileLineItem__c> bpliMap = new Map<Id, XC_BillingProfileLineItem__c>(bpliList);
        if(bpliMap.values().isEmpty()) {
            return;
        }
        
		List<String> accountIdList = XC_UTIL_SObject.getListFieldValues(bpliList, 'XC_Account__c');   
        Map<Id,Account> accMap = new Map<Id,Account>([select id, IdentityType__c,
                                                             IdentityNumber__c,
                                                             XC_DocumentCountry__c,
                                                             XC_NIE_expedition_date__c,
                                                             XC_NIE_expiration_date__c 
                                                     from Account where id in :accountIdList]);
		
        String newAccountIdentityType = '';
        String newAccountIdentityNumber = '';
        String newAccountDocumentCountry = '';
        String newAccountDocumentReleaseDate = '';
        String newAccountDocumentExpirationDate = '';
        
        String orgId = UserInfo.getOrganizationId();
        Map<Id, XC_CM_LegalEntity_Configuration__mdt> legalInfoMap = new Map<Id, XC_CM_LegalEntity_Configuration__mdt>([SELECT Id, XC_LegalEntity__c, XC_Stream__c, XC_Country__c, XC_ValidDocuments__c FROM XC_CM_LegalEntity_Configuration__mdt WHERE XC_OrgId__c =: orgId]);
        Map<String, String> legalEntityDocuments = new Map<String, String>();
        for(XC_CM_LegalEntity_Configuration__mdt mdt : legalInfoMap.values()) {
            legalEntityDocuments.put(mdt.XC_LegalEntity__c+mdt.XC_Stream__c, mdt.XC_Country__c + '-' + mdt.XC_ValidDocuments__c);
        }

        Boolean check = true;
        List<XC_Integration_Log__c> integrationLogsToInsert = new List<XC_Integration_Log__c>();
        for(XC_BillingProfileLineItem__c bpli : bpliMap.values()) {
            Account acc = accMap.get(bpli.XC_Account__c);
            newAccountIdentityType = acc.IdentityType__c;
            newAccountIdentityNumber = acc.IdentityNumber__c;
            newAccountDocumentCountry = acc.XC_DocumentCountry__c;
            newAccountDocumentReleaseDate = String.valueOf(acc.XC_NIE_expedition_date__c);
            newAccountDocumentExpirationDate = String.valueOf(acc.XC_NIE_expiration_date__c);
        
            
            String country = '';
            List<String> validDocuments = new List<String>();
            if(String.isNotBlank(legalEntityDocuments.get(bpli.XC_LegalEntity__c+bpli.XC_BillingProfile__r.XC_Segment__c))) {
                country = legalEntityDocuments.get(bpli.XC_LegalEntity__c+bpli.XC_BillingProfile__r.XC_Segment__c).split('-')[0];
                validDocuments.addAll((legalEntityDocuments.get(bpli.XC_LegalEntity__c+bpli.XC_BillingProfile__r.XC_Segment__c).split('-')[1]).split(';'));
            }
            
			country = country == null ? newAccountDocumentCountry : country;
            
            Map<String, String> parametersMap = new Map<String, String>{'zuoraAccountId' => bpli.XC_ZuoraId__c,
                                                                        'billToId' => bpli.XC_BillToContactId__c,
                                                                        'soldToId' => bpli.XC_SoldToContactId__c,
                                                                        'billAddrId' => bpli.XC_BillToAddress__c,
                                                                        'soldAddrId' => bpli.XC_SoldToAddress__c,
                                                                        'newAccountName' => bpli.XC_BillingProfile__r.NE__Account__r.Name,
                                                                        'legalEntity' => bpli.XC_LegalEntity__c,
                                                                        'newAccountIdentityType' => (country == newAccountDocumentCountry && validDocuments.contains(newAccountIdentityType) || true) ? newAccountIdentityType : '',
                                                                        'newAccountIdentityNumber' => (country == newAccountDocumentCountry && validDocuments.contains(newAccountIdentityType) || true) ? newAccountIdentityNumber : '',
                                                                        'newAccountDocumentCountry' => (country == newAccountDocumentCountry && validDocuments.contains(newAccountIdentityType) || true) ? newAccountDocumentCountry : '',
                                                                        'newAccountDocumentReleaseDate' => (country == newAccountDocumentCountry && validDocuments.contains(newAccountIdentityType) || true) ? newAccountDocumentReleaseDate : '',
                                                                        'newAccountDocumentExpirationDate' => (country == newAccountDocumentCountry && validDocuments.contains(newAccountIdentityType) || true) ? newAccountDocumentExpirationDate : '',
                                                                        'newRecipientCodeB2B' => bpli.XC_RecipientCodeB2B__c,
                                                                        'newOfficeCode' => bpli.XC_OfficeCode__c,
                                                                        'newBillingAgency' => (bpli.XC_BillingProfile__r.NE__Account__r.XC_BillingAgency__c != null && bpli.XC_BillingProfile__r.NE__Account__r.XC_BillingAgency__r.Name != null)?bpli.XC_BillingProfile__r.NE__Account__r.XC_BillingAgency__r.Name:'',
                                                                        'segment' => bpli.XC_BillingProfile__r.XC_Segment__c,
                                                                        'newPEC' => bpli.XC_PEC__c};

            //ZuoraWebService zws = new ZuoraWebService(XC_UTIL_Integration_U.getEntityName(bpli.XC_LegalEntity__c));
            ZuoraWebService zws = new ZuoraWebService(XC_UTIL_Integration_U.getEntityNameWithStream(bpli.XC_LegalEntity__c, bpli.XC_BillingProfile__r.XC_Segment__c));
            ZuoraWebService.CreateZuoraAccountResponse responseUpdateAccount = zws.updateZuoraAccount(parametersMap);
            if(responseUpdateAccount.success == 'false') {
                check = false;
            }

            if(responseUpdateAccount.integrationLog != null) {
                responseUpdateAccount.integrationLog.XC_BillingProfileLineItem__c = bpli.Id;
                responseUpdateAccount.integrationLog.XC_Log_AccountID__c = bpli.XC_Account__c;
                responseUpdateAccount.integrationLog.XC_Log_ClientSystem__c = 'XCustomer';
                responseUpdateAccount.integrationLog.XC_Log_ServerSystem__c = 'Zuora';
                integrationLogsToInsert.add(responseUpdateAccount.integrationLog);
            }
        }
        
		if(!integrationLogsToInsert.isEmpty()) {
			XC_UTIL_Sobject.insertListRecords(integrationLogsToInsert);
		}
       
    }

    @future(callout=true)
    public static void createSendInvoiceToCommodityLog(String accounts){
        system.debug('mario createSendInvoiceToCommodityLog');
        List<Account> accList = (List<Account>) JSON.deserialize(accounts, List<Account>.class);
        Map<Id,Account> accMap = new Map<Id,Account>(accList);
        List<String> accountIdList = XC_UTIL_SObject.getIds(accList);        
        Map<Id, XC_BillingProfileLineItem__c> bpliMap =
            new Map<Id, XC_BillingProfileLineItem__c>([SELECT Id, XC_ZuoraId__c, XC_BillToContactId__c, XC_SoldToContactId__c, XC_BillToAddress__c, XC_BillingProfile__r.XC_Segment__c,
                                                        XC_SoldToAddress__c, XC_LegalEntity__c, XC_BillingProfile__r.NE__Account__c, XC_BillingProfile__r.NE__Account__r.Name,
                                                        XC_BillingProfile__r.NE__Account__r.RecordType.Name, XC_BillingProfile__r.NE__Account__r.XC_DocumentCountry__c,
                                                        XC_BillingProfile__r.NE__Account__r.IdentityNumber__c, XC_BillingProfile__r.NE__Account__r.IdentityType__c,
                                                        XC_BillingProfile__r.NE__Account__r.XC_NIE_expiration_date__c, XC_BillingProfile__r.NE__Account__r.XC_NIE_expedition_date__c,
                                                        XC_BillingProfile__r.NE__Account__r.XC_BillingAgency__c,XC_PEC__c, XC_OfficeCode__c, XC_RecipientCodeB2B__c,
                                                        XC_BillingProfile__r.NE__Account__r.XC_BillingAgency__r.Name
                                                        FROM XC_BillingProfileLineItem__c
                                                        WHERE (XC_ZuoraId__c != null AND XC_BillingProfile__r.NE__Account__c in :accountIdList)]);
        if(bpliMap.values().isEmpty()) {
            return;
        }
        for(XC_BillingProfileLineItem__c bpli : bpliMap.values()) {
            ZuoraWebservice zwbs = new ZuoraWebservice(XC_UTIL_Integration_U.getEntityNameWithStream(bpli.XC_LegalEntity__c,bpli.XC_BillingProfile__r.XC_Segment__c));
            zwbs.createSendInvoiceToCommodityLog(accounts);       
        }
    }
}