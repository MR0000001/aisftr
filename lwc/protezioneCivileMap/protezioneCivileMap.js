import leaflet from '@salesforce/resourceUrl/leafletFSC';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { api, LightningElement, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { updateRecord, getRecord } from 'lightning/uiRecordApi';

//LABEL
import back from '@salesforce/label/c.caseDetails_Back';
import confirmAddress from '@salesforce/label/c.conferma_Area';
import initLoadFailed from '@salesforce/label/c.Georoma_Errors_InitLoadFailed';
import mapSettingsLoadFailed from '@salesforce/label/c.Georoma_Errors_MapMetadataNotFound';
import numberInputSize from '@salesforce/label/c.Georoma_InputSize_Number';
import streetInputSize from '@salesforce/label/c.Georoma_InputSize_Street';
import civico from '@salesforce/label/c.Georoma_Label_Number';
import via from '@salesforce/label/c.Georoma_Label_Street';
import buttonMapCenter from '@salesforce/label/c.buttonMapCenter';
//APEX
import getGeoromaMetadata from '@salesforce/apex/GeoromaController.getGeoromaMetadata';
import getStreetDetails from '@salesforce/apex/GeoromaController.getStreetDetails';
import getStreetsList from '@salesforce/apex/GeoromaController.getStreetsList';

const FIELDS = [
  'Campaign.Status',
  'Campaign.Geolocation__Latitude__s',
  'Campaign.Geolocation__Longitude__s',
  'Campaign.Distance__c'
];

export default class ProtezioneCivileMap extends NavigationMixin(LightningElement) {
  @api recordId;
  @api displayMode = false;

  @track lat;
  @track lng;
  @track municipality;
  // @track fullAddress;
  @track address;
  @track numberAddress;
  @track letterAddress;

  @track map;
  @track icon;
  @track isLoading;
  @track markerLayers = {};
  @track selectedStreet = '';
  @track selectedNumberStreet = '';
  @track searchStreetKey;
  @track searchStreetNumberKey;
  @track streetNames = [];
  @track streetDetails = [];
  @track numberAddressesOptions = [];
  @track _sliderValue = 50;
  @track initialSlider;
  @track initialLat;
  @track initialLng;

  get sliderValue() {
    return this.isKm ? this._sliderValue / 1000 : this._sliderValue;
  }

  set sliderValue(value) {
    if (this.isKm) {
      this._sliderValue = value * 1000;
    } else {
      this._sliderValue = value;
    }
  }

  get mVariant() {
    return this.isKm ? 'brand' : 'neutral';
  }
  get kmVariant() {
    return this.isKm ? 'neutral' : 'brand';
  }

  get position() {
    return { lat: this.lat, lng: this.lng };
  }

  @track campaignStatus = '';
  @track inizializeMap = false;
  @track isKm = true;
  @track radiusMaxKm = 20;
  @track radiusMinKm = 1;
  @track radiusMaxM = 1000;
  @track radiusMinM = 50;

  get buttonDisabledKm() {
    return this.isKm ? true : false;
  }
  get buttonDisabledM() {
    return this.isKm ? false : true;
  }

  get buttonMap() {
    if (this.initialLat && this.initialLng && this.initialSlider) {
      return this.lat && this.lng && this.sliderValue ? false : true;
    }
    return true;
  }
  mapSettings;
  streetsTimeoutId;
  civicoTimeoutId;
  label = {
    buttonMapCenter,
    back: back.toUpperCase(),
    confirmAddress: confirmAddress.toUpperCase(),
    numberInputSize,
    streetInputSize,
    civico: civico.toUpperCase(),
    via: via.toUpperCase(),
    errors: {
      initLoadFailed,
      mapSettingsLoadFailed
    }
  };

  // lat 41.91270500650227
  // lng 12.427725791931154

  @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
  wiredRecord({ error, data }) {
    if (error) {
      console.log('error ', error);
      this.reset();
    } else if (data) {
      console.log('wired data', JSON.stringify(data));
      this._sliderValue = data.fields.Distance__c.value ? data.fields.Distance__c.value : 50;
      this.isKm = this._sliderValue > this.radiusMaxM ? true : false;
      this.lat = data.fields.Geolocation__Latitude__s.value;
      this.lng = data.fields.Geolocation__Longitude__s.value;
      this.campaignStatus = data.fields.Status.value;
      if (this.lat && this.lng && this.sliderValue) {
        this.initialLat = this.lat;
        this.initialLng = this.lng;
        this.initialSlider = this._sliderValue;
        console.log('lat and lng exists');
        if (this.inizializeMap) {
          this.setMarker();
        }
      }
    }
  }

  connectedCallback() {
    console.log('Map - connectedCallback');
    console.log('lng', this.lng);
    console.log('lat', this.lat);
    console.log('municipality', this.municipality);
    console.log('fullAddress', this.fullAddress);
    console.log('address', this.address);
    console.log('numberAddress', this.numberAddress);
    console.log('letterAddress', this.letterAddress);
    // if (!this.displayMode) {
    //   setTimeout(() =>
    //     this.template.querySelector('input').setAttribute('list', this.template.querySelector('datalist').id)
    //   );
    // }

    Promise.all([loadScript(this, leaflet + '/leaflet.js'), loadStyle(this, leaflet + '/leaflet.css')])
      .then(() => {
        console.log('Promise All Then');
        getGeoromaMetadata()
          .then((data) => {
            this.mapSettings = data;
            console.log('mapSettings ', this.mapSettings);
            if (this.mapSettings) {
              console.log('mapSettings is not empty');
              this.initializeleaflet();
            }
          })
          .catch((error) => {
            console.log('error ', error);
            this.showToast(this.label.errors.mapSettingsLoadFailed, '', 'error');
          });
      })
      .catch((error) => {
        this.showToast(this.label.errors.initLoadFailed, error.message, 'error');
      });
  }

  renderedCallback() {
    if (!this.displayMode) {
      this.template.querySelector('input').setAttribute('list', this.template.querySelector('datalist').id);
    }
  }

  initializeleaflet() {
    const mapRoot = this.template.querySelector('.map-root');
    console.log('mapRoot ', mapRoot);
    let baseLayer = L.tileLayer.wms(this.mapSettings.Tile_Layer_Endpoint__c, {
      layers: this.mapSettings.Tile_Layer_Layers__c,
      format: this.mapSettings.Tile_Layer_Format__c,
      transparent: this.mapSettings.Tile_Layer_Is_Transparent__c,
      version: this.mapSettings.Tile_Layer_Version__c,
      uppercase: this.mapSettings.Tile_Layer_Is_Uppercase__c
    });
    // let baseLayer = L.tileLayer('http://{s}.google.com/vt/lyrs=m&x={x}&y={y}&z={z}', {
    //     maxZoom: 20,
    //     subdomains: ['mt0', 'mt1', 'mt2', 'mt3']
    // });

    // 42.175232481753724, 12.07321319136403 alto sx
    // 41.644753466649725, 12.88611032023486 basso dx

    let bounds = L.latLngBounds(
      [this.mapSettings.Map_Bound_Corner_One_Lat__c, this.mapSettings.Map_Bound_Corner_One_Lng__c],
      [this.mapSettings.Map_Bound_Corner_Two_Lat__c, this.mapSettings.Map_Bound_Corner_Two_Lng__c]
    );
    var self = this;
    this.map = L.map(mapRoot, {
      attributionControl: false,
      crs: L.CRS.EPSG3857,
      center: bounds.getCenter(),
      zoom: this.mapSettings.Zoom_Initial__c,
      minZoom: this.mapSettings.Zoom_Min__c,
      layers: [baseLayer],
      maxBounds: bounds
    }).on('click', function mapClickListen(e) {
      console.log('click e.latlng', e.latlng);
      console.log('click lat', e.latlng.lat);
      console.log('click lng', e.latlng.lng);
      self.lat = e.latlng.lat;
      self.lng = e.latlng.lng;
      console.log('map click event');
      self.setMarker();
    });
    this.map.setMinZoom(this.map.getBoundsZoom(this.map.options.maxBounds));
    this.map.zoomControl.setPosition(this.mapSettings.Zoom_Control_Position__c);
    this.inizializeMap = true;
    if (this.lat && this.lng && this.sliderValue) {
      console.log('lat and lng exists');
      this.setMarker();
    }
  }

  // pos = {lat: 41.870023849435604, lng: 12.438980340957643}
  @api
  setMarker() {
    console.log('setMarker', this.position);
    this.map.eachLayer((layer) => {
      if (layer instanceof L.Marker) {
        this.map.removeLayer(layer);
      }
      if (layer instanceof L.Circle) {
        this.map.removeLayer(layer);
        console.log('setMarker L.Circle ');
      }
    });

    this.markerLayers['main'] = L.marker(this.position).addTo(this.map);
    this.map.flyTo(this.position, this.mapSettings.Zoom_Max__c);
    console.log('il tuo slider value ', this.sliderValue);
    console.log('il radiusMax ', this.isKm ? this.radiusMaxKm : this.radiusMaxM);
    console.log('il radiusMin ', this.isKm ? this.radiusMinKm : this.radiusMinM);
    this.markerLayers['main'] = L.circle(this.position, { radius: this._sliderValue }).addTo(this.map);
  }

  handleCallout(event) {
    console.log('handleCallout');
    console.log('event.target.value ', event.target.value);
    console.log('event.keyCode ', event.keyCode);
    this.reset();
    if (event.keyCode != 13) {
      console.log('not enter');
      this.searchStreetKey =
        event.target.value.length >= this.mapSettings.Search_Bar_Min_Search_Key_Street__c
          ? event.target.value.toUpperCase()
          : null;
      clearTimeout(this.streetsTimeoutId);
      console.log('searchStreetKey ', this.searchStreetKey);
      if (this.searchStreetKey) {
        console.log('this.streetsTimeoutId ', this.streetsTimeoutId);
        console.log('start searching: ', this.searchStreetKey);
        this.streetsTimeoutId = setTimeout(this.callout.bind(this), this.mapSettings.Timeout_Get_Streets__c);
      }
    } else if (event.keyCode == 13 && this.searchStreetKey) {
      console.log('enter');
      console.log('this.streetsTimeoutId ', this.streetsTimeoutId);
      console.log('start searching: ', this.searchStreetKey);
      this.streetsTimeoutId = setTimeout(this.callout.bind(this), this.mapSettings.Timeout_Get_Streets__c);
    }
  }

  callout() {
    this.isLoading = true;
    console.log('this.streetNames. ', this.streetNames);
    console.log('this.searchStreetKey ', this.searchStreetKey);
    if (
      (this.streetNames.length == 1 && this.searchStreetKey == this.streetNames[0].value) ||
      this.streetNames.some((s) => s.label == this.searchStreetKey)
    ) {
      console.log('CALLOUT: getStreetDetails');
      console.log('single street: ', this.streetNames.find((s) => s.label == this.searchStreetKey).label);
      this.selectedStreet = this.streetNames.find((s) => s.label == this.searchStreetKey).label;
      this.calloutGetStreetDetails();
    } else {
      console.log('CALLOUT: getStreetsList');
      this.calloutGetStreetsList();
    }
  }

  reset() {
    console.group('reset');
    this.selectedStreet = '';
    this.selectedNumberStreet = '';
    this.streetDetails = [];
    this.numberAddressesOptions = [];
    console.groupEnd('reset');
  }

  calloutGetStreetsList() {
    getStreetsList({
      searchStreetKey: this.searchStreetKey,
      pageSize: this.mapSettings.Streets_List_Size__c
    })
      .then((data) => {
        console.log('in then ', data.sort());
        if (data.length) {
          console.log('streets exists');
          let streetNames = [];
          data.forEach((s) => {
            const option = {
              label: s,
              value: s
            };
            streetNames.push(option);
          });
          this.streetNames = streetNames;
        }
      })
      .catch((error) => {
        console.log('error ', error);
        this.reset();
        this.showToast(error.body.message, '', 'error');
      })
      .finally(() => {
        console.log('this.streetNames ', this.streetNames);
        this.isLoading = false;
        if (this.streetNames.length == 1 && this.searchStreetKey == this.streetNames[0].value) {
          console.log('CALLOUT: getStreetDetails2');
          console.log('single street: ', this.streetNames.find((s) => s.label == this.searchStreetKey).label);
          this.selectedStreet = this.streetNames.find((s) => s.label == this.searchStreetKey).label;
          this.calloutGetStreetDetails();
        }
      });
  }

  calloutGetStreetDetails() {
    console.group('calloutGetStreetDetails');
    console.log('selectedStreet ' + this.selectedStreet);
    console.log('searchStreetNumberKey ' + this.searchStreetNumberKey);
    if (this.selectedStreet) {
      console.log('start searching for details: ', this.selectedStreet);
      this.isLoading = true;
      getStreetDetails({
        streetName: this.selectedStreet,
        streetNumber: ''
      })
        .then((data) => {
          console.log('data ', data);
          if (Object.keys(data).length) {
            console.log('setting marker');
            this.address = data.streetName;
            this.streetDetails = data.streetDetails;
            let numberAddressesOptions = [];
            for (let key in this.streetDetails) {
              const option = {
                label: key,
                value: key
              };
              numberAddressesOptions.push(option);
            }
            numberAddressesOptions = numberAddressesOptions.sort((a, b) => {
              return a.label.localeCompare(b.label, undefined, { numeric: true, sensitivity: 'base' });
            });
            this.numberAddressesOptions = numberAddressesOptions;
          }
        })
        .catch((error) => {
          console.log('error ', error);
          this.reset();
        })
        .finally(() => {
          console.log('numberAddressesOptions ', JSON.parse(JSON.stringify(this.numberAddressesOptions)));
          this.isLoading = false;
        });
    }
    console.groupEnd('calloutGetStreetDetails');
  }

  handleNumberChange(event) {
    console.group('handleNumberChange');
    this.selectedNumberStreet = event.detail.value;

    let streetDetail = this.streetDetails[event.detail.value];
    this.municipality = streetDetail.municipality;
    this.lat = streetDetail.latitude;
    this.lng = streetDetail.longitude;
    this.numberAddress = streetDetail.numberStreet;
    this.letterAddress = streetDetail.letterStreet;
    this.setMarker();
    console.groupEnd('handleNumberChange');
  }

  handleCircle(e) {
    this.sliderValue = e.detail.value;
    console.log('handleCircle', this.sliderValue);
    this.setMarker();
  }

  get isConfirmDisabled() {
    let bozza = 'Draft Start Alert';
    let approvazione = 'Approval Alert';
    console.group(
      'isConfirmDisabled',
      !(
        this.lat &&
        this.lng &&
        this.sliderValue &&
        (this.campaignStatus === bozza || this.campaignStatus === approvazione)
      )
    );
    console.log('status ', this.campaignStatus, this.campaignStatus === bozza || this.campaignStatus === approvazione);
    console.log('lat ', this.lat, Boolean(this.lat));
    console.log('lng ', this.lng, Boolean(this.lng));
    console.log('sliderValue ', this.sliderValue, Boolean(this.sliderValue));
    console.groupEnd();
    return !(
      this.lat &&
      this.lng &&
      this.sliderValue &&
      (this.campaignStatus === bozza || this.campaignStatus === approvazione)
    );
  }

  handleReturn(event) {
    console.group('handleReturn');
    console.log('event.target.dataset.label ', event.target.dataset.label);
    if (event.target.dataset.label === this.label.back) {
      console.log('back');
      const selectedEvent = new CustomEvent('goback');
      this.dispatchEvent(selectedEvent);
    } else if (event.target.dataset.label === this.label.confirmAddress) {
      console.log('confirm');
      console.log('la tua posizione ', this.position);
      console.log('fullAddress ', this.fullAddress);
      let fields = {};
      fields.Id = this.recordId;
      fields.Geolocation__Latitude__s = this.position.lat;
      fields.Geolocation__Longitude__s = this.position.lng;
      fields.Distance__c = this._sliderValue;
      if (this.addressToSave === undefined) {
        fields.Street__c = '';
      } else if (this.addressToSave) {
        fields.Street__c = this.fullAddress;
      }

      const recordInput = { fields };
      console.log('fields ', recordInput);
      updateRecord(recordInput)
        .then(() => {
          this.isloading = true;
        })
        .catch((error) => {
          console.log('error ', error.body.message);
          this.reset();
        })
        .finally(() => {
          console.log('finally');
          this.isloading = false;
          this.showToast('Success', 'Campagna aggiornata con successo', 'success');
          this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
              recordId: this.recordId,
              objectApiName: 'Campaign',
              actionName: 'view'
            }
          });
        });
    }
    console.groupEnd('handleReturn');
  }

  showToast(title, message, variant) {
    this.dispatchEvent(
      new ShowToastEvent({
        title: title,
        message: message,
        variant: variant
      })
    );
  }

  showMeters() {
    this.isKm = !this.isKm;
    this.sliderValue = this.radiusMaxM;
    this.setMarker();
  }

  showKm() {
    this.isKm = !this.isKm;
    this.sliderValue = this.radiusMinKm;
    this.setMarker();
  }

  centerMarker() {
    this.lat = this.initialLat;
    this.lng = this.initialLng;
    this.sliderValue = this.initialSlider;
    this.setMarker();
  }

  get addressToSave() {
    if (this.initialLat && this.initialLng && this.initialLat === this.lat && this.initialLng === this.lng) { //non aggiorna campo
      return null;
    }
    if (this.address) {
      return `${this.addess} ${String(this.numberAddress) ? ', ' + this.numberAddress : ''}${this.letterAddress}`; //aggiorna campo
    }
    return undefined; //sbianca campo
  }

  get fullAddress() {
    let fullAddress = this.address ? this.address : null;
    fullAddress = fullAddress && String(this.numberAddress) ? fullAddress + ', ' + this.numberAddress : fullAddress;
    fullAddress = fullAddress && this.letterAddress ? fullAddress + this.letterAddress : fullAddress;
    return fullAddress;
  }  
}