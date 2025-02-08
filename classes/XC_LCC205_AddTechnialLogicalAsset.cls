/**
* @author Nicola Arrigo - narrigo@deloitte.it
* @date Creation 15/09/2020
* @description class to retreiveTechnicalandLogicalAsset
*/
public with sharing class XC_LCC205_AddTechnialLogicalAsset {

    public class responseWrapper{
        public String result = 'OK';
        public String errorMessage;
        public List<Asset> techAssetList=new List<Asset>();
        List<Asset> logicalAssetList = new List<Asset>();
        public List<Asset> networkAssetList=new List<Asset>(); //DeAv 07.07.2022 - NR2330
        public String caseBsnLine = '';
        public Boolean isForceWorkOrder = false;
    }


    /**
* @author Nicola Arrigo - narrigo@deloitte.it
* @date Creation 15/09/2020
* @description class to retreiveTechnicalandLogicalAsset
*/
@AuraEnabled
    public static string  retrieveListAsset(string recordId ){
        string result;
        List<Asset> assetList=new List<Asset>(); 
        List<Asset> newListAsset=new List<Asset>();
        List<Asset> logicalAsset = new List<Asset>();
        Map<string,List<Asset>> mapAsset=new Map<string,List<Asset>>();
        List<String> logicalAssetId = new List<String>();
        case c=[select id,XC_Address__c,AccountId,XC_BusinessLine__c,XC_IsCloned__c,ParentId,XC_Address__r.XC_StreetTypeText__c,XC_Address__r.XC_Address__c,XC_Address__r.XC_City__c,XC_Address__r.XC_PostalCode__c
                 from case
                 where id=:recordId];       
         if(c.XC_Address__c==null){
            mapAsset.put(Label.XC_CL_CaseErrorMessage_MalfunctioningAddress,assetList);
            system.debug('No Adress found');
           // c.adderror('Please set the address on the case');
         }/*else if(c.ParentId!=null){
            //c.adderror(Label.XC_CL_CaseErrorMessage_MalfunctioningIsCloned);
            mapAsset.put(Label.XC_CL_CaseErrorMessage_MalfunctioningIsCloned,assetList);
            system.debug('Case is cloned');
         }*/else{
           /* assetList=[select id,Name,TAM_AssetType__c,AccountId, XC_Address__c,TAM_IsTechnical__c, TAM_IsLogical__c from Asset 
                    where (TAM_IsTechnical__c=true or TAM_IsLogical__c=true) and AccountId=:c.AccountId and XC_Address__c =:c.XC_Address__c and TAM_BusinessLine__c=:c.XC_BusinessLine__c];*/  
                    assetList=[Select  id,Name,TAM_AssetType__c,AccountId, XC_Address__c,TAM_IsTechnical__c, TAM_IsLogical__c, RootAssetId,
                              XC_Address__r.XC_StreetTypeText__c,XC_Address__r.XC_Address__c,XC_Address__r.XC_City__c,XC_Address__r.XC_PostalCode__c,SerialNumber from Asset 
                              where (TAM_IsTechnical__c=true) and AccountId=:c.AccountId /*and TAM_BusinessLine__c=:c.XC_BusinessLine__c*/]; 
            string addresKey=c.XC_Address__r.XC_StreetTypeText__c+'_'+c.XC_Address__r.XC_Address__c+'_'+c.XC_Address__r.XC_City__c+'_'+c.XC_Address__r.XC_PostalCode__c;
            for(asset a:assetList){
                string assetAdressKey=a.XC_Address__r.XC_StreetTypeText__c+'_'+a.XC_Address__r.XC_Address__c+'_'+a.XC_Address__r.XC_City__c+'_'+a.XC_Address__r.XC_PostalCode__c;
                if(addresKey==assetAdressKey){
                    newListAsset.add(a);
                    logicalAssetId.add(a.RootAssetId);
                }
            }
            if(newListAsset.size()==0){
                mapAsset.put('No Asset found',newListAsset); 
                system.debug('No found List');
            }else{
                mapAsset.put('Ok',newListAsset);
                if(!logicalAsset.isEmpty()){
                    logicalAsset = [Select  id,Name,TAM_AssetType__c,AccountId, XC_Address__c,TAM_IsTechnical__c, TAM_IsLogical__c, RootAssetId,
                    XC_Address__r.XC_StreetTypeText__c,XC_Address__r.XC_Address__c,XC_Address__r.XC_City__c,XC_Address__r.XC_PostalCode__c,SerialNumber from Asset 
                    where  TAM_IsLogical__c=true and AccountId=:c.AccountId and TAM_BusinessLine__c=:c.XC_BusinessLine__c]; 
                }
            }            
         }        
       system.debug('AssetList '+assetList);
       system.debug('NewAsseListSize'+newListAsset);
       system.debug('AssetLisSize '+assetList.size());
       system.debug('mapAsset '+mapAsset);
       return  JSON.serialize(mapAsset);
        //return mapAsset;
    }
    @AuraEnabled
    public static string caseUpdate(string recordId,id assetId, String assetSubtype, Boolean forceWOCreation){
        system.debug('enter method caseUpdate');
        system.debug('Case id '+recordId);
        system.debug('asset id '+assetId);
        string result;
        case c=[select id,XC_Address__r.XC_StreetType__c,XC_Address__r.XC_StreetTypeText__c,XC_Address__c,AccountId,XC_TechnicalAsset__c,XC_Force_Work_Order_creation__c,AssetId,XC_IsCloned__c,ParentId,Subcause__c, XC_AssetSubType__c, XC_Subtype__c, Reason
                from Case
                where id=:recordId];
        
        Asset a=[select id,TAM_PartnerContract__c,ParentId,TAM_CommercialAsset__c,TAM_CommercialAsset__r.NE__Order_Config__r.NE__OptyId__c, TAM_IsLogical__c from Asset
                 where id=:assetId]; 
        List<AssetRelationship> assetRelationships = [SELECT id, AssetId, RelatedAssetId, RelatedAsset.TAM_PartnerContract__r.XC_ContractAccount__c, RelatedAsset.TAM_PartnerContract__c  FROM AssetRelationship  WHERE AssetId =: assetId  AND RelationshipType = 'Root'];
        List<WorkOrder> woList=[select id,CaseId,status from WorkOrder where 
                                CaseId=:recordId and
                                (Status!='Canceled' and status!='Completed') and 
                                XC_WorkTypeCategory__c='Malfunctioning'];
        if(woList.size()>0){
            system.debug('ListWo related to the case '+woList);
            system.debug('1° Wo Status '+woList[0].status);
        }                        
        List<Case> existingCaseList=new List<Case>();
        if(!string.isBlank(c.XC_Subtype__c)){
            existingCaseList=[Select Id,Status, AccountId, ContactId, ParentId, CaseNumber, Subcause__c, XC_Subtype__c, Reason, Priority,
            XC_WorkOrder__c, XC_Opportunity__c, XC_Order__c, XC_OrderItem__c, AssetId, XC_Type_Intermediary__c,XC_TechnicalAsset__c
            from case 
            where (Reason=:c.Reason  and
                  Subcause__c=:c.Subcause__c and
                  (XC_Subtype__c=:c.XC_Subtype__c) and 
                   XC_TechnicalAsset__c=:assetId and 
                   ParentId=null and
                   id!=:recordId and 
                   status!='ESTA007' and
                   status!='ESTA008'
                    )
                    order by createddate asc
                   ];                     
        }else{
            existingCaseList=[Select Id,Status, AccountId, ContactId, ParentId, CaseNumber, Subcause__c, XC_Subtype__c, Reason, Priority,
                                    XC_WorkOrder__c, XC_Opportunity__c, XC_Order__c, XC_OrderItem__c, AssetId, XC_Type_Intermediary__c,XC_TechnicalAsset__c
                                    from case 
                                    where (Reason=:c.Reason  and
                                          Subcause__c=:c.Subcause__c and
                                          (XC_Subtype__c=null) and 
                                           XC_TechnicalAsset__c=:assetId and 
                                           ParentId=null and
                                           id!=:recordId and
                                           status!='ESTA007' and
                                           status!='ESTA008'
                                            )
                                            order by createddate asc
                                           ];                       
        }  
        c.XC_Force_work_Order_Creation__c = c.XC_Force_work_Order_Creation__c? c.XC_Force_work_Order_Creation__c : forceWOCreation;
        system.debug('List existing Case Controller AddTechnicalLogicalAsset '+existingCaseList);                                     
         if(c.XC_TechnicalAsset__c==assetId ){
            return 'The Asset is just related to the Case';
           } else if(existingCaseList.size()>0 && assetSubtype== null ){
             system.debug('enter else if condition existing case >=0 Controller AddTechnicalLogicalAsset');       
             result=Label.XC_CLCaseErroreMessage_CaselinkedtoParent;
            // return Label.XC_CLCaseErroreMessage_CaselinkedtoParent;
            }else if(c.XC_Force_Work_Order_creation__c==false &&
                    ((!assetRelationships.isEmpty() && assetRelationships[0].RelatedAsset.TAM_PartnerContract__c== null)|| (assetRelationships.isEmpty() && a.TAM_PartnerContract__c== null )) &&
                    existingCaseList.size()==0 && (!c.XC_BusinessLine__c.equals('eCity') && (c.XC_LegalEntity__c.equals('EnelXItalia') || c.XC_LegalEntity__c.equals('EnelSole')) )   ){ 
             
            // result='A Contract is not related to the Technical Asset';
            result=Label.XC_CL_CaseErrorMessage_TechnicalAsset;
           // return Label.XC_CL_CaseErrorMessage_TechnicalAsset;           
                    } 
                 else if(woList.size()>0){
                     system.debug('enter if condition woli list addTechncialLogicalAsset');
                    result=Label.XC_CL_CaseErrorMessage_WoMal;   
                 //   return Label.XC_CL_CaseErrorMessage_WoMal;
                    }
       else if((c.XC_TechnicalAsset__c==null ||
             c.XC_TechnicalAsset__c!=assetId) && 
             ((!assetRelationships.isEmpty() && assetRelationships[0].RelatedAsset.TAM_PartnerContract__c!= null) ||
              a.TAM_PartnerContract__c!= null ||
             c.XC_Force_Work_Order_creation__c==true            
             )){
                c.XC_TechnicalAsset__c=assetId;
                c.AssetId=a.TAM_CommercialAsset__c;
                c.XC_Opportunity__c=a.TAM_CommercialAsset__r.NE__Order_Config__r.NE__OptyId__c;
                c.XC_AssetSubType__c = assetSubtype;
                update c;
                result=c.id;
            }          
        return result;      
    }


    
    @AuraEnabled
    public static string  retrieveLogicalAndTechnicalAsset(string recordId ){
        responseWrapper wrapper = new responseWrapper();
        
        Set<Id> logicalAssetIds = new Set<Id>();
        Case caseInfo =[ SELECT id, AccountId,  XC_Address__r.XC_AddressCountry__c, XC_Address__r.XC_AddressProvince__c, XC_Address__r.XC_City__c, XC_Force_Work_Order_creation__c,
                        XC_Address__r.XC_KeyForDuplicationOne__c, XC_BusinessLine__c, XC_Address__c
                    FROM  Case 
                    WHERE  id=:recordId LIMIT 1];  
        if(caseInfo.XC_Address__c == null){
            wrapper.result = 'KO';
            wrapper.errorMessage = Label.XC_CL_CaseErrorMessage_MalfunctioningAddress;
            return JSON.serialize(wrapper);
        }
        wrapper.caseBsnLine =  caseInfo.XC_BusinessLine__c; 
        wrapper.isForceWorkOrder = caseInfo.XC_Force_Work_Order_creation__c;
        Map<id, Asset> assetList=new Map<id, Asset>([SELECT  id,Name,TAM_AssetType__c,AccountId, XC_Address__c,TAM_IsTechnical__c, TAM_IsLogical__c, RootAssetId,  XC_Address__r.XC_AddressCountry__c, XC_Address__r.XC_AddressProvince__c, XC_Address__r.XC_City__c, RootAsset.Name, Parent.Name,
        XC_Address__r.XC_KeyForDuplicationOne__c, SerialNumber ,TAM_PartnerContract__c  
        FROM Asset 
        WHERE TAM_IsTechnical__c = true 
        AND AccountId =: caseInfo.AccountId 
		AND  XC_Address__r.XC_AddressCountry__c =: caseInfo.XC_Address__r.XC_AddressCountry__c 
        AND  XC_Address__r.XC_AddressProvince__c =: caseInfo.XC_Address__r.XC_AddressProvince__c 
        AND  XC_Address__r.XC_City__c =: caseInfo.XC_Address__r.XC_City__c 
        AND  XC_Address__r.XC_KeyForDuplicationOne__c =: caseInfo.XC_Address__r.XC_KeyForDuplicationOne__c
        AND TAM_BusinessLine__c =: caseInfo.XC_BusinessLine__c 
        AND RecordType.DeveloperName != 'TAM_Lamp'
        AND RecordType.DeveloperName != 'TAM_PODMeter'
                                                     order by Name]);
        if(assetList.isEmpty() && !caseInfo.XC_BusinessLine__c.equals('eCity')){
            wrapper.result = 'KO';
            wrapper.errorMessage = 'No Asset found for this Account';
            return JSON.serialize(wrapper);
        }
        wrapper.techAssetList = assetList.values();
        List<AssetRelationship> assetRel = [Select AssetId, RelationshipType, RelatedAssetId  from AssetRelationship WHERE AssetId IN : assetList.keyset() and RelationshipType = 'Root'];
        wrapper.techAssetList = assetList.values();
        
        for(AssetRelationship a : assetRel){
            logicalAssetIds.add(a.RelatedAssetId);
        }
        wrapper.logicalAssetList = [SELECT  id,Name,TAM_AssetType__c,AccountId, XC_Address__c,TAM_IsTechnical__c, TAM_IsLogical__c, RootAssetId,  XC_Address__r.XC_AddressCountry__c, XC_Address__r.XC_AddressProvince__c, XC_Address__r.XC_City__c,
        XC_Address__r.XC_KeyForDuplicationOne__c, SerialNumber, TAM_PartnerContract__c
        FROM Asset 
        WHERE TAM_IsLogical__c = true 
        AND id IN: logicalAssetIds  order by Name ];

        //DeAv 07.07.2022 - NR2330 START
        List<String> legEntItaly = new List<String>{'EnelXItalia','EnelSole'}; 
        wrapper.networkAssetList = [SELECT Id, Name, SerialNumber, TAM_AssetType__c 
                                    FROM Asset 
                                    WHERE AccountId =: caseInfo.AccountId AND 
                                          RecordType.DeveloperName = 'TAM_Network' AND 
                                          Status IN ('Active','Installed') AND 
                                          XC_LegalEntity__c IN :legEntItaly];
        if(wrapper.networkAssetList.isEmpty() && caseInfo.XC_BusinessLine__c.equals('eCity')){
            wrapper.result = 'KO';
            wrapper.errorMessage = 'No Network Asset found for this Account';
            return JSON.serialize(wrapper);
        }
        //DeAv 07.07.2022 - NR2330 END

        return JSON.serialize(wrapper);
    }

    @AuraEnabled
    public static string retrieveFilteredLogicalAndTechnicalAsset(string recordId, String name ){
        String searchByName = '%'+ name + '%';
        responseWrapper wrapper = new responseWrapper();
        
        Set<Id> logicalAssetIds = new Set<Id>();
        Case caseInfo =[ SELECT id, AccountId,  XC_Address__r.XC_AddressCountry__c, XC_Address__r.XC_AddressProvince__c, XC_Address__r.XC_City__c, XC_Force_Work_Order_creation__c,
                        XC_Address__r.XC_KeyForDuplicationOne__c, XC_BusinessLine__c, XC_Address__c
                    FROM  Case 
                    WHERE  id=:recordId LIMIT 1];  
        if(caseInfo.XC_Address__c == null){
            wrapper.result = 'KO';
            wrapper.errorMessage = Label.XC_CL_CaseErrorMessage_MalfunctioningAddress;
            return JSON.serialize(wrapper);
        }
        Map<id, Asset> assetList=new Map<id, Asset>([SELECT  id,Name,TAM_AssetType__c,AccountId, XC_Address__c,TAM_IsTechnical__c, TAM_IsLogical__c, RootAssetId,  XC_Address__r.XC_AddressCountry__c, XC_Address__r.XC_AddressProvince__c, XC_Address__r.XC_City__c, RootAsset.Name, Parent.Name,
        XC_Address__r.XC_KeyForDuplicationOne__c, SerialNumber, TAM_PartnerContract__c
        FROM Asset 
        WHERE TAM_IsTechnical__c = true 
        AND AccountId =: caseInfo.AccountId 
        AND  XC_Address__r.XC_AddressCountry__c =: caseInfo.XC_Address__r.XC_AddressCountry__c 
        AND  XC_Address__r.XC_AddressProvince__c =: caseInfo.XC_Address__r.XC_AddressProvince__c 
        AND  XC_Address__r.XC_City__c =: caseInfo.XC_Address__r.XC_City__c 
        AND  XC_Address__r.XC_KeyForDuplicationOne__c =: caseInfo.XC_Address__r.XC_KeyForDuplicationOne__c 
        AND TAM_BusinessLine__c =: caseInfo.XC_BusinessLine__c
        AND RecordType.DeveloperName != 'TAM_Lamp'
        AND RecordType.DeveloperName != 'TAM_PODMeter'
        AND Name like : searchByName      
        /*AND TAM_BusinessLine__c =: caseInfo.XC_BusinessLine__c */ order by Name]);
        /*if(assetList.isEmpty()){
            wrapper.result = 'KO';
            wrapper.errorMessage = 'No Asset found for this Account';
            return JSON.serialize(wrapper);
        }*/
        wrapper.techAssetList = assetList.values();
        Map<id, Asset> assetList2=new Map<id, Asset>([SELECT  id,Name,TAM_AssetType__c,AccountId, XC_Address__c,TAM_IsTechnical__c, TAM_IsLogical__c, RootAssetId,  XC_Address__r.XC_AddressCountry__c, XC_Address__r.XC_AddressProvince__c, XC_Address__r.XC_City__c, RootAsset.Name, Parent.Name,
        XC_Address__r.XC_KeyForDuplicationOne__c, SerialNumber, TAM_PartnerContract__c
        FROM Asset 
        WHERE TAM_IsTechnical__c = true 
        AND AccountId =: caseInfo.AccountId 
        AND  XC_Address__r.XC_AddressCountry__c =: caseInfo.XC_Address__r.XC_AddressCountry__c 
        AND  XC_Address__r.XC_AddressProvince__c =: caseInfo.XC_Address__r.XC_AddressProvince__c 
        AND  XC_Address__r.XC_City__c =: caseInfo.XC_Address__r.XC_City__c 
        AND  XC_Address__r.XC_KeyForDuplicationOne__c =: caseInfo.XC_Address__r.XC_KeyForDuplicationOne__c     
        AND TAM_BusinessLine__c =: caseInfo.XC_BusinessLine__c
        AND RecordType.DeveloperName != 'TAM_Lamp' 
       	AND RecordType.DeveloperName != 'TAM_PODMeter'
         order by Name]);
        List<AssetRelationship> assetRel = [Select AssetId, RelationshipType, RelatedAssetId  from AssetRelationship WHERE AssetId IN : assetList2.keyset() and RelationshipType = 'Root' ];
        wrapper.techAssetList = assetList.values();
        
        for(AssetRelationship a : assetRel){
            logicalAssetIds.add(a.RelatedAssetId);
        }
        wrapper.logicalAssetList = [SELECT  id,Name,TAM_AssetType__c,AccountId, XC_Address__c,TAM_IsTechnical__c, TAM_IsLogical__c, RootAssetId,  XC_Address__r.XC_AddressCountry__c, XC_Address__r.XC_AddressProvince__c, XC_Address__r.XC_City__c,
        XC_Address__r.XC_KeyForDuplicationOne__c, SerialNumber, TAM_PartnerContract__c
        FROM Asset 
        WHERE TAM_IsLogical__c = true 
        AND Name like : searchByName  
        AND id IN: logicalAssetIds  order by Name ];

        //DeAv 07.07.2022 - NR2330 START
        List<String> legEntItaly = new List<String>{'EnelXItalia','EnelSole'}; 
        wrapper.networkAssetList = [SELECT Id, Name, SerialNumber, TAM_AssetType__c 
                                    FROM Asset 
                                    WHERE AccountId =: caseInfo.AccountId AND 
                                          Name like : searchByName AND
                                          RecordType.DeveloperName = 'TAM_Network' AND 
                                          Status IN ('Active','Installed') AND 
                                          XC_LegalEntity__c IN :legEntItaly];
        if(wrapper.networkAssetList.isEmpty() && caseInfo.XC_BusinessLine__c.equals('eCity')){
            wrapper.result = 'KO';
            wrapper.errorMessage = 'No Network Asset found for this Account';
            return JSON.serialize(wrapper);
        }
        //DeAv 07.07.2022 - NR2330 END

        return JSON.serialize(wrapper);
    }

    @AuraEnabled
    public static Boolean showNewComponent(String recordId){
        Case c = [Select id, XC_LegalEntity__c, XC_Segment__c from Case where id =: recordId LIMIT 1 ];
        System.debug('Org ID' + UserInfo.getOrganizationId());
        List<XC_CM_LegalEntity_Configuration__mdt> configuration = [Select id, XC_ShowLogicAssetOnCase__c from XC_CM_LegalEntity_Configuration__mdt where XC_LegalEntity__c =: c.XC_LegalEntity__c and XC_Stream__c =: c.XC_Segment__c and XC_OrgId__c = : UserInfo.getOrganizationId()];
        return !configuration.isEmpty() ? configuration[0].XC_ShowLogicAssetOnCase__c : false;
    }

    /**
    * @author Denise Avolio - denise.avolio@accenture.com
    * @date Creation 08/07/2022
    * @description check if the All Networks section should be shown - NR2330
    */
    @AuraEnabled
    public static Boolean showAllNetworks(String recordId){
        List<String> segmentList = new List<String>{'B2B','B2G'};
        List<String> legEntItaly = new List<String>{'EnelXItalia','EnelSole'}; 
        Boolean showSection = false;
        Case cs = [SELECT Id, XC_Segment__c, XC_LegalEntity__c, XC_BusinessLine__c, Country__c FROM Case WHERE Id =: recordId LIMIT 1 ];
        if(legEntItaly.contains(cs.XC_LegalEntity__c) && segmentList.contains(cs.XC_Segment__c) && 
           'eCity'.equalsIgnoreCase(cs.XC_BusinessLine__c) && 'Italy'.equalsIgnoreCase(cs.Country__c)){
            showSection = true;
        }
        return showSection;
    }
}