/**
* @author Federico Amici - federico.amici@nttdata.com, Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
* @date Creation 29/05/2019
* @date Modification dd/mm/yyyy
* @description Data factory for the NE__Matrix_Parameter__c object
*/
@isTest
public class XC_DF_Bundle {
   
    /**
    * @author Federico Amici - federico.amici@nttdata.com, Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
    * @date Creation 29/05/2019
    * @date Modification dd/mm/yyyy
    * @description Creates matrix paramter
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