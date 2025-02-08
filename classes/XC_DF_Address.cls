/**
* @author Roberta Porrega - roberta.porrega@nttdata.com 
* @date Creation 06/05/2019
* @description XC_DF_Address – Data Factory for Address
*/
@isTest
public class XC_DF_Address {

    /**
     * @author Roberta Porrega - roberta.porrega@nttdata.com
     * @description Method to create XC_Address__c
     * @param accountList list Account
     * @return  List<XC_Address__c> to insert
    */
    public static List<XC_Address__c> createAddress(List<Account> accountList) {
        List<XC_Address__c> aList = new List<XC_Address__c>();
        for(Integer i = 0; i < accountList.size() ; i++) {
            XC_Address__c addressToInsert = new XC_Address__c();
            addressToInsert.XC_Account__c = accountList.get(i).Id;
            addressToInsert.XC_Address__c = 'Test';
            addressToInsert.XC_City__c = 'Madrid';
            addressToInsert.XC_AddressCountry__c = 'Spain';
            addressToInsert.XC_PostalCode__c = '28080';
            addressToInsert.XC_AddressProvince__c = 'Madrid';
            addressToInsert.XC_StreetNumber__c = '11' + Math.random();
            addressToInsert.XC_StreetType__c = 'Street'; 
            addressToInsert.XC_Municipality__c   = 'Test' + Math.random();
            addressToInsert.XC_InstallationAddress__c = TRUE;
            addressToInsert.XC_DeliveryAddress__c = TRUE;
            addressToInsert.XC_BillingAddress__c = TRUE;
            addressToInsert.XC_PickUpPoint__c = TRUE;
            addressToInsert.XC_PointOfSales__c = TRUE;
            addressToInsert.XC_WareHouse__c = TRUE;
            aList.add(addressToInsert);
        }
        return aList;
    } 
    
     /**
     * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
     * @description Method to create n XC_Address__c
     * @param n number of addresse to be created
     * @return  List<XC_Address__c> to insert
    */
  	public static List<XC_Address__c> createAddress(Integer n) {
        List<Account> accountList = XC_DF_Account.createResidentialAccounts(n);
        insert accountList;
        List<XC_Address__c> aList = new List<XC_Address__c>();
        for(Integer i = 0; i < accountList.size() ; i++) {
            XC_Address__c addressToInsert = new XC_Address__c();
            addressToInsert.XC_Account__c = accountList.get(i).Id;
            addressToInsert.XC_Address__c = 'Address Name that have to pass the 80 charachter in order to cover the class to test';
            addressToInsert.XC_City__c = 'Madrid';
            addressToInsert.XC_AddressCountry__c = 'Spain';
            addressToInsert.XC_PostalCode__c = '28080';
            addressToInsert.XC_AddressProvince__c = 'Madrid';
            addressToInsert.XC_StreetNumber__c = '1' + i;
            addressToInsert.XC_StreetType__c = 'Street'; 
            addressToInsert.XC_Municipality__c   = 'Test';
            addressToInsert.XC_Stair__c = '7';
            addressToInsert.XC_Floor__c = 'B';
            aList.add(addressToInsert);
        }
        return aList;
    }
    
    /**
     * @description Method to create italian XC_Address__c
     * @param accountList
     * @return  List<XC_Address__c> to insert
    */
  	public static List<XC_Address__c> createItalianAddress(List<Account> accountList) {
        List<XC_Address__c> aList = new List<XC_Address__c>();
        for(Integer i = 0; i < accountList.size() ; i++) {
            XC_Address__c addressToInsert = new XC_Address__c();
            addressToInsert.XC_Account__c = accountList.get(i).Id;
            addressToInsert.XC_Address__c = 'Test';
            addressToInsert.XC_City__c = 'Latina';
            addressToInsert.XC_AddressCountry__c = 'Italy';
            addressToInsert.XC_PostalCode__c = '04100';
            addressToInsert.XC_AddressProvince__c = 'Madrid';
            addressToInsert.XC_StreetNumber__c = '33' + Math.random();
            addressToInsert.XC_StreetType__c = 'Street'; 
            addressToInsert.XC_Municipality__c   = 'Test' + Math.random();
            addressToInsert.XC_InstallationAddress__c = TRUE;
            addressToInsert.XC_DeliveryAddress__c = TRUE;
            addressToInsert.XC_BillingAddress__c = TRUE;
            addressToInsert.XC_PickUpPoint__c = TRUE;
            addressToInsert.XC_PointOfSales__c = TRUE;
            addressToInsert.XC_WareHouse__c = TRUE;
            aList.add(addressToInsert);
        }
        return aList;
    } 
 
}