/**
* @author De Blasio Valentina valentina.de.blasio@accenture.com
* @date Creation 22/02/2022
* @description XC_TR_Sla_Managment – Class for insert default entitlement-entitlemn process and milestone
*/  

public without sharing class XC_TR_Sla_Managment{ 

     public static void defaultSlaManagment(Map<Id, Account> mapNew) { 
        List<Entitlement> etList=new List<Entitlement>();
        String nameprocess;
        List <SlaProcess> spList=[Select id,Name from SlaProcess where Name like'%SLAPROCESS_DEFAULT%' and isActive=true ];
        Id rtAccId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_GLO_B2G').getRecordTypeId();
        for(Account acc : mapNew.values()) {
            for (SlaProcess sla:spList){
                if(acc.RecordTypeId==rtAccId && acc.Country__c=='Italy'){ //vdb fix 760
                    nameprocess=sla.Name.substring(0,2);              
                    Entitlement et=new Entitlement ();
                    et.AccountId=acc.Id;
                    if(sla.Name.contains(nameprocess)){
                        et.Name=nameprocess.substring(0,2);
                        et.SlaProcessId=sla.id;
                        et.StartDate=date.today();
                        et.XC_EntitlmentCheck__c=true; //vdb fix 760
                        etList.add(et);
                    }
                   }
                  
            }
       }
        if(etList.size() > 0){ 
          insert etList; 
        }
     }

}