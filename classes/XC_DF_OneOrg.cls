/**
* @author Marco Rosa - marco.rosa@nttdata.com
* @date Creation 29/04/2019
* @description XC_DF_Lead – Data Factory for Lead
*/

@isTest
public class XC_DF_OneOrg {

    /**
     * @author Marco Rosa - marco.rosa@nttdata.com
     * @description Create OneOrg Record for a given Country
     * @param country
     * @return OneOrg
    */
    
    public static OneOrg__c createOneOrg(String country){
        OneOrg__c org            = new OneOrg__c();
        org.SetupOwnerId         = UserInfo.getProfileId();
        org.Name                 = 'OneOrg (User)';
        if(country == 'Spain'){
            org.XC_Spain_Triggers__c = true;
        }
        return org;
    }

}