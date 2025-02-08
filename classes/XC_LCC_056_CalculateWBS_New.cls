/**
     * @author Donato Lombardi - dolombardi@deloitte.it
     * @description Method to retrieve a Map of Work Order -> List skills requested
     * @param listNew - List WorkOrder
     * @return void
    **/
public with sharing class XC_LCC_056_CalculateWBS_New {
    // public static List<wrappWBE> wrWBE = new List<wrappWBE>();

    public class wrappWBE{
        public NE__OrderItem__c orderItem;
        public String companyCode;
        public String productLine;
        public String digFree;
        public String capeX;
        public String projectScope;
        public String projectServiceType;
        public String businessModel;
        public String cta;
        public String channel;
        public String autoNumber;
        public String digitFree2;
        public String wbe;
        public String wbs;
        public Decimal estimatedRevenue;
        public Decimal estimatedRevenueFullLife;
        public Decimal estimatedCost;


    }
    public static void generateAutoNumber(List<NE__OrderItem__c> listItems){
        Set<String> setOrderNumber = new Set<String>();
        for(NE__OrderItem__c ne : listItems ){
            setOrderNumber.add(ne.NE__OrderId__r.name);
        }
        List<XC_WBE_Order_Number__c> listExistingOrderNumber = new List<XC_WBE_Order_Number__c>();
        if(Schema.SObjectType.XC_WBE_Order_Number__c.isAccessible()){
            listExistingOrderNumber = [SELECT ID, NAME FROM XC_WBE_Order_Number__c WHERE NAME IN : setOrderNumber];
        }
        if(!listExistingOrderNumber.isEmpty()){
            return;
        }
        List<XC_CM_LegalEntity_Configuration__mdt> listLegalEntiConf = new List<XC_CM_LegalEntity_Configuration__mdt>();
        listLegalEntiConf = retriveLegalEntity_configurations(listItems);
        if(listLegalEntiConf[0].XC_Type_of_WBE__c == 'Simple'){
            return;
        }

        XC_WBE_Order_Number__c maxOrdNum = getMaxRecord();

        List<XC_WBE_Order_Number__c> listOrdNum = new List<XC_WBE_Order_Number__c>();
        for(String s : setOrderNumber){
            //XC_WBE_Order_Number__c ordNum = new XC_WBE_Order_Number__c(name = s);
            if(maxOrdNum!=null){
                XC_WBE_Order_Number__c ordNum = maxOrdNum.clone(false, false, false, false);
                ordNum.name = s;
                Integer legalEntityMax = Integer.valueOf(ordNum.get('XC_'+listItems[0].NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c+'_Number__c'));
                String newMax = String.valueOf(legalEntityMax+1).left(8);
                ordNum.put('XC_'+listItems[0].NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c+'_Number__c', Decimal.valueOf(newMax));
                listOrdNum.add(ordNum);
            }

        }
        XC_UTIL_Sobject.insertListRecords(listOrdNum);
    }

    private static XC_WBE_Order_Number__c getMaxRecord(){
        /*XC_WBE_Order_Number__c maxOrdNum = null;
        String maxAutonumber = null;
        List<AggregateResult> maxList = [select max(XC_AutonumberWBS__c) max from XC_WBE_Order_Number__c];
        if(maxList != null && maxList.size() > 0){
            for(AggregateResult aggr : maxList){
                maxAutonumber = String.valueOf(aggr.get('max'));
            }
        }

        String query = String.escapeSingleQuotes(XC_UTIL_Sobject.selectAllFieldsGetSelect('XC_WBE_Order_Number__c'));
        query += String.escapeSingleQuotes(' FROM XC_WBE_Order_Number__c WHERE XC_AutonumberWBS__c = :maxAutonumber');
        List<sObject> results = Database.query(query);
        if(results!=null && !results.isEmpty()){
            maxOrdNum = (XC_WBE_Order_Number__c) results[0];
        }

        return maxOrdNum;*/
        XC_WBE_Order_Number__c maxOrdNum = null;
        String maxAutonumber = null;
        List<XC_WBE_Order_Number__c> maxList = [select XC_AutonumberWBS__c from XC_WBE_Order_Number__c order by XC_AutonumberWBS__c desc limit 1];
        if(maxList != null && maxList.size() > 0){
            for(XC_WBE_Order_Number__c aggr : maxList){
                maxAutonumber = String.valueOf(aggr.XC_AutonumberWBS__c);
            }
        }

        String query = String.escapeSingleQuotes(XC_UTIL_Sobject.selectAllFieldsGetSelect('XC_WBE_Order_Number__c'));
        query += String.escapeSingleQuotes(' FROM XC_WBE_Order_Number__c WHERE XC_AutonumberWBS__c = :maxAutonumber');
        List<sObject> results = Database.query(query);
        if(results!=null && !results.isEmpty()){
            maxOrdNum = (XC_WBE_Order_Number__c) results[0];
        }

        return maxOrdNum;

    }

    private static List<XC_CM_LegalEntity_Configuration__mdt> retriveLegalEntity_configurations(List<NE__OrderItem__c> listItems){
        List<XC_CM_LegalEntity_Configuration__mdt> listCM = new List<XC_CM_LegalEntity_Configuration__mdt>();
        Set<String> setLegalEntity = new Set<String>();
        for(NE__OrderItem__c ne : listItems){
            setLegalEntity.add(ne.NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c);
        }
        if(Schema.sObjectType.XC_CM_LegalEntity_Configuration__mdt.isAccessible()){
            listCM = [select XC_CompanyCode__c, XC_LegalEntity__c,XC_Type_of_WBE__c, XC_digFree__c,XC_Stream__c  from XC_CM_LegalEntity_Configuration__mdt WHERE XC_LegalEntity__c IN : setLegalEntity AND XC_Stream__c =: listItems[0].NE__OrderId__r.XC_Segment__c  and XC_OrgId__c = :userInfo.getOrganizationId()];
        }
        return listCM;

    }






    public static String calculateWBE(List<NE__OrderItem__c> listItems){
        String wbeOld = '';
        String wbeNew = '';
        String wbeDOld = '';
        String wbeDNew = '';
        List<wrappWBE> wrWBE = new List<wrappWBE>();
        Map<Id,String> mapIdStrungWBE = new Map<Id,String>();
        wrWBE = getCompanyCode(listItems);
        Map<String,XC_WBE_Dimension__c>  mapWbsDimensionValue = new Map<String,XC_WBE_Dimension__c>();
        mapWbsDimensionValue = retriveWBEdimRecord(wrWBE);
        String checkWBE = createWBETracking(wrWBE,mapWbsDimensionValue);
        if( checkWBE == 'OK'){
            return 'OK';
        }
        return Label.XC_CL_WBE_Missing_WBE_Dimension +' '+ checkWBE;









    }

    private static List<wrappWBE> getCompanyCode(List<NE__OrderItem__c> listItems){
        List<wrappWBE> wrWBE = new List<wrappWBE>();
        Map<Id,String> mapIdCompanyCode = new Map<Id,String>();
        for(NE__OrderItem__c ne : listItems){
            mapIdCompanyCode.put(ne.id,ne.NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c);
        }
        String segment = listItems[0].NE__OrderId__r.XC_Segment__c;
        Map<String,XC_CM_WBEChannelMapping__mdt> cmCodeChannel = new Map<String,XC_CM_WBEChannelMapping__mdt>();
        cmCodeChannel = getMapWbeChannel();
        List<XC_CM_LegalEntity_Configuration__mdt> listCMCompanyCode = [SELECT ID, XC_LegalEntity__c,XC_Stream__c, XC_CompanyCode__c,XC_digFree__c, XC_digitFree2__c, XC_Type_of_WBE__c, XC_WBEDigit18__c FROM XC_CM_LegalEntity_Configuration__mdt WHERE XC_LegalEntity__c IN:mapIdCompanyCode.values() AND XC_Stream__c =: segment AND XC_OrgId__c = :UserInfo.getOrganizationId() LIMIT 1];

        /*String geographicalData = null;
        if(listCMCompanyCode[0].XC_digFree__c == null){
            geographicalData = getGeographicalData(mapIdCompanyCode.values()[0], segment, listItems[0].NE__OrderId__r);
        }
        else{
            geographicalData = listCMCompanyCode[0].XC_digFree__c;
        }*/

        Map<Id,String> getGeographicalDataOrderItem = getGeographicalDataOrderItem(mapIdCompanyCode.values()[0], segment, listItems);
        Map<String,Integer> mapAutoNumber = new Map<String,Integer>();
        mapAutoNumber = retrieveAutoNumb(listItems);


        for(NE__OrderItem__c ne : listItems){
            if(ne.XC_WBE_Status__c=='Sent' || ne.XC_WBE_Status__c == 'New') {
                if (listCMCompanyCode[0].XC_Type_of_WBE__c == 'Complex') {
                    System.debug('NE COMPLEX---->' + ne);
                    wrappWBE wrObj = new wrappWBE();
                    wrObj.orderItem = ne;
                    wrObj.companyCode = listCMCompanyCode[0].XC_CompanyCode__c;  //4
                    wrObj.productLine = ne.NE__CatalogItem__r.XC_ProductLine__c; //4
                    wrObj.digFree = listCMCompanyCode[0].XC_digFree__c != null ? listCMCompanyCode[0].XC_digFree__c : getGeographicalDataOrderItem.get(ne.Id) != null ? getGeographicalDataOrderItem.get(ne.Id) : '00'; //geographicalData != null ? geographicalData : '00'; //2    ---- if digitFree is null => use dynamically computed geographical data
                    wrObj.capeX = ne.XC_BillingModel__c == 'Capex' ? 'W' : 'Y'; //1
                    wrObj.projectScope = 'S'; //1
                    wrObj.projectServiceType = (ne.NE__CatalogItem__r.XC_ProductServiceType__c != null) ? ne.NE__CatalogItem__r.XC_ProductServiceType__c : '000';  //3
                    wrObj.businessModel = getBillingModel(ne.XC_BillingModel__c, ne.NE__OrderId__r.NE__OptyId__r.XC_BusinessModel__c, ne.NE__OrderId__r.NE__OptyId__r.XC_ProductCategoryOfInterest__c);  //1
                    //wrObj.estimatedRevenue = evalueteEstimatedRevenue(ne)!= null ? evalueteEstimatedRevenue(ne) : 0; //TODO TBD
                    wrObj.estimatedRevenueFullLife = evalueteRevenueFullLife(ne)!= null ? evalueteRevenueFullLife(ne) : 0; //TODO TBD
                    /*   20.07.2021    */  wrObj.estimatedCost = evalueteEstimatedCost(ne)!= null ? evalueteEstimatedCost(ne) : 0; //TODO TBD
                    wrObj.cta = '0'; //checkIntercompany(ne.NE__OrderId__r.NE__OptyId__r.XC_Intercompany__c, ne.XC_BillingModel__c);  //1
                    wrObj.channel = listCMCompanyCode[0].XC_WBEDigit18__c == null ? cmCodeChannel.get(ne.NE__OrderId__r.NE__OptyId__r.XC_SalesChannel__c).XC_ChannelCode__c : listCMCompanyCode[0].XC_WBEDigit18__c;
                    wrObj.autoNumber = XC_Encode_Base62.generateBase62(mapAutoNumber.get(ne.NE__OrderId__r.name), 4).left(4);
                    wrObj.digitFree2 = listCMCompanyCode[0].XC_digitFree2__c == Null ? '' : listCMCompanyCode[0].XC_digitFree2__c;
                    wrObj.wbs = wrObj.companyCode + wrObj.productLine + wrObj.digFree + wrObj.capeX + wrObj.projectScope;
                    //[ BEGIN, jayaprasath.tj@accenture.com, 05/05/2022, ID-1 Update Calcola WBE, NR2453, R2-2022 ]
                    String wbe = wrObj.companyCode + wrObj.productLine + wrObj.digFree + wrObj.capeX + wrObj.projectScope + wrObj.projectServiceType + wrObj.businessModel + wrObj.cta + wrObj.channel + wrObj.autoNumber + wrObj.digitFree2;
                    String wbeV = wbe.length()>=17 ? wbe.substring(0, 17) + 'V' + wbe.substring(18, wbe.length()) : '';
                    if(ne.NE__OrderId__c != null && ne.NE__OrderId__r.XC_Calculation_Channel_WBE_EC__c == 'Offerta Comunità Energetica' && 'B2B'.equalsIgnoreCase(ne.XC_Segment__c) && 'Italy'.equalsIgnoreCase(ne.XC_Country__c)){
                         wrObj.wbe = wbeV;
                    }
                    else{
                        wrObj.wbe = wbe;
                    }
                    //[ END, jayaprasath.tj@accenture.com, 05/05/2022, ID-1 Update Calcola WBE, NR2453, R2-2022 ] 
                    wrWBE.add(wrObj);
                } else {
                    wrappWBE wrObj = new wrappWBE();
                    System.debug('NE SIMPLE---->' + ne);
                    wrObj.orderItem = ne;
                    wrObj.companyCode = listCMCompanyCode[0].XC_CompanyCode__c;  //4
                    wrObj.productLine = ne.NE__CatalogItem__r.XC_ProductLine__c; //4
                    wrObj.digFree = listCMCompanyCode[0].XC_digFree__c; //2
                    wrObj.capeX = 'Y'; //1
                    wrObj.projectScope = 'S'; //1
                    wrObj.projectServiceType = (ne.NE__CatalogItem__r.XC_ProductServiceType__c != null) ? ne.NE__CatalogItem__r.XC_ProductServiceType__c : '000';  //3
                    wrObj.businessModel = getBillingModel(ne.XC_BillingModel__c, ne.NE__OrderId__r.NE__OptyId__r.XC_BusinessModel__c, ne.NE__OrderId__r.NE__OptyId__r.XC_ProductCategoryOfInterest__c);  //1
                    wrObj.cta = '0';   //1
                    wrObj.channel = cmCodeChannel.get(ne.NE__OrderId__r.NE__OptyId__r.XC_SalesChannel__c).XC_WBE__c != Null ? cmCodeChannel.get(ne.NE__OrderId__r.NE__OptyId__r.XC_SalesChannel__c).XC_WBE__c : '0';
                    wrObj.wbs = wrObj.companyCode + wrObj.productLine + wrObj.digFree + wrObj.capeX + wrObj.projectScope;
                    //[ BEGIN, jayaprasath.tj@accenture.com, 05/05/2022, ID-1 Update Calcola WBE, NR2453, R2-2022 ]
                    String wbe = wrObj.companyCode + wrObj.productLine + wrObj.digFree + wrObj.capeX + wrObj.projectScope + wrObj.projectServiceType + wrObj.businessModel + wrObj.cta + wrObj.channel;
                    String wbeV = wbe.length()>=17 ? wbe.substring(0, 17) + 'V' + wbe.substring(18, wbe.length()) : '';
                    if(ne.NE__OrderId__c != null && ne.NE__OrderId__r.XC_Calculation_Channel_WBE_EC__c == 'Offerta Comunità Energetica' && 'B2B'.equalsIgnoreCase(ne.XC_Segment__c) && 'Italy'.equalsIgnoreCase(ne.XC_Country__c)){
                         wrObj.wbe = wbeV;
                    }
                    else{
                        wrObj.wbe = wbe;
                    }
                    //[ END, jayaprasath.tj@accenture.com, 05/05/2022, ID-1 Update Calcola WBE, NR2453, R2-2022 ]
                    wrWBE.add(wrObj);

                }
            }

        }
        return wrWBE;

    }

    private static String getBillingModel(String billingModel, String businessModelOpty, String prodctCategory){
	if(businessModelOpty == 'Join Venture' && prodctCategory == 'HPC'){
            System.debug('Donato return' + billingModel);
            return '5';
        }
        if(billingModel == 'One Shot' || billingModel == 'Milestone'){
            return '1';
        }else if(billingModel == 'Recurring' || billingModel == 'Installment plan' || billingModel == 'Billing Plan' || billingModel == 'Saving Sharing' || billingModel =='Usage' || billingModel == 'Revenue Sharing') {
            return '2';
        }else if(billingModel =='Capex'){
            return '3';
        }else if (billingModel == 'Financed Sale'){
            return '4';
        }else if (billingModel == 'Joint Venture'){
            return '5';
        }
        return '0';

    }


    private static Map<String,XC_CM_WBEChannelMapping__mdt> getMapWbeChannel(){
        List<XC_CM_WBEChannelMapping__mdt> cmCodeChannel = new List<XC_CM_WBEChannelMapping__mdt>();
        Map<String,XC_CM_WBEChannelMapping__mdt> mapNameCOdeChannel = new Map<String,XC_CM_WBEChannelMapping__mdt>();
        if(Schema.sObjectType.XC_CM_WBEChannelMapping__mdt.isAccessible()){
            cmCodeChannel = [SELECT XC_ChannelCode__c,XC_ChannelName__c, XC_WBE__c, XC_Profit_Center__c, XC_Cost_Center__c  FROM XC_CM_WBEChannelMapping__mdt];
        }
        for(XC_CM_WBEChannelMapping__mdt cm : cmCodeChannel){
            mapNameCOdeChannel.put(cm.XC_ChannelName__c,cm);
        }
        return mapNameCOdeChannel;
    }


    private static Map<String,XC_WBE_Dimension__c> retriveWBEdimRecord(List<wrappWBE> listWbeWrap){
        Map<String,XC_WBE_Dimension__c> mapWBSobject = new Map<String,XC_WBE_Dimension__c>();
        List<String> listWBS = new List<String>();
        for(wrappWBE wr : listWbeWrap){
            listWBS.add(wr.wbs);
        }
        List<XC_WBE_Dimension__c> wbeDimensionRecord = [select id, Name, XC_Scope__c, XC_SapPillar__c, XC_WbeDimensionName__c, XC_WbeDimensionCode__c, XC_WbeDimensionValue__c, XC_ProfitCenter__c, XC_CostCenter__c, XC_Project_Type__c, XC_Investment_Reason__c,
                XC_Status__c, XC_Generated_Date__c, XC_Return_Error_Description__c,
                XC_Return_Error_code__c, XC_Type__c, XC_Country__c
        from XC_WBE_Dimension__c where XC_WbeDimensionValue__c IN : listWBS];

        for(XC_WBE_Dimension__c wBdim :wbeDimensionRecord){
            mapWBSobject.put(wBdim.XC_WbeDimensionValue__c,wBdim);
        }

        return mapWBSobject;

    }
    private static Map<String,Integer> retrieveAutoNumb(List<NE__OrderItem__c> listItems){
        Map<String,Integer> mapNameNumber = new Map<String,Integer>();
        Set<String> setOrderName = new Set<String>();
        for(NE__OrderItem__c ne : listItems){
            setOrderName.add(ne.NE__OrderId__r.name);
        }
        List<XC_WBE_Order_Number__c> listOrder_numbers = new List<XC_WBE_Order_Number__c>();
        if(Schema.sObjectType.XC_WBE_Order_Number__c.isAccessible()){
            //DP listOrder_numbers = [SELECT ID, NAME, XC_AutonumberWBS__c FROM XC_WBE_Order_Number__c WHERE NAME IN : setOrderName];

            String query = String.escapeSingleQuotes(XC_UTIL_Sobject.selectAllFieldsGetSelect('XC_WBE_Order_Number__c'));
            query += String.escapeSingleQuotes(' FROM XC_WBE_Order_Number__c WHERE name = :setOrderName');
            listOrder_numbers = (List<XC_WBE_Order_Number__c>) Database.query(query);


        }
        if(listOrder_numbers.isEmpty() ){
            return mapNameNumber;
        }
            for(XC_WBE_Order_Number__c au : listOrder_numbers){
            //DP mapNameNumber.put(au.name, Integer.valueOf(au.XC_AutonumberWBS__c));
            mapNameNumber.put(au.name, Integer.valueOf(au.get('XC_'+listItems[0].NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c+'_Number__c')));
        }

        return mapNameNumber;

    }


    private static String createWBETracking(List<wrappWBE> listWbeWrap,Map<String,XC_WBE_Dimension__c> mapWbsDimensionValue){
        String checkWBE = 'OK';
        List<XC_WbeTracking__c> listTW = new List<XC_WbeTracking__c>();
        List<XC_WBE_Dimension__c> wbeDimensionRecord = new List<XC_WBE_Dimension__c>();
        Map<Id,Contract> mapIdOppContract = new Map<Id,Contract>();
        mapIdOppContract = retrieveContract(listWbeWrap);
    /*GS*/  Map<Id,Contract> mapIdOrdContract = new Map<Id,Contract>();
    /*GS*/  mapIdOrdContract = retrieveOrderContract(listWbeWrap);
        for(wrappWBE wr : listWbeWrap){
            System.debug('AUTONUMBER PRIMA IF---->'+wr);
            if(wr.autoNumber!=null){
                System.debug('AUTONUMBER---->'+wr);
                XC_WbeTracking__c tw = new XC_WbeTracking__c();
                tw.XC_ConfigurationItemId__c = wr.orderItem.id;
                tw.XC_ConfigurationId__c = wr.orderItem.NE__OrderId__c;
                tw.XC_OrderNumber__c = wr.orderItem.NE__OrderId__c;
                tw.XC_SalesOrder__c = wr.orderItem.NE__OrderId__r.name;
                tw.XC_Wbe__c = wr.wbe;
                tw.XC_Channel__c = wr.channel;
                tw.XC_CompanyCode__c = wr.companyCode;
                tw.XC_ProductLine__c = wr.productLine;
                tw.XC_ProductService__c = wr.projectServiceType;
                tw.XC_WBS__c = wr.wbs;
                tw.XC_WbeI__c = wr.wbs;
                tw.XC_WbeII__c = wr.projectServiceType + wr.businessModel + wr.cta + wr.channel;
                tw.XC_WbeIII__c = wr.autoNumber + wr.digitFree2;
                tw.XC_BusinessModelCode__c = wr.businessModel;
                tw.XC_Market__c = '00' + wr.businessModel;
                if(mapWbsDimensionValue.get(wr.wbs)==Null){
                    return wr.wbs;
                }
                tw.XC_CostCenterResponsible__c = mapWbsDimensionValue.get(wr.wbs).XC_CostCenter__c;
                tw.XC_CostCenter__c = mapWbsDimensionValue.get(wr.wbs).XC_CostCenter__c;
                tw.XC_ProfitCenter__c = mapWbsDimensionValue.get(wr.wbs).XC_ProfitCenter__c;
                tw.XC_SapPillar__c = mapWbsDimensionValue.get(wr.wbs).XC_SapPillar__c;
                tw.XC_Scope__c = mapWbsDimensionValue.get(wr.wbs).XC_Scope__c;
                wr.orderItem.XC_Wbe__c = wr.wbe;
                wr.orderItem.XC_WBE_Status__c = 'Sent';
                wr.orderItem.XC_BlockWBE_User__c = true;
                tw.XC_TypeOfSending__c = 'Order Submit';
                tw.XC_Status__c = 'Sent';
                wr.orderItem.XC_CMProfitCenter__c = mapWbsDimensionValue.get(wr.wbs).XC_ProfitCenter__c;
                wr.orderItem.XC_CMCostCenter__c = mapWbsDimensionValue.get(wr.wbs).XC_CostCenter__c;
 System.debug('Configuration ORDER'+mapIdOrdContract.get(wr.orderItem.NE__OrderId__c) );
                
/*GS */         if(mapIdOrdContract.get(wr.orderItem.NE__OrderId__c)!= null){
                    System.debug('Contract Start Date'+mapIdOrdContract.get(wr.orderItem.NE__OrderId__c).StartDate );
                    System.debug('Contract Start Date'+mapIdOrdContract.get(wr.orderItem.NE__OrderId__c).EndDate );
/*GS */             tw.XC_ContractStartDate__c = mapIdOrdContract.get(wr.orderItem.NE__OrderId__c).StartDate;
                    tw.XC_ContractEndDate__c =mapIdOrdContract.get(wr.orderItem.NE__OrderId__c).EndDate;
/*GS */         }
          //    tw.XC_ContractStartDate__c = wr.orderItem.NE__OrderId__r.NE__OptyId__r.XC_ContractStartDate__c;
          //    tw.XC_ContractEndDate__c = wr.orderItem.NE__OrderId__r.NE__OptyId__r.XC_ContractEndDate__c;
				tw.XC_EstimatedRevenue__c = wr.estimatedRevenueFullLife.setScale(3);
				tw.XC_EstimatedCost__c = wr.estimatedCost.setScale(3);
            //  tw.XC_EstimatedCost__c = (wr.orderItem.NE__OrderId__r.NE__OptyId__r.XC_RevenueFullLife__c - wr.orderItem.NE__OrderId__r.NE__OptyId__r.XC_GrossMarginFullLife__c).setScale(2);
                tw.XC_WBEcapexUpdate__c = false;
                if(mapIdOppContract.get(wr.orderItem.NE__OrderId__r.NE__OptyId__c)!= null){
                    tw.XC_ContractType__c = mapIdOppContract.get(wr.orderItem.NE__OrderId__r.NE__OptyId__c).Contract_Type__c;
                }
                tw.XC_DocumentType__c = wr.orderItem.NE__OrderId__r.NE__AccountId__r.IdentityType__c;
                tw.XC_DocumentNumber__c = wr.orderItem.NE__OrderId__r.NE__AccountId__r.IdentityNumber__c;
                tw.XC_CustomerName__c = wr.orderItem.NE__OrderId__r.NE__AccountId__r.Name;
                tw.XC_Ownership__c = false;  //TODO TBD
                tw.XC_Location__c = wr.orderItem.XC_Installation_Address__r.XC_PostalCode__c;
                tw.XC_ClientIdentifier__c =wr.orderItem.NE__OrderId__r.NE__AccountId__c;
                tw.XC_Ownership__c = wr.orderItem.NE__OrderId__r.XC_PlantOwnership__c=='Enel'? true : false;
                if(mapIdOppContract.get(wr.orderItem.NE__OrderId__r.NE__OptyId__c)!=null) {
                    tw.XC_Contract__c = mapIdOppContract.get(wr.orderItem.NE__OrderId__r.NE__OptyId__c).id;
                // * @ Mod CV CR.NR1652 @date 28/10/2021 @Description Update field XC_Zone__c on Contract Start-->
                    mapIdOppContract.get(wr.orderItem.NE__OrderId__r.NE__OptyId__c).XC_Zone__c = wr.orderItem.NE__OrderId__r.NE__OptyId__r.XC_Zone__c ;
                //<-- End
                }

                List<String> modeOfEngagement = new List<String>{'Consip 2','Consip 3','Consip 4'};
                String executionProject = modeOfEngagement.contains(wr.orderItem.NE__OrderId__r.NE__OptyId__r.XC_ModeOfEngagement__c) && wr.orderItem.NE__OrderId__r.NE__OptyId__r.XC_Segment__c == 'B2G' ? wr.orderItem.NE__OrderId__r.NE__OptyId__r.XC_ModeOfEngagement__c+'-'+wr.orderItem.NE__OrderId__r.NE__OptyId__r.XC_LOT__c : wr.orderItem.NE__OrderId__r.NE__OptyId__r.XC_ModeOfEngagement__c;
                //tw.XC_ExecutionProjectId__c = executionProject;
                if(String.isNotBlank(executionProject)) {
                    if (executionProject.length() >= 20) {
                        tw.XC_ExecutionProjectId__c = executionProject.left(20);
                    } else {
                        tw.XC_ExecutionProjectId__c = executionProject;
                    }
                }

                //[START - NR2459 - 31/05/2022 - mariateresa.mollica@accenture.com]
                System.debug('orderitem--> ' + wr.orderItem); 
                if(wr.orderItem!=null && wr.orderItem.XC_LegalEntity__c!=null && wr.orderItem.XC_LegalEntity__c.equalsIgnoreCase('EnelXEwiva')) tw.XC_Status__c = 'Approved';
                //List<User> u = [SELECT id,XC_LegalEntity__c, XC_LegalEntities__c FROM User WHERE Id=:UserInfo.getUserId() LIMIT 1];
                //[END - NR2459 - 31/05/2022
                listTW.add(tw);
            }
            else{
                System.debug('WR---->'+wr);
                wr.orderItem.XC_Wbe__c = wr.wbe;
                wr.orderItem.XC_CMProfitCenter__c = mapWbsDimensionValue.get(wr.wbs).XC_ProfitCenter__c !=Null ? mapWbsDimensionValue.get(wr.wbs).XC_ProfitCenter__c :'000';
                wr.orderItem.XC_CMCostCenter__c = mapWbsDimensionValue.get(wr.wbs).XC_CostCenter__c != Null ? mapWbsDimensionValue.get(wr.wbs).XC_CostCenter__c : '010';
                wr.orderItem.XC_WBE_Status__c = 'Sent';
            }



        }
        updateConfigurationItem(listWbeWrap, listTW);
        // * @ Mod CV CR.NR1652 @date 28/10/2021 @Description Update field XC_Zone__c on Contract
        updateContract(mapIdOppContract);
        return checkWBE;
    }


    // * @ Mod CV CR.NR1652 @date 28/10/2021 @Description mathod to update Contracts Start-->
     private static void updateContract(Map<Id,Contract> mapContracts){
        if(Schema.sObjectType.Contract.isUpdateable()){
            update mapContracts.values();
        }
    }
    //End <--

    private static void updateConfigurationItem(List<wrappWBE> listWbeWrap, List<XC_WbeTracking__c> listTW){
        List<NE__OrderItem__c> itemsToUpdate = new List<NE__OrderItem__c>();
        for(wrappWBE wp : listWbeWrap){
            itemsToUpdate.add(wp.orderItem);
        }
        checkSkipIntegration(itemsToUpdate);


        if(Schema.sObjectType.NE__OrderItem__c.isUpdateable()){
            update itemsToUpdate;
            for(NE__OrderItem__c ne : itemsToUpdate){
                ne.XC_BlockWBE_User__c = false;
            }

            update itemsToUpdate;
            itemsToUpdate[0].NE__OrderId__r.XC_UpdateWBE_FromButton__c = true;
            update itemsToUpdate[0].NE__OrderId__r;
        }


        if(Schema.sObjectType.XC_WbeTracking__c.isAccessible() && !listTW.isEmpty()){
            insert listTW;
        }
    }

    private static List<NE__OrderItem__c> checkSkipIntegration(List<NE__OrderItem__c>itemsToUpdate){
        Set<String> setLegalEntity = new Set<String>();
        Set<String> setSegment = New Set<String>();
        for(NE__OrderItem__c ne : itemsToUpdate){
            setLegalEntity.add(ne.XC_LegalEntity__c);
            setSegment.add(ne.XC_Segment__c);
        }
        List<XC_CM_LegalEntity_Configuration__mdt> listCM = new List<XC_CM_LegalEntity_Configuration__mdt>();
        listCM = [SELECT ID, XC_LegalEntity__c, XC_Stream__c, XC_Skip_WBE_Integration__c  FROM XC_CM_LegalEntity_Configuration__mdt WHERE XC_LegalEntity__c IN :setLegalEntity AND XC_Stream__c IN :setSegment AND XC_OrgId__c =: UserInfo.getOrganizationId()];
        for(NE__OrderItem__c ne :itemsToUpdate){
            for(XC_CM_LegalEntity_Configuration__mdt cm :listCM){
                if(cm.XC_Skip_WBE_Integration__c && ne.XC_LegalEntity__c == cm.XC_LegalEntity__c && ne.XC_Segment__c == cm.XC_Stream__c){
                    ne.XC_WBE_Status__c = 'Approved';
                }
            }
        }
        return itemsToUpdate;

    }



    /*private static String getGeographicalData(String legalEntity, String segment,NE__Order__c theOrder){
        List<XC_WBEGeographicalData__c> geographicalData = (new Map<id,XC_WBEGeographicalData__c>([select Id, Name, XC_Country__c, XC_LegalEntity__c, XC_Segment__c, XC_ObjectToQuery__c, XC_FieldToQuery__c, XC_ValueToCompare__c, XC_ValueToUse__c, XC_OrderFieldReference__c
                                                              from XC_WBEGeographicalData__c WHERE XC_LegalEntity__c = :legalEntity AND XC_Segment__c = :segment])).values();
        String retValue = null;

        if(geographicalData.isEmpty()){
            return retValue;
        }
        String objectToQuery = geographicalData[0].XC_ObjectToQuery__c;
        String fieldToQuery = geographicalData[0].XC_FieldToQuery__c;

        String orderQuery = 'SELECT '+geographicalData[0].XC_OrderFieldReference__c+' FROM NE__Order__c WHERE ID = \''+theOrder.Id+'\'';
        NE__Order__c queriedOrder = (NE__Order__c) Database.query(orderQuery);

        String s1 = geographicalData[0].XC_OrderFieldReference__c;
        List<String> s2 = s1.contains('.') ? s1.split('[\\.]') : new List<String>{s1};
        SObject obj = queriedOrder; //s2.size()>1 ? (SObject) queriedOrder.get(s2[0]) : queriedOrder;
        String objectId = null;
        for(String s : s2){
            if(s.contains('__r')){
                obj = (SObject) obj.getSObject(s);
            }
            else{
                objectId = String.valueOf(obj.get(s));
            }
        }

        String query = 'SELECT Id,'+fieldToQuery+' FROM '+objectToQuery+' WHERE ID = \''+objectId+'\'';
        List<SObject> result = Database.query(query);
        String orderValue = null;
        if(result==null || result.isEmpty()){
            return retValue;
        }
        else{
            orderValue = (String) result[0].get(fieldToQuery);
        }

        for(XC_WBEGeographicalData__c gd : geographicalData){
            if(gd.XC_ValueToCompare__c == orderValue){
                return gd.XC_ValueToUse__c;
            }
        }

        return retValue;
    }*/

    public static Map<Id,String> getGeographicalDataOrderItem(String legalEntity, String segment,List<NE__OrderItem__c> theOrderItems){
        List<XC_WBEGeographicalData__c> geographicalData = (new Map<id,XC_WBEGeographicalData__c>([select Id, Name, XC_Country__c, XC_LegalEntity__c, XC_Segment__c, XC_ObjectToQuery__c, XC_FieldToQuery__c, XC_ValueToCompare__c, XC_ValueToUse__c, XC_OrderFieldReference__c
        from XC_WBEGeographicalData__c WHERE XC_LegalEntity__c = :legalEntity AND XC_Segment__c = :segment])).values();
        Map<Id,String> retValue = new  Map<Id,String>();

        if(geographicalData.isEmpty()){
            return retValue;
        }
        String objectToQuery = geographicalData[0].XC_ObjectToQuery__c;
        String fieldToQuery = geographicalData[0].XC_FieldToQuery__c;

        List<String> query1List = XC_UTIL_Sobject.getIds(theOrderItems);
        String orderQuery = 'SELECT Id, '+geographicalData[0].XC_OrderFieldReference__c+' FROM NE__OrderItem__c WHERE ID in :query1List';
        System.debug('§§1 '+orderQuery);
        List<NE__OrderItem__c> queriedOrders = (List<NE__OrderItem__c>) Database.query(orderQuery);

        String s1 = geographicalData[0].XC_OrderFieldReference__c;
        Boolean bb = s1.contains('.');
        List<String> splittedList = s1.split('[\\.]');
        List<String> s2 = s1.contains('.') ? s1.split('[\\.]') : new List<String>{s1};
        System.debug('§§s2 '+s2);
        Map<Id,String> allObjIds = new Map<Id,String>();
        for(NE__OrderItem__c queriedOrder : queriedOrders) {
            SObject obj = queriedOrder; //s2.size()>1 ? (SObject) queriedOrder.get(s2[0]) : queriedOrder;
            String objectId = null;
            for (String s : s2) {
                if (s.contains('__r')) {
                    obj = (SObject) obj.getSObject(s);
                } else {
                    objectId = String.valueOf(obj.get(s));
                }
            }
            allObjIds.put(queriedOrder.Id,objectId);
        }

        List<String> query2List = allObjIds.values();
        String query = 'SELECT Id,'+fieldToQuery+' FROM '+objectToQuery+' WHERE ID in :query2List';
        System.debug('§§2 '+query);
        List<SObject> result = Database.query(query);
        Map<Id,String> orderValues = new Map<Id, String>();
        if(result==null || result.isEmpty()){
            return retValue;
        }
        else{
            for(SObject o : result) {
                orderValues.put((Id) o.id,(String) o.get(fieldToQuery));
            }
        }

        for(NE__OrderItem__c queriedOrder : queriedOrders) {
            Id valueId = (Id) allObjIds.get(queriedOrder.Id);
            String orderValue = orderValues.get(valueId);
            for (XC_WBEGeographicalData__c gd : geographicalData) {
                if (gd.XC_ValueToCompare__c == orderValue) {
                    retValue.put(queriedOrder.Id,gd.XC_ValueToUse__c);
                }
            }
        }

        return retValue;
    }

    private static Map<Id,Contract> retrieveContract(List<wrappWBE> listWbeWrap){
        Set<Id> setIdOpportuinty = new Set<Id>();
        for(wrappWBE wr : listWbeWrap){
            setIdOpportuinty.add(wr.orderItem.NE__OrderId__r.NE__OptyId__c);
        }
        List<Contract> listContract = new List<Contract>();
        // @ Mod CV CR.NR1652 @date 28/10/2021 add XC_Zone__c to quey
        listContract = [SELECT id, XC_Configurations__c,Opportunity__c,XC_ContractType__c, Contract_Type__c,XC_Zone__c from Contract where Opportunity__c = :setIdOpportuinty];
        Map<Id,Contract> mapIdConfigurationContract = new Map<Id,Contract>();
        for(Contract c :listContract){
            mapIdConfigurationContract.put(c.Opportunity__c, c);
        }
        return mapIdConfigurationContract;
    }

    private static Decimal evalueteEstimatedRevenue(NE__OrderItem__c ne){
        String billingModel = ne.XC_BillingModel__c;
        if(billingModel == 'One Shot' || billingModel == 'Milestone' || billingModel == 'Installment plan' || billingModel == 'Billing Plan'){
            return ne.NE__OneTimeFeeOv__c;
        }else if(billingModel == 'Recurring') {
            return (ne.NE__RecurringChargeOv__c * ne.XC_RecurringDuration__c);
        }else if (billingModel == 'Saving Sharing' || billingModel =='Usage' || billingModel =='Revenue Sharing'){
            return ne.XC_EstimatedRevenue__c;
        }
        return null;

    }
    	
	
    private static Map<Id,Contract> retrieveOrderContract(List<wrappWBE> listWbeWrap){
        Set<Id> setIdOrderContract = new Set<Id>();
        for(wrappWBE wr : listWbeWrap){
            setIdOrderContract.add(wr.orderItem.NE__OrderId__c);
        }
        List<Contract> listContract = new List<Contract>();
        listContract = [SELECT id, XC_Configurations__c,StartDate, EndDate from Contract where   XC_Configurations__c = :setIdOrderContract];
        Map<Id,Contract> mapIdOrderContract = new Map<Id,Contract>();	
        for(Contract c1 :listContract){
            mapIdOrderContract.put(c1.XC_Configurations__c, c1);
        }
        return mapIdOrderContract;
    }
    
        private static Decimal evalueteRevenueFullLife(NE__OrderItem__c ne){
        	String billingModel = ne.XC_BillingModel__c;
        	if((ne.NE__Parent_Order_Item__c == null || ne.NE__CatalogItem__r.NE__Item_Header__c == null) && billingModel !='Capex'){
            	
                     return ne.XC_RevenueFullLife__c;
            }          
            else  {
                return 0;
        	}	
    	}

            private static Decimal evalueteEstimatedCost(NE__OrderItem__c ne){
            String billingModel = ne.XC_BillingModel__c;
                if( ne.NE__Parent_Order_Item__c == null || ne.NE__CatalogItem__r.NE__Item_Header__c == null){
                    if(billingModel !='Capex' ){
                        return ne.XC_CostFullLife__c;
                } if(billingModel == 'Capex' && ne.XC_CapexFullLife__c!=null) {    
                            return ne.XC_CapexFullLife__c;
            
                        }
                }
                return 0;
            }
    
    /**
     * @author Álvaro Lag Caballero - alag@deloitte.es
     * @description Method to assign fake WBE to Cogenio OIs
     * @param listItems -> list of Configuration Items of Cogenio Order
    */
    public static void calculateFakeWBE (List<NE__OrderItem__c> listItems){
        for(NE__OrderItem__C oi : listItems){
            oi.XC_Wbe__c = 'ES0000000000000000';
            oi.XC_WBE_Status__c = 'Approved';
        }
        if(Schema.sObjectType.NE__OrderItem__c.isUpdateable()){
            update listItems;
        }
    }
}