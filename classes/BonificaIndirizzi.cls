/**
 * @author            : Davide Desideri
 * @created date      :
 * @description       :
 * @testClasses       : BonificaIndirizziTest
 * @last modified by  : Daniel Perrella
 * @last modified on  : 31-07-2023
 **/

public with sharing class BonificaIndirizzi {
  public static Residenza bonificaIndirizzo(String otherAddress) {
    if (String.isEmpty(otherAddress)) {
      throw new EmptyAddressException();
    }
    String indirizzo = otherAddress.split('[0-9]+').get(0).trim();
    Matcher civicoEstesoMatcher = Pattern.compile('\\d+[ ]?[A-Za-z]?').matcher(otherAddress);
    String civico = '';
    String lettera = '';
    if (civicoEstesoMatcher.find()) {
      String civicoEsteso = civicoEstesoMatcher.group();
      Matcher civicoMatcher = Pattern.compile('\\d+').matcher(civicoEsteso);
      if (civicoMatcher.find()) {
        civico = civicoMatcher.group();
      } else {
        throw new IncompleteAddressException();
      }
      Matcher letteraMatcher = Pattern.compile('[A-Za-z]').matcher(civicoEsteso);
      if (letteraMatcher.find()) {
        lettera = letteraMatcher.group();
      }
    } else {
      throw new IncompleteAddressException();
    }
    return new Residenza(indirizzo, civico, lettera);
  }

  public class Residenza {
    public String indirizzo { get; set; }
    public String civico { get; set; }
    public String lettera { get; set; }
    public Residenza(String indirizzo, String civico, String lettera) {
      this.indirizzo = indirizzo;
      this.civico = civico;
      this.lettera = lettera.toUpperCase();
    }
  }

  public class EmptyAddressException extends Exception {
  }
  public class IncompleteAddressException extends Exception {
  }
}