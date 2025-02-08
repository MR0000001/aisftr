/**
* @author Antonio D'Onofrio andonofrio@deloitte.it
* @date Creation 22/04/2020 
* @description XC_TR_zqu__ProductRatePlan__c_TEST – Test class for XC_TR_zqu__ProductRatePlan__c
*/



@isTest
public class XC_TR_zqu_ProductRatePlan_c_TEST {

    @isTest
    static void insertTest(){
        Test.startTest();

        Product2 p = new Product2(Name = 'Test',
                                  legacyId__c = 'xxx',
                                 isActive = true);
        insert p;

        zqu__ZProduct__c zp = new zqu__ZProduct__c(Name = 'Test');
        insert zp;
            
        zqu__ProductRatePlan__c prptoInsert = new zqu__ProductRatePlan__c(Name= 'TestProd', 
                                                                        migrationTool__c = true,
                                                                        zqu__ZProduct__c =zp.id,
                                                                       	legacyProductId__c = 'xxx');
        List<zqu__ProductRatePlan__c> listProductRatePlans = new List<zqu__ProductRatePlan__c>();
        listProductRatePlans.add(prptoInsert);
        
        insert listProductRatePlans;
 
        Test.stopTest();
    }
        
    
    @isTest
    static void updateTest(){
        Test.startTest();

                zqu__ZProduct__c zp = new zqu__ZProduct__c(Name = 'Test');
        insert zp;
            
        zqu__ProductRatePlan__c ptoInsert = new zqu__ProductRatePlan__c(Name= 'TestProd', 
                                                                        migrationTool__c = true,
                                                                        zqu__ZProduct__c =zp.id);
        List<zqu__ProductRatePlan__c> listProducts = new List<zqu__ProductRatePlan__c>();
        listProducts.add(ptoInsert);
        insert listProducts;
		update listProducts;
        Test.stopTest();
    }
    
    @isTest
    static void deleteTest(){
        Test.startTest();

               zqu__ZProduct__c zp = new zqu__ZProduct__c(Name = 'Test');
        insert zp;
            
        zqu__ProductRatePlan__c ptoInsert = new zqu__ProductRatePlan__c(Name= 'TestProd', 
                                                                        migrationTool__c = true,
                                                                        zqu__ZProduct__c =zp.id);
        List<zqu__ProductRatePlan__c> listProducts = new List<zqu__ProductRatePlan__c>();
        listProducts.add(ptoInsert);
        insert listProducts;
		delete listProducts;
        Test.stopTest();
    }
    
   /* @isTest
    static void testOthers(){
        Test.startTest();
       // OneOrg__c org            = new OneOrg__c(); 
       // org.Name                 = 'OneOrg (User)';
        //org.XC_Spain_Triggers__c = true;
        //insert org; 
        zqu__ProductRatePlan__c ptoInsert = new zqu__ProductRatePlan__c(Id = 'x,', 
                                          migrationTool__c = true);
        List<zqu__ProductRatePlan__c> listProducts = new List<zqu__ProductRatePlan__c>();
        listProducts.add(ptoInsert);
        insert listProducts;

        Test.stopTest();
    }
*/

}