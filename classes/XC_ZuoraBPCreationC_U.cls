/**
*@author Francesco Imperioli - fimperioli@deloitte.it
*@description : Utility class for ZuoraBillingProfileCreationController
*@createddate 2020-03-06
**/
public without sharing class XC_ZuoraBPCreationC_U {

    /**
    * @author Francesco Imperioli - fimperioli@deloitte.it
    * @description return contracts for new commodity bill management for EndesaX - optmizied for doing only one call to read account
    * @createdDate 2020-03-03
    */
    public static final Set<String> acceptedStatuses = new Set<String>{'Active','In Progress','01','02'};

    public static List<Map<String,Object>> getCommodityContract(Map<String,Object> params){

          List<Map<String,Object>> result = new List<Map<String,Object>>();
          String docType = String.valueOf(params.get('documentType'));
          String docNumber = String.valueOf(params.get('documentNumber'));
          String docCountry = String.valueOf(params.get('docCountry'));
          String sfAccountId = String.valueOf(params.get('accountId'));
          List<XC_Integration_Log__c> finalCallLogs = new List<XC_Integration_Log__c>();

          if(String.isNotBlank(docType) && String.isNotBlank(docNumber) && String.isNotBlank(docCountry)){
              XC_REST_Contract_Outbound.ContractOutboudCallInputData wrap = new XC_REST_Contract_Outbound.ContractOutboudCallInputData();
              wrap.identityNumber = docNumber;
              wrap.country = docCountry;
              wrap.identityType = docType == 'CF' || docType.equalsIgnoreCase('Codice Fiscale') ? 'Codice%20Fiscale' :
                                  docType.equalsIgnoreCase('Partita IVA') ? 'Partita%20IVA' : docType;
              wrap.insertLoggin = false;
              XC_REST_Contract_Outbound.ContractOutboudCallOutputData contractRespWrap = XC_REST_Contract_Outbound.callToGetContract(wrap);
              finalCallLogs.addAll(contractRespWrap.integrationLog);
              Map<String,Object> contractResp = contractRespWrap.fieldsData;
              Map<String,Object> resultMap = (Map<String,Object>) contractResp.get('Result');

              if(resultMap.get('ErrorCode') == '0'){
                List<Object> contractsRetrieved = (List<Object>) contractResp.get('Contract');
                //in case of contract retrieved, call the get account to retrieve normalized address and build the objects

                if(contractsRetrieved != null && !contractsRetrieved.isEmpty()){
                    System.Debug('COMMODITY CONTRACTS FOUND:: ' + contractsRetrieved.size());

                    // if(docCountry.equalsIgnoreCase('Spain')){

                    //     Map<String,Object> commodityAccountResult = manageCallToReadAccount(params);
                    //     //added logs management in calls
                    //     List<XC_UTIL_Address.AddressWrapper> commodityAddresses = (List<XC_UTIL_Address.AddressWrapper>) commodityAccountResult.get('addresses');
                    //     finalCallLogs.addAll((List<XC_Integration_Log__c>) commodityAccountResult.get('logs'));
                    //     //call managed method for spain
                    //     manageForSpain(contractsRetrieved, commodityAddresses, result);

                    // }else if(docCountry.equalsIgnoreCase('Italy')){
                        manageGetContractResponses(contractsRetrieved,result);
                    // }
                }

              }
              
              XC_UTIL_SObject.insertListRecords(finalCallLogs);
              
          }
          
          return result;
    }


    /**
    * @description temporary management for spain commodity - TODO: remove this after mashery adjustments
    * @author Francesco Imperioli - fimperioli@deloitte.it | 14/4/2020 
    * @param contracts 
    * @param commodityAddresses 
    * @param result 
    * @return void 
    **/
    // private static void manageForSpain (List<Object> contracts, List<XC_UTIL_Address.AddressWrapper> commodityAddresses,List<Map<String,Object>> result){

    //     for(Object contractObj : contracts){
    //         Map<String,Object> params = new Map<String,Object>();
    //         Map<String,Object> contract = (Map<String,Object>) contractObj;
    //         String commodityAddressId = String.valueOf(contract.get('AddressID'));
    //         String contractId = String.valueOf(contract.get('ContractNumber'));
    //         String contractType = String.valueOf(contract.get('ContractType'));
    //         String contractStatus = contract.containsKey('Status') ? String.valueOf(contract.get('Status')) : 'Active';

    //         String commodityAccountId = String.valueOf(contract.get('AccountID'));
    //         String commodityBillingCycleFreq = String.valueOf(contract.get('CommodityBillingCycleFrequency'));

    //         if(String.isNotBlank(commodityAddressId) && acceptedStatuses.contains(contractStatus)){
    //             params.put('addressId',commodityAddressId);
    //             params.put('contractId',contractId);
    //             params.put('contractType',contractType);
    //             params.put('billingBatch',manageCommodityContractBillingFrequency(contract));
    //             params.put('contractStatus',contractStatus=='01' ? 'Active' : contractStatus == '02' ? 'In Progress' : contractStatus);

    //             params.put('commodityAccountId',commodityAccountId);
    //             if(String.isNotBlank(commodityBillingCycleFreq)){
    //                 params.put('commodityBillingCycleFreq',commodityBillingCycleFreq);
    //             }

    //             //manage the account addresses
    //             if(!commodityAddresses.isEmpty()){
    //                 for(XC_UTIL_Address.AddressWrapper commodityAddress : commodityAddresses){
    //                     if(commodityAddress.AddressID != null && commodityAddress.AddressID==commodityAddressId && !commodityAddress.PointOfService.isEmpty()){
    //                         manageCommodityAddresses(commodityAddress,params,result);
    //                     }
    //                 }
    //             }
    //         }
    //     }

    // }

    /**
    * @description global management for getContract responses in order to show consistent picklist in components
    * @author Francesco Imperioli - fimperioli@deloitte.it | 14/4/2020 
    * @param contracts 
    * @param result 
    * @return void 
    **/
    private static void manageGetContractResponses (List<Object> contracts,List<Map<String,Object>> resultList){

        Integer i = 0;

        for(Object contractObj : contracts){
            Map<String,Object> contract = (Map<String,Object>) contractObj;
            String commodityAddress = String.valueOf(contract.get('AddressData'));
            String contractId = String.valueOf(contract.get('ContractNumber'));
            String contractType = String.valueOf(contract.get('ContractType'));
            String contractTypeValue = contractType == '01' ? 'ELECTRIC' : contractType == '02' ? 'GAS' : contractType;
             //[ START, gaurav.tejpal@accenture.com, 14/07/2022,Enel X - Get Contract] -->
            String commodityCustomerName = String.valueOf(contract.get('commodityCustomerName'));
            String commodityIdentityNumber = String.valueOf(contract.get('commodityIdentityNumber'));
             //[ END, gaurav.tejpal@accenture.com,  14/07/2022,Enel X - Get Contract] -->

            String commodityAccountId = String.valueOf(contract.get('AccountID'));
            String commodityBillingCycleFreq = String.valueOf(contract.get('CommodityBillingCycleFrequency'));

            String contractStatus = contract.containsKey('Status') ? String.valueOf(contract.get('Status')) : 'Active';
            if(String.isNotBlank(commodityAddress) && acceptedStatuses.contains(contractStatus) && commodityAddress != '_ -  '){

                String contractPickKey =  String.isNotBlank(contractId) && contractId!=null ? contractId: commodityAddress.split('_')[0];
                String pickValue = contractTypeValue + ' - ' + Label.XC_CL_LCP116_ContractPickVal1 + ': ' + contractPickKey + ' - ' + Label.XC_CL_LCP116_ContractPickVal2 + ': ' + commodityAddress.split('_')[0] + ' - ' + Label.XC_CL_LCP116_ContractPickVal3 + ': ' + commodityAddress.split('_')[1];
                
                //mapping the status
                String contractStatusCodeMapping = contractStatus=='01' ? 'Active' : 
                contractStatus == '02' ? 'In Progress' : 
                String.isBlank(contractId) ? 'In Progress' : contractStatus;

                String contractKey = String.isNotBlank(contractId) && contractId!=null ? contractId + '-' + commodityAddress.split('_')[0] : commodityAddress.split('_')[0] + '_' + i;
                
                Map<String,Object> resultEntry = new Map<String,Object>();
                resultEntry.put('key',contractKey);
                resultEntry.put('cups', commodityAddress.split('_')[0]);
                resultEntry.put('contractId',contractStatusCodeMapping!= 'In Progress' ? contractId : commodityAddress.split('_')[0]);
                resultEntry.put('contractTypeCode',contractType);
                resultEntry.put('contractTypeValue',contractTypeValue);
                resultEntry.put('billingBatch',manageCommodityContractBillingFrequency(contract));
                resultEntry.put('fullAddress',commodityAddress.split('_')[1]);
                resultEntry.put('pickValue',pickValue);
                resultEntry.put('contractStatus',contractStatusCodeMapping);

                //Commodity Bill additional fields from contract
                resultEntry.put('commodityAccountId',commodityAccountId);
                if(String.isNotBlank(commodityBillingCycleFreq)){
                    resultEntry.put('commodityBillCyleFreqOrig',commodityBillingCycleFreq);
                }

                //[ START, gaurav.tejpal@accenture.com,14/07/2022,Enel X - Get Contract] -->
                resultEntry.put('commodityCustomerName',commodityCustomerName);
                resultEntry.put('commodityIdentityNumber',commodityIdentityNumber);
                //[ END, gaurav.tejpal@accenture.com, 14/07/2022,Enel X - Get Contract] -->  

                resultList.add(resultEntry);

                i++;

            }
        }
    }


    /**
    * @author Francesco Imperioli - fimperioli@deloitte.it
    * @description private util to manageReadAccountMessages from commodity getAccount
    * @createdDate 2020-03-03
    */
    // private static  Map<String,Object> manageCallToReadAccount(Map<String,Object> params){

    //     Map<String,Object> resultMap = new Map<String,Object>();

    //     String docType = String.valueOf(params.get('documentType'));
    //     String docNumber = String.valueOf(params.get('documentNumber'));
    //     String sfAccountId = String.valueOf(params.get('accountId'));
    //     List<XC_UTIL_Address.AddressWrapper> result = new List<XC_UTIL_Address.AddressWrapper>();
    //     XC_REST_ReadAccont.WrapperResult readAccountResult = XC_REST_ReadAccont.callToReadAccount(sfAccountId,new Map<String,String>{'IdentityNumber'=>docNumber,'IdentityType'=>docType},false);
    //     List<XC_Integration_Log__c> logs = readAccountResult.integrationLog;

    //     System.Debug('READ ACCOUNT ENTERED ' + readAccountResult.success);
    //     if(readAccountResult.success){
    //         XC_REST_Account_W.WrapperResponseGET commodityAccountResp = readAccountResult.readAccountResponse;
    //         if(commodityAccountResp.Result==null || commodityAccountResp.Result.ErrorCode == '00' ){ //null on result means that we are in fake response case.
    //             System.Debug('ACCOUNT CHECK');
    //             for(XC_UTIL_Account.AccountIFWrapper account : commodityAccountResp.Account){
    //                 for(XC_UTIL_Address.AddressWrapper commodityAddress : account.Address){
    //                         result.add(commodityAddress);
    //                 }
    //             }
    //         }
    //     }

    //     resultMap.put('addresses',result);
    //     resultMap.put('logs',logs);

    //     return resultMap;

    // }

    /**
    *@author Francesco Imperioli - fimperioli@deloitte.it
    *@description private util to manage addresses retrieved from commodity account
    */
    // public static void manageCommodityAddresses(XC_UTIL_Address.AddressWrapper address,Map<String,Object> params,List<Map<String,Object>> resultList){

    //     String fullAddressString = address.Address+', '+
    //     address.StreetNumber+', '+
    //     address.ZipCode+', '+
    //     address.City+', ' +
    //     address.Province;

    //     String posTypeKey = String.valueOf(params.get('contractType')) == '01' ? 'Light' : String.valueOf(params.get('contractType')) == '02' ? 'Gas' : '';
        
    //     for(XC_UTIL_Address.PoSWrapper cups : address.PointOfService){

    //         //added check on POSType
    //         if((String.isNotBlank(posTypeKey) && String.isNotBlank(cups.POSType) && posTypeKey.equalsIgnoreCase(cups.POSType)) || String.isBlank(cups.POSType)){

    //             Map<String,Object> resultEntry = new Map<String,Object>();
    //             String contractTypeValue = String.valueOf(params.get('contractType')) == '01' ? 'ELECTRIC' : String.valueOf(params.get('contractType')) == '02' ? 'GAS' : String.valueOf(params.get('contractType'));
    //             String pickValue = contractTypeValue + ' - ' + Label.XC_CL_LCP116_ContractPickVal1 + ': ' + String.valueOf(params.get('contractId')) + ' - ' + Label.XC_CL_LCP116_ContractPickVal2 + ': ' + cups.POS + ' - ' + Label.XC_CL_LCP116_ContractPickVal3 + ': ' + fullAddressString;
    
    //             resultEntry.put('key',String.valueOf(params.get('contractId')) + '-' + cups.POS);
    //             resultEntry.put('cups', cups.POS);
    //             resultEntry.put('contractId',String.valueOf(params.get('contractId')));
    //             resultEntry.put('contractTypeCode',String.valueOf(params.get('contractType')));
    //             resultEntry.put('contractTypeValue',contractTypeValue);
    //             resultEntry.put('billingBatch',String.valueOf(params.get('billingBatch')));
    //             resultEntry.put('fullAddress',fullAddressString);
    //             resultEntry.put('pickValue',pickValue);
    //             resultEntry.put('contractStatus',String.valueOf(params.get('contractStatus')));

    //             //Commodity Bill additional fields from contract
    //             resultEntry.put('commodityAccountId',String.valueOf(params.get('commodityAccountId')));
    //             if(String.isNotBlank(String.valueOf(params.get('commodityBillingCycleFreq')))){
    //                 resultEntry.put('commodityBillCyleFreqOrig',String.valueOf(params.get('commodityBillingCycleFreq')));
    //             }

    //             resultList.add(resultEntry);
    //         }
    //     }

    // }


    /**
     * @author Francesco Imperioli - fimperioli@deloitte.it
     * @description manages billingFrequency returned from getContract in order to MAP Zuora Billing Batches
     * @createddate 2020-03-13
     */
    
    public static String manageCommodityContractBillingFrequency(Map<String,Object> commodityContract){
        return 'Batch1';

        //TODO: Verify Map Key for BillingFrequency
       /* String billingFrequency = commodityContract.containsKey('CommodityBillingCycleFrequency') ? String.valueOf(commodityContract.get('CommodityBillingCycleFrequency')) : '';
        String zuoraBatch = String.isBlank(billingFrequency) ? 'Batch1' :  !billingFrequency.equalsIgnoreCase('01') ? 'Batch50' : 'Batch1';
        return zuoraBatch; 
		*/
    }









}