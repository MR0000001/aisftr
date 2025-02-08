/**
 * @author Monica Cutillo - monica.cutillo@nttdata.com & Lorenzo Orlanducci - lorenzo.orlanduccio@nttdata.com
 * @date Creation 27/11/2018
 * @date Modification
 * @description XC_LCC044_OptyCheckBeforeNextStep - Check the possibility to click on 'Next Step' button from a Configuration Opty
 */
public without sharing class XC_LCC044_OptyCheckBeforeNextStep {

    /** @description The Constant DEBUGACTIVE. */
    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC044_OptyCheckBeforeNextStep');

    /**
    * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
    * @description Gets the visualforce relative URL.
    * @return the visualforce relative URL
    */
    @AuraEnabled
    public static String getVisualforceRelativeURL(){
        String prefix = Test.isRunningTest() ? 'fakePathPrefix' : Site.getPathPrefix();
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'URL='+ prefix.substring(0, prefix.length() - 2));
        return prefix.substring(0, prefix.length() - 2);
    }

    /**
    * @description Checks if is in community and installment number is same or not.
    * @param confItemId the Order Id
    * @return the optyCheckBeforeNextWrapper
    */
    @AuraEnabled
    public static XC_UTIL_Order.optyCheckBeforeNextWrapper isInCommunity(string confItemId){
        XC_UTIL_Order.optyCheckBeforeNextWrapper optyCheckBeforeNextWrapper=new XC_UTIL_Order.optyCheckBeforeNextWrapper();
        Set<String> installmentnumbers=new Set<String>();
        optyCheckBeforeNextWrapper.success = true;
        optyCheckBeforeNextWrapper.isInCommunity=false;
        String masterLabel = Site.getMasterLabel();
        if(masterLabel!=null) {
            optyCheckBeforeNextWrapper.isInCommunity='Enel x Partner Community'.equals(masterLabel);
        }
        /*List<NE__OrderItem__c> orderItems =[select id,XC_InstallmentsNumber__c,
        XC_Segment__c,NE__OrderId__r.XC_Country__c, XC_BillingModel__c
        from NE__OrderItem__c where XC_BillingModel__c = 'Installment Plan' and NE__OrderId__c =:confItemId];
        if(orderItems!=null && orderItems.size()>0 && orderItems[0].NE__OrderId__r!=null
        && 'B2B'.equalsIgnoreCase(orderItems[0].XC_Segment__c)
        && 'Italy'.equalsIgnoreCase(orderItems[0].NE__OrderId__r.XC_Country__c)) {
        Set<String> installmentnumbers=new Set<String>();
        optyCheckBeforeNextWrapper.success = true;
        for (NE__OrderItem__c orderitem : orderItems) {
        if(String.isNotBlank(orderitem.XC_InstallmentsNumber__c))
        {
        installmentnumbers.add(orderitem.XC_InstallmentsNumber__c);
        }
        if(installmentnumbers.size()>1)
        {
        optyCheckBeforeNextWrapper.success = false;
        optyCheckBeforeNextWrapper.resultMessage = Label.XC_CL_Configuration_OperationNotAllowedForDifferrentInstallmentNumber;
        break;
        }
        }
        }*/
        List<NE__Order_Item_Attribute__c> orderItemAtts =[select id, NE__Order_Item__r.NE__OrderId__r.XC_Country__c, NE__Order_Item__r.XC_Segment__c,NE__Value__c, NE__Order_Item__r.XC_BillingModel__c from NE__Order_Item_Attribute__c where NE__Order_Item__r.NE__OrderId__c =: confItemId and name = 'Number of installments' and NE__Order_Item__r.XC_BillingModel__c = 'Installment Plan'];
        if(orderItemAtts!=null && !orderItemAtts.isEmpty()) {
            for (NE__Order_Item_Attribute__c oiAtt : orderItemAtts) {
                if(oiAtt.NE__Order_Item__r.NE__OrderId__c!=null && 'B2B'.equalsIgnoreCase(oiAtt.NE__Order_Item__r.XC_Segment__c) && 'Italy'.equalsIgnoreCase(oiAtt.NE__Order_Item__r.NE__OrderId__r.XC_Country__c) && String.isNotBlank(oiAtt.NE__Value__c))
                {
                    installmentnumbers.add(oiAtt.NE__Value__c);
                }
                if(installmentnumbers.size()>1)
                {
                    optyCheckBeforeNextWrapper.success = false;
                    optyCheckBeforeNextWrapper.resultMessage = Label.XC_CL_Configuration_OperationNotAllowedForDifferrentInstallmentNumber;
                    break;
                }
            }
        }
        system.debug('optyCheckBeforeNextWrapper: '+optyCheckBeforeNextWrapper);
        return optyCheckBeforeNextWrapper;
    }

    /**
    * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
    * @description Check opty creation.
    * @param recordId the record id
    * @return the x C UTI L result wrapper
    */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper checkOptyCreation(String recordId){
        XC_UTIL_ResultWrapper wrPreconditions  =  XC_UTIL_Configuration.checkOpportunityStage(recordId);
        if(!wrPreconditions.success){
            return wrPreconditions;
        }

        XC_UTIL_ResultWrapper wr1  =  checkOptyReqCommercialVisit(recordId);
        XC_UTIL_ResultWrapper wr2  =  checkPhoneRequiredOnConfItem(recordId);
        XC_UTIL_ResultWrapper wr3  =  checkVoucherUtilization(recordId);
        XC_UTIL_ResultWrapper wr4 = checkOrderConfigurationInPlace(recordId);
        //XC_UTIL_ResultWrapper wr5 = checkOptyConsipStatus(recordId);


        if(wr1.success && wr2.success && wr3.success && wr4.success) {
            return wr1;
        } else if(!wr1.success) {
            wr1.typeMessage = 'commercialVisit';
            return wr1;
        } else if(!wr2.success) {
            return wr2;
        } else if(!wr3.success){
            return wr3;
        } else{
            return wr4;
        }

    }

    /**
    * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
    * @description check if Phone is RequiredOnConfItem
    * @param recordId the configuration id
    * @return the XC_UTIL_ResultWrapper
    */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper checkPhoneRequiredOnConfItem(String recordId){
        System.debug('In checkPhoneRequiredOnConfItem');
        XC_UTIL_ResultWrapper wr = new XC_UTIL_ResultWrapper();
        wr.success = true;
        NE__Order__c ord = new List<NE__Order__c>([SELECT id, NE__OptyId__r.Account.IdentityNumber__c, NE__OptyId__c,NE__OptyId__r.Account.XC_AccountPhone__c,NE__OptyId__r.Account.XC_AccountPhonePrefix__c,  (select id, NE__ProdId__c, NE__ProdName__c, NE__CatalogItem__r.NE__Catalog_Category_Name__r.XC_Phone_Required__c from NE__Order_Items__r)
                            FROM NE__Order__c where id =: recordId limit 1])[0];
        List<NE__OrderItem__c> orderItemList = new List<NE__OrderItem__c>();
        List<String> orderItemIds = new List<String>();

        if(ord.NE__OptyId__c == null) {
            wr.success = false;
            wr.typeMessage = 'noOpportunity';
            wr.resultMessage = Label.XC_CL_Opportunity_NoFound;
            return wr;
        }
        if(ord.NE__OptyId__r.Account.XC_AccountPhone__c!=null) {
            System.debug('Account Phone presente');
            wr.resultMessage = Label.XC_CL_Account_PhoneOK; //phone presente. Nessun controllo ulteriore è necessario
            return wr;
        }else{

            if(!ord.NE__Order_Items__r.isEmpty()) {
                orderItemList = ord.NE__Order_Items__r;
            }
            for(NE__OrderItem__c oi : orderItemList) {
                if(oi.NE__CatalogItem__r.NE__Catalog_Category_Name__r.XC_Phone_Required__c) { // controllo se il phone è required per ogni order item
                    wr.success = false;
                    wr.typeMessage = 'noPhone';
                    wr.resultMessage = Label.XC_CL_Product_PhoneMandatory + oi.NE__ProdName__c;
                    break;
                }
            }

        }

        return wr;
    }

    /**
    * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
    * @description Check opty creation.
    * @param recordId the record id
    * @return the x C UTI L result wrapper
    */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper checkOptyReqCommercialVisit(String recordId){
        XC_UTIL_ResultWrapper wr = new XC_UTIL_ResultWrapper();
        wr.success = true;
        //block if opty require Commercial Visit
        String optyId = XC_UTIL_Sobject.getFieldValue('NE__Order__c', 'NE__OptyId__c', recordId);

        if(!Schema.SObjectType.Opportunity.isAccessible()) {
            return new XC_UTIL_ResultWrapper();
        }

        Map<Id,Opportunity> optyMap = new Map<id,Opportunity> ([SELECT Id, XC_CommercialVisitRequired__c, CloseDate,XC_CommercialVisitStarted__c
                                                                FROM Opportunity WHERE Id =: optyId LIMIT 1]);
        List<Opportunity>opty = optyMap.values();
        if(!opty.isEmpty()) {
            /*  if(opty[0].CloseDate!= null && opty[0].CloseDate < Date.today() ) {
                wr.success = false;
                wr.resultMessage = Label.XC_CL_NextStepCloseDateError;

            }*/
            if(opty[0].XC_CommercialVisitRequired__c && !opty[0].XC_CommercialVisitStarted__c) {
                wr.success = false;
                wr.resultMessage = Label.XC_CL_Configuration_NextStepBlocked;
            }

        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ checkOptyCreation result = '+wr);
        return wr;
    }


    /**
    * @author Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
    * @description check Voucher Utilization.
    * @param recordId the record id
    * @return the x C UTI L result wrapper
    */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper checkVoucherUtilization(String recordId){
        XC_UTIL_ResultWrapper wr = new XC_UTIL_ResultWrapper();
        wr.success = true;

        Map<Id, NE__OrderItem__c> mapOrderIdToCoupon = XC_TR_Configuration_U_ManageVoucher.getCouponFromConfigurationId(new List<Id>{recordId});
        if(mapOrderIdToCoupon.get(recordId) == null) {
            return wr;
        }
        NE__OrderItem__c confItemCoupon = mapOrderIdToCoupon.get(recordId);

        Map<String, XC_Voucher__c> mapVoucher = XC_TR_Configuration_U_ManageVoucher.getVoucher(mapOrderIdToCoupon.values());

        String voucherCode = mapOrderIdToCoupon.get(recordId).NE__Order_Item_Attributes__r[0].NE__Value__c;
        XC_Voucher__c voucher = mapVoucher.get(voucherCode);

        if(!voucher.XC_Unlimited__c && voucher.RecordType.DeveloperName != 'XC_Voucher_Unlimited' && (voucher.XC_Usage_Counter__c >= voucher.XC_Uses__c)) {
            wr.success = false;
            wr.resultMessage = Label.XC_CL_Voucher_CannotBeUsed;
            return wr;
        } else {
            for(XC_VoucherUtilization__c voucherUtil : voucher.Voucher_Utilization__r) {
                if(confItemCoupon.NE__OrderId__r.NE__AccountId__c == voucherUtil.XC_Account__c && confItemCoupon.NE__OrderId__r.NE__OptyId__c != voucherUtil.XC_Opportunity__c) {
                    wr.success = false;
                    wr.resultMessage = Label.XC_CL_Voucher_AlreadyUsedByAccount;
                    return wr;
                }
            }
        }

        return wr;
    }


    /**
    * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
    * @description Check order creation.
    * @param recordId the record id
    * @return the x C UTI L result wrapper
    */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper checkOrderCreation(String recordId){
       system.debug('enter checkOrderCreation');
        XC_UTIL_ResultWrapper wr = new XC_UTIL_ResultWrapper();
        wr.success = false;
        wr.resultMessage = Label.XC_CL_Quote_OperationNotAllowedWithThisStatus;
        //block if previous status is Draft or notify to client

        if(!Schema.SObjectType.NE__Order__c.isAccessible()) {
            return new XC_UTIL_ResultWrapper();
        }

        Map<id,NE__Order__c> configurationsMap =  new Map<ID,NE__Order__c>([SELECT Id, XC_Response_From_Doxee__c, XC_LegalEntity__c, XC_Status__c, NE__OptyId__r.XC_Contact__r.Name,NE__OptyId__r.XC_Contact__r.Email, NE__OptyId__r.XC_Contact__c, NE__AccountId__c, RecordTypeId,XC_Segment__c,(SELECT XC_PartnerContract__r.XC_CheckExpirDate__c FROM NE__Order_Items__r) FROM NE__Order__c WHERE id=: recordId AND XC_Status__c !=: Label.XC_CL_Configuration_QuoteAccepted ]);
        List<NE__Order__c> configurations = configurationsMap.values();

        
        if(configurations.isEmpty()) {
            return wr;
        }

        
        if(hasItemsWithExpiredContract(configurations)){
            
            wr.resultMessage = Label.XC_CL_QuoteItemsExpiredContract;
            return wr;
        }
        //NA0402
        //check Billing Profile Line Item
        List<NE__OrderItem__c> configurationsItems= new List<NE__OrderItem__c>();
        if(Schema.sObjectType.NE__OrderItem__c.isAccessible()){
            configurationsItems=[select id,NE__OrderId__r.XC_LegalEntity__c,NE__OrderId__c,XC_BillingProfileLineItem__c,XC_Need_approval_VAT_exempt__c 
                                                from NE__OrderItem__c 
                                                where ( NE__OrderId__r.XC_LegalEntity__c=:Constants.CODENSA or 
                                                        NE__OrderId__r.XC_LegalEntity__c=:Constants.ENEL_X_CHILE or
                                                        NE__OrderId__r.XC_LegalEntity__c=:'EnelXMobilityChile' or
                                                        NE__OrderId__r.XC_LegalEntity__c=:Constants.ENEL_DISTRIBUCION_CHILE) and 
                                                        XC_BillingProfileLineItem__c=null and XC_BillingModel__c !='Capex' and
                                                        NE__Parent_Order_Item__c=null and 
                                                        NE__OrderId__c=: recordId];
            system.debug('populate confogiurationItems List');                                    
         }   
         system.debug('size configurationsItems' +' '+configurationsItems.size());
         if(!configurationsItems.isEmpty()){
            wr.success = false;
            wr.resultMessage = Label.XC_CL_Quote_OperationNotAllowedWithoutBillingProfile;
            return wr;
         }

        if(checkNeedApproval(recordId)){
            wr.success = false;
            wr.resultMessage= Label.XC_Markup_Need_ApprovalProcess;
            return wr;
        }
        Map<String,Object> needApprovalVat = doNeedVatApproval(configurationsItems , configurationsMap);
        if((Boolean)needApprovalVat.get('needApproval')){
            wr.success = false;
            wr.resultMessage = (String)needApprovalVat.get('errorMessage');
            return wr;
        }
        if(creditCheckStatus(recordId)){
            wr.success = false;
            wr.resultMessage= Label.XC_CL_CreditCheckMessage;
            return wr;
        }
        if(checkConsip(recordId)){
            wr.success = false;
            wr.resultMessage = Label.XC_CL_ConsipApproveQuote;
            return wr;
        }


        String recordTypeQuote = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Quote').getRecordTypeId();
        if( recordTypeQuote==configurations[0].RecordTypeId &&
            (configurations[0].XC_Status__c==Label.XC_CL_Configuration_QuoteDraft || configurations[0].XC_Status__c==Label.XC_CL_Configuratione_QuoteNotifiedToClient)) {

            /*
            if(!XC_UTIL_Configuration.areOrderItemsPaymentMethodsOk(configurations[0].Id)){
                wr.resultMessage = Label.XC_CL_PaymentMethodsRequiredMess;
                return wr;
            }
            */

            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Entrato in update Quote');
            configurations[0].XC_Status__c = Label.XC_CL_Configuration_QuoteAccepted;
            List<NE__OrderItem__c> listItemsToUpdate = new List<NE__OrderItem__c>();
            List<XC_UTIL_SObject.WrapperResult> updResults = XC_UTIL_DML.updateRecords(configurations);
            //listItemsToUpdate = needApprovaToConfItems(configurations[0].id);
            //if(!listItemsToUpdate.isEmpty()){
              //  update listItemsToUpdate;
            //}
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ checkOrderCreation updResults = '+updResults);

            wr.success = true;
            wr.resultMessage = 'Success';
        }

        return wr;
    }

    /**
    * @description  Method to create new personal document from NextStepNew component.
    * @param orderId
    * @param phoneValues
    * @return XC_UTIL_ResultWrapper
    */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper newPhone(String orderId, String phoneValues){
        XC_UTIL_ResultWrapper wr = new XC_UTIL_ResultWrapper();
        System.debug('In newPersonalDocument con orderId= '+orderId);
        NE__Order__c order = new List<NE__Order__c>([SELECT id, NE__OptyId__c, NE__OptyId__r.AccountId, NE__OptyId__r.XC_Contact__c,
                            NE__OptyId__r.Account.IdentityType__c, NE__OptyId__r.Account.IdentityNumber__c, NE__OptyId__r.Account.XC_AccountPhone__c,
                            NE__OptyId__r.Account.XC_AccountPhonePrefix__c
                            FROM NE__Order__c WHERE Id=:orderId limit 1])[0];

        String phoneNumber = null;
        String phonePrefix   = null;
        Map<String, Object> optionsMap = (Map<String, Object>)JSON.deserializeUntyped(phoneValues);
        if(optionsMap.containsKey('phoneNumber')) {
            phoneNumber = String.valueOf(optionsMap.get('phoneNumber'));
        }
        if(optionsMap.containsKey('phonePrefix')) {
            phonePrefix = String.valueOf(optionsMap.get('phonePrefix'));
        }


        XC_UTIL_Sobject.WrapperResult insertRes = new XC_UTIL_Sobject.WrapperResult();
        if(order.NE__OptyId__r.AccountId!=null) {
            Account a = new Account(id=order.NE__OptyId__r.AccountId);
            a.XC_AccountPhone__c   = phoneNumber;
            a.XC_AccountPhonePrefix__c = phonePrefix;
            insertRes = XC_UTIL_Sobject.updateRecord(a);
        }

        wr = new XC_UTIL_ResultWrapper(insertRes);

        return wr;
    }


    /**
    * @description check if an order already exist
    * @author Francesco Imperioli - fimperioli@deloitte.it | 6/5/2020 
    * @param recordId 
    * @return XC_UTIL_ResultWrapper 
    **/
    @AuraEnabled
    public static XC_UTIL_ResultWrapper checkOrderConfigurationInPlace(String recordId){
        
        XC_UTIL_ResultWrapper result = new XC_UTIL_ResultWrapper();
        String orderRtId =  Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Order').getRecordTypeId();
        String optyId = XC_UTIL_Sobject.getFieldValue('NE__Order__c', 'NE__OptyId__c', recordId);
        List<NE__Order__c> orderConfigurations = [SELECT ID FROM NE__Order__c WHERE NE__OptyId__c = :optyId AND RecordTypeId = :orderRtId LIMIT 1];

        result.success = orderConfigurations.isEmpty();
        result.resultMessage = Label.XC_LCC044_OrderExistErr;

        return result;

    }

    private static boolean checkNeedApproval(String recordId){
        Boolean check = false;
        List<NE__OrderItem__c> listItems = new List<NE__OrderItem__c>();
        if(Schema.SObjectType.NE__OrderItem__c.isAccessible()){
            listItems = [SELECT ID, XC_NeedApproval__c, NE__OrderId__c, NE__OrderId__r.XC_Segment__c, NE__OrderId__r.XC_LegalEntity__c FROM NE__OrderItem__c WHERE NE__OrderId__r.XC_Segment__c !='B2C' AND NE__OrderId__c = :recordId];
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'listItem');
        Set<String>stream = new Set<String>{'B2B','B2G'};
        Set<String>legalEnti = new Set<String>{'EnelXItala','EnelXMobilityItalia'};
        String country = 'EnelXItala';
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'listItem');
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'listItem'+ listItems);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'listItem');
        for(NE__OrderItem__c ne : listItems){
            if(stream.contains(ne.NE__OrderId__r.XC_Segment__c) && ne.XC_NeedApproval__c){
                check = true;
                return check;
            }
        }
        return check;

    }


    /**
     * @author Federico Angelini - fangelini@deloitte.it
     * @date 24/06/2021
     * @description check if configuration items XC_Need_approval_VAT_exempt__c is true
     * @return  Map<String,Object>
     */
    private static Map<String,Object> doNeedVatApproval(List<NE__OrderItem__c> configurationsItems, Map<id,NE__Order__c> mapConfiguration) {

        Map<String,Object> checkResult = new Map<String,Object>();
        checkResult.put('needApproval', false);
        checkResult.put('errorMessage', '');
        NE__Order__c configurationOrder = mapConfiguration.values()[0];

        if(configurationOrder.XC_LegalEntity__c == 'Codensa' && (configurationOrder.XC_Segment__c == 'B2G' || configurationOrder.XC_Segment__c == 'B2B')){
            for (NE__OrderItem__c configItem :configurationsItems){
                if (configItem.XC_Need_approval_VAT_exempt__c){
                    checkResult.put('needApproval', true);
                    checkResult.put('errorMessage', (String) 'A configuration item needs approval');
                    return checkResult;
                }
            }
        }
        return checkResult;
    }


    @AuraEnabled
    public static XC_UTIL_ResultWrapper checkOptyConsipStatus(String recordId){
        XC_UTIL_ResultWrapper wr = new XC_UTIL_ResultWrapper();
        wr.success = true;
        //block if opty require Commercial Visit
        String optyId = XC_UTIL_Sobject.getFieldValue('NE__Order__c', 'NE__OptyId__c', recordId);
        List<NE__Order__c> optyConf = (List<NE__Order__c>) XC_UTIL_Sobject.selectAllFields(recordId);
        if(!Schema.SObjectType.Opportunity.isAccessible()) {
            return new XC_UTIL_ResultWrapper();
        }

        Map<Id,Opportunity> optyMap = new Map<id,Opportunity> ([SELECT Id, CloseDate, StageName, XC_SubStatus_GB__c,XC_ConsipLot__c,XC_ModeOfEngagement__c, XC_LegalEntity__c, XC_Segment__c
                                                      FROM Opportunity WHERE Id =: optyId LIMIT 1]);
        List<Opportunity>opty = optyMap.values();
        if(!opty.isEmpty()) {
            /*  if(opty[0].CloseDate!= null && opty[0].CloseDate < Date.today() ) {
                wr.success = false;
                wr.resultMessage = Label.XC_CL_NextStepCloseDateError;

            }*/
            Set<String> itaLE = new Set<String>{'EnelXItalia','EnelSole','ESCoComuniSrl','YouSaveSpA','EnelXSrl','EnelXMobility','Cogenio', 'EnelXMSP','EnelXMobilityItalia','EnelXMobilityHolding'};
            if((opty[0].XC_ModeOfEngagement__c == 'Consip 3' || opty[0].XC_ModeOfEngagement__c == 'Consip 4') && opty[0].XC_SubStatus_GB__c != 'Project processing' && itaLE.contains(opty[0].XC_LegalEntity__c) && opty[0].XC_Segment__c=='B2G') {
                wr.success = false;
                wr.resultMessage = Label.XC_CL_ConsipNoQuoteCreation;
            }

            if((opty[0].XC_ModeOfEngagement__c == 'Consip 3' || opty[0].XC_ModeOfEngagement__c == 'Consip 4')  && itaLE.contains(opty[0].XC_LegalEntity__c) && opty[0].XC_Segment__c=='B2G'
                    && optyConf != null && !optyConf.isEmpty() &&
                    (optyConf[0].XC_FirstSiteInspectionDate__c == null ||
                    (optyConf[0].XC_SummaryQuoteSendingDate__c  == null && opty[0].XC_ModeOfEngagement__c == 'Consip 4')||
                    (optyConf[0].XC_SummaryQuoteAmount__c  == null && opty[0].XC_ModeOfEngagement__c == 'Consip 4')||
                    optyConf[0].XC_SiteInspectionClosureDate__c  == null)) {
                wr.success = false;
                wr.resultMessage = Label.XC_CL_ConsipOptyMissingFields;
            }

        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ checkOptyCreation result = '+wr);
        return wr;
    }

	 @AuraEnabled
    public static Boolean creditCheckStatus(String recordId){
         Boolean check = False;
        Set<String> itaLE = new Set<String>{'EnelXItalia','EnelXMobilityItalia','EnelSole','ESCoComuniSrl','YouSaveSpA','EnelXSrl','EnelXMobility','EnelXMobilityHolding','Cogenio', 'EnelXMSP'};
        Set<String> segment = new Set<String>{'B2B','B2G'};
        List<NE__Order__c> orderConfigurations = [select id, NE__OptyId__r.XC_CreditCheck_GB__c, XC_Segment__c, XC_LegalEntity__c, XC_Status__c, NE__OptyId__r.XC_ModeOfEngagement__c, NE__OptyId__r.XC_BusinessModel__c, NE__OptyId__r.XC_ContractType__c from NE__Order__c where id = :recordId];
        if(!itaLE.contains(orderConfigurations[0].XC_LegalEntity__c) && !segment.contains(orderConfigurations[0].XC_Segment__c)){
            return false;
        }
        if(orderConfigurations[0].XC_Segment__c=='B2C'){
            return false;
        }
        Set<String> crediCheckValueAvailabe = new Set<String>{'OK','OK_prepayment'};
        String businessModel = orderConfigurations[0].NE__OptyId__r.XC_BusinessModel__c;
        String modeOfEngagement = orderConfigurations[0].NE__OptyId__r.XC_ModeOfEngagement__c;
        String contractType = orderConfigurations[0].NE__OptyId__r.XC_ContractType__c;
        check = !crediCheckValueAvailabe.contains(orderConfigurations[0].NE__OptyId__r.XC_CreditCheck_GB__c);
        if(check){
            List<XC_CM_Skip_Credit_Check__mdt> listCMSkipCreditCheck = new List<XC_CM_Skip_Credit_Check__mdt>();
            listCMSkipCreditCheck = [select Id, DeveloperName, XC_Contract_Type__c, XC_BusinessModel__c, XC_ModeOfEngagement__c  from XC_CM_Skip_Credit_Check__mdt
            where XC_Contract_Type__c IN (:contractType,'*') AND XC_BusinessModel__c IN (:businessModel,'*') AND XC_ModeOfEngagement__c IN (:modeOfEngagement,'*')];
            if(!listCMSkipCreditCheck.isEmpty()){ 
                check = false;
            }
        }
        return check;

    }
    public static Boolean checkConsip(String recordId){
        Boolean check = false;
        Set<String> itaLE = new Set<String>{'EnelXItalia',
                'EnelSole',
                'ESCoComuniSrl',
                'YouSaveSpA',
                'EnelXSrl',
                'EnelXMobility',
                'Cogenio',
                'EnelXMSP'};
        Set<String> segment = new Set<String>{'B2B','B2G'};
        Set<String> setModeofEngament = new Set<String> {'Consip 3',
                'Consip 4'};
        Set<String> setZoneAccount = new Set<String>{
                'S&D North-Delivery Pie Nord e Valle D\'Ao',
                'S&D North-Delivery Pie Sud e Liguria',
                'S&D North-Delivery Lom Nord',
                'S&D North-Delivery Lom Est',
                'S&D North-Delivery Lom Ovest',
                'S&D North-Delivery Emilia Romagna',
                'S&D Center & South-Delivery Calabria',
                'S&D Center & South-Delivery Sicilia',
                'S&D Center & South-Delivery Tos, Umbria,',
                'S&D Center & South-Delivery Laz Abr Mol',
                'S&D Center & South-Delivery Camp, Puglia'
        };
        Set<String>setRequestForApproval = new Set<String>{
                'Approval not needed',
                'Approval Received'
        };

 List<NE__Order__c> orderConfigurations = [select id, NE__Recurring_Charge_Total__c, NE__One_Time_Fee_Total__c,  NE__AccountId__r.XC_Zone__c, NE__OptyId__r.XC_BusinessLine__c, XC_RequestForApproval__c, NE__OptyId__r.XC_CreditCheck_GB__c, XC_Segment__c, XC_LegalEntity__c, XC_Status__c, NE__OptyId__r.XC_ModeOfEngagement__c, NE__OptyId__r.XC_BusinessModel__c, NE__OptyId__r.XC_ContractType__c from NE__Order__c where id = :recordId];
        String businessLine = '';
        String modeOfEngagement = '';
        String contractType = '';
        String requestForApproval = '';
        String creditCheck = '';
        Decimal totalAmount = 0 ;
        String accountZone = '';

        if (!orderConfigurations.isEmpty()) {
            businessLine = orderConfigurations[0].NE__OptyId__r.XC_BusinessLine__c;
            modeOfEngagement = orderConfigurations[0].NE__OptyId__r.XC_ModeOfEngagement__c;
            contractType = orderConfigurations[0].NE__OptyId__r.XC_ContractType__c;
            requestForApproval = orderConfigurations[0].XC_RequestForApproval__c;
            creditCheck = orderConfigurations[0].NE__OptyId__r.XC_CreditCheck_GB__c;
            totalAmount = orderConfigurations[0].NE__Recurring_Charge_Total__c == null ? 0 : orderConfigurations[0].NE__Recurring_Charge_Total__c  + orderConfigurations[0].NE__One_Time_Fee_Total__c == null ? 0 : orderConfigurations[0].NE__One_Time_Fee_Total__c;
            accountZone = orderConfigurations[0].NE__AccountId__r.XC_Zone__c;

            if(!itaLE.contains(orderConfigurations[0].XC_LegalEntity__c) && !segment.contains(orderConfigurations[0].XC_Segment__c)){
                return false;
            }
        }

        if(businessLine == 'eCity' && !String.isBlank(contractType) &&
                !setModeofEngament.contains(modeOfEngagement) &&
                !setRequestForApproval.contains(requestForApproval) &&
                creditCheck == 'OK' && totalAmount > 0 &&
                setZoneAccount.contains(accountZone)
                )
                    {
                        return true;

                    }

        return false;

    }

    private static Boolean hasItemsWithExpiredContract(List<NE__Order__c> configurations){
        Boolean hasExpiredContract = false;
        
        for(NE__Order__c c: configurations){
            if((c.XC_Segment__c == 'B2B' || c.XC_Segment__c == 'B2G')){

                List<NE__OrderItem__c> configItems = c.NE__Order_Items__r;

                for(NE__OrderItem__c item: configItems){
                    if(!String.isBlank(item.XC_PartnerContract__c)){
                        if(!item.XC_PartnerContract__r.XC_CheckExpirDate__c){
                            hasExpiredContract = true;
                            break;
                        }
                    } 
                } 
            } 
        }


        return hasExpiredContract;
    }
    
}