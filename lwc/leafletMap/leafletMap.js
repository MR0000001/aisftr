/* eslint-disable guard-for-in */
/* eslint-disable @lwc/lwc/no-async-operation */
/* eslint-disable dot-notation */
/* eslint-disable no-undef */
import leaflet from '@salesforce/resourceUrl/leafletFSC';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { api, LightningElement, track } from 'lwc';
//LABEL
import back from '@salesforce/label/c.caseDetails_Back';
import confirmAddress from '@salesforce/label/c.caseDetails_confirmAddress';
import initLoadFailed from '@salesforce/label/c.Georoma_Errors_InitLoadFailed';
import mapSettingsLoadFailed from '@salesforce/label/c.Georoma_Errors_MapMetadataNotFound';
import numberInputSize from '@salesforce/label/c.Georoma_InputSize_Number';
import streetInputSize from '@salesforce/label/c.Georoma_InputSize_Street';
import civico from '@salesforce/label/c.Georoma_Label_Number';
import via from '@salesforce/label/c.Georoma_Label_Street';
//APEX
import getGeoromaMetadata from '@salesforce/apex/GeoromaController.getGeoromaMetadata';
import getStreetDetails from '@salesforce/apex/GeoromaController.getStreetDetails';
import getStreetsList from '@salesforce/apex/GeoromaController.getStreetsList';

export default class LeafletMap extends LightningElement {
  @api lat;
  @api lng;
  @api municipality;
  @api fullAddress;
  @api address;
  @api numberAddress;
  @api letterAddress;

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
  @track isConfirmDisabled = true;

  mapSettings;
  streetsTimeoutId;
  civicoTimeoutId;
  label = {
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

  connectedCallback() {
    console.log('Map - connectedCallback');
    console.log('lng', this.lng);
    console.log('lat', this.lat);
    console.log('municipality', this.municipality);
    console.log('fullAddress', this.fullAddress);
    console.log('address', this.address);
    console.log('numberAddress', this.numberAddress);
    console.log('letterAddress', this.letterAddress);
    setTimeout(() =>
      this.template.querySelector('input').setAttribute('list', this.template.querySelector('datalist').id)
    );
    Promise.all([loadScript(this, leaflet + '/leaflet.js'), loadStyle(this, leaflet + '/leaflet.css')])
      .then(() => {
        console.log('Promise All Then');
        this.getGeoromaMetadata();
      })
      .catch((error) => {
        this.showToast(this.label.errors.initLoadFailed, error.message, 'error');
      });
  }

  getGeoromaMetadata() {
    console.group('getGeoromaMetadata');
    getGeoromaMetadata({})
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
    console.groupEnd('getGeoromaMetadata');
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
    this.map = L.map(mapRoot, {
      attributionControl: false,
      crs: L.CRS.EPSG3857,
      center: bounds.getCenter(),
      zoom: this.mapSettings.Zoom_Initial__c,
      minZoom: this.mapSettings.Zoom_Min__c,
      layers: [baseLayer],
      maxBounds: bounds
    }) /* .on('click', function mapClickListen(e) {
      var pos = e.latlng;
      console.log('map click event');
                var marker = L.marker(pos);
      self.setMarker(pos);
        }) */;
    this.map.setMinZoom(this.map.getBoundsZoom(this.map.options.maxBounds));
    this.map.zoomControl.setPosition(this.mapSettings.Zoom_Control_Position__c);
    if (this.lat && this.lng) {
      console.log('lat and lng exists');
      this.setMarker([this.lat, this.lng]);
    }
    this.checkIsConfirmDisabled();
  }

  // pos = {lat: 41.870023849435604, lng: 12.438980340957643}
  @api
  setMarker(pos) {
    console.log('setMarker');
    this.map.eachLayer((layer) => {
      if (layer instanceof L.Marker) {
        this.map.removeLayer(layer);
      }
    });

    this.markerLayers['main'] = L.marker(pos).addTo(this.map).bindPopup(this.fullAddress, {closeButton:false}).openPopup();
    this.map.flyTo(pos, this.mapSettings.Zoom_Max__c);
    console.log('marker position:', pos);
  }

  /*@api
	centerMap(pos) {
		console.log("centerMap");
		this.map.panTo(new L.LatLng(lat, lng));
	}*/

  /* @api
	getMarker() {
	  console.log('getMarker');
	  this.dispatchEvent(
		new ShowToastEvent({
		  title: 'Point Latitude - Longitude',
		  message: this.markerLayers['main'].getLatLng().toString()
		})
	  );
	} */

  handleCallout(event) {
    console.log('handleCallout');
    console.log('event.target.value ', event.target.value);
    console.log('event.keyCode ', event.keyCode);
    this.reset();
    if(event.keyCode != 13) {
        console.log('not enter');
        this.searchStreetKey = event.target.value.length >= this.mapSettings.Search_Bar_Min_Search_Key_Street__c ? event.target.value.toUpperCase() : null;
        clearTimeout(this.streetsTimeoutId);
        this.checkIsConfirmDisabled();
        console.log('searchStreetKey ', this.searchStreetKey);
        if(this.searchStreetKey) {
          console.log('this.streetsTimeoutId ', this.streetsTimeoutId);
          console.log('start searching: ', this.searchStreetKey);
          this.streetsTimeoutId = setTimeout(this.callout.bind(this), this.mapSettings.Timeout_Get_Streets__c);
        }
    } else if(event.keyCode == 13 && this.searchStreetKey) {
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
    if((this.streetNames.length == 1 && this.searchStreetKey == this.streetNames[0].value ) || this.streetNames.some(s => s.label == this.searchStreetKey)) {
        console.log('CALLOUT: getStreetDetails');
        console.log('single street: ', this.streetNames.find(s => s.label == this.searchStreetKey).label);
        this.selectedStreet = this.streetNames.find(s => s.label == this.searchStreetKey).label;
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
    //this.streetNames = [];
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
          if(data.length) {
            console.log('streets exists');
            let streetNames = [];
            data.forEach(s => {
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
          if((this.streetNames.length == 1 && this.searchStreetKey == this.streetNames[0].value)) {
                console.log('CALLOUT: getStreetDetails2');
                console.log('single street: ', this.streetNames.find(s => s.label == this.searchStreetKey).label);
                this.selectedStreet = this.streetNames.find(s => s.label == this.searchStreetKey).label;
                this.calloutGetStreetDetails();
          }
      });
  }

  calloutGetStreetDetails() {
    console.group('calloutGetStreetDetails');
    console.log('selectedStreet ' + this.selectedStreet);
    console.log('searchStreetNumberKey ' + this.searchStreetNumberKey);
    if(this.selectedStreet) {
      console.log('start searching for details: ', this.selectedStreet);
      this.isLoading = true;
      getStreetDetails({
        streetName: this.selectedStreet,
        streetNumber: ''
      })
      .then((data) => {
        console.log('data ', data);
        if(Object.keys(data).length) {
          console.log('setting marker');
          this.address = data.streetName;
          this.streetDetails = data.streetDetails;
          let numberAddressesOptions = [];
          for(let key in this.streetDetails) {
            //console.log('key ', key);
            const option = {
              label: key,
              value: key
            };
            numberAddressesOptions.push(option);
          }
          numberAddressesOptions = numberAddressesOptions.sort((a, b) => {
            return a.label.localeCompare(b.label, undefined, {numeric: true, sensitivity: 'base'});
          });
          this.numberAddressesOptions = numberAddressesOptions;
        }
      })
      .catch((error) => {
        console.log('error ', error);
        this.reset();
        this.showToast(error.body.message, '', 'error');
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
    this.setFullAddress();
    this.setMarker([this.lat, this.lng]);
    this.checkIsConfirmDisabled();
    console.groupEnd('handleNumberChange');
  }

  checkIsConfirmDisabled() {
    console.group('checkIsConfirmDisabled');
    this.isConfirmDisabled = this.selectedStreet && String(this.selectedNumberStreet) && this.lat && this.lng && this.municipality && this.address && String(this.numberAddress) ? false : true;
    console.log('isConfirmDisabled ', this.isConfirmDisabled);
    console.groupEnd('checkIsConfirmDisabled');
  }

  setFullAddress() {
    console.group('setFullAddress');
    let fullAddress = this.address ? this.address : null;
    fullAddress = fullAddress && String(this.numberAddress) ? fullAddress + ', ' + this.numberAddress : fullAddress;
    fullAddress = fullAddress && this.letterAddress ? fullAddress + this.letterAddress : fullAddress;
    this.fullAddress = fullAddress;
    console.log('fullAddress ', this.fullAddress);
    console.groupEnd('setFullAddress');
  }

  handleReturn(event) {
    console.group('handleReturn');
    /* let fullAddress = this.address ? this.address : null;
		fullAddress =
			fullAddress && this.numberAddress
				? fullAddress + ", " + this.numberAddress
				: fullAddress; */
	console.log('event.target.dataset.label ', event.target.dataset.label);
    if(event.target.dataset.label === this.label.back) {
        console.log('back');
        const selectedEvent = new CustomEvent('goback');
        this.dispatchEvent(selectedEvent);
    } else {
        console.log('confirm');
        let params = {
              lat: this.lat,
              lng: this.lng,
              municipality: this.municipality,
              fullAddress: this.fullAddress,
              address: this.address,
              numberAddress: this.numberAddress,
              letterAddress: this.letterAddress
        };
        console.log('params ', params);
        const selectedEvent = new CustomEvent('goback', { detail: params });
        this.dispatchEvent(selectedEvent);
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
}