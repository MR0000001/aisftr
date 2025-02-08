/**
 * Created by LCONATO00 on 01/06/2020.
 */

public with sharing class WeeklyScheduleService {
    public static void TriggerHandlerValidateUser(List<Weekly_Schedule__c> weeklyScheduleList,Boolean beforeUpdate,Boolean beforeDelete,Boolean beforeInsert) {
        String currentUserId = UserInfo.getUserId();
        User currentUser = UserSelector.getUserbyId(currentUserId);
        List<String> structuresId = new List<String>();
        List<Weekly_Schedule__c> weeklyScheduleListTemp = new List<Weekly_Schedule__c>();
        Map<Id, String> structureIdMacrostructureMap = new Map<Id, String>();
        String errorLabel;
        Boolean userHasEmployee = false;
        List<Employee__c> userEmployees = new List<Employee__c>();
        if (currentUser.Profile.Name.containsIgnoreCase('system admin') || currentUser.Profile.Name.containsIgnoreCase('superuser')) {
            return;
        }
        if (beforeUpdate) {
            errorLabel = Label.NoWeekHoursEditAllowed;
        } else {
            if (beforeDelete) {
                errorLabel = Label.NoWeekHoursDeletionAllowed;
            } else {
                if (beforeInsert) {
                    errorLabel = Label.NoWeekHoursInsertionAllowed;
                }
            }
        }
        for (Weekly_Schedule__c weeklySchedule : weeklyScheduleList) {
            structuresId.add(weeklySchedule.Structure_Reference__c);
            weeklyScheduleListTemp.add(weeklySchedule);
        }
        List<Structure__c> structures = StructuresDAO.getStructuresByIds(structuresId);
        for (Structure__c structure : structures) {
            Id macrostructureId = structure.TechMacrostructureId__c;
            structureIdMacrostructureMap.put(structure.Id, macrostructureId);
        }
        if(currentUser.SerialNumber__c!=null){
            userEmployees = EmployeesDAO.getEmployeesBySerialNumber(currentUser.SerialNumber__c);
            userHasEmployee = !userEmployees.isEmpty();
        }

        if(currentUser.SerialNumber__c!=null && userHasEmployee){
            List<Role__c> rolesAssociated = RoleDAO.getRolesByEmployeeSerialNumberAndStructureId(currentUser.SerialNumber__c);
            List<MacrostructureAssociation__c> macrostructureAssociations = MacrostructureAssociationDAO.getMAbyUserIdAndStructureId(currentUserId);
            Boolean hasRoleAssociated = rolesAssociated != null && !rolesAssociated.isEmpty();
            Boolean hasMacrostructureAssociation = macrostructureAssociations != null && !macrostructureAssociations.isEmpty();
            List<String> roleStructureIds = new List<String>();
            List<String> MacroStructureIds = new List<String>();
            Set<String> roleMacroStructureIds = new Set<String>();
            if (hasRoleAssociated || hasMacrostructureAssociation) {
                Integer weeklyScheduleListSize = weeklyScheduleListTemp.size();
                if (hasRoleAssociated) {
                    for (Role__c role : rolesAssociated) {
                        roleStructureIds.add(role.StructureId__c);
                        Id macrostructId = role.StructureId__r.TechMacrostructureId__c;
                        roleMacroStructureIds.add(macrostructId);
                    }
                    for (Integer j = weeklyScheduleListSize - 1; j >= 0; j--) {
                        if (roleStructureIds.contains(weeklyScheduleListTemp[j].Structure_Reference__c) || roleMacroStructureIds.contains(structureIdMacrostructureMap.get(weeklyScheduleListTemp[j].Structure_Reference__c))
                                ) {
                            weeklyScheduleListTemp.remove(j);

                        }
                    }
                    weeklyScheduleListSize = weeklyScheduleListTemp.size();

                }
                if (hasMacrostructureAssociation && weeklyScheduleListSize >= 0) {
                    for (MacrostructureAssociation__c msa : macrostructureAssociations) {
                        MacroStructureIds.add(msa.Structure__c);
                    }
                    for (Integer j = weeklyScheduleListSize - 1; j >= 0; j--) {
                        if (MacroStructureIds.contains(structureIdMacrostructureMap.get(weeklyScheduleListTemp[j].Structure_Reference__c))) {
                            weeklyScheduleListTemp.remove(j);
                        }
                    }
                }
                if (!weeklyScheduleListTemp.isEmpty()) {
                    for (Weekly_Schedule__c weeklyScheduleTemp : weeklyScheduleListTemp) {
                        for (Weekly_Schedule__c weeklySchedule : weeklyScheduleList) {
                            if (weeklySchedule == weeklyScheduleTemp) {
                                weeklySchedule.addError(errorLabel);
                            }
                        }

                    }
                }

            } else {
                for (Weekly_Schedule__c weeklySchedule : weeklyScheduleList) {
                    weeklySchedule.addError(errorLabel);
                }
            }
        }else{
            if(currentUser.SerialNumber__c == null) {
                errorLabel = Label.NoUserSerialNumber;
            }else{
                errorLabel = Label.NoEmployeeWithSerialNumber+' '+currentUser.SerialNumber__c;
            }
            for (Weekly_Schedule__c weeklySchedule : weeklyScheduleList) {
                weeklySchedule.addError(errorLabel);
            }
        }
    }

}