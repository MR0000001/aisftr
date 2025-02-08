/**
 * @author            : Daniel Perrella
 * @created date      : 09-11-2023
 * @description       : Classe che rappresenta una option per una lightning combobox
 * @testClasses       : TestCaseCreationController
 * @last modified by  : Daniel Perrella
 * @last modified on  : 27-11-2023
 **/
public class ComboboxOption {
  @AuraEnabled
  public String label { get; set; }
  @AuraEnabled
  public String value { get; set; }

  public ComboboxOption(String value) {
    this(value, value);
  }

  public ComboboxOption(String value, String label) {
    this.value = value;
    this.label = label;
  }
}