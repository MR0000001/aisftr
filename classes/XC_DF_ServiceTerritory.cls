/**
* @author Roberta Cossiga - rcossiga@deloitte.it 
* @date Creation 06/05/2019
* @description XC_DF_ServiceTerritory – Data Factory for Service Territory
*/

@isTest
public class XC_DF_ServiceTerritory {

    /** 
     * Roberta Cossiga - rcossiga@deloitte.it
     * @description Method to create Service Territory
     * @param accList
     * @return  List<ServiceTerritory>
     */
    public static List<ServiceTerritory> createServiceTerritories(List<Account> accList){
        List<ServiceTerritory> servTerrList = new List<ServiceTerritory>();
        insert XC_DF_OperatingHours.createOperatingHours('Gold Appointment Calendar');
        OperatingHours opHours = [SELECT Id, Name FROM OperatingHours WHERE Name = 'Gold Appointment Calendar' LIMIT 1];
        for(Account a : accList){
            ServiceTerritory rootToInsert = new ServiceTerritory(); 
            rootToInsert.Name = a.Name;
            rootToInsert.XC_AccountId__c = a.Id;
            rootToInsert.OperatingHoursId = opHours.Id;
            rootToInsert.isActive = true;
            servTerrList.add(rootToInsert);
        }
        return servTerrList;
    }
}