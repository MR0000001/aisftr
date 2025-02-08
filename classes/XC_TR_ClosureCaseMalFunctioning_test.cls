@istest
public class XC_TR_ClosureCaseMalFunctioning_test {
    @testSetup static void methodName(){
       User u = XC_DF_User.createUserAdmin();
        u.XC_LegalEntity__c='EnelXItalia';
       insert u;   	   
        List<Account> accList = XC_DF_Account.createResidentialAccounts (1);
        insert accList;
     List<XC_Address__c> addr = XC_DF_Address.createAddress(accList);
        insert addr;
        List <Contact> cont = XC_DF_Contact.createResidentialContacts(accList);
        cont[0].AccountId=accList.get(0).id;
        cont[0].XC_Segment__c='B2B';
        insert cont;
        List<Asset> ass=XC_DF_Asset.createAssets(1);
        ass[0].AccountId = accList[0].Id;
        ass[0].TAM_IsLogical__c=true;
        ass[0].XC_Segment__c='B2B';
        ass[0].XC_Product_Subtype__c='Charging Station';
        ass[0].XC_LegalEntity__c='EnelXItalia';
        ass[0].XC_Address__c= addr[0].id;
        insert ass;
    	 id rtIdB2B2 =Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('XC_B2B_EnelXItalia_Management_Case').getRecordTypeId();
           List<Case> caseToCreateWo = XC_DF_Case.createCases(1);
        caseToCreateWo[0].XC_Subtype__c = 'XC199';
        caseToCreateWo[0].reason='XCMOT002';
        caseToCreateWo[0].SubCause__c='ATCL003';
        caseToCreateWo[0].AccountId=accList[0].id;
        caseToCreateWo[0].ContactId=cont[0].id;
        caseToCreateWo[0].XC_Segment__c='B2B';
       // caseTocreateWO[0].Status='ESTA003';
    	
    	//caseToCreateWo[0].XC_Asset_B2B__c=ass[0].id;
        //insert caseToCreateWo;
        insert  caseToCreateWo;
    	system.debug('RecordType' + [Select RecordType.DeveloperName from Case where Id =: caseToCreateWo[0].Id].RecordType.DeveloperName);
    	 system.debug('Segment '+caseToCreateWo[0].XC_Segment__c);
        caseToCreateWo[0].XC_Subtype__c = 'XC199';
        caseToCreateWo[0].reason='XCMOT002';
        caseToCreateWo[0].SubCause__c='ATCL003';
        caseToCreateWo[0].AccountId=accList[0].id;
        caseToCreateWo[0].ContactId=cont[0].id;
        caseToCreateWo[0].XC_Segment__c='B2B';
        caseTocreateWO[0].Status='ESTA003';
        caseToCreateWo[0].XC_Segment__c='B2B';
        caseToCreateWO[0].XC_NeedInternalCheck__c=false;
        caseToCreateWo[0].XC_LegalEntity__c='EnelXItalia';
        caseToCreateWO[0].XC_BusinessLine__c='eMobility'; 
        caseToCreateWo[0].XC_TechnicalAsset__c=ass[0].id;
        caseToCreateWo[0].XC_automaticClosure__c=false;
        caseTocreateWO[0].XC_Force_Work_Order_creation__c=TRUE;
        caseTocreateWO[0].Country__c='Italy';
        caseTocreateWO[0].RecordTypeId=rtIdB2B2;
        update caseTocreateWO;
        //caseChild.add(child);
       //  XC_TR_CheckParentMalfunctioning.onInsert(caseChild);
         WorkType workTypeToInsert = XC_DF_WorkType.createWorkType('Malfunctioning');
        insert workTypeToInsert;
    }
static testMethod  void manageForAutoschedule (){
    	User u = [Select id FROM user where XC_legalEntity__c ='EnelXItalia' and UserName ='pablo123@gmail.com'];
      test.startTest();
    System.runAs(u) {
         List<Account> accList=[select id from Account];
        List<Contact> cont=[select id from Contact];
        List<Asset> ass=[select id from Asset];    	
      
    	
    	//caseToCreateWo[0].XC_Asset_B2B__c=ass[0].id;
        //insert caseToCreateWo;
       List<case> caseTocreateWO=[select id from case order by createddate desc];
        WorkType workTypeToInsert=[select id from worktype order by createddate desc limit 1];
       /* Map<id,WorkOrder>mapOld=new Map<id,WorkOrder>();
    	List<WorkOrder> workOrderList = new List<WorkOrder>();*/
        XC_Address__c address = [SELECT Id, XC_Address__c FROM XC_Address__c LIMIT 1];
         id rtIdB2B2 =Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('XC_B2B_EnelXItalia_Management_Case').getRecordTypeId();
        List<case> caseChild=XC_DF_Case.createCases(1);
       /*  Case child=caseChild[0];
       // child.XC_TechnicalAsset__c= ass[0].id;
		child.XC_BusinessLine__c='eCity'; 
        child.XC_Segment__c='B2B';
       // child.ParentId=caseTocreateWO[0].id;
        child.XC_LegalEntity__c='EnelXItalia';
        child.AccountId=accList[0].id;    
        child.ContactId=cont[0].id;
        child.XC_Address__c=address.id;
        insert caseChild;
        child.XC_Segment__C='B2B';
        child.reason='XCMOT002';
        child.XC_Subtype__c = 'XC199';
        child.SubCause__c='ATCL003';
        child.RecordTypeId=rtIdB2B2;
        child.XC_TechnicalAsset__c=ass[0].id;
        child.XC_BusinessLine__c='eMobility';
        //child.XC_Force_Work_Order_creation__c=TRUE;
        child.Country__c='Italy';
        child.xc_isCloned__c=true;
        child.ParentId=caseTocreateWO[0].id;
        update caseChild;*/
       // XC_TR_CheckParentMalfunctioning.onInsert(caseChild);
      /*  WorkOrder workOrderToInsert = new WorkOrder();
    	workOrderToInsert.Status='New';
        workOrderToInsert.XC_WorkTypeCategory__c = 'Malfunctioning';
        workOrderToInsert.WorkTypeId = workTypeToInsert.Id;
        workOrderToInsert.XC_LegalEntity__c = 'EnelXItalia';
        workOrderToInsert.RecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('XC_B2B_EnelXItalia_WorkOrder').getRecordTypeId();
        workOrderToInsert.XC_Address__c = address.Id;
        workOrderToInsert.Street = address.XC_Address__c;
        workOrderToInsert.XC_Digitized__c = true;
        workOrderToInsert.XC_ToBeManuallyDigitalized__c = true;
    	workOrderToInsert.CaseId=caseToCreateWo[0].id;
        workOrderToInsert.AssetId=ass[0].id;
        workOrderToInsert.XC_DueDate__c=datetime.now(); 
        workOrderList.add(workOrderToInsert);
		insert workOrderList;
    	workOrderList[0].Status='Assigned';
    	Update workOrderList;
        workOrderList[0].Status='In Progress';
        update workOrderList;
        mapOld.put(workOrderList[0].id,workOrderList[0]);
        workOrderList[0].Status='Completed';
        update workOrderList;
        XC_TR_ClosureCaseMalFunctioning.caseClosureMalfunctioning(workOrderList,mapOld);
        test.stopTest();*/
        Map<id,WorkOrder> mapOld=new  Map<id,WorkOrder>();
        List<Workorder> workOrderList=[select id,XC_WorkTypeCategory__c,CaseId,Status,XC_Segment__c from workorder where caseId=:caseToCreateWo[0].id];
     workOrderList[0].Status='Assigned';
    	Update workOrderList;
        workOrderList[0].Status='In Progress';
        update workOrderList;
        mapOld.PUT(workOrderList[0].ID,workOrderList[0]);      
       workOrderList[0].Status='Completed';
        update WorkOrderList;  
   // system.assertEquals(2, WorkOrderListNew.size());
           test.stopTest();
     XC_TR_ClosureCaseMalFunctioning.caseClosureMalfunctioning(workOrderList, mapOld);
    }
       
  }

}