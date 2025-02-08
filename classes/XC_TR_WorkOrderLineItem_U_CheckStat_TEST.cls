/**
* @author sooraji.sajan@accenture.com - raffaele.sojka@accenture.com 
* @date Creation 11/03/2022
* @description Test class of the class XC_TR_WorkOrderLineItem_U_CheckStatus
*/
@isTest
public class XC_TR_WorkOrderLineItem_U_CheckStat_TEST {
    
    
     static testMethod void test(){
       
        NE__Order__c ord = XC_DF_Order.createOrder('test');
        List<NE__OrderItem__c> itemList = [SELECT id from NE__OrderItem__c Limit 1];
        ord.XC_Segment__c ='';
        update ord;
        //String test='';
        WorkOrderLineItem woli = new WorkOrderLineItem();
        woli.Status='New';
        WorkOrder wo = new WorkOrder();
        wo.XC_Configuration__c= ord.Id;
        wo.XC_Configuration_Item__c = itemList[0].Id;
        insert wo;
        woli.WorkOrderId = wo.Id;
        insert woli;
        woli.Status='Refused';
        System.debug('woli'+ woli);
        //update woli;
        
        List<WorkOrderLineItem> wolilist = new List<WorkOrderLineItem>();
         wolilist.add(woli);
          Database.update(wolilist, false);
       
        User u = XC_DF_User.createUserAdmin();
         
        Map<id,WorkOrderLineItem> mapNew= new Map <id,WorkOrderLineItem>();
   		mapNew.put(wolilist[0].id,wolilist[0]);
       
        
        Map<id,WorkOrderLineItem> mapOld= new Map <id,WorkOrderLineItem>();
   		mapOld.put(wolilist[0].id,wolilist[0]); 
        
        insert u;
        
        Test.startTest();
        System.runAs(u)
        
        {
           XC_TR_WorkOrderLineItem_U_CheckStatus.checkWoliStatusAndSentNotif(wolilist,mapOld,mapNew);
           List<String> fieldList = new List<String>{'Status'};
           List<WorkOrderLineItem> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
           
            if(!listChanged.isEmpty() && wolilist[0].status.equalsIgnoreCase('Refused')){
              System.assertEquals(1, listChanged.size());
                
            }
            
        }
        Test.stopTest(); 
        
    }
}