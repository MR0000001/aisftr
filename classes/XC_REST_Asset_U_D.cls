/**
* @author Simone Trenta - strenta@deloitte.it
* @date Creation 19/12/2018
* @date Modification dd/mm/yyyy
* @description XC_REST_Asset_U_D - dao class for rest asset
*/

public without sharing class XC_REST_Asset_U_D {

    /**
     * @description GetAssetById.
     * @param assetId the asset id
     * @return the Asset
     * @description: Method to get Asset by Id
     **/  
    public static Asset getAssetById(Id assetId){
            
        Set<String> setFields = new Set<String>{'id', 
                                                'name',
                                                'status', 
                                                'accountid', 
                                                'account.IdentityNumber__c',
                                                'account.PrimaryEmail__c',
                                                'NE__BaseRecurringCharge__c', 
                                                'ContactID', 
                                                'Quantity', 
                                                'SerialNumber', 
                                                'CurrencyIsoCode', 
                                                'PurchaseDate', 
                                                'InstallDate', 
                                                'UsageEndDate', 
                                                'IsCompetitorProduct', 
                                                'XC_Warranty_End_Date__c',
                                                'XC_ElectricalConnectionType__c', 
                                                'XC_ElectricalConnectionDate__c',
                                                'XC_Product_Catalog_Category__c',
                                                'NE__UsageCode__c'};

        List<Asset> a = (List<Asset>) XC_UTIL_Query.selectFieldsList(setFields, assetId);

        if(a.isEmpty()) {
            return null;
        }

        return a[0];
    }


    /**
     * @description GetAssetByAccount.
     * @param mapParams the map of account parameters
     * @return the list of Asset
     * @description: Method to get Asset by Account parameters
     **/  
    public static List<asset> getAssetByAccount(Map<string,string> mapParams){
        
        list<asset> res = new list<asset>();
        String accId = getAccount(mapParams);
        
        if (String.isBlank(accId)) {
            return res; //nessun account trovato

        } else{
            
            String query = 'SELECT Id, Name, Status, Accountid, NE__BaseRecurringCharge__c, ContactID, Quantity, SerialNumber, CurrencyIsoCode, '  +
                'PurchaseDate, InstallDate, UsageEndDate, IsCompetitorProduct, XC_Warranty_End_Date__c, XC_Address__c, '+
                'NE__Penalty_Fee__c, XC_Product_Name__c, NE__CatalogItem__r.NE__Engine_Code__c,XC_Subscription__r.Zuora__External_Id__c, '+
                'XC_Subscription__r.Zuora__CustomerAccount__r.Zuora__External_Id__c, NE__Catalog__r.Name, XC_NumberOfRepairs__c, '+
                'NE__Activation_Date__c, NE__ProdId__c, NE__CatalogItem__r.XC_Brand__c, NE__CatalogItem__c, XC_BillingModel__c, XC_PaymentMethod__c, '+
                'XC_BillingProfileLineItem__c, NE__BaseOneTimeFee__c, NE__Bundle_Configuration__c, XC_Model__c,XC_Product_Type__c, XC_AssociateToCustomer__c, XC_SpecialOfferType__c, '+
                'XC_Product_Subtype__c, ParentId, XC_ElectricalConnectionType__c, XC_ElectricalConnectionDate__c, NE__Catalog__c, NE__CatalogItem__r.NE__Catalog_Category_Name__c, NE__UsageCode__c, NE__CatalogItem__r.NE__UsageCode__c, XC_Contract__r.ContractNumber, '+ /*NicoloFodera 20220718 Added NE__CatalogItem__r.NE__UsageCode__c*/
                'XC_BillingProfileLineItem__r.XC_BillingProfile__r.XC_CommodityContractID__c, NE__ProdId__r.NE__Source_Product_Id__c'+ //20220429 LorenzoEvangelisti NR2476 Add CommodityContractNumber and SourceProduct fields in read Asset
            ' FROM Asset ' + 
            ' WHERE AccountId =: accId';

            
            if( mapParams.get('SerialNumber')!= null){
                String serialNumber = mapParams.get('SerialNumber');
                query += ' AND SerialNumber = :serialNumber';
            }

            res = (List<Asset>)Database.query(query);
            /*
            Map<Id, Asset> assetMap = new Map<Id, Asset>([  SELECT Id, Name, Status, Accountid, NE__BaseRecurringCharge__c, ContactID, Quantity, SerialNumber, CurrencyIsoCode,
                                                                PurchaseDate, InstallDate, UsageEndDate, IsCompetitorProduct, XC_Warranty_End_Date__c, XC_Address__c,
                                                                NE__Penalty_Fee__c, XC_Product_Name__c, NE__CatalogItem__r.NE__Engine_Code__c,XC_Subscription__r.Zuora__External_Id__c,
                                                                XC_Subscription__r.Zuora__CustomerAccount__r.Zuora__External_Id__c, NE__Catalog__r.Name, XC_NumberOfRepairs__c,
                                                                NE__Activation_Date__c, NE__ProdId__c, NE__CatalogItem__r.XC_Brand__c, NE__CatalogItem__c, XC_BillingModel__c, XC_PaymentMethod__c,
                                                                XC_BillingProfileLineItem__c, NE__BaseOneTimeFee__c, NE__Bundle_Configuration__c, XC_Model__c,XC_Product_Type__c,
                                                                XC_Product_Subtype__c, ParentId, XC_ElectricalConnectionType__c, XC_ElectricalConnectionDate__c
                                                            FROM Asset
                                                            WHERE AccountId =: accId]);

            res = assetMap.values();
            */
        }    

        return res;
    }
    

    /**
     * @description GetAssetByAddress.
     * @param mapParams the map of address parameters
     * @return the list of Assetù
     * @description: Method to get Asset by Address parameters
     **/
    public static List<asset> getAssetByAddress(Map<string,string> mapParams){

        List<Asset> assetList = new List<Asset>();

        String query= 'SELECT Id, Name, Status, Accountid, NE__BaseRecurringCharge__c, ContactID, Quantity, SerialNumber, CurrencyIsoCode, PurchaseDate, InstallDate,' + 
        'UsageEndDate, IsCompetitorProduct, XC_Warranty_End_Date__c, XC_Address__c, NE__Penalty_Fee__c, XC_Product_Name__c, NE__CatalogItem__r.NE__Engine_Code__c,' +
        'XC_Subscription__r.Zuora__External_Id__c, XC_Subscription__r.Zuora__CustomerAccount__r.Zuora__External_Id__c, NE__Catalog__r.Name,' +
        'XC_NumberOfRepairs__c, NE__Activation_Date__c, NE__ProdId__c, NE__CatalogItem__r.XC_Brand__c, NE__CatalogItem__c, XC_BillingModel__c, XC_PaymentMethod__c,' +
        'XC_BillingProfileLineItem__c, NE__BaseOneTimeFee__c, NE__Bundle_Configuration__c, XC_Model__c,XC_Product_Type__c, XC_Product_Subtype__c, ParentId,' +
        'XC_ElectricalConnectionType__c, XC_ElectricalConnectionDate__c, NE__Catalog__c, NE__CatalogItem__r.NE__Catalog_Category_Name__c, XC_AssociateToCustomer__c, XC_SpecialOfferType__c, NE__UsageCode__c, NE__CatalogItem__r.NE__UsageCode__c, ' + /*NicoloFodera 20220718 Added NE__CatalogItem__r.NE__UsageCode__c*/
        'XC_BillingProfileLineItem__r.XC_BillingProfile__r.XC_CommodityContractID__c, NE__ProdId__r.NE__Source_Product_Id__c, XC_Contract__r.ContractNumber'+ //20220429 LorenzoEvangelisti NR2476 Add CommodityContractNumber and SourceProduct fields in read Asset , //20220607 NicoloFodera Added missing field XC_Contract__r.ContractNumber
        ' FROM Asset ';

        if(String.isNotBlank(mapParams.get('AddressID'))) {

            if(!Schema.sObjectType.Asset.isAccessible()){
                return new List<Asset>();
            }
            String addressID = mapParams.get('AddressID');
            query += 'WHERE XC_Address__c =: addressID';
        
        /*
            assetList = [   SELECT Id, Name, Status, Accountid, NE__BaseRecurringCharge__c, ContactID, Quantity, SerialNumber, CurrencyIsoCode, PurchaseDate, InstallDate, 
                                UsageEndDate, IsCompetitorProduct, XC_Warranty_End_Date__c, XC_Address__c, NE__Penalty_Fee__c, XC_Product_Name__c, NE__CatalogItem__r.NE__Engine_Code__c,
                                XC_Subscription__r.Zuora__External_Id__c, XC_Subscription__r.Zuora__CustomerAccount__r.Zuora__External_Id__c, NE__Catalog__r.Name,
                                XC_NumberOfRepairs__c, NE__Activation_Date__c, NE__ProdId__c, NE__CatalogItem__r.XC_Brand__c, NE__CatalogItem__c, XC_BillingModel__c, XC_PaymentMethod__c,
                                XC_BillingProfileLineItem__c, NE__BaseOneTimeFee__c, NE__Bundle_Configuration__c, XC_Model__c,XC_Product_Type__c, XC_Product_Subtype__c, ParentId,
                             XC_ElectricalConnectionType__c, XC_ElectricalConnectionDate__c
                            FROM Asset
                            WHERE XC_Address__c =: mapParams.get('AddressID')];
        */
        } else {
            if(!Schema.sObjectType.Asset.isAccessible()){
                return new List<Asset>();    
            }
            
            String address=mapParams.get('Address');
            String streetType = mapParams.get('StreetType');
            String streetNumb = mapParams.get('StreetNumber');
            String zipcode = mapParams.get('ZipCode');
            String city = mapParams.get('City');
            String country= mapParams.get('Country');
            String category = mapParams.get('Category');
            String door = mapParams.get('Door');
            String stair = mapParams.get('Stair');
            String province = mapParams.get('Province');
            System.debug('StreetType: '+ mapParams.get('StreetType') );
            System.debug('map:' + mapParams);
            query += 'WHERE XC_Address__r.Name =:address'+
                ' AND XC_Address__r.XC_StreetNumber__c =: streetNumb' +
                ' AND XC_Address__r.XC_PostalCode__c =:zipCode'+ 
                ' AND XC_Address__r.XC_StreetType__c =: streetType'+
                ' AND XC_Address__r.XC_City__c =: city' +
                ' AND XC_Address__r.XC_AddressCountry__c =: country'+
                ' AND XC_Address__r.XC_Category__c =: category'+
                ' AND XC_Address__r.XC_Door__c =: door' +
                ' AND XC_Address__r.XC_Stair__c =: stair'+
                ' AND XC_Address__r.XC_AddressProvince__c =: province';
               
            /*
            assetList = [   SELECT Id, Name, Status, Accountid, NE__BaseRecurringCharge__c, ContactID, Quantity, SerialNumber, CurrencyIsoCode, PurchaseDate, InstallDate, 
                                UsageEndDate, IsCompetitorProduct, XC_Warranty_End_Date__c, XC_Address__c, NE__Penalty_Fee__c, XC_Product_Name__c, NE__CatalogItem__r.NE__Engine_Code__c,
                                XC_Subscription__r.Zuora__External_Id__c, XC_Subscription__r.Zuora__CustomerAccount__r.Zuora__External_Id__c, NE__Catalog__r.Name,
                                XC_NumberOfRepairs__c, NE__Activation_Date__c, NE__ProdId__c, NE__CatalogItem__r.XC_Brand__c, NE__CatalogItem__c, XC_BillingModel__c, XC_PaymentMethod__c,
                                XC_BillingProfileLineItem__c, NE__BaseOneTimeFee__c, NE__Bundle_Configuration__c, XC_Model__c,XC_Product_Type__c, XC_Product_Subtype__c, ParentId,
                             XC_ElectricalConnectionType__c, XC_ElectricalConnectionDate__c
                            FROM Asset
                            WHERE XC_Address__r.Name =: mapParams.get('Address')
                            AND XC_Address__r.XC_StreetType__c =: mapParams.get('StreetType')
                            AND XC_Address__r.XC_StreetNumber__c =: mapParams.get('StreetNumber')
                            AND XC_Address__r.XC_PostalCode__c =: mapParams.get('ZipCode')
                            AND XC_Address__r.XC_City__c =: mapParams.get('City')
                            AND XC_Address__r.XC_AddressCountry__c =: mapParams.get('Country')
                            AND XC_Address__r.XC_Category__c =: mapParams.get('Category')
                            AND XC_Address__r.XC_Door__c =: mapParams.get('Door')
                            AND XC_Address__r.XC_Stair__c =: mapParams.get('Stair')
                            AND XC_Address__r.XC_AddressProvince__c =: mapParams.get('Province')];
            
            system.debug('simone:'+assetList);*/
            
        }
        
        if( mapParams.get('SerialNumber')!= null){
            String serialNumber = mapParams.get('SerialNumber');
            query += ' AND SerialNumber = :serialNumber';
        }
        //query += ' LIMIT 10';
        return (List<Asset>)Database.query(query);
        //return assetList;
    }
    

    /**
     * @description GetAssetByPOD.
     * @param mapParams the map of pod parameters
     * @return the list of Asset
     * @description: Method to get Asset by pod parameters
     **/
    public static List<asset> getAssetByPOD(Map<string,string> mapParams){
        list<asset> res = new list<asset>();

        Set<String> setFields = new Set<String>{'id', 'XC_Address__c'};
        List<XC_PointOfService__c> pos = (List<XC_PointOfService__c>) XC_UTIL_Query.selectFieldsList(setFields, mapParams.get('POSID'));
                                            
        List<String> addids = new List<String>();
        for (XC_PointOfService__c p : pos) {
            addids.add(p.XC_Address__c);
        }
        String query = 'SELECT Id, Name, Status, Accountid, NE__BaseRecurringCharge__c, ContactID, Quantity, SerialNumber, CurrencyIsoCode,'+
        ' PurchaseDate, InstallDate, UsageEndDate, IsCompetitorProduct, XC_Warranty_End_Date__c, XC_Address__c,'+
        ' NE__Penalty_Fee__c, XC_Product_Name__c, NE__CatalogItem__r.NE__Engine_Code__c, XC_Subscription__r.Zuora__External_Id__c,'+
        ' XC_Subscription__r.Zuora__CustomerAccount__r.Zuora__External_Id__c, NE__Catalog__r.Name, XC_NumberOfRepairs__c,'+
        ' NE__Activation_Date__c, NE__ProdId__c, NE__CatalogItem__r.XC_Brand__c, NE__CatalogItem__c, XC_BillingModel__c, XC_PaymentMethod__c,'+
        ' XC_BillingProfileLineItem__c, NE__BaseOneTimeFee__c, NE__Bundle_Configuration__c, XC_Model__c,XC_Product_Type__c, XC_AssociateToCustomer__c, XC_SpecialOfferType__c,'+
        ' XC_Product_Subtype__c, ParentId, XC_ElectricalConnectionType__c, XC_ElectricalConnectionDate__c, NE__Catalog__c, NE__CatalogItem__r.NE__Catalog_Category_Name__c, NE__UsageCode__c,  NE__CatalogItem__r.NE__UsageCode__c, '+  /*NicoloFodera 20220718 Added NE__CatalogItem__r.NE__UsageCode__c*/
        ' XC_BillingProfileLineItem__r.XC_BillingProfile__r.XC_CommodityContractID__c, NE__ProdId__r.NE__Source_Product_Id__c, XC_Contract__r.ContractNumber '+ //20220429 LorenzoEvangelisti NR2476 Add CommodityContractNumber and SourceProduct fields in read Asset, //20220607 NicoloFodera Added missing field XC_Contract__r.ContractNumber
        ' FROM Asset WHERE XC_Address__c in: addids';
        /*
        Map<Id, Asset> assetMap = new Map<Id, Asset>([  SELECT Id, Name, Status, Accountid, NE__BaseRecurringCharge__c, ContactID, Quantity, SerialNumber, CurrencyIsoCode,
                                                            PurchaseDate, InstallDate, UsageEndDate, IsCompetitorProduct, XC_Warranty_End_Date__c, XC_Address__c,
                                                            NE__Penalty_Fee__c, XC_Product_Name__c, NE__CatalogItem__r.NE__Engine_Code__c, XC_Subscription__r.Zuora__External_Id__c,
                                                            XC_Subscription__r.Zuora__CustomerAccount__r.Zuora__External_Id__c, NE__Catalog__r.Name, XC_NumberOfRepairs__c,
                                                            NE__Activation_Date__c, NE__ProdId__c, NE__CatalogItem__r.XC_Brand__c, NE__CatalogItem__c, XC_BillingModel__c, XC_PaymentMethod__c,
                                                            XC_BillingProfileLineItem__c, NE__BaseOneTimeFee__c, NE__Bundle_Configuration__c, XC_Model__c,XC_Product_Type__c,
                                                            XC_Product_Subtype__c, ParentId, XC_ElectricalConnectionType__c, XC_ElectricalConnectionDate__c
                                                        FROM Asset WHERE XC_Address__c in: addids]);
        res = assetMap.values();
        */
        if( mapParams.get('SerialNumber')!= null){
            String serialNumber = mapParams.get('SerialNumber');
            query += ' AND SerialNumber = :serialNumber';
        }

        return (List<Asset>)Database.query(query);
    }


    /**
     * @description GetAccount.
     * @param mapParams the map params
     * @return the accout id
     * @description: Method to get Account ID
     **/
    public static String getAccount(Map<string,string> mapParams){

        String accountId = mapParams.get('AccountID');
        String primaryEmail = mapParams.get('PrimaryEmail');
        String identityNumber = mapParams.get('IdentityNumber');
        String uniqueId = mapParams.get('UniqueID');
        String method = mapParams.get('Method');
        
        List<Account> listAccount;                      /* The account to be associated to the voucher */
                
        if(String.isNotBlank(accountId)) {      /* Retrieve the account by one key */
            /*
            Map<Id, Account> accMap = new Map<Id, Account>([SELECT Id, IdentityNumber__c, PrimaryEmail__c,
                                                            (SELECT Id, XC_DocumentNumber__c FROM Personal_Documents__r)
                                                            FROM Account 
                                                            WHERE Id = :accountId]);
            listAccount = accMap.values();
            */
            return mapParams.get('AccountID');
        
        } else if (String.isNotBlank(primaryEmail)) {
            Map<Id, Account> accMap = new Map<Id, Account>([SELECT Id, IdentityNumber__c, PrimaryEmail__c,
                                                            (SELECT Id, XC_DocumentNumber__c FROM Personal_Documents__r)
                                                            FROM Account 
                                                            WHERE PrimaryEmail__c = :PrimaryEmail]);
            listAccount = accMap.values();
                
        } else if (String.isNotBlank(identityNumber)) {
            Map<Id, Account> accMap = new Map<Id, Account>([SELECT Id, IdentityNumber__c, PrimaryEmail__c, RecordType.Name,
                                                            (SELECT Id, XC_DocumentNumber__c FROM Personal_Documents__r)
                                                            FROM Account 
                                                            WHERE IdentityNumber__c = :IdentityNumber]);
            listAccount = accMap.values();

            if(listAccount.isEmpty() || listAccount[0].RecordType.Name == 'Residential') {
                accMap = new Map<Id, Account>([SELECT Id, IdentityNumber__c, PrimaryEmail__c,
                                                                (SELECT Id, XC_DocumentNumber__c FROM Personal_Documents__r WHERE XC_DocumentNumber__c =: IdentityNumber)
                                                                FROM Account
                                                                WHERE Id IN (SELECT XC_Account__c FROM XC_PersonalDocument__c WHERE XC_DocumentNumber__c =: IdentityNumber)]);
                listAccount = accMap.values();
            }

        } else if (String.isNotBlank(uniqueId)) {
            Map<Id, Account> accMap = new Map<Id, Account>([SELECT Id, IdentityNumber__c, PrimaryEmail__c,
                                                            (SELECT Id, XC_DocumentNumber__c FROM Personal_Documents__r)
                                                            FROM Account 
                                                            WHERE XC_UniqueId__c = :uniqueId]);
            listAccount = accMap.values();
        }

        if( listAccount.isEmpty() ||( String.isBlank(listAccount.get(0).IdentityNumber__c) && listAccount.get(0).Personal_Documents__r.isEmpty() ) && method == 'POST'){
            return Label.XC_CL_Account_MissingDocument;
        }

        if(listAccount.size() > 0) {
            return listAccount.get(0).id;
        }
                
        return '';
    }


     /**
     * @description GetAssetBySusbscription.
     * @param subscriptionID the subscription ID
     * @param status the status
     * @return the asset list by susbscription
     * @description: Method to get Asset list by susbscription
     */
    public static List<Asset> getAssetBySusbscription(String subscriptionID, String status){
        
        if(!String.isBlank(Status)){
            /*Map<String, zqu__Quote__c> mapIdZquote = New Map<String, zqu__Quote__c>([SELECT id, zqu__ZuoraSubscriptionID__c FROM zqu__Quote__c 
                                                        WHERE zqu__ZuoraSubscriptionID__c =: SubscriptionID]); */
            return [SELECT Id, Name, Status, Accountid, NE__BaseRecurringCharge__c, ContactID, Quantity, SerialNumber, CurrencyIsoCode, PurchaseDate, InstallDate,
                        UsageEndDate, IsCompetitorProduct, XC_Warranty_End_Date__c, XC_Address__c, NE__Penalty_Fee__c, XC_Product_Name__c,
                        NE__CatalogItem__r.NE__Engine_Code__c, XC_Subscription__r.Zuora__External_Id__c, XC_Subscription__r.Zuora__CustomerAccount__r.Zuora__External_Id__c,
                        NE__Catalog__r.Name, XC_NumberOfRepairs__c, NE__Activation_Date__c, NE__ProdId__c, NE__CatalogItem__r.XC_Brand__c, NE__CatalogItem__c, XC_BillingModel__c, XC_PaymentMethod__c,
                        XC_BillingProfileLineItem__c, NE__BaseOneTimeFee__c, NE__Bundle_Configuration__c, XC_Model__c,XC_Product_Type__c,XC_AssociateToCustomer__c,XC_SpecialOfferType__c,
                        XC_Product_Subtype__c, ParentId, XC_ElectricalConnectionType__c, XC_ElectricalConnectionDate__c, NE__Catalog__c, NE__CatalogItem__r.NE__Catalog_Category_Name__c,
                        NE__UsageCode__c, NE__CatalogItem__r.NE__UsageCode__c, /*NicoloFodera 20220718 Added NE__CatalogItem__r.NE__UsageCode__c*/  XC_BillingProfileLineItem__r.XC_BillingProfile__r.XC_CommodityContractID__c, NE__ProdId__r.NE__Source_Product_Id__c,XC_Contract__r.ContractNumber, (SELECT Id, Status FROM NE__Assets4__r), (SELECT Id, Status FROM ChildAssets) //20220429 LorenzoEvangelisti NR2476 Add CommodityContractNumber and SourceProduct fields in read Asset, //20220607 NicoloFodera Added missing field XC_Contract__r.ContractNumber
                    FROM Asset
                    WHERE Status =:Status AND XC_Subscription__r.Zuora__External_Id__c =: subscriptionID];

        } else {
            /*Map<String, zqu__Quote__c> mapIdZquote = New Map<String, zqu__Quote__c>([SELECT id, zqu__ZuoraSubscriptionID__c FROM zqu__Quote__c 
                                                        WHERE zqu__ZuoraSubscriptionID__c =: SubscriptionID]);*/
            return [SELECT  Id, Name, Status, Accountid, NE__BaseRecurringCharge__c, ContactID, Quantity, SerialNumber, CurrencyIsoCode, PurchaseDate, InstallDate,
                        UsageEndDate, IsCompetitorProduct, XC_Warranty_End_Date__c, XC_Address__c, NE__Penalty_Fee__c, XC_Product_Name__c, NE__CatalogItem__r.NE__Engine_Code__c,
                        XC_Subscription__r.Zuora__External_Id__c, XC_Subscription__r.Zuora__CustomerAccount__r.Zuora__External_Id__c, NE__Catalog__r.Name, XC_NumberOfRepairs__c,
                        NE__Activation_Date__c, NE__ProdId__c, NE__CatalogItem__r.XC_Brand__c, NE__CatalogItem__c, XC_BillingModel__c, XC_PaymentMethod__c, XC_BillingProfileLineItem__c,XC_AssociateToCustomer__c, XC_SpecialOfferType__c, 
                        NE__BaseOneTimeFee__c, NE__Bundle_Configuration__c, XC_Model__c,XC_Product_Type__c, XC_Product_Subtype__c, ParentId, XC_ElectricalConnectionType__c, XC_ElectricalConnectionDate__c, NE__Catalog__c,
                        NE__CatalogItem__r.NE__Catalog_Category_Name__c, NE__UsageCode__c, NE__CatalogItem__r.NE__UsageCode__c, /*NicoloFodera 20220718 Added NE__CatalogItem__r.NE__UsageCode__c*/ XC_BillingProfileLineItem__r.XC_BillingProfile__r.XC_CommodityContractID__c, NE__ProdId__r.NE__Source_Product_Id__c, XC_Contract__r.ContractNumber //20220429 LorenzoEvangelisti NR2476 Add CommodityContractNumber and SourceProduct fields in read Asset, //20220607 NicoloFodera Added missing field XC_Contract__r.ContractNumber
                    FROM Asset
                    WHERE XC_Subscription__r.Zuora__External_Id__c =: subscriptionID];
        }
    }

    /**
     * @description GetAssetByAssetID.
     * @param AssetID
     * @param status
     * @return the asset list by AssetID
     * @description: Method to get Asset list by AssetID
     */
    public static List<Asset> getAssetByAssetID(String AssetID, String status){
        
        
        if(!String.isBlank(Status)){

            return [SELECT Id, Name, Status, Accountid, NE__BaseRecurringCharge__c, ContactID, Quantity, SerialNumber, CurrencyIsoCode, PurchaseDate, InstallDate,
                        UsageEndDate, IsCompetitorProduct, XC_Warranty_End_Date__c, XC_Address__c, NE__Penalty_Fee__c, XC_Product_Name__c,
                        NE__CatalogItem__r.NE__Engine_Code__c, XC_Subscription__r.Zuora__External_Id__c, XC_Subscription__r.Zuora__CustomerAccount__r.Zuora__External_Id__c,
                        NE__Catalog__r.Name, XC_NumberOfRepairs__c, NE__Activation_Date__c, NE__ProdId__c, NE__CatalogItem__r.XC_Brand__c, NE__CatalogItem__c, XC_BillingModel__c, XC_PaymentMethod__c,
                        XC_BillingProfileLineItem__c, NE__BaseOneTimeFee__c, NE__Bundle_Configuration__c, XC_Model__c,XC_Product_Type__c,XC_AssociateToCustomer__c, XC_SpecialOfferType__c, 
                        XC_Product_Subtype__c, ParentId, XC_ElectricalConnectionType__c, XC_ElectricalConnectionDate__c, NE__Catalog__c, NE__CatalogItem__r.NE__Catalog_Category_Name__c,
                        NE__UsageCode__c,NE__CatalogItem__r.NE__UsageCode__c, /*NicoloFodera 20220718 Added NE__CatalogItem__r.NE__UsageCode__c*/ XC_BillingProfileLineItem__r.XC_BillingProfile__r.XC_CommodityContractID__c, NE__ProdId__r.NE__Source_Product_Id__c, XC_Contract__r.ContractNumber, (SELECT Id, Status FROM NE__Assets4__r), (SELECT Id, Status FROM ChildAssets) //20220429 LorenzoEvangelisti NR2476 Add CommodityContractNumber and SourceProduct fields in read Asset, //20220607 NicoloFodera Added missing field XC_Contract__r.ContractNumber
                    FROM Asset
                    WHERE Status =:Status AND Id =: AssetID];

        } else {

            return [SELECT Id, Name, Status, Accountid, NE__BaseRecurringCharge__c, ContactID, Quantity, SerialNumber, CurrencyIsoCode, PurchaseDate, InstallDate,
                        UsageEndDate, IsCompetitorProduct, XC_Warranty_End_Date__c, XC_Address__c, NE__Penalty_Fee__c, XC_Product_Name__c, NE__CatalogItem__r.NE__Engine_Code__c,
                        XC_Subscription__r.Zuora__External_Id__c, XC_Subscription__r.Zuora__CustomerAccount__r.Zuora__External_Id__c, NE__Catalog__r.Name, XC_NumberOfRepairs__c,
                        NE__Activation_Date__c, NE__ProdId__c, NE__CatalogItem__r.XC_Brand__c, NE__CatalogItem__c, XC_BillingModel__c, XC_PaymentMethod__c, XC_BillingProfileLineItem__c,XC_AssociateToCustomer__c, XC_SpecialOfferType__c, 
                        NE__BaseOneTimeFee__c, NE__Bundle_Configuration__c, XC_Model__c,XC_Product_Type__c, XC_Product_Subtype__c, ParentId, XC_ElectricalConnectionType__c, XC_ElectricalConnectionDate__c, NE__Catalog__c,
                        NE__CatalogItem__r.NE__Catalog_Category_Name__c, NE__UsageCode__c, NE__CatalogItem__r.NE__UsageCode__c, /*NicoloFodera 20220718 Added NE__CatalogItem__r.NE__UsageCode__c*/ XC_BillingProfileLineItem__r.XC_BillingProfile__r.XC_CommodityContractID__c, NE__ProdId__r.NE__Source_Product_Id__c, XC_Contract__r.ContractNumber //20220429 LorenzoEvangelisti NR2476 Add CommodityContractNumber and SourceProduct fields in read Asset, //20220607 NicoloFodera Added missing field XC_Contract__r.ContractNumber
                    FROM Asset
                    WHERE Id =: AssetID];
        }
    }

}