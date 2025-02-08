/**
* @File Name          : XC_IN_QRS12_ChangeOwnership_U.cls
* @Description        : util class for XC_IN_QRS12_ChangeOwnership.cls
* @Author             : Luisana Rocco - lrocco@deloitte.it
* @Group              : 
* @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
* @Last Modified On   : 
* @Modification Log   : 
* Ver       Date            Author      		    Modification
* 1.0    04/10/2021   Luisana Rocco - lrocco@deloitte.it     Initial Version
**/

public without sharing class XC_IN_QRS12_ChangeOwnership_U {


    
    /**
    * @description populate wrapper response 
    * @author Luisana Rocco - lrocco@deloitte.it  
    * @param Map<String,Object> utilMap 
    **/
    public static void populateWrRes(Map<String,Object> utilMap){ 

        XC_REST_Order_U.WrapperRes wrResp = (XC_REST_Order_U.WrapperRes) utilMap.get('wrResp');
        wrResp.Result.ErrorCode = '500';
        wrResp.Result.logError = 'ERROR. ' + (String)utilMap.get('ErrorMessage');
        wrResp.Result.Message = 'ERROR. ' + (String)utilMap.get('ErrorMessage');
    
    }


    
    /**
    * @description method to retrieve util info
    * @author Luisana Rocco - lrocco@deloitte.it 
    * @param utilMap
    **/
    public static Boolean getUtilInfo(Map<String,Object> utilMap){

        Map<Id,XC_QueuedRequestStep__c> previousSteps = (Map<Id,XC_QueuedRequestStep__c>) utilMap.get('previousSteps');
        String legalEntity = (String) utilMap.get('legalEntity');

        XC_REST_Account_W.WrapperResponse responseWrPreviousStepAddress;
        XC_REST_Account_W.WrapperResponse responseWrPreviousStepBP;
        for(XC_QueuedRequestStep__c previousStep : previousSteps.values()){
            if(previousStep.XC_StepLabel__c == 'Create Address'){
                responseWrPreviousStepAddress = (XC_REST_Account_W.WrapperResponse) JSON.deserialize(previousStep.XC_ExecutionResponse__c, XC_REST_Account_W.WrapperResponse.class);
            }else if(previousStep.XC_StepLabel__c == 'Create Billing Profile'){
                responseWrPreviousStepBP = (XC_REST_Account_W.WrapperResponse) JSON.deserialize(previousStep.XC_ExecutionResponse__c, XC_REST_Account_W.WrapperResponse.class);
            }
        }


        //Get Addresses
        Set<Id> addressIds = new Set<Id>();
        for(XC_UTIL_Address.AddressWrapper addrWr : responseWrPreviousStepAddress.Address){
            addressIds.add(addrWr.AddressID);
        }


        // Util Infos
        utilMap.put('BillingProfileID', responseWrPreviousStepBP.BillingProfile[0].BillingProfileID);
        utilMap.put('accountIdNew', responseWrPreviousStepBP.Account.AccountID);
        utilMap.put('addressIds', addressIds);


        Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, XC_Segment__c,
                                                            (SELECT Id, XC_BillingProfile__c, XC_BillingProfile__r.NE__Payment__c, XC_BillToAddress__c, XC_SoldToAddress__c  FROM XC_BillingProfileLineItems__r WHERE XC_BillToAddress__c IN : addressIds AND XC_SoldToAddress__c IN : addressIds  AND XC_BillingProfile__c =: responseWrPreviousStepBP.BillingProfile[0].BillingProfileID AND XC_LegalEntity__c =: legalEntity),
                                                            (SELECT Id, XC_AddressProvince__c, XC_BillingAddress__c, XC_PricinRegion__c, XC_DeliveryAddress__c, XC_InstallationAddress__c  FROM Addresses__r WHERE Id IN : addressIds)
                                                            FROM Account WHERE Id =:  responseWrPreviousStepBP.Account.AccountID LIMIT 1]);

        if(accountMap.isEmpty()){
            utilMap.put('ErrorMessage', 'Account not found');
            return false;
        }

        if(accountMap.values()[0].XC_BillingProfileLineItems__r.isEmpty()){
            utilMap.put('ErrorMessage', 'Billing Profile Line Item not found');
            return false; 
        }

        Map<Id,XC_Address__c> addressMap = new Map<Id,XC_Address__c>();
        for(XC_Address__c addr : accountMap.values()[0].Addresses__r){
            addressMap.put(addr.Id, addr);
        }

        utilMap.put('segment', accountMap.values()[0].XC_Segment__c);
        utilMap.put('accountMap', accountMap);
        utilMap.put('addressMap', addressMap);

        return true;
    }


     /**
    * @description method to select the BPLI to be used on the order
    * @author Luisana Rocco - lrocco@deloitte.it 
    * @param Map<String,Object> utilMap 
    **/
    public static Boolean selectBPLI(Map<String,Object> utilMap){

        String changeOrderId = (String) utilMap.get('changeOrderId');
        Map<Id, Account> accountMap = (Map<Id, Account>) utilMap.get('accountMap');
        Map<Id,XC_Address__c> addressMap = (Map<Id,XC_Address__c>) utilMap.get('addressMap');

        Map<Id,NE__OrderItem__c> mapOI = new Map<Id,NE__OrderItem__c>([ SELECT Id,NE__OrderId__r.XC_InstallationAddress__c, NE__Root_Order_Item__c
                                                                        FROM NE__OrderItem__c 
                                                                        WHERE NE__OrderId__c =: changeOrderId]);
        if(mapOI.isEmpty()){
            utilMap.put('ErrorMessage', 'OrderItem not found for Order with Id: '+ changeOrderId);
            return false;
        }


        String installationAddress = mapOI.values()[0].NE__OrderId__r.XC_InstallationAddress__c;
        XC_BillingProfileLineItem__c bpliToUse;
        for(XC_Address__c addr : addressMap.values()){
            Boolean foundBpli = false;
            for(XC_BillingProfileLineItem__c bpli : accountMap.values()[0].XC_BillingProfileLineItems__r){
                if(bpli.XC_SoldToAddress__c == installationAddress && bpli.XC_BillToAddress__c == addr.id){
                    bpliToUse = bpli;
                    foundBpli = true;
                    break;
                }
            }
            if(foundBpli){
                break; 
            }
        }

        if(bpliToUse == null){
            bpliToUse = accountMap.values()[0].XC_BillingProfileLineItems__r[0];
        }

        if(!updateOiWithBP(utilMap, bpliToUse, mapOI)){
            return false;
        }

        return true;
    }


    /**
    * @description method to select the BPLI to be used on the order
    * @author Luisana Rocco - lrocco@deloitte.it | 04-10-2021 
    * @param Map<String,Object> utilMap 
    * @param XC_BillingProfileLineItem__c bpliToUse 
    * @param Map<Id,NE__OrderItem__c>  mapOI 
    **/
    public static Boolean updateOiWithBP(Map<String,Object> utilMap, XC_BillingProfileLineItem__c bpliToUse, Map<Id,NE__OrderItem__c> mapOI){

        List<NE__OrderItem__c> oiToUpdateList = new List<NE__OrderItem__c>();
        for(NE__OrderItem__c ordItem : mapOI.values()) {
            if((bpliToUse.XC_BillingProfile__r.NE__Payment__c == Label.XC_CL_Commodity_Bill && String.isBlank(ordItem.NE__Root_Order_Item__c)) ||
                    bpliToUse.XC_BillingProfile__r.NE__Payment__c != Label.XC_CL_Commodity_Bill) {
                    ordItem.NE__BillingProfId__c = bpliToUse.XC_BillingProfile__c;
                    ordItem.XC_BillingProfileLineItem__c = bpliToUse.Id;
                    ordItem.XC_PaymentMethod__c = bpliToUse.XC_BillingProfile__r.NE__Payment__c;
                    oiToUpdateList.add(ordItem);
            }
        }

        if(!oiToUpdateList.isEmpty()){
            List<XC_UTIL_Sobject.WrapperResult> updateConfItemResult = XC_UTIL_Sobject.updateListRecords(oiToUpdateList);
            for(XC_UTIL_Sobject.WrapperResult updateRes: updateConfItemResult){
                if(!updateRes.success){
                    utilMap.put('ErrorMessage', 'Error on Billing Profile Line Item selection: '+ updateRes.ErrorMessage);
                    return false;
                }
            }
        }
        
        return true;
    }


    /**
    * @description retrieve asset information
    * @author Luisana Rocco - lrocco@deloitte.it 
    * @param utilMap 
    * @return List<Asset> 
    **/
    public static List<Asset> getAssetInfo(Map<String,Object> utilMap){

        String assetId = (String)utilMap.get('assetId');
        Case changeOrderCase = (Case) utilMap.get('changeOrderCase');

        
        Map<Id,Asset> mapAsset = new Map<Id,Asset>();
        if(!String.isBlank(assetId)){
            mapAsset = new Map<Id, Asset>([SELECT Id,Name, NE__Order_Config__c,NE__Order_Config__r.NE__Type__c,
                                            NE__Order_Config__r.XC_Status__c, Status, NE__Order_Config__r.Name, Account.XC_Segment__c,
                                            XC_LegalEntity__c,  XC_Segment__c, NE__Order_Config__r.NE__OptyId__r.Name, NE__Order_Config__r.NE__OptyId__r.StageName,
                                            (SELECT id, Status, XC_WorkTypeCategory__c FROM WorkOrders
                                            WHERE Status='New' OR Status = 'Assigned' OR Status = 'On Hold' OR Status ='In Progress'),
                                            (SELECT id, Status, RecordType.DeveloperName, Description, Reason, SubCause__c, CaseNumber, XC_Subtype__c, AssetId  FROM Cases 
                                            WHERE (Status='ESTA001' OR Status = 'ESTA004' OR Status='ESTA003') AND Id <>: changeOrderCase.Id)
                                            FROM Asset WHERE Id =: assetId]);
        }   
      
        utilMap.put('mapAsset', mapAsset);
        return mapAsset.values();
    }


     /**
    * @description method to check asset and son before change order
    * @author Luisana Rocco - lrocco@deloitte.it
    * @param Map<String,Object> utilMap 
    **/
    public static boolean checkBeforeChangeOrder(Map<String,Object> utilMap){

        String operationType = 'ChangeOrder';
        Asset a = ((Map<Id,Asset>)utilMap.get('mapAsset')).values()[0];

        String orgId = UserInfo.getOrganizationId();
        Map<Id, XC_CM_LegalEntity_Configuration__mdt> checkBlock = new Map<Id,XC_CM_LegalEntity_Configuration__mdt> ([SELECT XC_SkipChangeOwnershipBlock__c 
                                                                                                                      FROM XC_CM_LegalEntity_Configuration__mdt  
                                                                                                                      WHERE XC_LegalEntity__c =: a.XC_LegalEntity__c AND XC_Stream__c =:a.XC_Segment__c AND XC_OrgId__c =: orgId]);

        //check Order 'Disconnect' OR 'ChangeOrder' already opened
        if(a.NE__Order_Config__c != null && 
          (a.NE__Order_Config__r.NE__Type__c == 'Disconnection' || a.NE__Order_Config__r.NE__Type__c == 'ChangeOrder') &&
           a.NE__Order_Config__r.XC_Status__c != 'Closed' && a.NE__Order_Config__r.XC_Status__c != 'Cancelled'){
            utilMap.put('ErrorMessage', String.format(Label.XC_CL_OrderAlreadyInProgress, new List<String>{a.NE__Order_Config__r.Name}));
            
            if(checkBlock.values()[0].XC_SkipChangeOwnershipBlock__c){
                utilMap.put('OrderAlreadyInProgress', a.NE__Order_Config__c);
                manageChangeOwnershipCase(utilMap);
            }
            return false;
        }

        //check Order 'InOrder' already opened for ChangeOrder
        if(a.NE__Order_Config__c != null && 
          (a.NE__Order_Config__r.NE__Type__c == 'InOrder' && operationType == 'ChangeOrder') &&
           a.NE__Order_Config__r.XC_Status__c != 'Closed' && a.NE__Order_Config__r.XC_Status__c != 'Cancelled'){
            utilMap.put('ErrorMessage', String.format(Label.XC_CL_OrderAlreadyInProgress, new List<String>{a.NE__Order_Config__r.Name}));
            
            if(checkBlock.values()[0].XC_SkipChangeOwnershipBlock__c){
                utilMap.put('OrderAlreadyInProgress', a.NE__Order_Config__c); 
                manageChangeOwnershipCase(utilMap);
            }
            return false;
        }

        //check asset status
        if(a.Status != Label.XC_CL_Asset_StatusActive){
            utilMap.put('ErrorMessage', Label.XC_CL_NoChangeOrdOnProvisioningProduct);
            return false;
        }

        // chek opportunity status
        if(a.NE__Order_Config__c != null && a.NE__Order_Config__r.NE__OptyId__r.StageName != Label.XC_CL_Opportunity_ClosedWon && a.NE__Order_Config__r.NE__OptyId__r.StageName != Label.XC_CL_Opportunity_ClosedLost){
            utilMap.put('ErrorMessage', String.format(Label.XC_CL_ChangeOwnership_StatusNotAllowed, new List<String>{ a.NE__Order_Config__r.NE__OptyId__r.Name}));
            
            if(checkBlock.values()[0].XC_SkipChangeOwnershipBlock__c){
                utilMap.put('OptyNotFinalStatus', a.NE__Order_Config__r.NE__OptyId__c); 
                manageChangeOwnershipCase(utilMap);
            }
            return false;
        }

        //checkActiveAsset
        if(!a.WorkOrders.isEmpty() || !a.Cases.isEmpty()){
            //Check if is to block
            if(XC_UTIL_ChangeOrder.checkIsToBlock(utilMap)){
                utilMap.put('ErrorMessage', Label.XC_CL_ActionNotAllowed);
                if(((Map<String,String>)utilMap.get('complaintCase'))!= null && !((Map<String,String>)utilMap.get('complaintCase')).isEmpty()){ 
                    manageChangeOwnershipCase(utilMap);
                }else{
                    manageCaseCreation(utilMap); // Pendig activities. --> SKIP STEP.
                }
               
                return false;
            } else if(((Map<Id, Case>)utilMap.get('caseToUpdate'))!= null && !((Map<Id, Case>)utilMap.get('caseToUpdate')).isEmpty()){
                if(!XC_UTIL_ChangeOrder.updateCase(utilMap)){
                    return false;
                }
            }
           
        }

        
        
        return true;

    }


    /**
    * @description method to check asset and son before change order
    * @author Luisana Rocco - lrocco@deloitte.it
    * @param Map<String,Object> utilMap 
    **/
    public static void manageCaseCreation(Map<String,Object> utilMap){

        String accountId = (String) utilMap.get('accountId');
        String billingProfId = (String) utilMap.get('BillingProfileID');
        String accountIdNew = (String) utilMap.get('accountIdNew');
        String description = Label.XC_CL_NewContractOwner;

        Map<Id,Contact> primaryContact = new Map<Id,Contact>([ SELECT Id, Account.XC_Segment__c
                                                               FROM Contact 
                                                               WHERE XC_PrimaryContact__c = true AND AccountId =: accountId
                                                            ]);

        // assignment rules
        AssignmentRule AR = new AssignmentRule();
        AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.assignmentRuleId = AR.id;

        List<String> caseSettingNames = new List<String>{Label.XC_CL_CMD_ChangeOfContractHolder};
        Map<String, XC_CM_Case_Type_Setting__mdt> caseSettingsMap = XC_UTIL_Case.retriveCaseTypeSettings(caseSettingNames);
        XC_CM_Case_Type_Setting__mdt caseSettings = caseSettingsMap.get(Label.XC_CL_CMD_ChangeOfContractHolder); 
        Case c = XC_UTIL_Case.initCaseFromCaseSettings(caseSettings);
        c.AccountId = accountId; // former account
        c.ContactId = primaryContact.values()[0].Id; // former contact 
        c.AssetId = (String) utilMap.get('assetId');
        c.Description = (!String.isBlank((String)utilMap.get('BlockCompliantCases'))) ?  description.replace('<1>', accountIdNew).replace('<2>', billingProfId) + '\n' + (String)utilMap.get('BlockCompliantCases') :  description.replace('<1>', accountIdNew).replace('<2>', billingProfId);//Label.XC_CL_NewAccount  + '. AccountID: '+ accountIdNew + '; ' + Label.XC_CL_BillingProfile + ':' + billingProfId ; // Adding new account information
        c.XC_OriginChannel__c =  (String) utilMap.get('channel');
        c.XC_Segment__c = primaryContact.values()[0].Account.XC_Segment__c;
        c.XC_LegalEntity__c = (String)utilMap.get('legalEntity');
        //c.origin = ((String) utilMap.get('channel') == 'Market') ? Label.XC_CL_Case_Origin_Market : (String) utilMap.get('channel');
        c.XC_Order__c = (!String.isBlank((String)utilMap.get('OrderAlreadyInProgress'))) ? (String)utilMap.get('OrderAlreadyInProgress') : null;
        c.XC_Opportunity__c = (!String.isBlank((String)utilMap.get('OptyNotFinalStatus'))) ? (String)utilMap.get('OptyNotFinalStatus') : null; 
        c.setOptions(dmlOpts);
        XC_UTIL_Sobject.WrapperResult wrResCase = XC_UTIL_SObject.insertRecord(c);
        if(wrResCase.success){
            Map<Id,Case> mapCase = new Map<Id,Case>([SELECT CaseNumber FROM Case WHERE Id =: c.Id]);
            utilMap.put('CaseNumberMessage', '. On Xcustomer has been opened case n.'+ mapCase.values()[0].CaseNumber);
            utilMap.put('ChangeOfOwnershipCase', c); 
        }else {
            utilMap.put('ErrorMessage', ' Error during case creation. ' + wrResCase.ErrorMessage);
        }
        
    }


    /**
    * @description method to manage change of ownership case. If change of ownership case does not exists, it will be created. 
      This new case will be linked to the order/opportunity not in a final status.In addition, if there are compliant cases blocking the change of ownership,
      these will be reported in the description field of the change of ownership case.
    * @author Luisana Rocco - lrocco@deloitte.it
    * @param Map<String,Object> utilMap 
    **/
    public static void manageChangeOwnershipCase(Map<String,Object> utilMap){

        Asset a = ((Map<Id,Asset>)utilMap.get('mapAsset')).values()[0];
        Map<String,String> compliantCase = (Map<String,String>)utilMap.get('complaintCase');

        Case changeOwnershipCase = checkChangeOwnershipCase(utilMap);

        if(changeOwnershipCase != null){ // already exists a case for change of ownership
            List<Case> caseToUpdate = new List<Case>();
                if(!XC_UTIL_ChangeOrder.manageChangeOwnershipCase(utilMap, changeOwnershipCase)){
                    return;
                }            
            utilMap.put('CaseNumberMessage', '. On Xcustomer has been opened case n.'+ changeOwnershipCase.CaseNumber);

        } else {// does not exists a case for change of ownership
            if(compliantCase != null){
                Map<String,String> compliantCaseMap = (Map<String,String>)utilMap.get('complaintCase');
                String concatenateValue = String.join(compliantCaseMap.values(), ';');
                String str= Label.XC_CL_ComplaintCaseErrorMessage + ':[' + concatenateValue + '].';
                utilMap.put('BlockCompliantCases',str);
            }
            manageCaseCreation(utilMap); // Pendig activities. --> SKIP STEP
        }
       
    }


    /**
    * @description method to check if already exists a change ownership case linked to the asset
    * @author Luisana Rocco - lrocco@deloitte.it
    * @param Map<String,Object> utilMap 
    **/
    private static Case checkChangeOwnershipCase(Map<String,Object> utilMap){

        Asset a = ((Map<Id,Asset>)utilMap.get('mapAsset')).values()[0];

        List<String> caseSettingNames = new List<String>{Label.XC_CL_CMD_ChangeOfContractHolder};
        Map<String, XC_CM_Case_Type_Setting__mdt> caseSettingsMap = XC_UTIL_Case.retriveCaseTypeSettings(caseSettingNames);
        XC_CM_Case_Type_Setting__mdt caseSettings = caseSettingsMap.get(Label.XC_CL_CMD_ChangeOfContractHolder); 
    
        Case changeOwnershipCase; 
        for(Case c: a.Cases){
            if(caseSettings!=null && c.Reason == caseSettings.XC_Case_Reason__c && c.SubCause__c == caseSettings.XC_Sub_Cause__c && c.XC_Subtype__c  == caseSettings.XC_Sub_Type__c){// check change ownership triplet case 
                changeOwnershipCase = c; 
                break;
            }
        }

        return changeOwnershipCase;
    }
}