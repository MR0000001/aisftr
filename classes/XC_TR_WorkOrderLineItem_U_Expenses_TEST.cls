@isTest 
public class XC_TR_WorkOrderLineItem_U_Expenses_TEST {
    static testmethod void expensesCreation(){
        test.startTest();
        User u = XC_DF_User.createUserAdmin();
        insert u;
        project_cloud__Project__c project = new project_cloud__Project__c();
        project.project_cloud__IsTemplate__c =true;
        project.project_cloud__Type__c='provisioning';
        project.XC_LegalEntity__c ='EnelX';
        project.XC_Country__c ='Chile';
        project.XC_Status__c = 'Assigned';
        insert project; 
        
        project_cloud__Project_Phase__c ph = new project_cloud__Project_Phase__c();
        ph.project_cloud__Project__c=project.id;
        insert ph;
        
        project_cloud__Project_Task__c proj = new project_cloud__Project_Task__c();
        proj.project_cloud__Project_Phase__c= ph.id;
        proj.project_cloud__Estimated_Hours__c = 1;
        proj.project_cloud__Units__c='Duration';
        insert proj;
        
        project_cloud__Project_Task__c proj2 = new project_cloud__Project_Task__c();
        proj2.project_cloud__Project_Phase__c= ph.id;
        proj2.project_cloud__Estimated_Hours__c = 1;
        proj2.project_cloud__Units__c='Duration';
        insert proj2;
        
        List<WorkOrder> wo = XC_DF_WorkOrder.createWorkOrders(2,'Commercial Visit');      
        wo.get(0).XC_Project_Task__c=proj.Id;
        wo.get(1).XC_Project_Task__c=proj2.id;
        wo.get(0).XC_LegalEntity__c ='EnelXItalia';
        wo.get(1).XC_LegalEntity__c ='EnelXItalia';
		wo.get(0).XC_Segment__c ='B2B';
        wo.get(1).XC_Segment__c ='B2B';
        id rid=Schema.SObjectType.WorkOrder.getRecordTypeInfosByName().get('XC_B2B_EnelXItalia_WorkOrder').getRecordTypeId ();
        wo.get(0).RecordTypeId=rid;
        wo.get(1).RecordTypeId=rid;
        insert wo;
   
        WorkOrderLineItem woli = new WorkOrderLineItem();
        woli.WorkOrderId= wo.get(0).id;
        woli.XC_Project_Task__c = proj.id;
        woli.XC_WOLIType__c ='Material Supply';
        woli.Status='New';
        insert woli;
        
        
        WorkOrderLineItem olditem =  woli.clone(true,false,false,false);
       
        
        Product2 realProduct = new Product2();
        realProduct.Name = 'Real Product Name';                                        
        realProduct.IsActive = true;                                       
        realProduct.zqu__ZuoraId__c = '8adc8f996a3446ab016a4fc80e1f1e1f';
        insert realProduct;
        
        ProductRequired pr = new ProductRequired();
        pr.XC_ProductRequiredId__c = pr.Id;
        pr.ParentRecordId = woli.id;
    	pr.Product2Id=realProduct.Id;
        pr.XC_WorkOrderId__c =wo[0].id;
        pr.XC_WorkOrderLineItem__c = woli.id;
        pr.XC_OrderQuantity__c=1;
        pr.XC_PriceUnits__c=1;
        pr.XC_WorkOrderId__c= wo.get(0).Id;
        Schema.SObjectType.ProductRequired.getRecordTypeInfosByName().get('XC_B2G_EnelXItalia_MaterialRequest').getRecordTypeId ();
        //sistem.debug('id'+ woli.id);
        //pr.XC_WorkOrderId__c= wo.get(1).Id;
        //insert pr; 
        List<ProductRequired> prlist= new List<ProductRequired>();
        prlist.add(pr);
        insert prlist;
        project_cloud__Expense2__c pce = new project_cloud__Expense2__c();
        pce.project_cloud__Project__c=project.id;
       	pce.project_cloud__Amount__c =pr.XC_OrderQuantity__c * pr.XC_PriceUnits__c;
        pce.project_cloud__Date__c=Date.today();
        pce.project_cloud__Type__c = 'Budgeted';       
        insert pce;
        
        
        Map<Id, project_cloud__Expense2__c> mapEx = new Map<Id, project_cloud__Expense2__c>();
        mapEx.put(pce.id,pce);
         Map<Id, WorkOrderLineItem> mapOld = new Map<Id, WorkOrderLineItem>();
        mapOld.put(olditem.id,olditem);  
         woli.Status='Completed';
        update woli;
        Map<Id, WorkOrderLineItem> mapNew = new Map<Id, WorkOrderLineItem>();        
        mapNew.put(woli.id,woli);
        system.runAs(u){
        XC_TR_WorkOrderLineItem_U_Expenses.expensesCreation(mapNew,mapOld);
        }
        test.stopTest();
       
      
    }
    static testmethod void expensesCreation2(){
        test.startTest();
        User u = XC_DF_User.createUserAdmin();
        project_cloud__Project__c project = new project_cloud__Project__c();
        project.project_cloud__IsTemplate__c =true;
        project.project_cloud__Type__c='provisioning';
        project.XC_LegalEntity__c ='EnelX';
        project.XC_Country__c ='Chile';
        project.XC_Status__c = 'Assigned';
        insert project; 
        
        project_cloud__Project_Phase__c ph = new project_cloud__Project_Phase__c();
        ph.project_cloud__Project__c=project.id;
        insert ph;
        
        project_cloud__Project_Task__c proj = new project_cloud__Project_Task__c();
        proj.project_cloud__Project_Phase__c= ph.id;
        proj.project_cloud__Estimated_Hours__c = 1;
        proj.project_cloud__Units__c='Duration';
        insert proj;
        
        project_cloud__Project_Task__c proj2 = new project_cloud__Project_Task__c();
        proj2.project_cloud__Project_Phase__c= ph.id;
        proj2.project_cloud__Estimated_Hours__c = 1;
        proj2.project_cloud__Units__c='Duration';
        insert proj2;
        
        List<WorkOrder> wo = XC_DF_WorkOrder.createWorkOrders(2,'Commercial Visit');      
        wo.get(0).XC_Project_Task__c=proj.Id;
        wo.get(1).XC_Project_Task__c=proj2.id;
        wo.get(0).XC_LegalEntity__c ='EnelXItalia';
        wo.get(1).XC_LegalEntity__c ='EnelXItalia';
		wo.get(0).XC_Segment__c ='B2B';
        wo.get(1).XC_Segment__c ='B2B';
        id rid=Schema.SObjectType.WorkOrder.getRecordTypeInfosByName().get('XC_B2B_EnelXItalia_WorkOrder').getRecordTypeId ();
        wo.get(0).RecordTypeId=rid;
        wo.get(1).RecordTypeId=rid;
        insert wo;

        WorkOrderLineItem woli = new WorkOrderLineItem();
        woli.WorkOrderId= wo.get(0).id;
        woli.XC_Project_Task__c = proj.id;
        woli.XC_WOLIType__c ='Partner Payment';
        woli.Status='New';
        insert woli;       
        WorkOrderLineItem olditem =  woli.clone(true,false,false,false);
        Map<Id, WorkOrderLineItem> mapOld = new Map<Id, WorkOrderLineItem>();
        mapOld.put(olditem.id,olditem);      
        woli.Status='Released';
        update woli;
        Map<Id, WorkOrderLineItem> mapNew = new Map<Id, WorkOrderLineItem>();        
        mapNew.put(woli.id,woli);
          
        Product2 realProduct = new Product2();
        realProduct.Name = 'Real Product Name';                                        
        realProduct.IsActive = true;                                       
        realProduct.zqu__ZuoraId__c = '8adc8f996a3446ab016a4fc80e1f1e1f';
        insert realProduct;
        
        ProductRequired pr = new ProductRequired();
        pr.XC_ProductRequiredId__c = pr.Id;
        pr.ParentRecordId = woli.id;
    	pr.Product2Id=realProduct.Id;
        pr.XC_WorkOrderLineItem__c = woli.id;
        pr.XC_OrderQuantity__c=1;
        pr.XC_PriceUnits__c=1;
        pr.XC_WorkOrderId__c= wo.get(0).Id;
        Schema.SObjectType.ProductRequired.getRecordTypeInfosByName().get('XC_B2G_EnelXItalia_MaterialRequest').getRecordTypeId ();
        //sistem.debug('id'+ woli.id);
        //pr.XC_WorkOrderId__c= wo.get(1).Id;
        //insert pr; 
        List<ProductRequired> prlist= new List<ProductRequired>();
        prlist.add(pr);
        insert prlist;
        id recordid=Schema.SObjectType.ProductRequired.getRecordTypeInfosByName().get('XC_B2G_EnelXItalia_MaterialRequest').getRecordTypeId ();
        XC_ProductConsumed__c pc = new XC_ProductConsumed__c();
        pc.XC_WorkOrderLineItem__c = woli.id;
        pc.XC_QuantityConsumed__c=0;
        pc.XC_UnitPrice__c=0;
        pc.XC_WorkOrder__c= wo.get(0).Id;
        //pc.RecordTypeId= recordid;
		insert pc;
        project_cloud__Expense2__c pce = new project_cloud__Expense2__c();
        pce.project_cloud__Project__c=project.id;
       	pce.project_cloud__Amount__c =pr.XC_OrderQuantity__c * pr.XC_PriceUnits__c;
        pce.project_cloud__Date__c=Date.today();
        pce.project_cloud__Type__c = 'Budgeted';       
        insert pce;      
        Map<Id, project_cloud__Expense2__c> mapEx = new Map<Id, project_cloud__Expense2__c>();
        mapEx.put(pce.id,pce);
        insert u;
		system.runAs(u){
        XC_TR_WorkOrderLineItem_U_Expenses.expensesCreation(mapNew,mapOld);
        }
        test.stopTest();
       
      
    }
        static testmethod void expensesCreation3(){
        test.startTest();
        User u = XC_DF_User.createUserAdmin();
        project_cloud__Project__c project = new project_cloud__Project__c();
        project.project_cloud__IsTemplate__c =true;
        project.project_cloud__Type__c='provisioning';
        project.XC_LegalEntity__c ='EnelX';
        project.XC_Country__c ='Chile';
        project.XC_Status__c = 'Assigned';
        project.XC_Segment__c='B2B';
        insert project; 
        
        project_cloud__Project_Phase__c ph = new project_cloud__Project_Phase__c();
        ph.project_cloud__Project__c=project.id;
        insert ph;
        
        project_cloud__Project_Task__c proj = new project_cloud__Project_Task__c();
        proj.project_cloud__Project_Phase__c= ph.id;
        proj.project_cloud__Estimated_Hours__c = 1;
        proj.project_cloud__Units__c='Duration';
        insert proj;
        
        project_cloud__Project_Task__c proj2 = new project_cloud__Project_Task__c();
        proj2.project_cloud__Project_Phase__c= ph.id;
        proj2.project_cloud__Estimated_Hours__c = 1;
        proj2.project_cloud__Units__c='Duration';
        insert proj2;
        
          List<WorkOrder> wo = XC_DF_WorkOrder.createWorkOrders(2,'Commercial Visit');      
        wo.get(0).XC_Project_Task__c=proj.Id;
        wo.get(1).XC_Project_Task__c=proj2.id;
        wo.get(0).XC_LegalEntity__c ='EnelXItalia';
        wo.get(1).XC_LegalEntity__c ='EnelXItalia';
		wo.get(0).XC_Segment__c ='B2B';
        wo.get(1).XC_Segment__c ='B2B';
        id rid=Schema.SObjectType.WorkOrder.getRecordTypeInfosByName().get('XC_B2B_EnelXItalia_WorkOrder').getRecordTypeId ();
        wo.get(0).RecordTypeId=rid;
        wo.get(1).RecordTypeId=rid;
        insert wo;
   
        WorkOrderLineItem woli = new WorkOrderLineItem();
        woli.WorkOrderId= wo.get(0).id;
        woli.XC_Project_Task__c = proj.id;
        woli.XC_WOLIType__c ='Partner Engagement';
        woli.Status='New';
        insert woli;
            system.debug('woli 233  ' + woli);
        
        
        WorkOrderLineItem olditem =  woli.clone(true,false,false,false);
            Map<Id, WorkOrderLineItem> mapOld = new Map<Id, WorkOrderLineItem>();
        mapOld.put(olditem.id,olditem);  
        woli.Status='Completed';
        update woli;
        Map<Id, WorkOrderLineItem> mapNew = new Map<Id, WorkOrderLineItem>();        
        mapNew.put(woli.id,woli);
        
        system.debug('mappa nuova  ' + mapNew);
        system.debug('mappa vecchia '+ mapOld);
        
        Product2 realProduct = new Product2();
        realProduct.Name = 'Real Product Name';                                        
        realProduct.IsActive = true;                                       
        realProduct.zqu__ZuoraId__c = '8adc8f996a3446ab016a4fc80e1f1e1f';
        insert realProduct;
        
        ProductRequired pr = new ProductRequired();
        pr.XC_ProductRequiredId__c = pr.Id;
        pr.ParentRecordId = woli.id;
    	pr.Product2Id=realProduct.Id;
        pr.XC_WorkOrderLineItem__c = woli.id;
        pr.XC_OrderQuantity__c=1;
        pr.XC_PriceUnits__c=1;
        pr.XC_WorkOrderId__c= wo.get(0).Id;
        Schema.SObjectType.ProductRequired.getRecordTypeInfosByName().get('XC_B2G_EnelXItalia_MaterialRequest').getRecordTypeId ();
        //sistem.debug('id'+ woli.id);
        //pr.XC_WorkOrderId__c= wo.get(1).Id;
        //insert pr; 
        List<ProductRequired> prlist= new List<ProductRequired>();
        prlist.add(pr);
        insert prlist;
        
        project_cloud__Expense2__c pce = new project_cloud__Expense2__c();
        pce.project_cloud__Project__c=project.id;
       	pce.project_cloud__Amount__c =pr.XC_OrderQuantity__c * pr.XC_PriceUnits__c;
        pce.project_cloud__Date__c=Date.today();
        pce.project_cloud__Type__c = 'Budgeted';       
        insert pce;
        
        System.debug('project id'+ project.id);
        System.debug('wo.get(0).Id'+ wo.get(0).Id);
        System.debug('XC_WorkOrderLineItem__c id'+ woli.id);
        System.debug('proj.id id'+ proj.id);
        System.debug('ph.id id'+ ph.id);
        XC_RequiredPosition__c requi = new XC_RequiredPosition__c();
        requi.XC_WorkOrderLineItem__c = woli.id;
        requi.XC_Quantity__c=0;
        requi.XC_UnitPrice__c=0;
        LIst<XC_RequiredPosition__c> requili = new List<XC_RequiredPosition__c>();
        requili.add(requi);
        insert requili;
        Map<Id, project_cloud__Expense2__c> mapEx = new Map<Id, project_cloud__Expense2__c>();
        mapEx.put(pce.id,pce);  
        insert u;
        system.runAs(u){
        XC_TR_WorkOrderLineItem_U_Expenses.expensesCreation(mapNew,mapOld);
        }
        test.stopTest();
       
      
    }
}