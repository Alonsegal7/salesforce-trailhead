import { LightningElement } from 'lwc';
import init from '@salesforce/apex/Ctrl_DashboardPageApp.initPortfolioManagment';
import greenURL from '@salesforce/label/c.Dashboard_GreenBucket';
import orangeURL from '@salesforce/label/c.Dashboard_OrangeBucket';

export default class PortfolioManagement extends LightningElement {
    dataLoaded = false;
    orangeCount = 0;
    greenCount = 0;
    orangeTotalARR = 0;
    greenTotalARR = 0;
    greenBarTitle = '';
    orangeBarTitle = '';
    greenBarStyle = '';
    orangeBarStyle = '';
    greenBucketURL = '';
    orangeBucketURL = '';
    
    connectedCallback(){
        this.greenBucketURL = greenURL;
        this.orangeBucketURL = orangeURL;
        
        init()
        .then((data) => {
            if (!this.isEmpty(data)){
                console.log('Portfolio Management: ' + JSON.stringify(data));
                this.orangeCount = data.orange_count;
                this.greenCount = data.green_count;
                this.orangeTotalARR = Math.round(data.orange_total_arr / 1000);
                this.greenTotalARR = Math.round(data.green_total_arr / 1000);

                let totalAccounts = ((data.orange_count + data.green_count) != 0 ? (data.orange_count + data.green_count) : 1);
                let greenRate = Math.round(data.green_count * 100 / totalAccounts);
                let orangeRate = ((data.orange_count + data.green_count) != 0) != 0 ? (100 - greenRate) : 0;
                this.greenBarTitle = greenRate + '%';
                this.orangeBarTitle = orangeRate + '%';
                this.greenBarStyle = 'width: ' + greenRate + '%;';
                this.orangeBarStyle = 'width: ' + orangeRate + '%;';
            }
        })
        .catch((err) => { console.log('Error initializing Portfolio Management: ' + JSON.stringify(err)); });
    }

    /**
    * @param {Object} obj Any object to test
    * @return {Boolean} true if empty
    */
     isEmpty(obj){
        return (obj == null || obj == 'null' || typeof(obj) == 'undefined' || obj == 'undefined' || obj == '');
    }
}