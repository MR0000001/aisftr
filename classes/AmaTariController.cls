/**
 * @author            : Daniel Perrella
 * @created date      :
 * @description       :
 * @testClasses       : AmaTari_Test
 * @last modified by  : Daniel Perrella
 * @last modified on  : 28-09-2023
 **/
public with sharing class AmaTariController {
  @AuraEnabled
  public static String getTari(String PIVAorCF, Boolean isJuridicalPerson) {
    DebugService.printLimits('AmaTariController', 'getTari', 'start');
    PIVAorCF = PIVAorCF.toUpperCase();
    try {
      if (isJuridicalPerson && PIVAorCF.substring(0, 1).isNumeric()) {
        PIVAorCF = 'IT' + PIVAorCF;
      }
      return AmaTariCallout.amaTariCallout(PIVAorCF, isJuridicalPerson);
    } catch (Exception e) {
      ErrorLogEventHandler.standardExceptionLog('AmaTariController', 'getTari', e);
      throw new AuraHandledException(e.getMessage());
    } finally {
      DebugService.printLimits('AmaTariController', 'getTari', 'end');
    }
  }

  @AuraEnabled
  public static String getAvvisiPagamento(String vkont, String bp) {
    DebugService.printLimits('AmaTariController', 'getAvvisiPagamento', 'start');
    try {
      return AmaTariCallout.amaTariAvvisiPagamentoCallout(vkont, bp);
    } catch (Exception e) {
      ErrorLogEventHandler.standardExceptionLog('AmaTariController', 'getAvvisiPagamento', e);
      throw new AuraHandledException(e.getMessage());
    } finally {
      DebugService.printLimits('AmaTariController', 'getAvvisiPagamento', 'end');
    }
  }

  @AuraEnabled(Cacheable=true)
  public static Map<String, String> getOperandiTranscoding() {
    Map<String, String> transcodifiche = new Map<String, String>();
    for (AMA_TaRi__mdt operando : AMA_TaRi__mdt.getAll().values()) {
      transcodifiche.put(operando.label, operando.Codice_Operando_Transcoding__c);
    }
    return transcodifiche;
  }
}