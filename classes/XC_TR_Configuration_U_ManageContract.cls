/**
 *
 * @author :              Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation :       16/01/2019
 * @date Modification :   dd/mm/yyyy
 * @description :         XC_TR_Configuration_U_ManageContract – class to manage update operation on contract 
 * 
 */


public without sharing class XC_TR_Configuration_U_ManageContract {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_Configuration_U_ManageContract');

    /** 
    * @description manage update contract.
    * @param listNew the list new
    * @param mapOld the map old
    * @param mapNew the map new
    */
    public static void manageUpdateContract(List<NE__Order__c> listNew, Map<Id,NE__Order__c> mapOld, Map<Id,NE__Order__c> mapNew) {

        XC_UTIL_Debug.debug(DEBUGACTIVE, 'In XC_TR_Configuration_U_ManageContract.manageUpdateContract');

        List<String> fieldList = new List<String>{'NE__OrderStatus__c', 'XC_Status__c'};
        List<NE__Order__c> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
        Set<Id> orderIds = new Set<Id>();
        for(NE__Order__c order : listChanged) {
            if(order.XC_Status__c == Label.XC_CL_Configuration_OrderInProvisioning && order.NE__OrderStatus__c == Label.XC_CL_Order_StatusSent 
                && (order.NE__Type__c == Label.XC_CL_Configuration_TypeChangeOrder || order.NE__Type__c == Label.XC_CL_Configuration_TypeDisconnection)) {
                    orderIds.add(order.id);
            }
        }
        
        if(!orderIds.isEmpty()){
            updateContractFields(orderIds);
        }
    }

    
    /** 
    * @description method to manage contract on update
    * @param Set<Id> - orderIds 
    */
    public static void updateContractFields(Set<Id> orderIds){

        Map<Id, NE__Order__c> orderMap = new Map<Id, NE__Order__c>([SELECT toLabel(XC_Subtype__c), (SELECT XC_Contract__c, XC_Contract__r.XC_VersionNumber__c, XC_Contract__r.XC_ChangeComments__c FROM NE__Assets__r), 
                                                                    (SELECT Id, NE__Parent_Order_Item__c, NE__Bundle_Configuration__c, NE__ProdName__c, NE__Action__c, NE__OrderId__c FROM NE__Order_Items__r WHERE NE__Action__c = 'Add' OR NE__Action__c = 'Remove') 
                                                                    FROM NE__Order__c WHERE Id IN: orderIds]);                                                                                                                                                                                                     
    
        Map<Id, String> removedProd = new Map<Id, String>(); 
        Map<Id, String> addedProd = new Map<Id, String>();
        Map<Contract, NE__Order__c> contractToOrder = new Map<Contract, NE__Order__c>();

        Map<String,Object> utilMap = new Map<String,Object> {'removedProd' => removedProd,
                                                              'addedProd' => addedProd
                                                            };


        for(NE__Order__c ord : orderMap.values()){
            Boolean parentOrderRemovedFound = false;
            Boolean parentOrderAddedFound = false;
            contractToOrder = retrieveContract( ord.NE__Assets__r, ord);
            utilMap.put('parentOrderRemovedFound', parentOrderRemovedFound);
            utilMap.put('parentOrderAddedFound', parentOrderAddedFound);
           
            for(NE__OrderItem__c ordItem : ord.NE__Order_Items__r){
                utilMap.put('ordItem', ordItem);
                if(ordItem.NE__Action__c == 'Remove' && !(Boolean) utilMap.get('parentOrderRemovedFound')){
                    manageRemovedProduct(utilMap);
                }else if(ordItem.NE__Action__c == 'Add' && ordItem.NE__ProdName__c != 'Penalty' && !(Boolean) utilMap.get('parentOrderAddedFound')){
                    manageAddedProduct(utilMap);
                }
            }
        }

        updateFields(contractToOrder, (Map<Id, String>) utilMap.get('removedProd'), (Map<Id, String>) utilMap.get('addedProd'));
    }


    /** 
    * @description method to retrieve removed product
    * @param utilMap - the map with orderId as key and removedProduct as value
    */
    public static void manageRemovedProduct(Map<String,Object> utilMap){

        Map<Id, String> removedProd =  (Map<Id, String>) utilMap.get('removedProd'); 
        NE__OrderItem__c ordItem = (NE__OrderItem__c) utilMap.get('ordItem');
        Boolean  parentOrderRemovedFound = (Boolean) utilMap.get('parentOrderRemovedFound');

        if(String.isBlank(ordItem.NE__Parent_Order_Item__c) && String.isBlank(ordItem.NE__Bundle_Configuration__c)){
            removedProd = new Map<Id, String>();
            removedProd.put(ordItem.NE__OrderId__c, ordItem.NE__ProdName__c);
            parentOrderRemovedFound = true;
            utilMap.put('removedProd', removedProd);
            utilMap.put('parentOrderRemovedFound', parentOrderRemovedFound);
        }else{
            if(!removedProd.containsKey(ordItem.NE__OrderId__c)){
                removedProd.put(ordItem.NE__OrderId__c, ordItem.NE__ProdName__c);
            }else{
                String temp = removedProd.get(ordItem.NE__OrderId__c) + ', ' + ordItem.NE__ProdName__c; 
                removedProd.put(ordItem.NE__OrderId__c, temp);
            }
        }
    }


    /** 
    * @description method to retrieve added product
    * @param utilMap - the map with orderId as key and addedProduct as value
    */
    public static void manageAddedProduct(Map<String,Object> utilMap){

        Map<Id, String> addedProd =  (Map<Id, String>) utilMap.get('addedProd'); 
        NE__OrderItem__c ordItem = (NE__OrderItem__c) utilMap.get('ordItem');
        Boolean  parentOrderAddedFound = (Boolean) utilMap.get('parentOrderAddedFound');

        if(String.isBlank(ordItem.NE__Parent_Order_Item__c) && String.isBlank(ordItem.NE__Bundle_Configuration__c)){
            addedProd = new Map<Id, String>();
            addedProd.put(ordItem.NE__OrderId__c, ordItem.NE__ProdName__c);
            parentOrderAddedFound = true;
            utilMap.put('addedProd', addedProd);
            utilMap.put('parentOrderAddedFound', parentOrderAddedFound);
        }else{
            if(!addedProd.containsKey(ordItem.NE__OrderId__c)){
                addedProd.put(ordItem.NE__OrderId__c, ordItem.NE__ProdName__c);
            }else{
                String temp = addedProd.get(ordItem.NE__OrderId__c) + ', ' + ordItem.NE__ProdName__c; 
                addedProd.put(ordItem.NE__OrderId__c, temp);
            }
        }
    }


    /** 
    * @description method to retrieve relationship between contract and order
    * @param List<Asset> - assetList
    * @param NE__Order__c - ord
    * @return Map<Contract, NE__Order__c> the map with contract as key and order as value
    */
    public static Map<Contract, NE__Order__c> retrieveContract(List<Asset> assetList, NE__Order__c ord){
        Map<Contract, NE__Order__c> contractToOrder = new Map<Contract, NE__Order__c> ();
        for(Asset ass : assetList){
            if(!String.isBlank(ass.XC_Contract__c)){
                Contract contr = new Contract (Id = ass.XC_Contract__c, XC_VersionNumber__c = ass.XC_Contract__r.XC_VersionNumber__c, XC_ChangeComments__c = ass.XC_Contract__r.XC_ChangeComments__c);
                contractToOrder.put(contr, ord);
            }
        }
        return contractToOrder;
    }


    /** 
    * @description method to update contract fields
    * @param contractToOrder - Map<Contract, NE__Order__c>  the map with contract as key and order as value
    * @param removedProd - Map<Id,String> the map with orderId as key and removed asset name as value
    * @param addedProd - Map<Id,String> the map with orderId as key and added asset name as value
    */
    public static void updateFields(Map<Contract, NE__Order__c> contractToOrder, Map<Id,String> removedProd, Map<Id, String> addedProd){

        List<Contract> contrToUpdate = new List<Contract>();
        for(Contract contr : contractToOrder.keySet()){
            Contract contrUp = new Contract();
            contrUp.Id = contr.Id; 
            contrUp.XC_VersionNumber__c = (contr.XC_VersionNumber__c != null) ? contr.XC_VersionNumber__c + 1 : 2;
            String newComments=populateChangeComments(contractToOrder.get(contr),removedProd,addedProd);
            contrUp.XC_ChangeComments__c = String.isBlank(contr.XC_ChangeComments__c) ? newComments : contr.XC_ChangeComments__c + '\n' + newComments;
            contrToUpdate.add(contrUp);
        }
        XC_UTIL_Sobject.updateListRecords(contrToUpdate);
    }


    /** 
    * @description method to populate ChangeCommentsField
    * @param order - Order 
    * @param removedProd - Map<Id,String> the map with orderId as key and removed asset name as value
    * @param addedProd - Map<Id,String> the map with orderId as key and added asset name as value
    * @param newcomments the commetns
    */

    private static String populateChangeComments(NE__Order__c order, Map<Id,String> removedProd, Map<Id, String> addedProd) {
 
        String newcomments = Label.XC_CL_ContractChangeComments;
        Datetime datetoday = System.now();
        newcomments = newcomments.replace('<date>', datetoday.format('dd/MM/yyyy'));
        newcomments = newcomments.replace('<1>', order.XC_Subtype__c);
        String tempComments = newcomments.substringBefore('.') + '.';

        /*if(removedProd.isEmpty() || addedProd.isEmpty()){
            newcomments = newcomments.substringBefore('.') + '.';
        }else{
            newcomments = newcomments.replace('<2>', removedProd.get(order.Id)).replace('<3>', addedProd.get(order.Id)); 
        }*/

        if(!removedProd.isEmpty() && addedProd.isEmpty()){
            newcomments = (newcomments.substringBefore(',') + '.').replace('<2>', removedProd.get(order.Id));
        } else if(!removedProd.isEmpty() && !addedProd.isEmpty()){
            newcomments = newcomments.replace('<2>', removedProd.get(order.Id)).replace('<3>', addedProd.get(order.Id)); 
        } else if(removedProd.isEmpty() && !addedProd.isEmpty()){
            newcomments = tempComments + ' ' + newcomments.replace('<3>', addedProd.get(order.Id)).substringAfter(', ').capitalize();
        }else if(removedProd.isEmpty() && addedProd.isEmpty()){
            newcomments = newcomments.substringBefore('.') + '.';
        }

        return newcomments;
    }

}