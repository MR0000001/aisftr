/**
     * @author Donato Lombardi - dolombardi@deloitte.it
     * @description Method to retrieve a Map of Work Order -> List skills requested
     * @param listNew - List WorkOrder
     * @return void
    **/
public with sharing class XC_TR_PPM_Project_DisconnectAsset {
    public static void closedAsset(Map<Id,project_cloud__Project__c> mapNew, Map<Id,project_cloud__Project__c> mapOld){
        List<project_cloud__Project__c> listProjectChange = XC_UTIL_Sobject.getListChanged(new List<String>{'XC_Status__c'}, mapOld, mapNew);
        List<project_cloud__Project__c> listProjectClose = new List<project_cloud__Project__c>();
        listProjectClose = getAllProjectClose(mapNew,mapOld);
        if(listProjectClose.isEmpty()){
            return ;
            }

        Map<ID,NE__Order__c> mapIdOred = new Map<Id,NE__Order__c>();
        mapIdOred = retrieveOrderContractAsset(listProjectClose);
        System.debug('MapIdOrder'+mapIdOred);
        if(mapIdOred.isEmpty()){
            return ;
        }
        updateAssetAndContract(mapIdOred);

    }


    private static List<project_cloud__Project__c> getAllProjectClose(Map<Id,project_cloud__Project__c> mapNew, Map<Id,project_cloud__Project__c> mapOld){
        List<project_cloud__Project__c> listProjectChange = XC_UTIL_Sobject.getListChanged(new List<String>{'XC_Status__c'}, mapOld, mapNew);
        System.debug('listpProjectChane'+listProjectChange);
        List<project_cloud__Project__c> listProjectClose = new List<project_cloud__Project__c>();
        for(project_cloud__Project__c p : listProjectChange){
            if(p.XC_Status__c== 'Closed'){
                listProjectClose.add(p);
            }
        }
        System.debug('listpProjectClose'+listProjectClose);
        return listProjectClose;
    }

      private static Map<Id,NE__Order__c> retrieveOrderContractAsset(List<project_cloud__Project__c> listProjectClose){
        Set<Id> setOrderId = XC_UTIL_Sobject.getSetIdsOnField(listProjectClose,'XC_Configuration__c');
        System.debug('orderId'+setOrderId);
        Map<Id,NE__Order__c> mapIdOrder = new Map<Id,NE__Order__c>([select id,NE__Type__c , (select id, XC_Configuration__c from Projects__r), (select id, Status from Assets__r), (select id, Status from Contract__r) 
                                                                    from NE__Order__c where Id IN :setOrderId
                                                                   ]);
        return mapIdOrder;
    }

       private static void updateAssetAndContract(Map<Id,NE__Order__c> mapIdOrder){
        List<Asset>listAssetToUpdate = new List<Asset>();
        List<Contract> listContractToUpdate = new List<Contract>();
        for(NE__Order__c ne : mapIdOrder.values()) {
            if(ne.NE__Type__c == 'Disconnection')
            {
            for(Contract c : ne.Contract__r){
                c.Status='Cancelled';
                listContractToUpdate.add(c);
            }

            for(Asset a : ne.Assets__r){
                a.Status='Inactive';
                listAssetToUpdate.add(a);

            }
		}

        }
        //XC_UTIL_Sobject.updateListRecords(listContractToUpdate);
        //XC_UTIL_Sobject.updateListRecords(listAssetToUpdate);
        update(listContractToUpdate);
        update(listAssetToUpdate);


    }



}