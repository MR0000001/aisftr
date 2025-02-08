/**
 * Created by LCONATO00 on 03/06/2020.
 */

public with sharing class MacrostructureAssociationDAO {
    public static List<MacrostructureAssociation__c> getMAbyUserIdAndStructureId(String userId){
        List<MacrostructureAssociation__c> macrostructureAssociations = new List<MacrostructureAssociation__c>();
        macrostructureAssociations = [SELECT Id, Structure__c FROM MacrostructureAssociation__c WHERE User__c =: userId];
        return macrostructureAssociations;
    }
}