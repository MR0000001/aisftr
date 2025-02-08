/**  
* @author FirstName : Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
* @date Creation 20/02/2020
* @date Modification dd/mm/yyyy
* @description To retrieve all transfer order to share.
*/    
global without sharing class Giic_BA009_ShareTOPartner implements Database.Batchable<sObject> , Schedulable{
    

    
    public Database.QueryLocator start(Database.BatchableContext context){
        
        String query = 'SELECT Id, CreatedDate, LastModifiedDate, gii__FromWarehouse__c,  gii__TransferToWarehouse__c FROM gii__TransferOrder__c';
        return Database.getQueryLocator(query);
    
        
    }


   global void execute(Database.BatchableContext BC, List<gii__TransferOrder__c> scope){
      
       List<Boolean> resultList = executeShare(scope);
   }
    
    
    public static List<Boolean> executeShare(List<gii__TransferOrder__c> scope){
        List<String> wh1ds = XC_UTIL_Sobject.getListFieldValues(scope, 'gii__FromWarehouse__c');
        List<String> wh2ds = XC_UTIL_Sobject.getListFieldValues(scope, 'gii__TransferToWarehouse__c');
        map<Id,gii__Warehouse__c> wareHouseMap = new  map<Id,gii__Warehouse__c>([SELECT Id, gii__Account__c FROM gii__Warehouse__c WHERE Id IN:wh1ds OR Id IN:wh2ds]);
        map<Id,List<Id>> transferOrdIdTouserOrGroupId = new  map<Id,List<Id>>();
        List<giic_UTIL_TransferOrderSharing.Giic_SharingTOWrapper> transferWrapper = new List<giic_UTIL_TransferOrderSharing.Giic_SharingTOWrapper>();
        List<String> allAccountList = new  List<String>(); 
        for(gii__TransferOrder__c t : scope){
            giic_UTIL_TransferOrderSharing.Giic_SharingTOWrapper toWr = new giic_UTIL_TransferOrderSharing.Giic_SharingTOWrapper();
            String firstAccount = wareHouseMap.get(t.gii__FromWarehouse__c).gii__Account__c;
            String secondAccount = wareHouseMap.get(t.gii__TransferToWarehouse__c).gii__Account__c;
            allAccountList.add(firstAccount);
            allAccountList.add(secondAccount);
            System.debug('allAccountList = '+allAccountList);
            toWr.transferOrderId = t.Id;
            toWr.firstAccount = firstAccount;
            toWr.secondAccount = secondAccount;
            transferWrapper.add(toWr);
         }
        
        
        map<Id,User> userMap = new  map<Id,User>([SELECT Id,ContactId,Contact.AccountId,ProfileId,Profile.Name 
                                                  FROM User 
                                                  WHERE (Profile.Name like '%_PartnerAdmin' OR Profile.Name like '%_PartnerManager') 
                                                  AND (not Profile.Name  like '%EnelX%') 
                                                  AND  Contact.AccountId IN: allAccountList  AND IsActive=true]);
  
        System.debug('@@@@ userMap = '+userMap);
        for(giic_UTIL_TransferOrderSharing.Giic_SharingTOWrapper w : transferWrapper){
        	List<Id> userToShare = new  List<Id>();
        	for(User u : userMap.values()){
            	if(u.Contact.AccountId == w.firstAccount || u.Contact.AccountId == w.secondAccount){
                    userToShare.add(u.Id);
                }
        	}
            transferOrdIdTouserOrGroupId.put(w.transferOrderId , userToShare);
            
        }
        List<gii__TransferOrder__Share> shareObjectList = [SELECT Id,ParentId,RowCause 
                                                           FROM gii__TransferOrder__Share 
                                                           WHERE ParentId IN: transferOrdIdTouserOrGroupId.keySet() 
                                                           AND  RowCause='Manual'  
                                                           AND (UserOrGroup.Profile.Name  like '%_PartnerAdmin' OR UserOrGroup.Profile.Name like '%_PartnerManager') ];

        delete shareObjectList;
        List<Boolean> resultList = giic_UTIL_TransferOrderSharing.manualShareRead(transferOrdIdTouserOrGroupId);
        

        
        return resultList;
        
    }
        


   global void finish(Database.BatchableContext BC){

   }
    
    
    
    global void execute(SchedulableContext ctx){
       
        Database.executebatch(new Giic_BA009_ShareTOPartner(),  70);
    }



}