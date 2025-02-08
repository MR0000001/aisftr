/**
* @author Antonio D'Onofrio andonofrio@deloitte.it
* @date Creation 22/04/2020 
* @description XC_TR_zqu__ProductRatePlanCharge__c_TEST – Test class for XC_TR_zqu__ProductRatePlanCharge__c
*/



@isTest
public class XC_TR_zqu_ProductRatePlanCharge_TEST {

    @isTest
    static void insertTest(){
        Test.startTest();
                zqu__ZProduct__c zp = new zqu__ZProduct__c(Name = 'Test');
        insert zp;

        zqu__ProductRatePlan__c prp = new zqu__ProductRatePlan__c(Name = 'Test',
                                  legacyId__c = 'xxx',
                                  zqu__ZProduct__c = zp.Id);
        insert prp;

            
        zqu__ProductRatePlanCharge__c prpctoInsert = new zqu__ProductRatePlanCharge__c(Name= 'TestProd', 
                                                                        migrationTool__c = true,
                                                                       	legacyProductRatePlanId__c = 'xxx');
        List<zqu__ProductRatePlanCharge__c> listProductRatePlanCharges = new List<zqu__ProductRatePlanCharge__c>();
        listProductRatePlanCharges.add(prpctoInsert);
        
        insert listProductRatePlanCharges;
 
        Test.stopTest();
    }
        
    
    @isTest
    static void updateTest(){
        Test.startTest();

        zqu__ZProduct__c zp = new zqu__ZProduct__c(Name = 'Test');
        insert zp;

        zqu__ProductRatePlan__c prp = new zqu__ProductRatePlan__c(Name = 'Test',
                                  legacyId__c = 'xxx',
                                  zqu__ZProduct__c = zp.Id);
        insert prp;

            
        zqu__ProductRatePlanCharge__c prpctoInsert = new zqu__ProductRatePlanCharge__c(Name= 'TestProd', 
                                                                        migrationTool__c = true,
                                                                       	legacyProductRatePlanId__c = 'xxx');
        List<zqu__ProductRatePlanCharge__c> listProductRatePlanCharges = new List<zqu__ProductRatePlanCharge__c>();
        listProductRatePlanCharges.add(prpctoInsert);
        
        insert listProductRatePlanCharges;
        update listProductRatePlanCharges;
 
        Test.stopTest();
    }
    
    @isTest
    static void deleteTest(){
        Test.startTest();

        zqu__ZProduct__c zp = new zqu__ZProduct__c(Name = 'Test');
        insert zp;

        zqu__ProductRatePlan__c prp = new zqu__ProductRatePlan__c(Name = 'Test',
                                  legacyId__c = 'xxx',
                                  zqu__ZProduct__c = zp.Id);
        insert prp;

            
        zqu__ProductRatePlanCharge__c prpctoInsert = new zqu__ProductRatePlanCharge__c(Name= 'TestProd', 
                                                                        migrationTool__c = true,
                                                                       	legacyProductRatePlanId__c = 'xxx');
        List<zqu__ProductRatePlanCharge__c> listProductRatePlanCharges = new List<zqu__ProductRatePlanCharge__c>();
        listProductRatePlanCharges.add(prpctoInsert);
        
        insert listProductRatePlanCharges;
        delete listProductRatePlanCharges;
 
        Test.stopTest();
    }
    


}