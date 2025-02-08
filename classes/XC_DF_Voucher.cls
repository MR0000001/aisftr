/**
* @author Roberta Porrega - roberta.porrega@nttdata.com 
* @date Creation 06/05/2019
* @description XC_DF_Voucher – Data Factory for Voucher
*/
@isTest
public class XC_DF_Voucher {
	
     /**
     * @author Roberta Porrega - roberta.porrega@nttdata.com && Federica Tavera - federica.tavera@nttdata.com
     * @description Method to create XC_Voucher__c
     * @param n - number of voucher
     * @return  List<XC_Voucher__c> to insert
    */
    public static List<XC_Voucher__c> generateSingleVoucher(Integer n){
        List<XC_Voucher__c> vouchList = new List<XC_Voucher__c>();
        for(Integer i=0; i<n; i++){
            XC_Voucher__c vouc = new XC_Voucher__c();
            vouc.Name = 'Test Voucher';
            vouc.XC_StartDate__c = Date.today();
            vouc.XC_Voucher_To_Be_Created__c = 4;
            vouc.XC_Status__c = 'Active';
            vouc.XC_EndDate__c = Date.newInstance(2030, 12, 31);
            vouc.XC_Amount__c = 35;
            vouc.XC_Billing_Model__c = 'Onetime';
            vouchList.add(vouc);
        } 
        return vouchList;
    }

    /**
     * @author Roberta Porrega - roberta.porrega@nttdata.com && Federica Tavera - federica.tavera@nttdata.com
     * @description Method to create XC_Voucher__c
     * @param n - number of voucher
     * @return  List<XC_Voucher__c> to insert
    */
    public static List<XC_Voucher__c> generatePromotionalVoucher(Integer n){
        List<XC_Voucher__c> vouchList = new List<XC_Voucher__c>();
        for(Integer i=0; i<n; i++){
            XC_Voucher__c vouc = new XC_Voucher__c();
            vouc.Name = 'Test Voucher';
            vouc.XC_StartDate__c = Date.today();
            vouc.XC_Voucher_To_Be_Created__c = 4;
            vouc.XC_Status__c = 'Active';
            vouc.XC_EndDate__c = Date.newInstance(2030, 12, 31);
            vouc.XC_Amount__c = 35;
            vouc.XC_Billing_Model__c = 'Onetime';
            vouc.XC_VoucherCode__c = '123456789abc';
            vouchList.add(vouc);
        } 
        return vouchList;
    }
}