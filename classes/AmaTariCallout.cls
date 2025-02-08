/**
 * @author            : Daniel Perrella
 * @created date      : 28-09-2023
 * @description       :
 * @testClasses       : AmaTari_Test
 * @last modified by  : Daniel Perrella
 * @last modified on  : 11-10-2023
 **/
public with sharing class AmaTariCallout {
  private static Callout_Common_Settings__mdt commonCalloutSettings = Callout_Common_Settings__mdt.getInstance(
    'AmaTari'
  );

  public static String amaTariCallout(String PIVAorCF, Boolean isJuridicalPerson) {
    DebugService.printLimits('AmaTariCallout', 'amaTariCallout', 'start');
    System.debug('PIVAorCF: ' + PIVAorCF);
    System.debug('isJuridicalPerson: ' + isJuridicalPerson);
    String accessToken = WSO2AuthCallout.WSO2AuthCallout();
    CalloutUtils callout = new CalloutUtils()
      .endPoint(
        commonCalloutSettings.Endpoint__c +
          'anagrafiche/' +
          (isJuridicalPerson ? 'partita-iva/' : 'codice-fiscale/') +
          PIVAorCF
      )
      .method(commonCalloutSettings.Method__c)
      .addAuthorization(commonCalloutSettings.Auth_Type__c + ' ' + accessToken)
      .addHeader('Content-Type', commonCalloutSettings.Header_Content_Type__c)
      .addHeader('Accept', commonCalloutSettings.Header_Accept_Type__c)
      .timeout(Integer.valueOf(commonCalloutSettings.Timeout_Value__c));
    try {
      System.HttpResponse response = callout.send();
      serviceRespondsPositively(response);
      return callout.response.getBody();
    } finally {
      DebugService.printLimits('AmaTariCallout', 'AmaTariCallout', 'end');
    }
  }

  public static String amaTariAvvisiPagamentoCallout(String vkont, String bp) {
    DebugService.printLimits('AmaTariCallout', 'amaTariAvvisiPagamentoCallout', 'start');
    String accessToken = WSO2AuthCallout.WSO2AuthCallout();
    CalloutUtils callout = new CalloutUtils()
      .endPoint(commonCalloutSettings.Endpoint__c + 'avvisi-pagamento')
      .method('POST')
      .addAuthorization(commonCalloutSettings.Auth_Type__c + ' ' + accessToken)
      .addHeader('Content-Type', commonCalloutSettings.Header_Content_Type__c)
      .addHeader('Accept', commonCalloutSettings.Header_Accept_Type__c)
      .addHeader('Content-Length', '0')
      .body(generateAvvisiPagamentoBody(vkont, bp))
      .timeout(Integer.valueOf(commonCalloutSettings.Timeout_Value__c));
    try {
      System.HttpResponse response = callout.send();
      serviceRespondsPositively(response);
      return callout.response.getBody();
    } finally {
      DebugService.printLimits('AmaTariCallout', 'AmaTariCallout', 'end');
    }
  }

  private static boolean serviceRespondsPositively(System.HttpResponse response) {
    if (!(response.getStatusCode() == 200 || response.getStatusCode() == 201)) {
      String messageDescription  = response.getBody().substringBetween('"MessageDescription": ',',');
      String errorMessage = response.getBody().substringBetween('"MessageError": ',',');
      System.debug(errorMessage);
      if (String.isNotBlank(messageDescription)) {
        throw new StatusCodeErrorException(messageDescription);
      }
      if (String.isNotBlank(errorMessage)) {
        throw new StatusCodeErrorException(errorMessage);
      }
      throw new StatusCodeErrorException('Servizio non raggiungibile, Riprova più tardi');
    }
    return true;
  }

  private static string generateAvvisiPagamentoBody(String vkont, String bp) {
    return '{"VKONT": "' +
      vkont +
      '","BP": "' +
      bp +
      '","DOC": true,"SOLL": true,"RUOLO": true,"P_RATA": true,"DOC_PARE": true}';
  }

  public class StatusCodeErrorException extends Exception {
  }
}