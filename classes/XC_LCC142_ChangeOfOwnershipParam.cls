/**
* The Class XC_LCC142_ChangeOfOwnershipParam
* @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
* @description controller for XC_LCP142_ChangeOfOwnershipParam component
*/
public without sharing class XC_LCC142_ChangeOfOwnershipParam {


 /**
    * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
    * @date Creation 04/09/2019
    * @date Modification dd/mm/yyyy
    * @description set available TypeAndReason for init component 142 
    * @param configurationId
    * @return XC_UTIL_ResultWrapper
    */ 
    @AuraEnabled 
    public static XC_UTIL_ResultWrapper setTypeAndReason(String configurationId){
        System.debug('In setTypeAndReason');
        XC_UTIL_ResultWrapper resWrapper = new XC_UTIL_ResultWrapper(); 
        resWrapper.success = false;
        resWrapper.resultMessage = 'Action not allowed for this order';
        NE__Order__c o = [SELECT id, XC_Subtype__c, XC_Segment__c, (SELECT id, NE__Bundle__c FROM NE__Assets__r LIMIT 1) FROM NE__Order__c WHERE Id=: configurationId];
        If(o.XC_Subtype__c!='Change of ownership'){
            return resWrapper;
        }
        
        List<String> typeOptions = XC_UTIL_Sobject.getPicklistValues('NE__Order__c' ,  'XC_Type__c');
        if(!o.NE__Assets__r.isEmpty() && o.NE__Assets__r[0].NE__Bundle__c!=null){
            typeOptions.clear();
            typeOptions.add('With Subrogation');
        }else{ 
            typeOptions.remove(typeOptions.indexOf('With Subrogation'));
        }
        List<String> reasonOptions = XC_UTIL_Sobject.getPicklistValues('NE__Order__c' ,  'XC_ReasonOfChangeOwnership__c');
        if(!reasonOptions.isEmpty() && !typeOptions.isEmpty()){
                 resWrapper.success = true;
                 resWrapper.resultMessage ='';
                 resWrapper.fieldName = JSON.serialize(reasonOptions);
                 resWrapper.fieldName2 = JSON.serialize(typeOptions);
                 resWrapper.fieldName3 = JSON.serialize(String.valueOf(o.XC_Segment__c == 'B2C'));
        }
        return resWrapper;
    }

     /**
    * @author Andrea Di Cicco
    * @date Creation 31/07/2020
    * @date Modification dd/mm/yyyy
    * @description change OwnerOnOrder
    * @param accountId
    * @return XC_UTIL_ResultWrapper
    */ 
    @AuraEnabled 
    public static String getContactLists(String selectedAccount){
        Map<String, Object> returnValue = new Map<String, Object>();
        List<AccountContactRelation > contactList = new List<AccountContactRelation >();
        List<Map<String, String>> contactToComponent = new List<Map<String, String>>();
        try{
            
            if(Schema.sObjectType.AccountContactRelation.isAccessible()){
                contactList = [SELECT Contact.Name, ContactId FROM  AccountContactRelation WHERE AccountId = : selectedAccount];
            }
            for(AccountContactRelation contact : contactList){
                Map<String, String> contactInfo = new Map<String, String>();
                contactInfo.put('key', contact.ContactId);
                contactInfo.put('value', contact.Contact.Name);
                contactToComponent.add(contactInfo);
            } 
        }catch(Exception e){
            System.debug(e.getMessage());
        }
        returnValue.put('contactList', contactToComponent);
        return JSON.serialize(returnValue);
    }

 /**
    * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
    * @date Creation 04/09/2019
    * @date Modification dd/mm/yyyy
    * @description change OwnerOnOrder
    * @param configurationId
    * @param accountId
    * @param reason
    * @param type
    * @return XC_UTIL_ResultWrapper
    */ 
    @AuraEnabled 
    public static XC_UTIL_ResultWrapper changeOwnerOnOrder(String configurationId,String accountId,String reason, String type){
        
        System.debug('In changeOwnerOnOrder con reason '+reason+' AND type= '+type);

        SavePoint sp = DataBase.setSavePoint();
        
        XC_UTIL_ResultWrapper resWrapper = new XC_UTIL_ResultWrapper();
        try{

            /*get addresses and copy them*/
            List<NE__Order__c> currentOrd = [SELECT ID,XC_DeliveryAddress__c,XC_InstallationAddress__c 
            FROM NE__Order__c WHERE Id = :configurationId LIMIT 1];
            List<Contact> primaryContactOfAccount = [SELECT ID FROM Contact WHERE AccountId = :accountId AND XC_PrimaryContact__c = true];

            XC_Address__c deliveryAddr = (XC_Address__c) XC_UTIL_Sobject.selectAllFields(currentOrd[0].XC_DeliveryAddress__c)[0];
            XC_Address__c cloneDelivery = deliveryAddr.clone(false,false,false,false);
            cloneDelivery.XC_Account__c = accountId;
            cloneDelivery.XC_External_ID__c = null;
            cloneDelivery.XC_External_ID_delta__c = null;
            
            //making  inserts to retrieve the ids and update the order
            //XC_UTIL_Sobject.WrapperResult addressInsertResult = XC_UTIL_Sobject.insertRecord(cloneDelivery);
            //Check if address already exist
            String idAddressNewOwner = '';
            String  existingAddress = checkAddressExist(cloneDelivery,  accountId);
            if(existingAddress != ''){
                idAddressNewOwner = existingAddress;
            }else{
                //making  inserts to retrieve the ids and update the order
                XC_UTIL_Sobject.WrapperResult addressInsertResult = XC_UTIL_Sobject.insertRecord(cloneDelivery);
                if(!addressInsertResult.success){
                    resWrapper = new XC_UTIL_ResultWrapper(addressInsertResult);
                    return resWrapper;
                }
                idAddressNewOwner = addressInsertResult.recordId;
            }
            
            NE__Order__c ord = new NE__Order__c(id=configurationId, 
            NE__AccountId__c=accountId, NE__BillAccId__c=accountId,  NE__ServAccId__c=accountId,
            XC_ReasonOfChangeOwnership__c=reason, XC_Type__c=type,
            XC_DeliveryAddress__c= idAddressNewOwner, 
            XC_InstallationAddress__c=  idAddressNewOwner, 
            XC_ChangedContact__c=primaryContactOfAccount[0].Id,
            NE__BillingProfId__c = null
            );
            
            XC_UTIL_Sobject.WrapperResult wr = XC_UTIL_Sobject.updateRecord(ord);
            resWrapper = new XC_UTIL_ResultWrapper(wr);
            
            System.debug('changeOwnerOnOrder Result = '+resWrapper);
            if(!resWrapper.success){
                return resWrapper;
            }



            
            List<NE__OrderItem__c> orderItems = [SELECT id FROM NE__OrderItem__c WHERE NE__OrderId__c =:configurationId];
            for(NE__OrderItem__c oi : orderItems){
                oi.NE__Account__c = accountId;
                oi.NE__Billing_Account__c = accountId;
                oi.NE__Service_Account__c = accountId;
                oi.XC_BillingProfileLineItem__c = null;
                oi.XC_PaymentMethod__c = null;
                oi.XC_Installation_Address__c = idAddressNewOwner;  //addressInsertResult.recordId;

            }
            XC_UTIL_Sobject.updateListRecords(orderItems);

            

            /**Update On Asset OwnerShip**/
            // List<Asset> astToUpdate = new List<Asset>();
            // for(Asset connectAsset : [SELECT Id,AccountId,NE__Billing_Account__c,NE__Service_Account__c From Asset WHERE NE__Order_Config__c = : configurationId]){
            //     connectAsset.AccountId = accountId;
            //     connectAsset.NE__Billing_Account__c = accountId;
            //     connectAsset.NE__Service_Account__c = accountId;
            //     connectAsset.XC_Address__c=addressInsertResult.recordId;
            //     astToUpdate.add(connectAsset);
            // }
            // List<XC_UTIL_Sobject.WrapperResult> asstUpdate = XC_UTIL_Sobject.updateListRecords(astToUpdate);

        }catch(Exception e){

            Database.rollback(sp);
            System.Debug('EXCEPTION ON CHANGE OF OWNERSHIP COMPONENT ' + + e.getStackTraceString());
            throw new AuraHandledException('An Error Has Occured During Change of OwnerShip');

        }
        return resWrapper;
    }

     /**
    * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
    * @date Creation 04/09/2019
    * @date Modification dd/mm/yyyy
    * @description change OwnerOnOrder
    * @param configurationId
    * @param accountId
    * @param reason
    * @param type
    * @param contactId
    * @return XC_UTIL_ResultWrapper
    */ 
    @AuraEnabled 
    public static XC_UTIL_ResultWrapper changeOwnerAndContactOnOrder(String configurationId,String accountId,String reason, String type, String contactId){
        
        System.debug('In changeOwnerOnOrder con reason '+reason+' AND type= '+type);

        SavePoint sp = DataBase.setSavePoint();
        String existingAddress = '';
        String idAddressNewOwner = '';
        XC_UTIL_Sobject.WrapperResult addressInsertResult = new XC_UTIL_Sobject.WrapperResult();
        XC_UTIL_ResultWrapper resWrapper = new XC_UTIL_ResultWrapper();
        try{

            /*get addresses and copy them*/
            List<NE__Order__c> currentOrd = [SELECT ID,XC_DeliveryAddress__c,XC_InstallationAddress__c, XC_Segment__c
            FROM NE__Order__c WHERE Id = :configurationId LIMIT 1];

            XC_Address__c deliveryAddr = (XC_Address__c) XC_UTIL_Sobject.selectAllFields(currentOrd[0].XC_DeliveryAddress__c)[0];
            XC_Address__c cloneDelivery = deliveryAddr.clone(false,false,false,false);
            cloneDelivery.XC_Account__c = accountId;
            cloneDelivery.XC_External_ID__c = null;
            cloneDelivery.XC_External_ID_delta__c = null;
            if(currentOrd.get(0).XC_Segment__c == 'B2B' || currentOrd.get(0).XC_Segment__c == 'B2G'){
                existingAddress = checkAddressExist(cloneDelivery,  accountId);
            }
            if(existingAddress != ''){
                idAddressNewOwner = existingAddress;
            }else{
            //making  inserts to retrieve the ids and update the order
                addressInsertResult= XC_UTIL_Sobject.insertRecord(cloneDelivery);
                idAddressNewOwner = addressInsertResult.recordId;
            }
            
            NE__Order__c ord = new NE__Order__c(id=configurationId, 
            NE__AccountId__c=accountId, NE__BillAccId__c=accountId,  NE__ServAccId__c=accountId,
            XC_ReasonOfChangeOwnership__c=reason, XC_Type__c=type,
            XC_DeliveryAddress__c=idAddressNewOwner,
            XC_InstallationAddress__c=idAddressNewOwner,
            XC_ChangedContact__c=contactId,
            NE__BillingProfId__c = null
            );
            
            XC_UTIL_Sobject.WrapperResult wr = XC_UTIL_Sobject.updateRecord(ord);
            resWrapper = new XC_UTIL_ResultWrapper(wr);
            
            System.debug('changeOwnerOnOrder Result = '+resWrapper);
            if(!resWrapper.success){
                return resWrapper;
            }



            
            List<NE__OrderItem__c> orderItems = [SELECT id FROM NE__OrderItem__c WHERE NE__OrderId__c =:configurationId];
            for(NE__OrderItem__c oi : orderItems){
                oi.NE__Account__c = accountId;
                oi.NE__Billing_Account__c = accountId;
                oi.NE__Service_Account__c = accountId;
                oi.XC_BillingProfileLineItem__c = null;
                oi.XC_PaymentMethod__c = null;
                oi.XC_Installation_Address__c = idAddressNewOwner;
            }
            XC_UTIL_Sobject.updateListRecords(orderItems);
            if(currentOrd.get(0).XC_Segment__c == 'B2B' || currentOrd.get(0).XC_Segment__c == 'B2G'){
                cloneContract( currentOrd.get(0).id,  accountId);
            }
            /**Update On Asset OwnerShip**/
            // List<Asset> astToUpdate = new List<Asset>();
            // for(Asset connectAsset : [SELECT Id,AccountId,NE__Billing_Account__c,NE__Service_Account__c From Asset WHERE NE__Order_Config__c = : configurationId]){
            //     connectAsset.AccountId = accountId;
            //     connectAsset.NE__Billing_Account__c = accountId;
            //     connectAsset.NE__Service_Account__c = accountId;
            //     connectAsset.XC_Address__c=addressInsertResult.recordId;
            //     astToUpdate.add(connectAsset);
            // }
            // List<XC_UTIL_Sobject.WrapperResult> asstUpdate = XC_UTIL_Sobject.updateListRecords(astToUpdate);

        }catch(Exception e){

            Database.rollback(sp);
            System.Debug('EXCEPTION ON CHANGE OF OWNERSHIP COMPONENT ' + + e.getStackTraceString());
            throw new AuraHandledException('An Error Has Occured During Change of OwnerShip');

        }
        return resWrapper;
    }

    /**
    * @author Andrea Di Cicco
    * @date Creation 14/09/2019
    * @date Modification dd/mm/yyyy
    * @description change OwnerOnOrder
    * @param addressToClone
    * @param accountId
    * @return if the address already exists, the method returns the id of that address
    */ 
    public static String checkAddressExist(XC_Address__c addressToClone, String accountId){
        List<XC_Address__c> listExistingAddresses = new List<XC_Address__c>();
        String keyAddressToClone1 = addressToClone.XC_AddressCountry__c + ' ' + 
                                    addressToClone.XC_City__c + ' ' +
                                    addressToClone.XC_AddressProvince__c + ' ' +
                                    addressToClone.XC_StreetNumber__c;
        String keyAddressToClone2 = addressToClone.XC_Address__c + ' ' + 
                                    addressToClone.XC_StreetTypeText__c + ' ' +  
                                    addressToClone.XC_Municipality__c + ' ' + 
                                    addressToClone.XC_PostalCode__c;
        if(!Schema.sObjectType.XC_Address__c.isAccessible()){ 
            return '';
        } 
        listExistingAddresses = [SELECT Id, XC_AddressCountry__c, XC_City__c, XC_AddressProvince__c, XC_StreetNumber__c, XC_Address__c, XC_StreetTypeText__c, XC_Municipality__c, XC_PostalCode__c FROM XC_Address__c WHERE XC_Account__c =: accountId];

        for(XC_Address__c address : listExistingAddresses){
            String keyForDuplication1 = address.XC_AddressCountry__c + ' ' + 
                                        address.XC_City__c + ' ' +
                                        address.XC_AddressProvince__c + ' ' +
                                        address.XC_StreetNumber__c;
            String keyForDuplication2 = address.XC_Address__c + ' ' + 
                                        address.XC_StreetTypeText__c + ' ' +  
                                        address.XC_Municipality__c + ' ' +
                                        address.XC_PostalCode__c;

            if(keyForDuplication1 == keyAddressToClone1 && keyForDuplication2 == keyAddressToClone2){
                return address.id;
            }
        }

        return '';
    }
    /**
    * @author Andrea Di Cicco
    * @date Creation 14/09/2019
    * @date Modification dd/mm/yyyy
    * @description change OwnerOnOrder
    * @param orderId
    * @param accountId
    */ 
    public static void cloneContract(String orderId, String accountId){
        Contract clonedContract = new Contract();
        Asset changeOrderAsset = new Asset();
        Contract contr = new Contract();
        if(Schema.sObjectType.Asset.isAccessible()){
            changeOrderAsset = [ Select id,  XC_Original_Configuration_Item__r.NE__OrderId__c from Asset where NE__Order_Config__c =: orderId and ParentId = null limit 1];
            contr = [SELECT id, XC_Configurations__c  FROM Contract WHERE XC_Configurations__c  = : changeOrderAsset.XC_Original_Configuration_Item__r.NE__OrderId__c LIMIT 1];

        }
        Contract originaryContract = (Contract) XC_UTIL_Sobject.selectAllFields(contr.id)[0];
        clonedContract = originaryContract.clone(false,false,false,false);
        clonedContract.AccountId = accountId;
        clonedContract.XC_ContractAccount__c = accountId;
        clonedContract.XC_Configurations__c = orderId;
        clonedContract.status = 'Pending';
        XC_UTIL_Sobject.insertRecord(clonedContract) ;
        changeOrderAsset.XC_Contract__c = clonedContract.id;
        XC_UTIL_Sobject.updateRecord(changeOrderAsset);
    }
}