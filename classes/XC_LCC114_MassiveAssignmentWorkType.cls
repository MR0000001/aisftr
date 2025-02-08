/*
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 24/09/2020
* @description XC_LCC114_MassiveAssignmentWorkType – Apex Controller for component XC_LCP114_MassiveAssignmentWorkType
* @history
* Modified by Nicolo' Fodera, Lorenzo Evangelisti, Baba Goudiaby on 07.2022 - Refactoring 
*/

public without sharing class XC_LCC114_MassiveAssignmentWorkType {
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC114_MassiveAssignmentWorkType');
    private final static Integer limitRecordOperationAdd = Integer.valueOf(Label.XC_CL_MassiveWT_LimitRecordOperationAdd); // NicoloFodera 20220715 Changed
    private final static Integer batchScopeOperationAdd = 200;
    private final static Integer limitRecordOperationRemove = Integer.valueOf(Label.XC_CL_MassiveWT_LimitRecordOperationRemove); // NicoloFodera 20220715 Changed
    private final static Integer batchScopeOperationRemove = 200;
    private final static Integer limitRecordOperationTransfer = Integer.valueOf(Label.XC_CL_MassiveWT_LimitRecordOperationTransfer); // NicoloFodera 20220715 Changed
    private final static Integer batchScopeOperationTransfer = 200;

    /** @description OutputWrapper */
    public class OutputWrapper {
        @AuraEnabled
        public String accountName = '';
        @AuraEnabled
        public String country = '';
        @AuraEnabled
        public List<WorkType> listWorkType = new List<WorkType>();
        @AuraEnabled
        public Boolean success = true;
        @AuraEnabled
        public String message = '';
        @AuraEnabled
        public List<Map<String,String>> listProvinces = new List<Map<String,String>>();
        @AuraEnabled
        public Map<String, List<Map<String, String>>> mapProvinceListZipcode = new Map<String, List<Map<String, String>>>();
        @AuraEnabled
        public String quantityRowForOperation = '';
        @AuraEnabled
        public Boolean applyInitialFilter = false;
        @AuraEnabled
        public List<XC_PartnerCoverage__c> listPartnerCoverage = new List<XC_PartnerCoverage__c>();
        @AuraEnabled
        public String destinationPartnerName = '';
        @AuraEnabled
        public List<String> listZipCodes = new List<String>();
        @AuraEnabled
        public Boolean isAdmin = false;
        @AuraEnabled
        public String statusLogId = ''; /*LorenzoEvangelisti lorenzo.evangelisti@webresults.it 20220530 - EXSFDCSL-290 extend max limit*/ 
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 23/11/2020
    * @description CSVWrapper - Util Wrapper for CSV
    */ 
    public class UtilCSVWrapper {
        @AuraEnabled
        public List<XC_PartnerCoverage__c> listPcToReturn = new List<XC_PartnerCoverage__c>();
        @AuraEnabled
        public Map<String, String> mapNameIdWorkType = new Map<String, String>();
        @AuraEnabled
        public Boolean success = true;
        @AuraEnabled
        public String partnerName = '';
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 23/11/2020
    * @description UploadWrapper - Wrapper to import Excel
    */ 
    public class UploadWrapper {
        @AuraEnabled
        public String WorkTypeName = '';
        @AuraEnabled
        public String PostalCode = '';
    }

    /**
    * @author Lorenzo Evangelisti - lorenzo.evangelisti@webresults.it
    * @date Creation 31/05/2022
    * @description LogsWrapper 
    */ 
    public class LogsWrapper {
        @AuraEnabled
        public Boolean success = false;     
        @AuraEnabled
        public List<ListView> listViews = new List<ListView>(); 
        @AuraEnabled
        public String resultMessage {get; set;}      
        @AuraEnabled
        public Boolean dirtyData = false;
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date Creation 03/11/2020
     * @description Method to get User information
     * @return String - "isPartner" + "PartnerId"
    */ 
    @AuraEnabled 
    public static String getUserInformation() {
        String result = '';
        List<User> listUser = new List<User>([
            SELECT Id, AccountId, Account.IsPartner, XC_LegalEntity__c 
            FROM User 
            WHERE Id = :UserInfo.getUserId()
        ]);
        Map<String, Object> mapUser = listUser[0].getPopulatedFieldsAsMap();
        if(mapUser.containsKey('AccountId') && listUser[0].Account.IsPartner) {
            result = 'partner_' + listUser[0].AccountId;
        } else {
            result ='notPartner_empty';
        }
        result = result + '_' + listUser[0].XC_LegalEntity__c;
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ User information: ' + result);
        return result;
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date Creation 25/09/2020
     * @description Method to get informations for Add Operation
     * @param accountId - String
     * @return OutputWrapper
    */ 
    @AuraEnabled 
    public static OutputWrapper initAddOperation(String accountId) {
        OutputWrapper resultWrapper = new OutputWrapper();
        // Populate country and worktype:
        List<User> listUser = new List<User>([
            SELECT Id, Country__c, XC_LegalEntity__c, Profile.Name
            FROM User 
            WHERE Id = :UserInfo.getUserId()
        ]);
        resultWrapper.country = listUser[0].Country__c;
        resultWrapper.listWorkType = new List<WorkType>([
            SELECT Id, Name, XC_Segment__c
            FROM WorkType 
            WHERE XC_LegalEntity__c = :listUser[0].XC_LegalEntity__c
            ORDER BY Name
        ]);  
        List<Account> listAccount = new List<Account>([
            SELECT Id, Name
            FROM Account
            WHERE Id = :accountId
        ]);
        resultWrapper.accountName = listAccount[0].Name;

        // Populate Province/Zipcode:
        List<StaticResource> listStaticResource = new List<StaticResource>([
            SELECT Id, SystemModStamp, Name
            FROM StaticResource 
            WHERE Name IN :new List<String>{'XC_STR002_MapCountryProvinces','XC_STR003_'+resultWrapper.country+'MapProvinceZipCodes'}
        ]);
        Map<String, StaticResource> mapSr = new Map<String, StaticResource>();
        for(StaticResource sr : listStaticResource) {
            mapSr.put(sr.Name.toUpperCase(), sr);
        }
        // Load Map for Countr -> Province:
        String urlCountryProvince = '/resource/'
                                    + String.valueOf(((DateTime)mapSr.get('XC_STR002_MapCountryProvinces'.toUpperCase()).get('SystemModStamp')).getTime())
                                    + '/' 
                                    + mapSr.get('XC_STR002_MapCountryProvinces'.toUpperCase()).get('Name');
        PageReference fileCountryProvince = new PageReference(urlCountryProvince);
        String jsonMapCountryProvince = '';
        if(!Test.isRunningTest()) {
            jsonMapCountryProvince = fileCountryProvince.getContent().toString();
        } else {
            jsonMapCountryProvince = '{"SPAIN": {"resourceNameMap": "XC_STR003_SpainMapProvinceZipCodes","listProvinces": ["Madrid"],"mapNameCode": {"Madrid": "M"}},"ITALY": {"resourceNameMap": "XC_STR003_SpainMapProvinceZipCodes","listProvinces": ["Madrid"],"mapNameCode": {"Madrid": "M"}}}';
        }
        Map<String, Object> mapProvinceForCountry = (Map<String, Object>) JSON.deserializeUntyped(jsonMapCountryProvince);
        Map<String, Object> mapForCurrentCountry = (Map<String, Object>) mapProvinceForCountry.get(resultWrapper.country.toUpperCase());
        List<Object> listObj = (List<Object>) mapForCurrentCountry.get('listProvinces');
        for(Object obj : listObj) {
            resultWrapper.listProvinces.add(new Map<String, String>{
                'Id' => (String) obj,
                'value' => (String) obj
            });
        }
        Map<String, Object> mapProvinceCodeTemp = (Map<String, Object>) mapForCurrentCountry.get('mapNameCode');
        Map<String, String> mapProvinceCode = new Map<String, String>();
        for(String key : mapProvinceCodeTemp.keySet()) {
            mapProvinceCode.put((String) mapProvinceCodeTemp.get(key), key);
        }

        // Load Map for Country -> Province:
        String urlProvinceZipcode = '/resource/'
                                    + String.valueOf(((DateTime)mapSr.get(('XC_STR003_'+resultWrapper.country+'MapProvinceZipCodes').toUpperCase()).get('SystemModStamp')).getTime())
                                    + '/' 
                                    + mapSr.get(('XC_STR003_'+resultWrapper.country+'MapProvinceZipCodes').toUpperCase()).get('Name');
        PageReference fileProvinceZipCode = new PageReference(urlProvinceZipcode);
        String jsonMapProvinceZipcode = '';
        if(!Test.isRunningTest()) {
            jsonMapProvinceZipcode = fileProvinceZipCode.getContent().toString();
        } else {
            jsonMapProvinceZipcode = '{"M": ["00000", "00001", "00002"]}';
        }
        Map<String, Object> mapZipcodeTemp = (Map<String, Object>) JSON.deserializeUntyped(jsonMapProvinceZipcode);
        Map<String, List<String>> mapProvinceListZipcodeTemp = new Map<String, List<String>>();
        for(String key : mapZipcodeTemp.keySet()) {
            if(!mapProvinceCode.containsKey(key)) {
                continue;
            }
            for(Object obj : (List<Object>) mapZipcodeTemp.get(key)) {
                if(!mapProvinceListZipcodeTemp.containsKey(mapProvinceCode.get(key))) {
                    mapProvinceListZipcodeTemp.put(mapProvinceCode.get(key), new List<String>());
                }
                mapProvinceListZipcodeTemp.get(mapProvinceCode.get(key)).add((String) obj);
            }
        }
        for(String key : mapProvinceListZipcodeTemp.keySet()) {
            List<Map<String, String>> listMapValues = new List<Map<String, String>>();
            for(String value : mapProvinceListZipcodeTemp.get(key)) {
                listMapValues.add(new Map<String, String>{
                    'Id' => value,
                    'value' => value
                });
            }
            resultWrapper.mapProvinceListZipcode.put(key, listMapValues);
        }
        resultWrapper.isAdmin = listUser[0].Profile.Name == 'System Administrator';
        return resultWrapper;
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date Creation 25/09/2020
     * @description Method to insert Partner Coverage from component
     * @param listCombo - List<Object> (List of WorkType/ZipCode)
     * @param accountId - String
     * @return OutputWrapper
    */ 
    @AuraEnabled 
    public static OutputWrapper addOperation(List<Object> listCombo, String accountId) {
        OutputWrapper resultWrapper = new OutputWrapper();
        if(listCombo.size() > limitRecordOperationAdd) {
            resultWrapper.success = false;
            resultWrapper.message = '[Add] ' + String.format(Label.XC_CL_ErrorAdd, new List<String>{String.valueOf(limitRecordOperationAdd)});
            return resultWrapper;
        }
        //Savepoint savePoint = Database.setSavepoint(); 
        XC_MassiveAssignWorkTypeOperationStatus__c statusLog = new XC_MassiveAssignWorkTypeOperationStatus__c(); /*LorenzoEvangelisti lorenzo.evangelisti@webresults.it 20220530 - EXSFDCSL-290 extend max limit*/ 
        try {
            List<User> listUser = new List<User>([
                SELECT Id, XC_EnabledToSkip__c, Name, XC_LegalEntity__c, Profile.Name 
                FROM User 
                WHERE Id = :UserInfo.getUserId() and IsActive = true
            ]);
            resultWrapper.isAdmin = listUser[0].Profile.Name == 'System Administrator';
            if(listUser[0].XC_EnabledToSkip__c) {
                resultWrapper.success = false;
                resultWrapper.message = String.format(Label.XC_CL_MessageErrorAdd, new List<String>{listUser[0].Name});
                return resultWrapper;
            }

            /*LorenzoEvangelisti lorenzo.evangelisti@webresults.it 20220530 - EXSFDCSL-290 extend max limit [start] */
            /*BabaGoudiaby Added 20220708 - EXSFDCSL-290 Modularize status log creation */
            statusLog = XC_LCC114_MassiveAssignmentWorkType_U.initStatusLog('Add', 'Processing',accountId,null, listCombo.size());
            System.enqueueJob(new XC_LCC114_MassiveAssignmentWorkType_U.XC_Queueable_AddPartnerCoveragesAndSRCoverages(listCombo, accountId, listUser[0].XC_LegalEntity__c, batchScopeOperationAdd, statusLog.Id));
            resultWrapper.success = true; 
            resultWrapper.statusLogId = statusLog.Id; 
            /*LorenzoEvangelisti lorenzo.evangelisti@webresults.it 20220530 - EXSFDCSL-290 extend max limit [end] */ 
            
            return resultWrapper;
        } catch(Exception e) {
            //Database.rollback(savePoint);
            resultWrapper.success = false;
            resultWrapper.message = e.getMessage();
            if(statusLog.id != null){
                     XC_LCC114_MassiveAssignmentWorkType_U.saveStatusLogException(statusLog, e); //NicoloFodera 20220715 Added
            }
            return resultWrapper;
        }
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date Creation 30/09/2020
     * @description Method to get Partner Coverages from account id
     * @param accountId - String
     * @param cutoff - Integer
     * @param listZipCodeSelected - List<String>
     * @param listWorkTypeSelected - List<String>
     * @return OutputWrapper
    */ 
    @AuraEnabled 
    public static OutputWrapper getPartnerCoverage(String accountId, /*Integer cutoff //NicoloFodera 20220715 Changed*/ String typeOfOperation, List<String> listZipCodeSelected, List<String> listWorkTypeSelected) { 
        OutputWrapper result = new OutputWrapper();
        List<User> listUser = new List<User>([
                SELECT Id, Country__c, XC_LegalEntity__c, Profile.Name
                FROM User 
                WHERE Id = :UserInfo.getUserId()
            ]);
        result.isAdmin = listUser[0].Profile.Name == 'System Administrator';
        List<Account> listAccount = new List<Account>([
            SELECT Id, Name, XC_Country__c
            FROM Account
            WHERE Id = :accountId
        ]);
        result.accountName = listAccount[0].Name;
        result.country = listAccount[0].XC_Country__c;

        List<AggregateResult> listAggrResult = new List<AggregateResult>();
        if(listZipCodeSelected.isEmpty() && listWorkTypeSelected.isEmpty()) {
            listAggrResult = new List<AggregateResult>([
                SELECT COUNT(Id) CountCoverage
                FROM XC_PartnerCoverage__c
                WHERE XC_Account__c = :accountId
            ]);
        } else {
            listAggrResult = new List<AggregateResult>([
                SELECT COUNT(Id) CountCoverage
                FROM XC_PartnerCoverage__c
                WHERE XC_Account__c = :accountId AND XC_WorkType__r.Name IN :listWorkTypeSelected AND  XC_ZipCode__c IN :listZipCodeSelected
            ]);
        }
        Integer cutoff = typeOfOperation == 'Remove' ? limitRecordOperationRemove : limitRecordOperationTransfer; //NicoloFodera 20220715 Added*/
        if(Test.isRunningTest() && typeOfOperation == 'Remove'){
            cutoff = 1;
        }
        if(((Integer) listAggrResult[0].get('CountCoverage')) > cutoff) {
            result.success = false;
            result.message = String.format(Label.XC_CL_MessageErrorTransfer, new List<String>{String.valueOf(cutoff), result.accountName, String.valueOf(listAggrResult[0].get('CountCoverage'))});
            result.applyInitialFilter = true;

            // For WorkType:
            //@Baba Goudiaby - baba.goudiaby@webresults.it -20220706 avoid Too many query rows: 50001 exception - Added COUNT(Id)
            List<AggregateResult> listAggrWorkType = new List<AggregateResult>([
                SELECT XC_WorkType__c WorkType, COUNT(Id) 
                FROM XC_PartnerCoverage__c
                WHERE XC_Account__c = :accountId
                GROUP BY XC_WorkType__c
            ]);
            List<WorkType> listWorkType = new List<WorkType>([
                SELECT Id, Name, XC_Segment__c
                FROM WorkType 
                WHERE XC_LegalEntity__c = :listUser[0].XC_LegalEntity__c
                ORDER BY Name
            ]);  
            Map<String, WorkType> mapWorkType = new Map<String, WorkType>();
            for(WorkType wt : listWorkType) {
                mapWorkType.put(wt.Id, wt);
            }
            for(AggregateResult ar : listAggrWorkType) {
                String workTypeId = (String) ar.get('WorkType');
                Boolean existingWorkType = mapWorkType.containsKey(workTypeId);
                if(existingWorkType && String.isNotBlank(mapWorkType.get(workTypeId).Name) && String.isNotBlank(mapWorkType.get(workTypeId).XC_Segment__c)) {
                    result.listWorkType.add(
                        new WorkType(
                            Id = workTypeId,
                            Name = mapWorkType.get(workTypeId).Name,
                            XC_Segment__c = mapWorkType.get(workTypeId).XC_Segment__c
                        )
                    );
                }
            }
            
            // Transazione spezzata per rispettare i limiti di Salesforce: ritorno al component e chiamata a getPartnerCoveragePart2
            return result;
        } 
        else {
            if(!listWorkTypeSelected.isEmpty() || !listZipCodeSelected.isEmpty()) {
                result.listPartnerCoverage = new List<XC_PartnerCoverage__c>([
                    SELECT Id, XC_WorkType__r.XC_Segment__c, XC_WorkType__r.Id, XC_WorkType__r.Name, XC_Account__c, XC_ZipCode__c, XC_WorkType__c, XC_ZipCodeWorkType__c, XC_WorkTypeName__c, XC_ExternalId__c, XC_ExternalIdForDuplication__c, XC_WorkTypeLabel__c
                    FROM XC_PartnerCoverage__c 
                    WHERE XC_Account__c = :accountId AND XC_WorkType__r.Name IN :listWorkTypeSelected AND  XC_ZipCode__c IN :listZipCodeSelected AND XC_WorkType__r.XC_LegalEntity__c = :listUser[0].XC_LegalEntity__c
                    ORDER BY XC_WorkType__r.Name
                ]);
            } else {
                result.listPartnerCoverage = new List<XC_PartnerCoverage__c>([
                    SELECT Id, XC_WorkType__r.XC_Segment__c, XC_WorkType__r.Id, XC_WorkType__r.Name, XC_Account__c, XC_ZipCode__c, XC_WorkType__c, XC_ZipCodeWorkType__c, XC_WorkTypeName__c, XC_ExternalId__c, XC_ExternalIdForDuplication__c, XC_WorkTypeLabel__c
                    FROM XC_PartnerCoverage__c 
                    WHERE XC_Account__c = :accountId AND XC_WorkType__r.XC_LegalEntity__c = :listUser[0].XC_LegalEntity__c
                    ORDER BY XC_WorkType__r.Name
                ]);
            }

            if(result.listPartnerCoverage.isEmpty()) {
                result.success = false;
                result.message = Label.XC_CL_MessageErrorNoPC + ' ' + result.accountName;
            }

            List<String> listWorkTypeInList = new List<String>();
            for(XC_PartnerCoverage__c pc : result.listPartnerCoverage) {
                if(!listWorkTypeInList.contains(pc.XC_WorkType__r.Name)) {
                    result.listWorkType.add(new WorkType(
                        Id = pc.XC_WorkType__r.Id,
                        Name = pc.XC_WorkType__r.Name,
                        XC_Segment__c = pc.XC_WorkType__r.XC_Segment__c
                    ));
                    listWorkTypeInList.add(pc.XC_WorkType__r.Name);
                }
            }
        }
        return result;
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date Creation 14/01/2021
     * @description Method to get Partner Coverage (part 2)
     * @param resultPart2 - String
     * @param accountId - String
     * @return OutputWrapper
    */ 
    @AuraEnabled
    public static OutputWrapper getPartnerCoveragePart2(String accountId, String resultPart2Temp) {
        OutputWrapper resultPart2 = (OutputWrapper) JSON.deserialize(resultPart2Temp, OutputWrapper.class);

        // For Province/Zipcode:
        //@Baba Goudiaby - baba.goudiaby@webresults.it -20220706 avoid Too many query rows: 50001 exception - Added COUNT(Id)
        List<AggregateResult> listAggrZipCode = new List<AggregateResult>([
            SELECT XC_ZipCode__c ZipCode, COUNT(Id)
            FROM XC_PartnerCoverage__c 
            WHERE XC_Account__c = :accountId 
            GROUP BY XC_ZipCode__c 
        ]);
        resultPart2.listZipCodes = XC_UTIL_Sobject.getListFieldValues(listAggrZipCode, 'ZipCode');


        // Populate Province/Zipcode:
        List<StaticResource> listStaticResource = new List<StaticResource>([
            SELECT Id, SystemModStamp, Name
            FROM StaticResource 
            WHERE Name IN :new List<String>{'XC_STR002_MapCountryProvinces','XC_STR003_'+resultPart2.country+'MapProvinceZipCodes'}
        ]);
        Map<String, StaticResource> mapSr = new Map<String, StaticResource>();
        for(StaticResource sr : listStaticResource) {
            mapSr.put(sr.Name.toUpperCase(), sr);
        }
        
        String urlCountryProvince = '/resource/'
                                    + String.valueOf(((DateTime)mapSr.get('XC_STR002_MapCountryProvinces'.toUpperCase()).get('SystemModStamp')).getTime())
                                    + '/' 
                                    + mapSr.get('XC_STR002_MapCountryProvinces'.toUpperCase()).get('Name');
        PageReference fileCountryProvince = new PageReference(urlCountryProvince);
        String jsonMapCountryProvince = '';
        if(!Test.isRunningTest()) {
            jsonMapCountryProvince = fileCountryProvince.getContent().toString();
        } else {
            jsonMapCountryProvince = '{"SPAIN": {"resourceNameMap": "XC_STR003_SpainMapProvinceZipCodes","listProvinces": ["Madrid"],"mapNameCode": {"Madrid": "M"}},"ITALY": {"resourceNameMap": "XC_STR003_SpainMapProvinceZipCodes","listProvinces": ["Madrid"],"mapNameCode": {"Madrid": "M"}}}';
        }
        Map<String, Object> mapProvinceForCountry = (Map<String, Object>) JSON.deserializeUntyped(jsonMapCountryProvince);
        Map<String, Object> mapForCurrentCountry = (Map<String, Object>) mapProvinceForCountry.get(resultPart2.country.toUpperCase());
        Map<String, Object> mapProvinceCodeTemp = (Map<String, Object>) mapForCurrentCountry.get('mapNameCode');
        Map<String, String> mapCodeProvince = new Map<String, String>();
        for(String key : mapProvinceCodeTemp.keySet()) {
            mapCodeProvince.put((String) mapProvinceCodeTemp.get(key), key);
        }
        String urlProvinceZipcode = '/resource/'
                                    + String.valueOf(((DateTime)mapSr.get(('XC_STR003_'+resultPart2.country+'MapProvinceZipCodes').toUpperCase()).get('SystemModStamp')).getTime())
                                    + '/' 
                                    + mapSr.get(('XC_STR003_'+resultPart2.country+'MapProvinceZipCodes').toUpperCase()).get('Name');
        PageReference fileProvinceZipCode = new PageReference(urlProvinceZipcode);
        String jsonMapProvinceZipcode = '';
        if(!Test.isRunningTest()) {
            jsonMapProvinceZipcode = fileProvinceZipCode.getContent().toString();
        } else {
            jsonMapProvinceZipcode = '{"M": ["00000", "00001", "00002"]}';
        }
        Map<String, Object> mapZipcodeTemp = (Map<String, Object>) JSON.deserializeUntyped(jsonMapProvinceZipcode);
        Map<String, List<String>> mapProvinceListZipcodeTemp = new Map<String, List<String>>();
        for(String key : mapZipcodeTemp.keySet()) {
            if(!mapCodeProvince.containsKey(key)) {
                continue;
            }
            for(Object obj : (List<Object>) mapZipcodeTemp.get(key)) {
                if(resultPart2.listZipCodes.contains((String) obj)) { 
                    if(!mapProvinceListZipcodeTemp.containsKey(mapCodeProvince.get(key))) {
                        mapProvinceListZipcodeTemp.put(mapCodeProvince.get(key), new List<String>());
                    }
                    mapProvinceListZipcodeTemp.get(mapCodeProvince.get(key)).add((String) obj);
                }
            }
        }
        for(String key : mapProvinceListZipcodeTemp.keySet()) {
            List<Map<String, String>> listMapValues = new List<Map<String, String>>();
            for(String value : mapProvinceListZipcodeTemp.get(key)) {
                listMapValues.add(new Map<String, String>{
                    'Id' => value,
                    'value' => value
                });
            }
            resultPart2.mapProvinceListZipcode.put(key, listMapValues);
            resultPart2.listProvinces.add(new Map<String, String>{
                'Id' => key,
                'value' => key
            });
        }
        resultPart2.success = true;
        return resultPart2;
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date Creation 02/01/2020
     * @description Method to remove/transfer Partner Coverage from component
     * @param listCoverages - List<XC_PartnerCoverage__c> 
     * @param accountId - String
     * @param destinationPartner - String
     * @param typeOfOperation - String
     * @return OutputWrapper
    */ 
    @AuraEnabled 
    public static OutputWrapper otherOperation(List<Id> setCoverageIds, String accountId, String destinationPartner, String typeOfOperation) {
        OutputWrapper result = new OutputWrapper();
        //Savepoint savePoint = Database.setSavepoint(); // NicoloFodera Removed 20220707 - EXSFDCSL-290 extend max limit
        XC_MassiveAssignWorkTypeOperationStatus__c statusLog = new XC_MassiveAssignWorkTypeOperationStatus__c();  //NicoloFodera Added 20220707 - EXSFDCSL-290 extend max limit
        List<XC_PartnerCoverage__c> listCoverages = new List<XC_PartnerCoverage__c>();
       
        try {
            List<User> listUser = new List<User>([
                SELECT Id, XC_EnabledToSkip__c,XC_LegalEntity__c, Name 
                FROM User 
                WHERE Id = :UserInfo.getUserId() and IsActive = true
            ]);
            if(listUser[0].XC_EnabledToSkip__c) {
                result.success = false;
                result.message = String.format(Label.XC_CL_MessageErrorAdd, new List<String>{listUser[0].Name});
                return result;
            }
            
            if(typeOfOperation == 'Remove') {
                if(setCoverageIds.size() > limitRecordOperationRemove) {
                    result.success = false;
                    result.message = '[Remove] ' + String.format(Label.XC_CL_ErrorAdd, new List<String>{String.valueOf(limitRecordOperationRemove)});
                    return result;
                }
                /*NicoloFodera Added 20220707 - EXSFDCSL-290 extend max limit  [start]*/
                /*BabaGoudiaby Added 20220708 - EXSFDCSL-290 Modularize status log creation */
                statusLog = XC_LCC114_MassiveAssignmentWorkType_U.initStatusLog('Remove', 'Processing',accountId, null, setCoverageIds.size());
                System.enqueueJob(new XC_LCC114_MassiveAssignmentWorkType_U.XC_Queueable_RemovePartnerCoveragesAndSRCoverages(new Set<Id>(setCoverageIds), accountId, listUser[0].XC_LegalEntity__c, batchScopeOperationRemove, statusLog.Id));
                result.success = true; 
                result.statusLogId = statusLog.Id; 
                /*NicoloFodera Added 20220707 - EXSFDCSL-290 extend max limit  [end]*/

            }
            else if(typeOfOperation == 'Transfer') {
                if(setCoverageIds.size() > limitRecordOperationTransfer) {
                    result.success = false;
                    result.message = 'F ' + String.format(Label.XC_CL_ErrorAdd, new List<String>{String.valueOf(limitRecordOperationTransfer)});
                    return result;
                }
                /*NicoloFodera Added 20220707 - EXSFDCSL-290 extend max limit  [start]*/
                /*BabaGoudiaby Added 20220708 - EXSFDCSL-290 Modularize status log creation */
                statusLog = XC_LCC114_MassiveAssignmentWorkType_U.initStatusLog('Transfer', 'Processing', accountId, destinationPartner, setCoverageIds.size()); //!!! NicoloFodera aggiungere campo destination partner su status log
                System.enqueueJob(new XC_LCC114_MassiveAssignmentWorkType_U.XC_Queueable_TransferPartnerCoveragesAndSRCoverages(new Set<Id>(setCoverageIds), accountId, destinationPartner,  listUser[0].XC_LegalEntity__c, batchScopeOperationTransfer, statusLog.Id));
                result.success = true; 
                result.statusLogId = statusLog.Id;
            }
            return result;
        } catch(Exception e) {
            //Database.rollback(savePoint); NicoloFodera Removed 20220707 - EXSFDCSL-290 extend max limit
            result.success = false;
            result.message = e.getMessage();
            /*NicoloFodera Added 20220707 - EXSFDCSL-290 extend max limit [start]*/
            if(statusLog.id != null){ 
                    XC_LCC114_MassiveAssignmentWorkType_U.saveStatusLogException(statusLog, e); //NicoloFodera 20220715 Added
            }
            /*NicoloFodera Added 20220707 - EXSFDCSL-290 extend max limit [end]*/ 
            return result;
        }
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date Creation 03/02/2021
     * @description Method to upload coverage from CSV
     * @param strfromlex - String
     * @param accountId - String
     * @param legalEntity - String
     * @param cleanArrayExcel - Boolean
     * @return UtilCSVWrapper
    */
    @AuraEnabled
    public static UtilCSVWrapper uploadFileCsvOtherOperation(String strfromlex, String accountId, String legalEntity, Boolean cleanArrayExcel) {
        UtilCSVWrapper wr = new UtilCSVWrapper();
        List<UploadWrapper> dataList = (List<UploadWrapper>) JSON.deserialize(strfromlex, List<UploadWrapper>.class);
        List<String> listWorkTypeName = new List<String>();
        List<String> listPostalCode = new List<String>();
        Set<String> listKey = new Set<String>();
        Set<String> listDuplicateKey = new Set<String>(); // NicoloFodera 20220715 Changed: converted also this list to Set
        if(!cleanArrayExcel) {
        System.debug('NFCPUTimeLimit1 ' + Limits.getCpuTime());
            for(UploadWrapper uw : dataList) {
                listWorkTypeName.add(uw.WorkTypeName);
                String postalCodeFinal = XC_LCC114_MassiveAssignmentWorkType_U.normalizeZipCode(String.valueOf(uw.PostalCode));//NicoloFodera 20220715 Added  
                listPostalCode.add(postalCodeFinal);
                listKey.add(uw.WorkTypeName+'_'+postalCodeFinal);
            }
        } else {
        System.debug('NFCPUTimeLimit2 ' + Limits.getCpuTime());
            for(UploadWrapper uw : dataList) {
                String key = uw.WorkTypeName + uw.PostalCode;
                if(!listDuplicateKey.contains(key)) {
                    listDuplicateKey.add(key);
                    listWorkTypeName.add(uw.WorkTypeName);
                    String postalCodeTemp = String.valueOf(uw.PostalCode);
                    String postalCodeFinal = postalCodeTemp.length() == 1 ? '0000'+postalCodeTemp : (
                                                postalCodeTemp.length() == 2 ? '000'+postalCodeTemp : (
                                                    postalCodeTemp.length() == 3 ? '00'+postalCodeTemp : (
                                                        postalCodeTemp.length() == 4 ? '0'+postalCodeTemp : postalCodeTemp
                                            )));
                    listPostalCode.add(postalCodeFinal);
                    listKey.add(uw.WorkTypeName+'_'+postalCodeFinal);
                }
            }
        }
        System.debug('NFCPUTimeLimit3 ' + Limits.getCpuTime());
        List<XC_PartnerCoverage__c> listPc = new List<XC_PartnerCoverage__c>([
            SELECT Id, XC_Account__c, XC_WorkType__r.Name, XC_ExternalId__c, XC_WorkTypeName__c, XC_WorkType__c, XC_ZipCode__c, XC_BlockResourceCoverageCreation__c
            FROM XC_PartnerCoverage__c
            WHERE XC_Account__c = :accountId AND XC_WorkType__r.Name IN :listWorkTypeName AND XC_ZipCode__c IN :listPostalCode AND XC_WorkType__r.XC_LegalEntity__c = :legalEntity AND XC_WorkType__r.XC_Segment__c = 'B2C' 
        ]);
        System.debug('NFCPUTimeLimit4 ' + Limits.getCpuTime());
        for(XC_PartnerCoverage__c pc : listPc) {
            if(listKey.contains(pc.XC_WorkType__r.Name+'_'+pc.XC_ZipCode__c)) {
                wr.listPcToReturn.add(pc);
            }
        }

        List<Account> listAcc = new List<Account>([
            SELECT Id, Name
            FROM Account
            WHERE Id = :accountId
        ]);
        wr.partnerName = listAcc[0].Name;
        return wr;
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date Creation 04/02/2021
     * @description Method to upload coverage from CSV (add operation)
     * @param legalEntity - String
     * @param listWorkTypeName - String
     * @param accountId - String
     * @return UtilCSVWrapper 
    */
    @AuraEnabled
    public static UtilCSVWrapper uploadFileCsvAdd(String legalEntity, List<String> listWorkTypeName, String accountId) {
        UtilCSVWrapper wr = new UtilCSVWrapper();
        List<WorkType> listWt = new List<WorkType>([
            SELECT Id, Name
            FROM WorkType 
            WHERE XC_LegalEntity__c = :legalEntity AND XC_Segment__c = 'B2C' AND Name IN :listWorkTypeName
            ORDER BY Name
        ]);  
        if(listWt.isEmpty()) {
            wr.success = false;
        } else {
            for(WorkType wt : listWt) {
                wr.mapNameIdWorkType.put(wt.Name, wt.Id);
            }
            List<Account> listAcc = new List<Account>([
            SELECT Id, Name
            FROM Account
            WHERE Id = :accountId
        ]);
        wr.partnerName = listAcc[0].Name;
        }
        return wr;
    }

    /**
     * @author Lorenzo Evangelisti - lorenzo.evangelisti@webresults.it
     * @date Creation 31/05/2022
     * @description Method for populating LogsWrapper (to view Logs)
     * @param dirtyData - Boolean
     * @return wrapper - LogsWrapper
    */
    @AuraEnabled
    public static LogsWrapper populateLogsWrapper(Boolean dirtyData) {
        LogsWrapper wrapper = new LogsWrapper();
        if(!Schema.sObjectType.ListView.isAccessible()){
            wrapper.resultMessage = Label.XC_CL_InsufficientPrivileges;
            wrapper.success = false;
            return wrapper;
        }
        wrapper.success = true;
        wrapper.listViews = [SELECT Id, Name FROM ListView WHERE SobjectType = 'XC_MassiveAssignWorkTypeOperationStatus__c' and Name='All'];
        wrapper.dirtyData = dirtyData;
        return wrapper;
    }
}