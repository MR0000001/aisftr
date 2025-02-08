/**
* @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com 
* @date Creation 29/04/2019
* @description XC_DF_NE_Bundle – Data Factory for NE__Bundle
*/
@isTest
public class XC_DF_NE_Bundle {
    
       /** 
     * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com 
     * @description Method to create N NE__Bundle
     * @param n - Number of accounts to be created
     * @return  List<NE__Bundle__c> to insert
    */
    public static List<NE__Bundle__c> createBundleRecords(Integer numBundles) {

        List<NE__Bundle__c> listBundle = new List<NE__Bundle__c>();
        Integer counter = numBundles;
        NE__Bundle__c b;

        while(counter > 0) {
            b = new NE__Bundle__c();
            b.Name = 'Bandoleiro';
            b.NE__Configuration_Type__c = 'Free';
            b.NE__Start_Date__c = Date.Today();
            b.NE__RecurringChargeFrequency__c = 'Annual';
            listBundle.add(b);
            counter--;
        }

        return listBundle;
    }


}