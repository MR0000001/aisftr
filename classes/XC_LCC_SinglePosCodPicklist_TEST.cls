/**
* @author sooraji.sajan@accenture.com - raffaele.sojka@accenture.com 
* @date Creation 11/03/2022
* @description Test class of the class XC_LCC_SinglePosCodPicklistController
*/

@isTest
public class XC_LCC_SinglePosCodPicklist_TEST {
    
    static testMethod void test1(){
            
		NE__Order__c ord = XC_DF_Order.createOrder('test');
        List<NE__OrderItem__c> itemList = [SELECT id from NE__OrderItem__c Limit 1];
        ord.XC_Segment__c ='';
        update ord;
        String test='';
        WorkOrderLineItem woli = new WorkOrderLineItem();
        woli.Status='New';
        WorkOrder wo = new WorkOrder();
        wo.XC_Configuration__c= ord.Id;
        wo.XC_Configuration_Item__c = itemList[0].Id;
        insert wo;
        woli.WorkOrderId = wo.Id;
        insert woli;
        
       List<String> wolitest = XC_LCC_SinglePosCodPicklistController.getSinglePositionCodeValues(woli.id);
            
             for(String wolich : wolitest){
               System.assertNotEquals(test, wolich);
                 if(!test.equals(wolich)){
                     test = wolich;
                 }
             }
      
    }  
        

}