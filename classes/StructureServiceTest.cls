/**
 * Created by LCONATO00 on 03/06/2020.
 */

@IsTest
public with sharing class StructureServiceTest {
    @IsTest
    public static void TriggerHandlerValidateUserTest(){
        try {
            User u = TestDataFactory.createURPUser();
            List<Employee__c> employees = TestDataFactory.listEmployee();
            List<Structure__c> structures = TestDataFactory.listMacroStructures();
            List<Role__c> roles = TestDataFactory.listAllRoles(structures,employees);
            List<MacrostructureAssociation__c> mas = TestDataFactory.listMacrostructureAssociations(structures,u.Id);
            system.runAs(u){
                for(Structure__c structure : structures){
                    structure.StructureType__c = 'A';
                    structure.Name_Org_Type__c = 'D';
                    structure.ExtendedName__c = 'testtesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttes' +
                            'ttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttestt' +
                            'esttesttesttesttesttesttesttesttesttesttesttesttesttesttesttest';
                }
                update structures;
            }
        } catch(Exception e) {

        }
    }
}