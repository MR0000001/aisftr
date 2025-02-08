/**
* @author Patrizia Arcidiacono patrizia.arcidiacono@nttdata.com
* @date Creation  26/11/2019 
* @description XC_TR_GoodIssue_U_StartCongaWorkflow_U – XC_TR_GoodIssue_U_StartCongaW_TEST
*/ 
@isTest
public class XC_TR_GoodIssue_U_StartCongaW_TEST {
	@TestSetup
    static void setup(){ 
     	       
        APXTConga4__Conga_Template__c template = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'DDT good Issue', Country__c = 'Colombia');
        insert template;
     
        APXTConga4__Conga_Merge_Query__c congaQuery1 = new APXTConga4__Conga_Merge_Query__c(APXTConga4__Name__c = 'queryOnGoodIssue');
        insert congaQuery1;
		Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        OneOrg__c org = new OneOrg__c();
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
        Giic_UtilityClass_Test.accountCreation();
        Account accModRT = [Select Recordtype.Id, RecordType.DeveloperName from Account where Id=: Giic_UtilityClass_Test.objAccountCentral.Id];
        system.debug('@@@@ accModRt:' + accModRT.RecordType.DeveloperName);
        recordType idRT =[Select developername from Recordtype where name ='Partner' and developerName ='XC_Account_Partner'];
		accModRT.recordTypeId = idRT.id;
        update accModRT;
		       
        system.debug('@@@@ accModRt:' + idRT.developername);
        List<account> acc = [Select id From Account where id=:accModRT.Id];
      
        List<Contact> cont = XC_DF_Contact.createPartnerContacts(acc);
        system.debug('@@@@ cont:' + cont);

        insert cont;
        system.debug('@@@@ cont:' + cont);

    
        Giic_UtilityClass_Test.wareHouseGroupCreation();
       
        Giic_UtilityClass_Test.warehouseCreation();
                     
        Giic_UtilityClass_Test.productCreation();
  		gii__Product2Add__c objProdRef= [Select id,gii__ProductCode__c from gii__Product2Add__c where gii__ProductReference__c IN: Giic_UtilityClass_Test.lstProd Limit 1];
        objProdRef.gii__SerialControlled__c=true;
        objProdRef.giic_ProcurementType__c = 'Transfer';
        objProdRef.gii__PrimarySupplier__c = Giic_UtilityClass_Test.objAccountSupplier.Id;
        
        update objProdRef;
        
        system.debug('@@@@ insert obj ProductReference'); 
        Giic_UtilityClass_Test.SalesOrderCreation();
        Giic_UtilityClass_Test.salesOrderLineCreation(objProdRef);
        Giic_UtilityClass_Test.shipmentCreation();
      
    }
	
    
  	static testMethod void test1(){  
          Test.startTest();
          gii__Shipment__c gI = [Select id from gii__Shipment__c limit 1];   
          string esito = XC_TR_GoodIssue_U_StartCongaWorkflow.populateFieldDDT(gI.Id);
          system.assert(esito!='KO', esito);
          Test.stopTest();
    }    
}