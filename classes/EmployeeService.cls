/**
 * Created by LCONATO00 on 06/05/2020.
 */

public with sharing class EmployeeService {
    /**
	 * @description This method checks if the user has a WSO2 Integration profile
	 * @param
	 * @return A boolean that tells if the user is WSO2 one
	 */
    public static Boolean isNotWSO2() {

        User creator = [SELECT Id, Profile.Name FROM User WHERE Id = :UserInfo.getUserId()];
        Boolean isWSO2 = (creator.Profile.Name.contains('WSO2 Integration') );
        if(isWSO2) {
            return false;
        }
        return true;
    }

    public static void TriggerHandlerPopolateBeforeInsertBeforeUpdate(List<Employee__c> listEmployees){
        if(isNotWSO2()){
            return;
        }
        Datetime nowDatetime = Datetime.now();
        for(Employee__c employee : listEmployees){
            employee.LastModifiedWSO2__c = nowDatetime;
            employee.IsDeleted__c = false;
        }
    }

    public static void deleteEmployees(List<Employee__c> employees, Boolean allOrNone) {
        if(employees != null && !employees.isEmpty()) EmployeesDAO.deleteEmployees(employees, allOrNone);
    }

    public static void updateEmployees(List<Employee__c> employees, Boolean allOrNone) {
        if(employees != null && !employees.isEmpty()) EmployeesDAO.updateEmployees(employees, allOrNone);
    }
}