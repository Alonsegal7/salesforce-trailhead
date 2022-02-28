import { LightningElement } from 'lwc';
import tierBadges from '@salesforce/resourceUrl/DashboardTierStatus';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import jQuery from '@salesforce/resourceUrl/jQuery';
import jQueryGauge from '@salesforce/resourceUrl/jQueryGauge';
import loadTierData from '@salesforce/apex/Ctrl_DashboardPageApp.getTierStatus';

export default class TierStatus extends LightningElement {
    loadedData;
    gaugeArr = 0;
    badgeSrc;
    gagueLabel = '';
    dataLoaded = false;
    gaugeLoaded = false;
    isPlatinum = false;
    isGold = false;
    isSilver = false;
	isOutboundPlatinum = false;
    isOutboundGold = false;
    isOutboundSilver = false;
	isMapsPlatinum = false;
    isMapsGold = false;
    isMapsSilver = false;
    mapsLabel = '';
    mapsPositionStyle = '';
    outboundArrLabel = '';
    outboundArrPositionStyle = '';

    nextReviewLabel = '';

    jQueryInitialized = false;

    connectedCallback(){
        this.init();
    }

    renderedCallback() {
        if (this.jQueryInitialized) {
            return;
        }
        this.jQueryInitialized = true;

        Promise.all([
            loadScript(this, jQuery + '/jquery-3.6.0.min.js')
        ]).then(() => {
            console.log('jQuery loaded');
            Promise.all([
                loadStyle(this, jQueryGauge + '/jquery-gauge.css'),
                loadScript(this, jQueryGauge + '/jquery-gauge.min.js')
            ]).then(() => {
                console.log('Gauge loaded');
                if (this.dataLoaded){
                    this.initGauge();
                }
            }).catch(error => {
                console.error('Error loading gauge: ' + JSON.stringify(error));
            });
        }).catch(error => {
            console.error('Error loading jQuery: ' + JSON.stringify(error));
        });
    }

    initGauge(){
        console.log('Initializing gauge, total ARR: ' + this.gaugeArr);
        var theObj = $(this.template.querySelector('div.gauge'));        
        // jquery-gauge init
        theObj.gauge({
            values: {
                0 : '$60k',
                33: '$300k',
                66: '$750k',
                100: ''
            },
            colors: {
                0 : '#e2e3eb',
                33: '#ffd02a',
                66: '#97aab9'
            },
            angles: [
                180,
                360
            ],
            lineWidth: 8,
            arrowWidth: 10,
            arrowColor: '#313237',
            inset:true,
          
            value: this.gaugeArr
        });
        this.gaugeLoaded = true;
    }

    init(){
        loadTierData()
        .then((data) => {
            console.log('Loaded raw tier data: ' + JSON.stringify(data));
            if (!this.isEmpty(data)){
                this.loadedData = data;
                /**
                 * Handle Total ARR
                 */
                if (!this.isEmpty(data.partner_tier)){
                    if (data.partner_tier == 'Silver'){
                        this.badgeSrc = tierBadges + '/silver.png';
                        this.isSilver = true;
                    }
                    if (data.partner_tier == 'Gold' || data.partner_tier == 'Gold First Year'){
                        this.badgeSrc = tierBadges + '/gold.png';
                        this.isGold = true;
                    }
                    if (data.partner_tier == 'Platinum'){
                        this.badgeSrc = tierBadges + '/platinum.png';
                        this.isPlatinum = true;
                    }
                }
                if (data.total_arr <= 300000){
                    console.log('Tier gauge - Silver');
                    //this.badgeSrc = tierBadges + '/silver.png';
                    //this.isSilver = true;
                    let t = (data.total_arr / 1000 / 2.4 * 33 / 100) - 8.25;
                    this.gaugeArr = t < 0 ? 0 : t;
                }
                if (data.total_arr > 300000 && data.total_arr <= 750000){
                    console.log('Tier gauge - Gold');
                    // this.badgeSrc = tierBadges + '/gold.png';
                    // this.isGold = true;
                    let t = data.total_arr - 300000;
                    t = t * 100 / 450000 * 33 / 100 + 33;
                    this.gaugeArr = t;
                }
                if (data.total_arr > 750000){
                    console.log('Tier gauge - Platinum');
                    // this.badgeSrc = tierBadges + '/platinum.png';
                    // this.isPlatinum = true;
                    let t = data.total_arr - 750000;
                    t = t * 100 / 350000 * 66 / 100 + 66;
                    this.gaugeArr = t;
                    if (this.gaugeArr > 100) this.gaugeArr = 100;
                }
                console.log('Tier gauge - Final point: ' + this.gaugeArr);
                
                if ((data.total_arr / 1000) !== Math.round((data.total_arr / 1000))){
                    this.gagueLabel = '$' + this.formatNumber((data.total_arr / 1000).toFixed(1)) + 'k ARR';
                } else {
                    this.gagueLabel = '$' + this.formatNumber(Math.round((data.total_arr / 1000))) + 'k ARR';
                }
                
                /**
                 * .Handle Total ARR
                 */
                
                this.nextReviewLabel = data.next_review;
            }

            this.dataLoaded = true;

            if (!this.gaugeLoaded){
                this.initGauge();
            }
        })
        .catch((err) => { console.log('Error loading tier data #1: ' + err); });
    }

    /**
    * @param {Number} num Unformatted number
    * @return {Number} Formatted number
    */
     formatNumber(num){
        if (this.isEmpty(num)) return num;
        let decimalPart = '';
        let numAsString = num.toString();
        let numProcessed = '';
        if (numAsString.indexOf('.') > -1){
            decimalPart = numAsString.split('.')[1];
            numAsString = numAsString.split('.')[0];
        }
        if (numAsString.length < 4)  return num;
        for (let i = 0; i < numAsString.length; i++){
            if (i != 0 && (i % 3) == 0) numProcessed = ',' + numProcessed;
            numProcessed = numAsString.substr((numAsString.length - 1 - i), 1) + numProcessed;
        }
        if (decimalPart != '') numProcessed = numProcessed + '.' + decimalPart;
        return numProcessed;
    }

    /**
    * @param {Object} obj Any object to test
    * @return {Boolean} true if empty
    */
    isEmpty(obj){
        return (obj == null || obj == 'null' || typeof(obj) == 'undefined' || obj == 'undefined' || obj == '');
    }
}