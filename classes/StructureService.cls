/**
 * Created by LCONATO00 on 01/06/2020.
 */

public with sharing class StructureService {
    public static void TriggerHandlerValidateUser(List<Structure__c> listStructures){
        String currentUserId = UserInfo.getUserId();
        User currentUser = UserSelector.getUserbyId(currentUserId);
        List<String> structuresId = new List<String>();
        Map<Id, Structure__c> idStructureMap = new Map<Id, Structure__c>();
        Map<Id, String> structureIdMacrostructureMap = new Map<Id, String>();
        String errorLabel = Label.NoStructureEditAllowed;
        Boolean userHasEmployee = false;
        List<Employee__c> userEmployees = new List<Employee__c>();
        if(currentUser.Profile.Name.containsIgnoreCase('system admin')||currentUser.Profile.Name.containsIgnoreCase('jenkins')||currentUser.Profile.Name.containsIgnoreCase('superuser')||currentUser.Profile.Name.containsIgnoreCase('wso2')){
            return;
        }
        for(Structure__c structure : listStructures){
            structuresId.add(structure.Id);
            idStructureMap.put(structure.Id, structure);
            Id macrostructureId = structure.TechMacrostructureId__c;
            structureIdMacrostructureMap.put(structure.Id,macrostructureId);
        }
        if(currentUser.SerialNumber__c!=null){
            userEmployees = EmployeesDAO.getEmployeesBySerialNumber(currentUser.SerialNumber__c);
            userHasEmployee = !userEmployees.isEmpty();
        }

        if(currentUser.SerialNumber__c!=null && userHasEmployee) {
            List<Role__c> rolesAssociated = RoleDAO.getRolesByEmployeeSerialNumberAndStructureId(currentUser.SerialNumber__c);
            List<MacrostructureAssociation__c> macrostructureAssociations = MacrostructureAssociationDAO.getMAbyUserIdAndStructureId(currentUserId);
            Boolean hasRoleAssociated = rolesAssociated != null && !rolesAssociated.isEmpty();
            Boolean hasMacrostructureAssociation = macrostructureAssociations != null && !macrostructureAssociations.isEmpty();
            List<String> roleStructureIds = new List<String>();
            Set<String> roleMacroStructureIds = new Set<String>();
            List<String> MacroStructureIds = new List<String>();
            if (hasRoleAssociated || hasMacrostructureAssociation) {
                Integer structuresIdSize = structuresId.size();
                if (hasRoleAssociated) {
                    for (Role__c role : rolesAssociated) {
                        roleStructureIds.add(role.StructureId__c);
                        Id macstruct = role.StructureId__r.TechMacrostructureId__c;
                        roleMacroStructureIds.add(macstruct);
                    }
                    for (Integer j = structuresIdSize - 1; j >= 0; j--) {
                        if (roleStructureIds.contains(structuresId[j]) || roleMacroStructureIds.contains(structureIdMacrostructureMap.get(structuresId[j]))) {
                            structuresId.remove(j);
                        }
                    }
                    structuresIdSize = structuresId.size();
                }
                if (hasMacrostructureAssociation && structuresIdSize >= 0) {
                    for (MacrostructureAssociation__c msa : macrostructureAssociations) {
                        MacroStructureIds.add(msa.Structure__c);
                    }

                    for (Integer j = structuresIdSize - 1; j >= 0; j--) {
                        if (MacroStructureIds.contains(structureIdMacrostructureMap.get(structuresId[j]))) {
                            structuresId.remove(j);
                        }
                    }
                }

                if (!structuresId.isEmpty()) {
                    for (String structureId : structuresId) {
                        Structure__c structure = idStructureMap.get(structureId);
                        structure.addError(errorLabel);
                    }
                }

            } else {
                for (Structure__c structure : listStructures) {
                    structure.addError(errorLabel);
                }
            }
        }else{
            if(currentUser.SerialNumber__c == null) {
                errorLabel = Label.NoUserSerialNumber;
            }else{
                errorLabel = Label.NoEmployeeWithSerialNumber+' '+currentUser.SerialNumber__c;
            }
            for (Structure__c structure : listStructures) {
                structure.addError(errorLabel);
            }
        }
    }
    public static void TriggerHandlerPopulateLastModifiedWSO2(List<Structure__c> listStructures){
        if(EmployeeService.isNotWSO2()){
            return;
        }
        Datetime nowDatetime = Datetime.now();
        for(Structure__c structure : listStructures){
            structure.LastModifiedWSO2__c = nowDatetime;
            structure.IsDeleted__c = false;
        }
    }
    public static void TriggerHandlerPopulateName(List<Structure__c> listStructures,Map<Id, Structure__c> oldStructures){
        if(oldStructures!= null){
            for(Structure__c structure : listStructures){
                if (structure.ExtendedName__c != oldStructures.get(structure.Id).ExtendedName__c){
                    String extendedName = structure.ExtendedName__c;
                    if(extendedName!= null) {
                        if (extendedName.length() >= 255) {
                            structure.StructureName__c = extendedName.substring(0, 255);
                        } else {
                            structure.StructureName__c = extendedName;
                        }
                    }
                }
            }
        }else{
            for(Structure__c structure : listStructures){
                String extendedName = structure.ExtendedName__c;
                if(extendedName!= null) {
                    if (extendedName.length() >= 255) {
                        structure.StructureName__c = extendedName.substring(0, 255);
                    } else {
                        structure.StructureName__c = extendedName;
                    }
                }
            }
        }
    }
    public static void TriggerHandlerSetRecordType(List<Structure__c> listStructures,Map<Id, Structure__c> oldStructures){
        Map<String, NameOrgRecordMap__c> nameOrgRecordMap = NameOrgRecordMap__c.getAll();
        List<RecordType> recordTypes = RecordTypeDAO.getStructuresRecordTypes();
        Map<String,String> nameIdRecordTypeMap = new Map<String,String>();
        for(RecordType recordType : recordTypes){
            nameIdRecordTypeMap.put(recordType.DeveloperName,recordType.Id);
        }
        if(oldStructures!= null){
            for(Structure__c structure : listStructures){
                if (structure.Name_Org_Type__c != oldStructures.get(structure.Id).Name_Org_Type__c){
                    NameOrgRecordMap__c nameOrgRecord = nameOrgRecordMap.get(structure.Name_Org_Type__c);
                    if(nameOrgRecord != null){
                        String recordTypeId = nameIdRecordTypeMap.get(nameOrgRecord.RecordType__c);
                        if(recordTypeId!= null){
                            structure.RecordTypeId = recordTypeId;
                        }
                    }
                }
            }
        }else{
            for(Structure__c structure : listStructures){
                NameOrgRecordMap__c nameOrgRecord = nameOrgRecordMap.get(structure.Name_Org_Type__c);
                if(nameOrgRecord != null){
                    String recordTypeId = nameIdRecordTypeMap.get(nameOrgRecord.RecordType__c);
                    if(recordTypeId!= null){
                        structure.RecordTypeId = recordTypeId;
                    }
                }
            }
        }
    }

    public static void deleteStructures(List<Structure__c> structures, Boolean allOrNone) {
        if(structures !=null && !structures.isEmpty()) StructuresDAO.deleteStructures(structures, allOrNone);
    }

    public static void updateStructures(List<Structure__c> structures, Boolean allOrNone) {
        if(structures !=null && !structures.isEmpty()) StructuresDAO.updateStructures(structures, allOrNone);
    }
}