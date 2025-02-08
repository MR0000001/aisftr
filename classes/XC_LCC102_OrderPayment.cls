/**
* @author Lorenzo Orlanducci -lorenzo.orlanducci@nttdata.com & Sara Miozza - sara.miozza@nttdata.com
* @date Creation 05/04/2019
* @date Modification 25/04/2020 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @description XC_LCC102_OrderPayment - Custom controller for the lightning component XC_LCP102_OrderPayment
*/

public without sharing class XC_LCC102_OrderPayment {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC102_OrderPayment');
    //[ BEGIN, arjun.raoh@accenture.com, 06/05/2022, ID-2 Update Select Payment Method, NR2453, R2-2022 ]
    private final static String ALPHA_NUMERIC_REGEX = '^(?=.*[a-zA-Z])(?=.*[0-9])[A-Za-z0-9]+$';
    //[ END, arjun.raoh@accenture.com, 06/05/2022, ID-2 Update Select Payment Method, NR2453, R2-2022 ]

    /** @description ConfigWrapper */
    public class ConfigWrapper {
        @AuraEnabled
        public String accountId;
        @AuraEnabled
        public Map<Id, NE__OrderItem__c> mapIdOrderItem;
        @AuraEnabled
        public Map<String, List<XC_UTIL_PaymentMethodFilter.MopWrapper>> mapIdPaymentMethod;
        @AuraEnabled
        public String contactId;
        @AuraEnabled
        public String legalEntityId;
        @AuraEnabled
        public String legalEntityName;
        @AuraEnabled
        public Boolean success;
        @AuraEnabled
        public String errorMessage;
        @AuraEnabled
        public Map<String,Object> filteredMopList;
    }

    /** @description BillingAddressWrapper */
    public class BillingAddressWrapper {
        @AuraEnabled
        public Map<String, String> BillingAddress;
        @AuraEnabled
        public List<Map<String, String>> BillingAddressPickList;
    }

    /**
    * @author Lorenzo Orlanducci -lorenzo.orlanducci@nttdata.com & Sara Miozza - sara.miozza@nttdata.com
    * @description  Method to retrieve a list of Configuration Items from a Configuration Id
    * @param recordId - String
    * @return String
    */
    @AuraEnabled
    public static String getListConfItem(String recordId) {
        ConfigWrapper wr = new ConfigWrapper();
        wr.success = true;
        Map<Id, NE__OrderItem__c> mapIdOrderItem = new Map<Id, NE__OrderItem__c>();
        // Map<Id, List<String>> mapIdPaymentMethod = new Map<Id, List<String> >();
        List<NE__OrderItem__c> orderItems = new List<NE__OrderItem__c>();
        Set<String> notAvailableTypes = new Set<String>{'Substitution (Malfunction)','Service Upgrade/Downgrade'};
        if (recordId == null) {
            return null;
        }
        Map<Id, NE__Order__c> confsMap = new Map<Id, NE__Order__c>([
                SELECT id,NE__Type__c,XC_Subtype__c,NE__AccountId__c,NE__OptyId__c,NE__OptyId__r.XC_Contact__c,NE__OptyId__r.XC_LegalEntity__c,XC_Segment__c,
                XC_ChangedContact__c,
                (SELECT id, NE__Parent_Order_Item__c, XC_ProvisioningSpareParts__c, Name,NE__OrderId__r.XC_Status__c,XC_ForcePaymentMethodEdit__c,
                        XC_Product_Type__c,XC_Product_Subtype__c,XC_IsAProduct__c,NE__Bundle_Configuration__c, XC_Segment__c,XC_BillingProfileLineItem__r.XC_PaymentTerm__c, // [ BEGIN, mridul.b.jain@accenture.com, 06/01/2022, ID-1 Select Payment Method, NR2073, ENEL X - r12 ]
                        NE__BillingProfId__c,NE__ProdName__c,XC_BillingModel__c, RecordType.DeveloperName, XC_PaymentMethod__c,XC_BillingProfileLineItem__c, NE__Billing_Account__c, NE__Account__c   
                FROM NE__Order_Items__r WHERE XC_PaymentMethod__c != 'No Payment Required')
                FROM NE__Order__c
                where id = :recordId
                LIMIT 1
        ]);

        List<NE__Order__c> confs = confsMap.values();
        // Manage change order cases
        if(notAvailableTypes.contains(confs[0].XC_Subtype__c) && confs[0].NE__Type__c.equalsIgnoreCase('ChangeOrder')){
            wr.success = false;
            wr.errorMessage = 'Error';//Label.XC_CL_LCP102_ErrorChangeOrder;
        }
        wr.contactId = String.isBlank(confs[0].XC_ChangedContact__c) ? confs[0].NE__OptyId__r.XC_Contact__c : confs[0].XC_ChangedContact__c;
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@Contact' + wr.contactId);
        wr.legalEntityId = confs[0].NE__OptyId__r.XC_LegalEntity__c;
        wr.legalEntityName = confs[0].NE__OptyId__r.XC_LegalEntity__c;
        // wr.filteredMopList = getPaymentMethodsPicklist(confs[0].NE__OptyId__r.XC_LegalEntity__c); -- Not used anymore
        orderItems = confs[0].NE__Order_Items__r;


        for(NE__OrderItem__c oi : orderItems) {

            if(oi.XC_Segment__c != 'B2C' && String.isBlank(oi.XC_BillingModel__c) && oi.RecordType.DeveloperName !='Technical_Item'){
                wr.success = false;
                wr.errorMessage = Label.XC_CL_CheckBillingModel;
            }


            if(
                   oi.NE__OrderId__r.XC_Status__c  != Label.XC_CL_Configuration_OrderInProgress
                && oi.NE__OrderId__r.XC_Status__c  != Label.XC_CL_Configuration_Draft
                && oi.NE__OrderId__r.XC_Status__c  != Label.XC_CL_Configuratione_QuoteNotifiedToClient)
            {
                wr.success = false;
                wr.errorMessage = 'You cannot change the Payment Method if the Provisioning has started';
                //return JSON.serialize(wr);
            }



            if (oi.XC_Product_Type__c == 'Bundle' && oi.NE__Bundle_Configuration__c == null) {
                mapIdOrderItem.put(oi.id, oi);
                // List<String> availablePaymentMethod = retrievePaymentMethodFiltered(oi.XC_BillingModel__c);

                // mapIdPaymentMethod.put(oi.id, oiItemsAvailableMopsMap.get(oi.Id));
                //break;
            }
            if ((oi.NE__Parent_Order_Item__c == null && oi.NE__Bundle_Configuration__c == null && oi.XC_Product_Type__c != 'Billing' && oi.XC_Product_Type__c != 'Technical' && oi.XC_BillingModel__c != 'Capex' )
                    || (oi.XC_ProvisioningSpareParts__c && oi.XC_Segment__c =='B2C')) {
                mapIdOrderItem.put(oi.id, oi);
                // List<String> availablePaymentMethod = retrievePaymentMethodFiltered(oi.XC_BillingModel__c);
                // mapIdPaymentMethod.put(oi.id, availablePaymentMethod);
            }
        }

        wr.mapIdOrderItem = mapIdOrderItem;
        wr.mapIdPaymentMethod = XC_UTIL_PaymentMethodFilter.getAvailabeMopsForOrderItems(wr.legalEntityName, confs[0].XC_Segment__c, orderItems);
        wr.accountId = confs[0].NE__AccountId__c;
        return JSON.serialize(wr);
    }

    /**
    * @author Lorenzo Orlanducci -lorenzo.orlanducci@nttdata.com & Sara Miozza - sara.miozza@nttdata.com
    * @description Method to set a wrapper to get the result of the update
    * @param confBillingMap - BillingAddressWrapper
    * @param orderId - String
    * @param billingAddressId - String
    * @return XC_UTIL_ResultWrapper
    */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper updateConfItem(Map<String, List<String>> confBillingMap, String orderId, String billingAddressId) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@enter in updateConfItem');
        XC_UTIL_ResultWrapper wr = new XC_UTIL_ResultWrapper();
        wr.success = false;

        List<NE__OrderItem__c> confItem = new List<NE__OrderItem__c>([
                SELECT id, XC_Product_Type__c, XC_PaymentMethod__c, XC_BillingProfileLineItem__c, XC_BillingModel__c, NE__Bundle_Configuration__c, 
                        NE__OrderId__c, XC_IsAProduct__c, NE__OrderId__r.NE__OptyId__r.Account.IdentityNumber__c,
                        NE__Account__c, NE__Account__r.XC_Segment__c,NE__Account__r.XC_Country__c, //[ arjun.raoh@accenture.com, 06/05/2022, ID-2 Update Select Payment Method, NR2453, R2-2022 ]
                        XC_Country__c , XC_Segment__c //gaurav.tejpal@accenture.com, 06/04/2022,Enel X - Multiple sales
                FROM NE__OrderItem__c
                WHERE id in: confBillingMap.keySet()
        ]);
        
        List<NE__OrderItem__c> confItemList = new List<NE__OrderItem__c>();
        List<NE__OrderItem__c> confItemListCommodityBill = new List<NE__OrderItem__c>();//gaurav.tejpal@accenture.com, 06/04/2022,Enel X - Multiple sales
        for (NE__OrderItem__c oi : confItem) {   // key: NE__OrderItem__c Id
            oi.XC_PaymentMethod__c = confBillingMap.get(oi.id)[0];
            oi.XC_BillingProfileLineItem__c = String.isNotBlank(confBillingMap.get(oi.id)[1]) ? confBillingMap.get(oi.id)[1] : null;
            Map<String,Object> installmentPlanFields = String.isNotBlank(confBillingMap.get(oi.id)[2]) ? (Map<String,Object>) JSON.deserializeUntyped(confBillingMap.get(oi.id)[2]) : new Map<String,Object>();

            oi.XC_InstallmentPlanType__c = String.valueOf(installmentPlanFields.get('installmentType'));
            oi.InstallmentDivisionTax__c  = String.valueOf(installmentPlanFields.get('installmentTax'));
            oi.XC_InstallmentFrequency__c = String.valueOf(installmentPlanFields.get('installmentFreq'));
            oi.XC_InstallmentsNumber__c	 = String.valueOf(installmentPlanFields.get('installmentNum'));
            oi.XC_InstallmentRate__c = String.valueOf(installmentPlanFields.get('installmentRate'));
            oi.XC_Interests_Index__c = String.valueOf(installmentPlanFields.get('interestIndex'));

            if(installmentPlanFields.get('impliedInterest') != null) {
                oi.XC_ImpliedInterest__c = Decimal.valueOf(String.valueOf(installmentPlanFields.get('impliedInterest')));
            }
            confItemList.add(oi);
            //[ START, gaurav.tejpal@accenture.com, 06/04/2022,Enel X - Multiple sales] -->
            if(!confBillingMap.isEmpty() && confBillingMap.get(oi.id)[0] == Constants.ORDER_PAYMENT_METHOD_TYPE 
               && oi.XC_Country__c == Constants.BRAZIL && oi.XC_Segment__c =='B2C' && oi.XC_Product_Type__c != Constants.ORDER_PRODUCT_TYPE){
                confItemListCommodityBill.add(oi);
            }
            //[ END, gaurav.tejpal@accenture.com, 06/04/2022,Enel X - Multiple sales] -->
        }
        //[ BEGIN, arjun.raoh@accenture.com, 06/05/2022, ID-2 Update Select Payment Method, NR2453, R2-2022 ]
        if(!confItem.isEmpty()) {
            List<Contact> contactList = [SELECT Id, XC_ContactDocumentNumber__c FROM Contact WHERE XC_PrimaryContact__c = TRUE AND AccountId = :confItem[0].NE__Account__c WITH SECURITY_ENFORCED];
            if(!contactList.isEmpty() && confItem[0].XC_PaymentMethod__c == 'Direct Debt' && confItem[0].NE__Account__r.XC_Segment__c == 'B2B' && confItem[0].NE__Account__r.XC_Country__c == 'Italy' && (String.isBlank(contactList[0].XC_ContactDocumentNumber__c) || !Pattern.matches(ALPHA_NUMERIC_REGEX, contactList[0].XC_ContactDocumentNumber__c))) {
                wr.success = false;
                wr.resultMessage = Label.XC_CL_ContactDocumentNumberIsNotAlphanumeric;
                return wr;
            }
        }
        //[ END, arjun.raoh@accenture.com, 06/05/2022, ID-2 Update Select Payment Method, NR2453, R2-2022 ]
         //[ BEGIN, gaurav.tejpal@accenture.com, 06/04/2022,Enel X - Multiple sales] -->
         Boolean showCommodityBillWarning=false;
         if(!confItemListCommodityBill.isEmpty()){
             if(confItemListCommodityBill.size() >1){ 
                 showCommodityBillWarning=true;           
             }else if (confItemListCommodityBill.size() == 1){
                 List<NE__OrderItem__c> orderItemList = manageProduct(orderId);
                 if(!orderItemList.isEmpty()){
                     for(NE__OrderItem__c oi : orderItemList ){
                         if(confItemListCommodityBill[0].id != oi.Id ){
                             showCommodityBillWarning=true;
                             break;
                         }
                     }
                 }
             }
             if(showCommodityBillWarning){
                 wr.success = false;
                 wr.resultMessage = Label.XC_WarningCommodityBill;
                 return wr;
             }
         }  
         //[ END, gaurav.tejpal@accenture.com, 06/04/2022,Enel X - Multiple sales] -->
        manageBundle(confItemList);
        manageTechnicalItem(confItemList);
        List<String> paymentWithMandatoryDoc = new List<String>();
        List<XC_DocumentByPaymentMethod__mdt> paymentMetadataMethods = new List<XC_DocumentByPaymentMethod__mdt>([
                SELECT id, XC_PaymenMethod__c
                FROM XC_DocumentByPaymentMethod__mdt
        ]);
        for(XC_DocumentByPaymentMethod__mdt dpm : paymentMetadataMethods) {
            paymentWithMandatoryDoc.add(dpm.XC_PaymenMethod__c);
        }

        Map<String, String> mapIdDocNumber = new Map<String, String>();
        for (NE__OrderItem__c stm : confItemList) {
            mapIdDocNumber.put(stm.Id, stm.NE__OrderId__r.NE__OptyId__r.Account.IdentityNumber__c);
        }

        for (NE__OrderItem__c oi : confItem) {
            if (paymentWithMandatoryDoc.contains(oi.XC_PaymentMethod__c)) {
                if(mapIdDocNumber.containsKey(oi.Id)){
                    if (mapIdDocNumber.get(oi.Id) == null) {
                        wr.typeMessage = 'noDocument';
                        wr.resultMessage = Label.XC_CL_WarningPaymentMethod + oi.XC_PaymentMethod__c + Label.XC_CL_DocumentMandatory + ' Do you want to insert it?';
                        return wr;
                    }
                }
            }
        }

        //cleaning list from eventual duplicates
        //cleaning list from eventual duplicates
        Map<Id,NE__OrderItem__c> oisToUpdate = new Map<id,NE__OrderItem__c>();
        for(NE__OrderItem__c oi : confItemList){
            oisToUpdate.put(oi.Id,oi);
        }

        List<XC_UTIL_Sobject.WrapperResult> wrapperResultList = XC_UTIL_Sobject.updateListRecords(oisToUpdate.values());
        if(!XC_UTIL_Sobject.checkDMLResults(wrapperResultList)) {
            wr.resultMessage = Label.XC_CL_ConfItem_Warning + wrapperResultList[0].errorMessage;
            return wr;
        }

        // Update Billing Address for Order:
        if(String.isNotBlank(billingAddressId)) {
            NE__Order__c order = new NE__Order__c(Id = orderId);
            order.XC_OrderBillingAddress__c = billingAddressId;
            XC_UTIL_Sobject.updateRecord(order);
        }
        wr.success = true;
        wr.resultMessage = Label.XC_CL_ConfItem_UpdateOk;
        return wr;
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date 20/11/2019
    * @description Method for manage Technical Items from Select Payment Method component
    * @param listItems - List<NE__OrderItem__c>
    */
    public static void manageTechnicalItem(List<NE__OrderItem__c> listItems) {
        /*if(listItems[0].XC_Product_Type__c != Label.XC_CL_Technical) {
            return;
        }

        List<NE__OrderItem__c> listTechnicalOrderItemByOrder = new List<NE__OrderItem__c>([
                SELECT Id, NE__Bundle_Configuration__c, NE__OrderId__c, XC_IsAProduct__c, XC_PaymentMethod__c,
                        XC_BillingProfileLineItem__c, XC_Product_Type__c,XC_BillingModel__c, NE__OrderId__r.NE__OptyId__r.Account.IdentityNumber__c
                FROM NE__OrderItem__c
                WHERE NE__OrderId__c = :listItems[0].NE__OrderId__c AND Id != :listItems[0].Id
        ]);*/

        // __________ NM LR - 2020/05/10 __________     Fix for not update the bundle in the same order
        NE__OrderItem__c tecProduct;
        for(NE__OrderItem__c oi : listItems) {
            if(oi.XC_Product_Type__c == Label.XC_CL_Technical) {
                tecProduct = oi;
                break;
            }
        }
        if(tecProduct == null) {
            return;
        }

        List<NE__OrderItem__c> listTechnicalOrderItemByOrder = new List<NE__OrderItem__c>([
                SELECT Id, NE__Bundle_Configuration__c, NE__OrderId__c, XC_IsAProduct__c, XC_PaymentMethod__c,
                        XC_BillingProfileLineItem__c, XC_Product_Type__c,XC_BillingModel__c, NE__OrderId__r.NE__OptyId__r.Account.IdentityNumber__c
                FROM NE__OrderItem__c
                WHERE NE__OrderId__c = :tecProduct.NE__OrderId__c AND Id != :tecProduct.Id AND XC_Product_Type__c = :Label.XC_CL_Technical
        ]);
        // __________ NM LR - 2020/05/10 __________

        if(listTechnicalOrderItemByOrder.isEmpty()) {
            return;
        }

        List<NE__OrderItem__c> listOrderItemToAdd = new List<NE__OrderItem__c>();
        for(NE__OrderItem__c orderItem : listTechnicalOrderItemByOrder) {
            orderItem.XC_BillingModel__c = tecProduct.XC_BillingModel__c;
            orderItem.XC_PaymentMethod__c = tecProduct.XC_PaymentMethod__c;
            orderItem.XC_BillingProfileLineItem__c = tecProduct.XC_BillingProfileLineItem__c;
            listOrderItemToAdd.add(orderItem);
        }
        listItems.addAll(listOrderItemToAdd);
    }

    /**
    * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
    * @description  Method for manage bundle from Select Payment Method component
    * @param bundle - List<NE__OrderItem__c>
    */
    public static void manageBundle(List<NE__OrderItem__c> bundle) {
        List<String> bundleIds = new List<String>();
        for (NE__OrderItem__c oi : bundle) {
            if (oi.XC_Product_Type__c == 'Bundle') {
                bundleIds.add(oi.Id);
            }
        }
        List<NE__OrderItem__c> orderItemToUpdate = new List<NE__OrderItem__c>();
        Map<Id,NE__OrderItem__c> orderItemProducts = new Map<Id,NE__OrderItem__c>([
                SELECT Id, NE__Bundle_Configuration__c,NE__OrderId__c,XC_IsAProduct__c,XC_PaymentMethod__c,
                        XC_BillingProfileLineItem__c, XC_Product_Type__c,XC_BillingModel__c, NE__OrderId__r.NE__OptyId__r.Account.IdentityNumber__c
                FROM NE__OrderItem__c
                WHERE NE__Bundle_Configuration__c IN:bundleIds
        ]);

        XC_UTIL_Debug.debug(DEBUGACTIVE, '---orderItemProducts contiene ' + orderItemProducts.values());
        for (NE__OrderItem__c ordIt : orderItemProducts.values()) {
            NE__OrderItem__c bundleItem = new NE__OrderItem__c(Id = ordIt.NE__Bundle_Configuration__c);
            //ordIt.XC_PaymentMethod__c = confItemList[0].XC_PaymentMethod__c;
            //ordIt.XC_BillingProfileLineItem__c = confItemList[0].XC_BillingProfileLineItem__c;
            for (NE__OrderItem__c o : bundle) {
                if (o.id == bundleItem.id) {
                    //dp o.XC_BillingModel__c = ordIt.XC_BillingModel__c;
                    ordIt.XC_BillingModel__c = o.XC_BillingModel__c;
                    ordIt.XC_PaymentMethod__c = o.XC_PaymentMethod__c;
                    ordIt.XC_BillingProfileLineItem__c = o.XC_BillingProfileLineItem__c;
                    if (ordIt.Id!=o.Id) {
                        orderItemToUpdate.add(ordIt);
                    }
                }
            }
        }
        bundle.addAll(orderItemToUpdate);
    }

    /**
    * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
    * @description Method to create new personal document from Select Payment Method component.
    * @param orderId - String
    * @param personalDocValues - String
    * @return XC_UTIL_ResultWrapper
    */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper newPersonalDocument(String orderId, String personalDocValues) {
        XC_UTIL_ResultWrapper wr = new XC_UTIL_ResultWrapper();
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'In newPersonalDocument con orderId= ' + orderId);
        NE__Order__c order = [
                SELECT id, NE__OptyId__c, NE__OptyId__r.AccountId, NE__OptyId__r.XC_Contact__c,
                        NE__OptyId__r.Account.IdentityType__c, NE__OptyId__r.Account.IdentityNumber__c
                FROM NE__Order__c
                WHERE Id = :orderId
                limit 1
        ];
        String country = null;
        String docNumber = null;
        String docType = null;
        Map<String, Object> optionsMap = (Map<String, Object>) JSON.deserializeUntyped(personalDocValues);
        if (optionsMap.containsKey('docCountry')) {
            country = String.valueOf(optionsMap.get('docCountry'));
        }
        if (optionsMap.containsKey('docNumber')) {
            docNumber = String.valueOf(optionsMap.get('docNumber'));
        }
        if (optionsMap.containsKey('docType')) {
            docType = String.valueOf(optionsMap.get('docType'));
        }
        XC_PersonalDocument__c personalDoc = new XC_PersonalDocument__c(XC_Country__c = country, XC_DocumentType__c = docType, XC_DocumentNumber__c = docNumber,
                XC_Account__c = order.NE__OptyId__r.AccountId, XC_Contact__c = order.NE__OptyId__r.XC_Contact__c);
        if (order.NE__OptyId__r.AccountId != null) {
            Account a = new Account(id = order.NE__OptyId__r.AccountId);
            a.IdentityType__c = docType;
            a.IdentityNumber__c = docNumber;
            XC_UTIL_Sobject.updateRecord(a);
        }
        XC_UTIL_Sobject.WrapperResult insertRes = XC_UTIL_Sobject.insertRecord(personalDoc);
        wr = new XC_UTIL_ResultWrapper(insertRes);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'newPersonalDocument result = ' + wr);
        return wr;
    }

    /**
    * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
    * @description  Method to retrievePaymentMethodFiltered
    * @param billingValue - String
    * @return List<String>
    */
    // public static List<String> retrievePaymentMethodFiltered(String billingValue) {
    //     List<String> listActiveValues = new List<String>();
    //     if (billingValue == '3 years renting') {
    //         listActiveValues.add('SEPA');
    //         listActiveValues.add('CreditCard');
    //     }
    //     return listActiveValues;
    // }

    /**
    * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
    * @description  Method to populate Address Picklist
    * @param recordId - String
    * @return BillingAddressWrapper
    */
    @AuraEnabled
    public static BillingAddressWrapper populateAddressPick(String recordId) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'ENTRATO IN populateAddressPick');
        BillingAddressWrapper baw = new BillingAddressWrapper();
        List<Map<String, String>> addressMapList = new List<Map<String, String>>();
        if(!checkAccessibleConfiguration()) {
            return baw;
        }
        NE__Order__c order = [
            SELECT Id, NE__AccountId__c,NE__BillAccId__c,NE__Type__c,XC_Subtype__c, XC_OrderBillingAddress__c,XC_DeliveryAddress__c, XC_OrderBillingAddress__r.XC_FullAddress__c,XC_OrderBillingAddress__r.Name
            FROM NE__Order__c
            WHERE Id = :recordId
            LIMIT 1
        ];

        Map<Id, Account> accMap = new Map<Id, Account>([
                SELECT Id,Name, (SELECT Id, XC_FullAddress__c,Name FROM Addresses__r WHERE XC_BillingAddress__c = true AND CreatedById != '0051i000002EpBCAA0')
                FROM Account
                WHERE Id = :order.NE__BillAccId__c
                LIMIT 1
        ]);
        List<Account> accList = accMap.values();
        Account a = accList[0];
        for (XC_Address__c add : a.Addresses__r) {
            Map<String, String> addMap = new Map<String, String>();
            if(!String.isEmpty(order.XC_Subtype__c)  && !order.XC_Subtype__c.equalsIgnoreCase('Change of ownership')){
                addMap.put('key', add.Id);
                addMap.put('value', add.Name);
                addressMapList.add(addMap);
            }else{
                //if(order.XC_DeliveryAddress__c==add.Id){
                addMap.put('key', add.Id);
                addMap.put('value', add.Name);
                addressMapList.add(addMap);
                //}
            }
        }
        Map<String, String> addressMap = new Map<String, String>();
        addressMap.put('key', order.XC_OrderBillingAddress__c);
        addressMap.put('value', order.XC_OrderBillingAddress__r.Name);
        baw.BillingAddressPickList = addressMapList;
        baw.BillingAddress = addressMap;
        return baw;
    }

    /**
    * @description check if the XC_LCP103_ConfirmEditForm component must use billing account filters
    * @author pedro.danielalmeida@nttdata.com | 07-07-2022 
    * @param orderId 
    * @return Boolean 
    **/
    @AuraEnabled
    public static Boolean checkBillingAccount(String orderId){
        
        NE__Order__c ord = [
                SELECT Id,NE__OptyId__r.XC_Billing_Account__c
                FROM NE__Order__c
                WHERE Id = :orderId
        ];

        if (!String.isBlank(ord.NE__OptyId__r.XC_Billing_Account__c)) {
            return true;
        } else {
            return false;
        }
    }

    /**
    * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
    * @description  Method to check the accessibility
    * @return Boolean
    */
    public static Boolean checkAccessibleConfiguration() {
        Boolean res = false;
        if (Schema.sObjectType.NE__Order__c.isAccessible() &&
                Schema.sObjectType.NE__Order__c.isCreateable() &&
                Schema.sObjectType.NE__Order__c.isUpdateable()) {
            //  Schema.sObjectType.NE__Order__c.isDeletable() ){
            res = true;
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'NE_Order Accessible?' + res);
        return res;
    }

    /**
    * @description  Method to check the accessibility
    * @return Boolean
    */
    /*public static  Boolean checkAccessibleAccount(){
        Boolean res = false;
        if(Schema.sObjectType.Account.isAccessible() &&
           Schema.sObjectType.Account.isCreateable() &&
           Schema.sObjectType.Account.isUpdateable() &&
           Schema.sObjectType.Account.isDeletable() ){
               res = true;
           }
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Account Accessible?' +res);
        return res;
    }
    */

    /**
    * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
    * @description  Method to retrieve Billing Profiles from an order
    * @param recordId - String
    * @return List<NE__Billing_Profile__c>
    */
    @AuraEnabled
    public static List<NE__Billing_Profile__c> retrieveBillingProfile(String recordId) {
        List<NE__Billing_Profile__c> billingList = new List<NE__Billing_Profile__c>();
        if(!checkAccessibleConfiguration()) {
            return billingList;
        }
        String userLe = XC_UTIL_User.getLegalEntityFromUser();
        NE__Order__c conf = [SELECT Id,NE__AccountId__c, XC_Segment__c FROM NE__Order__c WHERE Id = :recordId LIMIT 1];
        if(!String.isBlank(conf.NE__AccountId__c)) {
            if(conf.XC_Segment__c == 'B2C'){
            Map<Id, Account> accMap = new Map<Id, Account>([SELECT Id, (SELECT Id, Name,NE__Payment__c,CreatedDate,NE__IBAN__c FROM NE__Billing_Profiles__r WHERE XC_LegalEntity__c = null OR XC_LegalEntity__c = : userLe ) FROM Account WHERE Id = :conf.NE__AccountId__c LIMIT 1]);
            List<Account> accList = accMap.values();
            billingList.addAll(accList[0].NE__Billing_Profiles__r);
            }else{
                Map<Id, Account> accMap = new Map<Id, Account>([SELECT Id, (SELECT Id, Name,NE__Payment__c,CreatedDate,NE__IBAN__c FROM NE__Billing_Profiles__r ) FROM Account WHERE Id = :conf.NE__AccountId__c LIMIT 1]);
            List<Account> accList = accMap.values();
            billingList.addAll(accList[0].NE__Billing_Profiles__r);
            }
                
        }
        return billingList;
    }

    /**
    * @description  Method to retrieve Display Density theme (Compact or Comfy).
    * @return Map<String, Object>
    */
    /*@AuraEnabled
    public static Map<String,Object> retrieveDisplayDensity(){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'entrato in retrieveDisplayDensity');
        HttpRequest tk = XC_UTIL_RESTCallout.getTokenRequest();
        String token = XC_UTIL_RESTCallout.retrieveToken(tk);
        String sfdcURL = URL.getSalesforceBaseUrl().toExternalForm();
        String restAPIURL = sfdcURL + '/services/data/v46.0/ui-api/themes/active';

        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setMethod('GET');

       // httpRequest.setHeader('Content-Type', 'application/json');
        httpRequest.setHeader('Authorization', 'Bearer '+token);
        httpRequest.setEndpoint(restAPIURL);
        String response = '';
        try {
            Http http = new Http();
            HttpResponse httpResponse = http.send(httpRequest);
            if (httpResponse.getStatusCode() == 200 ) {
                response = JSON.serializePretty( JSON.deserializeUntyped(httpResponse.getBody()) );
            } else {
                XC_UTIL_Debug.debug(DEBUGACTIVE, ' httpResponse ' + httpResponse.getBody() );
                throw new CalloutException( httpResponse.getBody() );
            }
       } catch( System.Exception e) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'ERROR: '+ e);
            response = e.getMessage();
            throw e;

        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, ' ** response ** : ' + response );
        Map<String,Object> values = (Map<String,Object>)JSON.deserializeUntyped(response);
        return values;
    }
    */

    /**
    *@author: francesco imperioli - fimperioli@deloitte.it
    *@description: retrieve the delivery address on the order to prepopulate billing profile creation
    *@history: 2019-05-12 creation
    **/
    @AuraEnabled
    public static String getSoldToAddress(String recordId){
        Map<String,Object> result = new Map<String,Object>();
        NE__Order__c currentOrder = [SELECT Id,XC_DeliveryAddress__c,XC_DeliveryAddress__r.Name FROM NE__Order__c WHERE Id = :recordId LIMIT 1];
        result.put('deliveryAddressId',currentOrder.XC_DeliveryAddress__c);
        result.put('deliveryAddressName',currentOrder.XC_DeliveryAddress__r.Name);
        return JSON.serialize(result);
    }

    /**
    *@author: francesco imperioli - fimperioli@deloitte.it
    *@description : retrieve dynamically available payment methods from Billing Profile Object.
    *@createddate 2019-11-06 - modified 18-11-2019 added legalentity filter
    **/
    @AuraEnabled
    public static Map<String,Object> getPaymentMethodsPicklist(String legalEntity){
        Map<String,Object> result= new Map<String,Object>();
        Schema.DescribeFieldResult fr = NE__Billing_Profile__c.NE__Payment__c.getDescribe();
        List<Schema.PicklistEntry> entryList = fr.getPicklistValues();
        for(Schema.PickListEntry ple : entryList){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'ple '+ple);
            result.put(ple.getLabel(),ple.getValue());
        }
        //XC_UTIL_Debug.debug(DEBUGACTIVE, 'metodi filtrati'+filterMopWithLegalEntity(legalEntity, result));
        List<String> listValues = filterMopWithLegalEntity(legalEntity, result.values());
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'VALORI FILITRATO ' + listValues);
        Map<String,Object> resultFilter= new Map<String,Object>();
        for(String s : result.keySet()){
            for(Object o : listValues){
                if(result.get(s)== String.valueOf(o)){
                    resultFilter.put(s,o);
                }
            }
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Result FILTER'+resultFilter);
        return resultFilter;
        //return filterMopWithLegalEntity(legalEntity, result.values());
        //return result;
    }

    /**
    *@author: francesco imperioli - fimperioli@deloitte.it
    *@description : filters available payment methods for legalentity - use custom metadata for the configuration
    *@createddate 2019-11-18
    **/
    private static List<String> filterMopWithLegalEntity(String legalEntity,List<Object> mops){
        List<String> mopsToString = new List<String>();
        for(Object m : mops){
            mopsToString.add(String.valueof(m));
        }
        if(String.isBlank(legalEntity)){
            return mopsToString;
        }
        List<XC_CM_Excluded_MOP_LE__mdt> excludedMopsConfs = [SELECT DeveloperName,XC_Excluded_Payment_Methods__c FROM XC_CM_Excluded_MOP_LE__mdt WHERE DeveloperName = :legalEntity LIMIT 1];
        if(excludedMopsConfs.isEmpty()){
            return mopsToString;
        }
        // extracting the list of unavailable payment methods from the custom metadata
        String[] excludedMops = excludedMopsConfs[0].XC_Excluded_Payment_Methods__c.split(';');
        if(excludedMops.isEmpty()){
            return mopsToString;
        }
        Set<String> excludedMopsSet = new Set<String>();
        excludedMopsSet.addAll(excludedMops);
        List<String> newMopList = new List<String>();
        for(String inputMop : mopsToString){
            //check if the mop is in the excluded mop set
            if(!excludedMopsSet.contains(inputMop)){
                newMopList.add(inputMop);
            }
        }
        return !newMopList.isEmpty() ? newMopList : mopsToString;
    }

    /**
    * @description return the legenda string based on available mops for LE
    * @author Francesco Imperioli - fimperioli@deloitte.it | 6/5/2020 
    * @param recordId 
    * @return String 
    **/
    @AuraEnabled
    public static String getSearchLegendaText(String recordId){
        String legenda = Label.XC_LCP102_LegendaTextInit + '\n\n';
        NE__Order__c currentOrd = [SELECT ID,XC_LegalEntity__c FROM NE__Order__c WHERE ID = :recordId LIMIT 1];
        Map<String,Object> mops = getPaymentMethodsPicklist(currentOrd.XC_LegalEntity__c);
        for(String label : mops.keySet()){
            legenda += label + ' -> ' + mops.get(label) + '\n';
        }

        return legenda;
    }

    /**
    * @description check if credit assigment survey has to be taken
    * @author Francesco Imperioli - fimperioli@deloitte.it | 27/5/2020 
    * @param recordId 
    * @return Map<String, Object> 
    **/
    @AuraEnabled
    public static Map<String,Object> checkIfCASurveyHasToBeExecuted(String recordId){

        Map<String,Object> result = new Map<String,Object>();
        result.put('surveyToBeDone',false);

        //getting order infos
        NE__Order__c currentOrd = [SELECT Id,XC_LegalEntity__c,XC_Segment__c, 
            (SELECT Id,Name,NE__ProdName__c 
            FROM NE__Order_Items__r 
            WHERE XC_Product_Subtype__c = :Label.XC_CL_ProductSubtypeIncentive 
            AND NE__Bundle_Configuration__c !=null 
            AND XC_CreditAssignmentSurvey__c != null) 
        FROM NE__Order__c WHERE Id = :recordId LIMIT 1];

        if(currentOrd.NE__Order_Items__r.isEmpty()){
            return result;
        }

        //check if legalentity has credit assignment
        List<XC_CM_LegalEntity_Configuration__mdt> leConf = [SELECT XC_LegalEntity__c,XC_AllowCreditAssignment__c 
        FROM XC_CM_LegalEntity_Configuration__mdt 
        WHERE XC_LegalEntity__c = :currentOrd.XC_LegalEntity__c 
        AND XC_Stream__c = :currentOrd.XC_Segment__c 
        AND XC_OrgId__c = :UserInfo.getOrganizationId() LIMIT 1];

        if(leConf[0].XC_AllowCreditAssignment__c){

            //legal entity allows credit assignment, check if survey has been taken for all items.
            Set<String> oiIds = new Set<String>();
            Map<String,Boolean> oiTakenSurveyMap = new Map<String,Boolean>();
            for(NE__OrderItem__c incentiveOi : currentOrd.NE__Order_Items__r){
                oiIds.add(incentiveOi.Id);
                oiTakenSurveyMap.put(incentiveOi.Id,false);
            }

            //getting survey responses
            List<XC_GetFeedbackResponse__c> surveyResponses = [SELECT Id,XC_ConfigurationItem__c 
            FROM XC_GetFeedbackResponse__c 
            WHERE XC_ConfigurationItem__c IN : oiIds];

            for(XC_GetFeedbackResponse__c resp : surveyResponses){
                if(oiTakenSurveyMap.containsKey(resp.XC_ConfigurationItem__c)){
                    oiTakenSurveyMap.put(resp.XC_ConfigurationItem__c,true);
                }
            }

            //checking surveys
            for(String oiId : oiTakenSurveyMap.keySet()){
                if(!oiTakenSurveyMap.get(oiId)){
                    result.put('surveyToBeDone',true);
                    result.put('message',Label.XC_CL_LCP102WarningCASurvey);
                    break;
                }
            }

        }
        return result;
    }

    /**
    * @description check if the partner will pay for the customer
    * @author Andrea Di Cicco
    * @param recordId 
    * @return Map<String, Object> 
    **/
    @AuraEnabled
    public static Map<String,Object>  isBillToPartner(String recordId){
        Map<String,Object> result = new Map<String,Object>();
        result.put('isBillToPartner', false);

        NE__Order__c ord = [Select NE__BillAccId__c, NE__AccountId__c,NE__OptyId__r.XC_Country__c, XC_Segment__c from NE__Order__c  where id = : recordId]; 
        //[START,gaurav.tejpal@accenture.com, 19/05/2022,Enel X - NR2187, added stream and country again in response ]
        if(null != ord.XC_Segment__c){
            result.put('stream', ord.XC_Segment__c);
        }        
        if(null != ord.NE__OptyId__r.XC_Country__c){
            result.put('country', ord.NE__OptyId__r.XC_Country__c);
        }
        //[END,gaurav.tejpal@accenture.com, 19/05/2022,Enel X - NR2187, added stream and country again in response]
        if(ord.NE__BillAccId__c != null && ord.NE__AccountId__c != null && ord.NE__BillAccId__c != ord.NE__AccountId__c){
            result.put('isBillToPartner', true);
        }
        return result;
    }

    /**
    * @description return list of order items if payment method is commoditybill and product type is not bundle
    * @author Gaurav Tejpal gaurav.tejpal@accenture.com
    * @param orderId 
    * @return List<NE__OrderItem__c>
    **/
    @AuraEnabled
    public static List<NE__OrderItem__c> manageProduct(string orderId){
        List<NE__OrderItem__c> confItemList = new List<NE__OrderItem__c>();
        List<NE__OrderItem__c> confItem = new List<NE__OrderItem__c>([SELECT Id, NE__OrderId__c, XC_PaymentMethod__c, XC_Product_Type__c  FROM NE__OrderItem__c WHERE NE__OrderId__c = :orderId]);
        for(NE__OrderItem__c oi: confItem){
            if(oi.XC_PaymentMethod__c ==Constants.ORDER_PAYMENT_METHOD_TYPE && oi.XC_Product_Type__c != Constants.ORDER_PRODUCT_TYPE){
                confItemList.add(oi);
            }
        }
        return confItemList;
    }
}