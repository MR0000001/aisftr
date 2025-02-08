import getOperandiTranscoding from '@salesforce/apex/AmaTariController.getOperandiTranscoding';
import getTari from '@salesforce/apex/AmaTariController.getTari';
import getAvvisiPagamento from '@salesforce/apex/AmaTariController.getAvvisiPagamento';
import Activation_Date from '@salesforce/label/c.Activation_Date';
import Category from '@salesforce/label/c.Category';
import CF_TaRi from '@salesforce/label/c.CF_TaRi';
import Contract_Code from '@salesforce/label/c.Contract_Code';
import Contract_address from '@salesforce/label/c.Contract_address';
import Contract_List from '@salesforce/label/c.Contract_List';
import Customer_Accounts from '@salesforce/label/c.Customer_Accounts';
import Customer_Accounts_List from '@salesforce/label/c.Customer_Accounts_List';
import Delivery_address from '@salesforce/label/c.Delivery_address';
import Effective_Date from '@salesforce/label/c.Effective_Date';
import End_Date_Valid from '@salesforce/label/c.End_Date_Valid';
import FirstName_LastName from '@salesforce/label/c.FirstName_LastName';
import FiscalCode_PIVA from '@salesforce/label/c.FiscalCode_PIVA';
import genericError from '@salesforce/label/c.Generic_SomethingWrong';
import Information from '@salesforce/label/c.Information';
import Information_Code from '@salesforce/label/c.Information_Code';
import No_Info_TARI from '@salesforce/label/c.No_Info_TARI';
import PIVA_TaRi from '@salesforce/label/c.PIVA_TaRi';
import Residence_address from '@salesforce/label/c.Residence_address';
import Search from '@salesforce/label/c.Search';
import Termination_Date from '@salesforce/label/c.Termination_Date';
import User_Code from '@salesforce/label/c.User_Code';
import User_Code2 from '@salesforce/label/c.User_Code2';
import User_Type from '@salesforce/label/c.User_Type';
import Value from '@salesforce/label/c.Value';
import ActivitiesLog_Action from '@salesforce/label/c.ActivitiesLog_Action';
import conto_economico from '@salesforce/label/c.conto_economico';
import num_doc from '@salesforce/label/c.num_doc';
import data_documento from '@salesforce/label/c.data_documento';
import data_scadenza_documento from '@salesforce/label/c.data_scadenza_documento';
import tipo_documento from '@salesforce/label/c.tipo_documento';
import importo_totale from '@salesforce/label/c.importo_totale';
import importo_pagato from '@salesforce/label/c.importo_pagato';
import importo_da_pagare from '@salesforce/label/c.importo_da_pagare';
import tipo_contratto from '@salesforce/label/c.tipo_contratto';
import num_piano_rientro from '@salesforce/label/c.num_piano_rientro';
import data_inizio_rientro from '@salesforce/label/c.data_inizio_rientro';
import data_fine_rientro from '@salesforce/label/c.data_fine_rientro';
import num_sollecito from '@salesforce/label/c.num_sollecito';
import data_emissione_sollecito from '@salesforce/label/c.data_emissione_sollecito';
import numero_ruolo from '@salesforce/label/c.numero_ruolo';
import data_emissione_ruolo from '@salesforce/label/c.data_emissione_ruolo';
import solleciti from '@salesforce/label/c.Solleciti';
import ruoli from '@salesforce/label/c.Ruoli';
import piani_rate from '@salesforce/label/c.Piani_Rate';
import USER_ID from '@salesforce/user/Id';
import CASE_BUSINESS_ACCOUNT from '@salesforce/schema/Case.Case_Business_Account__c';
import CASE_CF_PIVA from '@salesforce/schema/Case.CF_o_PIVA__c';
import CASE_TYPE from '@salesforce/schema/Case.Type';
import CASE_CASE_SPEC from '@salesforce/schema/Case.Case_Specification__c';
import USER_NAME from '@salesforce/schema/User.Name';
import { getRecord, createRecord } from 'lightning/uiRecordApi';
import { api, LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const CASE_FIELDS = [CASE_BUSINESS_ACCOUNT, CASE_CF_PIVA, CASE_TYPE, CASE_CASE_SPEC];
const USER_FIELDS = [USER_NAME];

export default class AmaTari extends LightningElement {
  @api recordId;
  @track operandi = new Map();
  @track error;
  @track queryResult;
  @track activeSections = ['A', 'B'];
  @track loading = false;
  userId = USER_ID;
  wiredCase;
  textToSearch;

  get isBusinessAccount() {
    return this.wiredCase?.data?.fields.Case_Business_Account__c.value;
  }
  get type() {
    return this.wiredCase?.data?.fields.Type.value;
  }
  get caseSpec() {
    return this.wiredCase?.data?.fields.Case_Specification__c.value;
  }

  label = {
    errors: {
      genericError,
      noDataFound: No_Info_TARI
    },
    input_text_pf: CF_TaRi,
    input_text_pg: PIVA_TaRi,
    cerca: Search,
    info: Information,
    cod_utente: User_Code,
    cod_fis_or_p_iva: FiscalCode_PIVA,
    nome_cognome: FirstName_LastName,
    ind_res: Residence_address,
    lista_conti_cliente: Customer_Accounts_List,
    conto_cliente: Customer_Accounts,
    ind_recapito: Delivery_address,
    lista_contratti: Contract_List,
    cod_contratto: Contract_Code,
    ind_contratto: Contract_address,
    data_attivazione: Activation_Date,
    data_cessazione: Termination_Date,
    cod_impianto: User_Code2,
    categoria: Category,
    tipo_utenza: User_Type,
    cod_operando: Information_Code,
    data_inizio_validita: Effective_Date,
    data_fine_validita: End_Date_Valid,
    valore: Value,
    conto_economico: conto_economico,
    num_doc: num_doc,
    data_documento: data_documento,
    data_scadenza_documento: data_scadenza_documento,
    tipo_documento: tipo_documento,
    importo_totale: importo_totale,
    importo_pagato: importo_pagato,
    importo_da_pagare: importo_da_pagare,
    tipo_contratto: tipo_contratto,
    num_piano_rientro: num_piano_rientro,
    data_inizio_rientro: data_inizio_rientro,
    data_fine_rientro: data_fine_rientro,
    num_sollecito: num_sollecito,
    data_emissione_sollecito: data_emissione_sollecito,
    numero_ruolo: numero_ruolo,
    data_emissione_ruolo: data_emissione_ruolo,
    solleciti: solleciti,
    ruoli: ruoli,
    piani_rate: piani_rate
  };

  connectedCallback() {
    console.log('AMA Tari - connectedCallback - recordId:', this.recordId);
    console.log('AMA Tari - connectedCallback - userId:', this.userId);
    console.log('AMA Tari - connectedCallback - wiredUser:', this.wiredUser.data);
    console.log('AMA Tari - connectedCallback - wiredCase:', this.wiredCase.data);
    this.getOperandi();
  }

  @wire(getRecord, { recordId: '$userId', fields: USER_FIELDS })
  wiredUser;

  @wire(getRecord, { recordId: '$recordId', fields: CASE_FIELDS })
  wiredCaseHandler(value) {
    this.wiredCase = value;
    const { data, error } = value;
    if (data) {
      this.textToSearch = data.fields.CF_o_PIVA__c.value;
    }
  }
  get inputTextLabel() {
    return this.isBusinessAccount ? this.label.input_text_pg : this.label.input_text_pf;
  }

  find() {
    console.log('Find - Start');
    this.loading = true;
    const recordInput = {
      apiName: 'Activities_Log__c',
      fields: {
        Log_Action__c: ActivitiesLog_Action,
        Log_Date_Time__c: new Date(),
        Log_User_does_Action__c: this.wiredUser.data.fields.Name.value,
        Log_Type__c: this.type,
        Log_Specification__c: this.caseSpec,
        Log_Case__c: this.recordId,
        CF_PIVA__c: this.textToSearch
      }
    };
    createRecord(recordInput)
      .then((value) => {
        console.log('createRecordLogSuccessful', value);
      })
      .catch((error) => {
        console.error('createRecordLogError', error);
      });

    getTari({
      PIVAorCF: this.textToSearch,
      isJuridicalPerson: this.isBusinessAccount
    })
      .then((data) => {
        // console.log('AMA Tari - getTari data ', data);
        if (data && data.length) {
          console.log('AMA Tari - tari exists ', data);
          let res = JSON.parse(data);
          if (res.BP.length > 0) {
            res.BP.forEach((bp) => {
              bp.CA.forEach((conto_cliente) => {
                // console.log('AMA Tari - conto_cliente', conto_cliente);
                if (conto_cliente.CONTRATTI) {
                  conto_cliente.CONTRATTI.forEach((contratto) => {
                    // console.log('AMA Tari - contratto', contratto);
                    if (contratto.INFO_IMPIANTO) {

                      let listaimpianti = [];
                      
                      contratto.INFO_IMPIANTO.sort((a, b) => {
                        const dateA = new Date(a.DataInizioValidita.split("-").reverse().join("-"));
                        const dateB = new Date(b.DataInizioValidita.split("-").reverse().join("-"));
                        return dateB - dateA;
                      });

                      contratto.INFO_IMPIANTO.forEach((impianto) => {
                        console.log(
                          'AMA Tari - impianto',
                          impianto.CodiceOperando,
                          'transcodifica',
                          this.operandi[impianto.CodiceOperando]
                        );
                        try {

                          if(impianto.CodiceOperando != '5COMUNE'){

                            if (this.operandi[impianto.CodiceOperando]) {
                              impianto.CodiceOperando = this.operandi[impianto.CodiceOperando];
                            }

                            listaimpianti.push(impianto);
                          }
                        } catch (error) {
                          console.error(error);
                        }
                      });

                      contratto.INFO_IMPIANTO = listaimpianti;

                    }
                  });
                }
              });
            });
          }
          this.queryResult = res;
        } else {
          this.dispatchEvent(
            new ShowToastEvent({
              title: 'Error',
              message: data ? this.label.errors.noDataFound : this.label.errors.genericIntegrationError
            })
          );
        }
      })
      .catch((error) => {
        console.error('AMA Tari - error ', error);
        this.dispatchEvent(
          new ShowToastEvent({
            title: 'Error',
            message: error.body.message
          })
        );
      })
      .finally(() => {
        this.loading = false;
        console.groupEnd('AMA Tari - query');
      });
  }

  getOperandi() {
    getOperandiTranscoding()
      .then((value) => {
        // console.log('AMA Tari - getOperandiTranscoding value ', value);
        this.operandi = value;
      })
      .catch((error) => {
        console.error('AMA Tari - error ', error);
        this.dispatchEvent(
          new ShowToastEvent({
            title: 'Error',
            message: error.body.message
          })
        );
      });
  }

  getPosizioneEconomica(event) {
    console.log('getPosizioneEconomica - START');
    console.log('target', JSON.stringify(event.target.dataset));
    const bp = event.target.dataset.bp;
    const ca = event.target.dataset.ca;
    const searchIndexBP = this.queryResult.BP.findIndex((element) => element.CodiceBP == bp);
    const searchIndexCA = this.queryResult.BP[searchIndexBP].CA.findIndex((element) => element.CodiceCA == ca);
    if (this.queryResult.BP[searchIndexBP].CA[searchIndexCA]?.DOCUMENTI) {
      console.log('esiste già');
    } else {
      this.loading = true;
      getAvvisiPagamento({ vkont: ca, bp: bp })
        .then((data) => {
          if (data && data.length) {
            console.log('AMA Tari - getPosizioneEconomica data ', data);
            let receivedDoc = JSON.parse(data);
            this.queryResult.BP[searchIndexBP].CA[searchIndexCA].DOCUMENTI = receivedDoc.T_DOCUMENTI;
            this.queryResult.BP[searchIndexBP].CA[searchIndexCA].DOCUMENTI.forEach((doc) => {
              doc.TIPO =
                doc.TIPO === 'S'
                  ? 'Sanzioni'
                  : doc.TIPO === 'I'
                  ? 'Interessi'
                  : doc.TIPO === 'F'
                  ? 'Fattura'
                  : doc.TIPO;
              doc.TIPO_CONTRATTO =
                doc.TIPO_CONTRATTO === 'DOM'
                  ? 'Domestico'
                  : doc.TIPO_CONTRATTO === 'NDOM'
                  ? 'Non Domestico'
                  : doc.TIPO_CONTRATTO;
            });
          } else {
            this.dispatchEvent(
              new ShowToastEvent({
                title: 'Error',
                message: data ? this.label.errors.noDataFound : this.label.errors.genericIntegrationError
              })
            );
          }
        })
        .catch((error) => {
          console.error('AMA Tari - getPosizioneEconomica', error);
          this.dispatchEvent(
            new ShowToastEvent({
              title: 'Error',
              message: error.body.message
            })
          );
        })
        .finally(() => {
          // console.log('AMA Tari - getPosizioneEconomica finally', JSON.stringify(this.queryResult));
          this.loading = false;
        });
    }
  }

  handleInputChange(event) {
    this.textToSearch = event.detail.value.trim();
  }
}