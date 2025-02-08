/**
* @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
* @date Creation 12/11/2019
* @date 
* @description giic_TR_PriceBook_DuplicationRule – class for avoid priceBook duplicates 
*/  
public without sharing class giic_TR_PriceBook_DuplicationRule {
    
    public static void avoidDuplicates(List<gii__PriceBook__c> listNew){
        List<Id> contractId = new  List<Id> ();
        for(gii__PriceBook__c pb : listNew){
            contractId.add(pb.giic_Contract__c);
        }
        List<gii__PriceBook__c> duplicates = [SELECT Id, giic_Contract__c FROM gii__PriceBook__c WHERE giic_Contract__c IN: contractId];
        if(!duplicates.isEmpty()){
            for(gii__PriceBook__c dup : duplicates){
                for(gii__PriceBook__c p : listNew){
                    if(p.giic_Contract__c == dup.giic_Contract__c && p.giic_Contract__c!=null){
                        p.addError(Label.giic_PriceBookDuplicationError);
                    }
                }
            }
        }
        
        
    }
    
    

}