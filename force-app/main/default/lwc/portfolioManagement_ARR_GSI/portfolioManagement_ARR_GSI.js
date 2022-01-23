import { LightningElement } from 'lwc';
import init from '@salesforce/apex/Ctrl_DashboardPageApp.initARRGSIPortfolioManagment';
import greenURL from '@salesforce/label/c.Dashboard_GreenBucket';
import orangeURL from '@salesforce/label/c.Dashboard_OrangeBucket';

export default class PortfolioManagement_ARR_GSI extends LightningElement {
    dataLoaded = false;
    count = 0;
    totalARR = 0;
    totalInfluenced = 0;
    totalSourced = 0;
    purpleBarTitle = '';
    blueBarTitle = '';
    purpleBarStyle = '';
    blueBarStyle = '';
    greenBucketURL = '';
    orangeBucketURL = '';
    portfolioARRURL = '';
    
    connectedCallback(){
        this.greenBucketURL = 'https://monday.force.com/gsis/s/report/00O7T0000017euKUAQ/number-of-accounts-gsis?queryScope=everything';
        this.orangeBucketURL = 'https://monday.force.com/gsis/s/report/00O7T0000017euUUAQ/total-arr-gsis-portal?queryScope=everything';
        this.portfolioARRURL = 'https://monday.force.com/gsis/s/report/00O7T0000017euUUAQ/total-arr-gsis-portal?queryScope=everything';
        
        init()
        .then((data) => {
            if (!this.isEmpty(data)){
                console.log('ARR GSI Portfolio Management: ' + JSON.stringify(data));
                this.count = data.count;
                this.totalARR = this.formatNumber(data.total);
                this.totalInfluenced = Math.round(data.totalInfluenced / 1000);
                this.totalSourced = Math.round(data.totalSourced / 1000);

                let totalARR = ((this.totalInfluenced + this.totalSourced) != 0 ? (this.totalInfluenced + this.totalSourced) : 1);
                let purpleRate = Math.round(this.totalInfluenced * 100 / totalARR);
                let blueRate = ((this.totalInfluenced + this.totalSourced) != 0) != 0 ? (100 - purpleRate) : 0;
                this.purpleBarTitle = purpleRate + '%';
                this.blueBarTitle = blueRate + '%';
                this.purpleBarStyle = 'width: ' + purpleRate + '%;';
                this.blueBarStyle = 'width: ' + blueRate + '%;';
            }
        })
        .catch((err) => { console.log('Error initializing Portfolio Management: ' + err); });
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