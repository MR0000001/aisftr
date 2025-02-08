/**
 * @description       : 
 * @author            : pedro.danielalmeida@nttdata.com
 * @group             : 
 * @last modified on  : 05-05-2022
 * @last modified by  : pedro.danielalmeida@nttdata.com
**/
public without sharing class XC_TR_ContractService_U_CheckDuplicates {
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_ContractService_U_CheckDuplicates');

    /**
    * @description check for duplicate contract services on contract
    * @author pedro.danielalmeida@nttdata.com | 26-04-2022 
    * @param listNew 
    **/
    public static void checkInsertContractService(List<XC_ContractItem__c> listNew) {
        Map<Id, Contract> mapContractLegalEntity = new Map<Id, Contract>();
        Map<Id, List<XC_ContractItem__c>> mapContractsWithContractServices = new Map<Id, List<XC_ContractItem__c>>();
        for (XC_ContractItem__c contService : listNew) {
            mapContractLegalEntity.put(contService.XC_Contract__c, null);
            mapContractsWithContractServices.put(contService.XC_Contract__c, new List<XC_ContractItem__c>{});
        }

        //get legal entity from contract
        for (Contract cont : [SELECT Id,XC_LegalEntity__c, XC_Segment__c
                              FROM Contract 
                              WHERE Id IN :mapContractLegalEntity.keySet()]) {
            mapContractLegalEntity.put(cont.Id, cont);
        }

        //get all contract services from each contract
        List<XC_ContractItem__c> lstContractServicesSF = new List<XC_ContractItem__c>();
        for (XC_ContractItem__c contService : [SELECT Id,XC_ProdName__c,XC_Contract__c 
                                               FROM XC_ContractItem__c 
                                               WHERE XC_Contract__c
                                               IN: mapContractsWithContractServices.keySet()]) {

            if (mapContractsWithContractServices.containsKey(contService.XC_Contract__c)) {
                lstContractServicesSF = mapContractsWithContractServices.get(contService.XC_Contract__c);
                lstContractServicesSF.add(contService);
                mapContractsWithContractServices.put(contService.XC_Contract__c,lstContractServicesSF);
            }
            else {
                mapContractsWithContractServices.put(contService.XC_Contract__c,new List<XC_ContractItem__c> {contService});
            }
        }

        //compare new contract services with the ones that alread exist
        for (XC_ContractItem__c newContService : listNew) {
            if (String.isBlank(newContService.XC_ProdName__c)) continue;
            if (mapContractsWithContractServices.get(newContService.XC_Contract__c) == null) continue;

            lstContractServicesSF = mapContractsWithContractServices.get(newContService.XC_Contract__c);
            for (XC_ContractItem__c contService : lstContractServicesSF) {
                if (newContService.XC_ProdName__c.equalsIgnoreCase(contService.XC_ProdName__c)) {
                    if (mapContractLegalEntity.get(contService.XC_Contract__c) != null){
                        if (mapContractLegalEntity.get(contService.XC_Contract__c).XC_LegalEntity__c != 'EnelSole' && (mapContractLegalEntity.get(contService.XC_Contract__c).XC_Segment__c == 'B2C' || String.isBlank(mapContractLegalEntity.get(contService.XC_Contract__c).XC_Segment__c))) continue;
                        newContService.addError(Label.XC_CL_ExistentContractServicesError);
                    }
                }
            }
        }
    }
}