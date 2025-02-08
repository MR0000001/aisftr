/**
* @author Riccardo Cossu - riccardo.cossu@nttdata.com
* @date Creation  16/05/2019
* @description Test Class for Controller LCP XC_LCP018_AccountGetScored
*/ 

@isTest
private class XC_LCC018_AccountGetScored_TEST {
    static testMethod void generateScoredTest(){
        insert XC_DF_OneOrg.createOneOrg('Spain');        
        Test.startTest();
        List<Account> acc = XC_DF_Account.createResidentialAccounts(1);
        insert acc;
        
        Double rnd =  Math.random()*10;
        Integer a = (Integer)rnd;
        
        String scored = 'Renting a 3 años (36 meses) - 50€';
        String scoredName;
        Integer scoredNumber = a;
        
        acc[0].XC_Score__c = scored;
        acc[0].XC_Score_Name__c = scoredName;
        acc[0].XC_Score_Number__c = scoredNumber;
        
        update acc;
        
        String accId = acc[0].Id;
        Boolean getScored = XC_LCC018_AccountGetScored.generateScored(accId);
        System.assert(getScored);
        Test.stopTest();
    }
    static testMethod void generateScoredTest1(){
        insert XC_DF_OneOrg.createOneOrg('Spain');        
        Test.startTest();
        List<Account> acc = XC_DF_Account.createResidentialAccounts(1);
        insert acc;
        
        Double rnd =  Math.random()*10;
        Integer a = (Integer)rnd;
        
        String scored = 'Renting a 3 años (36 meses) - 50€';
        String scoredName;
        Integer scoredNumber = a;
        
        acc[0].XC_Score__c = scored;
        acc[0].XC_Score_Name__c = scoredName;
        acc[0].XC_Score_Number__c = scoredNumber;
        
        update acc;
        
        String accId = acc[0].Id;
        Boolean getScored = XC_LCC018_AccountGetScored.generateScored(accId);
        System.assert(getScored);
        Test.stopTest();
    }
    static testMethod void generateScoredTest2(){
        insert XC_DF_OneOrg.createOneOrg('Spain');        
        Test.startTest();
        List<Account> acc = XC_DF_Account.createResidentialAccounts(1);
        insert acc;
        
        Double rnd =  Math.random()*10;
        Integer a = (Integer)rnd;
        
        String scored;
        String scoredName;
        Integer scoredNumber = a;
        
        acc[0].XC_Score__c = scored;
        acc[0].XC_Score_Name__c = scoredName;
        acc[0].XC_Score_Number__c = scoredNumber;
        
        update acc;
        
        String accId = acc[0].Id;
        Boolean getScored = XC_LCC018_AccountGetScored.generateScored(accId);
        System.assert(getScored);
        Test.stopTest();
    }
    static testMethod void generateScoredTest3(){
        insert XC_DF_OneOrg.createOneOrg('Spain');        
        Test.startTest();
        List<Account> acc = XC_DF_Account.createResidentialAccounts(1);
        insert acc;
        
        Double rnd =  Math.random()*10;
        Integer a = (Integer)rnd;
        
        String scored = 'Renting a 7 años (84 meses) - 50€';
        String scoredName;
        Integer scoredNumber = a;
        
        acc[0].XC_Score__c = scored;
        acc[0].XC_Score_Name__c = scoredName;
        acc[0].XC_Score_Number__c = scoredNumber;
        
        update acc;
        
        String accId = acc[0].Id;
        Boolean getScored = XC_LCC018_AccountGetScored.generateScored(accId);
        System.assert(getScored);
        Test.stopTest();
    }
}