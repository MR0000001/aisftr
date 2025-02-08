/**
 * Created by LCONATO00 on 03/06/2020.
 */
@IsTest
public with sharing class WeeklyScheduleServiceTest {
    @IsTest
    public static void TriggerHandlerValidateUserTest(){
        try {
            User u = TestDataFactory.createURPUser();
            List<Employee__c> employees = TestDataFactory.listEmployee();
            List<Structure__c> structures = TestDataFactory.listStructures();
            List<Structure__c> MacroStructures = TestDataFactory.listMacroStructures();
            List<Role__c> roles = TestDataFactory.listAllRoles(structures,employees);
            List<MacrostructureAssociation__c> mas = TestDataFactory.listMacrostructureAssociations(MacroStructures,u.Id);
            system.runAs(u){
                system.debug('@@@ structures '+structures);
                List<Weekly_Schedule__c> weeklySchedules = TestDataFactory.createWeeklySchedule(structures);

                for(Weekly_Schedule__c weeklySchedule : weeklySchedules){
                    weeklySchedule.Day__c = 'Martedì';
                }
                update weeklySchedules;
                delete weeklySchedules;
            }
        } catch(Exception e) {

        }
    }
}