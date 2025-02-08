@istest
public class XC_TR_WorkOrder_UpdateDateTimeField_TEST {
    static testmethod void onInsertCase(){
   test.startTest();
        User u = XC_DF_User.createUserAdmin();
         u.Country__c = 'ITLY';
        u.CompanyP__c = 'ITALY';
        u.XC_LegalEntity__c='EnelXItalia';
        insert u; 
      system.runAs(u){
        List<Account> accList = XC_DF_Account.createCondominiumAccounts(1);
   		insert accList;
        List<XC_Address__c> addr = XC_DF_Address.createAddress(accList);
        addr[0].XC_AddressCountry__c='Italy';
        insert addr;
    	List <Contact> cont = XC_DF_Contact.createCondominiumContacts(accList);
    	cont[0].AccountId=accList.get(0).id;
    	insert cont;  
    
    List<Asset> assCom = XC_DF_Asset.createAssets(1);
        //ass[0].XC_Contract__c= cont[0].id;
        //ass[0].AssetServicedById=accList[0].id;
        assCom[0].XC_Address__c= addr[0].id;
        assCom[0].serialnumber='1823747';
        assCom[0].TAM_IsTechnical__c= true;
        assCom[0].TAM_IsLogical__c=true;
        assCom[0].AccountId= accList[0].id;
        assCom[0].XC_Segment__c='B2B';
        assCom[0].XC_LegalEntity__c='EnelXItalia';
        insert assCom;
    
        List<Asset> ass = XC_DF_Asset.createAssets(1);
        //ass[0].XC_Contract__c= cont[0].id;
        //ass[0].AssetServicedById=accList[0].id;
        ass[0].XC_Address__c= addr[0].id;
        ass[0].serialnumber='1823747';
        ass[0].TAM_IsTechnical__c= true;
        ass[0].TAM_IsLogical__c=true;
        ass[0].AccountId= accList[0].id;
        ass[0].XC_Segment__c='B2B';
        ass[0].TAM_CommercialAsset__c=assCom[0].id;
         ass[0].XC_LegalEntity__c='EnelXItalia'; 
        insert ass;
    	//CASE b2c
/*	List<Case> caseB2C = XC_DF_Case.createCases(1);
     caseB2C[0].XC_Subtype__c = 'XC199';
     caseB2C[0].reason='XCMOT002';
     caseB2C[0].SubCause__c='ATCL003';
	 caseB2C[0].AccountId=accList[0].id;
     caseB2C[0].ContactId=cont[0].id;
    insert caseB2C;  
    caseB2C[0].XC_Segment__c='B2C';
      caseB2C[0].XC_LegalEntity__c='EnelXItalia';
      caseB2C[0].XC_BusinessLine__c='eCity'; 
      caseB2C[0].XC_Asset_B2B__c=ass[0].id;
    update caseB2C;*/
    	WorkType workTypeToInsert = XC_DF_WorkType.createWorkType('Malfunctioning');
         workTypeToInsert.Name='workType';
          
         //worktypeToInsert.XC_LegalEntity='EnelXItalia';
         
    	insert workTypeToInsert;
    	List<XC_CM_Case_Repair_Configuration__mdt> caseRepairList=[select id,XC_Reason__c, XC_Sub_Cause__c, XC_Sub_Type__c,XC_B2BWONeeded__c,XC_BusinessLine__c 
                                                                   from XC_CM_Case_Repair_Configuration__mdt where XC_B2BWONeeded__c=true];
        caseRepairList[0].XC_B2BWONeeded__c=true;
    id rtIdB2C =Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('XC_ITA_Management_Case').getRecordTypeId();
        List<Case> caseToCreateWo = XC_DF_Case.createCases(1);
        caseToCreateWo[0].XC_Subtype__c = 'XC199';
        caseToCreateWo[0].reason='XCMOT002';
        caseToCreateWo[0].SubCause__c='ATCL003';
		caseToCreateWo[0].AccountId=accList[0].id;
       	caseToCreateWo[0].ContactId=cont[0].id;
        //caseToCreateWo[0].XC_IsCloned__c=true; 
       // caseToCreateWo[0].XC_TechnicalAsset__c=ass[0].id;
       // caseToCreateWo[0].XC_LegalEntity__c='EnelXItalia';
       // caseToCreateWo[0].XC_Segment__c='B2B';
         caseToCreateWO[0].RecordTypeId=rtIdB2C;
         caseToCreateWO[0].XC_LegalEntity__c='EndesaX'; 
        insert caseToCreateWo;  
        XC_WorkOrderActivityPlanItem__c woa=new XC_WorkOrderActivityPlanItem__c();
        woa.XC_WorkType__c='Malfunctioning';
        woa.XC_RecordType__c='XC_ITA_Woli_ManualDialing';
        woa.XC_Country__c='Italy';
        woa.XC_CompletionMode__c='Manual Dialing';
        woa.XC_TechnicianResponse__c='Without Defect/With Defect';
        woa.XC_WorkType__c='Malfunctioning';
        insert woa;
        id rtIdB2B =Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('XC_B2B_EnelXItalia_Management_Case').getRecordTypeId();
        caseToCreateWO[0].RecordTypeId=rtIdB2B;
        caseToCreateWo[0].XC_Segment__c='B2B';
        caseToCreateWo[0].XC_LegalEntity__c='EnelXItalia';
        caseToCreateWO[0].XC_BusinessLine__c='eCity'; 
        caseToCreateWo[0].XC_TechnicalAsset__c=ass[0].id;
        caseTocreateWO[0].XC_Force_Work_Order_creation__c=TRUE;
        caseTocreateWO[0].XC_MalfunctioningWOCreation__c = System.today();  
         update  caseToCreateWo;
       /* List<WorkOrder> woList=[select id ,status from workorder where caseId=:caseTocreateWO[0].id];
           woList[0].Status='Assigned';
         update woList;*/
        }
     }
}