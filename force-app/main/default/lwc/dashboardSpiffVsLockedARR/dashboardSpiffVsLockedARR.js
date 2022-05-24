import { LightningElement } from 'lwc';
import images from '@salesforce/resourceUrl/DashboardSpiff';
import loadSpiff from '@salesforce/apex/Ctrl_DashboardPageApp.initSpiffVsLockedARR';

export default class DashboardSpiff extends LightningElement {
    title = '';
    spiff = '';
    mainImage;

    connectedCallback(){
        this.mainImage = images + '/money-with-wings.png';
        this.init();
    }

    init(){
        loadSpiff()
        .then((data) => {
            console.log('Spiff data: ' + JSON.stringify(data));
            this.title = data.title;
            this.spiff = this.formatNumber(data.spiff);
        })
        .catch((err) => { console.log('Error loading Spiff Vs. Locked ARR: ' + err); });
    }

    /**
    * @param {Number} num Unformatted number
    * @return {Number} Formatted number
    */
     formatNumber(num){
        if (this.isEmpty(num)) return num;
        let numAsString = num.toString();
        let numProcessed = '';
        if (numAsString.length < 4)  return num;
        for (let i = 0; i < numAsString.length; i++){
            if (i != 0 && (i % 3) == 0) numProcessed = ',' + numProcessed;
            numProcessed = numAsString.substr((numAsString.length - 1 - i), 1) + numProcessed;
        }
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