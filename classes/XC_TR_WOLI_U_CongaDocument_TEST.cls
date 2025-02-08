@istest
public class XC_TR_WOLI_U_CongaDocument_TEST {
  //[CR729 start sooraji.sajan@accenture.com 09.05.2022]
    @testSetup
        static void setup() {
            test.startTest();
            List<WorkOrder> wo = new List<WorkOrder>(); 
       WorkType wt=XC_DF_WorkType.createWorkType('Delivery'); 
        wt.RecordTypeId = Schema.SObjectType.WorkType.getRecordTypeInfosByDeveloperName().get('CHL').getRecordTypeId();
        wt.XC_LegalEntity__c='Codensa';    
        insert wt;
        
        WorkOrder ord=new WorkOrder();      
      	ord.RecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('XC_B2B_EnelXItalia_WorkOrder').getRecordTypeId();
       ord.XC_Segment__c='B2B';
       ord.XC_LegalEntity__c='EnelSole';
       ord.XC_WorkTypeCategory__c='';
       ord.XC_WorkTypeLabel__c='';
       ord.Description='Test Prova';
       ord.BusinessLine__c='eCity';
       ord.WorkTypeId=wt.id;
       insert ord;
       wo.add(ord);
       test.stopTest();
    }   
//[CR729 End sooraji.sajan@accenture.com 09.05.2022]    
    
  static testmethod void checkDocumentType(){
       insert XC_DF_OneOrg.createOneOrg('Spain');
    test.startTest();
      //[CR729 start sooraji.sajan@accenture.com 09.05.2022]
      //List<WorkOrder> wo = XC_DF_WorkOrder.createWorkOrdersForLead (1);
        //insert wo; 
        List<WorkOrder> listwo =[Select id,BusinessLine__c from WorkOrder where BusinessLine__c='eCity' limit 1];
      //[CR729 End sooraji.sajan@accenture.com 09.05.2022]
        WorkOrderLineItem woli = new WorkOrderLineItem(); 
      //[CR729 start sooraji.sajan@accenture.com 09.05.2022]
        //woli.WorkOrderId= wo[0].Id; 
        woli.WorkOrderId= listwo[0].Id;
      //[CR729 End sooraji.sajan@accenture.com 09.05.2022]
    	insert woli;
    	woli.XC_LCLDocument__c='ModArt26';
    	woli.XC_LCLDocumentRequired__c = true;
  		woli.Status = 'In Progress' ;
        woli.XC_OrderOfActivity__c=1;
        update woli;
      //[CR729 start sooraji.sajan@accenture.com 09.05.2022]
        //System.assert(wo!=null);
        System.assert(listwo[0]!=null);
      //[CR729 End sooraji.sajan@accenture.com 09.05.2022]
    system.debug('mio work order line'+ woli);
    test.stopTest();
}
static testmethod void checkDocumentType1(){
       insert XC_DF_OneOrg.createOneOrg('Spain');
    test.startTest();
    //[CR729 start sooraji.sajan@accenture.com 09.05.2022]
      //List<WorkOrder> wo = XC_DF_WorkOrder.createWorkOrdersForLead (1);
        //insert wo; 
        List<WorkOrder> listwo =[Select id,BusinessLine__c from WorkOrder where BusinessLine__c='eCity' limit 1];
      //[CR729 End sooraji.sajan@accenture.com 09.05.2022]
        WorkOrderLineItem woli = new WorkOrderLineItem();
      //[CR729 start sooraji.sajan@accenture.com 09.05.2022]
        //woli.WorkOrderId= wo[0].Id; 
        woli.WorkOrderId= listwo[0].Id;
    //[CR729 End sooraji.sajan@accenture.com 09.05.2022]
    	insert woli;
    	woli.XC_LCLDocument__c='LCL';
    	woli.XC_LCLDocumentRequired__c = true;
  		woli.Status = 'In Progress' ;
        woli.XC_OrderOfActivity__c=1;
        update woli;
       //[CR729 start sooraji.sajan@accenture.com 09.05.2022]
       //System.assert(wo!=null);
        System.assert(listwo[0]!=null);
      //[CR729 End sooraji.sajan@accenture.com 09.05.2022]
    system.debug('mio work order line'+ woli);
    test.stopTest();
}
static testmethod void checkDocumentType2(){
    insert XC_DF_OneOrg.createOneOrg('Spain');
 test.startTest();
    //[CR729 start sooraji.sajan@accenture.com 09.05.2022]
   //List<WorkOrder> wo = XC_DF_WorkOrder.createWorkOrdersForLead (1);
     //insert wo; 
     List<WorkOrder> listwo =[Select id,BusinessLine__c from WorkOrder where BusinessLine__c='eCity' limit 1];
    //[CR729 End sooraji.sajan@accenture.com 09.05.2022]
        WorkOrderLineItem woli = new WorkOrderLineItem();  
    //[CR729 start sooraji.sajan@accenture.com 09.05.2022]
        //woli.WorkOrderId= wo[0].Id; 
        woli.WorkOrderId= listwo[0].Id;
    //[CR729 End sooraji.sajan@accenture.com 09.05.2022]
     Id WOLI_RECORDTYPE = Schema.SObjectType.WorkOrderLineItem.getRecordTypeInfosByDevelopername().get('XC_B2G_EnelXItalia_PE_WOLI').getRecordTypeId();
     woli.RecordTypeId = WOLI_RECORDTYPE;
     insert woli;
     woli.XC_LCLDocument__c='Chiusura Lavori';
     woli.XC_LCLDocumentRequired__c = true;
       woli.Status = 'In Progress' ;
     woli.XC_OrderOfActivity__c=1;
     update woli;
    //[CR729 start sooraji.sajan@accenture.com 09.05.2022]
    //System.assert(wo!=null);
     System.assert(listwo[0]!=null);
    //[CR729 End sooraji.sajan@accenture.com 09.05.2022]
 system.debug('mio work order line'+ woli);
 test.stopTest();
}
    //[CR729 start sooraji.sajan@accenture.com 09.05.2022]
    static testmethod void checkRequestType1(){
       insert XC_DF_OneOrg.createOneOrg('Spain');
    test.startTest();
      //List<WorkOrder> wo = XC_DF_WorkOrder.createWorkOrdersForLead (1);
        //insert wo; 
        List<WorkOrder> listwo =[Select id,BusinessLine__c from WorkOrder where BusinessLine__c='eCity' limit 1];
        WorkOrderLineItem woli = new WorkOrderLineItem();   		  	
        //woli.WorkOrderId= wo[0].Id; 
        woli.WorkOrderId= listwo[0].Id;
        insert woli;
    	woli.XC_RequestType__c ='Sospensione';
    	//woli.XC_LCLDocumentRequired__c = true;
  		woli.Status = 'In Progress' ;
        woli.XC_OrderOfActivity__c=1;
        update woli;
        System.assert(listwo[0]!=null);
    system.debug('mio work order line'+ woli);
    test.stopTest();
}
    static testmethod void checkRequestType2(){
       insert XC_DF_OneOrg.createOneOrg('Spain');
    test.startTest();
      //List<WorkOrder> wo = XC_DF_WorkOrder.createWorkOrdersForLead (1);
        //insert wo; 
       List<WorkOrder> listwo =[Select id,BusinessLine__c from WorkOrder where BusinessLine__c='eCity' limit 1];
        WorkOrderLineItem woli = new WorkOrderLineItem();   		  	
        //woli.WorkOrderId= wo[0].Id; 
        woli.WorkOrderId= listwo[0].Id;
    	insert woli;
    	woli.XC_RequestType__c ='Proroga';
    	//woli.XC_LCLDocumentRequired__c = true;
  		woli.Status = 'In Progress' ;
        woli.XC_OrderOfActivity__c=1;
        update woli;
        System.assert(listwo[0]!=null);
    system.debug('mio work order line'+ woli);
    test.stopTest();
    }
    static testmethod void checkRequestType3(){
       insert XC_DF_OneOrg.createOneOrg('Spain');
    test.startTest();
      //List<WorkOrder> wo = XC_DF_WorkOrder.createWorkOrdersForLead (1);
        //insert wo; 
        List<WorkOrder> listwo =[Select id,BusinessLine__c from WorkOrder where BusinessLine__c='eCity' limit 1];
        WorkOrderLineItem woli = new WorkOrderLineItem();   		  	
        //woli.WorkOrderId= wo[0].Id; 
        woli.WorkOrderId= listwo[0].Id;
    	insert woli;
    	woli.XC_RequestType__c ='Ripresa';
    	//woli.XC_LCLDocumentRequired__c = true;
  		woli.Status = 'In Progress' ;
        woli.XC_OrderOfActivity__c=1;
        update woli;
        System.assert(listwo[0]!=null);
    system.debug('mio work order line'+ woli);
    test.stopTest();
    }
   //[CR729 End sooraji.sajan@accenture.com 09.05.2022]
}