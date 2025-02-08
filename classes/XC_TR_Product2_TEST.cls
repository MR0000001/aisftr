/**
* @author Antonio D'Onofrio andonofrio@deloitte.it
* @date Creation 22/04/2020 
* @description XC_TR_Product2_TEST – Test class for XC_TR_Product2
*/



@isTest
public class XC_TR_Product2_TEST {

    @isTest
    static void insertTest(){
        Test.startTest();

        Product2 ptoInsert = new Product2(Name= 'TestProd', 
                                          migrationTool__c = true);
        List<Product2> listProducts = new List<Product2>();
        listProducts.add(ptoInsert);
        insert listProducts;
        
        ptoInsert = new Product2(Id = listProducts[0].Id, 
                                          migrationTool__c = true);
        listProducts = new List<Product2>();
        Test.stopTest();
    }
        
    
    @isTest
    static void updateTest(){
        Test.startTest();

        Product2 ptoInsert = new Product2(Name= 'TestProd', 
                                          migrationTool__c = true);
        List<Product2> listProducts = new List<Product2>();
        listProducts.add(ptoInsert);
        insert listProducts;
		update listProducts;
        Test.stopTest();
    }
    
    @isTest
    static void deleteTest(){
        Test.startTest();

        Product2 ptoInsert = new Product2(Name= 'TestProd', 
                                          migrationTool__c = true);
        List<Product2> listProducts = new List<Product2>();
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
        Product2 ptoInsert = new Product2(Id = 'x,', 
                                          migrationTool__c = true);
        List<Product2> listProducts = new List<Product2>();
        listProducts.add(ptoInsert);
        insert listProducts;

        Test.stopTest();
    }
*/

}