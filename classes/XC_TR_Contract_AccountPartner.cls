/**
     * @author Donato Lombardi - dolombardi@deloitte.it
     * @description Method to retrieve a Map of Work Order -> List skills requested
     * @param listNew - List WorkOrder
     * @return void
    **/
public with sharing class XC_TR_Contract_AccountPartner {
    public static void afterInsertManageContract(Map<Id,Contract> mapNew){

        Map<Id,Contract> mapFieldIsChange = new Map<Id,Contract>();
        mapFieldIsChange = checkFieldContractPartnerIsFilled(mapNew);
        if(mapFieldIsChange.isEmpty()){
            return;
        }
        Map<Id,Contract> mapIdContractB2BG = new Map<Id,Contract>();
        mapIdContractB2BG = checkStreamAndLegalEntity(mapFieldIsChange);
        if(mapIdContractB2BG.isEmpty()){
            return;
        }
        Map<Id,Contract> mapIdContractActive = new Map<Id,Contract>();
        mapIdContractActive = checkActiveDate(mapIdContractB2BG);
        if(mapIdContractActive.isEmpty()){
            return;
        }

        Map<Id,Account> mapIdAccountAndRelatedAcccount = new Map<Id,Account>();
        mapIdAccountAndRelatedAcccount = retrieveAccountAndRelatedContract(mapIdContractActive);
        Map<Id,String> checkMaterialAndService = new Map<Id,String>();
        Map<Id,String> checkOneMaterilAndOneService = new Map<Id,String>();
        Map<Id,String> checkAllSERVICE = new Map<Id,String>();
        Map<Id,String> checkAllMATERIAL = new Map<Id,String>();
        Map<Id,String> allAccountToUpdate = new Map<Id,String>();

        checkMaterialAndService = checkMaterialAndService(mapIdAccountAndRelatedAcccount);
        checkOneMaterilAndOneService = checkOneMaterilAndOneService(mapIdAccountAndRelatedAcccount);
        checkAllSERVICE = checkAllSERVICE(mapIdAccountAndRelatedAcccount);
        checkAllMATERIAL = checkAllMATERIAL(mapIdAccountAndRelatedAcccount);
        allAccountToUpdate.putAll(checkAllSERVICE);
        allAccountToUpdate.putAll(checkAllMATERIAL);
        allAccountToUpdate.putAll(checkOneMaterilAndOneService);
        allAccountToUpdate.putAll(checkMaterialAndService);
        updateAccount(mapIdAccountAndRelatedAcccount,allAccountToUpdate);






        }

    private static Map<Id,Contract> checkFieldContractPartnerIsFilled(Map<Id,Contract> mapNew){
        Map<Id,Contract> mapFiledIsChange = new Map<Id,Contract>();
        Set<String> setFieldSap = new Set<String>();
        setFieldSap.add('SERVICE');
        setFieldSap.add('MATERIAL');
        setFieldSap.add('MATERIAL AND SERVICE');
        for(Contract c : mapNew.values()){
            if(setFieldSap.contains(c.XC_ContractType__c)){
                mapFiledIsChange.put(c.id,c);
            }
        }
        return mapFiledIsChange;

    }

    private static Map<Id,Contract> checkStreamAndLegalEntity(Map<Id,Contract>mapNew){
        Set<String> setLeagEntities = new Set<String>();
        setLeagEntities.add('EnelXItalia');
        setLeagEntities.add('EnelXMobilityItalia');
        setLeagEntities.add('Cogenio');
        setLeagEntities.add('EnelSole');
        Set<String> setStream = new Set<String>();
        setStream.add('B2B');
        setStream.add('B2G');
        Map<Id,Contract> mapIdContractB2BG = new Map<Id,Contract>();
        for(Contract contra : mapNew.values()){
            if(setLeagEntities.contains(contra.XC_LegalEntity__c) && setStream.contains(contra.XC_Segment__c)){
                mapIdContractB2BG.put(contra.id,contra);
            }
        }
        return mapIdContractB2BG;

    }

    private static Map<Id,Contract> checkActiveDate(Map<Id,Contract> mapIdContractB2BG) {
        Map<Id, Contract> mapIdContractActive = new Map<Id, Contract>();
        for (Contract c : mapIdContractB2BG.values()) {
            if (c.StartDate <= Date.today() && c.EndDate >= Date.today()) {
                mapIdContractActive.put(c.id, c);
            }
        }
        return mapIdContractB2BG;

    }

    private static Map<Id,Account> retrieveAccountAndRelatedContract(Map<Id,Contract> mapIdContractActive){
        set<Id> setAccountIds = new Set<Id>();
        Map<Id,Contract> mapIdAccountAndRelatedContract = new Map<Id,Contract>();
        for(Contract c : mapIdContractActive.values()){
            setAccountIds.add(c.AccountId);
        }
        Map<Id,Account> mapIdAllCOntractAndAccount = new Map<Id,Account>([select id, (select id, AccountId, XC_ContractType__c from Contracts), XC_AccountType__c, recordType.developerName  from Account WHERE Id IN :setAccountIds AND recordType.developerName ='XC_Account_Partner']);

        return mapIdAllCOntractAndAccount;
    }



    private static Map<Id,String> checkMaterialAndService(Map<Id,Account> mapIdAccountAndRelatedContract){
        Map<Id,String> mapIdAccountAndAccountType = new Map<Id,String>();
        for(Account acc : mapIdAccountAndRelatedContract.values()){
            for(Contract c : acc.contracts ) {
                if (c.XC_ContractType__c == 'MATERIAL AND SERVICE') {
                    mapIdAccountAndAccountType.put(c.AccountId, 'Partner Supplier');
                }
            }
        }
        return mapIdAccountAndAccountType;
    }
    private static Map<Id,String> checkOneMaterilAndOneService(Map<Id,Account> mapIdAccountAndRelatedContract){
        Map<Id,String> mapIdAccountAndAccountTypeMATERIAL = new Map<Id,String>();
        Map<Id,String> mapIdAccountAndAccountTypeSERVICE = new Map<Id,String>();
        Map<Id,String> mapIdAccountAndAccountType = new Map<Id,String>();
        for(Account acc : mapIdAccountAndRelatedContract.values()) {
            for (Contract c : acc.contracts) {
                if (c.XC_ContractType__c == 'MATERIAL') {
                    mapIdAccountAndAccountTypeMATERIAL.put(c.AccountId, 'Partner Supplier');
                }
                if (c.XC_ContractType__c == 'SERVICE') {
                    mapIdAccountAndAccountTypeSERVICE.put(c.AccountId, 'Partner Supplier');
                }
            }
        }

        for(Id i : mapIdAccountAndAccountTypeMATERIAL.keySet()){
            if(mapIdAccountAndAccountTypeSERVICE.get(i)!= Null){
                mapIdAccountAndAccountType.put(i,mapIdAccountAndAccountType.get(i));
            }
        }
        return mapIdAccountAndAccountType;
    }

    private static Map<Id,String> checkAllSERVICE(Map<Id,Account> mapIdAccountAndRelatedContract){
        Map<Id,String> mapIdAccountAndAccountType = new Map<Id,String>();
        for(Account acc : mapIdAccountAndRelatedContract.values()) {
            for (Contract c : acc.contracts) {
                if (c.XC_ContractType__c != 'SERVICE') {
                    mapIdAccountAndAccountType.put(c.AccountId, 'KO');
                    break;
                }
                mapIdAccountAndAccountType.put(c.AccountId, 'Partner Account');
            }
        }
        return mapIdAccountAndAccountType;
    }

    private static Map<Id,String> checkAllMATERIAL(Map<Id,Account> mapIdAccountAndRelatedContract){
        Map<Id,String> mapIdAccountAndAccountType = new Map<Id,String>();
        for(Account acc : mapIdAccountAndRelatedContract.values()) {
            for (Contract c : acc.contracts) {
                if (c.XC_ContractType__c != 'MATERIAL') {
                    mapIdAccountAndAccountType.put(c.AccountId, 'KO');
                    break;
                }
                mapIdAccountAndAccountType.put(c.AccountId, 'Supplier');
            }
        }
        return mapIdAccountAndAccountType;
    }

    private static void updateAccount(Map<Id,Account> mapIdAccountAndRelatedAcccount,Map<Id,String> allAccountToUpdate){
        List<Account> listAccont = new List<Account>();
        for(Id idAcc :mapIdAccountAndRelatedAcccount.keySet()){
            if(allAccountToUpdate.get(idAcc)!= Null && allAccountToUpdate.get(idAcc) != 'KO'){
                mapIdAccountAndRelatedAcccount.get(idAcc).XC_AccountType__c = allAccountToUpdate.get(idAcc);
                listAccont.add(mapIdAccountAndRelatedAcccount.get(idAcc));
            }
        }       
        if(Schema.sObjectType.Account.isUpdateable()&& !listAccont.isEmpty()){
            Update listAccont;

        }

    }

    public static void afterUpdateManageContract(Map<Id,Contract> mapNew, Map<Id,Contract> mapOld){
        Map<Id,Contract> mapIdContractIsChange = new Map<Id,Contract>();
        mapIdContractIsChange = checkFieldContractPartnerIsFilledUpdate(mapNew,mapOld);
        System.debug('DL..mapIdContractIsChange '+mapIdContractIsChange);
        if(mapIdContractIsChange.isEmpty()){
            return;
        }
        Map<Id,Contract> mapIdContractB2BG = new Map<Id,Contract>();
        mapIdContractB2BG = checkStreamAndLegalEntity(mapIdContractIsChange);
        System.debug('DL..mapIdContractB2BG '+mapIdContractB2BG);
        if(mapIdContractB2BG.isEmpty()){
            return;
        }
        Map<Id,Contract> mapIdContractActive = new Map<Id,Contract>();
        mapIdContractActive = checkActiveDate(mapIdContractB2BG);
        System.debug('DL..mapIdContractActive '+mapIdContractActive);
        if(mapIdContractActive.isEmpty()){
            return;
        }

        Map<Id,Account> mapIdAccountAndRelatedAcccount = new Map<Id,Account>();
        mapIdAccountAndRelatedAcccount = retrieveAccountAndRelatedContract(mapIdContractActive);
        System.debug('DL..mapIdAccountAndRelatedAcccount '+mapIdAccountAndRelatedAcccount);
        Map<Id,String> checkMaterialAndService = new Map<Id,String>();
        Map<Id,String> checkOneMaterilAndOneService = new Map<Id,String>();
        Map<Id,String> checkAllSERVICE = new Map<Id,String>();
        Map<Id,String> checkAllMATERIAL = new Map<Id,String>();
        Map<Id,String> allAccountToUpdate = new Map<Id,String>();

        checkMaterialAndService = checkMaterialAndService(mapIdAccountAndRelatedAcccount);
        checkOneMaterilAndOneService = checkOneMaterilAndOneService(mapIdAccountAndRelatedAcccount);
        checkAllSERVICE = checkAllSERVICE(mapIdAccountAndRelatedAcccount);
        checkAllMATERIAL = checkAllMATERIAL(mapIdAccountAndRelatedAcccount);
        allAccountToUpdate.putAll(checkAllSERVICE);
        allAccountToUpdate.putAll(checkAllMATERIAL);
        allAccountToUpdate.putAll(checkOneMaterilAndOneService);
        allAccountToUpdate.putAll(checkMaterialAndService);
        updateAccount(mapIdAccountAndRelatedAcccount,allAccountToUpdate);
        System.debug('DL..allAccountToUpdate '+allAccountToUpdate);



    }

    private static Map<Id,Contract> checkFieldContractPartnerIsFilledUpdate(Map<Id,Contract> mapNew, Map<Id,Contract> mapOld){
        Map<Id,Contract> mapFiledIsChange = new Map<Id,Contract>();
        List<String> fieldList = new List<String>();
        fieldList.add('XC_ContractType__c');
        List<Contract> listContractChanged = new List<Contract>();
        listContractChanged = XC_UTIL_Sobject.getListChanged(fieldList,mapOld,mapNew);
        Set<String> setFieldSap = new Set<String>();
        setFieldSap.add('SERVICE');
        setFieldSap.add('MATERIAL');
        setFieldSap.add('MATERIAL AND SERVICE');
        for(Contract c : listContractChanged){
            if(setFieldSap.contains(c.XC_ContractType__c)){
                mapFiledIsChange.put(c.id,c);
            }
        }
        return mapFiledIsChange;

    }




}