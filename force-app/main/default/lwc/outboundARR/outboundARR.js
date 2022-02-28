import { LightningElement } from 'lwc';
import tierBadges from '@salesforce/resourceUrl/DashboardTierStatus';
import loadTierData from '@salesforce/apex/Ctrl_DashboardPageApp.getTierStatus';

export default class OutboundARR extends LightningElement {
    outboundArrLabel = '';
    outboundArrPositionStyle = '';

    connectedCallback(){
        loadTierData()
        .then((data) => {
            if (!this.isEmpty(data)){
                var outBoundArrLeftPos = 0;
                if (data.outbound_arr <= 150000){
                    outBoundArrLeftPos = (data.outbound_arr / 1000 / 1.5 * 30 / 100);
                }
                if (data.outbound_arr > 150000 && data.outbound_arr <= 375000){
                    outBoundArrLeftPos = (data.outbound_arr / 1000 / 3.75 * 45 / 100) + 30;
                }
                if (data.outbound_arr > 375000){
                    outBoundArrLeftPos = (data.outbound_arr / 1000 / 5 * 25 / 100) + 75;
                    if (outBoundArrLeftPos > 100) outBoundArrLeftPos = 100;
                }
                this.outboundArrLabel = '$' + Math.round((data.outbound_arr / 1000)) + 'k';
                if (outBoundArrLeftPos < 8){
                    this.outboundArrPositionStyle = 'left: ' + outBoundArrLeftPos + '%;';
                    this.outboundArrPositionStyle += 'background-image: url(' + tierBadges + '/RightHalfArrowMarker.png);';
                    this.outboundArrPositionStyle += 'background-position-x: left;'
                } else if (outBoundArrLeftPos > 84) {
                    this.outboundArrPositionStyle = 'right: calc(-' + outBoundArrLeftPos + '% + 52px);';
                    this.outboundArrPositionStyle += 'background-image: url(' + tierBadges + '/LeftHalfArrowMarker.png);';
                    this.outboundArrPositionStyle += 'background-position-x: right;'
                } else {
                    this.outboundArrPositionStyle = 'left: calc(' + outBoundArrLeftPos + '% - 26px);';
                    this.outboundArrPositionStyle += 'background-image: url(' + tierBadges + '/ArrowMarker.png);';
                }
            }
        })
        .catch((err) => { console.log('Error loading tier data: ' + JSON.stringify(err)); });
    }

    /**
    * @param {Object} obj Any object to test
    * @return {Boolean} true if empty
    */
     isEmpty(obj){
        return ((obj == null || obj == 'null' || typeof(obj) == 'undefined' || obj == 'undefined' || obj == '') && obj != 0);
    }
}