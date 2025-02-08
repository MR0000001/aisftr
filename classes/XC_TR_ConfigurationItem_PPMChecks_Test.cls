/*
* @author Nicola Arrigo -
* @date Creation 26/10/2020
* @date Modification 
* @description  XC_TR_ConfigurationItem_PPMChecks_Test
*/
@isTest
public class XC_TR_ConfigurationItem_PPMChecks_Test {
   @TestSetup 
    static void setup(){
        OneOrg__c org=new OneOrg__c();
        org.XC_Spain_Triggers__c=true;
        insert org;
         NE__Order__c order=XC_DF_Order.createOrder('InOrder');
        order.XC_LegalEntity__c='EnelXItalia';
        order.XC_Country__c = 'Italy';
        order.XC_Segment__c = 'B2B';
        update order;
       // NE__OrderItem__c item=XC_DF_OrderItem.createOrderItem(order);
       // insert item;
    }
     @isTest
    static void checkProjectTemplate(){
        test.startTest();
        //Project
		    project_cloud__Project__c p = new project_cloud__Project__c(name='ProgettoTestTemplate', 
	   	                         project_cloud__Type__c='Provisioning',
	   	                         project_cloud__IsTemplate__c=true,
                                 XC_LegalEntity__c='EnelXItalia',
                                 project_cloud__Units__c='Duration',
                                 XC_Country__c ='Italy',
                                 XC_Segment__c='B2B'                                       
	   	                         );
			
	        insert p;
        NE__Order__c order=[select id from NE__Order__c order 
                            order by createddate desc limit 1];
        
        NE__OrderItem__c item=[select id,XC_Project_Template__c,NE__OrderId__c,XC_LegalEntity__c,XC_ConfigurationType__c
                              from NE__OrderItem__c 
                               where NE__OrderId__c=:order.Id
                              order by createddate desc limit 1];
      /* NE__OrderItem__c item=XC_DF_OrderItem.createOrderItem(order);
        //item.XC_Segment__c='B2B';
        insert item;*/
        item.XC_LegalEntity__c=p.XC_LegalEntity__c;
       item.XC_ConfigurationType__c='InOrder';
       item.XC_Project_Template__c=p.id;
        update item;
       // item.XC_Project_Template__c=p.id;
       // update item;
    }
   @isTest
    static void updateCommercialParent(){
       /* List<Opportunity> o = XC_DF_Opportunity.createOpportunity(1, false);
        insert o;*/
    /*    NE__Order__c order=[select id,XC_LegalEntity__c,NE__AccountId__c
                            from NE__Order__c order 
                            order by createddate desc limit 1];
                NE__OrderItem__c item=[select id,XC_Project_Template__c,NE__OrderId__c,XC_LegalEntity__c,XC_ConfigurationType__c
                              from NE__OrderItem__c 
                               where NE__OrderId__c=:order.Id 
                              order by createddate desc limit 1];
        item.XC_LegalEntity__c=order.XC_LegalEntity__c;
       item.XC_ConfigurationType__c='InOrder'; 
        update item;*/
        List<NE__OrderItem__c> itemChild=XC_DF_OrderItem.createOrderItems(2);
         NE__Order__c order=[select id,XC_LegalEntity__c,NE__AccountId__c,XC_Segment__c
                                from NE__Order__c 
                                 where id=:itemChild[0].NE__OrderId__c  
                                order by createddate desc limit 1];
        order.XC_LegalEntity__c='EnelXItalia';
        order.XC_Country__c = 'Italy';
        order.XC_Segment__c = 'B2B';
        update order;
        insert itemChild;
        itemChild[0].XC_ParentCommercialItem__c=itemChild[1].id;
        update itemChild;        
    }
}