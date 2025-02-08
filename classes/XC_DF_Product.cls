/**
* @author Federico Amici - federico.amici@nttdata.com
* @description Data factory for the NE__Product__c object
*/
@isTest
public class XC_DF_Product {
    
    /**
    * @author Federico Amici - federico.amici@nttdata.com
    * @param nProduct number of NE__Product__c instances to create
    * @description creates an NE__Product__c instance
    * @return the 
    */
    public static List<NE__Product__c> createProducts(Integer nProduct) {
       
        List<String> nameProduct = new List<String>();
        for (integer i=0; i < nProduct; i++){
           String nameProd = 'Prod Name '+ i;
           nameProduct.add(nameProd);
        }
        
        System.debug('###products names' + nameProduct);
        List<NE__Product__c> productList = new List<NE__Product__c>();

        for (String name : nameProduct) {

            NE__Product__c prodToInsert = new NE__Product__c();

            prodToInsert.Name = name;
            prodToInsert.NE__Block_Change__c = false;
            prodToInsert.NE__Check_Stock__c = false;
            prodToInsert.NE__Export_Images__c = false;
            prodToInsert.NE__Finishing_on__c = Date.newInstance(2040, 10, 14);
            prodToInsert.NE__IsPromo__c = false;
            prodToInsert.NE__Starting_on__c = Date.newInstance(2018, 07, 30);
            prodToInsert.NE__Stock__c = 300;
            prodToInsert.NE__Engine_Code__c = 'code';
            prodToInsert.NE__Recurring_Cost_Frequency__c = 'Semiannual';

            productList.add(prodToInsert);
        }
        System.debug('### products names' + productList);
        return productList;
    }
}