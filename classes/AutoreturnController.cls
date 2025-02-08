/**
 * Created by snekkanti002 on 17/05/2022.
 */

public without sharing class AutoreturnController {
    public class Vehicle {
        @AuraEnabled public String licence {get; set;}
        @AuraEnabled public String model {get; set;}
        @AuraEnabled public String removalPlace {get; set;}
        @AuraEnabled public String removalStatus {get; set;}
        @AuraEnabled public String depositDate {get; set;}
        @AuraEnabled public String depositDateFormatted {get; set;}
        @AuraEnabled public String depositInfo {get; set;}
        @AuraEnabled public String custodyPlace {get; set;}
        @AuraEnabled public String withdrawalDate {get; set;}
        @AuraEnabled public String withdrawalDateFormatted {get; set;}
        @AuraEnabled public String veicoloRitirato {get; set;}
        @AuraEnabled public Boolean veicoloRitiratoBoolean {get; set;}
    }

    @AuraEnabled
    public static List<Vehicle> getVehicles(String licencePlate) {
        DebugService.printLimits('AutoReturnController', 'getVehicles', 'start');
        List<Vehicle> vehicles = null;
        ResponseAutoreturn responsesAutoreturn = AutoreturnCallout.autoreturnCallout(licencePlate);
        try {
            vehicles = createVehicleWrapper(responsesAutoreturn);
        } catch(Exception e) {
            ErrorLogEventHandler.standardExceptionLog('AutoreturnController', 'getVehicles', e);
        }
        DebugService.printLimits('AutoReturnController', 'getVehicles', 'end');

        return vehicles;
    }

    public static List<Vehicle> createVehicleWrapper(ResponseAutoreturn responsesAutoreturn) {
        DebugService.printLimits('AutoReturnController', 'createVehicleWrapper', 'start');
        List<Vehicle> vehicles = null;

        if(responsesAutoreturn != null && responsesAutoreturn.storicoEventiAutoResponse?.result != null) {
            System.debug('responseAutoreturn is not null ' + responsesAutoreturn);
            vehicles = new List<Vehicle>();
            for(ResponseAutoreturn.Result result: responsesAutoreturn.storicoEventiAutoResponse.result) {
                Vehicle vehicle = new Vehicle();

                vehicle.licence = result.Targa;
                vehicle.model = result.ModelloVeicolo;
                vehicle.removalPlace = result.LuogoRimozione;
                vehicle.custodyPlace = result.LuogoCustodia;
                vehicle.withdrawalDate = result.DataOraRitiro;
                vehicle.withdrawalDateFormatted = (result.DataOraRitiro != null) ? String.valueOf(Date.parse(result.DataOraRitiro.substringBefore(' '))) : '';
                vehicle.removalStatus = result.TipoProcedimento;
                vehicle.veicoloRitirato = result.VeicoloRitirato ? '✔' : '❌';
                vehicle.veicoloRitiratoBoolean = result.VeicoloRitirato;
                vehicle.depositDate = result.DataOraCustodia;
                vehicle.depositDateFormatted = String.valueOf(Date.parse(result.DataOraCustodia.substringBefore(' ')));
                vehicle.depositInfo = result.Deposito;

                vehicles.add(vehicle);
            }
        }

        DebugService.printList('AutoReturnController', 'createVehicleWrapper', 'vehicles', vehicles, true);
        DebugService.printLimits('AutoReturnController', 'createVehicleWrapper', 'end');

        return vehicles;
    }

    @AuraEnabled
    public static Integer getPageSize() {
        DebugService.printLimits('AutoreturnController', 'getPageSize', 'start/end');
        return Integer.valueOf(Paginator_Settings__c.getInstance('Autoreturn').Page_Size__c);
    }
}